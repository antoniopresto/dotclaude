# F013 + F014: SQLite Storage Architecture + CLI Utility

## Overview

Replace JSON/TXT files with SQLite + FTS5 for projects managed by HQ.
Provide a CLI utility (`harness`) for AI agents and humans to interact programmatically.

**Scope:** This is for projects that HQ will manage, NOT for HQ's own `.harness/` folder.

---

## F013: Storage Architecture

### Database Location
```
<project>/.harness/harness.db
```

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Primary Keys** | ULID (TEXT 26 chars) | Sortable by timestamp, no coordination needed, URL-safe |
| **Timestamps** | ISO 8601 TEXT | Human-readable, sortable, SQLite datetime() compatible |
| **Booleans** | TEXT 'true'/'false' | Explicit semantics, JSON-compatible |
| **Enums** | UPPERCASE TEXT + CHECK | Clear constants, enforced at DB level |
| **Naming** | Semantic prefixes | `project_tasks`, `work_sessions` - clear domain context |

### Schema

```sql
-- ============================================================================
-- PRAGMAS (run on every connection)
-- ============================================================================
PRAGMA journal_mode = WAL;          -- Better concurrent access
PRAGMA synchronous = NORMAL;        -- Good balance of safety/speed
PRAGMA foreign_keys = OFF;          -- Using composite IDs, no FK enforcement needed

-- ============================================================================
-- SCHEMA VERSION
-- ============================================================================
CREATE TABLE schema_metadata (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
) WITHOUT ROWID;
INSERT INTO schema_metadata (key, value) VALUES ('version', '1.0.0');

-- ============================================================================
-- ENUMS (documented as CHECK constraints)
-- ============================================================================
-- TaskStatus: BACKLOG | TODO | DOING | REVIEW | QA | DONE

-- ============================================================================
-- CORE TABLES
-- ============================================================================

-- Project Tasks (replaces features.json)
CREATE TABLE project_tasks (
  id TEXT PRIMARY KEY CHECK(length(id) = 26),           -- ULID
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'BACKLOG'
    CHECK(status IN ('BACKLOG', 'TODO', 'DOING', 'REVIEW', 'QA', 'DONE')),
  category TEXT,
  sort_order REAL NOT NULL DEFAULT 0.0,                 -- float for fractional ordering
  is_passed TEXT NOT NULL DEFAULT 'false'
    CHECK(is_passed IN ('true', 'false')),
  created_at TEXT NOT NULL,                             -- ISO 8601: 2026-01-04T15:30:00Z
  updated_at TEXT NOT NULL                              -- ISO 8601
);

-- Task Steps (checklist items within a task)
-- ID format: task#{task_ulid}#{step_ulid} (prefix = parent table name)
-- Note: Steps are append-only, ordered by ULID timestamp. No reordering.
CREATE TABLE task_steps (
  id TEXT PRIMARY KEY,                                  -- Composite: task#{task_ulid}#{step_ulid}
  description TEXT NOT NULL,
  is_completed TEXT NOT NULL DEFAULT 'false'
    CHECK(is_completed IN ('true', 'false')),
  created_at TEXT NOT NULL
) WITHOUT ROWID;
-- Query steps for task X: WHERE id GLOB 'task#X#*' ORDER BY id

-- Work Sessions (AI/human work periods)
CREATE TABLE work_sessions (
  id TEXT PRIMARY KEY CHECK(length(id) = 26),           -- ULID
  summary TEXT,
  started_at TEXT NOT NULL,                             -- ISO 8601
  ended_at TEXT                                         -- ISO 8601, NULL if ongoing
);

-- Project Progress (session log entries, replaces progress.txt)
-- ID format: session#{session_ulid}#{progress_ulid} (prefix = parent table name)
-- Note: No WITHOUT ROWID - needs implicit rowid for FTS5 sync
CREATE TABLE project_progress (
  id TEXT PRIMARY KEY,                                  -- Composite: session#{session_ulid}#{progress_ulid}
  content TEXT NOT NULL,
  created_at TEXT NOT NULL                              -- ISO 8601
);
-- Query progress for session X: WHERE id GLOB 'session#X#*' ORDER BY id

-- ============================================================================
-- FULL-TEXT SEARCH (FTS5)
-- ============================================================================

CREATE VIRTUAL TABLE project_tasks_fts USING fts5(
  title,
  description,
  category,
  content='project_tasks',
  content_rowid='rowid'
);

CREATE VIRTUAL TABLE project_progress_fts USING fts5(
  content,
  content='project_progress',
  content_rowid='rowid'
);

-- ============================================================================
-- FTS SYNC TRIGGERS
-- ============================================================================

-- project_tasks -> project_tasks_fts
CREATE TRIGGER project_tasks_fts_insert AFTER INSERT ON project_tasks BEGIN
  INSERT INTO project_tasks_fts(rowid, title, description, category)
  VALUES (NEW.rowid, NEW.title, NEW.description, NEW.category);
END;

CREATE TRIGGER project_tasks_fts_delete AFTER DELETE ON project_tasks BEGIN
  INSERT INTO project_tasks_fts(project_tasks_fts, rowid, title, description, category)
  VALUES('delete', OLD.rowid, OLD.title, OLD.description, OLD.category);
END;

CREATE TRIGGER project_tasks_fts_update AFTER UPDATE ON project_tasks BEGIN
  INSERT INTO project_tasks_fts(project_tasks_fts, rowid, title, description, category)
  VALUES('delete', OLD.rowid, OLD.title, OLD.description, OLD.category);
  INSERT INTO project_tasks_fts(rowid, title, description, category)
  VALUES (NEW.rowid, NEW.title, NEW.description, NEW.category);
END;

-- project_progress -> project_progress_fts
CREATE TRIGGER project_progress_fts_insert AFTER INSERT ON project_progress BEGIN
  INSERT INTO project_progress_fts(rowid, content)
  VALUES (NEW.rowid, NEW.content);
END;

CREATE TRIGGER project_progress_fts_delete AFTER DELETE ON project_progress BEGIN
  INSERT INTO project_progress_fts(project_progress_fts, rowid, content)
  VALUES('delete', OLD.rowid, OLD.content);
END;

CREATE TRIGGER project_progress_fts_update AFTER UPDATE ON project_progress BEGIN
  INSERT INTO project_progress_fts(project_progress_fts, rowid, content)
  VALUES('delete', OLD.rowid, OLD.content);
  INSERT INTO project_progress_fts(rowid, content)
  VALUES (NEW.rowid, NEW.content);
END;

-- ============================================================================
-- INDEXES
-- ============================================================================

-- project_tasks indexes
CREATE INDEX idx_project_tasks_status ON project_tasks(status);
CREATE INDEX idx_project_tasks_sort_order ON project_tasks(sort_order);
CREATE INDEX idx_project_tasks_created_at ON project_tasks(created_at);

-- work_sessions indexes
CREATE INDEX idx_work_sessions_started_at ON work_sessions(started_at);

-- Note: task_steps and project_progress don't need separate indexes
-- Prefix queries use: WHERE id GLOB 'task#<parent_ulid>#*' or 'session#<parent_ulid>#*'
-- SQLite PK B-tree index handles prefix matching efficiently
```

### ID Strategy

#### Standalone Entities (ULID)
```
01ARZ3NDEKTSV4RRFFQ69G5FAV
|-------||------------|
Timestamp   Randomness
(48-bit)    (80-bit)
```

Used for: `project_tasks`, `work_sessions`

#### Child Entities (Composite ID)

**Format:** `{parent_table}#{parent_ulid}#{child_ulid}`

```
task#01ARZ3NDEKTSV4RRFFQ69G5FAV#01BRZXYZ...
|----||--------------------------||--------|
Parent     Parent ULID             Child ULID
Table

session#01ARZ3NDEKTSV4RRFFQ69G5FAV#01BRZXYZ...
|------||--------------------------||--------|
Parent       Parent ULID             Child ULID
Table
```

Used for:
- `task_steps`: `task#{task_ulid}#{step_ulid}` (parent = `project_tasks`)
- `project_progress`: `session#{session_ulid}#{progress_ulid}` (parent = `work_sessions`)

Design notes:
- Prefix = parent table name (singular form for readability)
- Child portion uses ULID for timestamp-based ordering
- Append-only design (no reordering of children)

#### Benefits
- **No FK column needed** - parent ID embedded in child ID
- **Prefix queries** - `WHERE id GLOB 'task#01ARZ*'` gets all steps for that task
- **Natural ordering** - ULID suffix sorts by creation time
- **Single index** - PK B-tree handles prefix matching efficiently

### Pagination Model

All list methods return:
```typescript
interface PaginatedResult<T> {
  items: T[];
  hasNext: boolean;
  hasPrev: boolean;
  nextCursor: string | null;  // base64 encoded cursor
  prevCursor: string | null;
}
```

Cursor-based using `id` or `created_at` for stable pagination.

---

## F014: CLI Utility (`harness`)

### Binary Structure

Add to `src-tauri/Cargo.toml`:
```toml
[[bin]]
name = "harness"
path = "src/bin/harness.rs"
```

Shared library code in `src-tauri/src/db/` used by both Tauri app and CLI.

### Commands

```bash
# Setup
harness init                              # Create .harness/harness.db
harness migrate                           # Migrate from legacy TXT/JSON
harness db status                         # Show DB info (size, counts)

# Tasks
harness task add "Title" [-d "desc"] [-c category] [-s status]
harness task list [--status=X] [--limit=N] [--cursor=X]
harness task search "query" [--limit=N] [--cursor=X]
harness task get <id>
harness task update <id> [--status=X] [--title=X] [--desc=X] [--order=X]
harness task delete <id>
harness task reorder <id> --after=<other_id>  # Reposition in order

# Task Steps
harness step add <task_id> "description"
harness step complete <step_id>
harness step uncomplete <step_id>
harness step list <task_id>
harness step delete <step_id>

# Progress
harness progress add "content" [--session=X]
harness progress list [--limit=N] [--cursor=X]
harness progress search "query" [--limit=N] [--cursor=X]

# Sessions
harness session start [--summary="X"]
harness session end [--summary="X"]
harness session list [--limit=N]
harness session current

# Info
harness status                            # Project summary (tasks by status, etc.)
```

### Output Formats

```bash
harness task list              # Human-readable table
harness task list --json       # JSON for AI consumption
harness task list --quiet      # IDs only
```

### Exit Codes

- `0`: Success
- `1`: General error
- `2`: Not a harness project (no .harness/)
- `3`: Database error

---

## F006 Update: Project Setup

When HQ opens a directory:

| Scenario | Action |
|----------|--------|
| Has `.harness/harness.db` | Open normally |
| Has `.harness/` with TXT/JSON (legacy) | Show "Migrate to SQLite" button |
| No `.harness/` folder | Show "Initialize Harness" button |

Both buttons invoke equivalent of `harness init` or `harness migrate`.

---

## Implementation Order

### Phase 1: Core Storage (Rust)
1. Add `rusqlite` dependency with FTS5 feature
2. Create `src-tauri/src/db/mod.rs` - DB module
3. Create `src-tauri/src/db/schema.rs` - Schema initialization
4. Create `src-tauri/src/db/tasks.rs` - Task CRUD + FTS search
5. Create `src-tauri/src/db/progress.rs` - Progress CRUD + FTS search
6. Create `src-tauri/src/db/sessions.rs` - Session management
7. Create `src-tauri/src/db/pagination.rs` - Cursor pagination helpers

### Phase 2: CLI Binary
1. Create `src-tauri/src/bin/harness.rs` - CLI entry point
2. Add `clap` for argument parsing
3. Implement subcommands: init, task, step, progress, session, status
4. Add output formatters (table, json, quiet)

### Phase 3: Tauri Integration
1. Create Tauri commands that wrap DB operations
2. Update frontend to use new commands
3. Add project detection logic (has DB? has legacy? nothing?)

### Phase 4: Migration Tool
1. Create `harness migrate` command
2. Parse `features.json` → insert into `tasks` table
3. Parse `progress.txt` → insert into `progress` table
4. Preserve original files as `.harness/backup/`

---

## Files to Create

```
src-tauri/
├── src/
│   ├── bin/
│   │   └── harness.rs          # CLI entry point
│   ├── db/
│   │   ├── mod.rs              # Module exports
│   │   ├── types.rs            # TaskStatus enum, structs (ProjectTask, etc.)
│   │   ├── schema.rs           # CREATE TABLE statements
│   │   ├── connection.rs       # DB connection management
│   │   ├── tasks.rs            # Task CRUD + FTS search
│   │   ├── steps.rs            # Step CRUD
│   │   ├── progress.rs         # Progress CRUD + FTS search
│   │   ├── sessions.rs         # Session management
│   │   ├── pagination.rs       # Cursor-based pagination
│   │   └── migrate.rs          # Legacy TXT/JSON migration
│   └── lib.rs                  # Add db module
```

## Files to Modify

```
src-tauri/Cargo.toml            # Add rusqlite, clap
src-tauri/src/lib.rs            # Register db module + Tauri commands
src/components/KanbanBoard.tsx  # Use new Tauri commands (later)
.harness/features.json          # Add F013, F014 entries
```

## Dependencies to Add

```toml
# src-tauri/Cargo.toml
rusqlite = { version = "0.32", features = ["bundled", "fts5"] }
clap = { version = "4", features = ["derive"] }
ulid = "1"                    # ULID generation
chrono = { version = "0.4", features = ["serde"] }  # ISO 8601 timestamps
```

### Rust Types (Enums)

```rust
// src-tauri/src/db/types.rs

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum TaskStatus {
    Backlog,
    Todo,
    Doing,
    Review,
    Qa,
    Done,
}

impl TaskStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Backlog => "BACKLOG",
            Self::Todo => "TODO",
            Self::Doing => "DOING",
            Self::Review => "REVIEW",
            Self::Qa => "QA",
            Self::Done => "DONE",
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProjectTask {
    pub id: String,                    // ULID
    pub title: String,
    pub description: Option<String>,
    pub status: TaskStatus,
    pub category: Option<String>,
    pub sort_order: f64,
    pub is_passed: bool,               // Rust bool, serialized as "true"/"false"
    pub created_at: String,            // ISO 8601
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskStep {
    pub id: String,                    // Composite: task#{task_ulid}#{step_ulid}
    pub description: String,
    pub is_completed: bool,
    pub created_at: String,
}

impl TaskStep {
    /// Prefix for composite ID (parent table name, singular)
    pub const PREFIX: &'static str = "task";

    /// Extract parent task ULID from composite ID
    pub fn task_id(&self) -> &str {
        // id = "task#01ARZ3NDEKTSV4RRFFQ69G5FAV#01BRZXYZ..."
        self.id.split('#').nth(1).unwrap_or("")
    }

    /// Generate composite ID for a new step
    pub fn make_id(task_id: &str, step_ulid: &str) -> String {
        format!("{}#{}#{}", Self::PREFIX, task_id, step_ulid)
    }

    /// Generate GLOB pattern to find all steps for a task
    pub fn glob_pattern(task_id: &str) -> String {
        format!("{}#{}#*", Self::PREFIX, task_id)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WorkSession {
    pub id: String,                    // ULID
    pub summary: Option<String>,
    pub started_at: String,
    pub ended_at: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProjectProgress {
    pub id: String,                    // Composite: session#{session_ulid}#{progress_ulid}
    pub content: String,
    pub created_at: String,
}

impl ProjectProgress {
    /// Prefix for composite ID (parent table name, singular)
    pub const PREFIX: &'static str = "session";

    /// Extract parent session ULID from composite ID
    pub fn session_id(&self) -> &str {
        // id = "session#01ARZ3NDEKTSV4RRFFQ69G5FAV#01BRZXYZ..."
        self.id.split('#').nth(1).unwrap_or("")
    }

    /// Generate composite ID for a new progress entry
    pub fn make_id(session_id: &str, progress_ulid: &str) -> String {
        format!("{}#{}#{}", Self::PREFIX, session_id, progress_ulid)
    }

    /// Generate GLOB pattern to find all progress for a session
    pub fn glob_pattern(session_id: &str) -> String {
        format!("{}#{}#*", Self::PREFIX, session_id)
    }
}
```

---

## Success Criteria

- [ ] `harness init` creates `.harness/harness.db` with correct schema
- [ ] `harness task add/list/search/update/delete` work correctly
- [ ] `harness progress add/list/search` work correctly
- [ ] FTS5 search returns relevant results
- [ ] Pagination with prev/next cursors works
- [ ] `--json` output is valid JSON parseable by AI
- [ ] `harness migrate` successfully imports legacy TXT/JSON
- [ ] Tauri app can detect and handle all 3 project states

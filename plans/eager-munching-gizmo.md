# F016: Semantic Search - Implementation Plan

## Overview

Add vector-based semantic search using **sqlite-vec** + **fastembed** with automatic embedding generation on CRUD operations.

**Goal**: "OAuth" finds "OAuth2" and "authentication" | "bug fix" finds "error correction"

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CRUD Flow                               │
├─────────────────────────────────────────────────────────────────┤
│  create_task(title, desc)                                       │
│       │                                                         │
│       ▼                                                         │
│  EmbeddingService::embed(title + " " + desc)                   │
│       │                                                         │
│       ▼                                                         │
│  ┌─────────────┐    ┌──────────────────┐                       │
│  │project_tasks│───▶│task_embeddings   │                       │
│  │   (rowid)   │    │(rowid, embedding)│                       │
│  └─────────────┘    └──────────────────┘                       │
│                              │                                  │
│                              ▼                                  │
│                     KNN MATCH query                             │
│                     ORDER BY distance                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Files to Modify/Create

| File | Action | Purpose |
|------|--------|---------|
| `src-tauri/Cargo.toml` | MODIFY | Add sqlite-vec, fastembed, zerocopy |
| `src-tauri/src/db/mod.rs` | MODIFY | Export embeddings module |
| `src-tauri/src/db/schema.rs` | MODIFY | Add vec0 tables |
| `src-tauri/src/db/embeddings.rs` | CREATE | EmbeddingService + CRUD |
| `src-tauri/src/db/tasks.rs` | MODIFY | Hook embedding in CRUD |
| `src-tauri/src/db/progress.rs` | MODIFY | Hook embedding in CRUD |
| `src-tauri/src/bin/harness.rs` | MODIFY | Add --semantic flag |

---

## Phase 1: Dependencies & Schema

### 1.1 Cargo.toml additions

```toml
# Semantic search (F016)
sqlite-vec = "0.1.7-alpha.2"
fastembed = "4"
zerocopy = { version = "0.8", features = ["derive"] }
```

### 1.2 Schema additions (schema.rs)

```rust
pub const VEC_SCHEMA_SQL: &str = r#"
-- Task embeddings (384 dims = AllMiniLML6V2)
CREATE VIRTUAL TABLE IF NOT EXISTS task_embeddings USING vec0(
    embedding float[384]
);

-- Progress embeddings
CREATE VIRTUAL TABLE IF NOT EXISTS progress_embeddings USING vec0(
    embedding float[384]
);
"#;
```

**Note**: vec0 uses implicit rowid that matches source table rowid.

### 1.3 Extension registration

```rust
// In connection.rs or schema.rs
use sqlite_vec::sqlite3_vec_init;
use rusqlite::ffi::sqlite3_auto_extension;

pub fn register_sqlite_vec() {
    unsafe {
        sqlite3_auto_extension(Some(std::mem::transmute(
            sqlite3_vec_init as *const ()
        )));
    }
}
```

---

## Phase 2: EmbeddingService (embeddings.rs)

### 2.1 Singleton pattern with lazy init

```rust
use std::sync::OnceLock;
use fastembed::{TextEmbedding, InitOptions, EmbeddingModel};
use parking_lot::Mutex;

static EMBEDDING_SERVICE: OnceLock<Mutex<TextEmbedding>> = OnceLock::new();

pub fn get_embedding_service() -> &'static Mutex<TextEmbedding> {
    EMBEDDING_SERVICE.get_or_init(|| {
        let model = TextEmbedding::try_new(
            InitOptions::new(EmbeddingModel::AllMiniLML6V2)
                .with_show_download_progress(true)
        ).expect("Failed to load embedding model");
        Mutex::new(model)
    })
}
```

### 2.2 Core functions

```rust
/// Generate embedding for text
pub fn generate_embedding(text: &str) -> DbResult<Vec<f32>> {
    let model = get_embedding_service().lock();
    let embeddings = model.embed(vec![text], None)
        .map_err(|e| DbError::Embedding(e.to_string()))?;
    Ok(embeddings.into_iter().next().unwrap_or_default())
}

/// Store task embedding (linked by rowid)
pub fn store_task_embedding(conn: &Connection, task_rowid: i64, embedding: &[f32]) -> DbResult<()> {
    conn.execute(
        "INSERT INTO task_embeddings(rowid, embedding) VALUES (?1, ?2)",
        params![task_rowid, embedding.as_bytes()],
    )?;
    Ok(())
}

/// Update task embedding
pub fn update_task_embedding(conn: &Connection, task_rowid: i64, embedding: &[f32]) -> DbResult<()> {
    conn.execute(
        "DELETE FROM task_embeddings WHERE rowid = ?1",
        params![task_rowid],
    )?;
    store_task_embedding(conn, task_rowid, embedding)
}

/// Delete task embedding
pub fn delete_task_embedding(conn: &Connection, task_rowid: i64) -> DbResult<()> {
    conn.execute(
        "DELETE FROM task_embeddings WHERE rowid = ?1",
        params![task_rowid],
    )?;
    Ok(())
}

/// Semantic search for tasks (KNN)
pub fn search_tasks_semantic(
    conn: &Connection,
    query: &str,
    limit: Option<usize>,
) -> DbResult<Vec<ProjectTask>> {
    let query_embedding = generate_embedding(query)?;
    let limit = limit.unwrap_or(20);

    let mut stmt = conn.prepare(r#"
        SELECT p.id, p.title, p.description, p.status, p.category,
               p.sort_order, p.is_passed, p.created_at, p.updated_at,
               e.distance
        FROM project_tasks p
        JOIN task_embeddings e ON p.rowid = e.rowid
        WHERE e.embedding MATCH ?1
        ORDER BY e.distance
        LIMIT ?2
    "#)?;

    let rows = stmt.query_map(
        params![query_embedding.as_bytes(), limit as i64],
        |row| row_to_task(row)
    )?;

    rows.collect::<Result<Vec<_>, _>>().map_err(Into::into)
}
```

### 2.3 Similar functions for progress

- `store_progress_embedding()`
- `update_progress_embedding()`
- `delete_progress_embedding()`
- `search_progress_semantic()`

---

## Phase 3: CRUD Hooks

### 3.1 tasks.rs modifications

```rust
// In create_task()
pub fn create_task(conn: &Connection, task: &ProjectTask) -> DbResult<()> {
    // Existing INSERT code...
    conn.execute(/* INSERT INTO project_tasks ... */)?;

    // NEW: Get rowid and generate embedding
    let rowid = conn.last_insert_rowid();
    let text = format!("{} {}", task.title, task.description.as_deref().unwrap_or(""));
    let embedding = embeddings::generate_embedding(&text)?;
    embeddings::store_task_embedding(conn, rowid, &embedding)?;

    Ok(())
}

// In update_task()
pub fn update_task(conn: &Connection, id: &str, update: TaskUpdate) -> DbResult<bool> {
    // Check if title or description changed
    let needs_reembed = update.title.is_some() || update.description.is_some();

    // Existing UPDATE code...

    if needs_reembed && rows_affected > 0 {
        // Get rowid
        let rowid: i64 = conn.query_row(
            "SELECT rowid FROM project_tasks WHERE id = ?1",
            [id],
            |row| row.get(0)
        )?;

        // Get current title+description
        let (title, desc): (String, Option<String>) = conn.query_row(
            "SELECT title, description FROM project_tasks WHERE id = ?1",
            [id],
            |row| Ok((row.get(0)?, row.get(1)?))
        )?;

        let text = format!("{} {}", title, desc.as_deref().unwrap_or(""));
        let embedding = embeddings::generate_embedding(&text)?;
        embeddings::update_task_embedding(conn, rowid, &embedding)?;
    }

    Ok(rows_affected > 0)
}

// In delete_task()
pub fn delete_task(conn: &Connection, id: &str) -> DbResult<bool> {
    // Get rowid before delete
    let rowid: Option<i64> = conn.query_row(
        "SELECT rowid FROM project_tasks WHERE id = ?1",
        [id],
        |row| row.get(0)
    ).ok();

    // Existing DELETE code...

    if let Some(rowid) = rowid {
        embeddings::delete_task_embedding(conn, rowid)?;
    }

    Ok(rows_affected > 0)
}
```

### 3.2 progress.rs modifications

Same pattern for:
- `add_progress()` / `create_progress()` → embed content
- `update_progress_content()` → re-embed content
- `delete_progress()` → delete embedding

---

## Phase 4: CLI Commands

### 4.1 harness.rs - Search command modification

```rust
/// Search tasks using full-text search
Search {
    /// Search query
    query: String,

    /// Maximum number of results
    #[arg(short, long, default_value = "20")]
    limit: usize,

    /// Use semantic search (vector embeddings)
    #[arg(long, default_value = "false")]
    semantic: bool,
},
```

### 4.2 Command handler

```rust
TaskCommands::Search { query, limit, semantic } => {
    let tasks = if semantic {
        db::search_tasks_semantic(&conn, &query, Some(limit))?
    } else {
        db::search_tasks(&conn, &query, Some(limit))?
    };
    // ... rest unchanged (format output)
}
```

### 4.3 New embeddings subcommand

```rust
/// Embedding management
#[derive(Subcommand)]
enum EmbeddingsCommands {
    /// Rebuild all embeddings
    Rebuild,
    /// Show embedding statistics
    Status,
}
```

---

## Phase 5: Testing

### 5.1 Unit tests (embeddings.rs)

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn test_generate_embedding_returns_384_dims() {
        let embedding = generate_embedding("Hello world").unwrap();
        assert_eq!(embedding.len(), 384);
    }

    #[test]
    fn test_semantic_search_finds_similar() {
        // Create in-memory DB
        // Insert task "OAuth2 integration"
        // Search for "OAuth"
        // Assert task is found
    }

    #[test]
    fn test_crud_auto_embeds() {
        // Create task → embedding exists
        // Update title → embedding updated
        // Delete task → embedding gone
    }
}
```

### 5.2 CLI integration tests

```bash
# Test semantic search
harness task add "Implement OAuth2 authentication"
harness task search --semantic "login"  # Should find OAuth2 task
```

---

## Implementation Order

| Step | Task | Est. Lines |
|------|------|------------|
| 1 | Add dependencies to Cargo.toml | 5 |
| 2 | Register sqlite-vec extension | 20 |
| 3 | Add vec0 tables to schema | 15 |
| 4 | Create embeddings.rs with EmbeddingService | 150 |
| 5 | Add embedding hooks to tasks.rs | 50 |
| 6 | Add embedding hooks to progress.rs | 40 |
| 7 | Export in db/mod.rs | 5 |
| 8 | Add --semantic flag to CLI search | 20 |
| 9 | Add embeddings subcommand to CLI | 50 |
| 10 | Write unit tests | 100 |
| 11 | Test with bun tauri dev | - |

**Total**: ~455 lines of new/modified code

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| First embedding slow (~3s model load) | Lazy init singleton, show progress bar |
| Model download fails | Graceful fallback to FTS5, cache in ~/.cache |
| sqlite-vec version incompatibility | Pin version, test with rusqlite 0.38 |
| Large binary size (~30MB model) | Model downloaded at runtime, not bundled |

---

## Success Criteria

1. `harness task search --semantic "OAuth"` finds "OAuth2 authentication"
2. `harness task add "X"` auto-generates embedding
3. `harness task update` regenerates embedding when title/desc changes
4. `harness task delete` removes embedding
5. `harness embeddings status` shows stats
6. All 133+ existing tests still pass
7. Tauri app compiles and runs

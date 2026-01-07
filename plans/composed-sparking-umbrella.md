# Plan: CLAUDE.md + db.json Improvements

## Objective
Create task continuity system with incremental commits and efficient context usage via subagents.

**Language Policy:** CLAUDE.md and db.json in English (LLM best practices).

---

## 1. Re-evaluation of Previous Suggestions for db.json

### What NOT to do (over-engineering):
| Previous Suggestion | Why discard |
|---------------------|-------------|
| External JSON Schema | Adds complexity without immediate value |
| `dependsOn` fields | Execution is sequential, unnecessary |
| `createdAt/updatedAt` timestamps | Git provides sufficient traceability |
| `assignee` field | BMAD agents already have defined ownership |
| Split into multiple files | Increases I/O, complicates queries |

### What TO DO (pragmatic):
| Improvement | Justification |
|-------------|---------------|
| Add `status` to each entry | Enables TODO vs DONE filtering via jq |
| Granularize tasks | One task per entry, not mega-blocks |
| Semantic IDs | `phase0-task-a` vs `00000001` |
| `phase` field | Aligns with BMAD workflow |

---

## 2. Memory-Efficient Reading Tool: `jq`

### Why jq:
- Already available (bash command allowed)
- Selective queries without loading entire file into context
- Supports complex filters (`select`, `map`, `group_by`)

### Standard commands for CLAUDE.md:
```bash
# List all TODO tasks
jq '.value[] | select(.status == "TODO")' db.json

# Get next pending task
jq '.value | map(select(.status == "TODO")) | first' db.json

# Mark task as DONE (via temp file)
jq '(.value[] | select(.id == "TASK_ID")).status = "DONE"' db.json > tmp.json && mv tmp.json db.json

# Count tasks by status
jq '.value | group_by(.status) | map({status: .[0].status, count: length})' db.json
```

---

## 3. CLAUDE.md Structure

### File: `/Users/anotonio.silva/antonio/mms/MFC/CLAUDE.md`

```markdown
# MMS Project - Claude Code Instructions

## Quick Commands
- `continue` - Resume pending tasks from db.json
- `status` - Show current progress

## Task Management via db.json

### Reading Tasks (Memory-Efficient)
Use `jq` to query db.json without loading full content:
```bash
jq '.value[] | select(.status == "TODO") | {id, kind, phase}' db.json
```

### Workflow: "continue"
1. Query next TODO task: `jq '.value | map(select(.status == "TODO")) | first' db.json`
2. Spawn executor subagent for task execution
3. Spawn monitor subagent to validate execution
4. On success: update status to DONE, git commit
5. Repeat until no TODO tasks

## Subagent Architecture

### Executor Agent
- Type: `general-purpose`
- Scope: Execute single task from db.json
- Output: Report success/failure + files modified

### Monitor Agent
- Type: `general-purpose`
- Scope: Validate executor's work
- Checks: Files exist, content correct, no regressions

## Git Commit Discipline

### Rule: Commit After Every Task
After EACH task completion:
```bash
git add -A && git commit -m "feat(phase-X): <task-description>"
```

### Commit Message Format
- `feat(phase-N):` - New functionality
- `fix(phase-N):` - Bug fixes
- `docs(phase-N):` - Documentation
- `refactor(phase-N):` - Code restructuring

## Context Preservation
- Main chat: Orchestration only
- Subagents: All heavy lifting (file ops, validation)
- db.json: Single source of truth for task state
```

---

## 4. Proposed db.json Structure

```json
{
  "README": "Query with jq: jq '.value[] | select(.status == \"TODO\")' db.json",
  "value": [
    {
      "id": "phase0-knowledge-structure",
      "kind": "task",
      "phase": 0,
      "status": "TODO",
      "value": "Create _bmad/knowledge/{technical,business,domain} folders",
      "acceptance": "Folders exist with appropriate content moved"
    },
    {
      "id": "phase0-agent-otto",
      "kind": "task",
      "phase": 0,
      "status": "DONE",
      "value": "Create Otto (OR Specialist) agent",
      "acceptance": "File exists at _bmad/custom/agents/or-specialist.agent.md"
    }
  ]
}
```

---

## 5. Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `CLAUDE.md` | CREATE | Main instructions for continuity |
| `db.json` | MODIFY | Restructure with status, granularize tasks |

---

## 6. "continue" Execution Flow

```
┌─────────────────┐
│   Main Chat     │
│  (Orchestrator) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ jq query db.json│
│ get next TODO   │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐ ┌───────┐
│Executor│ │Monitor│
│Subagent│ │Subagent│
└───┬───┘ └───┬───┘
    │         │
    ▼         ▼
┌─────────────────┐
│ Report to Main  │
│ Update db.json  │
│ Git Commit      │
└─────────────────┘
```

---

## 7. Implementation Checklist

- [ ] Create CLAUDE.md with complete instructions
- [ ] Restructure db.json with granular schema
- [ ] Sync db.json with real state (mark DONE what already exists)
- [ ] Test "continue" workflow with a complete cycle
- [ ] Document jq commands in CLAUDE.md

---

## 8. Design Decisions (User Confirmed)

1. **jq as standard tool** - Avoids loading large JSON into context
2. **One task per entry** - Facilitates tracking and atomic commits
3. **Subagents for execution** - Preserves main chat context
4. **Git commit per task** - Granular traceability
5. **Simple status (TODO/DONE)** - Avoids intermediate state complexity
6. **CLAUDE.md only for commits** - No git hooks, clear instructions in CLAUDE.md ✓
7. **Sync db.json** - Check filesystem and mark DONE what already exists ✓

---

## 9. Execution Order

1. **Create CLAUDE.md** with all instructions
2. **Audit filesystem** - Verify what's already done
3. **Restructure db.json** - Granularize + sync status
4. **Test "continue" command** - Validate complete flow
5. **Initial commit** - `docs: add CLAUDE.md and restructure db.json`

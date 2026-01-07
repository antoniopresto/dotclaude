# MMS Harness - Current State & Next Steps

> **Last Updated**: 2026-01-06T15:00:00Z
> **Status**: PHASE 0 COMPLETE → Ready for PHASE 1

---

## QUICK START FOR NEW SESSION

```
1. READ .harness/progress.txt → understand what happened
2. READ .harness/features.json → find next task (passes: false)
3. EXECUTE next task
4. COMMIT after success
5. UPDATE progress.txt
```

---

## CURRENT STATE

### PHASE 0: SETUP ✅ COMPLETE

| Task | Status | Description |
|------|--------|-------------|
| TASK-000 | ✅ | Directory structure created |
| TASK-001 | ✅ | Hook block-forbidden-packages.sh created |
| TASK-002 | ✅ | Hook block-forbidden-imports.sh created |

**All committed to git.**

### Files Created

```
.harness/
├── features.json    # 27 tasks defined
└── progress.txt     # Session history

.claude/hooks/
├── session-start.sh              # Injects harness context
├── block-forbidden-packages.sh   # Blocks bun add @blueprintjs, etc.
└── block-forbidden-imports.sh    # Blocks import from '@blueprintjs'

subagents/results/   # Empty, awaiting PHASE 1 outputs
_memory/             # Empty, awaiting extracted knowledge
```

---

## NEXT: PHASE 1 - MAP (Parallel Knowledge Extraction)

Launch 10 subagents to extract knowledge from previous conversations.

### Subagent Tasks (All in Parallel)

| Task ID | Focus | Input | Output |
|---------|-------|-------|--------|
| TASK-010 | STACK: Packages researched | conversations.jsonl | 20260106-TASK-010.jsonl |
| TASK-011 | STACK: Versions validated | conversations.jsonl | 20260106-TASK-011.jsonl |
| TASK-012 | STACK: Package hallucinations | conversations.jsonl | 20260106-TASK-012.jsonl |
| TASK-020 | ARCH: World metro systems | Web search | 20260106-TASK-020.jsonl |
| TASK-021 | ARCH: RailNova research | Web search | 20260106-TASK-021.jsonl |
| TASK-022 | ARCH: SignatureRail research | Web search | 20260106-TASK-022.jsonl |
| TASK-023 | ARCH: LOD Layers approach | conversations.jsonl | 20260106-TASK-023.jsonl |
| TASK-030 | FAILURES: What went wrong | conversations.jsonl | 20260106-TASK-030.jsonl |
| TASK-031 | FAILURES: Forgotten constraints | conversations.jsonl | 20260106-TASK-031.jsonl |
| TASK-040 | WORKING: Code that worked | conversations.jsonl | 20260106-TASK-040.jsonl |

### Input File Location

```
/Users/anotonio.silva/antonio/mms/system/genesis/attempt6202/chats/conversations.jsonl
```
- Size: 9304 lines (~7MB)
- Contains: All conversations from 5+ failed attempts

### Output Location

```
./subagents/results/20260106-TASK-XXX.jsonl
```

### Output Format (JSONL)

```json
{"task_id": "TASK-010", "timestamp": "2026-01-06T...", "finding_type": "...", "content": "...", "source_line": 1234}
```

---

## EXECUTION PROTOCOL

### For Each Subagent

1. **Get prompt from features.json** (field: `prompt`)
2. **Launch Task tool** with prompt
3. **Subagent saves result** to output_path
4. **Mark task complete** in features.json (passes: true)
5. **Update progress.txt** with summary

### Commit After PHASE 1

After all 10 subagents complete:
```bash
git add subagents/results/
git commit -m "feat: PHASE 1 complete - extracted knowledge from conversations"
```

---

## FUTURE PHASES

### PHASE 2: REDUCE
- TASK-050: Merge all PHASE 1 findings
- TASK-051: Resolve conflicts
- TASK-052: Create FINAL SPEC

### PHASE 3: VALIDATE
- TASK-060-063: Verify tech stack with web research

### PHASE 4: APPROVAL
- TASK-070: Get user approval on spec

### PHASE 5: IMPLEMENTATION
- TASK-100-106: Build the application

---

## CRITICAL CONSTRAINTS

### Forbidden Packages (hooks will BLOCK)
- `@blueprintjs/*` → use `@patternfly/react-core`
- `@zazcart/*` → doesn't exist
- `xstate` → over-engineered
- `zustand/redux/mobx` → use `@belt/tools`
- `next` → need SPA (use vite)
- `react@18` → must use react@19

### Required Stack
- react@19.x
- @patternfly/react-core@6.x
- @belt/tools@latest
- @react-three/fiber@9.x
- @react-three/drei@10.x
- three@0.170+
- vite@6.x

---

## PROJECT CONTEXT

**MMS (Metro Maintenance Scheduler)**
- Client: Keolis MHI (Dubai Metro)
- Problem: Schedule maintenance for 128 trains × 12 years
- Solution: Semantic Zoom canvas
  - Zoom out → heatmap (density)
  - Zoom mid → DNA blocks
  - Zoom in → task cards
- Target: 60fps with 60k tasks

---

## REFERENCES

- [Anthropic - Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- progress.txt: `.harness/progress.txt`
- features.json: `.harness/features.json`
- CLAUDE.md: Project rules and constraints

# Plan: Progress File Rotation for Ralph Loop

## Context

`progress.txt` is 1888 lines / ~33k tokens and growing. Each Ralph iteration sends `TASK_PROMPT` which instructs the LLM to read `progress.txt`, but completed tasks are dead weight that bloats context and degrades quality. We need automatic archival of completed tasks before each iteration, plus LLM awareness of the `.loop/` archive folder.

**Separator**: progress.txt already uses 80 `-` chars as the logical task separator. The archival logic will use this as the canonical block delimiter.

## Implementation (all changes in `loop.ts`)

### 1. Add constant and `archiveCompletedTasks()` function

```ts
const SEPARATOR = '-'.repeat(80);
```

- Read `CONFIG.progressFile` content
- Estimate tokens: `Math.ceil(content.length / 4)` (standard LLM approximation)
- If <= 1000 tokens, return early
- Split content by the 80-dash separator line
- Classify each block: completed (`- [x]`) vs pending/in-progress
- Write completed blocks to `.loop/<ISO-timestamp>-progress.txt`
- Rewrite `progress.txt` with only pending/in-progress blocks (preserving separators between them)
- Log the archival via `syslog()`

### 2. Call `archiveCompletedTasks()` in the iteration loop

Insert call at the top of the `while` loop body, before `logBuffer.startNewFile()` — runs once per iteration, before Claude gets invoked.

### 3. Update `TASK_PROMPT` to include `.loop/` context

Add after the existing WORKFLOW section:

```
CONTEXT:
- The .loop/ directory contains archived progress logs and iteration logs.
- Files named <timestamp>-progress.txt contain previously completed tasks
  that were rotated out of progress.txt to keep context lean.
- You can read files in .loop/ if you need historical context about past work.
```

### Files Modified

- `loop.ts` — all 3 changes above (no other files needed)

### Verification

1. `wc -c .claude/progress.txt` before/after one iteration
2. Verify `.loop/<timestamp>-progress.txt` created with only `[x]` tasks
3. Verify `progress.txt` retains only pending/in-progress tasks with separators intact
4. `bun run check` passes

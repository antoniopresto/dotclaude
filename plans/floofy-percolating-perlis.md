# F017: Play Button - Execute Tasks with Claude Code

## Status: IMPLEMENTATION COMPLETE - Pending Commit

## Summary
Adicionar botão "Play" nas tarefas da coluna TODO que executa a tarefa usando Claude Code via PTY.

## Implementation Completed

### 1. TaskExecutionModal (NEW)
**File:** `src/components/TaskExecutionModal.tsx`
- Modal que mostra output PTY em tempo real
- Usa `ptySpawn('claude', [], projectPath)` para iniciar Claude Code
- Envia contexto da tarefa (título, descrição, steps) via `ptyWrite`
- Monitora `onPtyOutput` e `onPtyExit`
- Status: idle → starting → running → success/failed/cancelled

### 2. KanbanCard (MODIFIED)
**File:** `src/components/KanbanCard.tsx`
- Adicionada prop `onPlay?: () => void`
- Botão Play (PlayIcon) só aparece em tarefas com status TODO/pending
- Tooltip: "Execute task with Claude Code"

### 3. KanbanBoard (MODIFIED)
**File:** `src/components/KanbanBoard.tsx`
- Adicionada prop `onPlayTask?: (task: Feature) => void`
- Passa `onPlay` para cada KanbanCard

### 4. App.tsx (MODIFIED)
**File:** `src/App.tsx`
- Novo estado: `isExecutionModalOpen`, `executingTask`
- `handlePlayTask()`: move tarefa para DOING, abre modal
- `handleTaskExecutionComplete()`: move para DONE (success) ou QA (failed)
- Integra TaskExecutionModal

### 5. Features.json (UPDATED)
**File:** `.harness/features.json`
- F017 adicionada com status "doing"

## Flow
```
TODO task → Click Play → Move to DOING → PTY spawns Claude Code
→ Send task context → Claude works → PTY exits
→ Success? DONE : QA → Refresh board
```

## Remaining Steps
1. ✅ TypeScript compiles
2. ✅ Visual test (UI renders)
3. ⏳ Commit changes
4. ⏳ Update progress.txt
5. ⏳ Mark F017 as passed in features.json

## Files Modified
- `src/components/TaskExecutionModal.tsx` (NEW)
- `src/components/KanbanCard.tsx`
- `src/components/KanbanBoard.tsx`
- `src/components/index.ts`
- `src/App.tsx`
- `.harness/features.json`

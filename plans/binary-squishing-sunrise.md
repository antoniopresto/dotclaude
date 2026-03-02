# Plan: Ralph Loop Resilience — Commit Recovery & Task Decomposition

## Context

O loop Ralph (`loop.ts`) está abortando após 3 iterações porque **timeouts (exit code 124) contam como falhas consecutivas**. Claude nunca chegou a commitar — gastou todo o tempo no ciclo fix→test→novo-erro→fix de problemas CJS/ESM. Além disso, quando eventualmente tentar commitar, o pre-commit hook (`npm run lint` no projeto inteiro) pode falhar e perder todo o trabalho da iteração.

**Objetivo**: Tornar o loop resiliente com mudanças mínimas — timeout não aborta, commit com falha de lint salva o trabalho via `--no-verify` e registra tarefa prioritária de fix.

## File to Modify

`/Users/anotonio.silva/dev/rnm-app-fintech-rewardprogram/loop.ts`

## Change 1: Timeout não conta como falha (lines 453-459)

**Current:**
```typescript
if (exitCode === 0) {
  syslog('Claude Code completed successfully', 'green');
  consecutiveFailures = 0;
} else {
  syslog(`Claude Code exited with code ${exitCode}`, 'yellow');
  consecutiveFailures++;
}
```

**New:**
```typescript
if (exitCode === 0) {
  syslog('Claude Code completed successfully', 'green');
  consecutiveFailures = 0;
} else if (timedOut) {
  syslog('Iteration timed out — progress may persist in progress.txt', 'yellow');
} else {
  syslog(`Claude Code exited with code ${exitCode}`, 'yellow');
  consecutiveFailures++;
}
```

**Rationale**: 3 linhas adicionadas. Timeout não incrementa `consecutiveFailures`. A próxima iteração lê `progress.txt` e continua de onde parou.

## Change 2: TASK_PROMPT — 3 adições cirúrgicas

Sem remover nada do prompt existente. Três inserções:

### 2a. Prioridade LINT-FIX (inserir no step 1)

Após a linha `1. Read ./.claude/progress.txt and identify the most important pending task;` adicionar:
```
   - [PRIORITY] Tasks tagged [LINT-FIX] must be done FIRST, before any other task.
```

### 2b. Decomposição de tarefas (inserir como step 3.a, antes do execute)

Inserir antes de `b. Execute task`:
```
   a. Evaluate scope: if the task involves more than ~3 files or multiple concerns,
      break it into smaller sub-tasks in progress.txt BEFORE starting. Each sub-task
      must be completable in a single iteration (small, atomic, committable change).
```

### 2c. Recuperação de commit falho (inserir como step 3.h, após commit)

Após `g. Commit task changes (not include unrelated code)` adicionar:
```
   h. IF THE COMMIT FAILS (pre-commit hook / lint error):
      - Add a [LINT-FIX] priority task to progress.txt describing the exact errors
      - Retry the commit with `git commit --no-verify` to save your work
      - The NEXT iteration will fix the lint errors as its top priority
      - Do NOT spend time fixing lint in this iteration — save tokens for the next one
```

## Summary of All Changes

| O quê | Onde | Linhas |
|---|---|---|
| `else if (timedOut)` branch | `main()`, line ~456 | +3 linhas |
| `[PRIORITY] LINT-FIX` rule | `TASK_PROMPT`, step 1 | +1 linha |
| Task decomposition step 3.a | `TASK_PROMPT`, before execute | +3 linhas |
| Commit failure recovery step 3.h | `TASK_PROMPT`, after commit | +5 linhas |

**Total: ~12 linhas adicionadas, 0 removidas, 0 funções novas, 0 dependências novas.**

## Verification

1. `bun run loop.ts 1` — rodar 1 iteração e verificar que Claude lê progress.txt e tenta executar
2. Simular timeout: reduzir `iterationTimeout` para 10s temporariamente, confirmar que o loop **não** aborta após 3 timeouts
3. Simular commit failure: verificar nos logs que Claude registra `[LINT-FIX]` task e faz `--no-verify`

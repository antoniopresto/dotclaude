# Plano de Execução: MMS System - Completude Total

**Objetivo:** Corrigir todas as pendências, eliminar TODOs/FIXMEs, testar todas as features e garantir UX "impressionante" para usuários finais.

**Data:** 2026-01-05
**Escopo:** apps/canvas + packages/toolkit

---

## Resumo das Pendências Identificadas

### 1. @zazcart/tools State Machine (5 problemas críticos)
| Issue | Arquivo | Linhas | Severidade | Tempo |
|-------|---------|--------|------------|-------|
| GC Thrashing | machine.ts | 52-114 | CRITICAL | 1h |
| Validation Hot Path | context.ts | 25-39 | CRITICAL | 15m |
| V8 De-optimization | hooks.ts | 61-93 | CRITICAL | 1-2h |
| Double Proxying | machine.ts | 37-50 | HIGH | 2h |
| Unsafe Unsubscribe | store.ts | 46-68 | HIGH | 15m |

### 2. @zazcart/tools Helpers (2 críticos)
| Issue | Arquivo | Severidade |
|-------|---------|------------|
| devLog crash risk | logs.ts | CRITICAL |
| O(N²) reduceObject | object-utils.ts | HIGH |

### 3. @zazcart/tools Schema (1 alto)
| Issue | Arquivo | Severidade |
|-------|---------|------------|
| Interpreted validation | type.ts | HIGH |

### 4. apps/canvas Features (6 - código existe, teste pendente)
- F016, F021, F022, F026, F027, F028

### 5. apps/canvas TODOs
- Momentum scrolling (linha 1903)
- PERF-002 viewport culling (linha 341)

---

## Fases de Execução

### FASE 1: Correções Críticas @zazcart/tools (3-4h)

#### 1.1 Unsafe Listener Unsubscription (15m)
**Arquivo:** `packages/toolkit/src/state-machine/store.ts`
**Linha:** 66

```typescript
// ANTES (buggy)
for (const listener of currentListeners) {
  listener(currentState, action);
}

// DEPOIS (safe)
const listeners = currentListeners.slice(); // Copy before iteration
for (const listener of listeners) {
  listener(currentState, action);
}
```

#### 1.2 Validation on Hot Path (15m)
**Arquivo:** `packages/toolkit/src/state-machine/context.ts`
**Linhas:** 25-29

```typescript
const check = (value: unknown) => {
  assertObject(value, `Expected value to be an object.`);
  if (process.env.NODE_ENV !== 'production') {
    Assert(value); // Only validate in development
  }
  return value;
};
```

#### 1.3 devLog Crash Risk (15m)
**Arquivo:** `packages/toolkit/src/logs.ts`

```typescript
// ANTES (crashes)
if (typeof messageOrError !== 'string') {
  throw messageOrError;
}

// DEPOIS (safe)
if (typeof messageOrError !== 'string') {
  console.error('[devLog]', messageOrError);
  return;
}
```

#### 1.4 GC Thrashing - Metadata Option (1h)
**Arquivo:** `packages/toolkit/src/state-machine/machine.ts`
**Linhas:** 52-114, 160-170

1. Adicionar `metadata?: boolean` ao `MachineConfig` type
2. Condicionalmente chamar `UpsertStateMetadata` apenas se `config.metadata !== false`
3. Default: `metadata: true` para backward compatibility

#### 1.5 O(N²) reduceObject (30m)
**Arquivo:** `packages/toolkit/src/object-utils.ts`

```typescript
// ANTES (O(N²))
return items.reduce((acc, entry) => ({ ...acc, ...next }), {});

// DEPOIS (O(N))
const result = {};
for (const [key, value] of Object.entries(items)) {
  Object.assign(result, reducer([key, value]));
}
return result;
```

#### 1.6 V8 De-optimization (1-2h) ⚠️ BREAKING
**Arquivo:** `packages/toolkit/src/state-machine/hooks.ts`
**Linhas:** 61-93

```typescript
// ANTES (hybrid array+object)
return Object.assign([selection, actions], actions, selection);

// DEPOIS (clean object)
return { state: selection, actions, dispatch };
```

**Impacto:** Atualizar todos os usos em apps/canvas

#### 1.7 Double Proxying (2h)
**Arquivo:** `packages/toolkit/src/state-machine/machine.ts`
**Linhas:** 37-50

```typescript
// ANTES (double produce)
return produce(state, draft => {
  selectorEntries.forEach(([key, fn]) => {
    draft[key] = fn(draft);
  });
});

// DEPOIS (direct assignment)
if (!selectorEntries?.length) return state;
const enhanced = { ...state };
selectorEntries.forEach(([key, fn]) => {
  enhanced[key] = fn(state);
});
return enhanced;
```

---

### FASE 2: Testes Features apps/canvas (2h)

Para cada feature pendente:

1. **F016** - Shift+Scroll vertical pan
   - Código: InfiniteCanvas.tsx
   - Testar: Shift+Scroll move camera verticalmente

2. **F021** - Keyboard navigation
   - Código: InfiniteCanvas.tsx (findNextTaskInDirection)
   - Testar: Tab, Shift+Tab, Arrow keys, Enter, Escape

3. **F022** - ARIA labels
   - Código: MicroLayer.tsx (linha 248)
   - Testar: aria-label em tasks, aria-live region

4. **F026** - Task details panel
   - Código: TaskDetailsPanel.tsx
   - Testar: Click task → panel abre, Escape → fecha

5. **F027** - Keyboard shortcuts zoom
   - Código: InfiniteCanvas.tsx
   - Testar: +/- keys, 0 reset

6. **F028** - Keyboard shortcuts pan
   - Código: InfiniteCanvas.tsx
   - Testar: Arrow keys, PageUp/Down, Home/End

**Protocolo por feature:**
```
1. mcp__playwright__browser_navigate → http://localhost:5173
2. mcp__playwright__browser_console_messages → check errors
3. mcp__playwright__browser_take_screenshot → visual check
4. Test interaction (keyboard/mouse)
5. Update features.json → passes: true
```

---

### FASE 3: Implementar PERF-002 + Momentum (2h)

#### 3.1 PERF-002 Viewport Culling
**Arquivo:** `apps/canvas/src/canvas/layers/MesoLayer.tsx` (linha 341)

1. Usar `viewportBounds` prop já passado
2. Filtrar tasks visíveis antes de renderizar
3. Usar RBushSpatialIndex já implementado

```typescript
// Usar spatial index para filtrar
const visibleTaskIds = spatialIndex.query(viewportBounds);
const visibleTasks = tasks.filter(t => visibleTaskIds.includes(t.id));
```

#### 3.2 Momentum Scrolling
**Arquivo:** `apps/canvas/src/canvas/InfiniteCanvas.tsx` (linha 1903)

1. Reimplementar com state machine sync
2. Usar canvasStore.getState() para evitar stale closures
3. Velocity tracking durante drag
4. Friction-based animation (F=0.93)

---

### FASE 4: QA Manual Completo (1-2h)

#### 4.1 Checklist Visual (Playwright MCP)

| Teste | Critério |
|-------|----------|
| MACRO (zoom < 0.5) | Heatmap visível, cores corretas |
| MESO (0.5-2.0) | Task blocks coloridos, conflicts vermelhos |
| MICRO (zoom > 2.0) | Cards detalhados, labels legíveis |
| LOD transitions | Blend suave entre níveis |
| Sidebar | Sync com camera Y |
| Timeline | Datas adaptativas por zoom |
| Minimap | Click/drag navega corretamente |
| Zoom buttons | +/- funcionam |
| Reset | Volta ao estado inicial |

#### 4.2 Checklist Interação

| Teste | Ação | Resultado Esperado |
|-------|------|-------------------|
| Pan | Drag canvas | Camera move suavemente |
| Zoom | Scroll wheel | Zoom centralizado no cursor |
| Pinch | Ctrl+Scroll | Zoom touch-like |
| Double-click | 2 clicks | Zoom 2x no ponto |
| Hover | Mouse sobre task | Tooltip aparece |
| Click | Click task | Panel abre |
| Keyboard | Tab | Foca próxima task |
| Keyboard | Arrows | Navega entre tasks |
| Keyboard | +/- | Zoom in/out |
| Keyboard | Escape | Fecha panel/limpa seleção |

#### 4.3 Checklist Performance

| Métrica | Target |
|---------|--------|
| FPS idle | >= 60 |
| FPS pan/zoom | >= 30 |
| Console errors | 0 |
| GC pauses | Imperceptível |

---

### FASE 5: Commit e Documentação (30m)

1. Update features.json → todas features `passes: true`
2. Update progress.txt → sessão documentada
3. Remover arquivos FIXME (após correções)
4. Git commit com mensagem descritiva
5. Git push

---

## Arquivos a Modificar

### packages/toolkit/src/state-machine/
- [ ] `store.ts` - Unsafe unsubscribe fix
- [ ] `context.ts` - Validation hot path
- [ ] `machine.ts` - GC thrashing + double proxy
- [ ] `hooks.ts` - V8 de-optimization
- [ ] `models.ts` - Add metadata flag type

### packages/toolkit/src/
- [ ] `logs.ts` - devLog crash fix
- [ ] `object-utils.ts` - O(N²) fix

### apps/canvas/src/
- [ ] `canvas/InfiniteCanvas.tsx` - Momentum reimplementation
- [ ] `canvas/layers/MesoLayer.tsx` - PERF-002 culling

### Harness Files
- [ ] `.harness/features.json` - Mark features complete
- [ ] `.harness/progress.txt` - Session notes
- [ ] Delete FIXME*.md files after fixes

---

## Ordem de Execução

```
1. [30m] Quick fixes: store.ts, context.ts, logs.ts
2. [2h] Core fixes: machine.ts (GC + proxy), hooks.ts (V8)
3. [30m] Helper fix: object-utils.ts (O(N²))
4. [1h] Canvas: PERF-002 + Momentum
5. [2h] Feature tests: F016, F021, F022, F026, F027, F028
6. [1h] QA manual: visual + interaction + performance
7. [30m] Commit + documentation
```

**Tempo total estimado:** 7-8 horas

---

## Critérios de Sucesso

- [ ] Zero FIXMEs ou TODOs no código
- [ ] Todas as 6 features pendentes testadas e aprovadas
- [ ] Performance: 60fps idle, 30fps+ durante interação
- [ ] Zero console errors
- [ ] UX "impressionante": smooth pan/zoom, feedback visual, acessibilidade
- [ ] Código commitado e documentado

---

## Decisões do Usuário

- **Breaking Changes:** ✅ APROVADO - Corrigir tudo incluindo V8 De-optimization

---

## Notas

### harness-dashboard
O projeto `packages/harness-dashboard` **NÃO será incluído** nesta execução pois:
- Não está relacionado ao produto final (apps/canvas)
- D001 ainda não foi iniciado
- Foco é "usuários finais" = aplicação principal

### Breaking Changes
A correção V8 De-optimization (hooks.ts) é uma **breaking change**. Todos os usos de `useMachine()` em apps/canvas precisarão ser atualizados de:
```typescript
const [state, actions] = machine.useMachine();
```
Para:
```typescript
const { state, actions, dispatch } = machine.useMachine();
```

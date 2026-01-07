# Plano: Validação de Upgrades de Pacotes - Belt Tools

## Contexto

Commit `a3552f7` atualizou todos os pacotes para versões mais recentes via `pnpm up --latest`.

### Mudanças Críticas
| Pacote | Versão Anterior | Nova Versão | Risco |
|--------|----------------|-------------|-------|
| **immer** | 10.2.0 | 11.1.3 | 🔴 ALTO (major) |
| **@types/node** | 22.x | 25.x | 🟡 MÉDIO (major) |
| **typebox** | 1.0.50 | 1.0.73 | 🟢 BAIXO (patch) |
| turbo | 2.3.0 | 2.7.2 | 🟢 BAIXO |
| @biomejs/biome | 2.3.8 | 2.3.11 | 🟢 BAIXO |
| tsup | 8.3.0 | 8.5.1 | 🟢 BAIXO |
| vitest | 4.0.8 | 4.0.16 | 🟢 BAIXO |

### Status de TODOs/FIXMEs
✅ **NENHUM encontrado** - código limpo

### Cobertura de Testes Atual
- 1 arquivo de teste: `packages/tools/src/schema/lib/__tests__/type.spec.ts`
- Sem testes para state-machine (usa Immer - risco crítico)
- Sem testes para helpers

---

## Fase 1: Verificações Automatizadas

### 1.1 Build
```bash
pnpm build
```
**Critério de sucesso:**
- Gera `dist/index.js`, `dist/index.cjs`, `dist/index.d.ts`
- Sem erros de compilação

### 1.2 Type Check
```bash
pnpm typecheck
```
**Critério de sucesso:** Sem erros TypeScript

**Arquivos de maior risco:**
- `packages/tools/src/state-machine/machine.ts` (usa Immer)
- `packages/tools/src/state-machine/slice.ts` (usa Immer)
- `packages/tools/src/helpers/error-utils.ts` (usa Error.captureStackTrace)

### 1.3 Lint
```bash
pnpm lint
```
**Critério de sucesso:** Sem erros de lint

### 1.4 Testes Unitários
```bash
pnpm test
```
**Critério de sucesso:** Todos os testes passam

---

## Fase 2: Verificação Manual - State Machine (CRÍTICO)

O Immer 11.x tem breaking changes. O código usa apenas `produce()`:

**Arquivos que usam Immer:**
- `packages/tools/src/state-machine/machine.ts:35` - `produce(state, draft => {...})`
- `packages/tools/src/state-machine/slice.ts:158,205` - reducers async/sync

### 2.1 Criar Script de Teste Manual
```typescript
// test-state-machine.ts
import { createMachine, createSlice, createAsyncSlice } from './packages/tools/src';

// Test sync slice
const counter = createSlice({
  id: 'counter',
  cache: { strategy: 'none' },
  initial: { count: 0 },
  reducers: {
    increment: (draft) => { draft.count += 1; },
    set: (draft, value: number) => { draft.count = value; },
  },
});

// Test async slice
const user = createAsyncSlice({
  id: 'user',
  cache: { strategy: 'none' },
  context: {},
  load: async () => ({ name: 'Test' }),
});

// Test machine
const machine = createMachine({
  id: 'test',
  slices: { counter, user },
});

// Verify mutations
machine.dispatch(machine.actions.counter.increment(null));
console.assert(machine.getState().counter.count === 1, 'increment failed');

machine.dispatch(machine.actions.counter.set(10));
console.assert(machine.getState().counter.count === 10, 'set failed');

console.log('✓ State machine tests passed');
```

### 2.2 Executar via Node
```bash
npx tsx test-state-machine.ts
```

---

## Fase 3: Verificação de Exports

### 3.1 Testar import ESM
```bash
node --input-type=module -e "import('@belt/tools').then(m => console.log('ESM:', Object.keys(m).length, 'exports'))"
```

### 3.2 Testar require CJS
```bash
node -e "console.log('CJS:', Object.keys(require('@belt/tools')).length, 'exports')"
```

---

## Fase 4: Cleanup (se necessário)

### 4.1 TODOs/FIXMEs
✅ Já verificado - nenhum encontrado

### 4.2 Mocks em código de produção
✅ Já verificado - nenhum encontrado

### 4.3 Console statements
✅ Verificado - apenas em logging utilities intencionais:
- `helpers/logs.ts` - devLog() com guards
- `helpers/error-utils.ts` - InvariantError com guards

---

## Arquivos Críticos

```
packages/tools/src/
├── state-machine/
│   ├── machine.ts      # Usa produce() - TESTAR
│   └── slice.ts        # Usa produce() - TESTAR
├── schema/
│   └── lib/
│       ├── type.ts     # Usa TypeBox - TESTADO
│       └── __tests__/
│           └── type.spec.ts  # Testes existentes
└── helpers/
    └── error-utils.ts  # Error.captureStackTrace - verificar tipos
```

---

## Rollback (se necessário)

```bash
git revert a3552f7
pnpm install
```

---

## Checklist de Execução

- [ ] `pnpm build` - sucesso
- [ ] `pnpm typecheck` - sucesso
- [ ] `pnpm lint` - sucesso
- [ ] `pnpm test` - sucesso
- [ ] Teste manual state-machine - sucesso
- [ ] Verificar exports ESM/CJS - sucesso
- [ ] Limpar arquivos temporários de teste

---

## Análise de Erros Lógicos do Plano

### Pontos Revisados:
1. ✅ Immer 11.x: código usa apenas `produce()` sem features deprecated
2. ✅ TypeBox: já usa API nova (`Compile` não `TypeCompiler`)
3. ✅ @types/node: código não usa APIs removidas (fs.F_OK, etc)
4. ✅ Error.captureStackTrace: já tem guard `hasCaptureStackTrace`

### Riscos Identificados:
1. **State-machine sem testes** - maior gap de cobertura
2. **React hooks não testáveis** sem ambiente React

### Recomendações Pós-Validação:
1. Adicionar testes para state-machine
2. Adicionar testes para helpers críticos

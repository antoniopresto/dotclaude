# plugin-hooks — Plano de Melhorias

## Context

`plugin-hooks` é usado como sistema de hooks no `loop.ts` (Ralph Loop). Durante a integração, 3 agents Opus revisaram e identificaram bugs reais no source, gaps na cobertura de testes, e oportunidades de modernização. A exploração profunda do source confirmou todos os achados e revelou issues adicionais.

O objetivo é corrigir bugs, aumentar cobertura de testes, limpar código morto, e modernizar o toolchain — sem quebrar a API pública.

---

## 1. Bugs a Corrigir

### 1.1 Sync `PluginExecutionContext` com contadores hardcoded em zero
**Arquivo:** `src/syncPlugin.ts:121-124`
```ts
const self: PluginExecutionContext<any, any> = {
  handledCount: 0,   // BUG: deveria ser `handledCount` (variável)
  ignoredCount: 0,   // BUG: deveria ser `ignoredCount` (variável)
```
A versão async (asyncPlugin.ts:137-138) faz corretamente. Sync deve espelhar.

### 1.2 Sync dispatch pula middleware quando valor é `undefined`
**Arquivo:** `src/syncPlugin.ts:144`
```ts
if (lastValue !== EmptySymbol && lastValue !== undefined) {
```
Se qualquer middleware seta `lastValue` como `undefined` (ou initial value é `undefined`), todos os subsequentes são silenciosamente pulados. Async não tem esse guard. Remover a checagem de `undefined` — apenas `EmptySymbol` deve ser sentinela.

### 1.3 Sync `finish` test não executa dispatch
**Arquivo:** `src/__tests__/plugins.spec.ts:140-154`
O test registra middleware com `finish(555)` mas nunca chama `plugin.dispatch()`. Ele só verifica `calledNext === false` — que é true por default. O test passa mas não testa nada.

### 1.4 Arquivo de test morto por typo no nome
**Arquivo:** `src/__tests__/examples.spect.ts` — "spect" ao invés de "spec". Jest default pattern (`*.spec.ts`) não captura. Renomear para `examples.spec.ts`.

---

## 2. Código Morto a Remover

### 2.1 `executionsCountLimit` em `PluginOptions`
**Arquivo:** `src/createPlugins.ts:5`
Declarado mas nunca implementado em nenhum lugar. Remover da interface.

### 2.2 Código unreachable em `asyncPlugin.ts:182-186`
```ts
if (replacedValue !== EmptySymbol) {
  if (returnOnFirst) {
    finish(lastValue);
  }
}
```
Nunca alcançado: `self.replace()` sempre joga `ReplaceSymbol` (non-returnOnFirst) ou `ForceFinishSymbol` (returnOnFirst) antes de chegar aqui. Remover.

### 2.3 type-utils.ts — Tipos não consumidos
`type-utils.ts` tem 229 linhas. Apenas `IsKnown<T>` é usado pelo package (em `AsyncExec` e `SyncPluginExec`). Os types utilitários restantes (`ObjectDotNotations`, `Merge`, `ExtendListDeep`, `tupleEnum`, etc.) não são consumidos. Extrair apenas `IsKnown` e suas dependências (`IsAny`, `IsNever`, `IsUnknown`) para um arquivo focado, ou mover o restante para export separado.

---

## 3. Testes Faltantes

Adicionar testes em `src/__tests__/plugins.spec.ts`:

| Cenário | Tipo |
|---------|------|
| `exit()` flow — middleware chama exit, próximo recebe valor anterior | async + sync |
| `replace()` flow — middleware chama replace, próximo recebe valor substituído | async + sync |
| `unshiftMiddleware` — middleware adicionado no início executa primeiro | async + sync |
| Named middleware registration — `plugin('myName', fn)` | async |
| Context parameter (`C`) com sync plugins | sync |
| Middleware array freeze após primeiro dispatch (async) | async |
| Error propagation em async plugins | async |
| Múltiplos dispatches no mesmo plugin | async |
| `returnOnFirst` com sync plugin | sync |
| Dispatch com initial value `undefined` | async + sync |
| Dispatch sem middleware retorna initial value | sync (já existe pra async) |

---

## 4. Modernização do Toolchain

### 4.1 Atualizar devDependencies
| Package | De | Para |
|---------|-----|------|
| typescript | ~4.7.4 | ^5.5 |
| jest | ^27 | ^29 |
| ts-jest | ^27 | ^29 |
| @types/jest | ^26 | ^29 |
| @types/node | ^16 | ^20 |

### 4.2 Remover Babel, usar tsc para build
A build atual usa Babel para transpilação + tsc separado para declarations. TypeScript 5.x compila para ESNext/ES2020 diretamente — elimina a necessidade de Babel e as 6 devDependencies Babel.

**Remover:**
- `@babel/cli`, `@babel/core`, `@babel/preset-env`, `@babel/preset-typescript`, `@babel/plugin-proposal-class-properties`, `@babel/register`

**Atualizar scripts:**
```json
{
  "build": "rm -rf lib && tsc",
  "test": "jest"
}
```

**Atualizar tsconfig.json:**
- Target: `ES2020` (ou `ES2022`)
- Module: `CommonJS` (manter compat)
- `declaration: true`, `declarationMap: true`
- `outDir: "lib"`, `rootDir: "src"`

### 4.3 Remover resolutions mortas
`package.json` tem `resolutions` para `ts-loader`, `ts-node`, `ts-node-dev` que não são usados.

---

## 5. JSDoc nas Interfaces Públicas

Adicionar JSDoc em `createPlugins.ts`:
- `PluginExecutionContext.replace()` — doc atual diz "Exit current middleware execution and go to the next" (copy-paste de `exit()`). Corrigir para descrever que substitui o valor e avança.
- `PluginExecutionContext.finish()` — documentar que joga exceção internamente, middleware code após `finish()` não executa.

---

## Ordem de Execução

1. Fix bugs (1.1 → 1.4) — atômicos, sem dependência entre si
2. Remover código morto (2.1 → 2.3)
3. Adicionar testes (3)
4. Modernizar toolchain (4.1 → 4.3)
5. JSDoc (5)

## Arquivos Modificados

| Arquivo | Mudanças |
|---------|----------|
| `src/syncPlugin.ts` | Fix contadores (1.1), fix undefined guard (1.2) |
| `src/asyncPlugin.ts` | Remover dead code (2.2) |
| `src/createPlugins.ts` | Remover `executionsCountLimit` (2.1), fix JSDoc (5) |
| `src/type-utils.ts` | Limpar tipos não consumidos (2.3) |
| `src/__tests__/plugins.spec.ts` | Fix sync finish test (1.3), adicionar testes (3) |
| `src/__tests__/examples.spect.ts` → `examples.spec.ts` | Rename (1.4) |
| `package.json` | Atualizar deps (4.1), remover Babel (4.2), remover resolutions (4.3) |
| `tsconfig.json` | Atualizar target/config (4.2) |
| `tsconfig.declarations.json` | Remover (4.2 — tsc único faz tudo) |
| `.babelrc` ou `babel.config.*` | Remover se existir (4.2) |

## Verificação

1. `npm test` — todos tests passam (antigos + novos)
2. `npm run build` — build compila sem erros
3. Verificar que `lib/` contém `.js` + `.d.ts` para cada source file
4. Verificar `import { createAsyncPlugin, createSyncPlugin } from './lib'` funciona

# Plano: Build Tree-Shakeable para @belt/ai

## Problema

O pacote não é tree-shakeable devido a:
- Ausência de `exports` e `sideEffects` no package.json
- Entry point único no Vite
- `rollupTypes: true` bundleia todos os types

## Arquivos a Modificar

1. `packages/belt-ai/package.json`
2. `packages/belt-ai/vite.config.ts`

---

## Mudança 1: package.json

Adicionar campos:

```json
{
  "name": "@belt/ai",
  "version": "0.0.1",
  "type": "module",
  "sideEffects": false,
  "main": "./dist/index.cjs",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.mjs",
      "require": "./dist/index.cjs"
    },
    "./hooks": {
      "types": "./dist/hooks.d.ts",
      "import": "./dist/hooks.mjs",
      "require": "./dist/hooks.cjs"
    }
  },
  "files": ["dist"]
}
```

| Campo | Função |
|-------|--------|
| `sideEffects: false` | Permite tree-shaking agressivo |
| `exports` | Define subpaths importáveis |
| `main/module/types` | Retrocompatibilidade |

---

## Mudança 2: vite.config.ts

Alterar entry point e dts:

```typescript
build: {
  lib: {
    // DE: entry: resolve(__dirname, 'src/index.ts'),
    // PARA:
    entry: {
      index: resolve(__dirname, 'src/index.ts'),
      hooks: resolve(__dirname, 'src/hooks.ts'),
    },
    name: 'belt-ai',
    formats: ['es', 'cjs'],
    // DE: fileName: format => `index.${format === 'es' ? 'mjs' : 'cjs'}`,
    // PARA:
    fileName: (format, entryName) => {
      const ext = format === 'es' ? 'mjs' : 'cjs';
      return `${entryName}.${ext}`;
    },
  },
  // ... resto igual
},
plugins: [
  // ...
  dts({
    rollupTypes: false,  // ERA: true
    tsconfigPath: 'tsconfig.prod.json',
  }),
  // ...
]
```

---

## Estrutura de Build Resultante

```
dist/
├── index.mjs      # ESM barrel
├── index.cjs      # CJS barrel
├── index.d.ts     # Types barrel
├── hooks.mjs      # ESM direto
├── hooks.cjs      # CJS direto
└── hooks.d.ts     # Types direto
```

---

## Imports Habilitados

```typescript
// Via barrel (retrocompatível)
import { createHook } from '@belt/ai';

// Via subpath (tree-shakeable)
import { createHook } from '@belt/ai/hooks';
```

---

## Sequência de Execução

1. Editar `package.json`
2. Editar `vite.config.ts`
3. Executar `bun run build`
4. Verificar estrutura de `dist/`
5. (Opcional) Validar com `npx publint`

---

## Compatibilidade

| Bundler | Status |
|---------|--------|
| Webpack 5+ | OK |
| Rollup | OK |
| esbuild | OK |
| Vite | OK |

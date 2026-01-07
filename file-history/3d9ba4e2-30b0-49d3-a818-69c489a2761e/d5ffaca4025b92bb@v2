# Plan: Clean README and Republish

## Problem
O README atual contém linguagem de marketing amadora:
- "mission-critical applications" (linha 3)
- "Mission-Critical Ready" (linha 22)
- "Mission-Critical Usage (60fps Games)" (seção inteira, linha 186)
- Comentários como "Critical for 60fps"

Isso soa júnior porque bibliotecas profissionais não precisam se auto-proclamar "mission-critical" - isso é algo que usuários decidem, não algo que se declara.

## Changes to README.md

### 1. Header description (line 3)
**Before:**
```
A TypeScript utility library providing runtime type validation, state management, and common helpers for mission-critical applications including WebGL games and high-frequency update scenarios (60fps+).
```

**After:**
```
A TypeScript utility library providing runtime type validation, state management, and common helpers.
```

### 2. Features list (line 22)
**Remove:**
```
- **Mission-Critical Ready** - Optimized for 60fps game loops
```

### 3. Section "Mission-Critical Usage" (lines 186-263)
**Rename to:** `## Performance Optimization`
- Remove marketing language
- Keep technical content (the actual useful info about `trackMetadata: false`)
- Simplify examples

### 4. Code comments cleanup
- `// Critical for 60fps` → `// Disable for better performance`
- `// Disable for 60fps performance` → `// Better performance`

## NPM Republish Strategy

**Decision:** Unpublish 0.1.0 e republicar (usuário confirmou)

## Execution Steps

1. [ ] Edit README.md - remove "mission-critical" mentions
2. [ ] Edit README.md - rename section to "Performance Optimization"
3. [ ] Edit README.md - clean up marketing tone throughout
4. [ ] Build: `pnpm build`
5. [ ] Typecheck: `pnpm typecheck`
6. [ ] Unpublish: `npm unpublish @belt/tools@0.1.0`
7. [ ] Publish: `cd packages/tools && pnpm publish --access public`

## Files to Modify
- `/Users/anotonio.silva/antonio/belt/packages/tools/README.md`
- `/Users/anotonio.silva/antonio/belt/packages/tools/package.json` (version bump)

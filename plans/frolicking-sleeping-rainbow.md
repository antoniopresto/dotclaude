# Plan: Mission-Critical Optimization for @belt/tools

## Context
Optimize @belt/tools for mission-critical applications (games with WebGL, high-frequency updates at 60fps).

## Analysis Summary

### Critical Issues Found

| Category | Count | Severity |
|----------|-------|----------|
| Performance bottlenecks | 11 | CRITICAL |
| Naming inconsistencies | 24 | HIGH |
| Memory allocation issues | 5 | MEDIUM |
| Unnecessary dependencies | 3 | MEDIUM |

---

## Phase 1: Critical Performance Fixes

### 1.1 Fix SliceRooks Typo (CRITICAL)
**File**: `packages/tools/src/state-machine/models/hooks.ts:40`
```typescript
// Before
export type SliceRooks<Slice> = { ... }

// After
export type SliceHooks<Slice> = { ... }
```

### 1.2 Optimize Store Listener Copy (CRITICAL for 60fps)
**File**: `packages/tools/src/state-machine/store.ts:60-63`
```typescript
// Before - O(n) array copy every dispatch
const listeners = [...currentListeners];

// After - Direct iteration (safe with splice protection)
for (let i = currentListeners.length - 1; i >= 0; i--) {
  currentListeners[i](currentState, action);
}
```

### 1.3 Fix list.ts O(n²) Spread
**File**: `packages/tools/src/helpers/list.ts`
```typescript
// Before - O(n²) spread
return items.reduce((acc, entry) => ({ ...acc, ...next }), {});

// After - O(n) Object.assign
const result = {} as Result;
for (const item of items) {
  const next = reducer(item);
  if (next !== undefined) Object.assign(result, next);
}
return result;
```

### 1.4 Fix ms.ts hasOwnProperty Shadow
**File**: `packages/tools/src/helpers/ms.ts:71`
```typescript
// Before
function hasOwnProperty<Obj>(...) { ... }

// After
function hasOwn<Obj>(...) { ... }
```

### 1.5 Optimize Cache Object.assign
**File**: `packages/tools/src/state-machine/cache.ts:228-230`
```typescript
// Before
Object.assign(result.cleanState, { [sliceKey]: value });

// After - Direct assignment
result.cleanState[sliceKey] = value;
```

### 1.6 Fix Schema LRU Cache TTL
**File**: `packages/tools/src/schema/schema.ts:33-36`
```typescript
// Before - 1 minute TTL (too short)
ttl: ms('1min')

// After - 1 hour TTL (schema rarely changes)
ttl: ms('1h')
```

---

## Phase 2: Replace Unnecessary Dependencies

### 2.1 Replace date-fns isValid in typeof.ts
**File**: `packages/tools/src/helpers/typeof.ts:1,19`
```typescript
// Before
import { isValid } from 'date-fns';
if (isValid(value)) return 'Date';

// After - Native implementation
if (value instanceof Date && !Number.isNaN(value.getTime())) return 'Date';
```

### 2.2 Optimize ms.ts to Remove date-fns
**File**: `packages/tools/src/helpers/ms.ts`
```typescript
// Add constant multipliers instead of date-fns milliseconds()
const MS_MULTIPLIERS = {
  milliseconds: 1,
  seconds: 1000,
  minutes: 60_000,
  hours: 3_600_000,
  days: 86_400_000,
  weeks: 604_800_000,
  months: 2_629_746_000, // Average month
  years: 31_556_952_000, // Average year
};
```

### 2.3 Create Native Lodash Replacements
**File**: `packages/tools/src/helpers/object-utils.ts`
```typescript
// Replace lodash/get with native implementation
export function getPath<T>(obj: unknown, path: string): T | undefined {
  return path.split('.').reduce((acc, key) =>
    acc && typeof acc === 'object' ? (acc as Record<string, unknown>)[key] : undefined
  , obj) as T | undefined;
}

// Replace lodash/isPlainObject with native
export function isPlainObject(value: unknown): value is Record<string, unknown> {
  if (value === null || typeof value !== 'object') return false;
  const proto = Object.getPrototypeOf(value);
  return proto === Object.prototype || proto === null;
}
```

---

## Phase 3: Naming Standardization

### 3.1 Terminology Standardization
| Old Term | New Term | Usage |
|----------|----------|-------|
| `Type` (for validation) | `Schema` | Runtime validation definitions |
| `Model` (for validation) | `Schema` | Runtime validation definitions |
| `Type` (for TypeScript) | `Type` | TypeScript type definitions |
| `SliceRooks` | `SliceHooks` | React hooks for slices |

### 3.2 Files to Rename/Refactor
- `schema/schema.ts`: `createType()` → `createSchema()`
- `schema/schema.ts`: `createModel()` → `createObjectSchema()`
- `schema/lib/type.ts`: Keep as internal, rename exports
- `state-machine/models/hooks.ts`: `SliceRooks` → `SliceHooks`

### 3.3 Export Standardization
```typescript
// schema/index.ts - Standardized exports
export { createSchema, createObjectSchema } from './schema';
export { isSchema, assertSchema } from './helpers';
export type { SchemaDefinition, InferSchema } from './infer-type';

// Deprecation aliases (backward compatibility)
/** @deprecated Use createSchema instead */
export const createType = createSchema;
/** @deprecated Use createObjectSchema instead */
export const createModel = createObjectSchema;
```

---

## Phase 4: Hooks Memoization for 60fps

### 4.1 Fix useMachine Return Memoization
**File**: `packages/tools/src/state-machine/hooks.ts:60-72`
```typescript
// Before - Creates new object every render
return isSliceKey
  ? { state: stateRef.current, actions: actionsRef.current }
  : stateRef.current;

// After - Memoized return
const resultRef = React.useRef<{ state: unknown; actions: unknown } | null>(null);
if (isSliceKey) {
  if (!resultRef.current || resultRef.current.state !== stateRef.current) {
    resultRef.current = { state: stateRef.current, actions: actionsRef.current };
  }
  return resultRef.current;
}
return stateRef.current;
```

---

## Phase 5: Documentation

### 5.1 Update README.md
- Add "Mission-Critical Usage" section
- Add performance configuration guide
- Add game loop integration example
- Add WebGL state management example

### 5.2 Add JSDoc to All Public APIs
- Schema validation functions
- State machine functions
- Helper utilities

### 5.3 Create MIGRATION.md
- Document naming changes
- Provide migration examples
- List deprecated APIs

---

## Files to Modify

| File | Changes | Risk |
|------|---------|------|
| `state-machine/models/hooks.ts` | Fix typo SliceRooks→SliceHooks | LOW |
| `state-machine/store.ts` | Optimize listener iteration | LOW |
| `state-machine/cache.ts` | Optimize Object.assign | LOW |
| `state-machine/hooks.ts` | Add memoization | MEDIUM |
| `helpers/list.ts` | Fix O(n²) spread | LOW |
| `helpers/ms.ts` | Rename hasOwn, optimize | LOW |
| `helpers/typeof.ts` | Remove date-fns | LOW |
| `helpers/object-utils.ts` | Add native replacements | MEDIUM |
| `schema/schema.ts` | Fix TTL, rename functions | MEDIUM |
| `schema/index.ts` | Standardize exports | LOW |
| `README.md` | Complete rewrite | LOW |

---

## Expected Outcome

- ✅ 60fps game loop compatible
- ✅ Consistent naming (Schema for validation, Type for TS)
- ✅ Reduced bundle size (no lodash/date-fns in hot paths)
- ✅ Memoized hooks for React performance
- ✅ Complete documentation for new users
- ✅ Backward compatible with deprecation warnings

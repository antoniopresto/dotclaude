# Documentation Plan for @zazcart/toolkit

## Objective
Create comprehensive professional documentation in a single README.md file with both a Quick Start Guide and Complete API Reference in English.

## Analysis Summary (Based on Real Source Code)

### Package Structure
```
src/
├── helpers/           # Pure utility functions
├── schema/            # Runtime type validation (TypeBox wrapper)
├── state-machine/     # Redux-like state management
└── index.ts           # Public API exports
```

### Exported Modules Identified

#### 1. Schema Module (`src/schema/`)
**Public Functions:**
- `createType(definition)` - Creates compiled type validator with LRU cache (2000 max, 1min TTL)
- `createModel(properties)` - Convenience for creating object schemas
- `isType(value, definition)` - Type guard
- `invariantType(definition, value, parent?, message?)` - Assertion with custom messages

**Types:**
- `InferType<T>` - Infer TypeScript type from definition
- `Type<Definition, Result>` - Compiled type wrapper
- `TypeDefinition` - Union of string and object definitions
- `TypeDefinitionString` - String format: `'typeName[?][][?]'`

**Supported Types:**
- Primitives: `string`, `number`, `boolean`, `null`, `undefined`, `date`, `function`, `object`, `unknown`, `any`
- Modifiers: `?` (optional), `[]` (array)
- Object definitions: `{ properties: {...} }`, `{ enum: [...] }`, `{ items: ... }`, `{ union: [...] }`, `{ record: ... }`

#### 2. State Machine Module (`src/state-machine/`)
**Public Functions:**
- `createMachine(config)` - Factory for state machines
- `createSlice(config)` / `createSyncSlice(config)` - Factory for sync slices
- `createAsyncSlice(config)` - Factory for async slices

**Machine Config Options:**
- `id: string` - Required unique identifier
- `slices: Record<string, Slice>` - Required slice definitions
- `context?: { userID, ...}` - Runtime context
- `selectors?: Record<string, (state) => T>` - Derived state
- `initial?: Partial<State>` - Initial state overrides (hydration)
- `sessionID?: string` - App session ID
- `trackMetadata?: boolean` - Enable/disable metadata tracking (default: false)

**Slice Config Options (Sync):**
- `id: string` - Unique identifier
- `initial: State` - Initial state
- `reducers: Record<string, (draft, payload) => void>` - Immer-based reducers
- `cache: CacheStrategy` - Cache configuration

**Slice Config Options (Async):**
- `id: string` - Unique identifier
- `load: (payload, context) => Promise<Result>` - Async loader
- `context: SliceContext` - Required context dependencies
- `cache: CacheStrategy` - Cache configuration
- `initial?: AsyncSliceState<Result>` - Optional initial override

**Cache Configuration:**
```typescript
type CacheStrategy = {
  policy: 'public' | 'private' | 'session';
  ttl?: MSTimeString;  // e.g., '1h', '30m', '5s'
  swr?: boolean;       // Stale-While-Revalidate (default: true)
}
```

**Generated Machine Properties:**
- `useMachine(path)` - React hook returning `{ state, actions }` for slices
- `useSelector(selector)` - React hook for state selection
- `use${ID}` / `use${ID}Selector` - Aliased hooks
- `actions`, `actionTypes` - Nested action creators/types
- `${ID}Actions`, `${ID}ActionTypes` - Flattened with CamelCase keys
- `dispatch(action)`, `getState()`, `subscribe(listener)`
- `reset()`, `getContext()`, `provideContext(context)`
- `invalidations` - Cache invalidation report

#### 3. Helpers Module (`src/helpers/`)

**Object Utilities:**
- `objectKeys(obj)` - Type-safe Object.keys
- `objectEntries(obj)` - Type-safe Object.entries
- `objectValues(obj)` - Type-safe Object.values
- `isObject(value)` - Plain object type guard
- `assertObject(value, message?)` - Object assertion
- `getProperty(obj, path, allowFalsy?)` - Deep property access with dot notation
- `setProperty(obj, path, value)` - Deep property setter
- `keyBy(arr, keyOrFn, onDuplicate?)` - Array to keyed object
- `reduceObject(obj, reducer)` - O(N) object reduction
- `flatRecordRecords(prefix, record)` - Flatten nested records with CamelCase
- `deepFreeze(obj)` - Recursive Object.freeze
- `requireAll(record)` - Assert all values non-falsy
- `objectHasOwnProperty(obj, key)` - Type-safe hasOwnProperty

**Error Utilities:**
- `invariant(value, message?, parent?)` - Assert non-falsy
- `InvariantError` - Custom error class with stack trace support
- `tryCatch(handler, parent?)` - Safe error handling returning tuple
- `moveStackTrace(errorOrFn, newStack)` - Relocate stack trace
- `isErrorLike(value)` / `assertErrorLike(value)` - Error type guards
- `createErrorList(prefix?)` - Collect multiple errors
- `captureStackTrace(error, constructor?)` - Cross-platform stack capture

**String Utilities:**
- `isString(value)` - String type guard
- `assertString(value, options?)` - String assertion with notEmpty option
- `capitalize(value)` - Capitalize first letter

**Time Utilities:**
- `ms(timeString)` - Convert time string to milliseconds
  - Units: `y`, `mo`/`mon`/`months`, `w`, `d`, `h`, `m`/`min`, `s`, `ms`
- `delay(time?)` - Promise-based delay (default 500ms)

**Date Utilities:**
- `formatDate(date, pattern, options?)` - Format dates with date-fns
- `setDefaultDateLocale(locale)` - Set global locale
- `getDefaultDateLocale()` - Get current locale

**Other Utilities:**
- `createProxy(thunk, target?)` - Lazy initialization proxy
- `maskData(value)` - Mask sensitive data for logging
- `getTypeOf(value)` - Human-readable type names
- `devLog(message, ...args)` - Dev-only logging
- `devAssert(error)` - Dev-only throw
- `setLogMode(mode)` - Set log mode ('production' | 'development')
- `EMPTY` - Unique sentinel symbol

**Type Utilities (TypeScript only):**
- `Writable<T>`, `Compute<T>`, `Paths<T>`, `PathType<T, P>`
- `UnionToIntersection<T>`, `Falsy`, `isFalsy()`, `NullableToPartial<T>`
- And many more type-level utilities

---

## Documentation Structure

### README.md Sections

1. **Header & Badges**
   - Package name, version, license
   - npm/CI badges

2. **Overview**
   - Brief description
   - Key features list
   - Installation

3. **Quick Start Guide**
   - Schema validation example
   - State machine example
   - Helper utilities example

4. **API Reference**

   **4.1 Schema Module**
   - createType / createModel
   - Type definitions (string vs object format)
   - InferType usage
   - isType / invariantType
   - Complete type list

   **4.2 State Machine Module**
   - createMachine configuration
   - createSlice / createAsyncSlice
   - React hooks (useMachine, useSelector)
   - Cache strategies
   - Action types and creators
   - Metadata and invalidations

   **4.3 Helpers Module**
   - Object utilities
   - Error handling
   - String utilities
   - Time utilities
   - Date formatting
   - Development utilities

5. **Advanced Usage**
   - High-frequency machines (60fps)
   - Custom selectors
   - Context management
   - Cache invalidation handling

6. **TypeScript Support**
   - Type inference examples
   - Utility types overview

7. **License**

---

## Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `README.md` | Create/Replace | Complete documentation |

---

## Implementation Steps

1. **Create README.md structure**
   - Header with package info
   - Table of contents

2. **Write Quick Start section**
   - Installation command
   - 3 practical examples (schema, state-machine, helpers)

3. **Document Schema Module**
   - createType/createModel with all options
   - All type definition formats
   - InferType examples
   - Validation helpers

4. **Document State Machine Module**
   - createMachine with all config options
   - createSlice/createAsyncSlice
   - All React hooks
   - Cache strategies with examples
   - Generated properties

5. **Document Helpers Module**
   - Group by category
   - Function signatures from real code
   - Usage examples

6. **Add Advanced Usage section**
   - Performance guidelines
   - Complex patterns

7. **Final review**
   - Verify all exports are documented
   - Check examples compile
   - Ensure consistency

---

## Notes

- Documentation based on actual source code analysis (not existing comments)
- Package name: `@zazcart/toolkit`
- All function signatures derived from real implementation
- Types documented match actual TypeScript definitions

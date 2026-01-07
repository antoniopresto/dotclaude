# Plan: Toolkit Package Documentation

## Objective
Write comprehensive, concise documentation in English for the `@uptime/toolkit` package. The documentation must serve both humans and LLMs, documenting all utilities with usage examples.

## Analysis Summary

Based on my deep reading of the codebase, the toolkit has 3 main modules:

### 1. Schema System (`schema/`)
Core files: `schema.ts`, `infer-type.ts`, `helpers.ts`, `lib/type.ts`

**Public API:**
- `createType(definition)` - Create validated types
- `createModel({properties})` - Shorthand for object schemas
- `isType(value, definition)` - Type guard
- `invariantType(definition, value)` - Assert type or throw
- `InferType<T>` - TypeScript type inference
- `Type<D,R>` - Schema type with methods

**Type Definitions:**
- Primitives: `'string'`, `'number'`, `'boolean'`, `'null'`, `'undefined'`, `'date'`, `'function'`, `'object'`, `'unknown'`, `'any'`
- Modifiers: `'string?'` (optional), `'string[]'` (array), `'string[]?'` (optional array)
- Objects: `{properties: {name: 'string', age: 'number'}}`
- Enums: `{enum: ['a', 'b', 'c'] as const}`
- Unions: `{union: ['string', 'number', 'null']}`
- Arrays: `{items: 'string'}` or `{items: {properties: {...}}}`
- Records: `{record: 'string'}`

**Schema Methods:**
- `.parse(value, path?)` - Parse and validate, throws on error
- `.parseList(value, path?)` - Parse array of items
- `.isValid(value)` - Type guard boolean check
- `.list()` - Get array schema of this type

### 2. State Machine (`state-machine/`)
Core files: `machine.ts`, `slice.ts`, `cache.ts`, `models.ts`, `hooks.ts`

**Public API:**
- `createMachine(config)` - Create state machine
- `createSlice(config)` / `createSyncSlice(config)` - Sync slice
- `createAsyncSlice(config)` - Async slice with load/success/fail/clear

**Machine Config:**
```typescript
{
  id: string,
  slices: { [key]: Slice },
  selectors?: { [key]: (state) => value },
  context?: { userID?: string },
  initial?: State,
  sessionID?: string
}
```

**Slice Config (Sync):**
```typescript
{
  id: string,
  initial: State,
  reducers: { [name]: (draft, payload) => void },
  cache: 'session' | 'user' | 'global'
}
```

**Slice Config (Async):**
```typescript
{
  id: string,
  load: (context) => Promise<T>,
  context?: SliceContext,
  cache: 'session' | 'user' | 'global',
  initial?: AsyncSliceState<T>
}
```

**Machine Instance API:**
- `.dispatch(action)` - Dispatch action
- `.getState()` - Get current state
- `.subscribe(listener)` - Subscribe to changes
- `.reset()` - Reset to initial state
- `.actions` - Action creators by slice
- `.actionTypes` - Action type strings
- `.reducer` - Root reducer
- `.getContext()` / `.provideContext(ctx)`
- `.useMachine()` - React hook
- `.useSelector(selector)` - React selector hook

### 3. Helpers (`helpers/`)

**Error Utilities (`error-utils`):**
- `InvariantError` - Custom error class
- `invariant(value, message?)` - Assert truthy or throw
- `tryCatch(fn)` - Returns `[error, result]` tuple
- `moveStackTrace(error, fn)` - Clean stack traces
- `createErrorList(prefix?)` - Collect multiple errors

**Object Utilities (`object-utils`):**
- `getProperty(obj, path, allowFalsy?)` - Type-safe deep get
- `setProperty(obj, path, value)` - Type-safe deep set
- `objectKeys(obj)` - Typed Object.keys
- `objectEntries(obj)` - Typed Object.entries
- `objectValues(obj)` - Typed Object.values
- `isObject(value)` - Plain object check
- `assertObject(value)` - Assert plain object
- `keyBy(array, key)` - Create lookup object
- `reduceObject(obj, reducer)` - Reduce over entries
- `requireAll(obj)` - Assert no falsy values
- `deepFreeze(obj)` - Recursive Object.freeze
- `flatRecordRecords(prefix, record)` - Flatten nested records

**Type Utilities (`type-utils`):**
- `stringEnum(...values)` - Create typed enum array
- Types: `AnyRecord`, `UnknownRecord`, `Simplify<T>`, `Merge<A,B>`, `Paths<T>`, `PathType<T,P>`, `PromiseValue<T>`, `MaybePromise<T>`, `MaybeArray<T>`, `Writable<T>`, `PartialFields<T>`, `NullableToPartial<T>`, `UnionToIntersection<U>`, `IsAny<T>`, `IsNever<T>`, `IsOptional<T>`, `Cast<A,B>`, `Join<T,D>`, `Primitive`, `Serializable`, `AnyFunction`

**Time Utilities (`ms`):**
- `ms(timeString)` - Convert to milliseconds
- Formats: `'1s'`, `'5m'`, `'2h'`, `'1d'`, `'1w'`, `'1mo'`, `'1y'`

**Other Helpers:**
- `getTypeOf(value)` - Get type name string
- `maskData(value)` - Mask sensitive data for logging
- `delay(ms?)` - Promise-based setTimeout
- `createProxy(thunk)` - Lazy initialization proxy
- `formatDate(date, pattern)` - Format dates (ptBR locale)
- `EMPTY` - Unique symbol for empty values

## Documentation Structure

```markdown
# @uptime/toolkit

## Installation
## Quick Start

## Schema System
### createType / createModel
### Type Definitions
### Type Inference
### Validation Methods
### Helper Functions

## State Machine
### createMachine
### createSlice (Sync)
### createAsyncSlice
### Cache Strategies
### React Hooks

## Helpers
### Error Utilities
### Object Utilities
### Type Utilities
### Time Utilities
### Other Utilities
```

## File to Create
- `/Users/anotonio.silva/antonio/uptime/packages/toolkit/README.md`

## Approach
1. Write in English
2. Be concise but complete - every export documented
3. Use code examples from actual tests
4. Structure for quick scanning (headers, tables, code blocks)
5. Optimize for LLM consumption (clear patterns, no ambiguity)

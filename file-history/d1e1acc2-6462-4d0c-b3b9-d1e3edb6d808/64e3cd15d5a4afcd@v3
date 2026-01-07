# Technical Debt - Belt Monorepo

## Executive Summary

**Project**: Belt v0.1.0 (pre-release)
**Status**: Solid architecture, but critical gaps before NPM publishing
**Total Issues**: 47 items identified

| Severity | Count | Action |
|----------|-------|--------|
| Critical | 8 | Blocks publishing |
| High | 15 | Must resolve before v1.0 |
| Medium | 16 | Important improvements |
| Low | 8 | Nice-to-have |

---

## 1. MICRO ANALYSIS (Point Issues)

### 1.1 Confirmed Bugs

| File | Line | Severity | Description |
|------|------|----------|-------------|
| `apps/cli/src/app.tsx` | 60 | **CRITICAL** | UI executes `belt.check()` instead of selected command |
| `packages/plugins/sync-types/src/generate.ts` | 102-103 | **CRITICAL** | Generates invalid syntax for default exports: `export default {} as Type` |
| `packages/tools/src/helpers/logs.ts` | 14 | **HIGH** | Assignment in expression: `return (LOG_MODE = mode)` |
| `packages/plugins/sync-types/src/discover.ts` | 68-74 | **HIGH** | Naive regex for pattern matching - `**` becomes `.*` incorrectly |

### 1.2 Missing Error Handling

| File | Lines | Problem |
|------|-------|---------|
| `apps/cli/src/cli.ts` | 63-64, 78, 88 | Async calls without try-catch - silent crashes |
| `packages/core/src/belt.ts` | 78-80, 105 | Plugin initialization and command execution without error handling |
| `packages/plugins/sync-types/src/discover.ts` | 16, 40 | Doesn't validate if sourceDir exists before `readdirSync` |
| `packages/plugins/sync-types/src/write.ts` | 16 | `mkdirSync` can fail silently |
| `packages/plugins/typecheck/src/typecheck.ts` | 25-36 | Silent failure when tsconfig.json not found |

### 1.3 Type Safety Issues

| File | Line | Problem |
|------|------|---------|
| `packages/tools/src/helpers/compose.ts` | 19, 29, 40 | Multiple `any` in overloads |
| `packages/tools/src/helpers/function.ts` | 1 | Uses `Function` type (banned) |
| `packages/tools/src/helpers/object-utils.ts` | 131 | `objectHasOwnProperty` doesn't validate key type |
| `packages/tools/src/helpers/mask-data.ts` | 8-9 | `any` in recursive function |

### 1.4 Hardcoded Values

| File | Line | Value | Should Be |
|------|------|-------|-----------|
| `packages/plugins/sync-types/src/plugin.ts` | 34 | `'src'` | Configurable |
| `packages/plugins/typecheck/src/typecheck.ts` | 14-15 | `['src']` include default | Documented/configurable |
| `packages/core/src/belt.ts` | 48-53 | ANSI color codes | Respect NO_COLOR env |

### 1.5 Resource Leaks

| File | Line | Problem |
|------|------|---------|
| `packages/plugins/typecheck/src/typecheck.ts` | 48-51 | TypeScript program never disposed - memory leak in long-running |

---

## 2. MACRO ANALYSIS (Module-Level Problems)

### 2.1 @belt/core

**Status**: Functional, but fragile

| Issue | Severity | Description |
|-------|----------|-------------|
| No duplicate plugin validation | Medium | Plugins with same name can cause command ID collisions |
| No rootDir validation | Medium | Doesn't verify if directory exists/accessible |
| No timeout for commands | Low | Long-running commands can hang process |
| Hardcoded logging | Low | ANSI colors not disableable |

### 2.2 @belt/plugin-typecheck

**Status**: Basic but functional

| Issue | Severity | Description |
|-------|----------|-------------|
| Vulnerable path matching | High | `startsWith()` causes false positives (`/src-backup/` matches `/src/`) |
| Exclude patterns too simple | Medium | Doesn't use minimatch or similar |
| Inconsistent diagnostic category | Medium | `errorCount > messages.length` possible |
| No include/exclude validation | Low | Silent conflicts |

### 2.3 @belt/plugin-sync-types

**Status**: Basic - needs refinements (documented in CLAUDE.md)

| Issue | Severity | Description |
|-------|----------|-------------|
| Broken default export | **CRITICAL** | Invalid `.d.ts` syntax |
| Naive pattern matching | **HIGH** | Glob patterns don't work correctly |
| Incomplete import discovery | High | Only gets top-level imports, ignores nested/dynamic |
| Circular deps not handled | Medium | May hit maxDepth unnecessarily |
| Simplistic type generation | Medium | Loses transitive dependencies |
| Hardcoded `'src'` directory | Medium | Doesn't work with different structures |

### 2.4 @belt/tools

**Status**: Robust, minor issues

| Issue | Severity | Description |
|-------|----------|-------------|
| Lint warnings (127) | Medium | Mostly justified `any` types but flagged |
| Unused typebox import in DTS | Low | Warning in build output |
| Inconsistent error handling in objectKeys | Low | Non-Error throws ignored |

### 2.5 @belt/cli

**Status**: Functional with critical bugs

| Issue | Severity | Description |
|-------|----------|-------------|
| UI executes wrong command | **CRITICAL** | Always runs `belt.check()` ignoring selection |
| Async without error handling | High | Silent crashes |
| No --cwd validation | Medium | Late error if path invalid |
| No error boundary in UI | Medium | Can hang |
| Inconsistent exit codes | Low | runCommand doesn't exit on error |

---

## 3. HOLISTIC ANALYSIS (Architectural Problems)

### 3.1 Test Coverage

**CRITICAL - Biggest project gap**

```
Current:
  packages/tools/src/schema/lib/__tests__/type.spec.ts (1 file)

Missing:
  - Tests for @belt/core (0%)
  - Tests for @belt/plugin-typecheck (0%)
  - Tests for @belt/plugin-sync-types (0%)
  - Tests for @belt/cli (0%)
  - Integration tests (0%)
  - E2E tests (0%)
```

**Impact**: High regression risk during publishing and consumer usage.

### 3.2 CI/CD

**CRITICAL - Non-existent**

- No `.github/workflows/`
- Only local Husky hooks (insufficient)
- Pre-commit runs lint (which has 7 errors = **blocks commits**)
- Pre-push doesn't run tests

### 3.3 Build Configuration

**Inconsistencies found**:

| Config | Problem |
|--------|---------|
| `packages/tools/tsconfig.json` L8-9 | `module: ESNext` + `moduleResolution: Bundler` incompatible |
| `packages/tools/tsup.config.ts` | Builds ESM+CJS but tsconfig is different |
| `.npmrc` L4 | `link-workspace-packages=false` unusual for monorepo |

### 3.4 Documentation

**Gaps identified**:

1. **Outdated/Inconsistent**:
   - CLI README mentions `--output` that doesn't exist
   - sync-types README pattern format different from actual CLI
   - Programmatic examples don't match actual exports

2. **Missing**:
   - API reference for BeltContext and hooks
   - Troubleshooting guide
   - Migration guide
   - ADRs (Architecture Decision Records)

### 3.5 Error Handling Strategy

**Missing as architectural pattern**

- Only `InvariantError` exists in tools
- No structured error classes for other contexts
- No error context propagation
- No established recovery patterns

---

## 4. PRIORITIZATION MATRIX

### 4.1 Blocks NPM Publishing (Resolve Now)

| # | Issue | File | Effort |
|---|-------|------|--------|
| 1 | Bug: UI executes wrong command | `app.tsx:60` | 5min |
| 2 | Bug: Default export invalid syntax | `generate.ts:102-103` | 15min |
| 3 | Lint error blocking commits | `logs.ts:14` | 2min |
| 4 | Async error handling CLI | `cli.ts` | 30min |
| 5 | Validate sourceDir exists | `discover.ts:16` | 10min |
| 6 | Add minimal core tests | new | 2h |
| 7 | Create basic GitHub Actions | new | 1h |
| 8 | Fix tsconfig/tsup mismatch tools | `tools/tsconfig.json` | 15min |

### 4.2 Before v1.0 (High Impact)

| # | Issue | Module | Effort |
|---|-------|--------|--------|
| 9 | Pattern matching with minimatch | sync-types | 1h |
| 10 | Safe path matching | typecheck | 30min |
| 11 | Complete plugin error handling | core + plugins | 2h |
| 12 | Duplicate plugin validation | core | 30min |
| 13 | Complete import discovery | sync-types | 2h |
| 14 | Integration tests | new | 4h |
| 15 | API documentation | docs | 3h |
| 16 | Dispose TypeScript program | typecheck | 15min |

### 4.3 Important Improvements (Medium Term)

| # | Issue | Module | Effort |
|---|-------|--------|--------|
| 17 | Respect NO_COLOR env | core | 30min |
| 18 | Path configurability | sync-types | 1h |
| 19 | Error boundary UI | cli | 30min |
| 20 | Structured error classes | tools | 2h |
| 21 | Circular deps handling | sync-types | 1h |
| 22 | Config validation | core + plugins | 1h |
| 23 | Loading state during init | cli | 30min |

### 4.4 Nice-to-Have (Low Priority)

| # | Issue | Effort |
|---|-------|--------|
| 24 | Timeout for commands | 30min |
| 25 | Storybook for UI | 2h |
| 26 | E2E tests with Playwright | 4h |
| 27 | Documented ADRs | 2h |
| 28 | Coverage reporting | 1h |

---

## 5. WORK DEPENDENCIES

```
Fix lint errors ──► Pre-commit works ──► Add tests ──► GitHub Actions ──► Publish NPM
                                                                              ▲
Fix UI bug ────────────────────────────────────────────────────────────────────┤
Fix sync-types default export ─────────────────────────────────────────────────┤
Fix tsconfig mismatch ─────────────────────────────────────────────────────────┘

Pattern matching ──► sync-types reliable
Error handling ──► Production robust
```

---

## 6. QUICK WINS (< 30min each)

1. **`logs.ts:14`** - Change `return (LOG_MODE = mode)` to two lines
2. **`app.tsx:60`** - Use `belt.runCommand(command.id)` instead of `belt.check()`
3. **`generate.ts:102-103`** - Fix default export syntax
4. **`tools/tsconfig.json`** - Align module/moduleResolution
5. **`.npmrc:4`** - Evaluate if `link-workspace-packages=false` is intentional

---

# COMPLETE RESOLUTION ROADMAP

## Phase 0: Immediate Quick Wins (~30 min)
> Unblocks commits and fixes critical bugs

- [ ] **QW-1** `packages/tools/src/helpers/logs.ts:14` - Fix lint error (assignment in expression)
- [ ] **QW-2** `apps/cli/src/app.tsx:60` - Fix UI bug (executes wrong command)
- [ ] **QW-3** `packages/plugins/sync-types/src/generate.ts:102-103` - Fix default export syntax
- [ ] **QW-4** `packages/tools/tsconfig.json:8-9` - Align module/moduleResolution
- [ ] **QW-5** `.npmrc:4` - Evaluate/document link-workspace-packages=false

## Phase 1: CLI Error Handling (~1h)
> Stabilizes CLI execution

- [ ] **EH-1** `apps/cli/src/cli.ts:63-64` - try-catch in runTypecheck
- [ ] **EH-2** `apps/cli/src/cli.ts:78` - try-catch in runSyncTypes
- [ ] **EH-3** `apps/cli/src/cli.ts:88` - try-catch in runCommand
- [ ] **EH-4** `apps/cli/src/bin.ts` - Global error handling wrapper
- [ ] **EH-5** `apps/cli/src/app.tsx` - Error boundary for UI mode
- [ ] **EH-6** Validate --cwd exists before using

## Phase 2: Core + Plugin Error Handling (~1.5h)
> Robustness in plugin layer

- [ ] **EHP-1** `packages/core/src/belt.ts:78-80` - try-catch plugin.apply()
- [ ] **EHP-2** `packages/core/src/belt.ts:105` - try-catch command.handler()
- [ ] **EHP-3** `packages/core/src/belt.ts` - Validate rootDir exists
- [ ] **EHP-4** `packages/plugins/sync-types/src/discover.ts:16` - Validate sourceDir
- [ ] **EHP-5** `packages/plugins/sync-types/src/write.ts:16` - try-catch mkdirSync
- [ ] **EHP-6** `packages/plugins/sync-types/src/generate.ts:15-24` - try-catch TS operations
- [ ] **EHP-7** `packages/plugins/typecheck/src/typecheck.ts:25-36` - Differentiate config not found

## Phase 3: Sync-Types Refinement (~3h)
> Makes sync-types production-ready

- [ ] **ST-1** `discover.ts:68-74` - Use minimatch for pattern matching
- [ ] **ST-2** `discover.ts:23-31` - Implement recursive import discovery
- [ ] **ST-3** `discover.ts` - Support dynamic imports
- [ ] **ST-4** `generate.ts:28-42` - Improve circular deps handling
- [ ] **ST-5** `generate.ts:89-108` - Preserve transitive dependencies
- [ ] **ST-6** `generate.ts:98` - Don't truncate complex types
- [ ] **ST-7** `plugin.ts:34` - Make source dir configurable
- [ ] **ST-8** `write.ts:23-26` - Fix multi-line type indentation
- [ ] **ST-9** Add --output option to CLI
- [ ] **ST-10** Consult branch `feature/SPMAIS-31425-quality-clean` for refinements

## Phase 4: Typecheck Improvements (~1h)
> Fixes vulnerabilities and leaks

- [ ] **TC-1** `typecheck.ts:64-67` - Safe path matching (don't use startsWith)
- [ ] **TC-2** `typecheck.ts:65` - Use minimatch for exclude patterns
- [ ] **TC-3** `typecheck.ts:57-59` - Consistency errorCount vs messages.length
- [ ] **TC-4** `typecheck.ts:48-51` - Dispose TypeScript program (memory leak)
- [ ] **TC-5** Validate include/exclude don't conflict

## Phase 5: Core Improvements (~1h)
> Improves plugin system

- [ ] **CO-1** `belt.ts` - Duplicate plugin validation (by name)
- [ ] **CO-2** `belt.ts:48-53` - Respect NO_COLOR env var
- [ ] **CO-3** `belt.ts` - Optional timeout for commands
- [ ] **CO-4** Report which plugin failed in initialization
- [ ] **CO-5** Document BeltContext and hooks

## Phase 6: Tools Package Cleanup (~1h)
> Resolves lint warnings and type issues

- [ ] **TL-1** `compose.ts:19,29,40` - Resolve any types or add justified biome-ignore
- [ ] **TL-2** `function.ts:1` - Replace Function with safe type
- [ ] **TL-3** `object-utils.ts:131` - Validate key type in objectHasOwnProperty
- [ ] **TL-4** `object-utils.ts:42-47` - Document non-Error throws behavior
- [ ] **TL-5** `mask-data.ts:8-9` - Type recursion or justify any
- [ ] **TL-6** `error-utils.ts:36-43` - Add version check for Bun workaround
- [ ] **TL-7** Resolve remaining 127 lint warnings

## Phase 7: Test Infrastructure (~2h)
> Creates testing foundation

- [ ] **TST-1** Add vitest config to @belt/core
- [ ] **TST-2** Add vitest config to @belt/plugin-typecheck
- [ ] **TST-3** Add vitest config to @belt/plugin-sync-types
- [ ] **TST-4** Add vitest config to @belt/cli
- [ ] **TST-5** Create `pnpm test` script at root
- [ ] **TST-6** Create `pnpm test:watch` script
- [ ] **TST-7** Update pre-push hook to include tests

## Phase 8: Core Tests (~2h)
> Basic core coverage

- [ ] **CT-1** Test: Belt class initialization
- [ ] **CT-2** Test: Plugin registration
- [ ] **CT-3** Test: Plugin duplicate detection
- [ ] **CT-4** Test: Command registration
- [ ] **CT-5** Test: Command execution
- [ ] **CT-6** Test: Hook system (tapable)
- [ ] **CT-7** Test: Error propagation

## Phase 9: Plugin Tests (~2h)
> Plugin coverage

- [ ] **PT-1** Test: typecheck with valid tsconfig
- [ ] **PT-2** Test: typecheck with invalid tsconfig
- [ ] **PT-3** Test: typecheck path filtering
- [ ] **PT-4** Test: sync-types pattern matching
- [ ] **PT-5** Test: sync-types import discovery
- [ ] **PT-6** Test: sync-types declaration generation
- [ ] **PT-7** Test: sync-types edge cases (circular deps, complex types)

## Phase 10: CLI Tests (~1.5h)
> CLI coverage

- [ ] **CLT-1** Test: command parsing
- [ ] **CLT-2** Test: --cwd validation
- [ ] **CLT-3** Test: error exit codes
- [ ] **CLT-4** Test: help output
- [ ] **CLT-5** Test: UI rendering (snapshot or visual)

## Phase 11: CI/CD Setup (~1.5h)
> GitHub automation

- [ ] **CI-1** Create `.github/workflows/test.yml` (lint, build, typecheck, test)
- [ ] **CI-2** Create `.github/workflows/publish.yml` (manual trigger)
- [ ] **CI-3** Add status badge to README
- [ ] **CI-4** Configure Codecov or similar for coverage
- [ ] **CI-5** Create workflow for automatic releases

## Phase 12: Documentation (~2h)
> Updates all documentation

- [ ] **DOC-1** Fix: CLI README --output inconsistency
- [ ] **DOC-2** Fix: sync-types README pattern format
- [ ] **DOC-3** Fix: programmatic examples match actual exports
- [ ] **DOC-4** Add: API reference for BeltContext
- [ ] **DOC-5** Add: API reference for hooks
- [ ] **DOC-6** Add: Troubleshooting guide
- [ ] **DOC-7** Add: Error codes documentation
- [ ] **DOC-8** Add: ADR-001 (Why tapable?)
- [ ] **DOC-9** Add: ADR-002 (Why Ink?)
- [ ] **DOC-10** Review CLAUDE.md for accuracy

## Phase 13: Final Polish (~1h)
> Final preparation for publishing

- [ ] **FP-1** Run full build and verify zero errors
- [ ] **FP-2** Run full lint and verify zero critical warnings
- [ ] **FP-3** Run full test suite and verify 100% pass
- [ ] **FP-4** Verify package.json files arrays
- [ ] **FP-5** Test publishing with --dry-run
- [ ] **FP-6** Update CHANGELOG.md
- [ ] **FP-7** Git tag v0.1.0
- [ ] **FP-8** Publish to NPM

---

## Total Estimate

| Phase | Time | Cumulative |
|-------|------|------------|
| 0. Quick Wins | 30min | 30min |
| 1. Error Handling CLI | 1h | 1h30 |
| 2. Error Handling Plugins | 1.5h | 3h |
| 3. Sync-Types Refinement | 3h | 6h |
| 4. Typecheck Improvements | 1h | 7h |
| 5. Core Improvements | 1h | 8h |
| 6. Tools Cleanup | 1h | 9h |
| 7. Test Infrastructure | 2h | 11h |
| 8. Core Tests | 2h | 13h |
| 9. Plugin Tests | 2h | 15h |
| 10. CLI Tests | 1.5h | 16.5h |
| 11. CI/CD Setup | 1.5h | 18h |
| 12. Documentation | 2h | 20h |
| 13. Final Polish | 1h | **21h total** |

---

## Harness Tracking

After approval, `claude-progress.txt` will be updated with:

```markdown
## Technical Debt Resolution
- Current Phase: 0 (Quick Wins)
- Progress: 0/92 items
- Started: [date]
- Estimated Completion: ~21h of work

### Phase Status
- [ ] Phase 0: Quick Wins (0/5)
- [ ] Phase 1: Error Handling CLI (0/6)
- [ ] Phase 2: Error Handling Plugins (0/7)
- [ ] Phase 3: Sync-Types (0/10)
- [ ] Phase 4: Typecheck (0/5)
- [ ] Phase 5: Core (0/5)
- [ ] Phase 6: Tools (0/7)
- [ ] Phase 7: Test Infra (0/7)
- [ ] Phase 8: Core Tests (0/7)
- [ ] Phase 9: Plugin Tests (0/7)
- [ ] Phase 10: CLI Tests (0/5)
- [ ] Phase 11: CI/CD (0/5)
- [ ] Phase 12: Docs (0/10)
- [ ] Phase 13: Polish (0/8)
```

---

## Critical Files (Modification Order)

### Phase 0-2 (Unblocking)
```
packages/tools/src/helpers/logs.ts
apps/cli/src/app.tsx
packages/plugins/sync-types/src/generate.ts
packages/tools/tsconfig.json
apps/cli/src/cli.ts
apps/cli/src/bin.ts
packages/core/src/belt.ts
packages/plugins/sync-types/src/discover.ts
packages/plugins/sync-types/src/write.ts
packages/plugins/typecheck/src/typecheck.ts
```

### Phase 3-6 (Refinement)
```
packages/plugins/sync-types/src/discover.ts
packages/plugins/sync-types/src/generate.ts
packages/plugins/sync-types/src/plugin.ts
packages/plugins/sync-types/src/write.ts
packages/plugins/typecheck/src/typecheck.ts
packages/core/src/belt.ts
packages/tools/src/helpers/compose.ts
packages/tools/src/helpers/function.ts
packages/tools/src/helpers/object-utils.ts
packages/tools/src/helpers/mask-data.ts
packages/tools/src/helpers/error-utils.ts
```

### Phase 7-11 (Tests and CI)
```
packages/core/vitest.config.ts (new)
packages/core/src/__tests__/*.spec.ts (new)
packages/plugins/typecheck/vitest.config.ts (new)
packages/plugins/typecheck/src/__tests__/*.spec.ts (new)
packages/plugins/sync-types/vitest.config.ts (new)
packages/plugins/sync-types/src/__tests__/*.spec.ts (new)
apps/cli/vitest.config.ts (new)
apps/cli/src/__tests__/*.spec.ts (new)
.github/workflows/test.yml (new)
.github/workflows/publish.yml (new)
.husky/pre-push
package.json (scripts)
```

### Phase 12-13 (Docs and Polish)
```
apps/cli/README.md
packages/plugins/sync-types/README.md
packages/core/README.md
docs/api-reference.md (new)
docs/troubleshooting.md (new)
docs/adr/001-tapable.md (new)
docs/adr/002-ink.md (new)
CLAUDE.md
CHANGELOG.md
claude-progress.txt
```

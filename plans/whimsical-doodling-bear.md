# Migration Analysis Plan: feature/SPMAIS-32275_ (MyOrdersDetails ONLY)

## User Requirements (Confirmed)
- **Source of truth**: card-place for feature-specific logic (QA tested)
- **Scope**: ONLY MyOrdersDetails screen + orderDetail service layer
- **Context**: Other changes in the branch (ExtractRewardProgram, MyOrdersRewardProgram, etc.) were already migrated previously
- **Allowed fixes**: Changes that don't alter runtime logic (typing fixes, namings, etc.);

## Executive Summary

Focus on **MyOrdersDetails** ("Detalhes do pedido") feature only. The branch contains 56 files but most were already migrated. This analysis covers only the orderDetail-specific files.

---

## 1. Findings Overview

### 1.1 Folder Structure (No Issues Found)
| card-place | rewardprogram | Status |
|------------|---------------|--------|
| `src/store/rewardProgram/` | `src/services/` | Intentional mapping |
| `src/store/` imports | `~/store` imports | Correct per STYLE_GUIDE |

**newArch folder**: Only exists in `node_modules/@semparar/mf-app-user/` - NOT in source code of either repo. No conflict resolution issues detected.

### 1.2 Files Changed by Branch

| Category | Count | Details |
|----------|-------|---------|
| Deleted | 16 | PointsExtract screen, tests, Redux sagas |
| Added (Screens) | 11 | ExtractRewardProgram, MyOrdersDetails, MyOrdersRewardProgram |
| Added (Zustand) | 12 | api, repository, service, store, models for extract/orderDetail |
| Added (Other) | 2 | docs/zustand.md, test file |
| Modified | 15 | Routes, Points, PointsDetail, Redux, store slices |

---

## 2. Critical Differences Requiring Verification

### 2.1 ExtractRewardProgram Screen (HIGH PRIORITY)

| Aspect | card-place | rewardprogram | Impact |
|--------|-----------|---------------|--------|
| Error handling | `hasError: false` (hardcoded) | Full conditional logic | **LOGIC CHANGE** |
| Focus refresh | Not implemented | `useFocusEffect` refreshes data | **LOGIC CHANGE** |
| Points display | `toLocaleString()` | `Math.floor().toLocaleString()` | Display difference |
| Loading indicator | `ActivityIndicator` | `LoadingFooter` | UI component |

**Questions:**
- Is the error handling in card-place a regression or intentional?
- Should rewardprogram's focus refresh logic be backported?

### 2.2 MyOrdersRewardProgram Screen (MEDIUM PRIORITY)

| Aspect | card-place | rewardprogram | Impact |
|--------|-----------|---------------|--------|
| Screen name | MyOrdersRewardProgram | MyOrdersCashback | Different names |
| Amount display | `String(item.amount)` | `String(Math.abs(item.amount))` | **LOGIC CHANGE** |
| Empty state | Minimal styling | `pd="innerLarger"` padding | UI difference |

### 2.3 MyOrdersDetails Screen (LOW PRIORITY)

| Aspect | card-place | rewardprogram | Status |
|--------|-----------|---------------|--------|
| useMemo | No memoization | Wrapped in useMemo | Optimization added |
| Type casts | `as any` | `as never` | Cleaner type handling |
| handleOpenInfo | Connected | Marked unused (`_handleOpenInfo`) | **BUG in rewardprogram** |
| Type definitions | `number` | `number \| string` | More permissive |

### 2.4 PointsDetail Screen (MEDIUM PRIORITY)

| Aspect | Changed |
|--------|---------|
| Transaction types | `DEBIT` → `RESCUE`, `RECEIVED` → `CREDIT` |
| Function names | `formatPointsValue` → `getFormattedPointsValue` |
| Props | Removed filter management (moved to Zustand) |

### 2.5 Routes (MEDIUM PRIORITY)

| Route | Change |
|-------|--------|
| PointsExtract | Renamed to ExtractRewardProgram |
| PointsDetail | Props changed: `transaction` object → `transactionId` string |
| MyOrdersRewardProgram | Added |
| MyOrdersDetails | Added with `{transactionId, type?, icon?, status?, origination?}` |

---

## 3. Proposed Analysis Workflow

### Phase A: Service Layer Verification
Compare Zustand services between repos:
1. `extract.api.ts` - API endpoints and DTOs
2. `extract.repository.ts` - Data mapping
3. `extract.service.ts` - Business logic
4. `extract.store.ts` - State management
5. `orderDetail.api.ts` / `repository.ts` / `service.ts` / `store.ts`

### Phase B: Screen Logic Verification
For each screen, verify:
1. Import paths correctly mapped
2. Business logic preserved (or differences documented)
3. Navigation parameters match route definitions
4. Analytics events preserved

### Phase C: Type Consistency Check
1. Verify enum values match (`RESCUE` vs `DEBIT`, `CREDIT` vs `RECEIVED`)
2. Verify interface definitions are compatible
3. Check for type widening/narrowing issues

### Phase D: Integration Points
1. Redux → Zustand migration completeness
2. `~/store` imports resolve correctly
3. Route parameter types match screen expectations

---

## 4. Files to Analyze (Grouped)

### Group 1: Service Layer (card-place → rewardprogram mapping)
```
src/store/rewardProgram/api/extract.api.ts      → src/services/api/extract.api.ts
src/store/rewardProgram/repository/extract.repository.ts → src/services/repository/extract.repository.ts
src/store/rewardProgram/services/extract.service.ts      → src/services/services/extract.service.ts
src/store/rewardProgram/store/extract.store.ts  → src/services/store/extract.store.ts
src/store/rewardProgram/models/extract.model.ts → src/services/models/extract.model.ts
```
(Same pattern for orderDetail.*)

### Group 2: Screens
```
src/screens/ExtractRewardProgram/*
src/screens/MyOrdersDetails/*
src/screens/MyOrdersRewardProgram/*
src/screens/Points/* (modified)
src/screens/PointsDetail/* (modified)
```

### Group 3: Integration
```
src/routes/index.tsx
src/routes/Models/index.ts
src/store/slices.ts (card-place) → integration with SuperApp
```

---

## 5. Known Issues to Document

| ID | Location | Issue | Severity |
|----|----------|-------|----------|
| 1 | rewardprogram: MyOrdersDetails/view.tsx:195 | `handleOpenInfo` not connected | Medium |
| 2 | card-place: ExtractRewardProgram/index.ts | `hasError: false` hardcoded | High |
| 3 | Naming | MyOrdersCashback vs MyOrdersRewardProgram | Low |
| 4 | Types | valuePoints: number vs number\|string | Low |

---

## 6. Deliverable

Create detailed comparison report in `.claude/results/YYYYMMDDHHMMSS.txt` with:
1. File-by-file diff analysis
2. Logic differences documented
3. Recommended fixes (if any)
4. Verification commands (`npm run lint`, type checking)

---

## 7. Questions for User

Before proceeding with detailed analysis:

1. **Screen naming**: Should we align on `MyOrdersRewardProgram` (card-place) or `MyOrdersCashback` (rewardprogram)?

2. **Logic differences**: When card-place and rewardprogram differ in logic (e.g., error handling, Math.abs on amounts), which should be considered the source of truth?
   - Option A: card-place is source of truth (rewardprogram has improvements to backport later)
   - Option B: rewardprogram has the correct logic (card-place has regressions to fix)

3. **Scope**: Should I analyze only the new/modified files, or also verify that unchanged files haven't drifted?

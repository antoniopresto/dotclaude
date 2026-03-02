# Plan: Fix Migration Issues in Order Details Feature

## Summary

Based on comprehensive analysis of the original code in `rnm-app-fintech-card-place` (branch `feature/SPMAIS-32275_`) and the migrated code in commit `74de00f2`, I've identified **12 issues** that need correction. The Claude Code migration introduced several logic changes, type widening, and missing elements that deviate from the original tested implementation.

---

## Critical Fixes (Logic Changes - MUST REVERT)

### 1. Remove `Math.abs()` from Amount Display
**File:** `src/screens/MyOrdersRewardProgram/view.tsx:97`

```diff
- titleDescription={String(Math.abs(item.amount))}
+ titleDescription={String(item.amount)}
```
**Reason:** This changes user-visible data. Negative amounts (like rescues) should display with their sign.

---

### 2. Revert Box Props in ListEmptyComponent
**File:** `src/screens/MyOrdersRewardProgram/view.tsx:119`

```diff
- <Box align="center" pd="innerLarger" justify="center" mt="larger">
+ <Box height="100%" align="center" justify="center" mt="larger">
```
**Reason:** Original uses `height="100%"` for proper centering. Migrated version uses padding instead.

---

### 3. Remove `useMemo` Wrapper from `enrichedTransaction`
**File:** `src/screens/MyOrdersDetails/index.tsx:138-156`

```diff
- const enrichedTransaction = useMemo(() => {
-   if (!transaction) return undefined;
-   return {
-     ...transaction,
-     type: isValidTransactionType(passedType) ? passedType : transaction.type,
-     icon: passedIcon || transaction.icon,
-     status: passedStatus || transaction.status,
-     details: {
-       ...transaction.details,
-       provider: passedOrigination || transaction.details?.provider || '',
-     },
-   };
- }, [
-   transaction,
-   passedType,
-   passedIcon,
-   passedStatus,
-   passedOrigination,
- ]);
+ const enrichedTransaction = transaction ? {
+   ...transaction,
+   type: isValidTransactionType(passedType) ? passedType : transaction.type,
+   icon: passedIcon || transaction.icon,
+   status: passedStatus || transaction.status,
+   details: {
+     ...transaction.details,
+     provider: passedOrigination || transaction.details?.provider || '',
+   },
+ } : undefined;
```
**Reason:** Original doesn't use memoization. Adding it changes reference behavior.

---

### 4. Add Missing `handleOpenInfo` to Props Destructuring
**File:** `src/screens/MyOrdersDetails/view.tsx:29`

```diff
  handleOpenReportProblem,
  handleCloseReportProblem,
+ handleOpenInfo,
  handleCloseInfo,
```
**Reason:** Prop exists in interface but was removed from destructuring.

---

## High Priority Fixes (Type Changes)

### 5. Revert Type Widening in MarketplaceItemData
**File:** `src/screens/MyOrdersDetails/Models/index.ts:24`

```diff
export interface MarketplaceItemData {
  name: string;
  quantity: number;
- valuePoints: number | string;
+ valuePoints: number;
  imageUrl?: string;
  cleanedImageUrl?: string;
}
```

---

### 6. Revert Type Widening in MarketplaceContentData
**File:** `src/screens/MyOrdersDetails/Models/index.ts:34-35`

```diff
export interface MarketplaceContentData {
  orderNumber: string;
  status?: string;
  statusColor?: string;
  paymentType?: string;
- shippingValuePoints?: number | string;
- valuePoints?: number | string;
+ shippingValuePoints?: number;
+ valuePoints?: number;
  vendorName?: string;
  items: MarketplaceItemData[];
}
```

---

### 7. Revert Type Widening in Filter Options
**File:** `src/screens/MyOrdersRewardProgram/models/index.ts:24`

```diff
filterGroups: {
  label: string;
  options: {
    label: string;
-   value: number | string;
+   value: number;
  }[];
}[];
```

---

### 8. Add Back Missing `MyOrdersItem` Interface
**File:** `src/screens/MyOrdersRewardProgram/models/index.ts`

Add after STATUS_COLORS:
```typescript
export interface MyOrdersItem {
  id: string;
  date: string;
  description: string;
  type: string;
  amount: string;
  icon: string;
  status: string;
  origination: string;
}
```

---

## Medium Priority (Review - Keep as is)

### 9. tintColor Change - KEEP
**File:** `src/screens/MyOrdersRewardProgram/view.tsx:48`
- Original: `tintColor={"BRAND_BASE_01"}` (string literal - wrong)
- Migrated: `tintColor={theme.colors.BRAND_BASE_01}` (actual color - correct)
- **Status:** This is actually a BUG FIX. Keep the migrated version.

### 10. Theme Import Path - KEEP
**File:** `src/screens/MyOrdersDetails/view.tsx:13`
- Migrated uses `@semparar/design-system-app/src/styles/theme`
- **Status:** Appropriate for new repository structure. Keep.

### 11. Component Signature Change - KEEP
**File:** `src/screens/MyOrdersDetails/index.tsx:30-31`
- Migrated uses `useNavigation()` hook instead of destructured props
- **Status:** Both valid approaches. Hook approach is more modern. Keep.

### 12. Parameter Naming in utils.ts - KEEP
**File:** `src/screens/MyOrdersDetails/utils.ts:53-54`
- Migrated renames `gainType` to `_gainType` and `moment` to `momentInstance`
- **Status:** Better typing. Keep.

---

## Files to Modify

| File | Changes |
|------|---------|
| `src/screens/MyOrdersRewardProgram/view.tsx` | Remove Math.abs(), revert Box props |
| `src/screens/MyOrdersDetails/index.tsx` | Remove useMemo wrapper |
| `src/screens/MyOrdersDetails/view.tsx` | Add handleOpenInfo to destructuring |
| `src/screens/MyOrdersDetails/Models/index.ts` | Revert type widening (3 fields) |
| `src/screens/MyOrdersRewardProgram/models/index.ts` | Revert type widening, add MyOrdersItem interface |

---

## Verification Steps

After making changes:
1. Run `npm run lint` to check for any lint errors
2. Verify TypeScript compilation with `npm run typecheck` (if available)
3. Test the app manually:
   - Verify amounts display correctly (with sign for negatives)
   - Verify empty state layout centers properly
   - Verify order details load and display correctly
   - Verify navigation works correctly

---

## Execution Order

1. Fix `src/screens/MyOrdersRewardProgram/view.tsx` (Math.abs and Box props)
2. Fix `src/screens/MyOrdersDetails/index.tsx` (remove useMemo)
3. Fix `src/screens/MyOrdersDetails/view.tsx` (add handleOpenInfo)
4. Fix `src/screens/MyOrdersDetails/Models/index.ts` (revert types)
5. Fix `src/screens/MyOrdersRewardProgram/models/index.ts` (revert types, add interface)
6. Run `npm run lint` and fix any errors
7. Commit the changes
8. Launch 10 subagents for peer review

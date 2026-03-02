# Migration Analysis: Order Details Feature

This is a research task to document migration discrepancies. After approval, the report will be saved to `./hgxh771623.md`.

## Summary of Findings

I identified **12 significant issues** in the migration from `rnm-app-fintech-card-place` (branch `feature/SPMAIS-32275_`) to `rnm-app-fintech-rewardprogram` (commit `74de00f2`).

---

## Critical Issues (Behavioral Changes)

### 1. `enrichedTransaction` wrapped in `useMemo` - LOGIC CHANGE
**File:** `src/screens/MyOrdersDetails/index.tsx`

**Original (cardplace):**
```typescript
const enrichedTransaction = transaction ? {
  ...transaction,
  type: isValidTransactionType(passedType) ? passedType : transaction.type,
  // ...
} : undefined;
```

**Migrated:**
```typescript
const enrichedTransaction = useMemo(() => {
  if (!transaction) return undefined;
  return {
    ...transaction,
    // ...
  };
}, [transaction, passedType, passedIcon, passedStatus, passedOrigination]);
```

**Impact:** The original recalculates on every render. The migrated version only recalculates when dependencies change. This could cause stale data in edge cases where the object reference changes but the values don't.

---

### 2. Component signature changed - STRUCTURAL CHANGE
**File:** `src/screens/MyOrdersDetails/index.tsx`

**Original:**
```typescript
const MyOrdersDetails: FC<ScreenProps<'MyOrdersDetails'>> = ({
  navigation,
  route,
}) => {
```

**Migrated:**
```typescript
const MyOrdersDetails = ({ route }: ScreenProps<'MyOrdersDetails'>) => {
  const navigation = useNavigation();
```

**Impact:** Changed from receiving `navigation` from props to using `useNavigation()` hook. This is a structural change that alters how navigation is obtained.

---

### 3. Missing `handleOpenInfo` prop in view destructuring
**File:** `src/screens/MyOrdersDetails/view.tsx`

**Original:**
```typescript
const MyOrdersDetailView: FC<MyOrdersDetailProps> = ({
  // ...
  handleOpenInfo,
  handleCloseInfo,
  // ...
}) => {
```

**Migrated:**
```typescript
const MyOrdersDetailView: FC<MyOrdersDetailProps> = ({
  // ...
  handleCloseInfo,  // handleOpenInfo is MISSING!
  // ...
}) => {
```

**Impact:** The `handleOpenInfo` prop is defined in the interface but not destructured. The function exists but is never used in the view (neither in original nor migrated), but the prop was incorrectly removed from destructuring.

---

### 4. `tintColor` changed from string to theme reference
**File:** `src/screens/MyOrdersRewardProgram/view.tsx`

**Original:**
```typescript
tintColor={"BRAND_BASE_01"}
```

**Migrated:**
```typescript
tintColor={theme.colors.BRAND_BASE_01}
```

**Impact:** The original passed a string token; the migrated passes the actual color value. RefreshControl might handle these differently. If the design system expects the token string, this would break styling.

---

### 5. `Math.abs()` added to amount display
**File:** `src/screens/MyOrdersRewardProgram/view.tsx`

**Original:**
```typescript
titleDescription={String(item.amount)}
```

**Migrated:**
```typescript
titleDescription={String(Math.abs(item.amount))}
```

**Impact:** Negative amounts will now display as positive. This changes the visible data to users.

---

### 6. `as never` type assertions added to `eventServerResponse`
**File:** `src/services/services/orderDetail.service.ts`

**Original:**
```typescript
eventServerResponse('ORDER_DETAIL_SUCCESS');
eventServerResponse('ORDER_DETAIL_ERROR');
```

**Migrated:**
```typescript
eventServerResponse('ORDER_DETAIL_SUCCESS' as never);
eventServerResponse('ORDER_DETAIL_ERROR' as never);
```

**Impact:** Type safety hack that bypasses TypeScript. While it compiles, it indicates the event types might not be properly defined in the events system.

---

## Medium Issues (Type Changes)

### 7. Type widening in `MarketplaceItemData` and `MarketplaceContentData`
**File:** `src/screens/MyOrdersDetails/Models/index.ts`

**Original:**
```typescript
export interface MarketplaceItemData {
  valuePoints: number;  // strictly number
}
export interface MarketplaceContentData {
  shippingValuePoints?: number;  // strictly number
  valuePoints?: number;  // strictly number
}
```

**Migrated:**
```typescript
export interface MarketplaceItemData {
  valuePoints: number | string;  // WIDENED
}
export interface MarketplaceContentData {
  shippingValuePoints?: number | string;  // WIDENED
  valuePoints?: number | string;  // WIDENED
}
```

**Impact:** Type widening allows strings where only numbers were expected. This could cause runtime issues if math operations are performed on these values.

---

### 8. Type casting changed from `as any` to `as never`
**File:** `src/screens/MyOrdersDetails/view.tsx`

**Original:**
```typescript
type={(marketplaceContent.statusColor as any) || 'neutral'}
iconRight={null as any}
icon={transaction.icon as any}
```

**Migrated:**
```typescript
type={(marketplaceContent.statusColor as never) || 'neutral'}
iconRight={null as never}
icon={transaction.icon as never}
```

**Impact:** Cosmetic but `as never` is semantically incorrect here. `never` means a value that can never exist, not "bypass type checking".

---

## Minor Issues (Cosmetic/Style)

### 9. Theme import changed
**File:** `src/screens/MyOrdersDetails/view.tsx`

**Original:**
```typescript
import theme from '../../styles/theme';
```

**Migrated:**
```typescript
import theme from '@semparar/design-system-app/src/styles/theme';
```

**Impact:** Different theme source. Should be verified that both themes are equivalent.

---

### 10. Parameter renamed in `getFormattedHighlightText`
**File:** `src/screens/MyOrdersDetails/utils.ts`

**Original:**
```typescript
export const getFormattedHighlightText = (date: string, gainType: TransactionGainType, moment: any): string => {
```

**Migrated:**
```typescript
export const getFormattedHighlightText = (
  date: string,
  _gainType: TransactionGainType,  // RENAMED with underscore
  momentInstance: typeof moment,  // RENAMED
): string => {
```

**Impact:** The `gainType` was renamed to `_gainType` (indicating unused), and `moment` to `momentInstance`. The underscore prefix is unnecessary since it was already unused in original.

---

### 11. Added `@ts-ignore` comment
**File:** `src/screens/MyOrdersRewardProgram/view.tsx`

**Migrated added:**
```typescript
/* @ts-ignore `source` is not in the props Of `image` ( ͡° ͜ʖ ͡°) */
source={{ uri: emptyImage }}
```

**Impact:** Type error suppression that wasn't in original. Indicates potential type mismatch.

---

### 12. Box styling changed in `ListEmptyComponent`
**File:** `src/screens/MyOrdersRewardProgram/view.tsx`

**Original:**
```typescript
<Box height="100%" align="center" justify="center" mt="larger">
```

**Migrated:**
```typescript
<Box align="center" pd="innerLarger" justify="center" mt="larger">
```

**Impact:** Removed `height="100%"` and added `pd="innerLarger"`. This changes the layout of the empty state component.

---

## Files Verified as Correctly Migrated

- `src/services/api/orderDetail.api.ts` - Identical
- `src/services/repository/orderDetail.repository.ts` - Identical (formatting only)
- `src/services/store/orderDetail.store.ts` - Identical (formatting only)
- `src/services/models/orderDetail.model.ts` - Minor addition of re-export (acceptable)
- `src/services/utils/cleanup.ts` - Correctly updated with `orderDetailActions.reset()`
- `src/services/constants.ts` - Correctly added ORDER_DETAIL events
- Route registrations - Correctly added

---

## Conclusion

The migration contains several issues that should be reviewed:

1. **Critical (3):** `useMemo` wrapping change, component signature change, missing prop
2. **Behavioral (3):** tintColor change, Math.abs() addition, type assertions
3. **Type safety (2):** Type widening, incorrect `as never` usage
4. **Minor (4):** Import changes, parameter renames, ts-ignore, styling changes

Most critical are issues #1, #3, #4, and #5 which could cause visual or functional differences.

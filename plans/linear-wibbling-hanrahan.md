# Plano de Correção da Migração - Reward Program

## Problema Identificado

O código de filtros da `feature/SPMAIS-32274` **existia** no novo repo, mas foi **removido** no commit `eaf22d3b` ("feat: remove rewards code"). Quando os arquivos foram recriados, foram recriados **sem** a funcionalidade de filtros.

### Timeline do Problema
```
Antes de eaf22d3b  → MyOrdersRewardProgram TINHA filtros funcionais
eaf22d3b (30/01)   → DELETOU o arquivo (feat: remove rewards code)
034dafc1 → 79650e7c → Arquivo RECRIADO sem os filtros
af529121 (hoje)    → Migração do SPMAIS-32275_ (order details)
```

---

## Estado Atual do Novo Repo

### ✅ JÁ EXISTE (não precisa criar):
- `pointsExtractFilters` slice no store (`src/services/store/extract.store.ts:38`)
- `setTransactionsFilters` action (`:156`)
- `clearTransactionsFilters` action (`:163`)
- `appliedTransactionsFilters` state (`:57`)
- `AppliedFilters` interface (`src/services/models/extract.model.ts:98`)
- `PERIOD_DAYS_MAP` constant (`:26`)
- `getFilteredTransactions` função (`src/screens/ExtractRewardProgram/utils.ts:29`)

### ❌ FALTANDO:
- Lógica de filtros em `MyOrdersRewardProgram/index.tsx`
- Conexão da UI com os handlers
- Propriedade `order` na interface `AppliedFilters`
- Suporte a ordenação em `getFilteredTransactions`

---

## Funcionalidades a Implementar

### 1. MyOrdersRewardProgram/index.tsx
- [ ] `periodFilters` - array de opções (7, 15, 30, 60, 90 dias)
- [ ] `typeFilters` - array de ordenação (Mais recentes/antigas)
- [ ] `getFilterGroups` - computed value dos grupos de filtro
- [ ] `handleApplyFilters` - função que processa filtros selecionados
- [ ] `getActiveFiltersCount` - contador de filtros ativos
- [ ] `getInitialFilters` - restauração do estado dos filtros
- [ ] Adicionar `pointsExtractFilters` ao useRootStore
- [ ] Usar `appliedTransactionsFilters` para filtrar dados

### 2. MyOrdersRewardProgram/view.tsx
- [ ] Props: `handleApplyFilters`, `initialFilters`, `activeFiltersCount`
- [ ] Conectar `FiltersBottomSheet` aos handlers (atualmente: `onApplyFilters={() => {}}`)
- [ ] Conditional empty state (mensagem diferente quando há filtros ativos)
- [ ] `hasRightIcon` deve considerar filtros ativos

### 3. MyOrdersRewardProgram/models/index.ts
- [ ] Adicionar props na interface: `handleApplyFilters`, `initialFilters`, `activeFiltersCount`

### 4. src/services/models/extract.model.ts
- [ ] Adicionar `order?: string` na interface `AppliedFilters`

### 5. src/screens/ExtractRewardProgram/utils.ts
- [ ] Adicionar suporte a `filters.order` para ordenação (ASC/DESC)

### ~~6. BasicScreen notification badge~~ - NÃO NECESSÁRIO
- A feature existia no card-place mas **não é usada em nenhum lugar do novo repo**
- `version="2.0"` encontrado é para componentes do DS (CardVehicleTags, Accordion), não BasicScreen
- Pode ser adicionado no futuro se necessário, mas não é bloqueante

---

## Arquivos a Modificar (Novo Repo)

| # | Arquivo | Ação | Prioridade |
|---|---------|------|------------|
| 1 | `src/services/models/extract.model.ts` | Adicionar `order` na interface | CRÍTICA |
| 2 | `src/screens/ExtractRewardProgram/utils.ts` | Suporte a ordenação DESC | CRÍTICA |
| 3 | `src/screens/MyOrdersRewardProgram/models/index.ts` | Adicionar tipos de filtro | CRÍTICA |
| 4 | `src/screens/MyOrdersRewardProgram/index.tsx` | Implementar lógica de filtros | CRÍTICA |
| 5 | `src/screens/MyOrdersRewardProgram/view.tsx` | Conectar UI aos handlers | CRÍTICA |
| ~~6~~ | ~~`src/atomic/templates/BasicScreen/`~~ | ~~Notification badge~~ | NÃO NECESSÁRIO |

---

## Estratégia de Implementação

### Passo 1: Atualizar Model (AppliedFilters)
```typescript
// src/services/models/extract.model.ts
export interface AppliedFilters {
  period?: number;
  types?: string[];
  order?: 'ASC' | 'DESC';  // ADICIONAR
}
```

### Passo 2: Atualizar getFilteredTransactions
```typescript
// src/screens/ExtractRewardProgram/utils.ts
// Após filtrar, adicionar ordenação:
if (filters.order === 'DESC') {
  result.reverse();
}
return result;
```

### Passo 3: Atualizar Interface do View
```typescript
// src/screens/MyOrdersRewardProgram/models/index.ts
export interface MyOrdersItemPropsView {
  // ... props existentes ...
  handleApplyFilters: (filters: Record<number, unknown>) => void;
  initialFilters: Record<number, unknown>;
  activeFiltersCount?: number;
}
```

### Passo 4: Implementar Lógica no Index
Copiar de `git show eaf22d3b^:src/screens/MyOrdersRewardProgram/index.tsx` e adaptar imports:
- `~/newArch/store/rewardProgram/models` → `~/services`
- Adicionar `pointsExtractFilters` ao useRootStore
- Implementar `handleApplyFilters`, `getActiveFiltersCount`, `getInitialFilters`

### Passo 5: Conectar View
- Passar props para o componente View
- Conectar `FiltersBottomSheet` com `onApplyFilters={handleApplyFilters}`
- Adicionar conditional empty state

---

## Código de Referência (Source)

### handleApplyFilters (MyOrdersRewardProgram/index.tsx)
```typescript
const handleApplyFilters = useCallback(
    (filters: Record<number, unknown>) => {
        const period = filters[0] as number | undefined;
        const types = filters[1] as string | undefined;

        const hasPeriod = period !== undefined && period !== null;
        const hasOrdering = types !== undefined && types !== null;

        const parts: string[] = ['filtrar'];

        if (hasPeriod) {
            const periodDay = periodFilters[period].label.split(' ')[0];
            parts.push(`${periodDay}_dias`);
        }

        if (hasOrdering) {
            const label = typeFilters.find(
                item => item.value === types
            )?.label;
            if (label) {
                parts.push(label === 'Mais recentes' ? 'recentes' : 'antigas');
            }
        }

        eventSelectContent(parts.join('_'), 'filtro_extrato', 'meus_pedidos');

        setTransactionsFilters({
            period: hasPeriod ? PERIOD_DAYS_MAP[period as keyof typeof PERIOD_DAYS_MAP] : undefined,
            order: hasOrdering ? types : undefined,
        });
    },
    [setTransactionsFilters],
);
```

### periodFilters e typeFilters
```typescript
const periodFilters = [
    { label: '7 dias', value: 0 },
    { label: '15 dias', value: 1 },
    { label: '30 dias', value: 2 },
    { label: '60 dias', value: 3 },
    { label: '90 dias', value: 4 },
]

const typeFilters = [
    { label: 'Mais recentes', value: 'ASC' },
    { label: 'Mais antigas', value: 'DESC' },
]
```

### BasicScreen notification props
```typescript
// Models/index.tsx
version?: '1.0' | '2.0'
showNotification?: boolean
notificationNumber?: string

// view.tsx - no Header
<Header
  version='2.0'
  showNotification={showNotification}
  notificationsNumber={notificationNumber}
  hideBackground
  iconColorOnOption='BRAND_COMPLEMENT_02'
/>
```

---

## Verificação

1. [ ] `npm run lint` ou `yarn lint` passa sem erros
2. [ ] `npm run typecheck` ou `tsc --noEmit` passa sem erros
3. [ ] Abrir tela MyOrdersRewardProgram e verificar se filtros funcionam
4. [ ] Aplicar filtro de período e verificar se lista atualiza
5. [ ] Aplicar ordenação e verificar se lista reordena
6. [ ] Verificar badge de filtros ativos no header
7. [ ] Limpar filtros e verificar se volta ao estado original

---

## ANÁLISE PROFUNDA - DESCOBERTAS ADICIONAIS

### Arquitetura: Destino é MAIS completo que Origem

| Componente | Origem (card-place) | Destino (rewardprogram) |
|------------|---------------------|-------------------------|
| APIs | 4 módulos | **8 módulos** (+marketplace, products, rescue, orderDetail) |
| Store Slices | 4 slices | **8 slices** |
| Hooks | 2 hooks | **5 hooks** (+useMarketplace, useRescue, usePoints) |
| Models | ~10 tipos | **~25 tipos** |

**Conclusão**: O repo destino é a implementação completa. A origem é um subset.

---

### Telas: Diferenças Encontradas

| Tela | Diferença | Impacto |
|------|-----------|---------|
| Points | Redux → Hooks | ✅ OK - refatoração arquitetural |
| PointsDetail | Redux removido | ✅ OK - simplificação |
| ExtractRewardProgram | newArch → services | ✅ OK - reorganização |
| InvoiceCashback* | Color theme migration | ✅ OK - design system tokens |
| **InvoiceCashbackSummary** | **⚠️ CRÍTICO: Rescue envia `reaisSelected` ao invés de `pointsSelected`** | **VERIFICAR** |
| RewardProgramMarketplace | Redux → Hook | ✅ OK |
| AirlineMilesMarketplace | Import paths | ✅ OK |

### ✅ InvoiceCashbackSummary

A mudança de `pointsSelected` → `reaisSelected` no payload do rescue é **INTENCIONAL** - faz parte da evolução do novo repo.

---

### Componentes Atômicos: Gaps Encontrados

| Componente | Status no Destino | Ação |
|------------|-------------------|------|
| FiltersBottomSheet | ✅ Existe | OK |
| PointsInfoBottomSheet | ✅ Existe | OK |
| LearnMorePointsSection | ✅ Existe | OK |
| ApiError | ✅ Existe (melhorado) | OK |
| BasicScreen | ✅ Existe (notification props não são usadas no novo repo) | OK |
| TextIconRewardProgram | ❌ **NÃO EXISTE** | Avaliar necessidade |
| ButtonFinancialPoints | ❌ **NÃO EXISTE** | Avaliar necessidade |

**Nota**: TextIconRewardProgram e ButtonFinancialPoints são componentes do app principal (card-place). Podem não ser necessários no repo de rewards isolado.

---

## RESUMO: O que realmente precisa ser corrigido

### PRIORIDADE CRÍTICA
1. **Filtros em MyOrdersRewardProgram** - funcionalidade removida no commit eaf22d3b

### NÃO NECESSÁRIO
- ~~BasicScreen notification props~~ - não é usado em nenhum lugar do novo repo
- ~~TextIconRewardProgram~~ - usado apenas em InvoiceStatus (não faz parte do módulo rewards)
- ~~ButtonFinancialPoints~~ - usado apenas em InvoiceCard (não faz parte do módulo rewards)

---

## Verificação Final

1. [ ] Filtros funcionam em MyOrdersRewardProgram
2. [ ] Ordenação ASC/DESC funciona
3. [ ] `yarn lint` passa
4. [ ] `yarn typecheck` ou `tsc --noEmit` passa

---

## Riscos e Mitigações

| Risco | Mitigação |
|-------|-----------|
| Imports podem estar diferentes | Adaptar de `~/newArch/...` para `~/services/...` |
| Analytics events podem faltar | Verificar se PERIOD_DAYS_MAP e eventSelectContent existem |

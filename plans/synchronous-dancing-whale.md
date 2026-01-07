# Plano: Remover CSS Customizados e Usar Blueprint.js Nativo

## Resumo
Remover ABSOLUTAMENTE TODOS os CSS customizados (variáveis --mms-*, overrides, inline styles, classes utilitárias) e usar apenas os estilos nativos do Blueprint.js v6.

## Abordagem
1. **Remover tudo** - Eliminar todos CSS customizados
2. **Testar visualmente** - Usar Playwright MCP para verificar resultado
3. **Criar novos se necessário** - Apenas se algo quebrar, seguindo padrões Blueprint.js

## Contexto da Pesquisa

### Blueprint.js v6 - Theming Nativo
- **Dark Mode**: Classe `bp6-dark` (ou `bp5-dark` para compatibilidade)
- **Cores**: Usar `Intent` props (PRIMARY, SUCCESS, WARNING, DANGER)
- **Elevation**: Usar `Elevation` enum para sombras
- **Spacing**: Blueprint não força sistema de spacing - usar CSS padrão ou classes utilitárias
- **Typography**: Sistema nativo do Blueprint

### Versão Instalada
- `@blueprintjs/core: ^6.4.1`
- Componentes usam `bp6-*` classes
- Dark mode aceita `bp5-dark` (compatibilidade)

---

## Arquivos a Modificar

### 1. globals.css (REESCREVER DO ZERO)
**Arquivo:** `apps/web/src/app/globals.css`

**Manter APENAS:**
```css
/* Blueprint.js Core Styles */
@import "@blueprintjs/core/lib/css/blueprint.css";
@import "@blueprintjs/icons/lib/css/blueprint-icons.css";
@import "@blueprintjs/table/lib/css/table.css";
@import "@blueprintjs/select/lib/css/blueprint-select.css";
@import "@blueprintjs/datetime2/lib/css/blueprint-datetime2.css";

/* Leaflet Map Styles */
@import 'leaflet/dist/leaflet.css';
```

**Remover TUDO o resto:**
- Todas variáveis `--mms-*`
- Todos overrides `.bp5-dark`
- Todas classes `.mms-*`
- Todos estilos customizados de body, scrollbar, etc.

### 2. ThemeContext.tsx (SIMPLIFICAR)
**Arquivo:** `apps/web/src/components/layout/ThemeContext.tsx`

**Alterações:**
- Usar classe `bp5-dark` (compatibilidade com Blueprint v6)
- Remover dependência de variáveis MMS
- Manter localStorage persistence

### 3. Componentes Dashboard (REMOVER INLINE STYLES)
**Arquivos:**
- `apps/web/src/app/page.tsx`
- `apps/web/src/components/dashboard/KPICard.tsx`
- `apps/web/src/components/dashboard/DepotCapacityCards.tsx`
- `apps/web/src/components/dashboard/MaintenanceAlerts.tsx`
- `apps/web/src/components/dashboard/DashboardKPIs.tsx`

**Alterações:**
- Remover todos `style={{}}` com variáveis `--mms-*`
- Usar Blueprint props: `intent`, `elevation`, `minimal`
- Usar classes Blueprint nativas

### 4. Navigation.tsx (SIMPLIFICAR)
**Arquivo:** `apps/web/src/components/layout/Navigation.tsx`

**Alterações:**
- Remover inline styles
- Usar Navbar props nativas do Blueprint

### 5. Outras Páginas (REMOVER INLINE STYLES)
**Arquivos:**
- `apps/web/src/app/schedule/page.tsx`
- `apps/web/src/app/map/page.tsx`
- `apps/web/src/app/balancing/page.tsx`
- `apps/web/src/app/maintenance/page.tsx`
- `apps/web/src/app/fleet/page.tsx`
- `apps/web/src/app/allocation/page.tsx`

---

## Implementação Passo a Passo

### Fase 1: Reescrever globals.css
1. Substituir arquivo inteiro - manter APENAS imports Blueprint e Leaflet
2. Remover TODAS variáveis, classes e overrides customizados

### Fase 2: Limpar Componentes TSX
1. Remover TODOS inline styles que usam `var(--mms-*)`
2. Substituir por props Blueprint ou remover completamente
3. Arquivos: page.tsx, KPICard.tsx, DepotCapacityCards.tsx, MaintenanceAlerts.tsx, Navigation.tsx, todas pages

### Fase 3: Simplificar ThemeContext
1. Manter apenas toggle de classe `bp5-dark`
2. Remover qualquer referência a variáveis customizadas

### Fase 4: Testar Visualmente (Playwright MCP)
1. Navegar para cada página
2. Testar light mode
3. Testar dark mode
4. Capturar screenshots
5. Se algo quebrar visualmente: criar CSS mínimo seguindo padrões Blueprint

---

## Blueprint.js - Props a Usar

### Card
```tsx
<Card elevation={Elevation.TWO} interactive>
  conteúdo
</Card>
```

### Button/Tag
```tsx
<Button intent={Intent.PRIMARY} />
<Tag intent={Intent.SUCCESS} minimal />
```

### Cores Semânticas (Intent)
- `Intent.NONE` - cinza/neutro
- `Intent.PRIMARY` - azul
- `Intent.SUCCESS` - verde
- `Intent.WARNING` - laranja
- `Intent.DANGER` - vermelho

---

## Resultado Esperado

1. **globals.css**: ~50 linhas (apenas imports e utilitários mínimos)
2. **Componentes**: Sem inline styles, usando props Blueprint
3. **Dark Mode**: Funcional via `.bp5-dark` nativo
4. **Consistência**: Visual 100% Blueprint.js

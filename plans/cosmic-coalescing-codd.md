# MMS Fractal Canvas - Implementation Plan

## Executive Summary

Create an impressive demo for Dubai Metro / Keolis MHI RFQ showing a "Single Pane of Glass" semantic zoom interface for maintenance planning of 128 trains over 12 years.

---

## Architecture Overview

### Semantic Zoom Levels

| Level | Zoom | Time Span | Visualization | Rendering |
|-------|------|-----------|---------------|-----------|
| **Strategic** | < 0.3x | 10-12 years | Heatmap (capacity/cost) | deck.gl WebGL |
| **Tactical** | 0.3x-1.0x | 1-3 years | Stacked bars (workload) | deck.gl/Canvas |
| **Operational** | 1.0x-3.0x | 1-6 months | DNA-like Gantt | Canvas 2D |
| **Execution** | > 3.0x | 1-4 weeks | Detailed task cards | SVG/HTML |

### Technology Stack

```
Rendering:      deck.gl 9.x + Canvas 2D + SVG
State:          XState 5.x (FSM for viewport, selection)
Math:           d3-scale, d3-interpolate, d3-ease, d3-time
Spatial:        rbush (R-tree)
UI Icons:       lucide-react
Dev:            Storybook + Vite + React 18
```

### Constraints

- **NO useState/useReducer/useEffect/useCallback**
- **ONLY useRef, useSyncExternalStore, useMemo** + library hooks
- **Dark Theme** (#0f172a slate-900 background)
- **60 FPS** during all interactions
- **< 2s** initial load

---

## Phase 1: POCs (Technical Validation)

### 1.1 Rendering POCs (`stories/01-POCs/Rendering/`)

| POC | Purpose | Success Criteria |
|-----|---------|------------------|
| `DeckGLHeatmap` | Test deck.gl for strategic view | 6K cells at 60fps |
| `DeckGLHexagon` | Test 3D aggregation | Smooth viewport transitions |
| `CanvasGantt` | Test Canvas 2D for operational | 500+ bars with virtualization |
| `SVGDetails` | Test SVG for execution | Expandable cards with animations |
| `RenderingComparison` | Side-by-side benchmark | Clear winner per zoom level |

### 1.2 State POCs (`stories/01-POCs/State/`)

| POC | Purpose | Success Criteria |
|-----|---------|------------------|
| `XStateViewport` | Viewport FSM | States: idle, panning, zooming, animating |
| `XStateSelection` | Selection FSM | States: none, single, multi, dragging |

### 1.3 Interaction POCs (`stories/01-POCs/Interactions/`)

| POC | Purpose | Success Criteria |
|-----|---------|------------------|
| `GestureRecognizer` | Native Pointer Events | Pan, pinch, double-tap, momentum |
| `SemanticZoom` | LOD transitions | Crossfade 200ms, no visual jump |
| `KeyboardNavigation` | Full keyboard support | Arrows, +/-, Home, T key |

### 1.4 Component POCs (`stories/01-POCs/Components/`)

| Component | Variants | Key Features |
|-----------|----------|--------------|
| `GanttBar` | PM1/PM2/PM3/Overhaul/Corrective | 4 sizes (8/16/24/32px) |
| `KPICard` | Availability/MDBF/Compliance/Cost | Delta indicators |
| `TodayLine` | Single | Red dashed vertical line |
| `Minimap` | Single | Click navigation, viewport indicator |
| `TimelineHeader` | Adaptive | Year/Quarter/Month/Week granularity |
| `TrainSidebar` | Virtualized | 128 rows, synced scroll |

---

## Phase 2: Individual Layers (`stories/02-Layers/`)

### 2.1 Strategic Layer (10-12 Years)

```
Visualization: Heatmap grid
- Rows: 128 trains (49 Kinki + 79 Alstom)
- Columns: 48 quarters (12 years)
- Color: Blue→Amber→Red gradient (#1e3a5f → #f59e0b → #dc2626)
- Elements: Overhaul blocks (orange), mileage threshold lines
- Metrics: Fleet size, contract period, projected cost
```

### 2.2 Tactical Layer (1-3 Years)

```
Visualization: Stacked bars
- X-axis: 36 months
- Y-axis: Man-hours or Cost (toggle)
- Bars: PM1 + PM2 + PM3 + Overhaul + Corrective
- Background: Capacity utilization heatmap
- Elements: Capacity line, budget period markers
```

### 2.3 Operational Layer (1-6 Months)

```
Visualization: DNA-like Gantt
- X-axis: 24 weeks
- Y-axis: 128 trains (virtualized)
- Bars: Individual work orders (16px height)
- Elements: Today line, mileage balance, conflicts, dependencies
- Pattern: Colored bars per maintenance type
```

### 2.4 Execution Layer (1-4 Weeks)

```
Visualization: Detailed Gantt with resources
- X-axis: 28 days
- Y-axis: Dual view (trains + pits/tracks)
- Cards: 32px with WO ID, duration, technicians, parts status
- Grid: 8 maintenance pits × 3 shifts
- Elements: Shift boundaries, current time, bay assignments
```

---

## Phase 3: Integration

### 3.1 Semantic Zoom Transitions

- Crossfade between layers (200ms ease-out-expo)
- CSS transform for instant zoom feedback
- Debounced redraw after zoom settles (150ms)
- Zoom thresholds: 0.3x, 1.0x, 3.0x

### 3.2 Synchronized Components

- Sidebar scroll ↔ Canvas vertical pan
- Timeline header ↔ Canvas horizontal pan
- Minimap viewport ↔ Canvas visible area

### 3.3 Navigation

- Pan: Drag, Arrow keys, Shift+Scroll
- Zoom: Scroll, Pinch, +/- keys
- Jump: Today (T key), Home (reset)
- Double-click: 2x zoom at point

---

## Phase 4: Demo (`stories/03-Demo/`)

### FractalCanvas.stories.tsx

Final integrated experience:

```
┌──────────────────────────────────────────────────────────────────────────┐
│ NAVBAR                                                    [Zoom: 1.00x]  │
│ [☰] MMS Canvas - Dubai Metro    [<< Today >>]    [🔍]    [⚙️] [👤]       │
├──────────┬───────────────────────────────────────────────────────────────┤
│          │  TIMELINE (adaptive)                                          │
│          │  │ 2024 │ 2025 │ 2026 │ ... │                                │
│  SIDEBAR ├───────────────────────────────────────────────────────────────┤
│          │                                                               │
│  128     │              FRACTAL CANVAS                                   │
│  TRAINS  │                                                               │
│          │     [Strategic ↔ Tactical ↔ Operational ↔ Execution]         │
│  ────────│                                                               │
│  KINKI   │              Seamless semantic zoom                           │
│  (49)    │                                                               │
│  ────────│                                                   ┌─────────┐│
│  ALSTOM  │                                                   │ MINIMAP ││
│  (79)    │                                                   └─────────┘│
│          │                                             [+] [-] [🏠] [T] │
└──────────┴───────────────────────────────────────────────────────────────┘
```

---

## Mock Data Configuration

```typescript
const MOCK_CONFIG = {
  fleets: [
    { id: 'kinki', name: 'Kinki Sharyo', count: 49, prefix: 'K' },
    { id: 'alstom', name: 'Alstom', count: 79, prefix: 'A' }
  ],
  timeRange: { start: '2024-01-01', end: '2036-12-31' },
  maintenanceTypes: [
    { id: 'pm1', interval_km: 15000, duration_hours: 2, color: '#60a5fa' },
    { id: 'pm2', interval_km: 60000, duration_hours: 8, color: '#a78bfa' },
    { id: 'pm3', interval_km: 120000, duration_hours: 24, color: '#f472b6' },
    { id: 'overhaul', interval_km: 480000, duration_hours: 720, color: '#fb923c' }
  ],
  resources: { pits: 8, shifts_per_day: 3, max_manhours_per_month: 2000 },
  dailyMileage: { average: 450, variance: 0.15 }
};
```

---

## Implementation Order

### Week 1: Foundation
1. Setup Storybook structure (`01-POCs/`, `02-Layers/`, `03-Demo/`)
2. Install dependencies (deck.gl, XState, d3-*, rbush)
3. Create mock data generator
4. POC: deck.gl heatmap
5. POC: XState viewport machine

### Week 2: Rendering POCs
1. POC: Canvas Gantt with virtualization
2. POC: SVG details with animations
3. POC: Gesture recognizer
4. POC: Semantic zoom transitions
5. Rendering comparison benchmark

### Week 3: Components & Layers
1. Build UI components (GanttBar, KPICard, TodayLine)
2. Strategic layer (deck.gl heatmap)
3. Tactical layer (deck.gl + Canvas)
4. Operational layer (Canvas 2D)
5. Execution layer (SVG/HTML)

### Week 4: Integration & Polish
1. Semantic zoom integration
2. Sidebar + Timeline sync
3. Minimap navigation
4. KPIs panel
5. Final demo story
6. Performance optimization
7. Dark theme refinement

---

## Quality Checklist

### UX
- [ ] Zoom semântico imperceptível (no visual jumps)
- [ ] 60 FPS constante em todas interações
- [ ] Feedback visual < 16ms
- [ ] Navegação intuitiva (Google Maps-like)
- [ ] Dark theme consistente

### Visual
- [ ] Paleta de cores consistente
- [ ] Tipografia legível em todos zoom levels
- [ ] Contraste adequado (WCAG AA)
- [ ] Animações suaves (ease-out-expo)
- [ ] Sem elementos visuais quebrados

### Técnico
- [ ] Sem memory leaks
- [ ] State 100% fora do React (XState + external stores)
- [ ] Dados mock realistas (~60K tarefas)
- [ ] Testes de performance documentados
- [ ] Zero useState/useReducer/useEffect

### Demo-Ready
- [ ] Funciona sem backend
- [ ] 128 trens, 12 anos de dados
- [ ] Todas interações funcionais
- [ ] Minimap funcional
- [ ] KPIs visíveis

---

## Decisions Made (2025-12-18)

| Question | Decision | Rationale |
|----------|----------|-----------|
| **Prazo** | Qualidade máxima | Usar todo tempo necessário, revisar, revalidar, usar Harness |
| **State Management** | Migrar para XState | Seguir style guide, FSM puro para viewport/selection |
| **UI Library** | BlueprintJS 6 | Manter BP, ignorar dark mode (usar light theme) |
| **Estrutura** | Expandir stories | Adicionar pastas em `apps/canvas/src/stories/` |
| **Dark Mode** | IGNORAR | Não implementar dark mode, focar na funcionalidade |

---

## References

- `docs/MMS_PRESENTAION.md` - Detailed requirements
- `docs/MMS_STYLE_GUIDE.md` - Complete design system
- `docs/UX_SPECIFICATION.md` - UX patterns (existing)
- Moodboard sources: voestalpine, ZEDAS, Siemens, Prometheus, Linear, Grafana

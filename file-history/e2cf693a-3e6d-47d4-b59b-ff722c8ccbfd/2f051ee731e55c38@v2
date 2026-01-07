# MMS-MFC Complete Implementation Plan

## Executive Summary

Projeto MMS (Railway Fleet Management) - Plano completo para implementação de qualidade profissional.

**Escopo Definido pelo Usuário:**
- **Full Canvas Architecture** com semantic zoom e LOD (libs a serem decididas)
- **Solver REAL** com OR-Tools CP-SAT (zero mocks exceto dados seed)
- **Melhor resultado possível** sem restrição de timeline

**Prioridades:**
1. **Tela de Simulações** (Issues #6 e #7) - Diferencial competitivo
2. **Full Canvas Architecture** - Semantic zoom com 4 LOD levels
3. **OR-Tools Solver Real** - CP-SAT com constraints reais
4. **Design System Enterprise Dark Mode** - Profissionalização visual
5. **Dívida Técnica** - Issues #3, #4, #5, #8

---

## Reference Documents (AI-Generated - Verify Before Use)

| Document | Location | Lines | Use Case |
|----------|----------|-------|----------|
| MMS Style Guide | `/Users/anotonio.silva/antonio/mms/MMS_STYLE_GUIDE.md` | 788 | Design system, colors, typography |
| Demo Playbook | `docs/MMS_DEMO_PLAYBOOK.md` | 1495 | Domain knowledge, fleet specs |
| UX Specification | `/Users/anotonio.silva/antonio/mms/system/docs/UX_SPECIFICATION.md` | 444 | Semantic zoom architecture |
| Research | `/Users/anotonio.silva/antonio/mms/system/docs/RESEARCH.md` | 1030 | Solver techniques, industry practices |
| Domain | `/Users/anotonio.silva/antonio/mms/system/docs/DOMAIN.md` | 476 | Fleet composition, maintenance types |

**WARNING:** All docs are AI-generated. Verify each detail before implementing.

---

## Phase 1: Simulation Feature (Issues #6 + #7) - Priority P0

### Current State

**File:** `apps/web/src/components/balancing/SimulationPanel.tsx` (271 lines)

- Lines 90-94: Hardcoded demo changes
- Line 36: Single scenario selection only
- No multi-select or comparison view

### Implementation Steps

#### 1.1 Allocation Editor Panel
**Files:** `SimulationPanel.tsx`

- Fetch services from `/api/services/pending`
- Display current train per service
- Dropdown to reassign trains
- Track changes in state array

```typescript
interface AllocationChange {
  serviceId: string;
  serviceName: string;
  originalTrainId: string | null;
  newTrainId: string;
}
```

**Effort:** 3-4 hours

#### 1.2 Replace Hardcoded Changes
**Files:** `SimulationPanel.tsx` lines 88-95

Replace demo data with `scenarioChanges` state.

**Effort:** 30 minutes

#### 1.3 Multi-Select Scenarios
**Files:** `SimulationPanel.tsx`

- Checkbox per scenario (max 3)
- "Compare Selected" button when 2+ selected

**Effort:** 1-2 hours

#### 1.4 Comparison View Component
**Create:** `apps/web/src/components/balancing/ScenarioComparison.tsx`

Side-by-side table with best values highlighted green.

**Effort:** 2-3 hours

#### 1.5 Apply to Live
**Files:** API + Frontend

- `POST /api/simulation/:id/apply` endpoint
- Confirmation dialog
- Update allocations table

**Effort:** 2 hours

---

## Phase 2: Semantic Zoom Canvas Architecture

### Technology Decision: Pixi.js

Based on agent analysis, **Pixi.js** is recommended over deck.gl:

| Criteria | Pixi.js | deck.gl |
|----------|---------|---------|
| Bundle Size | ~150KB | ~500KB+ |
| 2D Timeline | Optimized | Over-engineered (geo-focused) |
| Zoom/Pan | pixi-viewport built-in | Requires custom |
| React Integration | @pixi/react v8 | Works but complex |
| Learning Curve | Medium | High |

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    UNIFIED CANVAS CONTAINER                      │
│                (ScheduleCanvas.tsx - 'use client')               │
├─────────────────────────────────────────────────────────────────┤
│  PIXI.JS APPLICATION (WebGL Layer)                              │
│  └── VIEWPORT (pixi-viewport) - handles zoom, pan, gestures     │
│      ├── LOD 0: HeatmapLayer (Strategic: 10-12 years)           │
│      ├── LOD 1: CampaignLayer (Tactical: 1-3 years)             │
│      ├── LOD 2: WorkOrderLayer (Operational: 1-6 months)        │
│      └── LOD 3: TaskDetailLayer (Execution: 1-4 weeks)          │
├─────────────────────────────────────────────────────────────────┤
│  CANVAS TEXT LAYER (OffscreenCanvas for crisp labels)           │
├─────────────────────────────────────────────────────────────────┤
│  REACT DOM OVERLAY (Tooltips, Modals, Context menus)            │
├─────────────────────────────────────────────────────────────────┤
│  FIXED CONTROLS (ZoomSlider, TimeRange, LOD indicator)          │
└─────────────────────────────────────────────────────────────────┘
```

### LOD Visibility by Zoom Scale

| Scale | LOD | Time Span | Content |
|-------|-----|-----------|---------|
| 0.05-0.2 | 0 (Strategic) | 10-12 years | Heatmap aggregation |
| 0.2-0.5 | 1 (Tactical) | 1-3 years | Campaign bars |
| 0.5-1.0 | 2 (Operational) | 1-6 months | Work orders |
| 1.0-4.0 | 3 (Execution) | 1-4 weeks | Task details |

### State Management: @zazcart/toolkit

```typescript
interface ViewportState {
  scale: number;
  translateX: number;
  translateY: number;
  currentLOD: 0 | 1 | 2 | 3;
  visibleStartDate: Date;
  visibleEndDate: Date;
  isZooming: boolean;
  isPanning: boolean;
  selectedItems: Set<string>;
}
```

### Implementation Steps

#### 2.1 Foundation (3-4 days)
- Install pixi.js, @pixi/react, pixi-viewport
- Create ScheduleCanvas wrapper component
- Implement viewportStore with @zazcart/toolkit
- Wire viewport events

**Files to create:**
- `apps/web/src/components/schedule/ScheduleCanvas.tsx`
- `apps/web/src/components/schedule/ViewportControls.tsx`
- `apps/web/src/stores/viewportStore.ts`

#### 2.2 LOD 2-3 (Operational + Execution) (4-5 days)
- WorkOrderLayer (week blocks)
- TaskDetailLayer (day tasks)
- TimelineRuler (dynamic scale)
- Drag-drop interactions

#### 2.3 LOD 0-1 (Strategic + Tactical) (3-4 days)
- HeatmapLayer (yearly aggregation)
- CampaignLayer (quarterly bars)
- Aggregation API endpoints

#### 2.4 Polish (2-3 days)
- LOD transition animations (crossfade)
- Performance optimization (culling, batching)
- Minimap navigation

**Total Estimated Effort: 14-18 days**

---

## Phase 3: OR-Tools CP-SAT Solver

### Architecture

```
solver/
├── src/
│   ├── main.py                    # FastAPI entry
│   ├── models/                    # Pydantic models
│   ├── engine/
│   │   ├── allocator.py           # CP-SAT recommendation
│   │   ├── simulator.py           # What-if projection
│   │   ├── scorer.py              # 0-100 normalization
│   │   └── justifier.py           # Text generation
│   ├── data/
│   │   └── db_client.py           # PostgreSQL async
│   └── utils/
│       └── geo.py                 # Haversine distance
```

### CP-SAT Model

**Decision Variables:**
```python
x[t] = BoolVar  # 1 if train t selected
```

**Hard Constraints:**
1. Train fitness_status = 'fit'
2. No overlapping allocations
3. Train aptitude matches route

**Soft Constraints (Objective):**
```python
model.Minimize(
    1000 * km_penalty +        # Km balancing (HIGH)
    100 * dead_running +       # Dead running (MEDIUM)
    10 * depot_proximity       # Maintenance proximity (LOW)
)
```

**Output per recommendation:**
- train_id, score (0-100)
- 3+ justification strings
- dead_running_km
- solver_time_ms

### Justification Examples
- "Km 12% below fleet average (balancing priority)"
- "Minimal dead running (8.5km to origin)"
- "Service ends at maintenance depot (Porto)"
- "Train is fit for service"

### Implementation Steps

#### 3.1 Models Package (2 hours)
Create Pydantic models for Train, Service, Recommendation

#### 3.2 Database Client (3 hours)
asyncpg client for PostgreSQL queries

#### 3.3 CP-SAT Allocator (6 hours)
Core optimization model with constraints

#### 3.4 Justification Generator (2 hours)
Text generation from constraint satisfaction

#### 3.5 Simulation Engine (4 hours)
30-day projection with variance calculation

#### 3.6 API Integration (3 hours)
Update /recommend and /simulate endpoints

**Total Estimated Effort: 27.5 hours (3-4 days)**

---

## Phase 4: Design System (Enterprise Dark Mode)

### Color Palette (from MMS_STYLE_GUIDE.md)

```javascript
// tailwind.config.js
colors: {
  canvas: '#0A0A0A',
  panel: '#141414',
  elevated: '#1C1C1C',
  hover: '#262626',
  border: '#2A2A2A',
  'text-primary': '#FAFAFA',
  'text-secondary': '#A1A1A1',
  'text-muted': '#6B6B6B',
  'maint-pm1': '#10B981',      // Green
  'maint-pm2': '#3B82F6',      // Blue
  'maint-pm3': '#F59E0B',      // Amber
  'maint-overhaul': '#EF4444', // Red
}
```

### Typography

```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap');

:root {
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
}
```

### Components to Update

| Component | File | Changes |
|-----------|------|---------|
| Navigation | `layout/Navigation.tsx` | Dark header, active states |
| KPICard | `dashboard/KPICard.tsx` | bg-panel, text-text-primary |
| DepotCapacity | `dashboard/DepotCapacityCards.tsx` | Dark cards |
| MaintenanceAlerts | `dashboard/MaintenanceAlerts.tsx` | Dark list |
| FleetMap | `map/FleetMap.tsx` | Carto Dark tiles |
| AllocationPanel | `allocation/AllocationPanel.tsx` | Full dark theme |
| BalancingDashboard | `balancing/*.tsx` | Dark charts |
| MaintenanceGantt | `maintenance/*.tsx` | Dark timeline |

**Estimated Effort: 8-12 hours**

---

## Phase 5: Technical Debt

### Issue #4: Map Status Logic
**File:** `apps/web/src/components/map/FleetMap.tsx`

Add allocation check for in-service status (blue markers).

**Effort:** 2-3 hours

### Issue #5: Allocation Panel Filters
**File:** `apps/web/src/components/allocation/AllocationPanel.tsx`

Add fleet, depot, km range, status filters with chips.

**Effort:** 3-4 hours

### Issue #8: Gantt Validation
**File:** `apps/web/src/components/maintenance/MaintenanceGantt.tsx`

Add depot capacity, window tolerance, overlap detection.

**Effort:** 4-5 hours

---

## Execution Summary

| Phase | Focus | Effort | Priority |
|-------|-------|--------|----------|
| 1 | Simulation (Issues #6, #7) | 8-10 hours | P0 |
| 2 | Semantic Zoom Canvas | 14-18 days | P0 |
| 3 | OR-Tools Solver | 3-4 days | P0 |
| 4 | Design System | 8-12 hours | P1 |
| 5 | Technical Debt (#4, #5, #8) | 9-12 hours | P2 |

**Total: ~25-30 days full implementation**

---

## Critical Files Summary

### Phase 1 (Simulation)
- `apps/web/src/components/balancing/SimulationPanel.tsx`
- `apps/web/src/components/balancing/ScenarioComparison.tsx` (new)
- `apps/api/src/routes/simulation.ts`

### Phase 2 (Canvas)
- `apps/web/src/components/schedule/ScheduleCanvas.tsx` (new)
- `apps/web/src/components/schedule/layers/*.tsx` (new)
- `apps/web/src/stores/viewportStore.ts` (new)

### Phase 3 (Solver)
- `solver/src/main.py`
- `solver/src/engine/allocator.py` (new)
- `solver/src/engine/justifier.py` (new)
- `solver/src/data/db_client.py` (new)

### Phase 4 (Design)
- `apps/web/tailwind.config.js`
- `apps/web/src/app/globals.css`
- All component files (bg-white → bg-panel)

---

## Notes

1. **Verify AI-generated docs** before implementing any detail
2. **Visual testing mandatory** with Playwright MCP after each feature
3. **Atomic commits** per logical change
4. **Update claude-progress.txt** after each phase
5. **Reference ~/antonio/mms/system** for patterns (but verify)

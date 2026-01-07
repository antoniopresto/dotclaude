# DECK-MIGRATE-001: Migration Plan - R3F to deck.gl

## Executive Summary

Migrate the MMS Canvas app from React Three Fiber (R3F) to **deck.gl** for improved performance, simpler architecture, and native semantic zoom support. The current R3F stack carries unnecessary 3D overhead for what is fundamentally a 2D timeline visualization.

### Key Benefits of deck.gl Migration

| Aspect | Current (R3F) | After (deck.gl) |
|--------|---------------|-----------------|
| Bundle size | ~600KB+ | ~400KB |
| LOD handling | Manual (2100+ lines in InfiniteCanvas) | Native via CompositeLayer |
| Pan/zoom | Custom implementation | Built-in OrthographicView controller |
| Heatmap | Custom InstancedMesh + d3 | Native HeatmapLayer/GridLayer |
| Spatial culling | SimpleSpatialIndex (O(n)) | Built-in layer filtering |
| Input handling | Manual trackpad/mouse detection | @use-gesture (recommended pairing) |

---

## Phase Overview

```
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 0: Preparation & Archive                                   │
│ - Archive current R3F architecture docs                          │
│ - Compress claude-progress.txt historical notes                  │
│ - Update features.json with migration tasks                      │
├─────────────────────────────────────────────────────────────────┤
│ PHASE 1: deck.gl Foundation                                      │
│ - Install deck.gl + @use-gesture/react                          │
│ - Create DeckCanvas.tsx with OrthographicView                    │
│ - Integrate with @mms/toolkit state                              │
├─────────────────────────────────────────────────────────────────┤
│ PHASE 2: Layer Migration                                         │
│ - Migrate MacroLayer → GridLayer/HeatmapLayer                   │
│ - Migrate MesoLayer → ScatterplotLayer/PolygonLayer             │
│ - Migrate MicroLayer → TextLayer + HTMLOverlay                  │
├─────────────────────────────────────────────────────────────────┤
│ PHASE 3: LOD System                                              │
│ - Create MaintenanceLayer (CompositeLayer)                       │
│ - Implement filterSubLayer() for zoom thresholds                │
│ - Add crossfade transitions during LOD switch                    │
├─────────────────────────────────────────────────────────────────┤
│ PHASE 4: Interaction & State                                     │
│ - Migrate viewport state to deck.gl ViewState                    │
│ - Keep interaction state in @mms/toolkit                         │
│ - Implement hover/selection via layer callbacks                  │
├─────────────────────────────────────────────────────────────────┤
│ PHASE 5: Feature Parity                                          │
│ - F023 Dependency lines → PathLayer                             │
│ - F021/F022 Keyboard nav & ARIA → Custom handlers               │
│ - F018/F019 Hover/selection → Layer picking                     │
├─────────────────────────────────────────────────────────────────┤
│ PHASE 6: Cleanup & Optimization                                  │
│ - Remove R3F/Three.js dependencies                               │
│ - Remove unused spatial indexing code                            │
│ - Performance benchmarking                                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 0: Preparation & Archive

### Tasks

1. **Compress Historical Architecture Notes**
   - Move R3F-specific notes from `claude-progress.txt` to `docs/archive/r3f-architecture.md`
   - Keep only migration-relevant context in progress file

2. **Update features.json**
   - Mark existing R3F features as `deprecated: true`
   - Add DECK-MIGRATE-001 through DECK-MIGRATE-006 tasks
   - Add dependency chain between tasks

3. **Create Migration Documentation**
   - Document current layer mapping for reference
   - Create `docs/deck-migration/` folder

### Files to Modify
- `claude-progress.txt` - compress, add migration section
- `features.json` - add migration tasks
- Create: `docs/archive/r3f-architecture.md`
- Create: `docs/deck-migration/layer-mapping.md`

---

## Phase 1: deck.gl Foundation (DECK-MIGRATE-001)

### Dependencies to Install

```bash
# Core deck.gl
bun add deck.gl @deck.gl/core @deck.gl/layers @deck.gl/aggregation-layers @deck.gl/react

# Input handling (recommended by research)
bun add @use-gesture/react
```

### New Files to Create

```
apps/canvas/src/
├── deck/
│   ├── DeckCanvas.tsx         # Main deck.gl component
│   ├── controllers/
│   │   └── TimelineController.ts  # Custom pan/zoom behavior
│   └── utils/
│       └── viewport.ts         # Coordinate conversions
```

### DeckCanvas.tsx Structure

```typescript
import { DeckGL } from '@deck.gl/react';
import { OrthographicView } from '@deck.gl/core';

// Key: Use OrthographicView, NOT MapView (timeline is not geo)
const INITIAL_VIEW_STATE = {
  target: [0, 0, 0],
  zoom: 0,
  minZoom: -5,
  maxZoom: 10,
};

export function DeckCanvas({ tasks, trains, onViewStateChange }) {
  const [viewState, setViewState] = useState(INITIAL_VIEW_STATE);

  return (
    <DeckGL
      views={new OrthographicView({ id: 'timeline' })}
      viewState={viewState}
      onViewStateChange={({ viewState }) => setViewState(viewState)}
      controller={{
        scrollZoom: true,
        dragPan: true,
        doubleClickZoom: true,
        touchRotate: false,
      }}
      layers={[/* layers from Phase 2 */]}
    />
  );
}
```

### State Integration

- **Migrate viewport state**: deck.gl manages viewState natively
- **Keep interaction state**: @mms/toolkit for hover/selection/focus
- **Simplify @mms/toolkit**: Remove viewport slice, keep only interaction slice

---

## Phase 2: Layer Migration (DECK-MIGRATE-002)

### Layer Mapping

| R3F Layer | deck.gl Layer | Notes |
|-----------|---------------|-------|
| MacroLayer (heatmap) | GridLayer or HeatmapLayer | GPU aggregation built-in |
| MesoLayer (blocks) | PolygonLayer or ScatterplotLayer | Auto-instancing |
| MicroLayer (cards) | TextLayer + HTMLOverlay | HTML for interactive elements |

### MacroLayer → GridLayer

```typescript
new GridLayer({
  id: 'macro-heatmap',
  data: tasks,
  getPosition: d => [d.startDay * pxPerDay, -d.trainIndex * pxPerTrain],
  cellSize: DAYS_PER_CELL * pxPerDay, // ~30 days
  colorRange: [
    [255, 255, 190], // Yellow
    [254, 178, 76],  // Orange
    [240, 59, 32],   // Red
  ],
  elevationRange: [0, 0], // 2D only
  extruded: false,
  visible: zoom < 0.5,
});
```

### MesoLayer → PolygonLayer

```typescript
new PolygonLayer({
  id: 'meso-blocks',
  data: tasks,
  getPolygon: d => [
    [d.startDay * pxPerDay, (-d.trainIndex - 0.5) * pxPerTrain + 2],
    [d.startDay * pxPerDay + d.duration * pxPerDay, (-d.trainIndex - 0.5) * pxPerTrain + 2],
    [d.startDay * pxPerDay + d.duration * pxPerDay, (-d.trainIndex - 0.5) * pxPerTrain - 2 + pxPerTrain],
    [d.startDay * pxPerDay, (-d.trainIndex - 0.5) * pxPerTrain - 2 + pxPerTrain],
  ],
  getFillColor: d => d.hasConflict ? [239, 68, 68] : COLORS[d.color],
  pickable: true,
  visible: zoom >= 0.5 && zoom <= 2.0,
  updateTriggers: { getFillColor: [hoveredTaskId, selectedTaskId] },
});
```

### MicroLayer → TextLayer + HTMLOverlay

```typescript
// Labels
new TextLayer({
  id: 'micro-labels',
  data: visibleTasks,
  getPosition: d => [d.startDay * pxPerDay + d.duration * pxPerDay / 2, -d.trainIndex * pxPerTrain - pxPerTrain / 2],
  getText: d => d.type.charAt(0).toUpperCase() + d.type.slice(1),
  getSize: 10,
  getColor: [255, 255, 255],
  visible: zoom > 2.0,
});

// Grid lines - SolidPolygonLayer for backgrounds
// Dependency lines - PathLayer (see Phase 5)
```

---

## Phase 3: LOD System (DECK-MIGRATE-003)

### CompositeLayer Pattern

Create a `MaintenanceLayer` that encapsulates all LOD logic:

```typescript
import { CompositeLayer } from '@deck.gl/core';

export class MaintenanceLayer extends CompositeLayer {
  renderLayers() {
    const { zoom } = this.context.viewport;
    const { data, hoveredTaskId, selectedTaskId } = this.props;

    // LOD thresholds with hysteresis
    const macroVisible = zoom < 0.5;
    const mesoVisible = zoom >= 0.35 && zoom <= 2.15;
    const microVisible = zoom > 1.85;

    // Crossfade opacities
    const macroOpacity = this.calculateOpacity(zoom, 0.35, 0.5, 'out');
    const mesoOpacity = this.calculateOpacity(zoom, 0.35, 0.5, 'in') *
                        this.calculateOpacity(zoom, 1.85, 2.15, 'out');
    const microOpacity = this.calculateOpacity(zoom, 1.85, 2.15, 'in');

    return [
      macroVisible && new GridLayer({ ...macroProps, opacity: macroOpacity }),
      mesoVisible && new PolygonLayer({ ...mesoProps, opacity: mesoOpacity }),
      microVisible && new TextLayer({ ...microProps, opacity: microOpacity }),
    ].filter(Boolean);
  }

  calculateOpacity(zoom, start, end, direction) {
    const t = (zoom - start) / (end - start);
    const clamped = Math.max(0, Math.min(1, t));
    return direction === 'in' ? clamped : 1 - clamped;
  }
}
```

---

## Phase 4: Interaction & State (DECK-MIGRATE-004)

### Hover Detection

deck.gl has native picking support:

```typescript
<DeckGL
  onHover={({ object }) => {
    if (object) {
      canvasStore.dispatch(canvasActions.interaction.setHoveredTask(object.id));
    } else {
      canvasStore.dispatch(canvasActions.interaction.clearHover());
    }
  }}
  onClick={({ object }) => {
    if (object) {
      canvasStore.dispatch(canvasActions.interaction.setSelectedTask(object.id));
    } else {
      canvasStore.dispatch(canvasActions.interaction.clearSelection());
    }
  }}
/>
```

### State Simplification

**Before (R3F):**
```
@mms/toolkit:
├── viewport (camera, momentum, animation, pan state)  ← COMPLEX
└── interaction (hover, selection, focus)
```

**After (deck.gl):**
```
deck.gl viewState (native):
└── target, zoom, minZoom, maxZoom

@mms/toolkit:
└── interaction (hover, selection, focus)  ← SIMPLIFIED
```

---

## Phase 5: Feature Parity (DECK-MIGRATE-005)

### F023 Dependency Lines → PathLayer

```typescript
new PathLayer({
  id: 'dependency-lines',
  data: dependencies,
  getPath: d => [
    [d.from.endX, d.from.y],
    [d.to.startX, d.to.y],
  ],
  getColor: [139, 92, 246], // violet-500
  getWidth: 2,
  widthUnits: 'pixels',
  visible: zoom > 1.85,
});
```

### F021/F022 Keyboard Navigation

- Keep existing keyboard handlers
- Connect to deck.gl via `setViewState()` for navigation
- ARIA live region implementation unchanged

### F018/F019 Hover/Selection

- Handled by deck.gl `onHover`/`onClick` (see Phase 4)
- Visual feedback via `updateTriggers` on layers

---

## Phase 6: Cleanup & Optimization (DECK-MIGRATE-006)

### Dependencies to Remove

```bash
# Remove R3F stack
bun remove @react-three/fiber @react-three/drei three @types/three r3f-perf troika-three-utils
```

### Files to Delete

```
apps/canvas/src/canvas/
├── InfiniteCanvas.tsx      # Replaced by DeckCanvas
├── layers/
│   ├── MacroLayer.tsx      # Replaced by deck.gl GridLayer
│   ├── MesoLayer.tsx       # Replaced by deck.gl PolygonLayer
│   └── MicroLayer.tsx      # Replaced by deck.gl TextLayer
```

### Code to Simplify

1. **@mms/toolkit viewport slice** - Remove entirely, deck.gl manages this
2. **SimpleSpatialIndex** - deck.gl has built-in filtering, keep only for tests
3. **EntityStore** - Keep as-is, directly compatible with deck.gl data format

### Performance Benchmarks

After migration, verify:
- [ ] 60fps during pan/zoom with 60k tasks
- [ ] LOD transitions smooth (no pop-in)
- [ ] Memory stable (no leaks)
- [ ] Bundle size < 500KB (canvas app)

---

## Risk Mitigation

| Risk | Probability | Mitigation |
|------|-------------|------------|
| deck.gl OrthographicView unfamiliar | Low | Research doc provides examples |
| PathLayer insufficient for curved deps | Medium | Fall back to canvas overlay |
| HTML overlay performance at micro zoom | Low | Limit visible HTML elements (existing pattern) |
| Integration with BlueprintJS | Low | HTML overlay layer supports any React content |

---

## Critical Files

### To Create
- `apps/canvas/src/deck/DeckCanvas.tsx`
- `apps/canvas/src/deck/layers/MaintenanceLayer.ts`
- `apps/canvas/src/deck/controllers/TimelineController.ts`
- `docs/archive/r3f-architecture.md`

### To Modify
- `apps/canvas/src/App.tsx` - Replace InfiniteCanvas with DeckCanvas
- `apps/canvas/src/state/viewport.ts` - Simplify significantly
- `apps/canvas/package.json` - Update dependencies
- `features.json` - Add migration tasks
- `claude-progress.txt` - Compress and update

### To Delete (Phase 6)
- `apps/canvas/src/canvas/InfiniteCanvas.tsx` (~2100 lines)
- `apps/canvas/src/canvas/layers/MacroLayer.tsx`
- `apps/canvas/src/canvas/layers/MesoLayer.tsx`
- `apps/canvas/src/canvas/layers/MicroLayer.tsx`

---

## Commit Strategy

Each phase should be a separate commit:
1. `chore: archive R3F architecture and prepare for deck.gl migration`
2. `feat(deck): add deck.gl foundation with OrthographicView`
3. `feat(deck): migrate MacroLayer, MesoLayer, MicroLayer to deck.gl`
4. `feat(deck): implement CompositeLayer LOD system with crossfade`
5. `feat(deck): integrate deck.gl interactions with @mms/toolkit`
6. `feat(deck): add PathLayer for dependency lines, keyboard nav`
7. `chore: remove R3F dependencies and cleanup`

---

## Approval Checklist

Before starting implementation, confirm:
- [ ] deck.gl OrthographicView approach approved
- [ ] @use-gesture/react for input handling approved
- [ ] Removal of R3F/Three.js dependencies approved
- [ ] Timeline estimate acceptable

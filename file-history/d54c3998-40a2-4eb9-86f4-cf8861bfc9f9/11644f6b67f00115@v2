# D3 Modules Integration Plan for MMS Canvas

## Executive Summary

Analysis of 19 TypeScript files in `apps/canvas/src/` identified significant opportunities to replace ad-hoc implementations with battle-tested D3 modules. This will improve cross-browser compatibility, reduce maintenance burden, and enhance performance.

**Key Finding**: ~150+ lines of custom event handling and ~200+ lines of utility functions can be replaced with ~6 D3 modules.

---

## D3 Modules Recommended

| Module | Purpose | Size (gzip) | Files Affected |
|--------|---------|-------------|----------------|
| `d3-zoom` | Pan/zoom/gestures | ~8KB | InfiniteCanvas.tsx |
| `d3-scale` | Linear/time scales | ~6KB | Minimap.tsx, TimelineHeader.tsx |
| `d3-array` | bin, rollup, extent | ~4KB | MacroLayer.tsx, Minimap.tsx, types.ts |
| `d3-time` | Date arithmetic | ~3KB | TimelineHeader.tsx, generator.ts |
| `d3-time-format` | Date formatting | ~2KB | TimelineHeader.tsx |
| `d3-interpolate` | Color interpolation | ~3KB | MacroLayer.tsx, Minimap.tsx |

**Total estimated bundle impact**: ~26KB gzipped (tree-shakeable)

---

## Detailed Opportunities by File

### 1. InfiniteCanvas.tsx (HIGH PRIORITY)

**Current Pain Points:**
- BUG-009: Trackpad zoom lag due to manual event normalization
- BUG-008: Momentum disabled due to stale closure issues
- ~150 lines of cross-platform wheel event handling

**D3-zoom Replacement Targets:**

| Current Function | Lines | D3 Replacement |
|-----------------|-------|----------------|
| `normalizeWheelDelta()` | 1134-1175 | `d3.zoom().wheelDelta()` |
| Trackpad detection heuristics | 756-760 | Built-in to d3-zoom |
| `PinchState` interface | 316-324 | `d3.zoom().touchable()` |
| `handleWheel()` momentum | 698-782 | `d3.zoom().on('zoom')` |

**Migration Complexity**: MEDIUM (requires R3F integration layer)
**Estimated Reduction**: ~60-70% of event handling code

### 2. TimelineHeader.tsx (MEDIUM PRIORITY)

**Current Implementation:**
- Manual date arithmetic with hardcoded day calculations
- Custom unit stepping logic (day/week/month/year)

**D3 Replacement Targets:**

| Current Function | Lines | D3 Replacement |
|-----------------|-------|----------------|
| `addDays()` | 87-91 | `d3.timeDay.offset()` |
| `getUnitStart()` | 96-118 | `d3.timeDay.floor()`, `d3.timeWeek.floor()`, etc. |
| `advanceUnit()` | 139-158 | `d3.timeDay.offset()`, `d3.timeWeek.offset()` |
| `formatDate()` | 163-183 | `d3.timeFormat()` |
| `worldXToDayOffset()` | 73-77 | `d3.scaleLinear().invert()` |
| `dayOffsetToWorldX()` | 79-82 | `d3.scaleLinear()` |

**Migration Complexity**: LOW
**Estimated Reduction**: ~80 lines

### 3. Minimap.tsx (MEDIUM PRIORITY)

**Current Implementation:**
- Manual coordinate transforms world <-> minimap
- Custom grid binning for heatmap
- Linear color interpolation

**D3 Replacement Targets:**

| Current Function | Lines | D3 Replacement |
|-----------------|-------|----------------|
| `worldToMinimap()` | 58-68 | `d3.scaleLinear()` (x/y scales) |
| `minimapToWorld()` | 70-83 | `d3.scaleLinear().invert()` |
| `generateHeatmapData()` | 89-117 | `d3.bin()` + `d3.rollup()` |
| `interpolateColor()` | 122-136 | `d3.interpolateRgb()` |

**Migration Complexity**: LOW
**Estimated Reduction**: ~60 lines

### 4. MacroLayer.tsx (LOW PRIORITY)

**Current Implementation:**
- Custom density grid calculation
- Manual color gradient interpolation

**D3 Replacement Targets:**

| Current Function | Lines | D3 Replacement |
|-----------------|-------|----------------|
| `calculateDensityGrid()` | 75-100 | `d3.bin()` + `d3.rollup()` |
| `getHeatmapColor()` | 46-69 | `d3.scaleSequential(d3.interpolateYlOrRd)` |

**Migration Complexity**: LOW
**Estimated Reduction**: ~50 lines

### 5. types.ts (LOW PRIORITY)

**Current Implementation:**
- Manual min/max loops for bounds calculation

**D3 Replacement Targets:**

| Current Function | Lines | D3 Replacement |
|-----------------|-------|----------------|
| `calculateWorldBounds()` | 153-164 | `d3.extent()` |
| `calculateDataBounds()` min/max loops | 189-242 | `d3.extent()` |

**Migration Complexity**: LOW
**Estimated Reduction**: ~30 lines

### 6. generator.ts (LOW PRIORITY)

**Current Implementation:**
- Task date generation with manual Date arithmetic

**D3 Replacement Targets:**
- Date offset calculations could use `d3.timeDay.offset()`
- Not critical - mock data generator

**Migration Complexity**: LOW

---

## Files WITHOUT D3 Opportunities

| File | Reason |
|------|--------|
| `viewport.ts` | State management via @mms/toolkit - architecture is sound |
| `App.tsx` | Orchestration layer - no calculations to replace |
| `MesoLayer.tsx` | InstancedMesh setup - R3F-specific, no D3 relevance |
| `MicroLayer.tsx` | HTML overlay rendering - React/CSS domain |
| `PerfMonitor.tsx` | Performance monitoring - stats.js integration |
| `TaskTooltip.tsx` | Simple UI component |
| `TaskDetailsPanel.tsx` | Simple UI component |

---

## Phased Migration Plan

### Phase 1: Quick Wins (LOW complexity)

**Goal**: Build confidence with simple replacements

1. **types.ts** - Replace extent calculations
   - Install: `bun add d3-array`
   - Replace `calculateWorldBounds()` min/max with `d3.extent()`
   - Test: Unit tests for bounds calculation

2. **TimelineHeader.tsx** - Replace date utilities
   - Install: `bun add d3-time d3-time-format d3-scale`
   - Replace: `addDays()`, `getUnitStart()`, `advanceUnit()`, `formatDate()`
   - Test: Visual verification of timeline labels

3. **Minimap.tsx** - Replace coordinate transforms
   - Use already-installed `d3-scale`
   - Replace: `worldToMinimap()`, `minimapToWorld()`, `interpolateColor()`
   - Install: `bun add d3-interpolate`
   - Test: Minimap click navigation

### Phase 2: Core Optimization (MEDIUM complexity)

**Goal**: Address BUG-009 with d3-zoom

4. **InfiniteCanvas.tsx** - Replace wheel event handling
   - Install: `bun add d3-zoom`
   - Create R3F integration adapter
   - Replace: `normalizeWheelDelta()`, trackpad detection
   - Test: Cross-browser zoom (Chrome, Safari, Firefox)
   - Verify: BUG-009 resolved (trackpad zoom lag)

### Phase 3: Visual Polish (LOW complexity)

5. **MacroLayer.tsx** - Replace heatmap generation
   - Use already-installed `d3-array`, `d3-interpolate`
   - Replace: `calculateDensityGrid()`, `getHeatmapColor()`
   - Test: Visual verification of heatmap colors

---

## Implementation Notes

### d3-zoom + R3F Integration

```typescript
// Adapter pattern for R3F integration
import { zoom } from 'd3-zoom';
import { select } from 'd3-selection';

function useD3Zoom(containerRef: RefObject<HTMLElement>) {
  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const zoomBehavior = zoom<HTMLElement, unknown>()
      .scaleExtent([minZoom, maxZoom])
      .on('zoom', (event) => {
        // Dispatch to @mms/toolkit store
        canvasStore.dispatch(canvasActions.viewport.setCamera({
          x: event.transform.x,
          y: event.transform.y,
          zoom: event.transform.k,
        }));
      });

    select(container).call(zoomBehavior);

    return () => {
      select(container).on('.zoom', null);
    };
  }, [containerRef, minZoom, maxZoom]);
}
```

### d3-scale for Coordinate Transforms

```typescript
// Before
function worldToMinimap(worldX: number, worldY: number) {
  const x = ((worldX - worldBounds.minX) / worldWidth) * minimapWidth;
  const y = ((worldY - worldBounds.minY) / worldHeight) * minimapHeight;
  return { x, y };
}

// After
const xScale = d3.scaleLinear()
  .domain([worldBounds.minX, worldBounds.maxX])
  .range([0, minimapWidth]);

const yScale = d3.scaleLinear()
  .domain([worldBounds.minY, worldBounds.maxY])
  .range([0, minimapHeight]);

function worldToMinimap(worldX: number, worldY: number) {
  return { x: xScale(worldX), y: yScale(worldY) };
}
```

---

## Success Criteria

- [ ] All unit tests pass
- [ ] Visual verification via Playwright MCP
- [ ] No console errors
- [ ] BUG-009 (trackpad zoom lag) resolved
- [ ] Cross-browser testing: Chrome, Safari, Firefox
- [ ] Performance: 60fps maintained during pan/zoom
- [ ] Bundle size increase < 30KB gzipped

---

## Critical Files to Modify

```
apps/canvas/src/
├── canvas/
│   ├── InfiniteCanvas.tsx    # Phase 2: d3-zoom
│   └── layers/
│       └── MacroLayer.tsx    # Phase 3: d3-array, d3-interpolate
├── components/
│   ├── Minimap.tsx           # Phase 1: d3-scale, d3-interpolate
│   └── TimelineHeader.tsx    # Phase 1: d3-time, d3-time-format, d3-scale
├── data/
│   └── types.ts              # Phase 1: d3-array (extent)
└── package.json              # Add d3 modules
```

---

## Output Files to Create

1. **`apps/canvas/d3-opportunities.txt`** - Detailed analysis document
2. **`features.json`** - Add D3-MIGRATE-001 task

---

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| d3-zoom conflicts with R3F event system | Create adapter layer, test thoroughly |
| Bundle size increase | Tree-shake unused D3 functions |
| Breaking existing interactions | Incremental migration, feature flags |
| Learning curve | Well-documented D3 modules, good TypeScript support |

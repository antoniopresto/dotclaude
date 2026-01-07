# MMS Beta - What-If Demo

**Source of Truth:** `./deck/docs/RFQ.md`

Create a high-fidelity demo in `./beta` implementing the "what-if" scenario from the RFQ with mocked data. Canvas Semantic Zoom (Google Maps style) + interactive man-hours vs capacity simulations.

---

## Project Structure

```
./beta/
├── apps/
│   └── demo/                    # Main demo application
├── packages/
│   ├── stores/                  # Vanilla stores + useSyncExternalStore
│   ├── entity-store/            # TypedArray SoA storage + fork/diff
│   ├── spatial/                 # RBush spatial index
│   ├── ui/                      # Design system
│   └── data/                    # Mock data generators
├── docs/
│   └── STREETSCAPE_PATTERNS.md  # TimeScrubber patterns analysis
├── CLAUDE.md                    # Harness
├── features.json                # Feature tracking
├── claude-progress.txt          # Session history
└── init.sh                      # Init script
```

---

## Tech Stack (VALIDATED)

| Layer | Technology | Justification |
|-------|------------|---------------|
| Runtime | Bun 1.2+ | Fast monorepo |
| Build | Vite 5.x | Fast HMR |
| Frontend | React 18 | Required for BlueprintJS |
| Visualization | deck.gl 9.x | Handles 1M items @60fps (validated) |
| State | Vanilla Store + useSyncExternalStore | Official React 18 pattern |
| Entity Data | EntityStore (TypedArrays) | Binary data for deck.gl perf |
| **Spatial Index** | **Flatbush** | **4x faster than RBush for static data** |
| List Virtualization | TanStack Virtual | Best for 2024/2025 |
| UI | BlueprintJS 6 | Enterprise dark theme |
| Charts | Visx | d3-based charts |
| Styling | Tailwind CSS | Utility-first |

### Performance Research Summary

**deck.gl (validated for 60k items):**
- Handles 1M items @60fps on 2015 MacBook
- Use binary data (TypedArrays) for best performance
- Use `data.attributes` to bypass CPU attribute generation
- Keep `pickable: false` when not needed

**Flatbush vs RBush (use Flatbush):**
| Benchmark (1M rectangles) | Flatbush | RBush |
|---------------------------|----------|-------|
| Index time | 273ms | 1143ms |
| 1000 searches 1% | 63ms | 155ms |

Flatbush is 4x faster for static data. Our data is static (loaded once).

**Sources:**
- https://deck.gl/docs/developer-guide/performance
- https://github.com/mourner/flatbush
- https://github.com/visgl/deck.gl/discussions/7076

---

## Design Inspirations

| Aspect | Reference |
|--------|-----------|
| Interaction | AVS/streetscape.gl |
| Timeline | Linear.app milestones |
| Scheduling | Dime Scheduler |
| Visual | IntelliJ Islands |

---

## Implementation Phases

### Phase 0: Harness Setup

Create harness structure for context persistence.

**Files:**
- `./beta/CLAUDE.md`
- `./beta/features.json`
- `./beta/claude-progress.txt`
- `./beta/init.sh`
- `./beta/.claude/settings.json`

---

### Phase 1: Stores + Streetscape Analysis

#### 1.1 Vanilla Stores (`packages/stores/`)

```typescript
// Pattern: Vanilla class + useSyncExternalStore
class ViewportStore {
  private state = { zoom: 1, pan: { x: 0, y: 0 } };
  private listeners = new Set<() => void>();

  getState = () => this.state;
  subscribe = (l: () => void) => { this.listeners.add(l); return () => this.listeners.delete(l); };

  setZoom = (zoom: number) => { this.state = { ...this.state, zoom }; this.listeners.forEach(l => l()); };
}

export const viewportStore = new ViewportStore();
export const useViewport = () => useSyncExternalStore(viewportStore.subscribe, viewportStore.getState);
```

**Stores to create:**
- `viewport.ts` - Zoom, pan, LOD
- `selection.ts` - Hover, selected tasks
- `sandbox.ts` - Live/What-If mode
- `ui.ts` - Panels, modals

#### 1.2 Streetscape.gl Analysis

Analyze https://github.com/uber/streetscape.gl for:
- PlaybackControl patterns
- StreamSettingsPanel patterns
- Document in `docs/STREETSCAPE_PATTERNS.md`

---

### Phase 2: EntityStore + SandboxStore

#### 2.1 Port EntityStore (`packages/entity-store/`)

**From:** `./deck/apps/canvas/src/entity-store/`

- `EntityStore.ts` - TypedArray SoA storage
- `types.ts` - TaskArrays, TaskCursor

#### 2.2 Create SandboxStore (NEW)

```typescript
interface ChangeSet {
  added: number[];
  removed: number[];
  modified: Array<{ index: number; field: string; oldValue: number; newValue: number; }>;
}

class SandboxStore {
  private baseline: EntityStore;
  private sandbox: EntityStore | null = null;

  get isInSandbox() { return this.sandbox !== null; }
  get activeStore() { return this.sandbox ?? this.baseline; }

  fork(): void;      // Create shallow copy
  diff(): ChangeSet; // Compute changes
  apply(): void;     // Commit changes
  discard(): void;   // Abandon changes
}
```

---

### Phase 3: Spatial Index + Canvas

#### 3.1 Create Flatbush Spatial Index (`packages/spatial/`)

**DO NOT port RBush** - use Flatbush instead (4x faster for static data).

```typescript
import Flatbush from 'flatbush';

class SpatialIndex {
  private index: Flatbush;

  build(tasks: Task[]) {
    this.index = new Flatbush(tasks.length);
    for (const task of tasks) {
      this.index.add(task.x, task.y, task.x + task.width, task.y + task.height);
    }
    this.index.finish();
  }

  queryViewport(minX, minY, maxX, maxY): number[] {
    return this.index.search(minX, minY, maxX, maxY);
  }
}
```

#### 3.2 Canvas Setup (`apps/demo/src/canvas/`)

- `DeckCanvas.tsx` - deck.gl wrapper
- `layers/MacroLayer.ts` - Heatmap (zoom < 0.5x)
- `layers/MesoLayer.ts` - Blocks (0.5x - 2x)
- `layers/MicroLayer.ts` - Details (> 2x)

---

### Phase 4: Design System + UI

#### 4.1 Design Tokens (`packages/ui/`)

```css
--bg-canvas: #0f0f0f;
--bg-panel: #1a1a1a;
--bg-elevated: #242424;
--text-primary: #ffffff;
--text-secondary: #a0a0a0;
--accent-primary: #5c7cfa;
--accent-sandbox: #be4bdb;
--font-sans: 'Inter', system-ui, sans-serif;
```

#### 4.2 Components

- Panel, TimelineRuler, ResourceBar, SandboxToggle

#### 4.3 TimeScrubber

Based on Streetscape.gl analysis from Phase 1.

---

### Phase 5: What-If Mode

#### 5.1 Flow

```
1. User clicks "Enter What-If Mode"
2. sandboxStore.fork()
3. User edits tasks (drag, resize)
4. UI shows diff in real-time
5. User clicks "Apply" → sandboxStore.apply()
   OR "Discard" → sandboxStore.discard()
```

#### 5.2 Components

- `SandboxToggle.tsx` - Live/What-If toggle
- `ImpactPanel.tsx` - Show diff, Apply/Discard buttons
- `ComparisonChart.tsx` - Man-hours vs capacity (RFQ Page 4 style)

---

### Phase 6: Mock Data

#### Generators (`packages/data/`)

- 128 trains (49 Kinki + 79 Alstom)
- 10 years of PM tasks (~60k tasks)
- Pre-defined scenarios: "Without adjustment" vs "With adjustment"
- Intentional capacity conflicts for demo

---

### Phase 7: Polish

- Smooth zoom transitions
- Hover effects
- Loading states
- Dark theme consistency

---

## Layout

```
┌──────────────────────────────────────────────────────────────────┐
│ NAVBAR  [Live ◉] [What-If ○]     [Today]  [Zoom: Month ▼]  [⚙]  │
├──────────────────────────────────────────────────────────────────┤
│          │                                                       │
│  SIDEBAR │                  CANVAS (deck.gl)                     │
│          │   ┌─────────────────────────────────────────────┐    │
│  Fleet   │   │ Timeline Ruler (Year/Quarter/Month)          │    │
│  Filter  │   ├─────────────────────────────────────────────┤    │
│          │   │ Train 001 ▓▓▓░░░▓▓░░▓▓▓▓░░░░░░▓▓▓░░░░░    │    │
│  Train   │   │ Train 002 ░░▓▓▓░░░░▓▓░░░░▓▓▓░░░░░░░░░░    │    │
│  List    │   │ ...                                          │    │
│          │   └─────────────────────────────────────────────┘    │
│          ├───────────────────────────────────────────────────────┤
│          │                  RESOURCE PANEL                       │
│          │   Man-Hours: [████████░░░░░░░░░░░░░] 65%              │
│          │   ⚠ Week 12: Over capacity by 45 man-hours            │
└──────────┴───────────────────────────────────────────────────────┘
```

---

## Features Tracking

```json
{
  "features": [
    { "id": "HARNESS-001", "phase": 0, "description": "Harness setup" },
    { "id": "STORES-001", "phase": 1, "description": "Vanilla stores" },
    { "id": "STREETSCAPE-001", "phase": 1, "description": "Streetscape.gl analysis" },
    { "id": "ENTITY-001", "phase": 2, "description": "Port EntityStore" },
    { "id": "SANDBOX-001", "phase": 2, "description": "Create SandboxStore (fork/diff)" },
    { "id": "SPATIAL-001", "phase": 3, "description": "Create Flatbush spatial index (NOT RBush)" },
    { "id": "CANVAS-001", "phase": 3, "description": "deck.gl canvas with LOD layers" },
    { "id": "DESIGN-001", "phase": 4, "description": "Design tokens + components" },
    { "id": "TIMESCRUB-001", "phase": 4, "description": "TimeScrubber component" },
    { "id": "WHATIF-001", "phase": 5, "description": "What-If mode" },
    { "id": "DATA-001", "phase": 6, "description": "Mock data generators" },
    { "id": "POLISH-001", "phase": 7, "description": "Visual polish" }
  ]
}
```

---

## Dependencies Graph

```
HARNESS-001
    │
    ├───────────────┐
    ▼               ▼
STORES-001    STREETSCAPE-001
    │               │
    ▼               │
ENTITY-001          │
    │               │
    ├────────┐      │
    ▼        ▼      │
SANDBOX-001  SPATIAL-001
    │        │      │
    │        ▼      │
    │   CANVAS-001──┘
    │        │
    │        ▼
    │   DESIGN-001
    │        │
    │        ├───────┐
    │        ▼       ▼
    │   TIMESCRUB-001
    │        │
    └───┬────┘
        ▼
   WHATIF-001 → DATA-001 → POLISH-001
```

---

## Next Steps

1. Create `./beta/` directory
2. Implement HARNESS-001
3. Implement STORES-001 (vanilla stores)
4. Start STREETSCAPE-001 analysis (parallel)
5. Port ENTITY-001 + create SANDBOX-001
6. Create SPATIAL-001 with Flatbush

**Do NOT start CANVAS-001 before:**
- ✅ Stores created
- ✅ EntityStore ported
- ✅ SandboxStore implemented
- ✅ Flatbush spatial index created

---

## Session Handoff Instructions

**Plan file:** `.claude/plans/quiet-hatching-music.md`

**Key decisions made:**
1. NO custom toolkit - use Vanilla Stores + useSyncExternalStore
2. Flatbush instead of RBush (4x faster for static data)
3. TanStack Virtual for list virtualization
4. deck.gl validated for 60k+ items (handles 1M @60fps)
5. EntityStore with TypedArrays for binary data performance
6. SandboxStore (NEW) for fork/diff What-If mode

**Source of truth:** `./deck/docs/RFQ.md`

**What to port from ./deck:**
- `./deck/apps/canvas/src/entity-store/EntityStore.ts` → adapt for ./beta
- `./deck/apps/canvas/src/entity-store/types.ts` → adapt for ./beta

**What NOT to port:**
- @mms/toolkit (too complex, use vanilla stores)
- RBush (use Flatbush instead)

**Start command:**
```bash
cd ./beta && bun install && bun run dev
```

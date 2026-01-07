# Plan: Migrate POC to Vite + React 18 + R3F + BlueprintJS

## Overview

Create a new app `apps/canvas` using Vite + React 18 + R3F + BlueprintJS 6, migrating the working `URGENT_POC/canvas.html` POC to a production-ready React application.

## Key Decisions

- **Location**: `apps/canvas/` (inside monorepo)
- **React Version**: 18.x (BlueprintJS 6 requires React 18)
- **Toolkit**: Adjust peerDependencies to accept `^18.0.0 || ^19.0.0`
- **Styling**: BlueprintJS 6 from the start (no Tailwind - avoid rewrite)
- **Harness**: Use existing `features.json` and `claude-progress.txt` (no new doc files)

## Harness Integration

Following [Anthropic's Effective Harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents):
- Add new features to existing `features.json`
- Update `claude-progress.txt` after each session
- Commit after each completed feature
- Visual test before marking passes:true

## Files to Modify

### 1. Toolkit peerDependencies
```
packages/toolkit/package.json
- "react": "^19.2.0" → "react": "^18.0.0 || ^19.0.0"
```

### 2. Harness Files
```
features.json
- Add new category "canvas" for migration features (F101-F117)
- Update product.entry to "apps/canvas"

claude-progress.txt
- Add new session entry for migration start
```

### 3. Documentation Updates (ALL)
```
CLAUDE.md
- Update URGENT_POC section to mark as "archived POC"
- Add new section for apps/canvas as production target
- Update Tech Stack section (React 18, BlueprintJS 6)
- Update Quick Commands for new app
- Update Project Structure diagram

docs/README.md
- Update "Current Implementation" to reference apps/canvas
- Update implementation status

docs/UX_SPECIFICATION.md
- Update section 3.1 to reference R3F implementation
- Update section 6 component layout for BlueprintJS

agent_docs/architecture.md
- Add apps/canvas architecture section
- Update tech stack references
```

## Files to Create

### New App Structure
```
apps/canvas/
├── package.json
├── vite.config.ts
├── tsconfig.json
├── index.html
└── src/
    ├── main.tsx
    ├── App.tsx
    ├── components/           # BlueprintJS UI components
    │   ├── AppLayout.tsx     # Navbar, Sidebar, Canvas container
    │   ├── TrainSidebar.tsx  # Train IDs list (Card)
    │   ├── ZoomControls.tsx  # ButtonGroup +/-
    │   └── LODIndicator.tsx  # Tag component
    ├── canvas/               # R3F rendering
    │   ├── InfiniteCanvas.tsx
    │   ├── CameraController.tsx
    │   └── layers/
    │       ├── MacroLayer.tsx
    │       ├── MesoLayer.tsx
    │       └── MicroLayer.tsx
    ├── data/
    │   ├── types.ts
    │   └── generator.ts
    └── hooks/
        └── useViewport.ts    # zoom, pan, LOD state
```

## Dependencies

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "@blueprintjs/core": "^6.1.0",
    "@blueprintjs/icons": "^6.1.0",
    "@react-three/fiber": "^8.17.0",
    "@react-three/drei": "^9.114.0",
    "three": "^0.170.0",
    "@mms/toolkit": "workspace:*"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.0",
    "vite": "^5.4.0",
    "typescript": "^5.6.0",
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "@types/three": "^0.170.0"
  }
}
```

## Implementation Phases (Features to add to features.json)

### Phase 1: Foundation
- **F101**: Create Vite + React 18 + BlueprintJS app skeleton
- **F102**: Add R3F Canvas with OrthographicCamera
- **F103**: Basic BlueprintJS layout (Navbar, sidebar placeholder)

### Phase 2: Data & Core Rendering
- **F104**: Data types and mock generator (port from canvas.html)
- **F105**: MesoLayer - InstancedMesh task blocks
- **F106**: Pan (drag) and Zoom (scroll) camera controls
- **F107**: LOD state (zoom thresholds: <0.5 MACRO, >2 MICRO)

### Phase 3: All LOD Layers
- **F108**: MacroLayer - Heatmap cells
- **F109**: MicroLayer - Html task cards with labels
- **F110**: Smooth LOD transitions (no flicker)

### Phase 4: UI Integration
- **F111**: TrainSidebar synced with camera Y
- **F112**: Timeline header (adaptive granularity)
- **F113**: ZoomControls and LODIndicator in Navbar
- **F114**: Conflict indicators (Intent.DANGER styling)

### Phase 5: Polish
- **F115**: Instructions Toaster (auto-dismiss)
- **F116**: Performance optimization (60fps)
- **F117**: Full visual parity with canvas.html POC

## Visual Test Protocol

Each feature must pass before marking `passes: true`:
1. Navigate to `http://localhost:5173`
2. Check console for errors
3. Screenshot and compare with POC reference
4. Test interactions (pan, zoom, LOD transitions)

## Success Criteria

- [ ] App runs without errors
- [ ] BlueprintJS components render correctly
- [ ] All 3 LOD layers work
- [ ] Pan/zoom smooth at 60fps
- [ ] Visual parity with canvas.html

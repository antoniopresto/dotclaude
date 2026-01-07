# Design Overhaul Plan - MMS-MFC

## ⚠️ CRITICAL: USE BMAD METHOD ONLY

**NO AD-HOC WORK ALLOWED.** All changes must flow through BMAD workflows.

## Problem Statement

- All screens visually inconsistent and unpresentable
- Canvas doesn't work correctly
- Design documents have conflicts
- What-if scenario planning is broken/missing
- All content may be AI-hallucinated - VERIFY EVERYTHING

## User Decisions

| Decision | Choice |
|----------|--------|
| Color Palette | Create NEW unified palette |
| Maintenance Terms | Use REAL railway terminology (research required) |
| Canvas Technology | Migrate to deck.gl |
| Scope | Complete visual redesign + LOD/zoom + What-if scenarios |
| Testing | Playwright MCP for ALL interactions (pan, zoom, drag, etc.) |

## Reference Materials (MUST VERIFY BEFORE USE)

**New Design Docs (may have errors):**
- `/docs/MMS_STYLE_GUIDE.md`
- `/docs/DESIGN_SPEC.md`
- `/docs/design/*`

**Previous Projects (UNTRUSTED - verify radically):**
- `/Users/anotonio.silva/antonio/mms/deck/` - deck.gl impl
- `/Users/anotonio.silva/antonio/mms/system/` - another MMS impl
- `/Users/anotonio.silva/antonio/mms/design/` - design assets

**Original Requirements:**
- `/Users/anotonio.silva/antonio/mms/RFQ.pdf` - The actual RFQ

---

## BMAD WORKFLOW CHAIN (MANDATORY)

```
Step 1: /correct-course
        └── Analyze impact on all BMAD artifacts
        └── Create Sprint Change Proposal
        └── Get user approval

Step 2: Update BMAD Planning Artifacts
        └── ux-design-specification.md (unified design)
        └── architecture.md (deck.gl migration)
        └── Add Epic 7 & 8 to epics.md

Step 3: /create-story (for each new story)
        └── 8-1 through 8-6 (Visual Redesign)
        └── 7-1 through 7-6 (What-If Scenarios)

Step 4: /dev-story (implement each story)
        └── With Playwright MCP visual testing
        └── All interactions tested

Step 5: /code-review (after each epic)
        └── Adversarial review
        └── Visual verification

Step 6: /retrospective (after completion)
```

---

## Critical Issues Identified

### 1. Design Document Conflicts (Must Resolve First)
| Issue | Documents Affected | Resolution Needed |
|-------|-------------------|-------------------|
| 3 different color palettes | MMS_STYLE_GUIDE, DESIGN_SPEC, UX_SPECIFICATION | Choose ONE official palette |
| Light vs Dark theme | UX_SPECIFICATION (light) vs others (dark) | Mandate dark-mode-first |
| Maintenance colors | PM1/2/3 (blue/violet/pink) vs A/B/C/D (green/blue/amber/red) | Unify terminology |
| LOD levels | 3 levels vs 4 levels | Lock down 3-level approach |

### 2. Implementation Inconsistencies
| Component | Problem | Status |
|-----------|---------|--------|
| MaintenanceGantt.tsx | Uses LIGHT mode (bg-white, text-gray-900) | BROKEN |
| Layout.tsx | Uses bg-gray-50 (light) instead of dark | BROKEN |
| ScheduleCanvas.tsx | Hardcoded hex colors, not CSS vars | BROKEN |
| Pixi.js text | White text directly, not themed | BROKEN |

### 3. New Reference Files to Evaluate
- `/docs/MMS_STYLE_GUIDE.md` - Comprehensive but conflicts with DESIGN_SPEC
- `/docs/DESIGN_SPEC.md` - deck.gl focused, different from current Pixi.js impl
- `/docs/design/*` - UX specs with light theme (contradicts dark mandate)

## BMAD Workflow Chain (Required)

```
Phase 1: Reconcile Design Documents
         → Manual update of conflicting specs
         → Create single source of truth

Phase 2: Update BMAD Artifacts
         /correct-course → Sprint Change Proposal
         → Update ux-design-specification.md
         → Update affected epics/stories

Phase 3: Create Implementation Stories
         /create-story → New stories for design fixes
         → Story for each screen/component

Phase 4: Implement Changes
         /dev-story → Implement each story
         → Visual testing with Playwright MCP

Phase 5: Review & Verify
         /code-review → Adversarial review
         → Playwright screenshots for each screen
```

## Recommended Approach

### Step 1: Resolve Design Document Conflicts (FIRST)

Before any BMAD workflow, we must create a **unified design source of truth**:

1. **Choose official palette**: MMS_STYLE_GUIDE.md (slate-900 dark theme)
2. **Lock maintenance colors**: Use consistent PM1/2/3 terminology with DESIGN_SPEC colors
3. **Fix LOD levels**: 3-level approach (MACRO/MESO/MICRO) from DESIGN_SPEC
4. **Update all docs** to match chosen decisions

### Step 2: Run /correct-course Workflow

With unified design specs, analyze impact:
- Which epics are affected? (Epic 2: Dashboard, Epic 6: Gantt/Canvas)
- What stories need updates?
- What components need rewriting?

### Step 3: Create New Epic for Design Overhaul

New Epic: "Design System Unification & Visual Polish"
- Story: Unify CSS variables with official palette
- Story: Fix MaintenanceGantt dark mode
- Story: Fix Layout.tsx dark background
- Story: Refactor ScheduleCanvas to use theme
- Story: Visual testing all screens

### Step 4: Implementation via /dev-story

Each story follows:
1. Update component code
2. Run visual tests with Playwright MCP
3. Capture screenshots
4. Mark story complete

## Files to Modify

### BMAD Artifacts
- `_bmad-output/planning-artifacts/ux-design-specification.md` - Update with unified design
- `_bmad-output/implementation-artifacts/sprint-status.yaml` - Add new stories

### Design Documents (Reconcile)
- `docs/MMS_STYLE_GUIDE.md` - Mark as PRIMARY
- `docs/DESIGN_SPEC.md` - Align with style guide
- `docs/design/UX_SPECIFICATION.md` - Fix light theme references

### Implementation Files
- `apps/web/src/app/globals.css` - CSS variables
- `apps/web/tailwind.config.ts` - Theme colors
- `apps/web/src/app/layout.tsx` - Dark background
- `apps/web/src/components/maintenance/MaintenanceGantt.tsx` - Dark mode
- `apps/web/src/app/schedule/page.tsx` - Canvas theming
- `apps/web/src/components/schedule/ScheduleCanvas.tsx` - Theme colors

## Questions for User

1. **Color Palette**: Should we use MMS_STYLE_GUIDE.md (slate-900) or DESIGN_SPEC.md (pure black #0A0A0A) as the official background?

2. **Maintenance Types**: Are PM1/PM2/PM3/Overhaul the correct terminology, or should it be A-Check/B-Check/C-Check/D-Overhaul?

3. **Canvas Technology**: Current implementation uses Pixi.js. DESIGN_SPEC.md recommends deck.gl. Should we:
   - A) Keep Pixi.js and fix theming (faster)
   - B) Migrate to deck.gl as per DESIGN_SPEC (more work, better long-term)

4. **Scope**: Should we fix only the visual theming (dark mode consistency), or also implement missing features like semantic zoom transitions?

## Research Findings: What-If Scenario Planning

### Industry Leaders (Sources)
- [ZEDAS zedas®asset](https://www.zedas.com/) - Forecasts vehicle condition, links maintenance data for budget decisions
- [AnyLogic Rail Simulation](https://www.anylogic.com/rail-logistics/) - Netherlands Railways uses for testing disruptions/timetable changes
- [DELMIA Quintiq (Dassault)](https://www.3ds.com/products/delmia/quintiq/) - Explores profitability of new routes, rolling stock investment, regulation impact
- [Epicflow What-If](https://www.epicflow.com/features/what-if/) - Drag-drop to visualize schedule, test different approaches
- [SAP/Absoft](https://www.absoft.co.uk/sap-for-transport-rail/) - Models "what-if" scenarios for transport services, budget vs actuals

### Key What-If Features to Implement

1. **Scenario Sandbox Mode**
   - Clone current state to sandbox environment
   - Make changes without affecting live data
   - Compare sandbox vs live side-by-side

2. **Resource Simulation**
   - Test fleet size changes (add/remove trains)
   - Vacation/absence planning for workforce
   - Budget allocation scenarios

3. **Impact Analysis**
   - Automatic calculation of km variance
   - Depot capacity utilization forecast
   - Maintenance schedule conflicts

4. **Comparison Dashboard**
   - Select 2-3 scenarios side-by-side
   - Highlight best values (green) vs worst (red)
   - KPI delta visualization

5. **Apply to Live**
   - One-click apply approved scenario
   - Audit trail of changes
   - Rollback capability

### What MMS Currently Has (BROKEN)
- SimulationPanel exists but uses hardcoded demo changes
- Cannot modify real allocations
- No scenario comparison
- No workforce/vacation planning
- No budget simulation

---

## BMAD Testing Configuration Required

### Playwright MCP Integration
All BMAD dev-story implementations MUST include:

```yaml
# Required in each story's acceptance criteria
visual_testing:
  - screenshot: before/after each change
  - console_check: no errors
  - interaction_test: required for UI stories

interaction_testing:
  - pan: test canvas dragging
  - zoom: test scroll wheel + pinch
  - click: test all buttons/links
  - drag_drop: test schedule editing
  - form_input: test what-if parameters
```

### BMAD Hook Configuration
Add to `.claude/hooks/` or BMAD config:
- Pre-commit: Run Playwright visual tests
- Post-story: Capture screenshots of all pages
- Code-review: Include visual diff in review

---

## New Epic: What-If Scenario System

### Epic 7: What-If Scenario Planning (NEW)

**Stories:**
1. **7-1-scenario-sandbox-mode** - Clone state to sandbox, visual indicator
2. **7-2-fleet-size-simulation** - Add/remove trains, see km impact
3. **7-3-workforce-vacation-planning** - Schedule staff absences, test coverage
4. **7-4-budget-allocation-scenarios** - Test different budget distributions
5. **7-5-scenario-comparison-dashboard** - Side-by-side with KPI deltas
6. **7-6-apply-scenario-to-live** - Commit changes with audit trail

---

## New Epic: Visual Redesign & deck.gl

### Epic 8: Visual Redesign (NEW)

**Stories:**
1. **8-1-unified-design-tokens** - CSS variables, Tailwind config, color palette
2. **8-2-typography-system** - Font scales, railway terminology labels
3. **8-3-component-dark-mode-fix** - Fix MaintenanceGantt, Layout.tsx
4. **8-4-deck-gl-canvas-migration** - Replace Pixi.js with deck.gl
5. **8-5-semantic-zoom-lod** - MACRO/MESO/MICRO with transitions
6. **8-6-interaction-testing-suite** - Playwright tests for all interactions

---

## Implementation Order (BMAD Chain)

```
Phase 1: Update BMAD Artifacts
├── /correct-course → Sprint Change Proposal
├── Update ux-design-specification.md
├── Update architecture.md (deck.gl)
└── Create Epic 7 & 8 story files

Phase 2: Design System Foundation (Epic 8.1-8.3)
├── /dev-story 8-1-unified-design-tokens
├── /dev-story 8-2-typography-system
├── /dev-story 8-3-component-dark-mode-fix
└── /code-review

Phase 3: Canvas Migration (Epic 8.4-8.6)
├── /dev-story 8-4-deck-gl-canvas-migration
├── /dev-story 8-5-semantic-zoom-lod
├── /dev-story 8-6-interaction-testing-suite
└── /code-review

Phase 4: What-If System (Epic 7)
├── /dev-story 7-1 through 7-6
├── Playwright interaction tests for each
└── /code-review

Phase 5: Final Polish
├── /retrospective for Epic 7 & 8
└── Full visual testing suite run
```

---

## Success Criteria

- [ ] All screens use consistent dark theme
- [ ] Canvas renders correctly with deck.gl
- [ ] Semantic zoom (3 LOD levels) working
- [ ] What-if scenarios can be created and compared
- [ ] Workforce/vacation planning functional
- [ ] All interactions tested with Playwright (pan, zoom, drag, click)
- [ ] No light-mode components in dark UI
- [ ] Visual testing passes for all pages
- [ ] All changes tracked via BMAD workflows
- [ ] Railway terminology used correctly

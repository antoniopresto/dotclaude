# Plan: DESIGN_SPEC.md Critical Revision - FINAL

## Summary

Complete revision of DESIGN_SPEC.md to fix critical issues and incorporate new reference sources.

---

## User Decisions (Confirmed 2025-12-19)

1. **Tech Stack**: Vite + React 18 (correct from Astro.js)
2. **Sandbox Mode**: Detailed specification required (will be implemented later)
3. **Scope**: Planning View + Sandbox Mode focused, with roadmap for post-demo features
4. **References**: Use new high-quality sources, screen-*.png as inspiration only

---

## 🎯 NEW REFERENCE SOURCES (Critical)

### Primary References (Must Study)

| Source | URL | Purpose |
|--------|-----|---------|
| **Epicflow What-If** | https://www.epicflow.com/features/what-if/ | Sandbox Mode UI pattern |
| **Epicflow Pipeline** | https://www.epicflow.com/wp-content/uploads/2023/10/pipeline-implement.png | Visual planning layout |
| **Dime Scheduler** | https://www.dimescheduler.com/ | EXCELLENT - watch video |
| **AVS Auto Demo** | https://avs.auto/demo/index.html | Single pane of glass example |
| **DHTMLX Gantt D3** | https://dhtmlx.github.io/demo-gantt-d3/index_1.html | Gantt with deck.gl-like rendering |
| **Prometheus Group** | https://www.prometheusgroup.com/resources/posts/what-does-flipping-burgers-have-to-do-with-managing-asset-or-location-availability | Asset availability patterns |
| **IBM Maximo Scheduler** | Search: "IBM Maximo Maintenance Scheduler" | Industry standard reference |

### Design Philosophy Sources

| Source | Purpose |
|--------|---------|
| **Linear App** | Modern aesthetic, dark mode, typography |
| **JetBrains Fleet (Islands UI)** | Enterprise layout density with clarity |
| **Google Maps** | Navigation fluidity (zoom/drag paradigm) |

---

## Issues to Fix

### CRITICAL (Block implementation)

1. **Tech Stack Mismatch**: Change Astro.js → Vite + React 18
2. **Reference Images Low Value**: Add new sources above, demote deck.gl geospatial
3. **Sandbox Mode Vague**: Add detailed specification with state machine

### HIGH (Quality impact)

4. **File Structure Wrong**: Update to match actual `apps/canvas/src/`
5. **RFQ Solutions Abstract**: Connect each pain point to specific screen/component
6. **Storybook Phases Overengineered**: Simplify for demo focus

### MEDIUM (Polish)

7. **Islands UI Pattern Not Explained**: Add concrete layout specs from JetBrains Fleet
8. **Post-Demo Roadmap Missing**: Add "Phase 2" section for future features

---

## Revised Document Structure

### Part 1: Vision & RFQ Mapping
- Pain points → visual solutions → screen reference
- Demo focus: Planning View + Sandbox Mode
- Post-demo roadmap

### Part 2: Moodboard (REWRITE NEEDED)
**Primary Sources:**
- Epicflow (what-if, pipeline)
- Dime Scheduler (enterprise scheduling)
- AVS Demo (single pane)
- DHTMLX Gantt D3 (rendering)

**Secondary Sources:**
- Linear (aesthetic)
- JetBrains Fleet (Islands layout)
- screen-*.png (internal inspiration)

**Remove/Demote:**
- deck.gl geospatial images (irrelevant)
- Railnova splash page
- Linear marketing pages

### Part 3: Design System (Keep)
- Colors, typography, spacing already defined

### Part 4: Application Shell (Update)
- Correct tech stack
- Update file structure to reality

### Part 5: Planning View (Enhance)
- Link each LOD to reference images
- Add semantic zoom transitions detail

### Part 6: Sandbox Mode (MAJOR REWRITE)
- XState state machine diagram
- localStorage persistence schema
- Comparison algorithm
- Undo/redo stack
- Conflict detection rules
- "Apply to Baseline" logic

### Part 7: Components (Keep)
- TaskBlock, KPICard, AlertBanner defined

### Part 8: Data Structures (Enhance)
- ScenarioChange edge cases
- Delta calculation formulas

### Part 9: Implementation (REWRITE)
- Correct: Vite + React 18 + deck.gl + XState
- Simplified Storybook phases
- Demo-critical vs deferred features

### Part 10: Roadmap (NEW)
- Phase 1: Demo (Planning + Sandbox)
- Phase 2: Post-demo features
- Phase 3: Production (integration, reports, etc.)

---

## Execution Steps

### Immediate (Before Context Limit)

1. **Exit plan mode**
2. **Update claude-progress.txt** with all findings and new references
3. **Update features.json** with DESIGN-REVISION task

### Next Session

4. Fetch new reference images (Epicflow, Dime Scheduler screenshots)
5. Rewrite DESIGN_SPEC.md Section 2 (Moodboard)
6. Correct tech stack throughout document
7. Add detailed Sandbox Mode specification
8. Add roadmap section

---

## Files to Modify

| File | Action |
|------|--------|
| `claude-progress.txt` | Save all analysis + new references |
| `features.json` | Add DESIGN-REVISION task |
| `docs/DESIGN_SPEC.md` | Major revision (next session) |
| `design/references/` | Add new screenshots (next session) |

---

## Key New References to Capture

```
MUST SCREENSHOT:
1. https://www.epicflow.com/features/what-if/ (what-if toggle, delta panel)
2. https://www.epicflow.com/wp-content/uploads/2023/10/pipeline-implement.png
3. https://www.dimescheduler.com/ (video + screenshots)
4. https://avs.auto/demo/index.html (single pane example)
5. https://dhtmlx.github.io/demo-gantt-d3/index_1.html
6. Google Image Search: "IBM Maximo Maintenance Scheduler"
```

---

## Demo Focus

### MUST Work Perfectly
1. Semantic Zoom (MACRO→MESO→MICRO)
2. Sandbox Mode Toggle (violet accent)
3. Delta Metrics (impact visualization)
4. Visual polish (modern, not amateur)

### Can Be Mock/Fake
1. Mileage calculations (hardcoded)
2. Reports
3. Notifications
4. Maximo integration

---

*Status: READY TO SAVE PROGRESS TO HARNESS*
*Next Action: Exit plan mode, update harness files immediately*

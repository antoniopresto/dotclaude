# MMS v1.0 Reset: Master Plan

> **Objective**: Consolidate all learnings from 6 projects into a definitive v1.0 specification and clean codebase
> **Methodology**: Scientific knowledge extraction with 20+ parallel agents
> **Output**: Single spec + PatternFly v6 canvas app + clean harness

---

## Executive Summary

This is a **meta-project** with two distinct phases:
1. **KNOWLEDGE EXTRACTION** - Systematically mine 6 repositories for validated learnings
2. **CONSOLIDATION & BUILD** - Create final specification and clean v1.0 codebase

**Critical Principle**: VERIFY EVERYTHING. Documentation claims must be validated against code and git history. AI-generated "complete" markers are suspect until proven.

---

## Phase 0: Preparation (Session 1)

### 0.1 Backup Current State
```bash
# Create backup branch
git checkout -b backup/pre-v1-reset-$(date +%Y%m%d)
git push origin backup/pre-v1-reset-$(date +%Y%m%d)

# Archive harness
cp -r .harness .harness.backup.$(date +%Y%m%d)
```

### 0.2 Create Extraction Infrastructure
- Create `.harness/extraction/` folder for agent outputs
- Create template for agent reports
- Setup parallel execution tracking

---

## Phase 1: Parallel Knowledge Extraction (20+ Agents)

### Architecture: Hub-and-Spoke Model

```
                    ┌─────────────────┐
                    │  ORCHESTRATOR   │
                    │  (Main Agent)   │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
    ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
    │ WAVE 1  │         │ WAVE 2  │         │ WAVE 3  │
    │ Extract │         │ Verify  │         │ Decide  │
    └────┬────┘         └────┬────┘         └────┬────┘
         │                   │                   │
    ┌────┴────┐         ┌────┴────┐         ┌────┴────┐
    │ 8 agents│         │ 6 agents│         │ 4 agents│
    │ parallel│         │ parallel│         │ debate  │
    └─────────┘         └─────────┘         └─────────┘
```

### Wave 1: Raw Knowledge Extraction (8 agents in parallel)

| Agent ID | Target | Focus |
|----------|--------|-------|
| EXT-01 | system/apps/canvas | Verify what ACTUALLY works (run code, check renders) |
| EXT-02 | system/packages/toolkit | Document actual API (not claimed API) |
| EXT-03 | system/docs/*.md | Extract unique domain knowledge |
| EXT-04 | deck/ | Extract harness research, POC learnings |
| EXT-05 | MFC/ | Extract BMAD methodology, solver architecture |
| EXT-06 | projects/* | Mine historical decisions and pivots |
| EXT-07 | Git history (all repos) | Key commits, decision points, reverts |
| EXT-08 | design/*.png + references | Visual specification catalog |

**Agent Output Format**:
```markdown
# Extraction Report: [Target]

## Verified Working Features
- [Feature]: [Evidence: commit/test/screenshot]

## Claimed But Unverified
- [Claim]: [Documentation location] - [Status: untested/broken/partial]

## Unique Knowledge
- [Insight]: [Source]

## Technology Decisions
- [Decision]: [Rationale]: [Outcome]

## Recommendations
- [What to keep/discard/investigate]
```

### Wave 2: Cross-Validation (6 agents in parallel)

| Agent ID | Focus |
|----------|-------|
| VAL-01 | Cross-reference WebGL claims across system/deck |
| VAL-02 | Compare state management approaches (toolkit vs @belt/tools) |
| VAL-03 | Verify performance claims (60fps, GC optimization) |
| VAL-04 | Validate domain knowledge (ECM, RAMS, EN 15380) via web research |
| VAL-05 | Compare PatternFly v6 vs BlueprintJS for MMS use case |
| VAL-06 | Evaluate 2D game frameworks mentioned (find and assess) |

### Wave 3: Decision Synthesis (4 agents - debate format)

| Agent ID | Perspective |
|----------|-------------|
| DEC-01 | Advocate for SIMPLICITY (minimal features, quick delivery) |
| DEC-02 | Advocate for COMPLETENESS (all learnings preserved) |
| DEC-03 | Advocate for PERFORMANCE (60fps, WebGL optimization) |
| DEC-04 | SYNTHESIZER (resolve conflicts, produce final recommendations) |

**Debate Protocol**:
1. Each advocate writes position paper (500 words max)
2. Cross-examination: each reviews others' positions
3. Synthesizer produces consensus document with rationale

---

## Phase 2: Specification Writing

### 2.1 Document Structure Decision

Based on Wave 3 synthesis, choose between:

**Option A: Single Comprehensive Spec** (~3000-4000 lines)
```
docs/SPECIFICATION.md
├── Part I: Domain & Business (ECM, RAMS, Railway standards)
├── Part II: UX & Design (PatternFly v6 tokens, components)
├── Part III: Architecture (Canvas, State, Solver)
├── Part IV: Implementation (Storybook, API, Testing)
└── Appendices (Visual references, seed data)
```

**Option B: Modular Documentation** (5-7 focused files)
```
docs/
├── DOMAIN.md           # Railway knowledge, ECM, RAMS
├── UX.md               # PatternFly integration, design system
├── ARCHITECTURE.md     # Canvas, state management, solver
├── CANVAS.md           # Semantic zoom implementation details
├── DEMO.md             # Presentation strategy, wow moments
└── DEVELOPMENT.md      # Setup, testing, deployment
```

### 2.2 Writing Agents (3 parallel)

| Agent | Responsibility |
|-------|----------------|
| SPEC-01 | Domain & Business sections |
| SPEC-02 | Technical Architecture sections |
| SPEC-03 | UX & Implementation sections |

Each agent receives:
- Extraction reports from Phase 1
- Validation reports from Wave 2
- Decision document from Wave 3

---

## Phase 3: Technology Stack Finalization

### 3.1 Verified Stack (based on extraction)

| Layer | Technology | Status | Alternative |
|-------|------------|--------|-------------|
| UI Framework | PatternFly v6 | **NEW** | - |
| State | @belt/tools | Verified npm | - |
| Canvas | TBD (after Wave 2) | Evaluate R3F vs deck.gl vs 2D engines | - |
| Build | Vite 5.x | Proven | - |
| Runtime | Bun | Proven | - |
| Testing | Playwright + Vitest | Proven | - |

### 3.2 Canvas Technology Decision Tree

```
IF (R3F semantic zoom is verified working)
  AND (60fps confirmed with evidence)
  THEN → Keep R3F 8.x

ELSE IF (deck.gl POC has better results)
  THEN → Migrate to deck.gl

ELSE IF (2D game engine found and viable)
  THEN → Evaluate for simpler use case

ELSE → Research new options (PixiJS, Konva, etc.)
```

---

## Phase 4: Repository Cleanup

### 4.1 Files to Remove
- `packages/toolkit/` - Replaced by npm @belt/tools
- `packages/harness-orchestrator/` - Not needed for v1.0
- `packages/harness-dashboard/` - Not needed for v1.0
- `docs/*.md` (all except final SPECIFICATION.md)
- `agent_docs/` - Consolidated into spec
- `scripts/parallel-*.ts` - Phase 2 tooling
- `design/reference/*.html` - POC served its purpose

### 4.2 Files to Preserve
- `apps/canvas/` - Clean and update
- `design/*.png` - Visual references
- `.harness/` - New v1.0 harness
- Git history - Never rewrite

### 4.3 Structure After Cleanup
```
system/
├── apps/
│   └── canvas/                # PatternFly + Canvas app
│       ├── src/
│       │   ├── components/    # PatternFly UI components
│       │   ├── canvas/        # WebGL rendering
│       │   ├── state/         # @belt/tools slices
│       │   └── stories/       # Storybook stories
│       ├── .storybook/
│       └── package.json
├── docs/
│   └── SPECIFICATION.md       # Single source of truth
├── design/
│   └── *.png                  # Visual references
├── .harness/
│   ├── progress.txt           # Fresh v1.0 tracking
│   ├── features.json          # v1.0 feature list
│   └── BACKUP_PRE_V1/         # Archived old harness
├── CLAUDE.md                  # Updated for v1.0
└── package.json               # Simplified root
```

---

## Phase 5: New Harness Setup

### 5.1 Features for v1.0 (Phased)

**Phase A: Canvas Foundation**
- [ ] F001: Vite + React 18 + PatternFly v6 scaffold
- [ ] F002: Storybook 8 setup with PatternFly theme
- [ ] F003: @belt/tools state machine integration
- [ ] F004: Canvas component (accepts data props)
- [ ] F005: MacroLayer (heatmap view)
- [ ] F006: MesoLayer (task blocks)
- [ ] F007: MicroLayer (detailed cards)
- [ ] F008: LOD transitions (smooth crossfade)
- [ ] F009: Pan/Zoom controls
- [ ] F010: Performance target (60fps verified)

**Phase B: UI Integration**
- [ ] F011: TrainSidebar (PatternFly Table)
- [ ] F012: TimelineHeader component
- [ ] F013: Minimap component
- [ ] F014: TaskDetailsPanel (PatternFly Drawer)
- [ ] F015: Keyboard navigation

**Phase C: Solver Integration**
- [ ] F016: Mock API service
- [ ] F017: Real solver connection
- [ ] F018: Allocation workflow
- [ ] F019: What-If simulation
- [ ] F020: Demo mode with fallbacks

### 5.2 Harness Protocol

```
READ .harness/progress.txt → Understand current state
READ .harness/features.json → Find next feature
VERIFY → Check if previous feature actually works (test!)
IMPLEMENT → One feature only
TEST → Storybook + Playwright screenshot
COMMIT → Atomic, mergeable state
UPDATE → progress.txt with evidence
STOP → Leave codebase production-ready
```

---

## Execution Timeline

### Session 1: Phase 0 + Wave 1 Launch
- Backup and prepare infrastructure
- Launch 8 extraction agents in parallel
- Collect initial reports

### Session 2: Wave 1 Complete + Wave 2 Launch
- Review extraction reports
- Launch 6 validation agents
- Begin cross-referencing

### Session 3: Wave 2 Complete + Wave 3 Debate
- Review validation reports
- Launch 4 decision agents
- Facilitate debate protocol

### Session 4: Specification Writing
- Launch 3 spec writing agents
- Consolidate into final document

### Session 5: Repository Cleanup
- Execute cleanup plan
- Update CLAUDE.md
- Setup new harness

### Session 6: Canvas Foundation (F001-F005)
- Begin actual implementation
- PatternFly scaffold
- Initial canvas component

### Session 7+: Continue Feature Implementation
- Follow harness protocol
- One feature per session

---

## Critical Success Factors

1. **VERIFY BEFORE TRUST** - Every claim must have evidence (commit, test, screenshot)
2. **PARALLEL EXTRACTION** - 20+ agents maximize knowledge capture
3. **DEBATE FOR DECISIONS** - Multiple perspectives prevent blind spots
4. **PHASED IMPLEMENTATION** - Canvas → UI → Solver → Integration
5. **CLEAN STATE ALWAYS** - Every session leaves codebase mergeable

---

## Key Files to Analyze First

| File | Purpose | Priority |
|------|---------|----------|
| `system/apps/canvas/src/App.tsx` | Current canvas implementation | P0 |
| `system/apps/canvas/src/canvas/*.tsx` | LOD layers | P0 |
| `deck/docs/DESIGN_SPEC.md` | Alternative approach | P0 |
| `MFC/docs/MMS_COMPLETE_SPECIFICATION.md` | Domain knowledge | P1 |
| `system/.harness/progress.txt` | Decision history | P1 |
| Git logs (all repos) | True history | P1 |

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Canvas doesn't actually work | EXT-01 will verify with actual tests |
| @belt/tools API differs | VAL-02 will verify against npm package |
| PatternFly incompatible | VAL-05 will evaluate before commitment |
| Too much parallelism | Orchestrator agent manages and synthesizes |
| Knowledge loss | Extraction reports preserve all findings |

---

## Sources

- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [PatternFly v6 Getting Started](https://www.patternfly.org/get-started/develop/)
- [PatternFly React GitHub](https://github.com/patternfly/patternfly-react)
- [PatternFly v6 Upgrade Guide](https://www.patternfly.org/get-started/upgrade/)

---

*Plan created: 2026-01-05*
*Status: AWAITING APPROVAL*

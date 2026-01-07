# MMS V1.0 GENESIS - Execution Plan

## Current State Analysis

### Git Status
- Branch: `main` (1 commit ahead of origin)
- Last commits show: genesis docs added, spec updates, toolkit performance fixes, reverts of failed reset attempts

### Genesis Documents Summary
Two files in `./genesis/`:

1. **MMS_V1_GENESIS.md**: 8-phase migration plan to consolidate 6 MMS projects into V1.0
   - Phase 1: Territory Mapping
   - Phase 2: Parallel Knowledge Extraction (8-10 agents)
   - Phase 3: Technology Research (PatternFly, @belt/tools, canvas tech)
   - Phase 4: Cross-Validation
   - Phase 5: Decision Debates
   - Phase 6: Specification Writing (~3000-4000 lines)
   - Phase 7: Repository Cleanup
   - Phase 8: Implementation

2. **PROMPT_WITH_ERRORS.md**: Alternative version with noted errors (mentions Portuguese naming for Dubai project)

### Current Harness State (`.harness/`)
- `features.json`: 1096 lines, ALL features marked `passes: true`
- `progress.txt`: Session history showing completed work
- Additional docs: GEMINI_REVIEW_EVALUATION.md, REVIEW_PLAN.md, SPEC_UPDATE_PLAN.md

### Key Technical Conflicts Identified

| Aspect | Genesis Says | Current State | Resolution Needed |
|--------|-------------|---------------|-------------------|
| UI Framework | PatternFly v6 | BlueprintJS 6 (working) | Clarify migration intent |
| State Management | @belt/tools (npm) | @zazcart/toolkit (local) + @belt/tools (integrated) | packages/toolkit deletion? |
| Specification | ~3000-4000 lines | MMS_COMPLETE_SPECIFICATION.md (~8922 lines) | Consolidate or rewrite? |
| packages/toolkit | DELETE | Contains TOOLKIT-PERF-001 fixes | Migrate fixes to @belt/tools? |

### RFQ (Source of Truth) - Dubai Metro / Keolis MHI
- **Fleets**: 128 trains (49 Kinki Sharyo + 79 Alstom)
- **Depots**: Al Rashidiya (Red), Jebel Ali (Green)
- **Contract**: 12 years
- **Maintenance Levels**: A/B/C/D (PM1/PM2/HM/OVH)
- **Core Deliverables**: Mileage management, maintenance planning, allocation, simulation

---

## Critical Questions (NEED USER INPUT)

### Q1: Stack Migration Intent
The genesis documents propose migrating from BlueprintJS to PatternFly v6. However, the current app (`apps/canvas`) is fully functional with BlueprintJS 6.

**Options:**
1. Keep BlueprintJS 6 (working, no migration needed)
2. Migrate to PatternFly v6 (significant effort, ~1-2 weeks)
3. Evaluate both and decide based on requirements

### Q2: Scope of "Reset V1"
What does "reset" mean for this project?

**Options:**
1. **Harness Reset Only**: Archive old harness, create new features.json based on genesis phases
2. **Clean Baseline**: Keep working code, reset documentation and harness
3. **Full Reset**: Delete existing implementation, start fresh with genesis plan
4. **Consolidation Reset**: Merge genesis knowledge into existing codebase, reset harness for new phase

### Q3: packages/toolkit Handling
Genesis says to delete `packages/toolkit` and use `@belt/tools` from npm. However, `packages/toolkit` contains 7 critical performance fixes (TOOLKIT-PERF-001).

**Options:**
1. Contribute fixes to @belt/tools npm package, then delete local
2. Keep packages/toolkit as-is (ignore genesis instruction)
3. Verify @belt/tools@0.0.1 already has fixes, then delete

### Q4: Specification Consolidation
Current spec is ~8922 lines. Genesis target is ~3000-4000 lines.

**Options:**
1. Keep current spec as-is
2. Consolidate to ~3000-4000 lines (remove redundancy)
3. Rewrite from scratch using genesis extraction process

---

## Proposed Execution Plan (Pending User Answers)

### Step 0: Backup & Reset Harness
```bash
# Backup current harness
cp -r .harness .harness-backup-$(date +%Y%m%d)
git add .harness-backup-*
git commit -m "backup: pre-genesis harness state"

# Create new V1.0 harness structure
```

### Step 1: Update Genesis Docs
- Fix errors in PROMPT_WITH_ERRORS.md (Portuguese references for Dubai project)
- Add harness-first protocol to genesis docs
- Document that all work must be via harness

### Step 2: Create New features.json
Based on genesis phases, create new feature list with `passes: false`:
- GENESIS-001 to GENESIS-XXX for extraction/validation phases
- F-V1-001 to F-V1-XXX for implementation features

### Step 3: Initialize progress.txt
- Archive old progress
- Start fresh with V1.0 session logging

### Step 4: Execute Genesis Phases
Follow the 8-phase plan with commits at each milestone:
- Each sub-task registered in harness
- Commit after each completed task
- Update progress.txt continuously

---

## Files to Modify/Create

| File | Action | Purpose |
|------|--------|---------|
| `.harness/features.json` | Rewrite | V1.0 feature list |
| `.harness/progress.txt` | Archive + New | Reset session log |
| `genesis/MMS_V1_GENESIS.md` | Update | Add harness-first protocol |
| `genesis/PROMPT_WITH_ERRORS.md` | Fix | Correct errors |
| `CLAUDE.md` | Update | Reflect V1.0 conventions |

---

## Waiting for User Clarification

Before proceeding, I need answers to Q1-Q4 above to finalize the execution plan.

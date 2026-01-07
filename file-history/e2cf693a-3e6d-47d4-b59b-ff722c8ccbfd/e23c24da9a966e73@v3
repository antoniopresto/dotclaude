# Plan: BMAD v6 Compliance Audit & Enforcement System

## Part 1: BMAD v6 Compliance Audit

### Official BMAD v6 Source
**Repository:** https://github.com/bmad-code-org/BMAD-METHOD
**Version Installed:** 6.0.0-alpha.21
**Installation Date:** 2025-12-28T07:23:51.421Z

---

## Installation Verification

| Requirement | Status | Evidence |
|-------------|--------|----------|
| `_bmad/` folder structure | ✅ PASS | core, bmm, bmb, custom modules present |
| `_bmad-output/` artifacts folder | ✅ PASS | planning-artifacts, implementation-artifacts exist |
| `config.yaml` in each module | ✅ PASS | core/config.yaml, bmm/config.yaml present |
| Agent manifests | ✅ PASS | 15 agents in agent-manifest.csv |
| Workflow manifests | ✅ PASS | 42 workflows in workflow-manifest.csv |
| Custom module integration | ✅ PASS | 6 MMS-specific agents in _bmad/custom/ |

**Verdict: INSTALLATION COMPLIANT** ✅

---

## Phase Execution Verification

### Phase 0: Discovery (Optional)

| Workflow | Required | Status | Notes |
|----------|----------|--------|-------|
| `*brainstorm` | Optional | SKIPPED | Justified: MMS_DEMO_PLAYBOOK.md exists |
| `*research` | Optional | SKIPPED | Justified: Domain documented |
| `*create-product-brief` | Optional | SKIPPED | Justified: Playbook serves as brief |

**Verdict:** ✅ COMPLIANT - Phase 0 is optional, skip documented in bmm-workflow-status.yaml

---

### Phase 1: Planning

| Workflow | Required | Status | Output |
|----------|----------|--------|--------|
| `*create-prd` | **YES** | ✅ DONE | `_bmad-output/planning-artifacts/prd.md` (726 lines) |
| `*create-ux-design` | If UI exists | ✅ DONE | `_bmad-output/planning-artifacts/ux-design-specification.md` (594 lines) |

**Verdict:** ✅ COMPLIANT

---

### Phase 2: Solutioning

| Workflow | Required | Status | Output |
|----------|----------|--------|--------|
| `*create-architecture` | **YES** | ✅ DONE | `_bmad-output/planning-artifacts/architecture.md` (703 lines) |
| `*create-epics-and-stories` | **YES** | ✅ DONE | `_bmad-output/planning-artifacts/epics.md` (890 lines) |
| `*testarch-test-design` | Recommended | ⚠️ NOT DONE | Status: "recommended" - never executed |
| `*check-implementation-readiness` | **YES** | ✅ DONE | `_bmad-output/planning-artifacts/implementation-readiness-report.md` (227 lines) |

**Verdict:** ⚠️ PARTIAL COMPLIANCE - Missing recommended `*testarch-test-design`

---

### Phase 3: Sprint Planning

| Workflow | Required | Status | Output |
|----------|----------|--------|--------|
| `*sprint-planning` | **YES** | ✅ DONE | `_bmad-output/implementation-artifacts/sprint-status.yaml` (113 lines) |

**Verdict:** ✅ COMPLIANT

---

### Phase 4: Implementation (CRITICAL GAPS FOUND)

| Workflow | Required | Status | Evidence |
|----------|----------|--------|----------|
| `*create-story` (per story) | **YES** | ❌ **NEVER EXECUTED** | No story files exist in implementation-artifacts/ |
| `*dev-story` (per story) | **YES** | ❌ **NEVER EXECUTED** | Requires story files which don't exist |
| `*code-review` | Recommended | ⚠️ AD-HOC | Session 006 did manual review, not `*code-review` workflow |
| `*retrospective` (per epic) | Optional | ❌ NOT DONE | All 6 marked "optional", none executed |

**CRITICAL FINDING: Story Files Missing**

```bash
# Expected files in _bmad-output/implementation-artifacts/:
$ ls _bmad-output/implementation-artifacts/
1-1-setup-monorepo-structure.md      # Story file with tasks, ACs, Dev Notes
1-2-configure-database-schema.md     # Story file with tasks, ACs, Dev Notes
... (33 story files total)
sprint-status.yaml

# Actual files:
$ ls _bmad-output/implementation-artifacts/
sprint-status.yaml                   # ONLY THIS FILE EXISTS
```

**BMAD Phase 4 Workflow (Expected vs Actual):**

```yaml
# Expected BMAD v6 Flow (per story):
1. *create-story → Creates {story_key}.md with tasks, ACs, Dev Notes
2. Story status: backlog → ready-for-dev
3. *dev-story → Implements story following story file
4. Story status: ready-for-dev → in-progress → review
5. *code-review → Reviews implementation, adds findings to story file
6. Story status: review → done

# Actual Execution:
1. ❌ *create-story NEVER run - no story files created
2. ❌ Stories jumped directly: backlog → done
3. ❌ *dev-story NEVER run - implementation was ad-hoc
4. ⚠️ Manual code review done, not via *code-review workflow
```

**Verdict:** ❌ **CRITICAL NON-COMPLIANCE** - Phase 4 workflows completely bypassed

---

## Gap Analysis

### GAP 1: Missing Story Files (CRITICAL)
- **What:** `*create-story` workflow NEVER executed for any of 33 stories
- **Impact:**
  - No story files with tasks, ACs, Dev Notes
  - No traceability between requirements and implementation
  - `*dev-story` workflow cannot function without story files
- **Severity:** 🔴 **CRITICAL**
- **Evidence:** `ls _bmad-output/implementation-artifacts/` shows only `sprint-status.yaml`
- **Remediation Options:**
  1. Create 33 story files retroactively (HIGH effort, ~2-3 hours)
  2. Accept current state, enforce for future stories (LOW effort)
  3. Create summary story files with completion evidence (MEDIUM effort)

### GAP 2: dev-story Workflow Never Executed (CRITICAL)
- **What:** `*dev-story` workflow NEVER executed - all implementation was ad-hoc
- **Impact:**
  - No red-green-refactor cycle enforced
  - No task-by-task progress tracking
  - No Dev Agent Record with implementation notes
  - Sprint-status state machine bypassed
- **Severity:** 🔴 **CRITICAL**
- **Evidence:** Sprint-status shows `backlog → done` (skipped `ready-for-dev`, `in-progress`, `review`)
- **Remediation:** Accept for current sprint, enforce for future development

### GAP 3: code-review Workflow Not Used (HIGH)
- **What:** Session 006 did manual "adversarial review" but not via `*code-review` workflow
- **Impact:**
  - Review findings not added to story files
  - No formal review record in BMAD artifacts
  - bmm-workflow-status.yaml not updated
- **Severity:** 🟠 **HIGH**
- **Remediation:** Document the review that was done, update workflow status

### GAP 4: Missing Test Design Workflow (MEDIUM)
- **What:** `*testarch-test-design` never executed
- **Impact:** No formalized test strategy document
- **Severity:** 🟡 **MEDIUM** (recommended, not required)
- **Remediation:** Execute `*testarch-test-design` workflow

### GAP 5: Missing Retrospectives (LOW)
- **What:** No `*retrospective` run for any of the 6 epics
- **Impact:** No lessons learned documented
- **Severity:** 🟢 **LOW** (optional workflow)
- **Remediation:** Run consolidated retrospective

---

## BMAD v6 Compliance Score (REVISED)

| Category | Weight | Score | Weighted | Notes |
|----------|--------|-------|----------|-------|
| Installation | 15% | 100% | 15% | ✅ All modules installed correctly |
| Phase 0 (Discovery) | 10% | 100% | 10% | ✅ Skipped with documentation |
| Phase 1 (Planning) | 15% | 100% | 15% | ✅ PRD + UX Design complete |
| Phase 2 (Solutioning) | 20% | 80% | 16% | ⚠️ test-design recommended but not done |
| Phase 3 (Sprint Planning) | 10% | 100% | 10% | ✅ sprint-status.yaml created |
| Phase 4 (Implementation) | 30% | 20% | 6% | ❌ create-story/dev-story NEVER executed |

**TOTAL COMPLIANCE: 72%** ⚠️

**Assessment:** Project is **PARTIALLY COMPLIANT** with BMAD v6.
- Phases 0-3: Fully compliant with all required artifacts
- Phase 4: **CRITICAL NON-COMPLIANCE** - Workflows bypassed entirely

**Root Cause:** Implementation was done ad-hoc without following the `*create-story` → `*dev-story` → `*code-review` workflow chain. The code works, but the process wasn't followed.

---

## Part 2: Remediation Plan

### Decision Required: How to Handle Phase 4 Non-Compliance?

**Option A: Accept Current State (Recommended for Demo)**
- Accept that Phase 4 was done ad-hoc
- Document the deviation in bmm-workflow-status.yaml
- Implement enforcement for FUTURE development
- Compliance: Remains at 72%

**Option B: Partial Remediation**
- Create summary story files documenting what was done
- Run `*code-review` on existing code (will create findings file)
- Run `*retrospective` for lessons learned
- Compliance: Could reach ~85%

**Option C: Full Retroactive Compliance (NOT Recommended)**
- Create all 33 story files with full content
- Update sprint-status with correct state transitions
- Document all implementation decisions
- Time: ~4-6 hours
- Compliance: Could reach ~95%

---

### Immediate Actions (P0) - If Option A Selected

1. **Document Phase 4 Deviation**
   - Update bmm-workflow-status.yaml with honest status
   - Add note explaining ad-hoc implementation approach
   - Mark current sprint as complete despite process deviation

2. **Implement Enforcement System**
   - Prevent future ad-hoc implementations
   - Require `*create-story` before any new development
   - Block edits without workflow context

### Recommended Actions (P1) - If Option B Selected

3. **Execute `*testarch-test-design`**
   - Agent: tea (Test Architect)
   - Output: Test design document
   - Time: ~15 min

4. **Run `*code-review` on Existing Code**
   - Creates formal review record
   - Documents any issues found
   - Time: ~20 min

5. **Run Consolidated `*retrospective`**
   - Document lessons learned from all 6 epics
   - Include finding about workflow bypass
   - Time: ~10 min

### Low Priority Actions (P2)

6. **Create Summary Story Documentation**
   - Optional: Create lightweight story summaries
   - Link to git commits as evidence of completion
   - Time: ~1 hour

---

## Part 3: Enforcement System (Original Plan)

### Problem Statement

The current hook system has **critical gaps** that allow bypassing BMAD v6 protocol:

1. **bmad-enforcement.sh is advisory-only** (always exits 0)
2. **Naive keyword detection** causes false positives/negatives
3. **No blocking on code edits** without workflow approval
4. **end-of-turn-check.sh doesn't block** on failures

### Current Hook Analysis

| Hook | Blocking? | Issue |
|------|-----------|-------|
| SessionStart | No | ✅ OK - informational |
| UserPromptSubmit | **No** | ❌ Should block implementation requests |
| PreToolUse (Write/Edit) | Only package.json | ❌ Should require workflow context |
| Stop | **No** | ❌ Should block if TypeScript errors |

### Proposed 3-Layer Enforcement

#### Layer 1: Smarter UserPromptSubmit Detection

**File:** `.claude/hooks/bmad-enforcement.sh`

```bash
#!/bin/bash
# BMAD v6 Enforcement Hook - UserPromptSubmit

USER_PROMPT=$(cat)

# Whitelist - always allowed without workflow
ALLOWED="research|explore|explain|what|how|why|show|read|list|find|search|doc|test|run|help|status"

# Implementation triggers - require workflow
IMPL="implement|create|add|fix|build|develop|code|write|make|update|change|modify|refactor|delete|remove"

# BMAD workflow keywords - allow if present
BMAD="workflow|dev-story|create-tech-spec|code-review|testarch|sprint|bmad|\*"

# Check if implementation request
if echo "$USER_PROMPT" | grep -iE "$IMPL" > /dev/null 2>&1; then
    # Allow if BMAD workflow mentioned
    if echo "$USER_PROMPT" | grep -iE "$BMAD" > /dev/null 2>&1; then
        exit 0
    fi
    # Allow if just research/exploration
    if echo "$USER_PROMPT" | grep -iE "$ALLOWED" > /dev/null 2>&1; then
        exit 0
    fi
    # BLOCK - implementation without workflow
    cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ BMAD v6 ENFORCEMENT - BLOCKED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Implementation request detected without BMAD workflow.

To proceed, use one of:
  *workflow-status  - Check current phase
  *dev-story        - Implement a story
  *quick-dev        - Quick implementation
  *code-review      - Review code

Or add BYPASS to your message to override.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    # Check for bypass
    if echo "$USER_PROMPT" | grep -i "BYPASS" > /dev/null 2>&1; then
        exit 0  # Allow with bypass
    fi
    exit 2  # BLOCK
fi

exit 0
```

#### Layer 2: Workflow Context Tracking

**File:** `.claude/hooks/workflow-context.json`

```json
{
  "active_workflow": null,
  "story_id": null,
  "allowed_files": ["*"],
  "started_at": null,
  "expires_at": null
}
```

**File:** `.claude/hooks/require-workflow-context.sh`

```bash
#!/bin/bash
# PreToolUse hook - require workflow context for source files

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip non-source files
if [[ ! "$FILE_PATH" =~ ^apps/.*(\.ts|\.tsx|\.py)$ ]]; then
    exit 0
fi

# Check workflow context
CONTEXT_FILE="$CLAUDE_PROJECT_DIR/.claude/hooks/workflow-context.json"
if [ -f "$CONTEXT_FILE" ]; then
    WORKFLOW=$(jq -r '.active_workflow' "$CONTEXT_FILE")
    if [ "$WORKFLOW" != "null" ] && [ -n "$WORKFLOW" ]; then
        exit 0  # Workflow active, allow
    fi
fi

# No workflow context - warn (advisory mode)
echo "⚠️ Editing source file without active workflow context"
exit 0
```

#### Layer 3: End-of-Turn Validation

**File:** `.claude/hooks/end-of-turn-check.sh` (enhanced)

```bash
#!/bin/bash
# Stop hook - validate session end

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ERRORS=0

# Check TypeScript errors
if command -v tsc &> /dev/null; then
    TS_ERRORS=$(cd "$PROJECT_DIR/apps/web" && tsc --noEmit 2>&1 | grep -c "error TS" || echo "0")
    if [ "$TS_ERRORS" -gt 0 ]; then
        echo "⚠️ TypeScript errors: $TS_ERRORS"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Check progress file updated today
PROGRESS_FILE="$PROJECT_DIR/claude-progress.txt"
if [ -f "$PROGRESS_FILE" ]; then
    TODAY=$(date +%Y-%m-%d)
    if ! grep -q "$TODAY" "$PROGRESS_FILE"; then
        echo "⚠️ claude-progress.txt not updated today"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Report status (advisory mode)
if [ $ERRORS -gt 0 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️ Session end warnings: $ERRORS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

exit 0  # Advisory mode - don't block
```

---

## Files to Modify

| File | Action | Priority |
|------|--------|----------|
| `.claude/hooks/bmad-enforcement.sh` | Rewrite with blocking + bypass | P0 |
| `.claude/hooks/workflow-context.json` | Create new | P1 |
| `.claude/hooks/require-workflow-context.sh` | Create new | P1 |
| `.claude/hooks/end-of-turn-check.sh` | Enhance validation | P1 |
| `.claude/settings.json` | Add new hook configurations | P0 |
| `_bmad-output/bmm-workflow-status.yaml` | Update with code-review status | P0 |

---

## Execution Order

**SELECTED: Option C - Full Retroactive Compliance**
User requirement: Execute the correct flow for each step, not just create story files.

---

### Phase A: Test Design (Pre-requisite)

1. **Execute `*testarch-test-design`**
   - Creates system-level test strategy document
   - Required before reviewing implementation
   - Output: `_bmad-output/test-design-system.md`

---

### Phase B: Story Files Creation (Per Epic)

For each of the 6 epics, execute the full story creation flow:

**Per Epic Process (repeat for Epic 1-6):**

2. **For each story in epic:**
   ```
   a) Run *create-story
      - Creates {story_key}.md with:
        - Tasks/Subtasks from epics.md
        - Acceptance Criteria
        - Dev Notes with context
      - Updates sprint-status: backlog → ready-for-dev

   b) Update story file with implementation evidence:
      - Mark all tasks as [x] (code exists)
      - Add File List with actual files created
      - Add Dev Agent Record with completion notes
      - Add Change Log with git commits

   c) Run *dev-story (for validation only)
      - Detects all tasks complete
      - Runs completion sequence
      - Updates sprint-status: ready-for-dev → in-progress → review
   ```

**Estimated time per story:** ~5-10 minutes
**Total for 33 stories:** ~3-5 hours

---

### Phase C: Code Review (Per Epic)

3. **For each epic, run `*code-review`**
   - Adversarial review of all story implementations
   - Creates review findings in story files
   - Updates stories with [AI-Review] tasks if issues found
   - After review: story status → done

**Estimated time per epic:** ~15-20 minutes
**Total for 6 epics:** ~1.5-2 hours

---

### Phase D: Retrospectives

4. **Run `*retrospective` for each epic**
   - Document lessons learned
   - Include finding about original workflow bypass
   - Create retrospective report
   - Update sprint-status: epic-X-retrospective: done

---

### Phase E: Enforcement System (Prevent Future Issues)

5. Rewrite bmad-enforcement.sh with blocking + BYPASS
6. Create workflow-context.json and require-workflow-context.sh
7. Enhance end-of-turn-check.sh to check for story file existence
8. Update settings.json with new hooks
9. Test enforcement system

---

### Phase F: Final Validation

10. **Verify all artifacts created:**
    ```bash
    ls _bmad-output/implementation-artifacts/
    # Should show: 33 story files + sprint-status.yaml
    ```

11. **Run `*workflow-status` to confirm 100% compliance**

12. **Update bmm-workflow-status.yaml with final state**

---

## Success Criteria (Option C Selected)

### Phase A: Test Design
- [ ] `*testarch-test-design` executed
- [ ] `test-design-system.md` created in `_bmad-output/`

### Phase B: Story Files (33 stories)
- [ ] All 33 story files created via `*create-story`
- [ ] Each story file contains: Tasks, ACs, Dev Notes, File List
- [ ] All tasks marked as [x] with implementation evidence
- [ ] Sprint-status shows correct state transitions

### Phase C: Code Reviews (6 epics)
- [ ] `*code-review` executed for each epic
- [ ] Review findings documented in story files
- [ ] All stories status updated to "done"

### Phase D: Retrospectives (6 epics)
- [ ] `*retrospective` executed for each epic
- [ ] Lessons learned documented
- [ ] Sprint-status shows `epic-X-retrospective: done`

### Phase E: Enforcement System
- [ ] bmad-enforcement.sh blocks ad-hoc implementations
- [ ] BYPASS mechanism works for legitimate overrides
- [ ] workflow-context.json tracks active workflow
- [ ] end-of-turn-check.sh validates story file existence

### Phase F: Final Validation
- [ ] 33 story files exist in `implementation-artifacts/`
- [ ] `*workflow-status` shows 100% compliance
- [ ] bmm-workflow-status.yaml fully updated
- [ ] BMAD v6 compliance score reaches ~95%

---

## Estimated Total Time

| Phase | Time Estimate |
|-------|---------------|
| A: Test Design | 15 min |
| B: Story Files (33 stories) | 3-5 hours |
| C: Code Reviews (6 epics) | 1.5-2 hours |
| D: Retrospectives (6 epics) | 1 hour |
| E: Enforcement System | 30 min |
| F: Final Validation | 15 min |
| **TOTAL** | **6-9 hours** |

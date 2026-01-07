# MMS V1.0 GENESIS: Meta-Harness Architecture

> **Critical Insight**: A complex migration task needs its own harness BEFORE any analysis begins.
> **Philosophy**: Unlimited agents/tokens. Quality over economy. Architecture over tactics.

---

## ABSOLUTE FIRST ACTION: Create Meta-Harness

**Why**: This migration will span multiple sessions. Without a harness, knowledge will be lost between context windows.

### Step 0.1: Backup Existing Harness
```bash
mkdir -p .harness/BACKUP_PROJECT_HARNESS
mv .harness/progress.txt .harness/BACKUP_PROJECT_HARNESS/
mv .harness/features.json .harness/BACKUP_PROJECT_HARNESS/
mv .harness/*.md .harness/BACKUP_PROJECT_HARNESS/ 2>/dev/null || true
```

### Step 0.2: Create Migration Harness Files
Create `.harness/MIGRATION_PROGRESS.md`:
```markdown
# MMS V1.0 GENESIS - Migration Progress

## Session 1: [DATE]
### Objective
Consolidate 6 repositories into single V1.0 codebase.

### Tasks Completed
- [ ] Backup existing harness
- [ ] Create migration harness
- [ ] Create extraction folder
- [ ] Launch extraction agents

### Findings
[To be updated during session]

### Next Session
[To be determined]
```

Create `.harness/MIGRATION_FEATURES.json`:
```json
{
  "project": "MMS V1.0 GENESIS",
  "phases": [
    {
      "id": "PHASE_0",
      "name": "Meta-Harness Setup",
      "tasks": [
        {"id": "M001", "name": "Backup existing harness", "passes": false},
        {"id": "M002", "name": "Create MIGRATION_PROGRESS.md", "passes": false},
        {"id": "M003", "name": "Create MIGRATION_FEATURES.json", "passes": false},
        {"id": "M004", "name": "Create _extraction/ folder", "passes": false}
      ]
    },
    {
      "id": "PHASE_1",
      "name": "Knowledge Extraction",
      "tasks": [
        {"id": "E001", "name": "Territory mapping agent", "passes": false},
        {"id": "E002", "name": "Canvas extraction agent", "passes": false},
        {"id": "E003", "name": "Domain extraction agent", "passes": false},
        {"id": "E004", "name": "Solver extraction agent", "passes": false},
        {"id": "E005", "name": "deck.gl extraction agent", "passes": false},
        {"id": "E006", "name": "Projects extraction agent", "passes": false},
        {"id": "E007", "name": "Git archaeology agent", "passes": false},
        {"id": "E008", "name": "Visual spec extraction agent", "passes": false}
      ]
    },
    {
      "id": "PHASE_2",
      "name": "Technology Research",
      "tasks": [
        {"id": "T001", "name": "PatternFly v6 research agent", "passes": false},
        {"id": "T002", "name": "@belt/tools API research agent", "passes": false},
        {"id": "T003", "name": "Canvas tech comparison agent", "passes": false}
      ]
    },
    {
      "id": "PHASE_3",
      "name": "Cross-Validation",
      "tasks": [
        {"id": "V001", "name": "Math formulas validation", "passes": false},
        {"id": "V002", "name": "Domain terms validation", "passes": false},
        {"id": "V003", "name": "Performance claims validation", "passes": false},
        {"id": "V004", "name": "Technology claims validation", "passes": false}
      ]
    },
    {
      "id": "PHASE_4",
      "name": "Decision Debates",
      "tasks": [
        {"id": "D001", "name": "Simplicity advocate position", "passes": false},
        {"id": "D002", "name": "Completeness advocate position", "passes": false},
        {"id": "D003", "name": "Performance advocate position", "passes": false},
        {"id": "D004", "name": "Synthesis document", "passes": false}
      ]
    },
    {
      "id": "PHASE_5",
      "name": "Specification Writing",
      "tasks": [
        {"id": "S001", "name": "Domain sections writer", "passes": false},
        {"id": "S002", "name": "Architecture sections writer", "passes": false},
        {"id": "S003", "name": "UX sections writer", "passes": false},
        {"id": "S004", "name": "Final editing pass", "passes": false}
      ]
    },
    {
      "id": "PHASE_6",
      "name": "Repository Cleanup",
      "tasks": [
        {"id": "R001", "name": "Create backup branch", "passes": false},
        {"id": "R002", "name": "Remove packages/ folder", "passes": false},
        {"id": "R003", "name": "Remove old docs", "passes": false},
        {"id": "R004", "name": "Update package.json", "passes": false},
        {"id": "R005", "name": "Clean canvas app", "passes": false},
        {"id": "R006", "name": "Create V1.0 harness", "passes": false},
        {"id": "R007", "name": "Update CLAUDE.md", "passes": false},
        {"id": "R008", "name": "Delete _extraction/", "passes": false},
        {"id": "R009", "name": "Commit V1.0 baseline", "passes": false}
      ]
    }
  ]
}
```

### Step 0.3: Create Extraction Folder
```bash
mkdir -p _extraction
```

---

## OBJECTIVE SYNTHESIS

**FROM** (6 fragmented repositories):
```
~/antonio/mms/
├── system/      # Production canvas app (R3F, BlueprintJS)
├── deck/        # deck.gl POC, harness research
├── MFC/         # Next.js + Solver, BMAD methodology
├── projects/    # Historical experiments
├── design/      # Visual references (9 images)
└── system_started/ # Bootstrap template
```

**TO** (clean V1.0 baseline):
```
~/antonio/mms/system/
├── apps/canvas/         # PatternFly v6 + Canvas
├── docs/SPECIFICATION.md  # Single source of truth
├── .harness/            # Fresh V1.0 features
└── CLAUDE.md            # Updated for V1.0
```

**Success Criteria**:
- ALL unique knowledge preserved in SPECIFICATION.md
- NO false claims (everything verified against code)
- PatternFly v6 + @belt/tools integrated
- Canvas renders 60fps (verified, not assumed)
- Zero unused code, zero outdated docs

---

## AGENT ORCHESTRATION ARCHITECTURE

### Principle 1: Unlimited Resources
- Use as many agents as needed
- Use as many tokens as needed
- Quality is the ONLY metric
- Never economize on thoroughness

### Principle 2: Disk-Based Memory
All agent outputs go to `_extraction/` folder:
```
_extraction/
├── 00_territory_map.md
├── 01_canvas_reality.md
├── 02_domain_knowledge.md
├── 03_solver_logic.md
├── 04_visualization_research.md
├── 05_experiments.md
├── 06_git_archaeology.md
├── 07_visual_spec.md
├── 10_patternfly_research.md
├── 11_belt_tools_api.md
├── 12_canvas_tech_comparison.md
├── 20_validation_math.md
├── 21_validation_domain.md
├── 22_validation_perf.md
├── 23_validation_tech.md
├── 30_debate_simplicity.md
├── 31_debate_completeness.md
├── 32_debate_performance.md
├── 35_synthesis_decisions.md
└── 99_final_notes.md
```

### Principle 3: Verify Before Trust
Every claim must have:
- **HYPOTHESIS**: What we believe
- **EVIDENCE**: File:line or commit hash
- **VERIFICATION**: How confirmed (ran code, screenshot, etc.)
- **STATUS**: VERIFIED or CLAIMED_UNVERIFIED

### Principle 4: Teach Concepts to Agents
Each agent prompt includes:
- Project context (what MMS is)
- Their specific mission
- Output format requirements
- Quality standards
- Where to write results

---

## AGENT PROMPT TEMPLATES

### Template: Extraction Agent
```markdown
# EXTRACTION AGENT: [TARGET]

## Project Context
MMS (Metro Mileage Management System) is a high-performance visualization
for railway fleet maintenance planning. It uses "Semantic Zoom" (like Google
Earth) to show 10 years of maintenance data for 50+ trains at 60fps.

We are consolidating 6 repositories into a single V1.0 codebase.

## Your Mission
Extract ALL unique knowledge from [TARGET DIRECTORY] that must be preserved.

## What to Extract
1. **Working Code**: What actually functions? (TEST IT, don't assume)
2. **Domain Knowledge**: Railway terms, regulations, math formulas
3. **Architecture Decisions**: Why was X chosen over Y?
4. **Failures**: What broke and how was it fixed?
5. **Unique IP**: Insights that don't exist elsewhere

## Output Format
For each finding:
```
### [Finding Title]
**HYPOTHESIS**: What I believe
**EVIDENCE**: File [path:line] or commit [hash]
**VERIFICATION**: [How confirmed]
**STATUS**: VERIFIED | CLAIMED_UNVERIFIED
**CONTENT**: [The actual knowledge]
```

## Quality Standard
- Do NOT trust documentation claims
- RUN code to verify functionality
- CHECK git history for reverts (indicates broken claims)
- USE unlimited tokens - thoroughness over brevity

## Output File
Write to: `_extraction/[OUTPUT_FILE].md`
```

### Template: Research Agent
```markdown
# RESEARCH AGENT: [TOPIC]

## Project Context
[Same as above]

## Your Mission
Research [TOPIC] thoroughly for MMS V1.0 integration.

## What to Research
1. Official documentation
2. GitHub repositories
3. API reference
4. Integration patterns
5. Compatibility with our stack

## Output Format
```
## [Topic] Research Summary

### Official Documentation
[Links and key points]

### API Reference
[Key functions/components we'll use]

### Integration Approach
[How to integrate with MMS]

### Compatibility Notes
[Any issues with React 18, WebGL, etc.]

### Recommendations
[What to use, what to avoid]
```

## Output File
Write to: `_extraction/[OUTPUT_FILE].md`
```

### Template: Validation Agent
```markdown
# VALIDATION AGENT: [FOCUS]

## Project Context
[Same as above]

## Your Mission
Cross-validate [FOCUS] across all extraction artifacts.

## What to Validate
1. Read all files in `_extraction/` that mention [FOCUS]
2. Compare claims from different sources
3. Identify CONFLICTS (different sources say different things)
4. Identify GAPS (knowledge that should exist but doesn't)
5. Confirm VERIFIED findings with additional evidence

## Output Format
```
## Validation: [Focus]

### Verified Findings
[Claims with multiple source confirmation]

### Conflicts Found
| Claim | Source A Says | Source B Says | Resolution |
|-------|---------------|---------------|------------|

### Gaps Identified
[Knowledge that's missing]

### Recommendations
[What to trust, what to investigate further]
```

## Output File
Write to: `_extraction/[OUTPUT_FILE].md`
```

### Template: Debate Agent
```markdown
# DEBATE AGENT: [PERSPECTIVE]

## Project Context
[Same as above]

## Your Mission
Argue for the [PERSPECTIVE] approach to MMS V1.0 decisions.

## Your Perspective: [SIMPLICITY | COMPLETENESS | PERFORMANCE]

SIMPLICITY: Argue for minimum viable demo, fast delivery, least complexity
COMPLETENESS: Argue for preserving all learnings, comprehensive spec
PERFORMANCE: Argue for 60fps non-negotiable, WebGL optimization first

## Debate Topics
1. Canvas technology choice (R3F vs deck.gl vs PixiJS)
2. Specification structure (single file vs modular)
3. V1.0 scope (canvas only vs full system)
4. PatternFly integration approach

## Output Format
```
## Position Paper: [Perspective]

### Overall Philosophy
[Why this perspective matters]

### Topic 1: Canvas Technology
**My Position**: [What I advocate]
**Argument**: [Why]
**Evidence**: [Supporting data]
**Tradeoffs Acknowledged**: [What we'd sacrifice]

[Repeat for each topic]

### Summary
[Key points of this perspective]
```

## Output File
Write to: `_extraction/[OUTPUT_FILE].md`
```

---

## PHASE-BY-PHASE EXECUTION

### PHASE 0: Meta-Harness (THIS SESSION, FIRST)
1. Backup existing harness
2. Create MIGRATION_PROGRESS.md
3. Create MIGRATION_FEATURES.json
4. Create _extraction/ folder
5. Mark tasks as passes: true

### PHASE 1: Knowledge Extraction (8 parallel agents)
| Agent | Target | Output |
|-------|--------|--------|
| EXT-01 | system/apps/canvas/ | 01_canvas_reality.md |
| EXT-02 | system/docs/ | 02_domain_knowledge.md |
| EXT-03 | MFC/ (solver, math) | 03_solver_logic.md |
| EXT-04 | deck/ | 04_visualization_research.md |
| EXT-05 | projects/ | 05_experiments.md |
| EXT-06 | All git logs | 06_git_archaeology.md |
| EXT-07 | design/*.png | 07_visual_spec.md |
| EXT-08 | Market mentions | 08_market_intel.md |

### PHASE 2: Technology Research (3 parallel agents)
| Agent | Topic | Output |
|-------|-------|--------|
| TECH-01 | PatternFly v6 | 10_patternfly_research.md |
| TECH-02 | @belt/tools | 11_belt_tools_api.md |
| TECH-03 | Canvas comparison | 12_canvas_tech_comparison.md |

### PHASE 3: Cross-Validation (4 parallel agents)
| Agent | Focus | Output |
|-------|-------|--------|
| VAL-01 | Math formulas | 20_validation_math.md |
| VAL-02 | Domain terms | 21_validation_domain.md |
| VAL-03 | Performance claims | 22_validation_perf.md |
| VAL-04 | Technology claims | 23_validation_tech.md |

### PHASE 4: Decision Debates (4 agents)
| Agent | Perspective | Output |
|-------|-------------|--------|
| DEB-01 | Simplicity | 30_debate_simplicity.md |
| DEB-02 | Completeness | 31_debate_completeness.md |
| DEB-03 | Performance | 32_debate_performance.md |
| DEB-04 | Synthesis | 35_synthesis_decisions.md |

### PHASE 5: Specification Writing (4 agents)
| Agent | Sections | Output |
|-------|----------|--------|
| SPEC-01 | Domain, Railway, Math | docs/SPECIFICATION.md (Part I) |
| SPEC-02 | Architecture, Canvas, State | docs/SPECIFICATION.md (Part II) |
| SPEC-03 | UX, PatternFly, Demo | docs/SPECIFICATION.md (Part III) |
| SPEC-04 | Final editing | docs/SPECIFICATION.md (complete) |

### PHASE 6: Repository Cleanup (Sequential)
1. Create backup branch
2. Remove packages/ entirely
3. Remove old docs (keep only SPECIFICATION.md)
4. Update package.json (PatternFly v6, @belt/tools)
5. Clean canvas app
6. Create V1.0 harness
7. Update CLAUDE.md
8. Delete _extraction/
9. Commit clean baseline

---

## KEY LEARNINGS TO PRESERVE (From This Chat)

### Domain Knowledge
- ECM Certification Framework (EU Regulation 2019/779)
- RAMS Compliance (EN 50126-1)
- Terminology: A/B/C/D Check ↔ PM1/PM2/PM3/HM
- Maintenance intervals and tolerances
- Math: km variance, fleet availability formulas
- Competitors: SignatureRail, Railnova, Tracsis, Quintiq

### Technical Knowledge
- STATE-ARCH-001: TypedArrays + SoA pattern
- TOOLKIT-PERF-001: 7 GC optimization fixes
- LOD: Macro (<0.5x), Meso (0.5-2x), Micro (>2x)
- Crossfade transitions for LOD
- RBush spatial indexing
- `trackMetadata: false` for 60fps

### Methodology
- Harness: progress.txt + features.json
- Hypothesis-Evidence-Action verification
- Disk-based artifact persistence
- Parallel extraction, sequential synthesis
- Debate protocol for decisions

### User Decisions
- **Autonomy**: FULL - decide everything, escalate only blockers
- **Cleanup**: AGGRESSIVE - delete all that's not useful
- **Scope**: PHASED - Canvas → UI → Solver

---

## IMMEDIATE EXECUTION SEQUENCE

1. **Backup harness** (shell commands)
2. **Create migration harness files** (Write tool)
3. **Create _extraction/ folder** (shell)
4. **Update MIGRATION_PROGRESS.md** with Phase 0 complete
5. **Launch Phase 1 agents** (8 parallel Task tools)

---

*Plan Version: 3.0 (Meta-Harness First)*
*Architecture: Robust*
*Objective: Clear*
*Ready for: Execution*

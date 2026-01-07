# Plan: Add O022 Doctor Command Tasks to features.json

## Summary

The user wants to:
1. Read `packages/harness-orchestrator/docs/PLAN-O022-DOCTOR.md`
2. Create proper tasks (features) in `packages/harness-orchestrator/features.json` for implementing the `harness doctor` command
3. Delete the PLAN-O022-DOCTOR.md file after tasks are created
4. Ensure all context is captured in the tasks so executing agents have no ambiguity

## Analysis of PLAN-O022-DOCTOR.md

The plan describes implementing a `harness doctor` command with:

### O022-A: Basic Checker (Programmatic, No AI)
- Check existence of harness files: features.json, claude-progress.txt, CLAUDE.md, init.sh, .claude/settings.json, .claude/hooks/, .git/, package.json
- Schema validation for features.json structure
- CLAUDE.md content validation (should mention harness/progress/features)
- Output: terminal UI with check results

### O022-B: Knowledge Base Manager
- Manage `.harness/kb/` directory with XML knowledge files
- `harness doctor --setup-kb` command to copy templates
- KB files versioned with manifest.json

### O022-C: Interactive Mode with @clack/prompts
- Add @clack/prompts dependency
- Beautiful multiselect UI for choosing verification options
- Options: AI Structure Verification, AI Health Check

### O022-D: AI Structure Verification
- Validates harness follows Anthropic's Two-Agent Architecture
- Checks claude-progress.txt format
- Validates hook configuration
- Checks CLAUDE.md completeness
- Uses KB context + spawns Claude for validation

### O022-E: AI Health Check
- Analyzes task quality (descriptions, steps, dependencies)
- Checks progress log quality
- Analyzes architecture (dependency chains, cycles)
- Provides recommendations

## Task Breakdown (5 subtasks)

I will create 5 features (O022-A through O022-E) that map to the plan sections, with all necessary context embedded so executing agents don't need the plan file.

## Files to Modify

1. `packages/harness-orchestrator/features.json` - Add O022-A through O022-E tasks
2. `packages/harness-orchestrator/progress.txt` - Add session entry
3. Delete `packages/harness-orchestrator/docs/PLAN-O022-DOCTOR.md` after tasks created

## Implementation Steps

1. Add 5 new features to features.json:
   - O022-A: BasicChecker (programmatic checks, no AI)
   - O022-B: KnowledgeManager (.harness/kb/ management)
   - O022-C: InteractiveUI (@clack/prompts integration)
   - O022-D: AIStructureChecker (AI validates structure)
   - O022-E: AIHealthChecker (AI health analysis)

2. Each feature will include:
   - Detailed description with ALL context from the plan
   - Step-by-step implementation steps
   - Explicit file paths to create/modify
   - Code examples where helpful
   - No ambiguity - executing agent should have everything needed

3. Update progress.txt with session entry

4. Delete PLAN-O022-DOCTOR.md

## Dependencies

- O022-A: Blocked by O020 (E2E test)
- O022-B: Blocked by O022-A
- O022-C: Blocked by O022-B (needs @clack/prompts)
- O022-D: Blocked by O022-B, O022-C
- O022-E: Blocked by O022-D

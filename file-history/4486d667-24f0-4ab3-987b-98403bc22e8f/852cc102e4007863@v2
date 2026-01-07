# Plan: Claude Code Hooks para MMS

## Objetivo

Criar hooks que **previnem problemas recorrentes** identificados no histórico do projeto, reduzindo iterações de correção e melhorando a qualidade dos resultados da AI.

**Baseado em:**
- [Anthropic - Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Claude Code — Use Hooks to Enforce End-of-Turn Quality Gates](https://jpcaparas.medium.com/claude-code-use-hooks-to-enforce-end-of-turn-quality-gates-5bed84e89a0d)

---

## Key Insight: Stop Hook for Quality Gates

> "The Stop event is ideal for end‑of‑turn validation, i.e. linting, type checks, tests, or any repo‑specific guardrail. This means your working tree is safer between turns and feedback is immediate."

**Pattern recommended:**
- `PostToolUse` → Fast (formatters, quick validations)
- `Stop` → Robust (typecheck, tests, visual verification reminders)
- `Exit code 2` → Blocks continuation, feeds error back to Claude

---

## Problemas Recorrentes Identificados

### Do histórico do projeto (claude-progress.txt, CLAUDE_NOTES.md):

| # | Problema | Frequência | Impacto |
|---|----------|------------|---------|
| 1 | AI marca feature como completa sem visual test | Alto | Features quebradas |
| 2 | Edição manual de package.json | Médio | Deps quebradas |
| 3 | TypeScript errors ignorados | Alto | Cascading failures |
| 4 | API patterns desatualizados (stale knowledge) | Médio | Código incorreto |
| 5 | Guessing loop (3+ tentativas sem pesquisar) | Alto | Tempo perdido |
| 6 | Console errors não verificados | Alto | Bugs ocultos |
| 7 | Comandos monorepo assumidos sem verificar | Médio | Dev server não inicia |
| 8 | Erros em visual test ignorados | Alto | Qualidade degradada |

---

## Hooks Propostos (Revised Architecture)

### Architecture: 3-Layer Hook System

```
┌─────────────────────────────────────────────────────────────┐
│  PreToolUse (BLOCKING)                                      │
│  → Prevent bad actions BEFORE they happen                   │
│  → Exit 2 to block, Exit 0 to allow                         │
├─────────────────────────────────────────────────────────────┤
│  PostToolUse (FAST)                                         │
│  → Quick validations AFTER each tool                        │
│  → Formatters, instant feedback                             │
├─────────────────────────────────────────────────────────────┤
│  Stop (QUALITY GATE)                                        │
│  → End-of-turn validation                                   │
│  → Typecheck, tests, harness enforcement                    │
│  → Exit 2 to block continuation + feed error to Claude      │
└─────────────────────────────────────────────────────────────┘
```

---

### Hook 1: `protect-package-json.sh` (PreToolUse) **[BLOCKING]**
**Objetivo**: Block manual edits to package.json

```bash
#!/bin/bash
# Exit 2 = BLOCK, Exit 0 = ALLOW
FILE_PATH=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [[ "$FILE_PATH" == *"package.json"* ]]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "🚫 BLOCKED: Manual edit to package.json" >&2
  echo "" >&2
  echo "Use 'bun add <package>' instead of editing manually." >&2
  echo "Package managers resolve versions and peer dependencies." >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  exit 2
fi

exit 0
```

---

### Hook 2: `after-write.sh` (PostToolUse) **[FAST]**
**Objetivo**: Quick feedback after file edits

```bash
#!/bin/bash
FILE_PATH=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)

# GLSL warning (shader errors are silent)
if [[ "$FILE_PATH" == *.glsl ]]; then
  echo "⚠️  GLSL edited - errors are SILENT. Check DevTools console." >&2
fi

# URGENT_POC visual test reminder
if [[ "$FILE_PATH" == *"URGENT_POC/"* ]]; then
  echo "📸 POC file edited - run visual test with Playwright MCP" >&2
fi

# TypeScript edited
if [[ "$FILE_PATH" == *.ts || "$FILE_PATH" == *.tsx ]]; then
  echo "✓ TypeScript edited - typecheck will run at end of turn" >&2
fi

exit 0
```

---

### Hook 3: `end-of-turn-check.sh` (Stop) **[QUALITY GATE]**
**Objetivo**: Enforce harness protocol at end of each turn

```bash
#!/bin/bash
set -e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 END-OF-TURN QUALITY CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. TypeScript check (if .ts/.tsx changed)
if git diff --name-only HEAD 2>/dev/null | grep -qE '\.(ts|tsx)$' || \
   git ls-files --others --exclude-standard | grep -qE '\.(ts|tsx)$'; then
  echo "📝 TypeScript files changed - running typecheck..."
  if ! bun run typecheck 2>&1 | head -20; then
    echo "" >&2
    echo "❌ TYPECHECK FAILED" >&2
    echo "Fix TypeScript errors before continuing." >&2
    exit 2
  fi
  echo "✅ Typecheck passed"
fi

# 2. Check for URGENT_POC changes (visual test reminder)
if git diff --name-only HEAD 2>/dev/null | grep -q 'URGENT_POC/' || \
   git ls-files --others --exclude-standard | grep -q 'URGENT_POC/'; then
  echo ""
  echo "┌────────────────────────────────────────────┐"
  echo "│ 📸 VISUAL TEST REQUIRED                    │"
  echo "│                                            │"
  echo "│ POC files changed. Before marking feature  │"
  echo "│ complete, run visual test with Playwright: │"
  echo "│                                            │"
  echo "│ 1. mcp__playwright__browser_navigate       │"
  echo "│ 2. mcp__playwright__browser_console_messages│"
  echo "│ 3. mcp__playwright__browser_take_screenshot│"
  echo "│ 4. Analyze screenshot                      │"
  echo "└────────────────────────────────────────────┘"
fi

# 3. Harness file validation
if [ ! -f "features.json" ]; then
  echo "⚠️  features.json not found - harness incomplete" >&2
fi

if [ ! -f "claude-progress.txt" ]; then
  echo "⚠️  claude-progress.txt not found - update progress log" >&2
fi

echo ""
echo "✅ End-of-turn check complete"
exit 0
```

---

### Hook 4: `session-start.sh` (SessionStart)
**Objetivo**: Enforce harness protocol at session start

```bash
#!/bin/bash
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 MMS HARNESS - SESSION START"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📅 Current date: $(date '+%Y-%m-%d')"
echo ""

# Remind about harness protocol
echo "┌────────────────────────────────────────────┐"
echo "│ HARNESS PROTOCOL REMINDERS                 │"
echo "├────────────────────────────────────────────┤"
echo "│ 1. Read claude-progress.txt first          │"
echo "│ 2. Check features.json for current state   │"
echo "│ 3. One feature per session                 │"
echo "│ 4. Visual test before marking complete     │"
echo "│ 5. Commit after each feature passes        │"
echo "│ 6. NEVER ignore errors (ask user)          │"
echo "└────────────────────────────────────────────┘"

# Check current versions (stale knowledge prevention)
if [ -f "package.json" ]; then
  echo ""
  echo "📦 Current package versions:"
  jq -r '.dependencies | to_entries[] | select(.key | test("react|three|astro|tailwind")) | "   \(.key): \(.value)"' package.json 2>/dev/null || true
fi

exit 0
```

---

### Hook 5: `task-type-detector.py` (UserPromptSubmit)
**Objetivo**: Detect task type and show contextual reminders

```python
#!/usr/bin/env python3
import json
import sys
import re

try:
    data = json.load(sys.stdin)
except:
    sys.exit(0)

prompt = data.get('prompt', '').lower()

# Task type detection and reminders
reminders = []

# Bug fix detection
if re.search(r'\b(bug|fix|broken|error|issue|crash)\b', prompt):
    reminders.append("""
┌─────────────────────────────────────────────┐
│ 🐛 BUG FIX DETECTED                         │
├─────────────────────────────────────────────┤
│ • Add test that reproduces the bug          │
│ • Verify fix with the test                  │
│ • Check for similar issues in codebase      │
└─────────────────────────────────────────────┘""")

# Feature implementation detection
if re.search(r'\b(add|implement|new|feature|create)\b', prompt):
    reminders.append("""
┌─────────────────────────────────────────────┐
│ ✨ FEATURE IMPLEMENTATION                   │
├─────────────────────────────────────────────┤
│ • Visual test REQUIRED before passes: true  │
│ • Check console for errors                  │
│ • Test user interactions                    │
└─────────────────────────────────────────────┘""")

# Shader/WebGL detection
if re.search(r'\b(shader|glsl|webgl|three|r3f)\b', prompt):
    reminders.append("""
┌─────────────────────────────────────────────┐
│ 🎮 WEBGL/SHADER WORK                        │
├─────────────────────────────────────────────┤
│ ⚠️  Shader errors are SILENT!               │
│ • Check DevTools console                    │
│ • Screenshot to verify rendering            │
│ • DataTexture issues won't throw errors     │
└─────────────────────────────────────────────┘""")

# Feature completion detection
if re.search(r'(passes.*true|feature.*complete|mark.*done)', prompt):
    reminders.append("""
┌─────────────────────────────────────────────┐
│ ✅ FEATURE COMPLETION CHECKLIST             │
├─────────────────────────────────────────────┤
│ □ Visual test with Playwright MCP?          │
│ □ Console has no red errors?                │
│ □ bun run typecheck passes?                 │
│ □ User interactions tested?                 │
│ □ claude-progress.txt updated?              │
└─────────────────────────────────────────────┘""")

for r in reminders:
    print(r, file=sys.stderr)

sys.exit(0)
```

---

## Estrutura de Arquivos

```
.claude/
├── settings.json           # Hook configuration
└── hooks/
    ├── protect-package-json.sh   # PreToolUse [BLOCKING]
    ├── after-write.sh            # PostToolUse [FAST]
    ├── end-of-turn-check.sh      # Stop [QUALITY GATE]
    ├── session-start.sh          # SessionStart
    └── task-type-detector.py     # UserPromptSubmit
```

---

## Final Configuration (.claude/settings.json)

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-start.sh" }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-package-json.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/after-write.sh" }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          { "type": "command", "command": "python3 \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/task-type-detector.py" }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/end-of-turn-check.sh" }
        ]
      }
    ]
  }
}
```

---

## Implementation Order

### Phase 1: Core (do first)
1. `.claude/settings.json` - Configuration file
2. `.claude/hooks/protect-package-json.sh` - **BLOCKING** package.json edits
3. `.claude/hooks/end-of-turn-check.sh` - **QUALITY GATE** at end of turn

### Phase 2: Feedback
4. `.claude/hooks/after-write.sh` - Quick feedback after writes
5. `.claude/hooks/task-type-detector.py` - Task-aware reminders

### Phase 3: Session
6. `.claude/hooks/session-start.sh` - Harness protocol reminder

---

## Execution Plan

```bash
# 1. Create hooks directory
mkdir -p .claude/hooks

# 2. Create each hook file (as shown in plan)

# 3. Make scripts executable
chmod +x .claude/hooks/*.sh
chmod +x .claude/hooks/*.py

# 4. Create settings.json

# 5. Test by opening new Claude Code session
```

---

## Testing Strategy

After implementation, test in a NEW Claude Code session:

1. **SessionStart** - Should show harness reminders on session start
2. **PreToolUse** - Try to edit package.json → should BLOCK
3. **PostToolUse** - Edit a .ts file → should show typecheck reminder
4. **UserPromptSubmit** - Type "fix bug" → should show bug fix reminder
5. **Stop** - End a turn with .ts changes → should run typecheck

---

## Files to Create

| File | Event | Behavior |
|------|-------|----------|
| `.claude/settings.json` | - | Configuration |
| `.claude/hooks/protect-package-json.sh` | PreToolUse | BLOCK package.json edits |
| `.claude/hooks/after-write.sh` | PostToolUse | Quick feedback |
| `.claude/hooks/end-of-turn-check.sh` | Stop | Typecheck + visual test reminder |
| `.claude/hooks/session-start.sh` | SessionStart | Harness protocol reminder |
| `.claude/hooks/task-type-detector.py` | UserPromptSubmit | Task-aware reminders |

---

## Notes

- All hooks use `$CLAUDE_PROJECT_DIR` for portability
- Exit code 2 = BLOCK (only for PreToolUse and Stop)
- Exit code 0 = Allow/Success
- Messages go to stderr to be visible to user
- Hooks run in parallel when multiple match
- Keep hooks FAST - defer heavy checks to Stop event

---

## Sources

- [Anthropic - Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Claude Code — Use Hooks to Enforce End-of-Turn Quality Gates](https://jpcaparas.medium.com/claude-code-use-hooks-to-enforce-end-of-turn-quality-gates-5bed84e89a0d)
- [Claude Code: Best practices for agentic coding](https://www.anthropic.com/engineering/claude-code-best-practices)

# Plan: Harness Self-Awareness System

## Problem Identified

**Symptom:** Claude Code starts sessions without knowing what "Harness" is, despite existing documentation.

**Root Cause Analysis:**

After deep analysis of existing documentation, I identified 4 structural problems:

### 1. Poor Positioning in CLAUDE.md
- The section "HARNESS: Work Loop for Long-Running Agents" is at **line 293** in CLAUDE.md
- The first 200+ lines are about KISS philosophy, tech stack, commands
- Claude may not read that far if the message is short or context is limited
- **Solution:** Move harness definition to the BEGINNING of CLAUDE.md

### 2. SessionStart Hook Doesn't Define the Concept
The current hook (`session-start.sh`) displays:
```
┌────────────────────────────────────────────┐
│ HARNESS PROTOCOL REMINDERS                 │
├────────────────────────────────────────────┤
│ 1. Read claude-progress.txt first          │
│ 2. Check features.json for current state   │
...
```

**Problem:** Assumes Claude already knows what harness is. Says "what to do" but not "why" or "what is".

**Solution:** Modify hook to include concise concept definition BEFORE the steps.

### 3. No Research Links
If Claude doesn't understand the concept from local documentation, there's no indication of where to find more information.

**Solution:** Include official Anthropic links in hook output:
- https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- https://code.claude.com/docs/en/hooks-guide

### 4. No Self-Correction Mechanism
There's no way to detect if Claude "understood" and suggest research if needed.

**Solution:** Add proactive suggestion in hook to research if not understood.

---

## Proposed Solution (No New Files)

### File 1: `.claude/hooks/session-start.sh`

Modify to include:

```bash
#!/bin/bash
# Hook: SessionStart - Harness Context Injection + Self-Correction

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 MMS HARNESS - SESSION START"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# WHAT IS A HARNESS? (definition FIRST)
echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ WHAT IS A HARNESS?                                          │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ A 'Harness' is a framework that enables AI agents to work   │"
echo "│ on long tasks across multiple context windows/sessions.     │"
echo "│                                                              │"
echo "│ PROBLEM: Each new session starts with NO memory.            │"
echo "│ SOLUTION: State files (progress + features) persist context.│"
echo "│                                                              │"
echo "│ Official source: anthropic.com/engineering/                 │"
echo "│                  effective-harnesses-for-long-running-agents│"
echo "└─────────────────────────────────────────────────────────────┘"

# Current date (prevents stale training data issue)
echo ""
echo "📅 Current date: $(date '+%Y-%m-%d')"

# Work protocol
echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ WORK PROTOCOL                                               │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ 1. READ claude-progress.txt → session history              │"
echo "│ 2. READ features.json → next feature (passes:false)        │"
echo "│ 3. IMPLEMENT one feature at a time                          │"
echo "│ 4. TEST visually with Playwright MCP                        │"
echo "│ 5. COMMIT after feature passes                              │"
echo "│ 6. UPDATE claude-progress.txt                               │"
echo "└─────────────────────────────────────────────────────────────┘"

# SELF-CORRECTION PROTOCOL
echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ 🔄 SELF-CORRECTION PROTOCOL                                 │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ If you DON'T KNOW what a 'Harness' is:                      │"
echo "│                                                              │"
echo "│ 1. SEARCH: WebSearch 'Anthropic harness agents 2025'        │"
echo "│ 2. ANALYZE: Why was local documentation unclear?            │"
echo "│ 3. FIX: Update CLAUDE.md or hooks to improve clarity        │"
echo "│ 4. DOCUMENT: Record the fix in claude-progress.txt          │"
echo "│                                                              │"
echo "│ This is a CONTINUOUS IMPROVEMENT system.                    │"
echo "│ Each session should leave harness clearer for the next.     │"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""

# Package versions and recent commits
if [ -f "package.json" ]; then
  echo "📦 Current package versions:"
  jq -r '.dependencies | to_entries[] | select(.key | test("react|three|blueprint")) | "   \(.key): \(.value)"' package.json 2>/dev/null || true
fi

if git rev-parse --git-dir > /dev/null 2>&1; then
  echo ""
  echo "📜 Recent commits:"
  git --no-pager log --oneline -3 2>/dev/null | sed 's/^/   /'
fi

exit 0
```

### File 2: `CLAUDE.md`

Move harness section to the BEGINNING of the file (after "Project Overview"):

```markdown
# Metro Integrated Planning System (MMS)

## Project Overview
[keep existing]

---

## HARNESS: Fundamental Concept (READ THIS FIRST)

> **This project uses a Harness.** If you don't know what that is, STOP and research:
> - [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)

### What is a Harness?

A **Harness** is a framework that enables AI agents to work on long tasks across multiple context windows/sessions.

**Problem:** Each new Claude Code session starts with NO memory of previous sessions.

**Solution:** State files persist context between sessions:
- `claude-progress.txt` → session history
- `features.json` → requirements with status (passes: true/false)

### Work Protocol

```
1. READ claude-progress.txt (understand current state)
2. READ features.json (find next feature)
3. IMPLEMENT one feature
4. TEST visually (Playwright MCP)
5. COMMIT after passing
6. UPDATE claude-progress.txt
7. STOP (leave codebase production-ready)
```

### Self-Correction Protocol

If you don't understand what harness is after reading this:
1. **SEARCH:** WebSearch "Anthropic harness agents 2025"
2. **ANALYZE:** Why was local documentation unclear?
3. **FIX:** Update CLAUDE.md or hooks to improve clarity
4. **DOCUMENT:** Record the fix in claude-progress.txt

### Harness Files

| File | Purpose | When to Read |
|------|---------|--------------|
| `claude-progress.txt` | Session history | **ALWAYS first** |
| `features.json` | Features with status | After progress.txt |
| `CLAUDE.md` | Project rules | Reference |

---

## KISS Philosophy
[rest of existing file...]
```

---

## Files to Modify

1. **`.claude/hooks/session-start.sh`** - Add conceptual definition + research link + self-correction protocol
2. **`CLAUDE.md`** - Move harness section to the beginning (before KISS Philosophy)
3. **`claude-progress.txt`** - Document this session and meta-reflection

---

## Why This Solution Works

1. **Hook injects context immediately** - Claude sees definition in first session output
2. **CLAUDE.md prioritizes harness** - If Claude reads the file, harness is first
3. **Official links provide fallback** - If local docs aren't enough, has where to research
4. **No new files created** - Reuses existing structure

---

## NEW: Self-Correction System (Self-Healing)

The user specifically requested a system where Claude:
1. **Detects** that it doesn't understand harness
2. **Searches** the internet to learn
3. **Analyzes** why local documentation failed
4. **Fixes** the project to prevent repetition

### Implementation: Hook with Self-Correction Instruction

The `session-start.sh` hook will include an **imperative instruction** for Claude:

```bash
echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ 🔄 SELF-CORRECTION PROTOCOL                                 │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ If you DON'T KNOW what a 'Harness' is:                      │"
echo "│                                                              │"
echo "│ 1. SEARCH: WebSearch 'Anthropic harness agents 2025'        │"
echo "│ 2. ANALYZE: Why was local documentation unclear?            │"
echo "│ 3. FIX: Update CLAUDE.md or hooks to improve clarity        │"
echo "│ 4. DOCUMENT: Record the fix in claude-progress.txt          │"
echo "│                                                              │"
echo "│ This is a CONTINUOUS IMPROVEMENT system.                    │"
echo "│ Each session should leave harness clearer for the next.     │"
echo "└─────────────────────────────────────────────────────────────┘"
```

### Self-Correction Cycle Logic

```
┌──────────────────────────────────────────────────────────────────┐
│                    SESSION START                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  SessionStart Hook displays:                                      │
│  - Harness definition                                             │
│  - Work protocol                                                  │
│  - Self-correction instruction                                    │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Claude understands? │
                    └─────────────────┘
                      /           \
                    YES           NO
                    /               \
                   ▼                 ▼
┌──────────────────────┐    ┌──────────────────────────────────────┐
│ Proceed with         │    │ 1. WebSearch: harness + agents       │
│ normal work          │    │ 2. Read official Anthropic article   │
│ (read progress.txt,  │    │ 3. Analyze: "Why didn't I understand?"│
│  features.json, etc) │    │ 4. Propose improvements to CLAUDE.md │
└──────────────────────┘    │ 5. Update harness files              │
                            │ 6. Document in progress.txt          │
                            └──────────────────────────────────────┘
                                          │
                                          ▼
                            ┌──────────────────────────────────────┐
                            │ Next session starts with harness     │
                            │ clearer - continuous improvement     │
                            └──────────────────────────────────────┘
```

### What Claude Should Fix If It Doesn't Understand

1. **CLAUDE.md** - If harness definition isn't clear:
   - Move section to more prominent position
   - Add concrete examples
   - Simplify language

2. **session-start.sh** - If hook doesn't communicate well:
   - Add more context
   - Improve formatting
   - Include more relevant links

3. **claude-progress.txt** - Always document:
   - What wasn't clear
   - What was searched
   - What was fixed
   - Lessons learned

---

## Files to Modify (Revised)

1. **`.claude/hooks/session-start.sh`**
   - Add conceptual harness definition
   - Add official research links
   - **NEW:** Add self-correction instruction

2. **`CLAUDE.md`**
   - Move harness section to the BEGINNING (after Project Overview)
   - Add official Anthropic link
   - Simplify language

3. **`claude-progress.txt`**
   - Document this meta-reflection session
   - Record changes made

---

## Validation

After implementing, start a new Claude Code session and verify:
- [ ] Hook displays harness definition
- [ ] Hook displays self-correction instruction
- [ ] Hook suggests research if not understood
- [ ] CLAUDE.md has harness at the beginning
- [ ] Claude demonstrates understanding of the concept
- [ ] If not understood, Claude searches AND fixes the project

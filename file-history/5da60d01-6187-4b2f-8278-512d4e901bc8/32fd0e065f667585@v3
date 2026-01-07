# Plan: LLM Rule Enforcement Mechanisms

## Context

User is designing a cascade framework where `__*.md` files contain rules that LLMs MUST follow when operating in that directory. The question is: **How to enforce these rules?**

## Current Understanding

From the brainstorming session, we have:
- `__*.md` files = mandatory rules per directory
- Hierarchical inheritance (child folders inherit parent rules)
- Rules added via `RULE:::...ELUR:::` syntax

## Enforcement Options to Explore

### Option A: Pre-Read Hook
- Before any file operation, read all `__*.md` in hierarchy
- Inject rules into LLM context
- **Pro**: Rules always present
- **Con**: Context overhead

### Option B: Message Pattern Matching
- Scan LLM output for rule violations
- Block/warn if pattern detected
- **Pro**: Catches violations post-hoc
- **Con**: Reactive, not proactive

### Option C: File Operation Interception
- Hook into Read/Write/Edit tools
- Check relevant `__*.md` before allowing
- **Pro**: Granular control
- **Con**: Complex implementation

### Option D: Subagent Prompt Injection
- When spawning subagents, automatically include rules from hierarchy
- **Pro**: Subagents inherit rules naturally
- **Con**: Requires orchestration layer

## User Decisions

1. **Timing**: Both (hybrid) - inject rules BEFORE + validate AFTER
2. **Target**: Both (cascade) - main agent + subagents inherit rules
3. **Consequence**: Hard block (exit 2) - stop execution on violation

## Proposed Implementation

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    ENFORCEMENT LAYERS                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  LAYER 1: PRE-ACTION (Proactive)                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Before Read/Write/Edit on path P:                    │    │
│  │   1. Collect all __*.md from P up to root            │    │
│  │   2. Inject rules into context                       │    │
│  │   3. Proceed with action                             │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  LAYER 2: POST-ACTION (Reactive)                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ After action completes:                              │    │
│  │   1. Scan output/changes for rule violations         │    │
│  │   2. If violation → exit 2 (hard block)              │    │
│  │   3. If clean → continue                             │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  LAYER 3: SUBAGENT INHERITANCE                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ When spawning Task:                                  │    │
│  │   1. Determine target directory from prompt          │    │
│  │   2. Collect relevant __*.md rules                   │    │
│  │   3. Prepend to subagent prompt                      │    │
│  │   4. Subagent operates with inherited rules          │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Implementation via Claude Code Hooks

**Hook 1: PreToolUse (Read/Write/Edit)**
```bash
#!/bin/bash
# .claude/hooks/inject-rules.sh

# Extract target path from tool input
TARGET_PATH="$1"

# Collect __*.md files in hierarchy
collect_rules() {
    local dir="$1"
    while [[ "$dir" != "/" ]]; do
        for f in "$dir"/__*.md; do
            [[ -f "$f" ]] && cat "$f"
        done
        dir=$(dirname "$dir")
    done
}

# Output rules to be injected
collect_rules "$(dirname "$TARGET_PATH")"
```

**Hook 2: PostToolUse (Validation)**
```bash
#!/bin/bash
# .claude/hooks/validate-rules.sh

# Check if output violates any rules
# Pattern matching against known violations
# exit 2 if violation found
```

### Challenges to Address

1. **Rule extraction from __*.md**: Parse RULES section
2. **Pattern matching**: How to detect violations?
3. **Context injection**: How to prepend rules to LLM context?
4. **Subagent directory detection**: How to know where subagent will operate?

## Next Steps

Research:
1. How Claude Code hooks can inject context
2. Pattern matching strategies for rule violations
3. Subagent prompt manipulation

# Plan: Evolve Cascade Rules to .agentrc.ts

## Context

Currently we have:
- `cascade-rules.sh` - Bash hook that collects `__*.md` files
- `__rules.md` files - Markdown rules shown to LLM

User wants to evolve to:
- `.agentrc.ts` / `.agentrc.js` files (regex: `/^\.?agentrc(\.[tj]s)?/`)
- Programmatic TypeScript hooks using `@belt/ai`
- Maintain cascade inheritance (child dirs inherit parent rc files)

## Current State

### Existing `.agentrc.ts` example:
```typescript
import { createHooks } from '@belt/ai';

export const hooks = createHooks({
  SessionStart: ({ printInfo }) => {
    printInfo('Banner here');
  },
});

// Dynamic config option
export default ({ dirname, getParentConfig }) => {
  return { hooks: {} };
};
```

### `@belt/ai` provides:
- `createHooks()` - Register hooks by action name
- Hook actions: PreToolUse, PostToolUse, SessionStart, etc.
- Context: `printLog`, `printInfo`, `break`, etc.

## Understanding

**Question**: What is the relationship between:
1. The existing bash `cascade-rules.sh`
2. The new `.agentrc.ts` approach

Options:
- A) Replace bash entirely with TypeScript runner
- B) Bash calls TypeScript, TS returns rules/decisions
- C) Two parallel systems (bash for blocking, TS for logic)

## Initial Analysis

The `.agentrc.ts` approach would:
1. Be more powerful (programmatic logic)
2. Be type-safe (TypeScript)
3. Support cascade via `getParentConfig()`
4. Allow dynamic rules based on context

---

## User Decisions

1. **Relationship**: Replace entirely (drop __*.md + bash, all in TypeScript)
2. **Runtime**: bun (fast, native TS support)

---

## Proposed Architecture

### File Pattern
```
/^\.?agentrc(\.[tj]s)?/

Matches:
- .agentrc.ts   (hidden, TypeScript)
- .agentrc.js   (hidden, JavaScript)
- agentrc.ts    (visible, TypeScript)
- agentrc.js    (visible, JavaScript)
```

### Cascade Hierarchy
```
project/
├── .agentrc.ts              ← Root config (all inherit)
├── src/
│   ├── .agentrc.ts          ← src config (inherits root)
│   └── components/
│       └── .agentrc.ts      ← components (inherits src + root)
└── docs/
    └── .agentrc.ts          ← docs (inherits root only)
```

### API Design

```typescript
// .agentrc.ts
import { defineAgent } from '@belt/ai';

export default defineAgent({
  // Static rules (like __rules.md content)
  rules: [
    {
      id: 'NO-FORBIDDEN-FILES',
      match: (path) => path.endsWith('.forbidden'),
      action: 'block',
      message: 'Cannot create .forbidden files',
    },
  ],

  // Programmatic hooks
  hooks: {
    PreToolUse: ({ tool, input, block }) => {
      if (tool === 'Write' && input.file_path.includes('secret')) {
        block('Cannot write to secret paths');
      }
    },
    SessionStart: ({ printInfo }) => {
      printInfo('Agent ready');
    },
  },

  // Inherit and extend parent config
  extend: (parentConfig) => ({
    ...parentConfig,
    rules: [...parentConfig.rules, ...myRules],
  }),
});
```

### Execution Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    AGENTRC EXECUTION                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Claude Code hook triggers (PreToolUse:Write)            │
│                                                              │
│  2. Bash wrapper calls bun:                                  │
│     bun run .claude/hooks/agentrc-runner.ts                 │
│                                                              │
│  3. Runner collects .agentrc.ts files in hierarchy:         │
│     - Start from target file's directory                    │
│     - Walk up to project root                               │
│     - Import each .agentrc.ts                               │
│     - Merge configs (child extends parent)                  │
│                                                              │
│  4. Runner executes relevant hook:                          │
│     - Pass tool name, input, context                        │
│     - Hook returns: allow / block / modify                  │
│                                                              │
│  5. Runner outputs result:                                   │
│     - exit 0 = allow                                        │
│     - exit 2 = block                                        │
│     - stdout = context injection                            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Files to Create

1. **`packages/belt-ai/src/define.ts`**
   - `defineAgent()` function
   - Type definitions for AgentConfig
   - Rule matching logic

2. **`.claude/hooks/agentrc-runner.ts`**
   - Main entry point called by bash
   - Collects .agentrc.ts files in hierarchy
   - Merges configs with inheritance
   - Executes hooks
   - Returns exit code

3. **`.claude/hooks/agentrc-wrapper.sh`**
   - Thin bash wrapper that calls bun
   - Passes stdin JSON to runner
   - Forwards exit code

4. **Update `.claude/settings.json`**
   - Replace cascade-rules.sh with agentrc-wrapper.sh

### Type Definitions

```typescript
// packages/belt-ai/src/types/agent.ts

export interface AgentRule {
  id: string;
  match: string | RegExp | ((path: string) => boolean);
  action: 'block' | 'warn' | 'allow';
  message?: string;
}

export interface AgentHooks {
  PreToolUse?: (ctx: PreToolUseContext) => void | 'block' | 'allow';
  PostToolUse?: (ctx: PostToolUseContext) => void;
  SessionStart?: (ctx: SessionContext) => void;
  // ... other hooks
}

export interface AgentConfig {
  rules?: AgentRule[];
  hooks?: AgentHooks;
  extend?: (parent: AgentConfig) => AgentConfig;
}

export function defineAgent(config: AgentConfig): AgentConfig;
```

### Migration Path

1. Keep `cascade-rules.sh` working during development
2. Create new `agentrc-runner.ts` in parallel
3. Test with simple `.agentrc.ts` at root
4. Once working, update `settings.json` to use new system
5. Remove old `cascade-rules.sh` and `__*.md` files

---

## Benefits Over Bash + Markdown

| Aspect | Old (bash + md) | New (TypeScript) |
|--------|-----------------|------------------|
| Type safety | ❌ None | ✅ Full TypeScript |
| Logic | ❌ Bash patterns only | ✅ Full JS/TS |
| Reusability | ❌ Copy/paste | ✅ Import/export |
| Testing | ❌ Manual | ✅ Unit tests |
| IDE support | ❌ Limited | ✅ Full autocomplete |
| Debugging | ❌ echo/log files | ✅ Node debugger |

---

## Additional User Decisions

3. **Package**: Local monorepo (packages/belt-ai, workspace reference)
4. **Async**: Supported (hooks can be async for file reads, API calls, etc.)

---

## Final Implementation Plan

### Step 1: Extend `@belt/ai` Types

**File**: `packages/belt-ai/src/types/agent.ts`

```typescript
export interface AgentRule {
  id: string;
  match: string | RegExp | ((path: string, ctx: RuleContext) => boolean | Promise<boolean>);
  action: 'block' | 'warn' | 'allow';
  message?: string;
}

export interface RuleContext {
  tool: string;
  input: Record<string, any>;
  projectRoot: string;
}

export interface HookContext {
  tool: string;
  input: Record<string, any>;
  projectRoot: string;
  filePath: string;
  block: (message: string) => void;
  warn: (message: string) => void;
  inject: (content: string) => void;
}

export interface AgentConfig {
  rules?: AgentRule[];
  hooks?: {
    PreToolUse?: (ctx: HookContext) => void | Promise<void>;
    PostToolUse?: (ctx: HookContext) => void | Promise<void>;
    SessionStart?: (ctx: HookContext) => void | Promise<void>;
    SessionEnd?: (ctx: HookContext) => void | Promise<void>;
  };
}

export function defineAgent(config: AgentConfig): AgentConfig {
  return config;
}
```

### Step 2: Create Runner

**File**: `.claude/hooks/agentrc-runner.ts`

```typescript
#!/usr/bin/env bun

import { resolve, dirname } from 'path';
import { existsSync } from 'fs';

const AGENTRC_PATTERN = /^\.?agentrc(\.[tj]s)?$/;
const PROJECT_ROOT = process.env.CLAUDE_PROJECT_DIR || process.cwd();

async function findAgentrcFiles(startDir: string): Promise<string[]> {
  const files: string[] = [];
  let currentDir = startDir;

  while (currentDir.startsWith(PROJECT_ROOT) && currentDir !== '/') {
    const entries = await Bun.file(currentDir).exists()
      ? []
      : await readdir(currentDir);

    for (const entry of ['agentrc.ts', '.agentrc.ts', 'agentrc.js', '.agentrc.js']) {
      const filePath = resolve(currentDir, entry);
      if (existsSync(filePath)) {
        files.push(filePath);
      }
    }
    currentDir = dirname(currentDir);
  }

  return files.reverse(); // Root first, then children
}

async function loadAndMergeConfigs(files: string[]): Promise<AgentConfig> {
  let mergedConfig: AgentConfig = { rules: [], hooks: {} };

  for (const file of files) {
    const module = await import(file);
    const config = module.default || module;

    // Merge rules
    if (config.rules) {
      mergedConfig.rules = [...(mergedConfig.rules || []), ...config.rules];
    }

    // Merge hooks (later overrides earlier)
    if (config.hooks) {
      mergedConfig.hooks = { ...mergedConfig.hooks, ...config.hooks };
    }
  }

  return mergedConfig;
}

async function main() {
  // Read stdin JSON
  const stdinJson = await Bun.stdin.text();
  const { tool_name, tool_input } = JSON.parse(stdinJson);
  const filePath = tool_input?.file_path;

  if (!filePath) {
    process.exit(0); // No file path, allow
  }

  // Find and load agentrc files
  const targetDir = dirname(filePath);
  const agentrcFiles = await findAgentrcFiles(targetDir);
  const config = await loadAndMergeConfigs(agentrcFiles);

  // Check rules
  for (const rule of config.rules || []) {
    const matches = typeof rule.match === 'function'
      ? await rule.match(filePath, { tool: tool_name, input: tool_input, projectRoot: PROJECT_ROOT })
      : typeof rule.match === 'string'
        ? filePath.includes(rule.match)
        : rule.match.test(filePath);

    if (matches && rule.action === 'block') {
      console.error(`❌ RULE VIOLATION: ${rule.id}`);
      console.error(`   ${rule.message || 'Action blocked'}`);
      process.exit(2);
    }
  }

  // Execute PreToolUse hook if defined
  if (config.hooks?.PreToolUse) {
    let blocked = false;
    let blockMessage = '';

    await config.hooks.PreToolUse({
      tool: tool_name,
      input: tool_input,
      projectRoot: PROJECT_ROOT,
      filePath,
      block: (msg) => { blocked = true; blockMessage = msg; },
      warn: (msg) => console.error(`⚠️ ${msg}`),
      inject: (content) => console.log(content),
    });

    if (blocked) {
      console.error(`❌ BLOCKED: ${blockMessage}`);
      process.exit(2);
    }
  }

  process.exit(0);
}

main().catch((err) => {
  console.error('Runner error:', err);
  process.exit(1);
});
```

### Step 3: Create Bash Wrapper

**File**: `.claude/hooks/agentrc-wrapper.sh`

```bash
#!/bin/bash
# Thin wrapper that calls bun with the TypeScript runner

exec bun run "$CLAUDE_PROJECT_DIR/.claude/hooks/agentrc-runner.ts"
```

### Step 4: Update Settings

**File**: `.claude/settings.json`

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [{
          "type": "command",
          "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/agentrc-wrapper.sh"
        }]
      },
      {
        "matcher": "Edit",
        "hooks": [{
          "type": "command",
          "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/agentrc-wrapper.sh"
        }]
      }
    ]
  }
}
```

### Step 5: Example .agentrc.ts

**File**: `.agentrc.ts`

```typescript
import { defineAgent } from './packages/belt-ai/src';

export default defineAgent({
  rules: [
    {
      id: 'NO-FORBIDDEN-FILES',
      match: (path) => path.endsWith('.forbidden'),
      action: 'block',
      message: 'Cannot create .forbidden files',
    },
    {
      id: 'NO-SECRET-PATHS',
      match: /secret|password|credential/i,
      action: 'warn',
      message: 'Sensitive path detected',
    },
  ],

  hooks: {
    PreToolUse: async ({ tool, filePath, block, inject }) => {
      // Example: inject context
      inject(`🔒 AgentRC active for: ${filePath}`);

      // Example: async check (read file content)
      if (tool === 'Edit') {
        // Could check existing file content here
      }
    },

    SessionStart: ({ inject }) => {
      inject('══════════════════════════════════════');
      inject('        AGENTRC SYSTEM ACTIVE          ');
      inject('══════════════════════════════════════');
    },
  },
});
```

---

## Implementation Order

1. ✅ Create types in `packages/belt-ai/src/types/agent.ts`
2. ✅ Create `defineAgent()` in `packages/belt-ai/src/define.ts`
3. ✅ Export from `packages/belt-ai/src/index.ts`
4. ✅ Create `.claude/hooks/agentrc-runner.ts`
5. ✅ Create `.claude/hooks/agentrc-wrapper.sh`
6. ✅ Update root `.agentrc.ts` with new API
7. ✅ Update `.claude/settings.json`
8. ✅ Test: create `.forbidden` file (should block)
9. ✅ Remove old `cascade-rules.sh` and `__rules.md`

---

## Files to Modify

| File | Action |
|------|--------|
| `packages/belt-ai/src/types/agent.ts` | Create |
| `packages/belt-ai/src/define.ts` | Create |
| `packages/belt-ai/src/index.ts` | Update exports |
| `.claude/hooks/agentrc-runner.ts` | Create |
| `.claude/hooks/agentrc-wrapper.sh` | Create |
| `.claude/settings.json` | Update hooks |
| `.agentrc.ts` | Update to new API |
| `.claude/hooks/cascade-rules.sh` | Delete (after migration) |
| `__rules.md` | Delete (after migration) |

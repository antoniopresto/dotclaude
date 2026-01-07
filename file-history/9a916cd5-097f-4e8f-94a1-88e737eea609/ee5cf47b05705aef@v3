# Belt NPM Publishing & Claude Code Automation Plan

## Context

Research completed on Anthropic Harness patterns, Claude Code hooks, NPM monorepo publishing, and pnpm workspace gotchas. Full findings in `.claude/research-report.md`.

**Key Insight**: "Anthropic Harness" refers to agent orchestration patterns for long-running tasks, not a specific product. The recommended approach uses progress files (`claude-progress.txt`) and structured artifacts rather than relying on context alone.

---

## Phase 1: NPM Publishing Preparation

### 1.1 Organization Setup (Manual, Pre-requisite)

Before any code changes:
1. Login to npmjs.com
2. Create organization "belt" (if not owned)
3. Generate Granular Access Token with publish permissions

### 1.2 Package Metadata Updates

**Files to modify:**
- `packages/core/package.json`
- `packages/plugins/typecheck/package.json`
- `packages/plugins/sync-types/package.json`
- `apps/cli/package.json`

**Fields to add:**
```json
{
  "repository": {
    "type": "git",
    "url": "https://github.com/antoniopresto/belt",
    "directory": "packages/core"
  },
  "homepage": "https://github.com/antoniopresto/belt#readme",
  "bugs": "https://github.com/antoniopresto/belt/issues",
  "author": "Antonio Presto <antoniopresto@gmail.com>",
  "license": "MIT",
  "keywords": ["belt", "developer-tools", "typescript", "typecheck", "monorepo"],
  "publishConfig": {
    "access": "public"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

### 1.3 Remove Unused Dependency

`packages/plugins/sync-types/package.json` - Remove `zx` (not used in code)

### 1.4 LICENSE Files

Create MIT LICENSE (single template, copy to each location):
- `/LICENSE`
- `/packages/core/LICENSE`
- `/packages/plugins/typecheck/LICENSE`
- `/packages/plugins/sync-types/LICENSE`
- `/apps/cli/LICENSE`

### 1.5 README Files (Succinct, Professional)

Create minimal, professional READMEs:

| File | Sections |
|------|----------|
| `/README.md` | Overview, Install, Quick Start, Packages, License |
| `/packages/core/README.md` | Purpose, Install, API, Example |
| `/packages/plugins/typecheck/README.md` | Purpose, Install, Options |
| `/packages/plugins/sync-types/README.md` | Purpose, Install, Options |
| `/apps/cli/README.md` | Install, Commands, Usage |

---

## Phase 2: Git Hooks (Husky)

### 2.1 Install at Root

```bash
pnpm add -D husky -w
pnpm exec husky init
```

### 2.2 Configure Hooks

**`.husky/pre-commit`**
```bash
#!/usr/bin/env sh
pnpm lint
```

**`.husky/pre-push`**
```bash
#!/usr/bin/env sh
pnpm build && pnpm typecheck
```

**`.husky/commit-msg`**
```bash
#!/usr/bin/env sh
commit_msg=$(cat "$1")
pattern="^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .{1,}"
if ! echo "$commit_msg" | grep -qE "$pattern"; then
  echo "Error: Commit message must follow format: type(scope): description"
  echo "Types: feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"
  exit 1
fi
```

### 2.3 Add prepare Script to Root

```json
{
  "scripts": {
    "prepare": "husky"
  }
}
```

---

## Phase 3: Claude Code Infrastructure

Based on Anthropic Harness patterns: use progress files for state persistence across sessions.

### 3.1 Directory Structure

```
.claude/
├── settings.json           # Hooks configuration
├── commands/
│   ├── publish.md          # Publish workflow
│   └── quality.md          # Quality checks
├── templates/
│   ├── plugin.ts           # New plugin template
│   └── progress.md         # Progress file template
└── research-report.md      # Research findings (already created)
```

### 3.2 Progress File (Anthropic Harness Pattern)

**`claude-progress.txt`** (project root)
```
# Belt Development Progress

## Current State
- Version: 0.1.0 (pre-release)
- Status: NPM publishing preparation

## Completed
- [x] Monorepo structure (pnpm + Turborepo)
- [x] @belt/core with tapable hooks
- [x] @belt/plugin-typecheck
- [x] @belt/plugin-sync-types
- [x] @belt/cli with React Ink

## In Progress
- [ ] NPM publishing setup
- [ ] Claude Code automation

## Next Session
1. Review this file
2. Check git log for recent changes
3. Continue from "In Progress" items

## Known Issues
- sync-types output needs refinement for edge cases
```

### 3.3 Hooks Configuration

**`.claude/settings.json`**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "cat \"$CLAUDE_PROJECT_DIR/claude-progress.txt\" 2>/dev/null || echo 'No progress file found'"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$TOOL_INPUT\" | grep -q 'pnpm publish'; then echo 'Reminder: Verify build succeeded before publishing'; fi"
          }
        ]
      }
    ]
  }
}
```

### 3.4 Custom Commands

**`.claude/commands/publish.md`**
```markdown
# Publish Workflow

Pre-publish checklist:
1. Ensure all packages build: `pnpm build`
2. Run type checks: `pnpm typecheck`
3. Run linting: `pnpm lint`
4. Verify versions in all package.json files match

Publish sequence (dependency order):
1. cd packages/core && pnpm publish --access public
2. cd packages/plugins/typecheck && pnpm publish --access public
3. cd packages/plugins/sync-types && pnpm publish --access public
4. cd apps/cli && pnpm publish --access public

Post-publish:
1. Create git tag: git tag v0.1.0
2. Push tag: git push origin v0.1.0
3. Update claude-progress.txt
```

**`.claude/commands/quality.md`**
```markdown
# Quality Check

Run all quality checks:
pnpm lint && pnpm build && pnpm typecheck

Fix auto-fixable issues:
pnpm lint:fix
```

### 3.5 Plugin Template

**`.claude/templates/plugin.ts`**
```typescript
import type { BeltPlugin } from '@belt/core';

export interface MyPluginOptions {
  // Define options here
}

export function myPlugin(options: MyPluginOptions = {}): BeltPlugin {
  return {
    name: 'my-plugin',
    apply(belt) {
      belt.hooks.initialize.tapPromise('my-plugin', async (ctx) => {
        // Initialize plugin
      });

      belt.hooks.beforeCheck.tapPromise('my-plugin', async (ctx) => {
        // Run before checks
      });
    },
  };
}
```

---

## Phase 4: Documentation Updates

### 4.1 Update CLAUDE.md

Add sections:
- NPM Publishing (link to publish command)
- Development Workflow (hooks, progress file)
- Claude Code Commands reference

### 4.2 Create CHANGELOG.md

```markdown
# Changelog

## [0.1.0] - 2024-XX-XX

### Added
- @belt/core: Plugin system with tapable hooks
- @belt/plugin-typecheck: TypeScript diagnostic filtering
- @belt/plugin-sync-types: Type declaration generation
- @belt/cli: Interactive TUI with React Ink
```

---

## Files Summary

| Action | Path |
|--------|------|
| Modify | `packages/core/package.json` |
| Modify | `packages/plugins/typecheck/package.json` |
| Modify | `packages/plugins/sync-types/package.json` |
| Modify | `apps/cli/package.json` |
| Modify | `package.json` (add prepare script) |
| Create | `LICENSE` (+ 4 copies) |
| Create | `README.md` (root) |
| Create | `packages/core/README.md` |
| Create | `packages/plugins/typecheck/README.md` |
| Create | `packages/plugins/sync-types/README.md` |
| Create | `apps/cli/README.md` |
| Create | `.husky/pre-commit` |
| Create | `.husky/pre-push` |
| Create | `.husky/commit-msg` |
| Create | `.claude/settings.json` |
| Create | `.claude/commands/publish.md` |
| Create | `.claude/commands/quality.md` |
| Create | `.claude/templates/plugin.ts` |
| Create | `claude-progress.txt` |
| Create | `CHANGELOG.md` |
| Modify | `CLAUDE.md` |

---

## Execution Order

1. Package metadata (all package.json files)
2. Remove unused zx dependency
3. LICENSE files
4. README files
5. Install Husky, configure hooks
6. Claude Code infrastructure (.claude/)
7. Progress file (claude-progress.txt)
8. CHANGELOG.md
9. Update CLAUDE.md
10. Final verification: `pnpm build && pnpm lint`

---

## Critical Notes (Senior Insights)

1. **NPM Organization**: Must exist before first publish. Create at npmjs.com/org/create
2. **Publish Order**: Core → Plugins → CLI (dependency order)
3. **First Publish**: Requires `--access public` flag (subsequent don't)
4. **workspace:* Resolution**: pnpm auto-converts to versions at publish time
5. **Husky Location**: Must be at monorepo root, not in packages
6. **Progress File**: Update after each significant change (Anthropic Harness pattern)
7. **No Over-Engineering**: Skip Changesets/CI for v0.1.0, add later if needed

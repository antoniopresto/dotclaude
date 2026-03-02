# Plan: Remove packages cli, compliance, terminal, belt-setup

## Context

Remove 4 packages from the monorepo: `@belt/cli`, `@belt/compliance`, `@belt/terminal`, and `belt-setup`, along with all references. After removal, 3 packages remain: `@belt/tools`, `@belt/ai`, `@belt/prettier-plugin`.

## Steps

### 1. Delete package directories
```
rm -rf packages/cli packages/compliance packages/terminal packages/belt-setup
```

### 2. Update `.github/workflows/publish.yml`
- Line 62: Remove `cli`, `belt-setup` from the dist verification loop → keep only `tools ai-tools prettier-plugin`
- Lines 75-79: Remove `Publish @belt/cli` step
- Lines 87-91: Remove `Publish belt-setup` step

### 3. Update `CLAUDE.md`
- Lines 34-37: Remove cli, belt-setup, compliance from project structure
- Lines 54-57: Remove from package table
- Lines 87-97: Remove from NPM Publishing section

### 4. Update `.claude/commands/publish.md`
- Lines 34-39: Remove cli, compliance, belt-setup from publish order table
- Lines 45-52: Remove publish commands for those packages

### 5. Update `.belt/harness/features.json`
- Remove features: `publish-cli`, `publish-setup`, `compliance-local-testing`

### 6. Update `.belt/harness/progress.txt`
- Update package count (6 → 3)
- Remove packages from table
- Remove "Publish @belt/compliance" from next steps

### 7. Update `PUBLISHING.md`
- Remove all references to cli, belt-setup, compliance packages

### 8. Regenerate lockfile
```bash
bun install
```

### 9. Verify
```bash
bun run build && bun run typecheck && bun test && bun lint
```

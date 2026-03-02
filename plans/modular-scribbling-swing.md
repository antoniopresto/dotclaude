# Plan: Remove cli, compliance, terminal, belt-setup packages

## Context
User wants to remove 4 packages from the monorepo: `cli`, `compliance`, `terminal`, `belt-setup`. Although they contain real code, the user considers them non-essential and wants them gone.

## Steps

### 1. Delete package directories
```
rm -rf packages/cli
rm -rf packages/compliance
rm -rf packages/terminal
rm -rf packages/belt-setup
```

### 2. Update `.github/workflows/publish.yml`
- Remove `cli` and `belt-setup` from the dist verification loop (line 62)
- Remove "Publish @belt/cli" step (lines 75-79)
- Remove "Publish belt-setup" step (lines 87-91)
- (compliance and terminal were never in CI)

### 3. Update `CLAUDE.md` (project root)
- Remove cli, compliance, belt-setup from Project Structure tree
- Remove them from Packages table
- Remove them from NPM Publishing section

### 4. Update `.claude/commands/publish.md`
- Remove @belt/compliance, @belt/cli, belt-setup from publish order table and commands

### 5. Update `PUBLISHING.md`
- Remove all references to @belt/cli, belt-setup, @belt/compliance throughout the doc

### 6. Update `TESTING.md`
- Remove @belt/cli and belt-setup test sections

### 7. Update `CHANGELOG.md`
- Remove @belt/cli entry

### 8. Update `.belt/harness/features.json`
- Remove features: `publish-cli`, `publish-setup`, `compliance-local-testing`

### 9. Run `bun install` to update lockfile

### 10. Verify
- `bun run build` succeeds
- `bun run test` passes
- `bun lint` passes

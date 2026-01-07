# Plan: Naming Convention for Cascade Rules Framework

## Research Summary

### Most Sophisticated RC Systems

| Rank | System | Key Feature |
|------|--------|-------------|
| 1 | **Git (.gitconfig)** | `includeIf` conditional (gitdir, branch, remote) |
| 2 | **ESLint (flat config)** | Composable arrays, extends from plugins |
| 3 | **TypeScript** | `extends` via npm packages |
| 4 | **EditorConfig** | Auto-cascade until `root = true` |

### Unix Naming Patterns

| Pattern | Example | Recognition | Notes |
|---------|---------|-------------|-------|
| `.Xrc` | `.bashrc`, `.npmrc` | Very High | "Run commands" - shell era |
| `.X/` | `.git/`, `.claude/` | High | Directory-based config |
| `Xfile` | `Makefile`, `Dockerfile` | Very High | Ruby/DevOps style |
| `X.md` | `CLAUDE.md`, `README.md` | High | Modern, readable |
| `__X__` | `__init__.py` | High (Python only) | Reserved for Python internals |
| `.X.d/` | `/etc/apt.d/` | High (Linux) | Modular configs |

### Emerging AI Agent Standards

| Tool | File | Format |
|------|------|--------|
| Claude Code | `CLAUDE.md` | Markdown |
| Cursor | `.cursor/rules/*.mdc` | MDC |
| VS Code Copilot | `.github/instructions/*.md` | Markdown |
| Multi-tool | `AGENTS.md` (emerging) | Markdown |

---

## Options for Cascade Rules Naming

### Option A: `.agentrc` (Unix RC Style)
```
project/
├── .agentrc              # Root rules
├── src/
│   └── .agentrc          # src rules (inherit root)
└── docs/
    └── .agentrc          # docs rules
```

**Pros**: Familiar Unix convention, works with existing tooling
**Cons**: "rc" implies "run commands", not "rules"; format unclear (INI? YAML?)

### Option B: `.agent/rules.md` (XDG + Markdown)
```
project/
├── .agent/
│   └── rules.md          # Root rules
├── src/
│   └── .agent/
│       └── rules.md      # src rules
```

**Pros**: Modern XDG-like structure, Markdown readable, extensible (.agent/config.yaml, etc.)
**Cons**: More directories, less discoverable

### Option C: `AGENTRULES` (CODEOWNERS Style)
```
project/
├── AGENTRULES            # Root rules
├── src/
│   └── AGENTRULES        # src rules
```

**Pros**: Visible (not hidden), follows CODEOWNERS pattern
**Cons**: No extension, unusual, might not support hierarchy well

### Option D: Keep `__rules.md` (Current)
```
project/
├── __rules.md            # Root rules
├── src/
│   └── __rules.md        # src rules
```

**Pros**: Already implemented, works
**Cons**: Python dunder association, less semantic

### Option E: Hybrid - `.rules.md` (Simple + Markdown)
```
project/
├── .rules.md             # Root rules
├── src/
│   └── .rules.md         # src rules
```

**Pros**: Simple, hidden, Markdown format clear, no tool lock-in
**Cons**: Very generic name

---

## Inheritance Syntax Options

### Git-style `includeIf`:
```yaml
---
includeIf:
  - condition: "path:src/frontend/**"
    extends: "./frontend-rules.md"
  - condition: "path:src/backend/**"
    extends: "./backend-rules.md"
---
```

### ESLint-style `extends`:
```yaml
---
extends:
  - "../.rules.md"           # Parent
  - "@claude/react"          # Preset
priority: 100
scope: "**/*.tsx"
---
```

### Kustomize-style (directory-based):
```
project/
├── base/
│   └── .rules.md           # Base rules
└── overlays/
    ├── development/
    │   └── .rules.md       # Dev overrides
    └── production/
        └── .rules.md       # Prod overrides
```

---

## Questions for User

1. **Naming**: Which convention resonates most?
2. **Format**: Pure Markdown? YAML frontmatter + Markdown?
3. **Inheritance**: Auto-cascade (like current) or explicit extends?
4. **Scope**: Tool-agnostic or Claude-specific?

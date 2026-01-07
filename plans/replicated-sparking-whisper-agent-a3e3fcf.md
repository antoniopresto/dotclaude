# Research: Configuration Inheritance Patterns for Agent Rules

## Executive Summary

This research analyzes inheritance/import patterns across 7 major configuration systems to identify the best approach for "agent rules" that cascade through directories.

---

## 1. ESLint Flat Config (2025)

### Syntax
```javascript
import { defineConfig } from "eslint/config";
import js from "@eslint/js";

export default defineConfig({
  files: ["**/*.js"],
  extends: [
    "js/recommended",           // String reference
    pluginConfig,               // Object
    [...arrayOfConfigs]         // Array spread handled automatically
  ],
  rules: {
    // Override specific rules
    "no-console": "warn"
  }
});
```

### Strengths
- `defineConfig()` eliminates spread operator confusion
- `extends` accepts strings, objects, OR arrays uniformly
- File-scoped inheritance with `files: ["pattern"]`
- Plugins can export named configs: `"plugin/recommended"`

### Override Semantics
- Later items in `extends` array override earlier ones
- Local `rules` override extended rules
- Clean merge: no complex resolution algorithm

### Weakness
- Requires import statements (no URL-based loading)
- No directory-based auto-discovery

---

## 2. TypeScript tsconfig.json

### Syntax
```json
{
  "extends": "./base/tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist"
  },
  "include": ["src/**/*"]
}
```

### Multi-extends (TypeScript 5.0+)
```json
{
  "extends": [
    "@tsconfig/node18/tsconfig.json",
    "./tsconfig.paths.json"
  ]
}
```

### Strengths
- Simple single-key `extends`
- Node-style resolution for packages
- Multiple extends with array syntax

### Override Semantics
- `compilerOptions`: deep merge (child wins on conflict)
- `include`/`exclude`: complete replacement (no merge)
- Paths resolved relative to originating file

### Weakness
- No override for specific paths
- Complete replacement of arrays is surprising
- No conditional inheritance

---

## 3. Kubernetes Kustomize

### Structure
```
base/
  kustomization.yaml
  deployment.yaml
overlays/
  dev/
    kustomization.yaml    # references ../base
  prod/
    kustomization.yaml    # references ../base
```

### Syntax
```yaml
# overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base            # Inherit from base

patches:
  - path: increase-replicas.yaml
    target:
      kind: Deployment

components:
  - ../../components/caching   # Reusable feature modules
```

### Strengths
- Explicit base/overlay separation
- Patches are surgical (JSON merge patch, strategic merge)
- Components for cross-cutting features
- Directory-based organization is first-class

### Override Semantics
- Base resources loaded first
- Patches applied in order
- Components can be mixed into any overlay

### Weakness
- Verbose for simple overrides
- Learning curve for patch types
- No inheritance from parent directories (only explicit references)

---

## 4. Terraform Modules

### Syntax
```hcl
module "network" {
  source = "./modules/network"

  # Explicit inputs (dependency inversion)
  vpc_cidr = "10.0.0.0/16"
}

module "app" {
  source = "./modules/app"

  # Wire outputs to inputs
  vpc_id = module.network.vpc_id
}
```

### Strengths
- Dependency inversion: modules don't embed dependencies
- Explicit data flow via inputs/outputs
- Composition over inheritance
- Flat hierarchy recommended

### Override Semantics
- No implicit inheritance
- All configuration is explicit
- Provider inheritance flows downward

### Weakness
- No "extends" concept
- Verbose for simple cases
- Not applicable for cascading rules

---

## 5. Babel Configuration

### Syntax
```javascript
// babel.config.js
module.exports = {
  extends: "./base.babelrc.js",
  presets: [
    ["@babel/preset-env", { targets: "defaults" }]
  ],
  plugins: [
    "@babel/plugin-transform-runtime"
  ]
};
```

### Strengths
- Simple `extends` with path
- Presets bundle common plugins

### Override Semantics
- Objects merged (not replaced)
- Plugins/presets replaced by identity
- Preset order is reversed (last-to-first)

### Weakness
- Reversed preset order is confusing
- Identity-based replacement is complex
- Known bugs with `extends` + `preset-env`

---

## 6. CSS Cascade Layers

### Syntax
```css
/* Establish layer order first */
@layer reset, framework, components, utilities;

/* Import into named layers */
@import url("normalize.css") layer(reset);
@import url("bootstrap.css") layer(framework);

/* Local overrides in higher-priority layer */
@layer utilities {
  .btn { /* Always wins over framework */ }
}
```

### Nested Layers
```css
@import url("theme.css") layer(framework.themes.dark);
```

### Strengths
- Explicit priority declaration upfront
- Layer order controls cascade (not specificity)
- Dot notation for nesting
- Anonymous layers for isolation

### Override Semantics
- First declared = lowest priority
- Last declared = highest priority (except `!important`)
- Unlayered styles beat all layers

### Weakness
- Browser-only (not general config)
- Must declare order before use
- No directory-based organization

---

## 7. Docker Multi-Stage Builds

### Syntax
```dockerfile
FROM node:20 AS base
RUN npm install

FROM base AS development
CMD ["npm", "run", "dev"]

FROM base AS production
RUN npm run build
CMD ["npm", "start"]
```

### Stage Aliasing
```dockerfile
ARG TARGET=production
FROM alpine:3.18 AS alpine

FROM alpine AS builder
RUN apk add build-base

FROM ${TARGET} AS final
```

### Strengths
- Explicit stage naming with `AS`
- Parallel builds from common base
- ARG-based conditional paths
- COPY --from=stage for artifacts

### Override Semantics
- Each FROM starts fresh
- Only COPY brings artifacts forward
- Conditional via ARG substitution

### Weakness
- Linear inheritance only
- No merge semantics
- Domain-specific (container builds)

---

## Comparative Analysis

| System | Import Syntax | Override Clarity | Directory Support | Flexibility |
|--------|--------------|-----------------|-------------------|-------------|
| ESLint | `extends: []` | High | Low | High |
| TypeScript | `extends: ""` | Medium | Low | Medium |
| Kustomize | `resources: []` | High | High | High |
| Terraform | `module {}` | Very High | Medium | Medium |
| Babel | `extends: ""` | Low | Low | Low |
| CSS Layers | `@layer` | Very High | N/A | Medium |
| Docker | `FROM AS` | High | N/A | Low |

---

## Recommendations for Agent Rules

### Best Import/Extend Syntax: ESLint's `defineConfig`

```javascript
// Why: Uniform handling of strings, objects, arrays
// No spread operator ambiguity
// File-pattern scoping built-in

defineConfig({
  files: ["src/**"],
  extends: ["./base-rules", localRules, plugin.recommended]
})
```

### Clearest Override Semantics: CSS Cascade Layers

```css
/* Why: Explicit priority declaration upfront */
@layer base, project, user;

/* Order is explicit, not implicit */
```

### Most Flexible Inheritance: Kustomize

```yaml
# Why: Directory-based, surgical patches, components
resources:
  - ../../base
patches:
  - path: override.yaml
components:
  - ../shared-features
```

---

## Proposed Design for Agent Rules

### Directory Structure
```
.claude/
  rules/
    __base__.md           # Global base rules
    security/
      __rules__.md        # Security-specific rules
    frontend/
      __rules__.md        # Frontend-specific rules
      react/
        __rules__.md      # React-specific (inherits from frontend)
```

### Inheritance Syntax (Hybrid Approach)

```yaml
# .claude/rules/frontend/react/__rules__.md
---
extends:
  - ../../__rules__.md    # Inherit from frontend
  - @claude/react         # Built-in preset
priority: 100             # Explicit layer priority
scope:
  files: ["**/*.tsx", "**/*.jsx"]
---

# Rules content in markdown...
```

### Key Design Decisions

1. **From ESLint**: `extends` array with mixed sources
2. **From CSS Layers**: Explicit `priority` number
3. **From Kustomize**: Directory-based organization with `__rules__.md`
4. **From TypeScript**: Node-style resolution for packages

### Override Algorithm

```
1. Collect all __rules__.md from root to current directory
2. Sort by priority (lower = base, higher = override)
3. Merge rules: later wins on conflict
4. Apply file scope filtering
```

### Example Resolution

```
Working on: src/components/Button.tsx

Rules loaded (in order):
1. .claude/rules/__base__.md (priority: 0)
2. .claude/rules/frontend/__rules__.md (priority: 50)
3. .claude/rules/frontend/react/__rules__.md (priority: 100)

Final rules = merge(base, frontend, react)
```

---

## Sources

- [ESLint Flat Config Extends](https://eslint.org/blog/2025/03/flat-config-extends-define-config-global-ignores/)
- [TypeScript tsconfig extends](https://www.typescriptlang.org/tsconfig/extends.html)
- [Kustomize Overlays](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [Terraform Module Composition](https://developer.hashicorp.com/terraform/language/modules/develop/composition)
- [Babel Configuration](https://babeljs.io/docs/configuration)
- [CSS Cascade Layers](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@layer)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)

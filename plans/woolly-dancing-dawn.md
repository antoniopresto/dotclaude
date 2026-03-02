# Git Hooks DX Improvement Plan

## Problem Summary

Your colleague is experiencing issues with git commit/push where:
1. `git push` shows "files altered" but `git status` shows nothing
2. Error messages are unclear about what failed

**Root Causes Identified:**
- Pre-push hook silences ALL errors with `2>/dev/null`
- Lint scripts modify files (`--fix`, `--write`) during push validation
- lint-staged is configured but NOT USED (pre-commit runs full repo lint)
- No `.gitattributes` = potential line ending inconsistencies across platforms
- No `.editorconfig` = inconsistent editor behavior
- Fallback branch is `origin/develop` but main branch is `master`

---

## Implementation Plan

### 1. Add Check-Only Lint Scripts

**File:** `package.json`

Add new scripts that validate WITHOUT modifying files:

```json
"lint:check": "run-s lint-check:*",
"lint-check:eslint": "eslint . --cache --format ./scripts/core/eslint-formatter-sorted.js",
"lint-check:prettier": "prettier --check --ignore-unknown .",
"lint-check:typescript": "ts-node ./scripts/typescript-check.ts"
```

---

### 2. Fix Pre-Commit Hook (Use lint-staged)

**File:** `.husky/pre-commit`

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
```

**File:** `package.json` - Update lint-staged config:

```json
"lint-staged": {
  "*.{ts,tsx}": [
    "eslint --fix --cache --format ./scripts/core/eslint-formatter-sorted.js",
    "prettier --write --ignore-unknown"
  ],
  "*.{js,jsx}": [
    "eslint --fix --cache --format ./scripts/core/eslint-formatter-sorted.js",
    "prettier --write --ignore-unknown"
  ],
  "*.json": [
    "prettier --write --ignore-unknown"
  ]
}
```

**Benefits:** Only staged files are linted = much faster commits

---

### 3. Fix Pre-Push Hook (Clear Error Messages)

**File:** `.husky/pre-push`

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

echo "Running pre-push checks..."

# Determine base branch for comparison
get_base_ref() {
  if git rev-parse --verify @{upstream} >/dev/null 2>&1; then
    echo "@{upstream}"
    return 0
  fi
  if git rev-parse --verify origin/master >/dev/null 2>&1; then
    echo "origin/master"
    return 0
  fi
  echo "HEAD"
}

BASE_REF=$(get_base_ref)
echo "Comparing against: $BASE_REF"

# Run check-only lint (NO auto-fix)
if ! npm run lint:check; then
  echo ""
  echo "========================================"
  echo "  PRE-PUSH CHECK FAILED"
  echo "========================================"
  echo ""
  echo "To fix automatically, run:"
  echo "  npm run lint"
  echo ""
  echo "Then stage and amend your commit:"
  echo "  git add -A && git commit --amend --no-edit"
  echo ""
  exit 1
fi

echo "All pre-push checks passed."
```

**Key Changes:**
- No `2>/dev/null` - all errors visible
- Uses `lint:check` (no file modification)
- Correct fallback to `origin/master`
- Clear, actionable error messages

---

### 4. Add `.gitattributes` (Line Ending Normalization)

**File:** `.gitattributes` (new)

```gitattributes
# Normalize line endings to LF
* text=auto eol=lf

# Source files
*.ts text eol=lf
*.tsx text eol=lf
*.js text eol=lf
*.jsx text eol=lf
*.json text eol=lf
*.md text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.sh text eol=lf

# Config files
.gitignore text eol=lf
.gitattributes text eol=lf
*.config.js text eol=lf
*.config.mjs text eol=lf

# Binary files
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.woff binary
*.woff2 binary
*.ttf binary

# iOS/Android
*.pbxproj merge=union
*.gradle text eol=lf
*.java text eol=lf
*.swift text eol=lf

# Lock files
package-lock.json text eol=lf
yarn.lock text eol=lf
Podfile.lock text eol=lf
```

**After creating:** Run `git add --renormalize .` to fix existing files

---

### 5. Add `.editorconfig` (Editor Consistency)

**File:** `.editorconfig` (new)

```editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.{ts,tsx,js,jsx,json}]
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[*.{java,kt,swift}]
indent_size = 4

[Makefile]
indent_style = tab
```

---

### 6. (Optional) Re-enable Commitlint

**File:** `.husky/commit-msg`

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx --no -- commitlint --edit "$1"
```

**File:** `commitlint.config.js` (new)

```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'subject-case': [0],
    'body-max-line-length': [0],
  },
};
```

---

## Files to Modify

| File | Action |
|------|--------|
| `package.json` | Add `lint:check` scripts, update `lint-staged` config |
| `.husky/pre-commit` | Replace with `npx lint-staged` |
| `.husky/pre-push` | Replace with improved hook |
| `.gitattributes` | Create new file |
| `.editorconfig` | Create new file |
| `.husky/commit-msg` | Uncomment commitlint (optional) |
| `commitlint.config.js` | Create new file (optional) |

---

## Verification

After implementation:

```bash
# 1. Fix existing line endings
git add --renormalize .
git commit -m "chore: normalize line endings"

# 2. Test pre-commit (should be fast, only staged files)
echo "test" >> README.md
git add README.md
git commit -m "test: verify pre-commit hook"

# 3. Test pre-push (should show clear errors if any)
git push origin feature/test-branch

# 4. Test lint:check (should NOT modify files)
npm run lint:check
git status  # Should show no changes
```

---

## Sources

- [Husky Official Docs](https://typicode.github.io/husky/)
- [lint-staged GitHub](https://github.com/lint-staged/lint-staged)
- [Git Line Endings Best Practices](https://www.aleksandrhovhannisyan.com/blog/crlf-vs-lf-normalizing-line-endings-in-git/)
- [Lefthook vs Husky Comparison](https://www.edopedia.com/blog/lefthook-vs-husky/)

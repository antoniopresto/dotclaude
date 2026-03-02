# Plan: Bootstrap "lol" project

## Context
Create a Raycast UI clone called "lol" for internal use. V1 is UI-only, no real OS integrations. Visually identical to Raycast's design system.

## Stack
- pnpm (package manager)
- Bun (runtime)
- TypeScript + React
- Vite (bundler)
- Sass (styling)

## Steps

1. Create `~/antonio/lol`
2. Scaffold Vite project with `pnpm create vite . --template react-ts`
3. Install dependencies: `pnpm add sass` + any needed dev deps
4. Create `README.md` — concise, LLM-optimized, no fluff
5. Create `.claude/CLAUDE.md` — project instructions for AI agents
6. Create `.claude/progress.txt` — phase 1 task list (80 char lines, `- [ ]` format, tasks separated by 80 `-` chars)
7. `git init`, commit everything, stop

## Files created
- `~/antonio/lol/` — full Vite + React + TS + Sass scaffold
- `~/antonio/lol/README.md`
- `~/antonio/lol/.claude/CLAUDE.md`
- `~/antonio/lol/.claude/progress.txt`

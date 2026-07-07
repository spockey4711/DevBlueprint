# Variant: Web app (Next.js + pnpm)

The stack this blueprint was extracted from: Next.js App Router, TypeScript (strict), Tailwind,
Vitest + Testing Library, Playwright, ESLint/Prettier, GitHub Actions CI, pnpm.

## Quality gate

```bash
pnpm lint && pnpm typecheck && pnpm test && pnpm build
```

## What `devblueprint init --variant web-nextjs` adds

- `docs/engineering/` - git-workflow, conventions (+ TS/React/Tailwind overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `pnpm install`).
- `.github/workflows/ci.yml` (quality + Playwright smoke).
- `.gitignore` for Node/Next.
- `src/` and `tests/` skeleton.

## After init (wire the toolchain)

This variant assumes a Next.js app already scaffolded (`pnpm create next-app`) or adds the
workflow around one. You still need to:

1. Add a `wt` package script: `"wt": "bash scripts/wt.sh"`.
2. Add the gate scripts: `lint`, `typecheck` (`tsc --noEmit`), `test` (`vitest run`),
   `test:e2e` (`playwright test`), `build`.
3. Add `.nvmrc` and set `packageManager` in `package.json` for CI.
4. Set up husky + lint-staged for the pre-commit hook.

# Variant: Web app (SvelteKit + pnpm)

A typed-as-you-go SvelteKit web stack: TypeScript on SvelteKit 2 / Svelte 5, pnpm for
dependencies, Prettier (with `prettier-plugin-svelte`) for formatting, ESLint +
`svelte-check` for linting and type-checking, Vitest for unit/component tests, Playwright
for e2e, and GitHub Actions CI.

## Quality gate

```bash
pnpm lint && pnpm check && pnpm test && pnpm build
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant sveltekit` adds

- `docs/engineering/` - git-workflow, conventions (+ SvelteKit/TypeScript overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `pnpm install`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/` - `ci.yml` (lint + check + test + build, plus a Playwright
  smoke job), plus the shared `security.yml`, `commit-checks.yml` and `coverage.yml`
  baseline.
- `.github/dependabot.yml` (npm + github-actions updates) and `.tool-versions` (Node + pnpm pin).
- `.gitignore` for `node_modules`, the `.svelte-kit/` output and build artifacts.
- `src/routes`, `src/lib`, `src/lib/components`, `src/lib/server`, `tests/unit`, `tests/e2e`
  scaffold.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. It cannot scaffold the SvelteKit application for you -
generate that first, then run setup:

```bash
npx sv create .          # scaffold SvelteKit into the repo root
./setup.sh               # writes eslint.config.js, .prettierrc, vitest/playwright
                         # config + the husky pre-commit hook, then pnpm add -D the toolchain
./setup.sh --no-install  # config only
```

`setup.sh` patches `package.json` with the gate scripts (`lint`, `check`, `test`, `build`, ...),
writes the ESLint flat config, Prettier config, Vitest and Playwright configs, and the
husky + lint-staged pre-commit hook, so `make check` and CI enforce the gate. Idempotent; never
clobbers existing files.

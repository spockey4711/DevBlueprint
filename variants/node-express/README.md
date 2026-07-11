# Variant: Backend API (Node + Express + TypeScript)

A typed HTTP API stack: Express on Node LTS, TypeScript (`strict`), ESLint (typescript-eslint,
type-checked) + Prettier, Vitest + supertest for units and endpoints, `tsc` build to `dist/`,
GitHub Actions CI. Ships a minimal working app (a `/health` route + error handling) so the gate
is green from the first commit.

## Quality gate

```bash
sh scripts/check-env.sh && npm run lint && npm run typecheck && npm test && npm run build
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant node-express` adds

- `docs/engineering/` - git-workflow, conventions (+ Node/Express overlay), quality-and-testing,
  engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `npm install`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/ci.yml` (env-schema check + lint + typecheck + test + build).
- `.github/dependabot.yml` (npm + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for Node build/test artifacts.
- `docs/ops/deployment.md` (deploy runbook: managed/Docker/VPS + DB + env checklists) and
  `.env.example` (committed template; real `.env*` stay ignored).
- Ops artifacts: `Dockerfile` (node:22-slim build -> slim non-root runtime) + `.dockerignore` +
  `docker-compose.yml`, `deploy/` (Fly/Render/Terraform skeletons), and `.env.schema` +
  `scripts/check-env.sh` (the env contract `make check` and CI enforce). All skeletons - fill the
  `<...>` placeholders.
- `src/{routes,middleware,services,lib}`, `tests/{unit,integration}` scaffold.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. Run it once:

```bash
./setup.sh              # writes tsconfig(.build).json, eslint.config.mjs, prettier + vitest
                        # config, husky + lint-staged, a minimal Express app + test, then
                        # `npm install` (which wires the pre-commit hook via `prepare: husky`)
./setup.sh --no-install # config only
```

Idempotent; never clobbers existing files. Then `npm run dev` starts the API on
`http://localhost:3000` (`GET /health` returns `{ "status": "ok" }`).

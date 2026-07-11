# Variant: Web app (Next.js + pnpm)

The stack this blueprint was extracted from: Next.js App Router, TypeScript (strict), Tailwind,
Vitest + Testing Library, Playwright, ESLint/Prettier, GitHub Actions CI, pnpm.

## Quality gate

```bash
sh scripts/check-env.sh && pnpm lint && pnpm typecheck && pnpm test && pnpm build
```

## What `devblueprint init --variant web-nextjs` adds

- `docs/engineering/` - git-workflow, conventions (+ TS/React/Tailwind overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `pnpm install`).
- `.github/workflows/ci.yml` (quality + Playwright smoke).
- `.github/dependabot.yml` (npm + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for Node/Next.
- `docs/ops/deployment.md` (deploy runbook: managed/Docker/VPS + DB + env checklists) and
  `.env.example` (committed template; real `.env*` stay ignored).
- Ops artifacts: `Dockerfile` (Next.js standalone output -> slim non-root `node server.js`) +
  `.dockerignore` + `docker-compose.yml`, `deploy/` (Vercel/Render/Fly/Terraform skeletons - Vercel
  is the primary managed target and needs no Dockerfile), and `.env.schema` + `scripts/check-env.sh`
  (the env contract the gate and CI enforce). All skeletons - fill the `<...>` placeholders.
- `src/` and `tests/` skeleton.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. Run it once:

```bash
./setup.sh              # patches package.json scripts + packageManager, writes .nvmrc,
                        # ESLint/Prettier/tsconfig/Vitest/Playwright configs, husky +
                        # lint-staged pre-commit, and installs the dev toolchain
./setup.sh --no-install # config only, skip `pnpm add`
```

It is idempotent and never clobbers existing files. It does **not** scaffold the Next.js app
itself - run `pnpm create next-app .` first (or point it at an existing app).

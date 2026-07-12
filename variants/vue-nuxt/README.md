# Variant: Web app (Vue + Nuxt + pnpm)

The Vue-side sibling of the `web-nextjs` variant: Nuxt (Vue 3, SSR/SSG via Nitro), TypeScript
(strict), Tailwind, Vitest + `@nuxt/test-utils` + Vue Testing Library, Playwright,
ESLint/Prettier, GitHub Actions CI, pnpm.

## Quality gate

```bash
sh scripts/check-env.sh && pnpm lint && pnpm typecheck && pnpm test && pnpm build
```

## What `devblueprint init --variant vue-nuxt` adds

- `docs/engineering/` - git-workflow, conventions (+ Vue/Nuxt/Tailwind overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `pnpm install`).
- `.github/workflows/ci.yml` (quality + Playwright smoke).
- `.github/dependabot.yml` (npm + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for Node/Nuxt.
- `docs/ops/deployment.md` (deploy runbook: managed/Docker/VPS + DB + env checklists) and
  `.env.example` (committed template; real `.env*` stay ignored).
- Ops artifacts: `Dockerfile` (Nitro `.output` -> slim non-root `node .output/server/index.mjs`) +
  `.dockerignore` + `docker-compose.yml`, `deploy/` (Vercel/Render/Fly/Terraform skeletons - Vercel
  is the primary managed target and needs no Dockerfile), and `.env.schema` + `scripts/check-env.sh`
  (the env contract the gate and CI enforce). All skeletons - fill the `<...>` placeholders.
- Nuxt directory skeleton (`pages/`, `components/`, `composables/`, `layouts/`, `server/api/`,
  `utils/`, `assets/css/`) and `tests/`.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. Run it once:

```bash
./setup.sh              # patches package.json scripts + packageManager, writes .nvmrc,
                        # ESLint/Prettier/tsconfig/Vitest/Playwright configs, husky +
                        # lint-staged pre-commit, and installs the dev toolchain
./setup.sh --no-install # config only, skip `pnpm add`
```

It is idempotent and never clobbers existing files. It does **not** scaffold the Nuxt app
itself - run `pnpm create nuxt@latest .` first (or point it at an existing app).

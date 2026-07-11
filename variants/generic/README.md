# Variant: Generic (language-agnostic)

The fallback variant - the full workflow (branching, worktrees, PRs, quality gate) with no
stack assumptions. Use it for CLI tools, scripts, or any language without a dedicated variant.

## Quality gate

```bash
make check   # you wire the lint / typecheck / test / build targets
```

## What `devblueprint init --variant generic` adds

- `docs/engineering/` - git-workflow, conventions, quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md`.
- `scripts/wt.sh` + `scripts/wt.conf` (no-op post-create hook).
- `.github/workflows/ci.yml` (runs `make check`).
- `Makefile` with stub gate targets to fill in (plus a `validate-env` step that runs in `make check`).
- `docs/ops/deployment.md` (deploy runbook: managed/Docker/VPS + DB + env checklists) and
  `.env.example` (committed template; real `.env*` stay ignored).
- Ops artifacts: `Dockerfile` + `.dockerignore` + `docker-compose.yml`, `deploy/` (Fly/Render/
  Terraform skeletons), and `.env.schema` + `scripts/check-env.sh` (the env contract `make check`
  enforces). All skeletons - fill the `<...>` placeholders for your stack.
- `.gitignore` and a `src/` + `tests/` skeleton.

## After init

`init` drops a `setup.sh` in the project. Run it once:

```bash
./setup.sh   # installs a committable .githooks/pre-commit (runs `make lint`) via core.hooksPath
```

Then the truly stack-specific bits it cannot guess:

1. Fill the `Makefile` targets with your real commands; remove any that do not apply.
2. Add your language setup step to `.github/workflows/ci.yml`.
3. Set the `wt_post_create` hook in `scripts/wt.conf` if the project needs a setup step.

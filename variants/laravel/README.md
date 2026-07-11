# Variant: Backend / web app (PHP / Laravel)

A typed-as-you-go PHP web stack: PHP 8.4 on Laravel, Composer for dependencies, Laravel Pint for
formatting and code style, PHPStan/Larastan for static analysis, Pest for tests, and GitHub
Actions CI.

## Quality gate

```bash
vendor/bin/pint --test && vendor/bin/phpstan analyse && vendor/bin/pest
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant laravel` adds

- `docs/engineering/` - git-workflow, conventions (+ PHP/Laravel overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `composer install`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/` - `ci.yml` (Pint + PHPStan + Pest), plus the shared
  `security.yml`, `commit-checks.yml` and `coverage.yml` baseline.
- `.github/dependabot.yml` (composer + github-actions updates) and `.tool-versions` (PHP pin).
- `.gitignore` for vendor, build assets and Laravel runtime state.
- `docs/ops/deployment.md` (deploy runbook: managed/Docker/VPS + DB, env, cache and storage
  checklists) and `.env.example` (committed template; real `.env*` stay ignored).
- Ops artifacts: `Dockerfile` (php-fpm build with Composer -> non-root runtime) + `.dockerignore` +
  `docker-compose.yml` (php-fpm service plus commented nginx and db skeletons), `deploy/` (Fly/
  Render/Terraform skeletons), and `.env.schema` + `scripts/check-env.sh` (the env contract
  `make check` and CI enforce). All skeletons - fill the `<...>` placeholders.
- `app`, `tests` scaffold.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. It cannot create the Laravel application for you -
scaffold that first, then run setup:

```bash
composer create-project laravel/laravel .   # scaffold into the repo root
./setup.sh              # writes pint.json, phpstan.neon, the pre-commit hook
                        # (via core.hooksPath), then runs composer install
./setup.sh --no-install # config only
```

`setup.sh` writes `pint.json` (Laravel preset) and `phpstan.neon` (Larastan, level 6) so
`make check` and CI enforce the gate. Add the dev tooling the gate expects - the exact
`composer require` commands are printed at the end of `setup.sh`. Idempotent; never clobbers
existing files.

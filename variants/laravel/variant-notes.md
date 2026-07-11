## Stack notes (PHP / Laravel)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `composer install` to warm the
  dependency cache). The PHP version is pinned in `.tool-versions` and the composer.json platform
  constraint so local, CI and teammates run one toolchain.
- Layer by responsibility: route -> controller (HTTP boundary) -> action/service (business logic)
  -> Eloquent model / repository (persistence). Keep controllers thin - validate via a Form
  Request, delegate, return a resource; no business rules in the controller.
- Depend on abstractions and let the service container inject them (constructor injection or
  method injection). Bind interfaces to implementations in a service provider so components stay
  explicit and testable without booting the whole framework.
- `pint` owns formatting and code style (Laravel preset, PSR-12 based) - do not hand-format, run
  `pint` to fix. `phpstan`/Larastan owns static analysis; treat a reported error as a build
  failure. Zero errors in CI.
- Validate every request at the boundary with Form Requests or `$request->validate()`; never
  trust input. Use Eloquent bindings / the query builder (never string-concatenated SQL), and
  guard mass assignment with `$fillable`. Escape output in Blade (`{{ }}`, not `{!! !!}`).
- Configuration and secrets come from `.env` read through `config()` (12-factor) - never call
  `env()` outside config files, and never commit real credentials. Ship a `.env.example` with
  safe placeholders.
- Ops artifacts ship as fillable skeletons: a multi-stage `Dockerfile` (a `php:8.3-fpm` build stage
  running `composer install --no-dev --optimize-autoloader` -> a non-root php-fpm runtime) +
  `.dockerignore` + `docker-compose.yml` (a php-fpm `app` service, with a commented nginx `web`
  service since PHP serves behind a web server, and a commented db service), and `deploy/` for a
  hosted target (`fly.toml`, `render.yaml`, `terraform/`). Keep the one target you deploy to and
  delete the rest; the runbook lives in `docs/ops/deployment.md` (covering `php artisan migrate`,
  `config:cache`/`route:cache`, and storage permissions). `APP_KEY` must be generated once with
  `php artisan key:generate` and kept in the platform's secret store, never committed.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`), and `make check` (plus CI) runs `scripts/check-env.sh` to keep `.env.example`
  in lockstep with it and enforce required keys in any real `.env`. Declare new variables in both the
  schema and `.env.example`, or the gate fails.
- User-facing copy lives in `lang/` and is resolved through `__()` / `trans()`, not scattered
  string literals.
- Prefer fast unit/feature tests over slow end-to-end ones. Feature tests boot the framework and
  hit routes with the test client; use `RefreshDatabase` against SQLite so each test owns its
  data. Reserve full external integration for the few paths that truly need it.

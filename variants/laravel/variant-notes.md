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
- User-facing copy lives in `lang/` and is resolved through `__()` / `trans()`, not scattered
  string literals.
- Prefer fast unit/feature tests over slow end-to-end ones. Feature tests boot the framework and
  hit routes with the test client; use `RefreshDatabase` against SQLite so each test owns its
  data. Reserve full external integration for the few paths that truly need it.

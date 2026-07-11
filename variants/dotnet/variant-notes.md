## Stack notes (C# / .NET)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `dotnet restore` to warm the
  NuGet cache). The SDK is pinned in `global.json` so local, CI and teammates build with one
  toolchain.
- Layer by responsibility: `Controller`/endpoint (HTTP boundary) -> service (business logic) ->
  repository (persistence). Keep endpoints thin; keep logic testable in services, not in the web
  layer.
- Constructor injection only - register dependencies in the DI container and inject them through
  the constructor. It keeps components explicit and lets you build them in a plain unit test
  without the host.
- `dotnet format` owns formatting and code style - do not hand-format. Roslyn analyzers own lint;
  `Directory.Build.props` turns on nullable reference types and warnings-as-errors so a warning
  fails the build. Zero warnings in CI.
- Nullable reference types are enabled project-wide - honor the annotations, do not litter `!`
  (null-forgiving); fail fast on invalid input instead of letting a `NullReferenceException`
  surface deep in a call.
- Configuration and secrets come from `appsettings.json` + environment/user-secrets (12-factor),
  never hard-coded. Keep environment overrides in `appsettings.<Environment>.json`; never commit
  real credentials.
- Prefer fast unit tests over spinning up the whole host; reach for `WebApplicationFactory`
  (integration tests) or Testcontainers only when a test genuinely needs the running app or a
  real database.
- Ops artifacts ship as fillable skeletons: a multi-stage `Dockerfile` (SDK `dotnet publish`
  build -> ASP.NET runtime, non-root) + `.dockerignore` + `docker-compose.yml` for containers, and
  `deploy/` for a hosted target (`fly.toml`, `render.yaml`, `terraform/`). Keep the one target you
  deploy to and delete the rest. Run EF Core migrations as a deliberate release step
  (`dotnet ef database update`), never on app boot.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`), and `make check` (plus CI) runs `scripts/check-env.sh` to keep `.env.example`
  in lockstep with it and enforce required keys in any real `.env`. A `__` in a key name binds to a
  nested config section (e.g. `ConnectionStrings__Default` -> `ConnectionStrings:Default`). Declare
  new variables in both the schema and `.env.example`, or the gate fails.

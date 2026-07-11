# Variant: Backend service (C# / .NET)

A typed .NET backend stack: C# on .NET 10 (LTS), the `dotnet` CLI with the SDK pinned in
`global.json`, `dotnet format` for formatting and code style, Roslyn analyzers for static
analysis, xUnit for tests, and GitHub Actions CI.

## Quality gate

```bash
dotnet format --verify-no-changes && dotnet build --configuration Release && dotnet test
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant dotnet` adds

- `docs/engineering/` - git-workflow, conventions (+ C#/.NET overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `dotnet restore`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/ci.yml` (env-schema check + dotnet format + Release build + tests).
- `.github/dependabot.yml` (nuget + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for .NET / MSBuild / test artifacts.
- `docs/ops/deployment.md` (deploy runbook: managed/Docker/VPS + DB + env checklists) and
  `.env.example` (committed template; real `.env*` stay ignored).
- Ops artifacts: `Dockerfile` (SDK build -> ASP.NET runtime, non-root) + `.dockerignore` +
  `docker-compose.yml`, `deploy/` (Fly/Render/Terraform skeletons), and `.env.schema` +
  `scripts/check-env.sh` (the env contract `make check` and CI enforce). All skeletons - fill the
  `<...>` placeholders.
- `src`, `tests` scaffold.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. It cannot create the .NET solution for you - scaffold
that first with the `dotnet` CLI, keeping `global.json` at the repo root. Then run:

```bash
./setup.sh              # writes global.json, Directory.Build.props, the pre-commit
                        # hook (via core.hooksPath), then warms the NuGet cache
./setup.sh --no-install # config only
```

`Directory.Build.props` turns on nullable reference types, warnings-as-errors and the Roslyn
analyzers for every project, so `make check` and CI enforce the gate with no per-`.csproj` wiring.
The exact `dotnet new` commands are printed at the end of `setup.sh`. Idempotent; never clobbers
existing files.

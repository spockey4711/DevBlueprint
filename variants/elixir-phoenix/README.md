# Variant: Backend / web app (Elixir / Phoenix)

A functional, fault-tolerant web stack: Elixir on Phoenix, Hex/mix for dependencies, `mix format`
for formatting, Credo for style and consistency, Dialyzer for success-typing static analysis,
ExUnit for tests, and GitHub Actions CI.

## Quality gate

```bash
mix format --check-formatted && mix credo --strict && mix dialyzer && mix test
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant elixir-phoenix` adds

- `docs/engineering/` - git-workflow, conventions (+ Elixir/Phoenix overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `mix deps.get`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/` - `ci.yml` (format + Credo + Dialyzer + ExUnit), plus the shared
  `security.yml`, `commit-checks.yml` and `coverage.yml` baseline.
- `.github/dependabot.yml` (hex + github-actions updates) and `.tool-versions` (Erlang + Elixir pin).
- `.gitignore` for `_build`, `deps`, the Dialyzer PLT and Phoenix asset output.
- `lib`, `test` scaffold.
- Ops artifacts: a multi-stage `Dockerfile` (a `hexpm/elixir` build stage running `MIX_ENV=prod
  mix release` -> a non-root `debian:bookworm-slim` runtime running the release), `.dockerignore`,
  `docker-compose.yml`, `deploy/` skeletons for Fly.io/Render/Terraform, and a `docs/ops/deployment.md`
  runbook (migrations run as a release command, `bin/app eval "App.Release.migrate"`, never on boot).

## Validated env contract

`.env.example` is paired with a `.env.schema` that declares each variable (`SECRET_KEY_BASE`,
`DATABASE_URL`, `PHX_HOST`, `PORT`, `MIX_ENV`, ...) as required or optional with an optional value
pattern. `make check` runs `scripts/check-env.sh` first (the `validate-env` target) so the example
can never drift from the schema, and a real `.env` is checked for every required key and pattern
before you ship. CI runs the same check as its first step, and `doctor --run-gate` picks it up via
the manifest's `QUALITY_GATE`.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. It cannot create the Phoenix application for you -
scaffold that first, then run setup:

```bash
mix phx.new .           # scaffold into the repo root (add --no-ecto for a DB-less app)
./setup.sh              # writes .formatter.exs, .credo.exs, the pre-commit hook
                        # (via core.hooksPath), then runs mix deps.get
./setup.sh --no-install # config only
```

`setup.sh` writes `.formatter.exs` and `.credo.exs` so `make check` and CI enforce the gate. Add
the dev tooling the gate expects (Credo, Dialyxir, Sobelow, mix_audit) and point Dialyzer at a
cached PLT - the exact `mix.exs` snippets are printed at the end of `setup.sh`. Idempotent; never
clobbers existing files.

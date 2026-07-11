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

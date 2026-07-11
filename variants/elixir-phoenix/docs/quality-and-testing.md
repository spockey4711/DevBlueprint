# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Phoenix app. Concrete overlay of the
blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
mix format --check-formatted   # formatting is canonical (mix format)
mix credo --strict              # style, consistency and complexity (Credo); an issue = failure
mix dialyzer                    # success-typing static analysis (Dialyzer); a warning = failure
mix test                        # unit + integration tests (ExUnit)
```

Everything runs through `mix` on the dependencies pinned by `mix.lock`, so local, CI and teammates
use the same tool versions. Install the pre-commit hook (`setup.sh` wires it via `core.hooksPath`)
and `mix format --check-formatted` + Credo run on every commit. Compile with
`--warnings-as-errors` so a warning is treated as a defect.

## Testing strategy

Test behavior, not the framework. Favor fast tests; only start what a test genuinely needs, and
run them `async: true` wherever the code under test is side-effect free.

- **Unit (ExUnit):** contexts, pure functions, changesets and value logic - call them directly and
  assert on the returned value or result tuple, no endpoint boot.
- **Controller (Phoenix.ConnTest):** exercise the real request pipeline (`get`/`post` on a `conn`)
  - routing, plugs, params, the controller and the rendered response - in-process.
- **LiveView (Phoenix.LiveViewTest):** drive mounts, events and rendered updates for interactive
  views without a browser.
- **Database:** back data tests with `Ecto.Adapters.SQL.Sandbox` so each test owns its transaction
  and rolls back; this keeps data tests `async: true`. Reach for a shared/real connection only for
  behavior the sandbox cannot model.
- **External services:** stub behind a behaviour (swap the implementation via config, e.g. Mox)
  instead of hitting the network.

Target meaningful coverage of the context and web layers and the domain rules - not a global
percentage, and not framework glue or generated code.

## Tooling

- **Erlang/OTP + Elixir (versions pinned in `.tool-versions` + mix.exs)** - the runtime and
  language; used everywhere.
- **Hex / mix** - dependency manager and task runner; `mix.lock` is committed so installs are
  reproducible.
- **mix format** - the single formatter (rules in `.formatter.exs`); `mix format` fixes,
  `mix format --check-formatted` gates. No hand-formatting.
- **Credo** - style, consistency and complexity analysis; `mix credo --strict` gates, config in
  `.credo.exs`.
- **Dialyzer (via Dialyxir)** - success-typing static analysis over a cached PLT; a reported
  warning fails the gate.
- **ExUnit** - the built-in test framework, with `Phoenix.ConnTest` / `Phoenix.LiveViewTest` for
  the web layer and `Ecto.Adapters.SQL.Sandbox` for data.
- **Sobelow + mix_audit** - Phoenix-focused security scanning (`mix sobelow`) and dependency
  advisory checks (`mix deps.audit`); run them alongside the gate and in the security workflow's
  spirit.
- **pre-commit hook** - `.githooks/pre-commit` runs `mix format --check-formatted` + Credo on commit.
- **CI** - `.github/workflows/ci.yml` runs the full gate on every PR into `develop`/`master`.

## Definition of done

1. It works, the route/behavior does what the task asked, and errors are handled deliberately
   (result tuples, supervised processes) rather than swallowed.
2. mix format, Credo, Dialyzer and the tests are green; new logic is covered at the right layer.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.

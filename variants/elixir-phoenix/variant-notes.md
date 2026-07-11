## Stack notes (Elixir / Phoenix)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `mix deps.get` to warm the
  dependency cache). The Erlang/OTP and Elixir versions are pinned in `.tool-versions` and the
  mix.exs `elixir` constraint so local, CI and teammates run one toolchain.
- Layer by responsibility: router -> controller (HTTP boundary) -> context module (business logic
  and the public API of a domain) -> Ecto schema / repo (persistence). Keep controllers thin -
  validate params, call a context function, render; no business rules or direct `Repo` calls in
  the controller.
- Contexts are the seam: a controller, a LiveView and a background job all go through the same
  context function, never around it into another context's schemas. This keeps domains decoupled
  and the code testable without the endpoint.
- `mix format` owns formatting (rules in `.formatter.exs`) - do not hand-format, run `mix format`
  to fix. Credo owns style/consistency/complexity (`mix credo --strict`); Dialyzer owns
  success-typing static analysis (`mix dialyzer`). Treat a reported issue as a build failure -
  zero in CI.
- Validate every request at the boundary with an Ecto changeset (`cast/3` + `validate_*`); never
  trust input. Query through Ecto (parameterized) - never string-interpolate into `fragment`.
  Escape output in HEEx (`<%= %>` auto-escapes; reserve `raw/1` for values you have deliberately
  sanitized). Keep the CSRF plug on for stateful forms.
- Configuration and secrets come from the environment read in `config/runtime.exs` (12-factor) -
  never commit real credentials, and never read `System.get_env/1` scattered through the app.
  Ship a `.env.example` (or documented env keys) with safe placeholders.
- Validated env contract: `.env.schema` declares each variable (`SECRET_KEY_BASE`, `DATABASE_URL`,
  `PHX_HOST`, `PORT`, `MIX_ENV`, ...) as required or optional with an optional value pattern.
  `make check` runs `scripts/check-env.sh` first so `.env.example` and the schema stay in lockstep
  and any real `.env` is checked for required keys and patterns; CI and `doctor --run-gate` run the
  same check.
- Ops artifacts: the shipped `Dockerfile` is a two-stage build - a `hexpm/elixir` stage that fetches
  prod deps, runs `mix assets.deploy` and `MIX_ENV=prod mix release`, then a non-root
  `debian:bookworm-slim` runtime running the self-contained release (its ERTS is bundled, so no
  Elixir/Erlang install in the final image). `deploy/` carries Fly.io/Render/Terraform skeletons
  (Fly.io is the common Phoenix target) and `docs/ops/deployment.md` is the runbook. Run Ecto
  migrations as a deliberate release command (`bin/app eval "App.Release.migrate"`), never on boot -
  a release has no `mix`, and coupling migrations to boot makes rollbacks unsafe.
- User-facing copy lives in `priv/gettext/*.po` and is resolved through the `gettext/1` macro, not
  scattered string literals in controllers and templates.
- Let it crash: supervise stateful processes and let a supervisor restart them rather than
  defensively rescuing everywhere. Reserve `try`/`rescue` for truly exceptional boundaries;
  model expected failure with `{:ok, _}` / `{:error, _}` tuples and `with`.
- Prefer fast ExUnit tests over slow end-to-end ones. Unit-test contexts and pure functions
  directly; use `Phoenix.ConnTest` for controllers and `Phoenix.LiveViewTest` for LiveViews. Back
  data tests with `Ecto.Adapters.SQL.Sandbox` so each test owns its transaction and runs
  `async: true`.

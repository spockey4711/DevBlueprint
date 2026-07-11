
---

## Stack-specific conventions (Elixir / Phoenix)

### Language & tooling

- **One pinned toolchain.** Pin Erlang/OTP and Elixir in `.tool-versions` and the mix.exs
  `elixir` constraint; fetch dependencies through Hex/mix so everyone shares one lockfile
  (`mix.lock` is committed).
- **`mix format`** owns formatting (rules in `.formatter.exs`) - do not hand-format, run
  `mix format` to fix and `mix format --check-formatted` to gate. **Credo** owns style,
  consistency and complexity (`mix credo --strict`); **Dialyzer** owns success-typing static
  analysis (`mix dialyzer`). A reported issue fails the build. Zero in CI.
- **Compile clean.** Build with `--warnings-as-errors`; a warning is a defect. Add typespecs
  (`@spec`) to public functions so Dialyzer has contracts to check, and prefer pattern matching
  in heads over defensive conditionals in the body.

### Structure & Phoenix idioms

- Layer by responsibility: router -> controller/LiveView (HTTP/UI boundary) -> context (business
  logic and the domain's public API) -> Ecto schema / `Repo` (persistence). Controllers and
  LiveViews stay thin - handle params, call a context function, render; no business rules and no
  direct `Repo` calls.
- **Contexts are the boundary between domains.** Call another domain only through its context's
  public functions, never by reaching into its schemas. This keeps domains decoupled and testable
  without the endpoint.
- **Validate at the boundary** with an Ecto changeset (`cast/3` + `validate_*`); never trust
  input. Return `{:ok, _}` / `{:error, changeset}` and let the caller branch with `with`.
- **Let it crash.** Supervise stateful processes and let a supervisor restart them instead of
  defensively rescuing everywhere. Reserve `try`/`rescue` for genuinely exceptional boundaries;
  model expected failure with result tuples, not exceptions.

### Data & security

- Query through Ecto (parameterized) - never string-interpolate user input into `fragment` or
  raw SQL. Manage schema with versioned migrations; never edit a shipped migration, add a new one.
- Escape output in HEEx - `<%= %>` auto-escapes; reserve `raw/1` for values you have deliberately
  sanitized. Keep the CSRF plug on for stateful forms and scope queries to the current user.
- Read config in `config/runtime.exs` from the environment (12-factor); keep compile-time config
  in `config/config.exs` / `config/<env>.exs`. No secrets in code, logs or committed config - ship
  a `.env.example` (or documented env keys) with safe placeholders.

### Naming

- Modules `PascalCase`, namespaced by domain and role (`MyApp.Accounts`, `MyApp.Accounts.User`,
  `MyAppWeb.UserController`, `MyAppWeb.UserLive`); the `*Web` namespace holds the web layer, the
  app namespace the domains. One module per file, path mirroring the module.
- Functions, variables and atoms `snake_case`; a trailing `?` for predicates (`active?`) and `!`
  for the raise-on-failure variant (`create_user!`). Module attributes and constants `@snake_case`.
- Ecto schemas singular (`User`), tables `snake_case` plural (`users`), columns `snake_case`.
  Context modules read as the domain (`Accounts`, `Billing`), not `*Service` / `*Manager`.


---

## Stack-specific conventions (Ruby on Rails)

### Language & tooling

- **Ruby 3.4, one pinned interpreter.** Pin the version in `.ruby-version` and `.tool-versions`;
  install gems through Bundler so everyone shares one toolchain. `Gemfile.lock` is committed and
  authoritative.
- **RuboCop (`rubocop-rails-omakase`)** owns formatting and code style - do not hand-format, run
  `bundle exec rubocop -A` to fix. Keep project overrides in `.rubocop.yml` minimal and justified.
  Zero offenses in CI.
- **Brakeman** runs on every commit and in CI - it is part of the gate, not an optional scan. Fix
  or explicitly annotate findings (mass assignment, SQL injection, unsafe redirects); do not
  silence them wholesale.

### Structure & Rails idioms

- Convention over configuration - follow the framework's layout and naming. **Fat model, skinny
  controller:** controllers parse params, call into a model or plain service object, and
  render/redirect; business rules live in models or `app/services`, never in the controller.
- Persistence is ActiveRecord: manage schema with reversible migrations (never edit `schema.rb`
  by hand), and put reusable query logic in named scopes. Guard against N+1 with
  `includes`/`preload`; always scope finders to the current user or tenant.
- Return view models / presenters or serializers (e.g. Jbuilder, ActiveModel::Serializer) from
  controllers rather than leaking raw records into an API contract. Keep view logic in helpers or
  presenters, not in ERB.
- Push slow or side-effectful work (email, external calls) into background jobs (ActiveJob /
  Solid Queue), not the request cycle. Make jobs idempotent and retry-safe.

### Security & data

- **Never trust params.** Use Strong Parameters (`params.require(...).permit(...)`) for every mass
  assignment and validate in the model. Rely on parameterized ActiveRecord queries - never
  string-interpolate SQL. Rails auto-escapes ERB output; reach for `html_safe`/`raw` only on
  content you control.
- Read secrets from encrypted credentials (`config/credentials`) and environment variables
  (12-factor); commit the encrypted files, never the `master.key`. No secrets in code, logs or
  committed config.
- Guard controllers with authentication and per-action authorization (e.g. Pundit / a policy
  object); do not rely on hiding a link. Set CSRF protection and strong headers (the Rails
  defaults) and keep them on.

### Copy & naming

- User-facing strings live in `config/locales/*.yml` and resolve through `I18n.t` / the `t`
  helper - do not scatter literals through controllers and views.
- Follow Rails naming: models `CamelCase` singular (`Order`) over `snake_case` plural tables
  (`orders`); controllers plural (`OrdersController`); files and methods `snake_case`; constants
  `SCREAMING_SNAKE_CASE`. Name service objects by their verb (`CreateOrder`, `SettleInvoice`).

## Stack notes (Ruby on Rails)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `bundle install` to install
  gems). Ruby is pinned in `.ruby-version` so local, CI and teammates run one interpreter; gems
  are locked in `Gemfile.lock`.
- Follow Rails conventions - convention over configuration. Fat model, skinny controller: keep
  business logic in models / plain service objects (`app/services`), keep controllers thin
  (params -> call -> render/redirect). Extract query logic into scopes, not controllers.
- ActiveRecord is the persistence layer - manage schema with reversible migrations, never edit
  `schema.rb` by hand. Guard against N+1 with `includes`/`preload`; scope every finder to the
  current user/tenant to avoid leaking records.
- Never trust params: use Strong Parameters (`params.require(...).permit(...)`) for mass
  assignment, and validate in the model. Escape output (Rails auto-escapes ERB) and rely on
  parameterized ActiveRecord queries - never string-interpolate SQL.
- RuboCop (the `rubocop-rails-omakase` ruleset) owns formatting and lint - do not hand-format,
  run `bundle exec rubocop -A`. Brakeman scans for security issues on every commit and in CI.
  Zero offenses in CI.
- Configuration and secrets come from `config/credentials` (encrypted) and environment variables
  (12-factor), never hard-coded. Commit the encrypted credentials, never the `master.key`.
- User-facing copy lives in `config/locales/*.yml` and is resolved through `I18n.t` / the `t`
  helper - do not scatter string literals through controllers and views.
- Test with Minitest (the Rails default): fast model/unit tests plus fixtures for the DB, and
  reserve system tests (Capybara) for the handful of flows that genuinely need a browser.
- Ops artifacts ship as fillable skeletons: a multi-stage `Dockerfile` (`ruby:3.3-slim` build stage
  running `bundle install` + `rails assets:precompile` -> a slim non-root Puma runtime) +
  `.dockerignore` + `docker-compose.yml` (with commented postgres/redis services) for containers,
  and `deploy/` for a hosted target (`fly.toml`, `render.yaml`, `terraform/`). Keep the one target
  you deploy to and delete the rest. Run `rails db:migrate` as a deliberate release step (Fly's
  `release_command`, Render's `preDeployCommand`, a VPS deploy hook), never on boot.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`), and `make check` (plus CI) runs `scripts/check-env.sh` to keep `.env.example`
  in lockstep with it and enforce required keys in any real `.env`. Declare new variables in both the
  schema and `.env.example`, or the gate fails. `SECRET_KEY_BASE` and `RAILS_MASTER_KEY` are secrets -
  they belong in the platform's secret store, never in git.

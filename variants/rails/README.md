# Variant: Web app (Ruby on Rails)

A full-stack Ruby on Rails web app: Ruby 3.4 (pinned in `.ruby-version`), Rails 8, Bundler for
dependencies, RuboCop (the `rubocop-rails-omakase` ruleset) for formatting and lint, Brakeman for
security scanning, Minitest for tests, and GitHub Actions CI.

## Quality gate

```bash
bundle exec rubocop && bundle exec brakeman -q --no-pager && bundle exec rails test
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant rails` adds

- `docs/engineering/` - git-workflow, conventions (+ Rails overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `bundle install`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/ci.yml` (RuboCop + Brakeman + tests).
- `.github/dependabot.yml` (bundler + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for Rails runtime, assets and local artifacts.
- `app`, `lib`, `test` scaffold.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. It cannot create the Rails app for you - scaffold that
first with the `rails` CLI into the project directory. Then run:

```bash
./setup.sh              # writes .ruby-version, .rubocop.yml, the pre-commit hook
                        # (via core.hooksPath), then installs gems (bundle install)
./setup.sh --no-install # config only
```

Rails 8 already adds `rubocop-rails-omakase` and `brakeman` to a new app's Gemfile, so the
`.rubocop.yml` written here inherits that ruleset once the gems are bundled. The exact `rails new`
command is printed at the end of `setup.sh`. Idempotent; never clobbers existing files.

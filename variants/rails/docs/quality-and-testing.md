# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Rails app. Concrete overlay of the
blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
bundle exec rubocop                 # formatting + code style (rubocop-rails-omakase)
bundle exec brakeman -q --no-pager  # static security scan (injection, mass assignment, ...)
bundle exec rails test              # unit + integration tests (Minitest)
```

Everything runs on the Ruby pinned in `.ruby-version` with gems from `Gemfile.lock`, so local, CI
and teammates use the same toolchain. Install the pre-commit hook (`setup.sh` wires it via
`core.hooksPath`) and `bundle exec rubocop` runs on every commit.

## Testing strategy

Test behavior, not the framework. Favor fast tests that do not boot a browser.

- **Model / unit (Minitest):** validations, scopes, business rules and service objects - build
  the object directly and assert on its behavior. Back DB-touching tests with fixtures so each
  test owns its data.
- **Controller / integration (`ActionDispatch::IntegrationTest`):** exercise the real request
  pipeline (routing, params, filters, rendering) in-memory - assert status codes, redirects and
  the response body, including the unhappy paths (validation failures, missing records, auth).
- **System (Capybara + headless driver):** reserve for the handful of end-to-end flows that
  genuinely need a browser (JavaScript, multi-step forms). They are the slowest tier - keep them
  few and focused.
- **Jobs / mailers:** test enqueued jobs and mailer content with the Rails test adapters rather
  than performing real work.

Target meaningful coverage of models, controllers and service objects - not a global percentage,
and not framework glue or generated scaffolding.

## Tooling

- **Ruby (pinned in `.ruby-version`) + Bundler** - one interpreter and a locked `Gemfile.lock`,
  used everywhere.
- **RuboCop (`rubocop-rails-omakase`)** - the single formatter and linter; `rubocop -A` fixes,
  a plain `rubocop` gates. No hand-formatting.
- **Brakeman** - static security analysis for Rails, run on commit and in CI; part of the gate.
- **Minitest** - the test framework (the Rails default), driven by `bin/rails test`, with
  fixtures and system tests via the generators.
- **pre-commit hook** - `.githooks/pre-commit` runs `bundle exec rubocop` on commit.
- **CI** - `.github/workflows/ci.yml` runs the full gate on every PR into `develop`/`master`.

## Provider-agnostic CI (GitLab)

The kit is not GitHub-only. Each project also ships a `.gitlab-ci.yml` that mirrors
the same gates, so it can live on either forge:

- **`quality`** stage - runs the quality gate above.
- **`security`** stage - GitLab's managed SAST, secret detection and dependency
  scanning, the GitLab-native counterpart to the GitHub security gate.
- **`deploy`** stage - the `deploy:preview` job (below).

`workflow:` rules run the pipeline on merge requests and the protected branches
without spawning duplicate pipelines. Delete `.gitlab-ci.yml` if the project is
hosted on GitHub only.

## Preview deploy

A provider-neutral preview environment ships for both forges - `preview-deploy.yml`
on GitHub and the `deploy:preview` job on GitLab. On every PR/MR it stands up an
ephemeral environment and comments its URL, then tears it down when the PR/MR
closes. The plumbing is wired; only the deploy step is a TODO, so point it at your
host (Vercel, Netlify, GitHub/GitLab Pages, Fly, ...).

## Definition of done

1. It works, the endpoint/behavior does what the task asked, and errors are handled deliberately.
2. RuboCop, Brakeman and the tests are green; new logic is covered at the right layer.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.

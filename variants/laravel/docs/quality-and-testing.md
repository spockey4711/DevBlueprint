# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Laravel app. Concrete overlay of the
blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
vendor/bin/pint --test       # formatting + code style are canonical (Laravel preset)
vendor/bin/phpstan analyse    # static analysis (PHPStan + Larastan); reported error = failure
vendor/bin/pest               # unit + feature tests (Pest)
```

Everything runs through the Composer-installed binaries in `vendor/bin`, pinned by
`composer.lock`, so local, CI and teammates use the same tool versions. Install the pre-commit
hook (`setup.sh` wires it via `core.hooksPath`) and Pint + PHPStan run on every commit.

## Testing strategy

Test behavior, not the framework. Favor fast tests; only boot what a test genuinely needs.

- **Unit (Pest):** actions, services, value objects, domain rules - construct them directly and
  assert on the result, no framework boot or database.
- **Feature (Pest + Laravel):** exercise the real request pipeline (`$this->get/post(...)`) -
  routing, middleware, validation, controllers, the container - in-process. Back them with
  `RefreshDatabase` against SQLite so each test owns its data.
- **Database:** prefer the in-memory SQLite connection for speed; reach for the real engine (via a
  service container / Docker) only for engine-specific behavior.
- **HTTP contract:** assert status codes, the JSON shape (`assertJson` / `assertJsonStructure`)
  and validation-error responses, not just the happy path. Cover authorization failures too.
- **External services:** fake them (`Http::fake()`, `Queue::fake()`, `Mail::fake()`) instead of
  hitting the network.

Target meaningful coverage of the controller/service and domain layers and the HTTP contract - not
a global percentage, and not framework glue or generated code.

## Tooling

- **PHP (version pinned in `.tool-versions` + composer.json)** - the runtime; used everywhere.
- **Composer** - dependency manager; `composer.lock` is committed so installs are reproducible.
- **Laravel Pint** - the single formatter and code-style fixer (Laravel preset, PSR-12 based);
  `pint` fixes, `pint --test` gates. No hand-formatting.
- **PHPStan + Larastan** - static analysis with Laravel awareness; level set in `phpstan.neon`,
  a reported error fails the gate.
- **Pest** - the test framework (built on PHPUnit), with the Laravel plugin for HTTP/database
  helpers. `php artisan test` runs the same suite.
- **pre-commit hook** - `.githooks/pre-commit` runs `pint --test` + `phpstan analyse` on commit.
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

1. It works, the route/behavior does what the task asked, and errors are handled deliberately.
2. Pint, PHPStan and the tests are green; new logic is covered at the right layer.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.

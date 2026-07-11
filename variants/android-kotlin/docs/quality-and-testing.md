# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Android/Kotlin app. Concrete overlay
of the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
./gradlew ktlintCheck        # lint + formatting is canonical - zero warnings
./gradlew detekt             # static analysis - findings fail the build
./gradlew lintDebug          # Android Lint - platform/resource/manifest issues
./gradlew testDebugUnitTest  # JVM unit tests
```

Everything runs through the Gradle wrapper (`./gradlew`) so the build is reproducible across local,
CI and teammates. Install the pre-commit hook (`./setup.sh`) and ktlint + detekt run on commit.

## Testing strategy

Test what has logic or can silently break; do not chase coverage on Composable layout code.

- **Unit (JUnit, on the JVM):** `ViewModel`s, use-cases/reducers, mappers, formatters, repository
  logic behind interfaces. Fast and deterministic - fake the data sources, control coroutine
  dispatchers with a test dispatcher, seed any randomness.
- **Instrumented / UI (androidTest), a few only:** critical Compose flows via `createComposeRule`
  and a smoke test that the app launches and primary navigation works. Keep the suite small -
  instrumented tests are slow and flaky by nature.
- Inject dependencies via interfaces so units test without the network, the real DB or the emulator.

Target: meaningful coverage of `ViewModel`s and the domain/data layer, not a global percentage or
Compose UI code.

## Tooling

- **ktlint** - lint + formatter for Kotlin, wired via the Gradle plugin; config in `.editorconfig`.
- **detekt** - static analysis; config in `config/detekt/detekt.yml`, findings fail the build.
- **Android Lint** - `lintDebug` for platform, resource and manifest problems.
- **JUnit** - unit specs in `app/src/test`; instrumented specs in `app/src/androidTest`.
- **pre-commit** - a committable `.githooks/pre-commit` (via `core.hooksPath`) runs ktlint + detekt
  on staged Kotlin.
- **Gradle** - the wrapper (`./gradlew`) pins the build; `gradle/actions/setup-gradle` caches it in CI.
- **CI** - `.github/workflows/ci.yml` runs the full gate on JDK 17 for every PR into
  `develop`/`master`.

## Accessibility & release

- Manual accessibility pass before a release: TalkBack labels on interactive elements, sufficient
  contrast, large-font and dark-theme layouts, touch targets >= 48dp.
- Release checklist: `versionCode`/`versionName` bumped, ProGuard/R8 rules verified on a release
  build, a signed `assembleRelease` / `bundleRelease` produced, and an internal-track smoke pass.

## Security and commit gates

Every PR also runs the security-gate baseline in `.github/workflows/` (shared
across variants), complementing the quality gate above:

- **`security.yml`** - gitleaks secret scanning, semgrep SAST, and (on PRs)
  `dependency-review` against the GitHub Advisory Database.
- **`codeql.yml`** - GitHub CodeQL semantic analysis; findings surface under
  Security > Code scanning.
- **`commit-checks.yml`** - commitlint on every commit plus a Conventional-Commits
  check on the PR title (the squash-merge subject).
- **`coverage.yml`** - reports line coverage and enforces a soft floor read from
  the `COVERAGE_MIN` repository variable (default `0`, i.e. report-only), so the
  threshold is opt-in and never reddens a fresh scaffold.

## Release automation

On every push to `master`, `release.yml` runs
[release-please](https://github.com/googleapis/release-please), turning the
Conventional-Commits history into releases and closing the loop on the changelog
discipline above:

- It maintains a standing **release PR** whose diff is the next SemVer bump plus
  the generated `CHANGELOG.md` entries (`feat` -> minor, `fix`/`perf` -> patch,
  `BREAKING CHANGE` -> major). Merging that PR tags the release and publishes a
  GitHub Release.
- `release-please-config.json` pins the release strategy to `simple` - release-please has no native updater for this stack, so the
  version lives in `release-please-manifest.json` alone. Add your build's
  version file (e.g. `gradle.properties`, `*.csproj`, `Info.plist`) to
  `extra-files` in the config to have that bumped in the same PR.
- This automates the manual "move `[Unreleased]`, tag, publish" steps in the git
  workflow: let the merged commits drive `CHANGELOG.md` instead of hand-editing it.

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

1. It works and matches the design/Material/accessibility specs.
2. ktlint, detekt, Android Lint and the unit tests are green.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR and is shippable to an internal track.

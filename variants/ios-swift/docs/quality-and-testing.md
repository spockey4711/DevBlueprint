# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Swift/iOS app. Concrete overlay of
the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing; CI runs the identical set on every PR:

```bash
swiftformat --lint .   # formatting is canonical
swiftlint --strict     # lint - warnings fail the build
swift build            # compiles (SPM); use xcodebuild for an app target
swift test             # unit tests
```

For an `.xcodeproj`/`.xcworkspace` app, swap the last two for `xcodebuild ... build test`
against a simulator destination.

## Testing strategy

Test what has logic or can silently break; do not chase coverage on SwiftUI view bodies.

- **Unit (XCTest / Swift Testing):** view models, reducers/stores, formatters, persistence and
  networking layers behind protocols so they can be faked. Pure logic first.
- **UI smoke (XCUITest), a few only:** the app launches, primary navigation works, one critical
  flow completes. Keep the suite small - UI tests are slow and flaky by nature.
- Inject dependencies via protocols so units test without the network or the real store.

Target: meaningful coverage of view models and the domain layer, not a global percentage.

## Tooling

- **SwiftFormat** - canonical formatting, enforced with `--lint` in CI.
- **SwiftLint** - `--strict` so warnings fail. Config in `.swiftlint.yml`.
- **XCTest / Swift Testing** - unit tests in `Tests/UnitTests`, UI in `Tests/UITests`.
- **pre-commit** - a git hook runs SwiftFormat + SwiftLint on staged files.
- **CI** - `.github/workflows/ci.yml` runs format, lint, build and test on a macOS runner for
  every PR into `develop`/`master`; `.github/dependabot.yml` keeps Swift packages + Actions current.

## Accessibility & release

- Manual accessibility pass before a release: Dynamic Type, VoiceOver labels on interactive
  elements, sufficient contrast, reduced-motion honored.
- App Store release checklist (see `docs/operations/app-store-readiness.md` if present):
  version/build bumped, screenshots current, privacy nutrition labels accurate, TestFlight
  smoke pass.

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

## Definition of done

1. It works and matches the design/HIG/accessibility specs.
2. format, lint, build, test are green.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR and is shippable via TestFlight.

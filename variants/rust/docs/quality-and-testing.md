# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Rust project. Concrete overlay of the
blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
cargo fmt --check                                        # formatting is canonical
cargo clippy --all-targets --all-features -- -D warnings # lint + type-aware analysis, zero warnings
cargo test --all-features                                # unit + integration tests
```

clippy compiles the crate, so it doubles as the type check - there is no separate typecheck step.
Install the pre-commit hook (`setup.sh` wires `.githooks/pre-commit` via `core.hooksPath`) and
`make lint` runs on every commit; the full gate runs in CI.

## Testing strategy

Test what has logic or can silently break.

- **Unit (`#[cfg(test)]`):** functions and methods with real logic - parsing, transforms,
  state machines, error paths. Deterministic; seed any randomness.
- **Integration (`tests/`):** exercise the crate through its public API, the way a consumer would,
  to catch API-shape regressions the unit tests miss.
- **Doctests:** examples in `///` docs that compile and run, so the documented usage cannot rot.
- Cover the error branches, not just the happy path - a `Result`-returning function should have a
  test that drives it into the `Err` arm.

Target: meaningful coverage of the library's logic and error handling, not a global percentage.

## Tooling

- **rustfmt** - the canonical formatter. Config in `rustfmt.toml`. `cargo fmt --check` in CI.
- **clippy** - lint + type-aware analysis, run with `pedantic` and warnings denied
  (`-D warnings`). Any `#[allow(...)]` carries a justifying comment.
- **cargo test** - the built-in test runner for unit, integration and doc tests.
- **rustup / rust-toolchain.toml** - pins the toolchain channel and components (rustfmt, clippy) so
  local and CI agree; `.tool-versions` mirrors it for asdf/mise.
- **pre-commit** - a committable `.githooks/pre-commit` (wired by `setup.sh` via `core.hooksPath`)
  runs `make lint` before each commit.
- **CI** - `.github/workflows/ci.yml` runs the full gate on every PR into `develop`/`master`.

## Security and commit gates

Every PR also runs the security-gate baseline in `.github/workflows/` (shared
across variants), complementing the quality gate above:

- **`security.yml`** - gitleaks secret scanning, semgrep SAST, and (on PRs)
  `dependency-review` against the GitHub Advisory Database.
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
- `release-please-config.json` pins the release strategy to `rust`, so it also bumps the version in `Cargo.toml` in the release PR.
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

1. It works and the public behaviour matches what the task asked for.
2. rustfmt, clippy (zero warnings) and cargo test are green.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.

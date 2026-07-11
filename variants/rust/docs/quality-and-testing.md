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

## Definition of done

1. It works and the public behaviour matches what the task asked for.
2. rustfmt, clippy (zero warnings) and cargo test are green.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.

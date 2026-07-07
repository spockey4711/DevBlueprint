# Variant: Rust (cargo)

A typed, reproducible Rust stack: a library-first crate layout, rustfmt (formatting), clippy
(lint + type-aware analysis, `pedantic`, warnings denied), `cargo test` (unit + integration +
doctests), a pinned toolchain, and GitHub Actions CI.

## Quality gate

```bash
cargo fmt --check && cargo clippy --all-targets --all-features -- -D warnings && cargo test
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant rust` adds

- `docs/engineering/` - git-workflow, conventions (+ Rust overlay), quality-and-testing,
  engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `cargo fetch`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/ci.yml` (rustfmt + clippy + cargo test).
- `.github/dependabot.yml` (cargo + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for Rust / cargo artifacts.
- `src/`, `tests/` scaffold.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. Run it once:

```bash
./setup.sh              # writes Cargo.toml (edition + lints), rust-toolchain.toml, rustfmt.toml,
                        # a minimal src/lib.rs, installs the pre-commit hook, then `cargo fetch`
./setup.sh --no-install # config only
```

Idempotent; never clobbers existing files.


---

## Stack-specific conventions (Rust)

### Language & tooling

- **rustfmt owns formatting; clippy owns lint** - do not hand-format. clippy runs with `pedantic`
  on and warnings denied in CI (`-D warnings`); fix or `#[allow(...)]` with a justifying comment,
  never leave a warning.
- Pin the edition and toolchain: `edition` and `rust-version` in `Cargo.toml`, the channel in
  `rust-toolchain.toml`, and the same version in `.tool-versions`. Bump them together.
- `Cargo.lock` is committed so builds and CI are reproducible.

### Error handling & safety

- Return `Result<T, E>` on any recoverable path; no `unwrap`/`expect`/`panic!` in library code
  (tests and `main` glue may `expect` with a message that explains the invariant). Use `?` to
  propagate.
- Model errors with an enum (e.g. `thiserror`) in libraries; `anyhow` is fine in binaries. Add
  context as errors cross a boundary rather than swallowing them.
- `unsafe` is `forbid`den by default. If a crate genuinely needs it, scope the opt-in narrowly and
  document every block with a `// SAFETY:` comment stating the upheld invariant.

### Modules & API

- `snake_case` modules, functions and variables; `PascalCase` types and traits;
  `SCREAMING_SNAKE_CASE` constants.
- Keep the public surface small: default to private, expose with `pub` deliberately. Document every
  public item with a `///` doc comment, and prefer doctests that compile.
- Reusable logic lives in the library crate; binaries stay thin wrappers over it.

### Testing

- Unit tests live in-module behind `#[cfg(test)]`; integration tests that exercise the public API
  live under `tests/`. Keep tests deterministic - seed any randomness.
- Read paths, credentials and configuration from the environment or a config layer - no secrets in
  code, logs or committed files (12-factor).

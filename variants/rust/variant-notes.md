## Stack notes (Rust / cargo)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `cargo fetch` to warm the
  cache). Do all work inside the printed worktree path.
- Layered: keep reusable logic in a library crate (`src/lib.rs` + modules); binaries (`src/main.rs`,
  `src/bin/`) stay thin and call into the library so the logic is unit-testable.
- **clippy is the lint and the type-aware analysis** (`-D warnings` in CI); rustfmt owns formatting.
  Never hand-format - run `cargo fmt`.
- No `unwrap`/`expect`/`panic!` on recoverable paths in library code - return `Result`. `unsafe` is
  forbidden by default in `Cargo.toml`; opt in per crate only with a documented `// SAFETY:` note.
- Toolchain is pinned in `rust-toolchain.toml` (native) and `.tool-versions` (asdf/mise); keep both
  and `Cargo.toml`'s `rust-version` in step. `Cargo.lock` is committed for reproducible builds.

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
- Read config from the environment (12-factor); no secrets in code, logs or committed files.
- Ops artifacts ship as fillable skeletons: a multi-stage `Dockerfile` (`cargo build --release`
  binary -> distroless non-root, with a musl/`scratch` static option in a comment) + `.dockerignore` +
  `docker-compose.yml` for containers, and `deploy/` for a hosted target (`fly.toml`, `render.yaml`,
  `terraform/`). Keep the one target you deploy to and delete the rest.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`), and `make check` (plus CI) runs `scripts/check-env.sh` to keep `.env.example`
  in lockstep with it and enforce required keys in any real `.env`. Declare new variables in both the
  schema and `.env.example`, or the gate fails.

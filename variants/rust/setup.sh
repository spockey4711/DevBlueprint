#!/usr/bin/env bash
# setup.sh - wire the Rust/cargo toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + `cargo fetch` + install pre-commit hook
#   ./setup.sh --no-install # wire config only
set -euo pipefail

DO_INSTALL=1
[ "${1:-}" = "--no-install" ] && DO_INSTALL=0

say() { printf '  %s\n' "$*"; }
write_if_absent() {
  if [ -e "$1" ]; then say "skip $1 (exists)"; return 0; fi
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  say "wrote $1"
}

PROJECT="$(basename "$PWD")"
RUST_VERSION="1.83.0"

echo "Wiring the Rust toolchain..."

# --- toolchain pin -----------------------------------------------------------
# rust-toolchain.toml is the native pin cargo/rustup honor; .tool-versions (from
# the variant's extras/) is the asdf/mise mirror. Keep the two in step.
write_if_absent rust-toolchain.toml <<EOF
[toolchain]
channel = "$RUST_VERSION"
components = ["rustfmt", "clippy"]
EOF

# --- Cargo.toml (package + workspace lints) ----------------------------------
# Lints live in [lints] so clippy/rustc pick them up for every target without a
# crate-level attribute. unsafe is forbidden by default; opt in per-crate if you
# genuinely need it and document each block with a // SAFETY: comment.
write_if_absent Cargo.toml <<EOF
[package]
name = "$PROJECT"
version = "0.1.0"
edition = "2021"
rust-version = "$RUST_VERSION"

[dependencies]

[lints.rust]
unsafe_code = "forbid"

[lints.clippy]
all = "warn"
pedantic = "warn"
EOF

# --- rustfmt config ----------------------------------------------------------
write_if_absent rustfmt.toml <<'EOF'
edition = "2021"
max_width = 100
EOF

# --- minimal crate root so cargo has something to build ----------------------
# init drops an empty src/; give it a library root (with a test) so `cargo test`
# and clippy are green from the first commit. Replace with real code.
if [ -z "$(find src -name '*.rs' 2>/dev/null | head -n 1)" ]; then
  write_if_absent src/lib.rs <<'EOF'
//! Crate root. Replace with your library, or add a `src/main.rs` for a binary.

/// Adds two numbers. Placeholder - delete once you have real code.
#[must_use]
pub fn add(a: i64, b: i64) -> i64 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::add;

    #[test]
    fn adds() {
        assert_eq!(add(2, 2), 4);
    }
}
EOF
fi

# --- pre-commit hook (committable, via core.hooksPath) -----------------------
# `make lint` (fmt --check + clippy) is fast; the heavier `cargo test` runs in CI.
write_if_absent .githooks/pre-commit <<'EOF'
#!/usr/bin/env bash
# Fast checks before commit. `make lint` should be quick; heavier gates run in CI.
set -euo pipefail
make lint
EOF
chmod +x .githooks/pre-commit 2>/dev/null || true
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config core.hooksPath .githooks && say "set core.hooksPath = .githooks"
else
  say "not a git repo yet - after 'git init' run: git config core.hooksPath .githooks"
fi

# --- fetch dependencies ------------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && command -v cargo >/dev/null 2>&1; then
  echo "Fetching dependencies (cargo fetch)..."
  cargo fetch || say "cargo fetch failed - run it manually"
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && {
  echo "Still to run yourself:"
  echo "  cargo fetch"
}
echo "Then: git init && git switch -c develop"
echo "Verify the gate: cargo fmt --check && cargo clippy --all-targets --all-features -- -D warnings && cargo test"

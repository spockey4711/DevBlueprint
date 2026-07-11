#!/usr/bin/env bash
# scaffold-check.sh - scaffold one variant into a throwaway dir, wire it with the
# variant's setup.sh, and verify the result with `devblueprint doctor`. This is
# the per-variant engine behind the Kit self-CI matrix
# (.github/workflows/scaffold-matrix.yml): it catches "variant rot" - a scaffold,
# setup.sh, Makefile or quality gate that has drifted out of a green state -
# before a release ships it.
#
# Usage:
#   scripts/scaffold-check.sh <variant>     check one variant
#   scripts/scaffold-check.sh --all         check every variant, sequentially
#   scripts/scaffold-check.sh --list        print variant names, one per line
#   scripts/scaffold-check.sh --list-json   print variant names as a JSON array
#
# What "green" means per variant:
#   - Variants whose setup.sh scaffolds a complete, self-checking starter (see
#     gated_variant below) get the full treatment: `./setup.sh` installs the
#     toolchain, then `devblueprint doctor --strict --run-gate` runs the real
#     quality gate and fails on any red. These use a toolchain the CI runner
#     already ships or that pins itself (make, rustup via rust-toolchain.toml,
#     npm), so the workflow needs no extra bootstrapping.
#   - The rest deliberately require you to create the real app/package first (a
#     Next.js app, a SwiftPM/Xcode project, a Gradle project, Python sources), so
#     their gate cannot pass on an empty scaffold. For them we verify the
#     scaffold plus a clean, idempotent `./setup.sh --no-install` with
#     `devblueprint doctor --strict` (no --run-gate).
#
# Env:
#   SCAFFOLD_CHECK_REQUIRE_GATE=1  a gated variant whose toolchain is missing is a
#                                  hard failure instead of a skip (CI sets this).
#   SCAFFOLD_CHECK_KEEP=1          keep the throwaway dir for debugging.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
DEVBLUEPRINT="$ROOT/bin/devblueprint"
VARIANTS_DIR="$ROOT/variants"

die() { echo "scaffold-check: $*" >&2; exit 1; }

# all_variants : every variant name (a dir under variants/ with a manifest.env),
# sorted so output is stable across filesystems.
all_variants() {
  local d
  for d in "$VARIANTS_DIR"/*/; do
    [ -f "$d/manifest.env" ] || continue
    basename "$d"
  done | sort
}

# gated_variant <variant> : true for variants whose setup.sh scaffolds a
# complete, self-checking starter that runs green with a toolchain the CI runner
# already ships (or that pins itself), so the full quality gate can run.
# Keep this in sync when a new variant qualifies; anything not listed falls back
# to the scaffold-only check (the safe default).
#
# backend-go is deliberately scaffold-only: its gate needs gofumpt + golangci-lint
# installed separately, and its shipped .golangci.yml tracks a specific
# golangci-lint major - a version coupling that belongs with the variant, not
# this harness. Wire its gate in once the variant pins those tools.
gated_variant() {
  case "$1" in
    generic|rust|node-express) return 0 ;;
    *) return 1 ;;
  esac
}

# gate_tool <variant> : the toolchain binary the variant's quality gate needs.
# When it is missing the gate cannot run - a skip locally, a hard failure in CI
# (SCAFFOLD_CHECK_REQUIRE_GATE=1).
gate_tool() {
  case "$1" in
    generic)      echo make ;;
    rust)         echo cargo ;;
    node-express) echo npm ;;
    *)            echo "" ;;
  esac
}

# run_variant <variant> <workdir> : the actual scaffold -> setup -> verify steps.
# Returns non-zero on the first red step; the caller owns <workdir>'s cleanup.
run_variant() {
  local v="$1" work="$2" title
  # shellcheck source=/dev/null
  title="$( . "$VARIANTS_DIR/$v/manifest.env"; printf '%s' "${VARIANT_TITLE:-$v}" )"

  printf '\n=== %s - %s ===\n' "$v" "$title"
  echo "scaffold dir: $work"

  echo "-> devblueprint init"
  if ! "$DEVBLUEPRINT" init --target "$work" --variant "$v" --name "selfci-$v" --force >/dev/null; then
    echo "FAIL: init failed"; return 1
  fi

  # doctor --strict expects a git repo; setup.sh wires the pre-commit hook via
  # core.hooksPath, which needs one too.
  echo "-> git init"
  if ! git -C "$work" init -q \
    || ! git -C "$work" config user.email "selfci@devblueprint.invalid" \
    || ! git -C "$work" config user.name "DevBlueprint Self-CI"; then
    echo "FAIL: git init failed"; return 1
  fi

  # A gated variant runs the full gate only when its toolchain is present.
  local gated=0 tool=""
  if gated_variant "$v"; then
    tool="$(gate_tool "$v")"
    if command -v "$tool" >/dev/null 2>&1; then
      gated=1
    elif [ "${SCAFFOLD_CHECK_REQUIRE_GATE:-0}" = "1" ]; then
      echo "FAIL: '$tool' not found but the gate is required (SCAFFOLD_CHECK_REQUIRE_GATE=1)"
      return 1
    else
      echo "NOTE: '$tool' not installed - skipping the quality gate, checking the scaffold only"
    fi
  fi

  # Full setup (installs the toolchain) only when we are going to run the gate,
  # so the gate has something to build; otherwise config-only.
  if [ "$gated" -eq 1 ]; then
    echo "-> ./setup.sh"
    if ! ( cd "$work" && ./setup.sh ); then
      echo "FAIL: setup.sh failed"; return 1
    fi
  else
    echo "-> ./setup.sh --no-install"
    if ! ( cd "$work" && ./setup.sh --no-install ); then
      echo "FAIL: setup.sh failed"; return 1
    fi
  fi

  # A second run must be a clean no-op: setup.sh is documented as idempotent.
  echo "-> ./setup.sh --no-install (idempotency re-run)"
  if ! ( cd "$work" && ./setup.sh --no-install >/dev/null ); then
    echo "FAIL: setup.sh is not idempotent (second run failed)"; return 1
  fi

  if [ "$gated" -eq 1 ]; then
    echo "-> devblueprint doctor --strict --run-gate"
    if ! "$DEVBLUEPRINT" doctor --target "$work" --strict --run-gate; then
      echo "FAIL: doctor / quality gate failed"; return 1
    fi
  else
    echo "-> devblueprint doctor --strict"
    if ! "$DEVBLUEPRINT" doctor --target "$work" --strict; then
      echo "FAIL: doctor failed"; return 1
    fi
  fi

  echo "PASS: $v"
  return 0
}

# check_variant <variant> : run_variant in a throwaway dir, cleaning it up
# afterwards (unless SCAFFOLD_CHECK_KEEP=1).
check_variant() {
  local v="$1"
  [ -f "$VARIANTS_DIR/$v/manifest.env" ] || die "unknown variant '$v' (see: scaffold-check.sh --list)"

  # The scaffold dir's basename becomes the project's package name (setup.sh
  # derives it from $PWD), so it must be a clean, lowercase identifier: mktemp's
  # random suffix mixes in '.' / uppercase, which break a Cargo package name (a
  # non-snake-case crate is a clippy error under -D warnings). Keep the random
  # uniqueness in a parent dir and scaffold into a fixed "selfci-<variant>" child.
  local tmproot rc=0 work
  tmproot="$(mktemp -d "${TMPDIR:-/tmp}/scaffold-${v}-XXXXXX")"
  work="$tmproot/selfci-$v"
  run_variant "$v" "$work" || rc=$?

  if [ "${SCAFFOLD_CHECK_KEEP:-0}" = "1" ]; then
    echo "  (kept throwaway dir: $tmproot)"
  else
    rm -rf "$tmproot"
  fi
  return "$rc"
}

# check_all : every variant in turn, printing a summary and failing if any did.
check_all() {
  local v failed="" total=0
  for v in $(all_variants); do
    total=$((total + 1))
    check_variant "$v" || failed="$failed $v"
  done

  echo
  echo "=== summary ==="
  if [ -n "$failed" ]; then
    echo "FAIL:$failed"
    echo "$((total - $(printf '%s' "$failed" | wc -w))) / $total variants green"
    return 1
  fi
  echo "all $total variants green"
  return 0
}

main() {
  [ "$#" -le 1 ] || die "expected a single variant name or flag (got $#)"
  case "${1:-}" in
    ""|-h|--help)
      sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      ;;
    --list)      all_variants ;;
    --list-json)
      # Variant names are kebab-case ([a-z0-9-]+), so no JSON escaping is needed.
      local first=1 v
      printf '['
      for v in $(all_variants); do
        [ "$first" -eq 1 ] || printf ','
        printf '"%s"' "$v"
        first=0
      done
      printf ']\n'
      ;;
    --all)       check_all ;;
    -*)          die "unknown flag '$1'" ;;
    *)           check_variant "$1" ;;
  esac
}

main "$@"

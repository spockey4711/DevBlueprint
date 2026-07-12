#!/usr/bin/env bash
# beginner-artifacts-check.sh - guard that the beginner artifacts and the docs
# that advertise them stay in sync, so neither can rot silently.
#
# The zero-install onboarding surface makes concrete promises to newcomers:
#   - every variant ships a .vscode/ pair (extensions.json + tasks.json) so the
#     scaffolded project opens ready in VS Code (P10-3, P10-4), and
#   - every variant ships a .devcontainer/devcontainer.json for the click-and-go
#     Codespaces / Dev Container path (P11-2), *except* the documented exceptions.
# GETTING-STARTED.md, README.md and docs/codespaces.md all repeat those promises
# in prose ("every project ships a .vscode/tasks.json", "every variant except
# ios-swift ships a Dev Container"). Add a variant without the artifacts, or
# change the exception set without touching the docs, and those promises quietly
# become lies.
#
# The bats suite (test/vscode.bats) validates each artifact's *contents* - valid
# JSON, a default build task, extensions matching recommendations. This check is
# the complementary half: it validates the *set* of artifacts against what the
# beginner docs claim, and it is the engine behind the dedicated Kit self-CI
# workflow (.github/workflows/beginner-artifacts.yml). Doc-link and command
# freshness across the wider beginner path is a separate concern (see P14-4).
#
# Usage:
#   scripts/beginner-artifacts-check.sh
#
# Exit status is 0 when every invariant holds, 1 otherwise. Every failure is
# printed with enough context to fix it; the run does not stop at the first one.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The single source of truth for which variants intentionally ship no Dev
# Container. ios-swift needs macOS + Xcode, which cannot run in a Linux
# container. Any change here must be matched on disk *and* in the docs below -
# this check enforces exactly that.
EXPECTED_NO_DEVCONTAINER=("ios-swift")

# Docs that promise the zero-install path and must name every exception.
CODESPACES_DOC="docs/codespaces.md"
DOCS_NAMING_EXCEPTIONS=("$CODESPACES_DOC" "README.md")

# Docs that must link to the zero-install doc, so the entry point to the
# artifacts cannot silently disappear.
DOCS_LINKING_CODESPACES=("GETTING-STARTED.md" "README.md")

fail_count=0

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  fail_count=$((fail_count + 1))
}

pass() {
  printf 'ok: %s\n' "$1"
}

# All variants, one name per line, sorted - a variant is a directory carrying a
# manifest.env.
variants() {
  local m v
  for m in "$REPO_ROOT"/variants/*/manifest.env; do
    v="$(basename "$(dirname "$m")")"
    printf '%s\n' "$v"
  done | sort
}

# ---------------------------------------------------------------------------
# Check 1: every variant ships the .vscode/ pair.
# Backs the "every project ships a .vscode/tasks.json" promise (GETTING-STARTED,
# README) and the one-click extensions promise (P10-3).
# ---------------------------------------------------------------------------
check_vscode_pair() {
  local v file
  local missing=0
  while IFS= read -r v; do
    for file in extras/.vscode/extensions.json extras/.vscode/tasks.json; do
      if [ ! -f "$REPO_ROOT/variants/$v/$file" ]; then
        fail "variant '$v' is missing $file (every variant must ship the VS Code pair)"
        missing=1
      fi
    done
  done < <(variants)
  [ "$missing" -eq 0 ] && pass "every variant ships extras/.vscode/{extensions,tasks}.json"
}

# ---------------------------------------------------------------------------
# Check 2: Dev Container coverage matches the documented exception set.
# The set of variants that lack a devcontainer on disk must equal
# EXPECTED_NO_DEVCONTAINER exactly, and every exception must be named in the
# docs. This is the core anti-rot guard: disk, this list and the prose can only
# ever change together.
# ---------------------------------------------------------------------------
check_devcontainer_coverage() {
  local v actual expected
  local actual_lines=""
  while IFS= read -r v; do
    if [ ! -f "$REPO_ROOT/variants/$v/extras/.devcontainer/devcontainer.json" ]; then
      actual_lines+="$v"$'\n'
    fi
  done < <(variants)

  actual="$(printf '%s' "$actual_lines" | sed '/^$/d' | sort | tr '\n' ' ' | sed 's/ *$//')"
  expected="$(printf '%s\n' "${EXPECTED_NO_DEVCONTAINER[@]}" | sort | tr '\n' ' ' | sed 's/ *$//')"

  if [ "$actual" != "$expected" ]; then
    fail "variants lacking a devcontainer are [$actual] but the docs promise exactly [$expected]"
    fail "  -> add extras/.devcontainer/devcontainer.json to the new variant, or update"
    fail "     EXPECTED_NO_DEVCONTAINER here and the prose in ${DOCS_NAMING_EXCEPTIONS[*]}"
    return
  fi
  pass "devcontainer coverage matches the documented exception set [$expected]"

  # Every documented exception must actually be named in each doc that promises
  # the zero-install path, so the prose cannot drift from the exception set.
  local exc doc
  for exc in "${EXPECTED_NO_DEVCONTAINER[@]}"; do
    for doc in "${DOCS_NAMING_EXCEPTIONS[@]}"; do
      if ! grep -q "$exc" "$REPO_ROOT/$doc"; then
        fail "$doc does not name the devcontainer exception '$exc'"
      fi
    done
  done
}

# ---------------------------------------------------------------------------
# Check 3: the zero-install doc exists and stays linked from the beginner path,
# so the entry point to the artifacts cannot silently disappear.
# ---------------------------------------------------------------------------
check_codespaces_entrypoint() {
  if [ ! -f "$REPO_ROOT/$CODESPACES_DOC" ]; then
    fail "the zero-install doc $CODESPACES_DOC is missing"
    return
  fi
  pass "$CODESPACES_DOC exists"

  local doc
  for doc in "${DOCS_LINKING_CODESPACES[@]}"; do
    if ! grep -q "$CODESPACES_DOC" "$REPO_ROOT/$doc"; then
      fail "$doc no longer links to $CODESPACES_DOC (the zero-install entry point)"
    fi
  done
}

main() {
  check_vscode_pair
  check_devcontainer_coverage
  check_codespaces_entrypoint

  echo
  if [ "$fail_count" -ne 0 ]; then
    printf '%d beginner-artifact check(s) failed.\n' "$fail_count" >&2
    exit 1
  fi
  echo "All beginner-artifact checks passed."
}

main "$@"

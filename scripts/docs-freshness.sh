#!/usr/bin/env bash
# docs-freshness.sh - periodic "does the beginner path still match the CLI?" pass.
#
# GETTING-STARTED.md walks a newcomer through one exact flow - init, setup.sh,
# git init, doctor, make check - and quotes the output they should see at each
# step. Those quoted transcripts are the guide's "screenshots": a beginner reads
# them to confirm their own run went right. If the CLI's wording drifts but the
# guide keeps the old transcript, the newcomer sees a mismatch on their very
# first run and cannot tell whether they broke something. P14-4's docs-check.sh
# catches dangling links and renamed subcommands on every push; this pass goes
# one level deeper - it actually *runs* the documented flow and confirms the
# guide's transcripts and version stamps still match what the CLI prints. It is
# heavier (it scaffolds a throwaway project and runs its gate), so it runs on a
# schedule rather than on every push - see .github/workflows/docs-freshness.yml.
#
# Two checks run over the beginner path:
#
#   flow      Scaffold hello-world exactly as the guide's "Your first run"
#             section does, then assert that each phrase the guide promises the
#             beginner will see is (a) still printed by the CLI and (b) still
#             quoted in GETTING-STARTED.md. If either side moved, the two have
#             drifted apart and this fails.
#
#   version   Every DevBlueprint version literal quoted in the beginner docs
#             (e.g. the "scaffolded from DevBlueprint X.Y.Z" line doctor prints)
#             matches ./VERSION, so a release bump cannot leave a stale number
#             frozen in the guide.
#
# Usage:
#   scripts/docs-freshness.sh            run both checks (CI default)
#   scripts/docs-freshness.sh --flow     documented-flow check only
#   scripts/docs-freshness.sh --version  version-stamp check only
#   scripts/docs-freshness.sh --help     show this usage
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
cd "$ROOT"

DEVBLUEPRINT="$ROOT/bin/devblueprint"

# The beginner path's front door and its German mirror. Both quote the same
# English CLI output (the CLI does not localize), so both are checked.
GUIDES=(
  GETTING-STARTED.md
  i18n/de/GETTING-STARTED.md
)

fail=0
problem() { printf 'docs-freshness: %s\n' "$*" >&2; fail=1; }

usage() { sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'; }

WORKDIR=""
cleanup() { [ -n "$WORKDIR" ] && rm -rf "$WORKDIR"; return 0; }
trap cleanup EXIT

# --- flow check ------------------------------------------------------------

# Phrases the guide promises the beginner will see at each step of "Your first
# run" (GETTING-STARTED.md). Each must still be printed by the CLI *and* still be
# quoted in the guide - if either drops it, the guide and the CLI have drifted.
# Keep these in step with the transcripts in GETTING-STARTED.md.
INIT_ANCHORS=(
  "Scaffolding 'hello-world' (Generic (language-agnostic)) into"
  "Done. Next steps:"
  "./setup.sh   (wires configs + pre-commit hook + installs the toolchain)"
  "Start a task in its own worktree:"
)
SETUP_ANCHORS=(
  "Wiring the generic toolchain..."
  "wrote .githooks/pre-commit"
  "Toolchain wired."
)
DOCTOR_ANCHORS=(
  "pre-commit hook wired"
  "doctor: all foundation files present"
)
GATE_ANCHORS=(
  "check-env: environment configuration is valid"
  "TODO: wire the linter for this project"
  "TODO: wire the type checker (or remove this target)"
  "TODO: wire the test runner"
  "TODO: wire the build/compile step"
)

# have <cmd> : true if <cmd> is on PATH.
have() { command -v "$1" >/dev/null 2>&1; }

# check_anchors <step> <output> <anchor...> : for each anchor, confirm it is in
# the CLI's <output> and quoted in every guide. Two-sided so drift on either the
# CLI or the doc side is caught, and per-guide so one mirror falling behind the
# other does not hide behind the other still quoting it.
check_anchors() {
  local step="$1" output="$2" anchor guide
  shift 2
  for anchor in "$@"; do
    printf '%s' "$output" | grep -Fq -- "$anchor" \
      || problem "flow ($step): the CLI no longer prints \"$anchor\" - the guides quote it"
    for guide in "${GUIDES[@]}"; do
      grep -Fq -- "$anchor" "$guide" \
        || problem "flow ($step): $guide no longer quotes \"$anchor\" - the CLI still prints it"
    done
  done
}

check_flow() {
  local target out
  if ! have git || ! have make; then
    problem "flow: git and make are required to run the documented flow"
    return
  fi

  WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/docs-freshness.XXXXXX")"
  target="$WORKDIR/hello-world"

  # 1. Scaffold, exactly as "Your first run" step 1 does.
  out="$("$DEVBLUEPRINT" init --target "$target" --name hello-world --variant generic 2>&1)" \
    || problem "flow: 'devblueprint init' exited non-zero"
  check_anchors init "$out" "${INIT_ANCHORS[@]}"

  # 2. Wire the toolchain (step 2).
  out="$(cd "$target" && ./setup.sh 2>&1)" \
    || problem "flow: './setup.sh' exited non-zero"
  check_anchors setup "$out" "${SETUP_ANCHORS[@]}"

  # 3. Put it under version control so the hook check has a repo (step 3).
  ( cd "$target" && git init -q && git config core.hooksPath .githooks ) \
    || problem "flow: 'git init' setup failed"

  # 4. Verify the foundation (step 4).
  out="$(cd "$target" && "$DEVBLUEPRINT" doctor --target . 2>&1)" \
    || problem "flow: 'devblueprint doctor' exited non-zero"
  check_anchors doctor "$out" "${DOCTOR_ANCHORS[@]}"

  # 5. Run the quality gate ("Your first task" step 3).
  out="$(cd "$target" && make check 2>&1)" \
    || problem "flow: 'make check' exited non-zero"
  check_anchors "make check" "$out" "${GATE_ANCHORS[@]}"

  cleanup
  WORKDIR=""
}

# --- version-stamp check ---------------------------------------------------

check_version() {
  local want guide literal found
  want="$(tr -d '[:space:]' < VERSION)"
  if [ -z "$want" ]; then
    problem "version: ./VERSION is empty"
    return
  fi
  for guide in "${GUIDES[@]}"; do
    [ -f "$guide" ] || { problem "version: beginner guide missing: $guide"; continue; }
    # The version appears as "DevBlueprint X.Y.Z" and "current X.Y.Z" in the
    # doctor transcript. Pull every such literal and hold it to ./VERSION.
    found=0
    while IFS= read -r literal; do
      found=1
      [ "$literal" = "$want" ] \
        || problem "version: $guide quotes DevBlueprint $literal but ./VERSION is $want"
    done < <(grep -oE '(DevBlueprint|current) [0-9]+\.[0-9]+\.[0-9]+' "$guide" \
      | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -u)
    [ "$found" -eq 1 ] \
      || problem "version: $guide quotes no DevBlueprint version - the doctor transcript that stamps it may have been dropped"
  done
}

# --- main ------------------------------------------------------------------

run_flow=1
run_version=1
case "${1:-}" in
  --flow) run_version=0 ;;
  --version) run_flow=0 ;;
  -h|--help|help) usage; exit 0 ;;
  '') : ;;
  *) problem "unknown option '$1' (try: --flow, --version, --help)"; exit 2 ;;
esac

[ "$run_flow" -eq 1 ] && check_flow
[ "$run_version" -eq 1 ] && check_version

if [ "$fail" -ne 0 ]; then
  echo "docs-freshness: FAILED - the beginner path has drifted from the CLI (see above)" >&2
  exit 1
fi
echo "docs-freshness: ok - the documented getting-started flow still matches the CLI"
exit 0

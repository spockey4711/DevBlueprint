# Shared helpers for the devblueprint bats suite.
#
# Every test scaffolds into a throwaway directory and runs the CLI from the repo
# under test, so the suite never touches the developer's working tree.

# Absolute path to the repo root (this file lives in <root>/test/).
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVBLUEPRINT="$REPO_ROOT/bin/devblueprint"

setup() {
  TEST_TMP="$(mktemp -d "${BATS_TMPDIR:-/tmp}/devblueprint.XXXXXX")"
  TARGET="$TEST_TMP/project"
}

teardown() {
  [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"
}

# db <args...> : run the CLI under `bats run`-friendly conditions.
db() {
  "$DEVBLUEPRINT" "$@"
}

#!/usr/bin/env bats
# packaging (P4-1): the no-clone install paths must run the real CLI so it can
# resolve core/ and variants/ next to itself. The tricky part is that the CLI
# derives its kit root without following symlinks, so these tests assert that the
# npm launcher and the curl|sh wrapper both reach the real bin/devblueprint.

load helper

@test "npm launcher resolves the kit through npm's bin symlink" {
  command -v node >/dev/null 2>&1 || skip "node not installed"

  # Emulate npm/npx: a symlink (in a .bin dir) pointing at the launcher.
  mkdir -p "$TEST_TMP/.bin"
  ln -s "$REPO_ROOT/packaging/npm/launch.cjs" "$TEST_TMP/.bin/devblueprint"

  run node "$TEST_TMP/.bin/devblueprint" version
  [ "$status" -eq 0 ]
  [[ "$output" == "devblueprint "* ]]

  # `list` reads variants/ next to the real bin, proving the kit root resolved.
  run node "$TEST_TMP/.bin/devblueprint" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Available variants:"* ]]
}

@test "curl|sh installer writes a working wrapper from a local source" {
  run env \
    DEVBLUEPRINT_PREFIX="$TEST_TMP/prefix" \
    DEVBLUEPRINT_BIN="$TEST_TMP/bin" \
    DEVBLUEPRINT_SRC="$REPO_ROOT" \
    sh "$REPO_ROOT/install.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"devblueprint "* ]]

  # The wrapper is executable and execs the real CLI, so the kit resolves.
  [ -x "$TEST_TMP/bin/devblueprint" ]
  run "$TEST_TMP/bin/devblueprint" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Available variants:"* ]]
}

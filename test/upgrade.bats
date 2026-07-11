#!/usr/bin/env bats
# upgrade (P4-2): self-update the installed kit with stable/next channels and
# pinning. These tests never touch the network: they build a throwaway kit copy
# and drive the "remote" through DEVBLUEPRINT_UPGRADE_SRC (a local kit dir, like
# install.sh's DEVBLUEPRINT_SRC) and DEVBLUEPRINT_LATEST_TAG (the stable-tag
# resolver override). The dev repo itself cannot be used as the kit under test:
# `upgrade` refuses a git clone, so each test copies bin/devblueprint into a
# throwaway kit whose root has no .git.

load helper

# make_kit <dir> <version> : a minimal installed kit at <dir> - the real CLI plus
# a VERSION file. That is all `upgrade` needs to resolve its own root and version.
make_kit() {
  mkdir -p "$1/bin"
  cp "$DEVBLUEPRINT" "$1/bin/devblueprint"
  printf '%s\n' "$2" > "$1/VERSION"
}

@test "upgrade --check reports installed vs available and writes nothing" {
  make_kit "$TEST_TMP/kit" 0.1.0
  make_kit "$TEST_TMP/new" 0.2.0

  run env DEVBLUEPRINT_UPGRADE_SRC="$TEST_TMP/new" \
    "$TEST_TMP/kit/bin/devblueprint" upgrade --channel next --check
  [ "$status" -eq 0 ]
  [[ "$output" == *"installed: 0.1.0"* ]]
  [[ "$output" == *"available: 0.2.0"* ]]
  [[ "$output" == *"Run 'devblueprint upgrade' to apply."* ]]

  # Nothing was written: version unchanged, no channel state recorded.
  [ "$(cat "$TEST_TMP/kit/VERSION")" = "0.1.0" ]
  [ ! -f "$TEST_TMP/kit/.channel" ]
}

@test "upgrade --channel next swaps in the new kit and records the channel" {
  make_kit "$TEST_TMP/kit" 0.1.0
  make_kit "$TEST_TMP/new" 0.2.0
  echo marker > "$TEST_TMP/new/NEWFILE"

  run env DEVBLUEPRINT_UPGRADE_SRC="$TEST_TMP/new" \
    "$TEST_TMP/kit/bin/devblueprint" upgrade --channel next
  [ "$status" -eq 0 ]
  [[ "$output" == *"Upgraded 0.1.0 -> 0.2.0."* ]]

  [ "$(cat "$TEST_TMP/kit/VERSION")" = "0.2.0" ]
  [ -f "$TEST_TMP/kit/NEWFILE" ]                       # new files land
  grep -q '^channel=next$' "$TEST_TMP/kit/.channel"
  grep -q '^version=0.2.0$' "$TEST_TMP/kit/.channel"
}

@test "upgrade is a no-op when already current, unless --force" {
  make_kit "$TEST_TMP/kit" 0.2.0
  make_kit "$TEST_TMP/new" 0.2.0

  run env DEVBLUEPRINT_UPGRADE_SRC="$TEST_TMP/new" \
    "$TEST_TMP/kit/bin/devblueprint" upgrade --channel next
  [ "$status" -eq 0 ]
  [[ "$output" == *"Already up to date (0.2.0)."* ]]

  # --force re-applies even at the same version.
  run env DEVBLUEPRINT_UPGRADE_SRC="$TEST_TMP/new" \
    "$TEST_TMP/kit/bin/devblueprint" upgrade --channel next --force
  [ "$status" -eq 0 ]
  [[ "$output" == *"Upgraded 0.2.0 -> 0.2.0."* ]]
}

@test "upgrade --version pins the recorded state" {
  make_kit "$TEST_TMP/kit" 0.1.0
  make_kit "$TEST_TMP/new" 0.3.0

  run env DEVBLUEPRINT_UPGRADE_SRC="$TEST_TMP/new" \
    "$TEST_TMP/kit/bin/devblueprint" upgrade --version 0.3.0
  [ "$status" -eq 0 ]
  [[ "$output" == *"pinned 0.3.0"* ]]
  [[ "$output" == *"ref: v0.3.0"* ]]                   # bare semver becomes a v-tag
  grep -q '^pin=0.3.0$' "$TEST_TMP/kit/.channel"
}

@test "choosing a channel clears an existing pin" {
  make_kit "$TEST_TMP/kit" 0.1.0
  make_kit "$TEST_TMP/new" 0.3.0
  env DEVBLUEPRINT_UPGRADE_SRC="$TEST_TMP/new" \
    "$TEST_TMP/kit/bin/devblueprint" upgrade --version 0.3.0 >/dev/null
  grep -q '^pin=0.3.0$' "$TEST_TMP/kit/.channel"

  run env DEVBLUEPRINT_UPGRADE_SRC="$TEST_TMP/new" \
    "$TEST_TMP/kit/bin/devblueprint" upgrade --channel next
  [ "$status" -eq 0 ]
  grep -q '^channel=next$' "$TEST_TMP/kit/.channel"
  grep -q '^pin=$' "$TEST_TMP/kit/.channel"
}

@test "upgrade refuses a git clone" {
  make_kit "$TEST_TMP/kit" 0.1.0
  make_kit "$TEST_TMP/new" 0.2.0
  mkdir -p "$TEST_TMP/kit/.git"

  run env DEVBLUEPRINT_UPGRADE_SRC="$TEST_TMP/new" \
    "$TEST_TMP/kit/bin/devblueprint" upgrade --channel next
  [ "$status" -ne 0 ]
  [[ "$output" == *"git clone"* ]]
  [ "$(cat "$TEST_TMP/kit/VERSION")" = "0.1.0" ]       # untouched
}

@test "stable channel resolves the latest release tag" {
  make_kit "$TEST_TMP/kit" 0.1.0
  make_kit "$TEST_TMP/new" 0.3.0

  run env DEVBLUEPRINT_LATEST_TAG=v0.3.0 DEVBLUEPRINT_UPGRADE_SRC="$TEST_TMP/new" \
    "$TEST_TMP/kit/bin/devblueprint" upgrade --channel stable --check
  [ "$status" -eq 0 ]
  [[ "$output" == *"Channel: stable"* ]]
  [[ "$output" == *"ref: v0.3.0"* ]]
  [[ "$output" == *"available: 0.3.0"* ]]
}

@test "upgrade rejects an invalid channel and unknown options" {
  make_kit "$TEST_TMP/kit" 0.1.0

  run "$TEST_TMP/kit/bin/devblueprint" upgrade --channel bogus
  [ "$status" -ne 0 ]
  [[ "$output" == *"invalid channel 'bogus'"* ]]

  run "$TEST_TMP/kit/bin/devblueprint" upgrade --nope
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown option: --nope"* ]]
}

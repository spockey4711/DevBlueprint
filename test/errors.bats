#!/usr/bin/env bats
# Beginner-friendly error messages (P12-1): every failure a newcomer can trip
# should say what to do next, not just what broke. `die` prints the recovery on
# its own indented "next:" line, so these tests assert both the diagnosis and
# that a recovery hint is present and points somewhere useful.

load helper

# has_next_line : true when output carries a "next:" recovery hint on its own
# line, the shape `die` gives every beginner-facing failure.
has_next_line() {
  [[ "$output" == *"next:"* ]]
}

@test "init without --target explains the flag and points at the wizard" {
  run db init --variant generic
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing --target"* ]]
  has_next_line
  # The single most useful escape hatch for a beginner: the no-flag wizard.
  [[ "$output" == *"init"*"no flags"*"wizard"* ]]
}

@test "unknown command lists the valid commands to try instead" {
  run db frobnicate
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown command 'frobnicate'"* ]]
  # A newcomer who mistypes gets the whole menu, not just a rejection.
  [[ "$output" == *"list"* ]]
  [[ "$output" == *"init"* ]]
  [[ "$output" == *"doctor"* ]]
  [[ "$output" == *"help"* ]]
}

@test "doctor without --target points at both --target and --env" {
  run db doctor
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing --target"* ]]
  has_next_line
  # The recovery names the machine-check alternative a beginner likely wants.
  [[ "$output" == *"doctor --env"* ]]
}

@test "update on a missing target suggests init and a typo check" {
  run db update --target "$TEST_TMP/does-not-exist"
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not exist"* ]]
  has_next_line
  [[ "$output" == *"devblueprint init"* ]]
}

@test "commands on a non-DevBlueprint directory explain how to scaffold first" {
  # A real, empty directory that simply was never scaffolded.
  mkdir -p "$TARGET"

  run db diff --target "$TARGET"
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not look like a DevBlueprint project"* ]]
  has_next_line
  [[ "$output" == *"devblueprint init"* ]]
}

@test "unknown init variant names the list command as the fix" {
  run db init --target "$TARGET" --name demo --variant no-such-stack
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown variant"* ]]
  [[ "$output" == *"devblueprint list"* ]]
}

@test "the next-step hint prints on its own indented line under the error" {
  run db init --variant generic
  [ "$status" -ne 0 ]
  # First line is the diagnosis, a later line is the indented recovery - so the
  # two never run together and a beginner can see the fix at a glance.
  [[ "${lines[0]}" == "devblueprint: missing --target"* ]]
  local found=0 l
  for l in "${lines[@]}"; do
    [[ "$l" == "  next: "* ]] && found=1
  done
  [ "$found" -eq 1 ]
}

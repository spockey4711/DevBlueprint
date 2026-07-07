#!/usr/bin/env bats
# Pre-commit hook wiring (P1-4): each variant's setup.sh must install a
# committable hook that runs the quality gate, so "run the gate before pushing"
# is enforced, not just documented. These tests cover the two variants that use
# `.githooks/pre-commit` + `core.hooksPath` (generic, ios-swift) and assert that
# doctor reports the hook's status.

load helper

# wire_variant <variant> [setup-args...] : scaffold the variant into $TARGET,
# make it a git repo, and run its setup.sh from inside. A non-zero setup.sh exit
# fails the calling test (bats aborts on any unchecked non-zero command).
wire_variant() {
  local variant="$1"; shift
  db init --target "$TARGET" --name demo --variant "$variant" >/dev/null
  git -C "$TARGET" init -q
  ( cd "$TARGET" && ./setup.sh "$@" ) >/dev/null 2>&1
}

@test "generic setup.sh writes an executable .githooks/pre-commit that runs the gate" {
  wire_variant generic
  [ -f "$TARGET/.githooks/pre-commit" ]
  [ -x "$TARGET/.githooks/pre-commit" ]
  run cat "$TARGET/.githooks/pre-commit"
  [[ "$output" == *"make lint"* ]]
}

@test "generic setup.sh points core.hooksPath at .githooks" {
  wire_variant generic
  run git -C "$TARGET" config core.hooksPath
  [ "$status" -eq 0 ]
  [ "$output" = ".githooks" ]
}

@test "ios-swift setup.sh wires the .githooks hook with --no-install" {
  wire_variant ios-swift --no-install
  [ -x "$TARGET/.githooks/pre-commit" ]
  run git -C "$TARGET" config core.hooksPath
  [ "$output" = ".githooks" ]
}

@test "the wired hook passes when the gate is green" {
  wire_variant generic
  run bash -c "cd '$TARGET' && exec .githooks/pre-commit"
  [ "$status" -eq 0 ]
}

@test "the wired hook fails the commit when the gate is red" {
  wire_variant generic
  printf 'lint:\n\t@exit 1\n' > "$TARGET/Makefile"
  run bash -c "cd '$TARGET' && exec .githooks/pre-commit"
  [ "$status" -ne 0 ]
}

@test "doctor notes when the pre-commit hook is not wired yet" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pre-commit hook not wired yet"* ]]
}

@test "doctor reports the pre-commit hook once setup.sh has wired it" {
  wire_variant generic
  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pre-commit hook wired"* ]]
}

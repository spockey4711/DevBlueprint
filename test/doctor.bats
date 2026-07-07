#!/usr/bin/env bats
# doctor --strict / --run-gate (P2-9): doctor goes beyond file existence. --strict
# reports git state and escalates the advisory pre-commit note to a failure;
# --run-gate resolves the project's quality gate from its variant stamp and runs it.

load helper

@test "doctor --run-gate runs the resolved quality gate and passes when green" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db doctor --target "$TARGET" --run-gate
  [ "$status" -eq 0 ]
  [[ "$output" == *"running: make check"* ]]
  [[ "$output" == *"quality gate passed"* ]]
}

@test "doctor --run-gate fails doctor when the gate is red" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  # Break the gate: make check now exits non-zero.
  printf 'check:\n\t@exit 1\n' > "$TARGET/Makefile"

  run db doctor --target "$TARGET" --run-gate
  [ "$status" -ne 0 ]
  [[ "$output" == *"quality gate failed"* ]]
}

@test "doctor --run-gate resolves a non-make gate from the variant stamp" {
  # backend-go's gate is a shell pipeline, not `make check` - doctor must read it
  # from the variant manifest via the .devblueprint stamp, not assume a Makefile.
  db init --target "$TARGET" --name demo --variant backend-go >/dev/null

  run db doctor --target "$TARGET" --run-gate
  # The go toolchain is almost certainly absent here, so the gate fails; what we
  # assert is that doctor resolved and *ran* the variant's gate, not `make check`.
  [[ "$output" == *"running: gofumpt"* ]]
  [[ "$output" != *"running: make check"* ]]
}

@test "doctor --strict fails on a bare scaffold (no git, no hook)" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db doctor --target "$TARGET" --strict
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a git repository"* ]]
  [[ "$output" == *"pre-commit hook not wired"* ]]
}

@test "doctor --strict passes and reports git state once wired" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  git -C "$TARGET" init -q
  ( cd "$TARGET" && ./setup.sh ) >/dev/null 2>&1

  run db doctor --target "$TARGET" --strict
  [ "$status" -eq 0 ]
  [[ "$output" == *"git repo on"* ]]
  [[ "$output" == *"pre-commit hook wired"* ]]
}

@test "doctor without flags stays advisory (unchanged default)" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pre-commit hook not wired yet"* ]]
  [[ "$output" == *"all foundation files present"* ]]
}

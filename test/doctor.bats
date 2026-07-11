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
  # backend-go's gate is `sh scripts/check-env.sh && test -z "$(gofumpt -l .)" && ...`,
  # so match on gofumpt (unique to the go gate) rather than assuming where in the
  # line it is - the check-env prefix means it no longer starts with `test -z`.
  [[ "$output" == *"running:"*"gofumpt"* ]]
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

# --fix (P6-5): doctor no longer only reports a missing or corrupted foundation
# file - with --fix it restores the file from the kit and passes.

@test "doctor flags an empty foundation file as corrupt and exits non-zero" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  # A zero-byte file is a corruption, not a healthy file.
  : > "$TARGET/docs/engineering/git-workflow.md"

  run db doctor --target "$TARGET"
  [ "$status" -ne 0 ]
  [[ "$output" == *"git-workflow.md (empty)"* ]]
}

@test "doctor --fix restores a missing foundation file and then passes" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  rm "$TARGET/.editorconfig"

  run db doctor --target "$TARGET" --fix
  [ "$status" -eq 0 ]
  [[ "$output" == *".editorconfig (repaired: was missing)"* ]]
  [[ "$output" == *"repaired 1 file(s)"* ]]
  [ -s "$TARGET/.editorconfig" ]

  # A follow-up doctor now finds nothing wrong.
  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"all foundation files present"* ]]
}

@test "doctor --fix restores a corrupted (empty) foundation file" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  : > "$TARGET/docs/engineering/conventions.md"

  run db doctor --target "$TARGET" --fix
  [ "$status" -eq 0 ]
  [[ "$output" == *"conventions.md (repaired: was empty)"* ]]
  [ -s "$TARGET/docs/engineering/conventions.md" ]
}

@test "doctor --fix rebuilds files byte-identically to a fresh scaffold" {
  local ref="$TEST_TMP/ref"
  db init --target "$ref" --name demo --variant generic >/dev/null
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  # Corrupt a variant-owned copy and a core copy; both must come back identical.
  : > "$TARGET/.gitignore"
  rm "$TARGET/docs/engineering/quality-and-testing.md"

  run db doctor --target "$TARGET" --fix
  [ "$status" -eq 0 ]
  cmp "$ref/.gitignore" "$TARGET/.gitignore"
  cmp "$ref/docs/engineering/quality-and-testing.md" "$TARGET/docs/engineering/quality-and-testing.md"
}

@test "doctor --fix rebuilds the .devblueprint stamp from --variant when it is gone" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  rm "$TARGET/.devblueprint"

  # The stamp is the variant's own record, so without it --fix needs --variant.
  run db doctor --target "$TARGET" --fix --variant generic
  [ "$status" -eq 0 ]
  [[ "$output" == *".devblueprint (repaired: was missing)"* ]]
  grep -q "^variant=generic$" "$TARGET/.devblueprint"
  # The rebuilt stamp lets a plain doctor resolve the variant again.
  run db doctor --target "$TARGET" --run-gate
  [ "$status" -eq 0 ]
  [[ "$output" == *"running: make check"* ]]
}

@test "doctor --fix cannot rebuild a variant-owned file without a variant" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  # Drop the stamp (variant source) and a variant-owned file together.
  rm "$TARGET/.devblueprint" "$TARGET/.gitignore"

  run db doctor --target "$TARGET" --fix
  [ "$status" -ne 0 ]
  [[ "$output" == *".gitignore (missing)"* ]]
  [ ! -e "$TARGET/.gitignore" ]
}

@test "doctor --fix rejects an unknown --variant" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db doctor --target "$TARGET" --fix --variant nope
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown variant 'nope'"* ]]
}

@test "doctor --json --fix reports the fixed count and repaired checks as ok" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  rm "$TARGET/.editorconfig"

  run db doctor --target "$TARGET" --json --fix
  [ "$status" -eq 0 ]
  [[ "$output" == *'"fixed":1'* ]]
  [[ "$output" == *'"ok":true'* ]]
  [[ "$output" == *'{"name":".editorconfig","status":"ok"'* ]]
}

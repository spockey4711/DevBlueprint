#!/usr/bin/env bats
# Org baseline / config inheritance: a project intake file (or `init --extends`)
# inherits a shared baseline's answers, with precedence CLI flag > project intake >
# baseline (chained) > built-in default. Baselines resolve by bare name through
# $DEVBLUEPRINT_BASELINE_DIR or by path relative to the referencing file.

load helper

# write_baseline <file> : a shared org baseline (branches + community + agents).
write_baseline() {
  cat > "$1" <<'EOF'
main: main
base: dev
community: true
contact: security@acme.example
agents: claude, cursor
EOF
}

@test "a project intake inherits a named baseline's answers" {
  export DEVBLUEPRINT_BASELINE_DIR="$TEST_TMP/baselines"
  mkdir -p "$DEVBLUEPRINT_BASELINE_DIR"
  write_baseline "$DEVBLUEPRINT_BASELINE_DIR/org-baseline.yml"

  local intake="$TEST_TMP/intake.yml"
  printf 'extends: org-baseline\nname: AcmeApp\nvariant: generic\n' > "$intake"

  run db init --target "$TARGET" --from "$intake"
  [ "$status" -eq 0 ]

  # Branches + agents come from the baseline, name from the project.
  grep -q 'MAIN_BRANCH="main"' "$TARGET/scripts/wt.conf"
  grep -q 'BASE_BRANCH="dev"' "$TARGET/scripts/wt.conf"
  [[ "$(head -n 1 "$TARGET/CLAUDE.md")" == "# AcmeApp" ]]
  [ -f "$TARGET/SECURITY.md" ]                       # community: true inherited
  grep -q "security@acme.example" "$TARGET/SECURITY.md"
  [ -f "$TARGET"/.cursor/rules/*.mdc ]              # agents: claude,cursor inherited

  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
}

@test "a project key overrides the baseline" {
  export DEVBLUEPRINT_BASELINE_DIR="$TEST_TMP/baselines"
  mkdir -p "$DEVBLUEPRINT_BASELINE_DIR"
  write_baseline "$DEVBLUEPRINT_BASELINE_DIR/org-baseline.yml"

  local intake="$TEST_TMP/intake.yml"
  printf 'extends: org-baseline\nvariant: generic\ncontact: team@acme.example\n' > "$intake"

  run db init --target "$TARGET" --from "$intake"
  [ "$status" -eq 0 ]
  grep -q "team@acme.example" "$TARGET/SECURITY.md"
  ! grep -q "security@acme.example" "$TARGET/SECURITY.md"
}

@test "an explicit CLI flag beats the baseline" {
  export DEVBLUEPRINT_BASELINE_DIR="$TEST_TMP/baselines"
  mkdir -p "$DEVBLUEPRINT_BASELINE_DIR"
  write_baseline "$DEVBLUEPRINT_BASELINE_DIR/org-baseline.yml"

  local intake="$TEST_TMP/intake.yml"
  printf 'extends: org-baseline\nvariant: generic\n' > "$intake"

  run db plan --target "$TARGET" --from "$intake" --base master
  [ "$status" -eq 0 ]
  [[ "$output" == *"branches: master -> main"* ]]
}

@test "--extends resolves a baseline by path relative to the intake file" {
  printf 'main: main\nbase: dev\n' > "$TEST_TMP/org.yml"
  local intake="$TEST_TMP/intake.yml"
  printf 'extends: org.yml\nvariant: generic\n' > "$intake"

  run db plan --target "$TARGET" --from "$intake"
  [ "$status" -eq 0 ]
  [[ "$output" == *"branches: dev -> main"* ]]
}

@test "a path baseline resolves relative to the file that declared it" {
  printf 'main: main\nbase: dev\n' > "$TEST_TMP/org.yml"
  mkdir -p "$TEST_TMP/sub"
  printf 'extends: ../org.yml\nvariant: generic\n' > "$TEST_TMP/sub/intake.yml"

  run db plan --target "$TARGET" --from "$TEST_TMP/sub/intake.yml"
  [ "$status" -eq 0 ]
  [[ "$output" == *"branches: dev -> main"* ]]
}

@test "--extends on the CLI works without a --from file" {
  export DEVBLUEPRINT_BASELINE_DIR="$TEST_TMP/baselines"
  mkdir -p "$DEVBLUEPRINT_BASELINE_DIR"
  write_baseline "$DEVBLUEPRINT_BASELINE_DIR/org-baseline.yml"

  run db plan --target "$TARGET" --variant generic --extends org-baseline
  [ "$status" -eq 0 ]
  [[ "$output" == *"branches: dev -> main"* ]]
  [[ "$output" == *"--extends org-baseline"* ]]   # echoed apply line carries it
}

@test "--extends on the CLI overrides an extends inside the intake file" {
  export DEVBLUEPRINT_BASELINE_DIR="$TEST_TMP/baselines"
  mkdir -p "$DEVBLUEPRINT_BASELINE_DIR"
  printf 'main: filemain\nbase: filebase\n' > "$DEVBLUEPRINT_BASELINE_DIR/from-file.yml"
  printf 'main: climain\nbase: clibase\n' > "$DEVBLUEPRINT_BASELINE_DIR/from-cli.yml"

  local intake="$TEST_TMP/intake.yml"
  printf 'extends: from-file\nvariant: generic\n' > "$intake"

  run db plan --target "$TARGET" --from "$intake" --extends from-cli
  [ "$status" -eq 0 ]
  [[ "$output" == *"branches: clibase -> climain"* ]]
}

@test "baselines chain, and a deeper baseline is the lowest precedence" {
  export DEVBLUEPRINT_BASELINE_DIR="$TEST_TMP/baselines"
  mkdir -p "$DEVBLUEPRINT_BASELINE_DIR"
  # division sets both branches; org overrides only base; project overrides nothing.
  printf 'main: divmain\nbase: divbase\n' > "$DEVBLUEPRINT_BASELINE_DIR/division.yml"
  printf 'extends: division\nbase: orgbase\n' > "$DEVBLUEPRINT_BASELINE_DIR/org.yml"

  local intake="$TEST_TMP/intake.yml"
  printf 'extends: org\nvariant: generic\n' > "$intake"

  run db plan --target "$TARGET" --from "$intake"
  [ "$status" -eq 0 ]
  # main from division (deepest), base from org (overrode division).
  [[ "$output" == *"branches: orgbase -> divmain"* ]]
}

@test "a circular extends chain is a hard error" {
  export DEVBLUEPRINT_BASELINE_DIR="$TEST_TMP/baselines"
  mkdir -p "$DEVBLUEPRINT_BASELINE_DIR"
  printf 'extends: b\nmain: a\n' > "$DEVBLUEPRINT_BASELINE_DIR/a.yml"
  printf 'extends: a\nvariant: generic\n' > "$DEVBLUEPRINT_BASELINE_DIR/b.yml"

  local intake="$TEST_TMP/intake.yml"
  printf 'extends: a\nvariant: generic\n' > "$intake"

  run db plan --target "$TARGET" --from "$intake"
  [ "$status" -ne 0 ]
  [[ "$output" == *"circular 'extends'"* ]]
}

@test "an unresolvable baseline is a hard error" {
  local intake="$TEST_TMP/intake.yml"
  printf 'extends: does-not-exist\nvariant: generic\n' > "$intake"

  run db plan --target "$TARGET" --from "$intake"
  [ "$status" -ne 0 ]
  [[ "$output" == *"baseline not found"* ]]
}

@test "a baseline may set the agents toolset" {
  export DEVBLUEPRINT_BASELINE_DIR="$TEST_TMP/baselines"
  mkdir -p "$DEVBLUEPRINT_BASELINE_DIR"
  write_baseline "$DEVBLUEPRINT_BASELINE_DIR/org-baseline.yml"

  local intake="$TEST_TMP/intake.yml"
  printf 'extends: org-baseline\nvariant: generic\n' > "$intake"

  run db plan --target "$TARGET" --from "$intake"
  [ "$status" -eq 0 ]
  [[ "$output" == *"agents: claude, cursor"* ]]
}

@test "the shipped agent/org-baseline.example.yml is a valid baseline" {
  local intake="$TEST_TMP/intake.yml"
  printf 'extends: %s/agent/org-baseline.example.yml\nname: Demo\nvariant: generic\n' \
    "$REPO_ROOT" > "$intake"

  run db plan --target "$TARGET" --from "$intake"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plan: init would scaffold 'Demo'"* ]]
  [ ! -e "$TARGET" ]
}

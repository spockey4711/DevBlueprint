#!/usr/bin/env bats
# Intake file + plan: `init --from <intake.yml>` seeds answers from a file (with
# explicit flags winning), and `plan` (= `init --dry-run`) previews exactly what
# init would write without touching disk.

load helper

# write_intake <file> : a complete, valid intake file for the generic variant.
write_intake() {
  cat > "$1" <<'EOF'
name: MyCoolApp
variant: generic
main: main
base: dev
community: true
contact: security@mycool.dev
deploy: vercel
EOF
}

@test "plan previews without touching disk" {
  local intake="$TEST_TMP/intake.yml"
  write_intake "$intake"

  run db plan --target "$TARGET" --from "$intake"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plan: init would scaffold 'MyCoolApp'"* ]]
  [[ "$output" == *"would write CLAUDE.md"* ]]
  [[ "$output" == *"Plan only - nothing was written"* ]]

  # The target directory must not have been created.
  [ ! -e "$TARGET" ]
}

@test "init --dry-run behaves like plan" {
  local intake="$TEST_TMP/intake.yml"
  write_intake "$intake"

  run db init --target "$TARGET" --from "$intake" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plan: init would scaffold"* ]]
  [ ! -e "$TARGET" ]
}

@test "plan and init report the identical file list" {
  local intake="$TEST_TMP/intake.yml"
  write_intake "$intake"

  db plan --target "$TARGET" --from "$intake" \
    | grep -oE 'would (write|append) .*' \
    | sed 's/^would write /X /; s/^would append /A /' | sort > "$TEST_TMP/plan.txt"
  db init --target "$TARGET" --from "$intake" \
    | grep -oE '(wrote|appended) .*' \
    | sed 's/^wrote /X /; s/^appended /A /' | sort > "$TEST_TMP/init.txt"

  diff "$TEST_TMP/plan.txt" "$TEST_TMP/init.txt"
}

@test "init --from applies name, branches and community from the file" {
  local intake="$TEST_TMP/intake.yml"
  write_intake "$intake"

  run db init --target "$TARGET" --from "$intake"
  [ "$status" -eq 0 ]

  [[ "$(head -n 1 "$TARGET/CLAUDE.md")" == "# MyCoolApp" ]]
  grep -q 'MAIN_BRANCH="main"' "$TARGET/scripts/wt.conf"
  grep -q 'BASE_BRANCH="dev"' "$TARGET/scripts/wt.conf"
  [ -f "$TARGET/SECURITY.md" ]
  grep -q "security@mycool.dev" "$TARGET/SECURITY.md"

  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
}

@test "explicit flags override intake file values" {
  local intake="$TEST_TMP/intake.yml"
  write_intake "$intake"

  # --name and --base on the CLI win; --main is left to the file (main).
  run db init --target "$TARGET" --from "$intake" --name Overridden --base master
  [ "$status" -eq 0 ]

  [[ "$(head -n 1 "$TARGET/CLAUDE.md")" == "# Overridden" ]]
  grep -q 'MAIN_BRANCH="main"' "$TARGET/scripts/wt.conf"
  grep -q 'BASE_BRANCH="master"' "$TARGET/scripts/wt.conf"
}

@test "the deploy target is echoed by plan" {
  local intake="$TEST_TMP/intake.yml"
  write_intake "$intake"

  run db plan --target "$TARGET" --from "$intake"
  [[ "$output" == *"deploy target: vercel"* ]]
}

@test "community: false leaves the community files out" {
  local intake="$TEST_TMP/intake.yml"
  cat > "$intake" <<'EOF'
variant: generic
community: false
EOF

  run db init --target "$TARGET" --from "$intake"
  [ "$status" -eq 0 ]
  [ ! -e "$TARGET/SECURITY.md" ]
  [ ! -e "$TARGET/CODE_OF_CONDUCT.md" ]
}

@test "quoted values and comments parse cleanly" {
  local intake="$TEST_TMP/intake.yml"
  cat > "$intake" <<'EOF'
# leading comment
variant: "generic"   # trailing comment
name: 'Spaced Name'
EOF

  run db plan --target "$TARGET" --from "$intake"
  [ "$status" -eq 0 ]
  [[ "$output" == *"'Spaced Name'"* ]]
  [[ "$output" == *"Generic (language-agnostic)"* ]]
}

@test "an unknown intake key is a hard error" {
  local intake="$TEST_TMP/intake.yml"
  printf 'variant: generic\nbogus: nope\n' > "$intake"

  run db plan --target "$TARGET" --from "$intake"
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown intake key 'bogus'"* ]]
}

@test "a malformed line is a hard error" {
  local intake="$TEST_TMP/intake.yml"
  printf 'variant generic\n' > "$intake"

  run db plan --target "$TARGET" --from "$intake"
  [ "$status" -ne 0 ]
  [[ "$output" == *"invalid intake line"* ]]
}

@test "a missing intake file is a hard error" {
  run db plan --target "$TARGET" --from "$TEST_TMP/does-not-exist.yml"
  [ "$status" -ne 0 ]
  [[ "$output" == *"intake file not found"* ]]
}

@test "the shipped agent/intake.example.yml is valid and plannable" {
  run db plan --target "$TARGET" --from "$REPO_ROOT/agent/intake.example.yml"
  [ "$status" -eq 0 ]
  [[ "$output" == *"would write CLAUDE.md"* ]]
  [ ! -e "$TARGET" ]
}

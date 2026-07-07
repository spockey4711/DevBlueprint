#!/usr/bin/env bats
# Generic variant-extras copy: a variant ships arbitrary config by dropping files
# under github/ or extras/, and init copies both trees recursively - no CLI edit.
# Each test builds a throwaway variants dir (a copy of the real generic variant
# plus fixture files) and points the CLI at it via DEVBLUEPRINT_VARIANTS, so the
# repo's own variants/ is never touched.

load helper

# Seed an isolated variants dir from the real generic variant, then add the
# fixture files this suite asserts on. Exports DEVBLUEPRINT_VARIANTS so the CLI
# resolves variants there instead of the kit's own variants/.
setup_extras_fixture() {
  FIXTURE_VARIANTS="$TEST_TMP/variants"
  mkdir -p "$FIXTURE_VARIANTS"
  cp -R "$REPO_ROOT/variants/generic" "$FIXTURE_VARIANTS/demo"
  local vdir="$FIXTURE_VARIANTS/demo"

  # A github/ file the CLI has never heard of, alongside the known ci.yml.
  printf 'version: 2\n' > "$vdir/github/dependabot.yml"

  # A root-level extras/ tree: a flat file and a nested one.
  mkdir -p "$vdir/extras/.devcontainer"
  printf '20.11.0\n' > "$vdir/extras/.tool-versions"
  printf '{}\n'       > "$vdir/extras/.devcontainer/devcontainer.json"

  export DEVBLUEPRINT_VARIANTS="$FIXTURE_VARIANTS"
}

@test "init copies the variant github/ tree recursively" {
  setup_extras_fixture
  run db init --target "$TARGET" --name demo --variant demo
  [ "$status" -eq 0 ]

  # The known CI workflow still lands (nested under workflows/)...
  [ -f "$TARGET/.github/workflows/ci.yml" ]
  # ...and so does a brand-new github/ file with no dedicated CLI support.
  [ -f "$TARGET/.github/dependabot.yml" ]
}

@test "init copies root-level extras/ recursively, nested dirs and all" {
  setup_extras_fixture
  run db init --target "$TARGET" --name demo --variant demo
  [ "$status" -eq 0 ]

  [ -f "$TARGET/.tool-versions" ]
  [ -f "$TARGET/.devcontainer/devcontainer.json" ]
  [ "$(cat "$TARGET/.tool-versions")" = "20.11.0" ]
}

@test "a variant with no extras/ dir still scaffolds cleanly" {
  setup_extras_fixture
  rm -rf "$FIXTURE_VARIANTS/demo/extras"
  run db init --target "$TARGET" --name demo --variant demo
  [ "$status" -eq 0 ]
  [ -f "$TARGET/.github/workflows/ci.yml" ]
}

@test "extras/ files honor overwrite safety and --force" {
  setup_extras_fixture
  db init --target "$TARGET" --name demo --variant demo >/dev/null

  echo "LOCAL EDIT - keep me" >> "$TARGET/.tool-versions"
  before="$(cat "$TARGET/.tool-versions")"

  # A second init skips the existing extras file and leaves it untouched.
  run db init --target "$TARGET" --name demo --variant demo
  [ "$status" -eq 0 ]
  [[ "$output" == *"skip .tool-versions"* ]]
  [ "$(cat "$TARGET/.tool-versions")" = "$before" ]

  # --force overwrites it back to the variant's version.
  run db init --target "$TARGET" --name demo --variant demo --force
  [ "$status" -eq 0 ]
  run grep -q "LOCAL EDIT" "$TARGET/.tool-versions"
  [ "$status" -ne 0 ]
}

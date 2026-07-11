#!/usr/bin/env bats
# diff (P5-1): the read-only precursor to `update`. It reports where a scaffolded
# project's core-owned files have drifted from the current kit - in sync, drifted,
# or missing - using the .devblueprint stamp (version + variant) as the base,
# without writing anything.

load helper

@test "diff reports a freshly scaffolded project as fully in sync" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db diff --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"scaffolded from: 0"*"up to date"* ]]
  [[ "$output" == *"ok"*".editorconfig"* ]]
  [[ "$output" == *"managed file(s) in sync"* ]]
  [[ "$output" != *"drifted"* ]]
  [[ "$output" != *"missing"* ]]
}

@test "diff flags a locally edited managed file as drifted" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  printf '\n# local edit\n' >> "$TARGET/.editorconfig"

  run db diff --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"drifted "*".editorconfig"* ]]
  [[ "$output" == *"1 drifted"* ]]
  # Drift points the user at update to re-sync.
  [[ "$output" == *"devblueprint update --target"* ]]
}

@test "diff flags a removed managed file as missing" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  rm "$TARGET/.gitattributes"

  run db diff --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"missing "*".gitattributes"* ]]
  [[ "$output" == *"1 missing"* ]]
}

@test "diff resolves the variant from the stamp to check the overlay docs" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db diff --target "$TARGET"
  [ "$status" -eq 0 ]
  # No --variant given, yet the variant-overlaid docs are compared (variant read
  # from the .devblueprint stamp).
  [[ "$output" == *"variant: generic"* ]]
  [[ "$output" == *"docs/engineering/conventions.md"* ]]
  [[ "$output" == *"docs/engineering/quality-and-testing.md"* ]]
}

@test "diff without a resolvable variant skips the overlay docs" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  # Drop the variant line from the stamp and pass no --variant: the overlay docs
  # cannot be rebuilt, so they are skipped rather than mis-reported.
  grep -v '^variant=' "$TARGET/.devblueprint" > "$TARGET/.devblueprint.tmp"
  mv "$TARGET/.devblueprint.tmp" "$TARGET/.devblueprint"

  run db diff --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"skip conventions.md, quality-and-testing.md"* ]]
}

@test "diff notes when the kit has advanced past the project's stamp" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  # Pretend the project was scaffolded from an older kit version.
  sed 's/^version=.*/version=0.0.1/' "$TARGET/.devblueprint" > "$TARGET/.devblueprint.tmp"
  mv "$TARGET/.devblueprint.tmp" "$TARGET/.devblueprint"

  run db diff --target "$TARGET" --variant generic
  [ "$status" -eq 0 ]
  [[ "$output" == *"scaffolded from: 0.0.1"* ]]
  [[ "$output" == *"kit has advanced"* ]]
}

@test "diff is read-only: it writes nothing" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  printf '\n# local edit\n' >> "$TARGET/.editorconfig"
  rm "$TARGET/.gitattributes"
  # Snapshot the tree, run diff, and assert the tree is byte-for-byte unchanged.
  cp -a "$TARGET" "$TEST_TMP/snapshot"

  db diff --target "$TARGET" >/dev/null

  run diff -r "$TEST_TMP/snapshot" "$TARGET"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "diff rejects a directory that is not a DevBlueprint project" {
  mkdir -p "$TARGET"

  run db diff --target "$TARGET"
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not look like a DevBlueprint project"* ]]
}

@test "diff requires --target" {
  run db diff
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing --target"* ]]
}

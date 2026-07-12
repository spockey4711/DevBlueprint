#!/usr/bin/env bats
# update: re-sync the core-owned files into a project scaffolded earlier,
# without touching the project's own CLAUDE.md, wt.conf or code.

load helper

@test "update re-syncs a removed stack-agnostic hygiene file" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  rm "$TARGET/.editorconfig"

  run db update --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"created .editorconfig"* ]]
  [ -f "$TARGET/.editorconfig" ]

  # doctor is green again now that the file is back.
  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
}

@test "update --dry-run reports the change without writing it" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  rm "$TARGET/.gitattributes"

  run db update --target "$TARGET" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"would create .gitattributes"* ]]
  [ ! -f "$TARGET/.gitattributes" ]
}

# --- P5-5: three-way merge -------------------------------------------------
#
# The merge base is the pristine kit copy cached in .devblueprint-base/. `update`
# seeds that cache, then reconciles local edits against it instead of overwriting.
# Several tests simulate an advanced kit by editing the cached base so it differs
# from the current kit (theirs) - the same three code inputs a real version bump
# would produce, without needing to move the kit under test.

@test "update seeds the .devblueprint-base merge-base cache" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db update --target "$TARGET"
  [ "$status" -eq 0 ]
  # The pristine kit copy is cached for each managed file, mirroring its path.
  [ -f "$TARGET/.devblueprint-base/.editorconfig" ]
  [ -f "$TARGET/.devblueprint-base/docs/engineering/git-workflow.md" ]
}

@test "update keeps a local edit when the kit has nothing new" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  db update --target "$TARGET" >/dev/null   # seed the base cache
  printf '\n# my local edit\n' >> "$TARGET/.editorconfig"

  run db update --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"kept local edits"* ]]
  # The edit survives: update did not overwrite it.
  grep -q "my local edit" "$TARGET/.editorconfig"
}

@test "update three-way merges an upstream change with a local edit" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  db update --target "$TARGET" >/dev/null
  # Simulate an upstream change: the base's first line differs from the current
  # kit, so the kit "advanced" that line.
  base="$TARGET/.devblueprint-base/.editorconfig"
  sed '1s/.*/# OLD BASE HEADER/' "$base" > "$base.tmp" && mv "$base.tmp" "$base"
  # A non-conflicting local edit elsewhere in the file.
  printf '\n# LOCAL APPEND\n' >> "$TARGET/.editorconfig"

  run db update --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"merged .editorconfig"* ]]
  [[ "$output" == *"merged local edits in 1"* ]]
  # Upstream line adopted, local edit preserved, no conflict markers.
  grep -q "LOCAL APPEND" "$TARGET/.editorconfig"
  ! grep -q "OLD BASE HEADER" "$TARGET/.editorconfig"
  ! grep -q "<<<<<<<" "$TARGET/.editorconfig"
}

@test "update fast-forwards an unedited file when the kit advances" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  db update --target "$TARGET" >/dev/null
  # Base and project file are an identical older version (no local edits), so the
  # user has not touched the file - update should advance it to the current kit.
  printf '# OLD CONTENT\n' > "$TARGET/.devblueprint-base/.gitattributes"
  printf '# OLD CONTENT\n' > "$TARGET/.gitattributes"

  run db update --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"updated .gitattributes"* ]]
  cmp -s "$TARGET/.gitattributes" "$REPO_ROOT/core/.gitattributes"
}

@test "update reports a conflict and keeps both sides with markers" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  db update --target "$TARGET" >/dev/null
  # Base, local, and kit all differ on the same line -> an unresolvable conflict.
  base="$TARGET/.devblueprint-base/.editorconfig"
  sed '1s/.*/# BASE VERSION/'  "$base" > "$base.tmp" && mv "$base.tmp" "$base"
  sed '1s/.*/# LOCAL VERSION/' "$TARGET/.editorconfig" > "$TARGET/.editorconfig.tmp" \
    && mv "$TARGET/.editorconfig.tmp" "$TARGET/.editorconfig"

  run db update --target "$TARGET"
  # A conflict is a partial failure: non-zero exit so scripts/CI notice.
  [ "$status" -ne 0 ]
  [[ "$output" == *"CONFLICT .editorconfig"* ]]
  [[ "$output" == *"could not be merged cleanly"* ]]
  # Both sides are preserved with standard conflict markers for manual resolution.
  grep -q "<<<<<<<" "$TARGET/.editorconfig"
  grep -q "# LOCAL VERSION" "$TARGET/.editorconfig"
}

@test "update never clobbers local edits with no recoverable merge base" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  # An older project that never ran update: the kit has advanced past its stamp and
  # there is no base cache, so a genuine merge is impossible.
  sed 's/^version=.*/version=0.0.1/' "$TARGET/.devblueprint" > "$TARGET/.devblueprint.tmp" \
    && mv "$TARGET/.devblueprint.tmp" "$TARGET/.devblueprint"
  rm -rf "$TARGET/.devblueprint-base"
  printf '\n# precious local edit\n' >> "$TARGET/.editorconfig"

  run db update --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"no merge base"* ]]
  # The local edit is untouched, and the base is seeded so the next update can merge.
  grep -q "precious local edit" "$TARGET/.editorconfig"
  [ -f "$TARGET/.devblueprint-base/.editorconfig" ]
}

@test "update --dry-run previews a merge without writing anything" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  db update --target "$TARGET" >/dev/null
  base="$TARGET/.devblueprint-base/.editorconfig"
  sed '1s/.*/# OLD BASE HEADER/' "$base" > "$base.tmp" && mv "$base.tmp" "$base"
  printf '\n# LOCAL APPEND\n' >> "$TARGET/.editorconfig"
  cp -a "$TARGET" "$TEST_TMP/snapshot"

  run db update --target "$TARGET" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"would merge .editorconfig"* ]]
  # Nothing on disk changed.
  run diff -r "$TEST_TMP/snapshot" "$TARGET"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# --- P15-1: guided `update` (no-flag interactive drift check + re-sync) -----
#
# `update` with no flags runs a plain-language wizard: it explains what an update
# is, asks only for the project folder, previews the drift by reusing the real
# update code path in dry-run, and re-syncs only on an explicit yes. Answers are
# piped on stdin (folder, then the final confirm) so the flow runs in one shot.

@test "guided update (no flags) detects drift and re-syncs on confirm" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  rm "$TARGET/.editorconfig"

  # Folder, then confirm the apply.
  run bash -c "printf '%s\ny\n' '$TARGET' | '$DEVBLUEPRINT' update"
  [ "$status" -eq 0 ]
  # It previews the change before touching disk, then applies it.
  [[ "$output" == *"nothing has touched disk yet"* ]]
  [[ "$output" == *"would create .editorconfig"* ]]
  [[ "$output" == *"created .editorconfig"* ]]
  [ -f "$TARGET/.editorconfig" ]
}

@test "guided update writes nothing when the final confirm is declined" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  rm "$TARGET/.editorconfig"

  run bash -c "printf '%s\nn\n' '$TARGET' | '$DEVBLUEPRINT' update"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Cancelled - nothing was written"* ]]
  [ ! -e "$TARGET/.editorconfig" ]
}

@test "guided update reports an in-sync project and asks for no confirm" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  # Only the folder is supplied; a fresh scaffold has no drift, so the wizard
  # never reaches the confirm and writes nothing.
  run bash -c "printf '%s\n' '$TARGET' | '$DEVBLUEPRINT' update"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already in sync"* ]]
  [[ "$output" != *"Apply these updates now?"* ]]
}

@test "guided update opens with an explanation before the one question" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run bash -c "printf '%s\n' '$TARGET' | '$DEVBLUEPRINT' update"
  [ "$status" -eq 0 ]
  # Plain-language framing, matching the init wizard's shape.
  [[ "$output" == *"never touched"* ]]
  [[ "$output" == *"Which project folder should be refreshed?"* ]]
}

@test "guided update resolves the variant from the stamp to refresh overlaid docs" {
  db init --target "$TARGET" --name demo --variant node-express >/dev/null
  # Drift a variant-owned doc; the wizard must consider it (not skip it), which it
  # only can if it resolved node-express from the stamp without a --variant flag.
  echo "local drift" > "$TARGET/docs/engineering/quality-and-testing.md"

  run bash -c "printf '%s\nn\n' '$TARGET' | '$DEVBLUEPRINT' update"
  [ "$status" -eq 0 ]
  [[ "$output" != *"pass --variant to refresh"* ]]
  [[ "$output" == *"quality-and-testing.md"* ]]
}

@test "guided update on a non-scaffold folder fails with recovery guidance" {
  mkdir -p "$TARGET"
  : > "$TARGET/random.txt"

  run bash -c "printf '%s\n' '$TARGET' | '$DEVBLUEPRINT' update"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not look like a DevBlueprint project"* ]]
}

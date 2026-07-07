#!/usr/bin/env bats
# Overwrite safety: a second `init` must never clobber existing files unless
# --force is given.

load helper

@test "re-running init skips existing files and leaves them untouched" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  # Mark the file so we can prove it was not rewritten.
  echo "LOCAL EDIT - keep me" >> "$TARGET/CLAUDE.md"
  before="$(cat "$TARGET/CLAUDE.md")"

  run db init --target "$TARGET" --name demo --variant generic
  [ "$status" -eq 0 ]
  [[ "$output" == *"skip CLAUDE.md"* ]]

  [ "$(cat "$TARGET/CLAUDE.md")" = "$before" ]
}

@test "--force overwrites an existing file" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  echo "LOCAL EDIT - clobber me" >> "$TARGET/CLAUDE.md"

  run db init --target "$TARGET" --name demo --variant generic --force
  [ "$status" -eq 0 ]
  [[ "$output" == *"wrote CLAUDE.md"* ]]

  # The local edit is gone; the file is back to the rendered template.
  run grep -q "LOCAL EDIT" "$TARGET/CLAUDE.md"
  [ "$status" -ne 0 ]
  [[ "$(head -n 1 "$TARGET/CLAUDE.md")" == "# demo" ]]
}

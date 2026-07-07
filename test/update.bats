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

#!/usr/bin/env bats
# --agents: init emits instruction files for the selected coding agents from the
# same canonical guidance as CLAUDE.md, records the choice in the .devblueprint
# stamp, and update re-renders them in step.

load helper

@test "init --agents emits the selected agent files and doctor still passes" {
  run db init --target "$TARGET" --name AcmeApp --variant generic \
    --agents claude,cursor,codex,copilot
  [ "$status" -eq 0 ]

  [ -f "$TARGET/CLAUDE.md" ]
  [ -f "$TARGET/AGENTS.md" ]
  [ -f "$TARGET/.cursor/rules/acmeapp.mdc" ]
  [ -f "$TARGET/.github/copilot-instructions.md" ]

  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
}

@test "default init emits only CLAUDE.md, no other agent files" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  [ -f "$TARGET/CLAUDE.md" ]
  [ ! -f "$TARGET/AGENTS.md" ]
  [ ! -d "$TARGET/.cursor" ]
  [ ! -f "$TARGET/.github/copilot-instructions.md" ]

  # The stamp still records the (default) claude-only selection.
  grep -q '^agents=claude$' "$TARGET/.devblueprint"
}

@test "the stamp records the selected agents" {
  db init --target "$TARGET" --name demo --variant generic \
    --agents cursor,codex >/dev/null

  # claude is always included and the order is canonical.
  grep -q '^agents=claude,codex,cursor$' "$TARGET/.devblueprint"
}

@test "agent files have every token substituted" {
  db init --target "$TARGET" --name AcmeApp --variant generic \
    --agents codex,cursor,copilot >/dev/null

  run grep -Rn "{{" "$TARGET/AGENTS.md" "$TARGET/.cursor/rules/acmeapp.mdc" \
    "$TARGET/.github/copilot-instructions.md"
  [ "$status" -ne 0 ]

  # PROJECT_NAME and the generic gate landed in the tool-neutral copy.
  [[ "$(head -n 1 "$TARGET/AGENTS.md")" == "# AcmeApp" ]]
  grep -q 'make check' "$TARGET/AGENTS.md"
}

@test "the cursor rule filename is a slug of the project name" {
  db init --target "$TARGET" --name "Acme App" --variant generic \
    --agents cursor >/dev/null

  [ -f "$TARGET/.cursor/rules/acme-app.mdc" ]
}

@test "--base master renders the trunk workflow in the agent files" {
  db init --target "$TARGET" --name Solo --variant generic --base master \
    --agents codex >/dev/null

  grep -q 'One long-lived branch (trunk)' "$TARGET/AGENTS.md"
  ! grep -q 'develop' "$TARGET/AGENTS.md"
}

@test "init rejects an unknown agent" {
  run db init --target "$TARGET" --name demo --variant generic --agents claude,nope
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown agent"* ]]
}

@test "plan previews the agent files without writing them" {
  run db plan --target "$TARGET" --name Foo --variant generic --agents cursor,codex
  [ "$status" -eq 0 ]
  [[ "$output" == *"would write AGENTS.md"* ]]
  [[ "$output" == *"would write .cursor/rules/foo.mdc"* ]]
  [ ! -e "$TARGET" ]
}

@test "update re-renders a corrupted agent file and is idempotent" {
  db init --target "$TARGET" --name AcmeApp --variant generic \
    --agents cursor,codex >/dev/null

  echo "corrupted" > "$TARGET/AGENTS.md"
  rm "$TARGET/.cursor/rules/acmeapp.mdc"

  run db update --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"updated AGENTS.md"* ]]
  [[ "$output" == *"created .cursor/rules/acmeapp.mdc"* ]]
  [[ "$(head -n 1 "$TARGET/AGENTS.md")" == "# AcmeApp" ]]

  # Re-running changes nothing.
  run db update --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"unchanged AGENTS.md"* ]]
}

@test "update leaves CLAUDE.md untouched while re-syncing agent files" {
  db init --target "$TARGET" --name demo --variant generic --agents codex >/dev/null

  # A user edit to the canonical CLAUDE.md must survive update.
  printf '\nlocal note\n' >> "$TARGET/CLAUDE.md"
  cp "$TARGET/CLAUDE.md" "$TARGET/.claude-before"

  run db update --target "$TARGET"
  [ "$status" -eq 0 ]
  cmp -s "$TARGET/CLAUDE.md" "$TARGET/.claude-before"
}

@test "update on a default project never creates agent files" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db update --target "$TARGET"
  [ "$status" -eq 0 ]
  [ ! -f "$TARGET/AGENTS.md" ]
  [[ "$output" != *"AGENTS.md"* ]]
}

@test "update --dry-run reports an agent change without writing it" {
  db init --target "$TARGET" --name demo --variant generic --agents codex >/dev/null
  echo "corrupted" > "$TARGET/AGENTS.md"

  run db update --target "$TARGET" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"would update AGENTS.md"* ]]
  [[ "$(cat "$TARGET/AGENTS.md")" == "corrupted" ]]
}

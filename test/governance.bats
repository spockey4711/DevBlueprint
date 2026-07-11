#!/usr/bin/env bats
# Governance scaffolding (P7-5): every project ships scripts/protect-branches.sh
# so the documented workflow can be enforced via `gh api`, and --community adds a
# .github/CODEOWNERS review-routing file alongside the other community-health
# files.

load helper

@test "init ships an executable protect-branches.sh by default" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  [ -f "$TARGET/scripts/protect-branches.sh" ]
  [ -x "$TARGET/scripts/protect-branches.sh" ]

  # It shares wt.sh's branch config rather than hardcoding branch names.
  grep -q 'wt.conf' "$TARGET/scripts/protect-branches.sh"
}

@test "init does not scaffold CODEOWNERS by default" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  [ ! -e "$TARGET/.github/CODEOWNERS" ]

  # doctor must still pass without it - governance files are optional.
  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
}

@test "--community scaffolds CODEOWNERS with tokens substituted" {
  db init --target "$TARGET" --name AcmeApp --variant generic --community >/dev/null

  [ -f "$TARGET/.github/CODEOWNERS" ]

  # No template placeholder survives rendering.
  run grep -n "{{" "$TARGET/.github/CODEOWNERS"
  [ "$status" -ne 0 ]

  # The fill-in owner handle and the project name landed.
  grep -q "@OWNER" "$TARGET/.github/CODEOWNERS"
  grep -q "AcmeApp" "$TARGET/.github/CODEOWNERS"
}

@test "--community respects CODEOWNERS overwrite safety" {
  db init --target "$TARGET" --name demo --variant generic --community >/dev/null

  printf 'hand-edited\n' > "$TARGET/.github/CODEOWNERS"
  run db init --target "$TARGET" --name demo --variant generic --community
  [ "$status" -eq 0 ]
  [[ "$output" == *"skip .github/CODEOWNERS"* ]]
  [[ "$(cat "$TARGET/.github/CODEOWNERS")" == "hand-edited" ]]
}

@test "update re-syncs a removed protect-branches.sh" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  rm "$TARGET/scripts/protect-branches.sh"

  run db update --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"created scripts/protect-branches.sh"* ]]
  [ -f "$TARGET/scripts/protect-branches.sh" ]
  [ -x "$TARGET/scripts/protect-branches.sh" ]
}

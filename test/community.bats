#!/usr/bin/env bats
# Optional community-health files: --community opts into SECURITY.md and
# CODE_OF_CONDUCT.md, --contact fills the reporting address, and neither file is
# scaffolded (nor required by doctor) without the flag.

load helper

@test "init does not scaffold community files by default" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  [ ! -e "$TARGET/SECURITY.md" ]
  [ ! -e "$TARGET/CODE_OF_CONDUCT.md" ]

  # doctor must still pass without them - they are optional, not foundation.
  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
}

@test "--community scaffolds both files with tokens substituted" {
  db init --target "$TARGET" --name AcmeApp --variant generic \
    --community --contact "security@acme.dev" >/dev/null

  [ -f "$TARGET/SECURITY.md" ]
  [ -f "$TARGET/CODE_OF_CONDUCT.md" ]

  # No template placeholder survives rendering.
  run grep -Rn "{{" "$TARGET/SECURITY.md" "$TARGET/CODE_OF_CONDUCT.md"
  [ "$status" -ne 0 ]

  # PROJECT_NAME and the contact address landed.
  grep -q "AcmeApp" "$TARGET/SECURITY.md"
  grep -q "security@acme.dev" "$TARGET/SECURITY.md"
  grep -q "security@acme.dev" "$TARGET/CODE_OF_CONDUCT.md"
}

@test "--community without --contact leaves a fill-in placeholder" {
  db init --target "$TARGET" --name demo --variant generic --community >/dev/null

  grep -q "INSERT CONTACT METHOD" "$TARGET/SECURITY.md"
  grep -q "INSERT CONTACT METHOD" "$TARGET/CODE_OF_CONDUCT.md"

  # The placeholder is not a leftover token.
  run grep -Rn "{{" "$TARGET/SECURITY.md" "$TARGET/CODE_OF_CONDUCT.md"
  [ "$status" -ne 0 ]
}

@test "--community respects overwrite safety" {
  db init --target "$TARGET" --name demo --variant generic --community \
    --contact first@demo.dev >/dev/null

  # A second run without --force must not clobber an edited SECURITY.md.
  printf 'hand-edited\n' > "$TARGET/SECURITY.md"
  run db init --target "$TARGET" --name demo --variant generic --community \
    --contact second@demo.dev
  [ "$status" -eq 0 ]
  [[ "$output" == *"skip SECURITY.md"* ]]
  [[ "$(cat "$TARGET/SECURITY.md")" == "hand-edited" ]]
}

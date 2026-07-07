#!/usr/bin/env bats
# Token substitution and branch modes: rendered docs must carry the project's
# real values, with no {{TOKENS}} left behind.

load helper

@test "CLAUDE.md and CONTRIBUTING.md have every token substituted" {
  db init --target "$TARGET" --name AcmeApp --variant generic >/dev/null

  # No template placeholder survives rendering.
  run grep -Rn "{{" "$TARGET/CLAUDE.md" "$TARGET/CONTRIBUTING.md"
  [ "$status" -ne 0 ]

  # PROJECT_NAME landed in both.
  [[ "$(head -n 1 "$TARGET/CLAUDE.md")" == "# AcmeApp" ]]
  grep -q "AcmeApp" "$TARGET/CLAUDE.md"

  # WT_CMD and QUALITY_GATE from the generic manifest landed too.
  grep -q './scripts/wt.sh new <type>/<slug>' "$TARGET/CLAUDE.md"
  grep -q 'make check' "$TARGET/CLAUDE.md"
  grep -q 'make check' "$TARGET/CONTRIBUTING.md"
}

@test "default init renders the two-branch develop -> master workflow" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  grep -q 'integrates on `develop`' "$TARGET/CLAUDE.md"
  grep -q 'always-deployable `master`' "$TARGET/CLAUDE.md"

  grep -q 'MAIN_BRANCH="master"' "$TARGET/scripts/wt.conf"
  grep -q 'BASE_BRANCH="develop"' "$TARGET/scripts/wt.conf"
}

@test "--base master selects single-branch mode in docs and wt.conf" {
  db init --target "$TARGET" --name demo --variant generic --base master >/dev/null

  # wt.conf collapses the integration branch onto master.
  grep -q 'MAIN_BRANCH="master"' "$TARGET/scripts/wt.conf"
  grep -q 'BASE_BRANCH="master"' "$TARGET/scripts/wt.conf"
  ! grep -q 'BASE_BRANCH="develop"' "$TARGET/scripts/wt.conf"

  # No stray develop leaks into the rendered guidance, and no tokens remain.
  ! grep -q 'develop' "$TARGET/CLAUDE.md"
  run grep -n "{{" "$TARGET/CLAUDE.md"
  [ "$status" -ne 0 ]
}

@test "--main and --base custom branches propagate to wt.conf" {
  db init --target "$TARGET" --name demo --variant generic \
    --main main --base dev >/dev/null

  grep -q 'MAIN_BRANCH="main"' "$TARGET/scripts/wt.conf"
  grep -q 'BASE_BRANCH="dev"' "$TARGET/scripts/wt.conf"
}

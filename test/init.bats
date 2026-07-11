#!/usr/bin/env bats
# init + doctor: the core promise. `init` scaffolds a project from core + a
# variant, and `doctor` confirms every foundation file landed.

load helper

@test "list prints the available variants" {
  run db list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Available variants:"* ]]
  [[ "$output" == *"generic"* ]]
}

@test "init scaffolds the generic variant and doctor passes" {
  run db init --target "$TARGET" --name demo --variant generic
  [ "$status" -eq 0 ]

  # Foundation files exist on disk.
  [ -f "$TARGET/CLAUDE.md" ]
  [ -f "$TARGET/CONTRIBUTING.md" ]
  [ -f "$TARGET/CHANGELOG.md" ]
  [ -f "$TARGET/.gitignore" ]
  [ -f "$TARGET/.editorconfig" ]
  [ -f "$TARGET/.gitattributes" ]
  [ -f "$TARGET/scripts/wt.sh" ]
  [ -f "$TARGET/scripts/wt.conf" ]
  [ -f "$TARGET/.github/workflows/ci.yml" ]
  [ -f "$TARGET/.github/workflows/release.yml" ]
  [ -f "$TARGET/.github/release-please-config.json" ]
  [ -f "$TARGET/.github/release-please-manifest.json" ]
  [ -f "$TARGET/.github/pull_request_template.md" ]
  [ -f "$TARGET/.github/ISSUE_TEMPLATE/bug_report.md" ]
  [ -f "$TARGET/.github/ISSUE_TEMPLATE/feature_request.md" ]
  [ -f "$TARGET/.github/ISSUE_TEMPLATE/config.yml" ]
  [ -f "$TARGET/docs/engineering/git-workflow.md" ]

  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"all foundation files present"* ]]
}

@test "init followed by doctor passes for every variant" {
  for variant in "$REPO_ROOT"/variants/*/; do
    [ -f "$variant/manifest.env" ] || continue
    name="$(basename "$variant")"
    dest="$TEST_TMP/$name"

    run db init --target "$dest" --name "$name" --variant "$name"
    [ "$status" -eq 0 ] || { echo "init failed for $name: $output"; false; }

    run db doctor --target "$dest"
    [ "$status" -eq 0 ] || { echo "doctor failed for $name: $output"; false; }
  done
}

@test "init defaults the project name to the target basename" {
  run db init --target "$TARGET" --variant generic
  [ "$status" -eq 0 ]
  [[ "$(head -n 1 "$TARGET/CLAUDE.md")" == "# project" ]]
}

@test "doctor reports failure and exits non-zero when a file is missing" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  rm "$TARGET/CLAUDE.md"

  run db doctor --target "$TARGET"
  [ "$status" -ne 0 ]
  [[ "$output" == *"MISS"* ]]
  [[ "$output" == *"CLAUDE.md"* ]]
}

@test "init rejects an unknown variant" {
  run db init --target "$TARGET" --name demo --variant nope
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown variant"* ]]
}

@test "init requires --target and --variant" {
  run db init --name demo --variant generic
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing --target"* ]]

  run db init --target "$TARGET" --name demo
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing --variant"* ]]
}

@test "unknown command exits non-zero" {
  run db frobnicate
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown command"* ]]
}

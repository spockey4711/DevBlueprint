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
  [ -f "$TARGET/.github/workflows/preview-deploy.yml" ]
  [ -f "$TARGET/.gitlab-ci.yml" ]
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

@test "init scaffolds provider-agnostic CI (GitLab + preview deploy) for every variant" {
  for variant in "$REPO_ROOT"/variants/*/; do
    [ -f "$variant/manifest.env" ] || continue
    name="$(basename "$variant")"
    dest="$TEST_TMP/pa-$name"

    run db init --target "$dest" --name "$name" --variant "$name"
    [ "$status" -eq 0 ] || { echo "init failed for $name: $output"; false; }

    # GitLab pipeline lands at the project root, its GitHub twin under workflows/.
    [ -f "$dest/.gitlab-ci.yml" ] || { echo "no .gitlab-ci.yml for $name"; false; }
    [ -f "$dest/.github/workflows/preview-deploy.yml" ] \
      || { echo "no preview-deploy.yml for $name"; false; }

    # The GitLab pipeline carries the three managed security scanners and a
    # preview environment, mirroring security.yml + preview-deploy.yml.
    grep -q "Security/SAST.gitlab-ci.yml" "$dest/.gitlab-ci.yml"
    grep -q "deploy:preview" "$dest/.gitlab-ci.yml"
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

# The no-flag interactive wizard: answers piped on stdin drive it in one shot.
# Order: project name, target folder, variant, branch-workflow choice, confirm.

@test "wizard (init with no flags) previews the plan, then scaffolds on confirm" {
  run bash -c "printf 'Demo App\n%s\ngeneric\n1\ny\n' '$TARGET' | '$DEVBLUEPRINT' init"
  [ "$status" -eq 0 ]

  # It shows exactly what would be written before touching disk, reusing `plan`.
  [[ "$output" == *"nothing has touched disk yet"* ]]
  [[ "$output" == *"Plan: init would scaffold"* ]]

  # Then it scaffolds for real: foundation files land and doctor passes.
  [ -f "$TARGET/CLAUDE.md" ]
  grep -q "Demo App" "$TARGET/CLAUDE.md"
  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
}

@test "wizard writes nothing when the final confirm is declined" {
  run bash -c "printf 'X\n%s\ngeneric\n1\nn\n' '$TARGET' | '$DEVBLUEPRINT' init"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Cancelled - nothing was written"* ]]
  [ ! -e "$TARGET" ]
}

@test "wizard re-prompts on an unknown variant" {
  run bash -c "printf 'X\n%s\nnope\ngeneric\n1\nn\n' '$TARGET' | '$DEVBLUEPRINT' init"
  [ "$status" -eq 0 ]
  [[ "$output" == *"not a known variant"* ]]
}

@test "wizard with no input at all cancels without scaffolding" {
  run bash -c "'$DEVBLUEPRINT' init </dev/null"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Cancelled - nothing was written"* ]]
  [ ! -e "$TARGET" ]
}

@test "wizard option 2 sets up a single-branch (trunk) workflow" {
  run bash -c "printf 'X\n%s\ngeneric\n2\nmain\ny\n' '$TARGET' | '$DEVBLUEPRINT' init"
  [ "$status" -eq 0 ]
  [[ "$output" == *"git branch -M main"* ]]
  [[ "$output" != *"git switch -c"* ]]
}

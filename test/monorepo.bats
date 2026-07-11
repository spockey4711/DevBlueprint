#!/usr/bin/env bats
# Monorepo / multi-variant init (P6-1). One repo, multiple packages, each with its
# own stack overlay and quality gate, tied together by shared root docs, an
# aggregated CI workflow, and a root `make check` that runs every package's gate.

load helper

@test "monorepo init lays shared root files once and a per-package overlay each" {
  run db init --target "$TARGET" --name shop \
    --package api:backend-python --package web:web-nextjs
  [ "$status" -eq 0 ]

  # Shared root, written once (not per package).
  [ -f "$TARGET/CLAUDE.md" ]
  [ -f "$TARGET/CONTRIBUTING.md" ]
  [ -f "$TARGET/CHANGELOG.md" ]
  [ -f "$TARGET/Makefile" ]
  [ -f "$TARGET/.gitignore" ]
  [ -f "$TARGET/.editorconfig" ]
  [ -f "$TARGET/.gitattributes" ]
  [ -f "$TARGET/scripts/wt.sh" ]
  [ -f "$TARGET/scripts/wt.conf" ]
  [ -f "$TARGET/.github/workflows/ci.yml" ]
  [ -f "$TARGET/.github/pull_request_template.md" ]
  [ -f "$TARGET/docs/engineering/git-workflow.md" ]
  [ -f "$TARGET/docs/project/backlog.md" ]
  # No single-variant conventions overlay or per-stack doc at the root.
  [ ! -f "$TARGET/docs/engineering/quality-and-testing.md" ]

  # Each package carries its own stack overlay.
  [ -f "$TARGET/packages/api/docs/engineering/quality-and-testing.md" ]
  [ -f "$TARGET/packages/api/.gitignore" ]
  [ -f "$TARGET/packages/api/setup.sh" ]
  [ -f "$TARGET/packages/web/docs/engineering/quality-and-testing.md" ]
  [ -f "$TARGET/packages/web/setup.sh" ]

  # Per-variant github/ trees are not copied into the packages (their workflows
  # assume a single-stack root); the aggregated root workflow replaces them.
  [ ! -d "$TARGET/packages/api/.github" ]
  [ ! -d "$TARGET/packages/web/.github" ]
}

@test "monorepo init scaffolds each package's source skeleton" {
  run db init --target "$TARGET" --package api:backend-python --package svc:backend-go
  [ "$status" -eq 0 ]

  # SRC_DIRS come from each variant's manifest, rooted under its package.
  [ -f "$TARGET/packages/api/app/routes/.gitkeep" ]
  [ -f "$TARGET/packages/api/tests/unit/.gitkeep" ]
  [ -f "$TARGET/packages/svc/cmd/.gitkeep" ]
  [ -f "$TARGET/packages/svc/internal/.gitkeep" ]
}

@test "root Makefile aggregates each package's own quality gate" {
  run db init --target "$TARGET" --package api:backend-python --package web:web-nextjs
  [ "$status" -eq 0 ]

  run cat "$TARGET/Makefile"
  # Each variant leads its gate with the env-schema check.
  [[ "$output" == *"cd packages/api && sh scripts/check-env.sh && ruff check ."* ]]
  [[ "$output" == *"cd packages/web && sh scripts/check-env.sh && pnpm lint"* ]]
}

@test "root Makefile doubles a literal \$ in a gate so make passes it to the shell" {
  run db init --target "$TARGET" --package svc:backend-go
  [ "$status" -eq 0 ]

  # The Go gate contains $(gofumpt -l .); in a recipe that must be $$(...) so make
  # does not expand it as a make variable. The generated Makefile must parse. The
  # gate leads with the env-schema check (`sh scripts/check-env.sh`).
  run grep -F 'cd packages/svc && sh scripts/check-env.sh && test -z "$$(gofumpt -l .)"' "$TARGET/Makefile"
  [ "$status" -eq 0 ]

  if command -v make >/dev/null; then
    run make -n -C "$TARGET" check
    [ "$status" -eq 0 ]
    [[ "$output" == *'test -z "$(gofumpt -l .)"'* ]]
  fi
}

@test "aggregated CI workflow has one matrix entry per package" {
  run db init --target "$TARGET" --base master --main master \
    --package api:backend-python --package web:web-nextjs
  [ "$status" -eq 0 ]

  run cat "$TARGET/.github/workflows/ci.yml"
  [[ "$output" == *"- package: api"* ]]
  # Each gate leads with the env-schema check.
  [[ "$output" == *"gate: 'sh scripts/check-env.sh && ruff check ."* ]]
  [[ "$output" == *"- package: web"* ]]
  [[ "$output" == *"gate: 'sh scripts/check-env.sh && pnpm lint"* ]]
  [[ "$output" == *'working-directory: packages/${{ matrix.package }}'* ]]
  # Single-branch flow collapses the push branches to just master.
  [[ "$output" == *'branches: [ "master" ]'* ]]
}

@test "root stamp records the monorepo package map; each package stamps its variant" {
  run db init --target "$TARGET" --package api:backend-python --package web:web-nextjs
  [ "$status" -eq 0 ]

  run cat "$TARGET/.devblueprint"
  [[ "$output" == *"monorepo=true"* ]]
  [[ "$output" == *"packages=api:backend-python,web:web-nextjs"* ]]

  run cat "$TARGET/packages/api/.devblueprint"
  [[ "$output" == *"variant=backend-python"* ]]
  [[ "$output" == *"package=api"* ]]

  run cat "$TARGET/packages/web/.devblueprint"
  [[ "$output" == *"variant=web-nextjs"* ]]
}

@test "root CLAUDE.md describes the packages and the aggregated gate" {
  run db init --target "$TARGET" --package api:backend-python --package web:web-nextjs
  [ "$status" -eq 0 ]

  run cat "$TARGET/CLAUDE.md"
  [[ "$output" == *"packages/api"* ]]
  [[ "$output" == *"Backend / API (Python + uv)"* ]]
  [[ "$output" == *"packages/web"* ]]
  [[ "$output" == *"Web app (Next.js + pnpm)"* ]]
  [[ "$output" == *"make check"* ]]
}

@test "--packages comma list is equivalent to repeated --package" {
  run db init --target "$TARGET" --packages api:backend-python,web:web-nextjs
  [ "$status" -eq 0 ]
  [ -d "$TARGET/packages/api" ]
  [ -d "$TARGET/packages/web" ]
}

@test "monorepo project name defaults to the target basename" {
  run db init --target "$TARGET" --package api:backend-python
  [ "$status" -eq 0 ]
  [[ "$(head -n 1 "$TARGET/CLAUDE.md")" == "# project" ]]
}

@test "monorepo plan writes nothing" {
  run db plan --target "$TARGET" --package api:backend-python --package web:web-nextjs
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plan only"* ]]
  [[ "$output" == *"would create packages/api/"* ]]
  [ ! -e "$TARGET" ]
}

@test "--variant and --package are mutually exclusive" {
  run db init --target "$TARGET" --variant generic --package api:backend-python
  [ "$status" -ne 0 ]
  [[ "$output" == *"mutually exclusive"* ]]
}

@test "a --package without a variant is rejected" {
  run db init --target "$TARGET" --package api
  [ "$status" -ne 0 ]
  [[ "$output" == *"expected <name>:<variant>"* ]]
}

@test "an unknown variant in a --package is rejected" {
  run db init --target "$TARGET" --package api:nope
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown variant 'nope'"* ]]
}

@test "a duplicate package name is rejected" {
  run db init --target "$TARGET" --package api:generic --package api:backend-go
  [ "$status" -ne 0 ]
  [[ "$output" == *"duplicate package name"* ]]
}

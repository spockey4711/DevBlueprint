#!/usr/bin/env bats
# Flavors: orthogonal add-on overlays (db, container, auth, ...) layered onto a base
# variant at init with --flavor. Assert discovery (list), resolution/validation, the
# overlay landing on disk, the stamp record, and the guard rails.

load helper

@test "list shows the add-on flavors" {
  run db list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Add-on flavors"* ]]
  [[ "$output" == *"postgres"* ]]
  [[ "$output" == *"docker"* ]]
  [[ "$output" == *"auth"* ]]
}

@test "list --json carries a flavors array" {
  run db list --json
  [ "$status" -eq 0 ]
  names="$(printf '%s' "$output" | python3 -c 'import sys,json; print(",".join(f["name"] for f in json.load(sys.stdin)["flavors"]))')"
  [[ "$names" == *"postgres"* ]]
  [[ "$names" == *"docker"* ]]
}

@test "init lays a flavor overlay and records it in the stamp" {
  run db init --target "$TARGET" --name demo --variant generic --flavor docker
  [ "$status" -eq 0 ]

  [ -f "$TARGET/.dockerignore" ]
  [ -f "$TARGET/docs/flavors/docker.md" ]
  grep -q '^flavors=docker$' "$TARGET/.devblueprint"

  # The base scaffold still passes doctor with a flavor layered on.
  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
}

@test "init layers several flavors and dedupes repeats" {
  run db init --target "$TARGET" --variant generic --flavor postgres,docker,docker
  [ "$status" -eq 0 ]
  [ -f "$TARGET/docker-compose.yml" ]
  [ -f "$TARGET/docs/flavors/postgres.md" ]
  [ -f "$TARGET/docs/flavors/docker.md" ]
  grep -q '^flavors=postgres,docker$' "$TARGET/.devblueprint"
}

@test "a flavor gitignore.append merges into .gitignore" {
  run db init --target "$TARGET" --variant generic --flavor auth
  [ "$status" -eq 0 ]
  grep -q '\*.pem' "$TARGET/.gitignore"
  grep -q 'secrets/' "$TARGET/.gitignore"
}

@test "no --flavor leaves the stamp without a flavors line" {
  run db init --target "$TARGET" --variant generic
  [ "$status" -eq 0 ]
  ! grep -q '^flavors=' "$TARGET/.devblueprint"
}

@test "an unknown flavor is a hard error" {
  run db init --target "$TARGET" --variant generic --flavor nope
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown flavor 'nope'"* ]]
  [ ! -d "$TARGET" ]
}

@test "--flavor and --package are mutually exclusive" {
  run db init --target "$TARGET" --package api:generic --flavor docker
  [ "$status" -ne 0 ]
  [[ "$output" == *"mutually exclusive"* ]]
}

@test "an intake file can carry a flavors key" {
  cat > "$TEST_TMP/intake.yml" <<'EOF'
variant: generic
flavors: postgres, docker
EOF
  run db init --target "$TARGET" --from "$TEST_TMP/intake.yml"
  [ "$status" -eq 0 ]
  grep -q '^flavors=postgres,docker$' "$TARGET/.devblueprint"
  [ -f "$TARGET/docker-compose.yml" ]
}

@test "plan lists flavors and writes nothing" {
  run db init --dry-run --target "$TARGET" --variant generic --flavor docker
  [ "$status" -eq 0 ]
  [[ "$output" == *"Flavors: docker"* ]]
  [[ "$output" == *"--flavor docker"* ]]
  [ ! -d "$TARGET" ]
}

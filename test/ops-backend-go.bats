#!/usr/bin/env bats
# Ops artifacts for the backend-go variant (P7-3): the env schema is a real gate
# check, not just a doc. These tests scaffold the backend-go variant and exercise
# the shipped scripts/check-env.sh directly, so drift between .env.example and
# .env.schema fails the build. The check-env mechanism's edge cases (rogue key,
# missing key, pattern violation) are covered generically in env-schema.bats; here
# we assert the backend-go variant ships and wires the artifacts correctly.

load helper

# Scaffold backend-go once per test into $TARGET; CHECK points at the validator.
scaffold_backend_go() {
  db init --target "$TARGET" --name ops-demo --variant backend-go --force >/dev/null
  CHECK="$TARGET/scripts/check-env.sh"
}

@test "backend-go ships the ops artifacts" {
  scaffold_backend_go
  [ -f "$TARGET/.env.schema" ]
  [ -f "$TARGET/scripts/check-env.sh" ]
  [ -f "$TARGET/Dockerfile" ]
  [ -f "$TARGET/.dockerignore" ]
  [ -f "$TARGET/docker-compose.yml" ]
  [ -f "$TARGET/deploy/fly.toml" ]
  [ -f "$TARGET/deploy/render.yaml" ]
  [ -f "$TARGET/deploy/terraform/main.tf" ]
}

@test "make check wires the validate-env step into the gate" {
  scaffold_backend_go
  run grep -E '^check:.*validate-env' "$TARGET/Makefile"
  [ "$status" -eq 0 ]
}

@test "CI runs the env-schema check" {
  scaffold_backend_go
  run grep -F 'check-env.sh' "$TARGET/.github/workflows/ci.yml"
  [ "$status" -eq 0 ]
}

@test "check-env passes on the freshly scaffolded env files" {
  scaffold_backend_go
  run sh "$CHECK" --schema "$TARGET/.env.schema" --example "$TARGET/.env.example"
  [ "$status" -eq 0 ]
  [[ "$output" == *"valid"* ]]
}

@test "the Dockerfile builds a static binary and runs non-root" {
  scaffold_backend_go
  run grep -F 'CGO_ENABLED=0' "$TARGET/Dockerfile"
  [ "$status" -eq 0 ]
  run grep -E '^USER ' "$TARGET/Dockerfile"
  [ "$status" -eq 0 ]
}

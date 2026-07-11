#!/usr/bin/env bats
# Ops artifacts for the generic variant (P7-3): the env schema is a real gate
# check, not just a doc. These tests scaffold the generic variant and exercise the
# shipped scripts/check-env.sh directly, so drift between .env.example and
# .env.schema - and a real .env that violates the schema - fails the build.

load helper

# Scaffold generic once per test into $TARGET; CHECK points at the shipped validator.
scaffold_generic() {
  db init --target "$TARGET" --name ops-demo --variant generic --force >/dev/null
  CHECK="$TARGET/scripts/check-env.sh"
}

@test "generic ships the ops artifacts" {
  scaffold_generic
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
  scaffold_generic
  run grep -E '^check:.*validate-env' "$TARGET/Makefile"
  [ "$status" -eq 0 ]
}

@test "check-env passes on the freshly scaffolded env files" {
  scaffold_generic
  run sh "$CHECK" --schema "$TARGET/.env.schema" --example "$TARGET/.env.example"
  [ "$status" -eq 0 ]
  [[ "$output" == *"valid"* ]]
}

@test "check-env fails when .env.example carries an undeclared variable" {
  scaffold_generic
  printf '\n# ROGUE_KEY=1\n' >> "$TARGET/.env.example"
  run sh "$CHECK" --schema "$TARGET/.env.schema" --example "$TARGET/.env.example"
  [ "$status" -eq 1 ]
  [[ "$output" == *"ROGUE_KEY"* ]]
}

@test "check-env fails when a schema variable is missing from .env.example" {
  scaffold_generic
  printf 'GHOST_KEY optional # declared but undocumented\n' >> "$TARGET/.env.schema"
  run sh "$CHECK" --schema "$TARGET/.env.schema" --example "$TARGET/.env.example"
  [ "$status" -eq 1 ]
  [[ "$output" == *"GHOST_KEY"* ]]
}

@test "check-env fails when a required key is unset in a real .env" {
  scaffold_generic
  printf 'TOKEN required # must be set to boot\n' >> "$TARGET/.env.schema"
  printf '# TOKEN=\n' >> "$TARGET/.env.example"
  printf 'APP_ENV=production\n' > "$TARGET/.env"
  run sh "$CHECK" --schema "$TARGET/.env.schema" --example "$TARGET/.env.example" --env "$TARGET/.env"
  [ "$status" -eq 1 ]
  [[ "$output" == *"TOKEN"* ]]
}

@test "check-env fails when a real .env value violates a pattern" {
  scaffold_generic
  printf 'PORT=not-a-number\n' > "$TARGET/.env"
  run sh "$CHECK" --schema "$TARGET/.env.schema" --example "$TARGET/.env.example" --env "$TARGET/.env"
  [ "$status" -eq 1 ]
  [[ "$output" == *"PORT"* ]]
}

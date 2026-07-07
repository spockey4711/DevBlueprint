#!/usr/bin/env bats
# detect (P3-7): inspect an existing repo's stack fingerprints and recommend the
# variant to scaffold from. Read-only - it never writes, just prints the matching
# variant and the exact `init` line to run. Two fingerprints map to two variants
# each (package.json -> web-nextjs/node-express, pyproject.toml ->
# data-python/backend-python), resolved by a dependency probe.

load helper

@test "detect recommends generic when nothing is recognized" {
  mkdir -p "$TARGET"

  run db detect --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No stack fingerprints found"* ]]
  [[ "$output" == *"Recommended variant: generic"* ]]
  [[ "$output" == *"--variant generic"* ]]
}

@test "detect maps go.mod to backend-go" {
  mkdir -p "$TARGET"; echo "module demo" > "$TARGET/go.mod"

  run db detect --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"go.mod -> backend-go"* ]]
  [[ "$output" == *"Recommended variant: backend-go"* ]]
}

@test "detect maps Cargo.toml to rust" {
  mkdir -p "$TARGET"; echo "[package]" > "$TARGET/Cargo.toml"

  run db detect --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Recommended variant: rust"* ]]
}

@test "detect maps Package.swift to ios-swift" {
  mkdir -p "$TARGET"; echo "// swift" > "$TARGET/Package.swift"

  run db detect --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Recommended variant: ios-swift"* ]]
}

@test "detect maps a plain package.json to node-express" {
  mkdir -p "$TARGET"; echo '{"dependencies":{"express":"^4"}}' > "$TARGET/package.json"

  run db detect --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Recommended variant: node-express"* ]]
}

@test "detect maps a package.json with a next dependency to web-nextjs" {
  mkdir -p "$TARGET"; echo '{"dependencies":{"next":"14.0.0","react":"^18"}}' > "$TARGET/package.json"

  run db detect --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"package.json (next dependency) -> web-nextjs"* ]]
  [[ "$output" == *"Recommended variant: web-nextjs"* ]]
}

@test "detect maps a plain pyproject.toml to backend-python" {
  mkdir -p "$TARGET"; printf '[project]\ndependencies = ["fastapi"]\n' > "$TARGET/pyproject.toml"

  run db detect --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Recommended variant: backend-python"* ]]
}

@test "detect maps a data-science pyproject.toml to data-python" {
  mkdir -p "$TARGET"; printf '[project]\ndependencies = ["pandas", "numpy"]\n' > "$TARGET/pyproject.toml"

  run db detect --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pyproject.toml (data-science dependencies) -> data-python"* ]]
  [[ "$output" == *"Recommended variant: data-python"* ]]
}

@test "detect reports every match and recommends the first in a polyglot repo" {
  mkdir -p "$TARGET"
  echo "module demo" > "$TARGET/go.mod"
  echo '{"dependencies":{"express":"^4"}}' > "$TARGET/package.json"

  run db detect --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"go.mod -> backend-go"* ]]
  [[ "$output" == *"package.json -> node-express"* ]]
  [[ "$output" == *"Multiple stacks detected"* ]]
}

@test "detect prints the exact init command for the recommended variant" {
  mkdir -p "$TARGET"; echo "module demo" > "$TARGET/go.mod"

  run db detect --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"devblueprint init --target $TARGET --variant backend-go"* ]]
}

@test "detect is read-only - it writes nothing into the target" {
  mkdir -p "$TARGET"; echo "module demo" > "$TARGET/go.mod"

  run db detect --target "$TARGET"
  [ "$status" -eq 0 ]
  # Only the file we created is present; detect added nothing.
  [ "$(find "$TARGET" -type f | wc -l | tr -d ' ')" -eq 1 ]
}

@test "detect requires --target" {
  run db detect
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing --target"* ]]
}

@test "detect fails on a nonexistent target" {
  run db detect --target "$TARGET/nope"
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "detect rejects unknown options" {
  mkdir -p "$TARGET"
  run db detect --target "$TARGET" --bogus
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown option"* ]]
}

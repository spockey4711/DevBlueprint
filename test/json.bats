#!/usr/bin/env bats
# Machine-readable output (P3-5): `list`, `doctor` and `version` grow a --json
# flag so an agent can parse available variants and post-setup health instead of
# scraping the human tables. The human output is unchanged; --json is additive.

load helper

# require_python : skip the current test unless a JSON parser is available. Only
# the "is valid JSON" assertions need it; the substring checks do not, so the
# suite still runs (minus strict validation) on a box without python3.
require_python() {
  command -v python3 >/dev/null 2>&1 || skip "python3 not available to validate JSON"
}

# --- version ---------------------------------------------------------------

@test "version --json emits a version object" {
  run db version --json
  [ "$status" -eq 0 ]
  [[ "$output" == '{"version":"'*'"}' ]]
}

@test "version without --json stays human" {
  run db version
  [ "$status" -eq 0 ]
  [[ "$output" == "devblueprint "* ]]
}

# --- list ------------------------------------------------------------------

@test "list --json is valid JSON listing every variant" {
  require_python
  run db list --json
  [ "$status" -eq 0 ]
  # Parseable, and lists the same variants as the variants/ tree.
  count="$(printf '%s' "$output" | python3 -c 'import sys,json; print(len(json.load(sys.stdin)["variants"]))')"
  on_disk="$(find "$REPO_ROOT"/variants -maxdepth 2 -name manifest.env | wc -l | tr -d ' ')"
  [ "$count" -eq "$on_disk" ]
}

@test "list --json includes a variant name, title and quality gate" {
  run db list --json
  [ "$status" -eq 0 ]
  [[ "$output" == *'"name":"generic"'* ]]
  [[ "$output" == *'"title":"Generic (language-agnostic)"'* ]]
  [[ "$output" == *'"gate":"make check"'* ]]
}

@test "list --json escapes quotes inside a quality gate" {
  # backend-go's gate is `test -z "$(gofumpt -l .)" && ...` - the embedded double
  # quotes must be backslash-escaped so the JSON stays well-formed.
  run db list --json
  [ "$status" -eq 0 ]
  [[ "$output" == *'test -z \"$(gofumpt -l .)\"'* ]]
}

@test "list without --json stays human" {
  run db list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Available variants:"* ]]
}

# --- doctor ----------------------------------------------------------------

@test "doctor --json reports ok:true and every check on a healthy scaffold" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db doctor --target "$TARGET" --json
  [ "$status" -eq 0 ]
  [[ "$output" == *'"ok":true'* ]]
  [[ "$output" == *'"failures":0'* ]]
  [[ "$output" == *'{"name":"CLAUDE.md","status":"ok"'* ]]
  [[ "$output" == *'"kitVersion":"'* ]]
}

@test "doctor --json is valid JSON" {
  require_python
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db doctor --target "$TARGET" --json
  [ "$status" -eq 0 ]
  printf '%s' "$output" | python3 -c 'import sys,json; d=json.load(sys.stdin); assert d["ok"] is True; assert isinstance(d["checks"], list)'
}

@test "doctor --json reports ok:false and exits non-zero when a file is missing" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  rm "$TARGET/CLAUDE.md"

  run db doctor --target "$TARGET" --json
  [ "$status" -ne 0 ]
  [[ "$output" == *'"ok":false'* ]]
  [[ "$output" == *'{"name":"CLAUDE.md","status":"miss"'* ]]
}

@test "doctor --json --run-gate records the quality-gate result" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db doctor --target "$TARGET" --json --run-gate
  [ "$status" -eq 0 ]
  [[ "$output" == *'{"name":"quality-gate-command","status":"gate","message":"running: make check"}'* ]]
  [[ "$output" == *'{"name":"quality-gate","status":"ok"'* ]]
}

@test "doctor --json --strict flags a bare scaffold as not a git repo" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db doctor --target "$TARGET" --json --strict
  [ "$status" -ne 0 ]
  [[ "$output" == *'"ok":false'* ]]
  [[ "$output" == *'{"name":"git-repo","status":"fail"'* ]]
}

@test "doctor without --json stays human" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null

  run db doctor --target "$TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"all foundation files present"* ]]
  [[ "$output" != *'"ok":'* ]]
}

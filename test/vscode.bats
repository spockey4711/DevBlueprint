#!/usr/bin/env bats
# P10-4: every variant ships a .vscode/tasks.json wiring its quality gate (and the
# common gate steps) to VS Code's task menu, so a beginner runs the gate from the
# editor without memorising commands. init copies it verbatim via the extras/ tree.

load helper

# require_python : skip the JSON-validation assertions when python3 is missing;
# the plain existence checks still run.
require_python() {
  command -v python3 >/dev/null 2>&1 || skip "python3 not available to validate JSON"
}

@test "every variant ships extras/.vscode/tasks.json" {
  for m in "$REPO_ROOT"/variants/*/manifest.env; do
    v="$(basename "$(dirname "$m")")"
    [ -f "$REPO_ROOT/variants/$v/extras/.vscode/tasks.json" ] \
      || { echo "missing tasks.json for variant: $v"; false; }
  done
}

@test "each tasks.json is valid JSON with a single default build gate" {
  require_python
  for m in "$REPO_ROOT"/variants/*/manifest.env; do
    v="$(basename "$(dirname "$m")")"
    run python3 - "$REPO_ROOT/variants/$v/extras/.vscode/tasks.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
assert d["version"] == "2.0.0", "version"
builds = [t for t in d["tasks"]
          if t.get("group", {}).get("kind") == "build" and t["group"].get("isDefault")]
assert len(builds) == 1, f"expected 1 default build task, got {len(builds)}"
assert builds[0]["command"], "gate command is empty"
PY
    [ "$status" -eq 0 ] || { echo "invalid tasks.json for $v: $output"; false; }
  done
}

@test "init lands .vscode/tasks.json in the scaffolded project" {
  run db init --target "$TARGET" --name demo --variant generic
  [ "$status" -eq 0 ]
  [ -f "$TARGET/.vscode/tasks.json" ]
}

@test "the generic gate task runs make check" {
  db init --target "$TARGET" --name demo --variant generic >/dev/null
  run grep -q '"make check"' "$TARGET/.vscode/tasks.json"
  [ "$status" -eq 0 ]
}

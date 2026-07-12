#!/usr/bin/env bats
# Per-variant VS Code integration: every variant ships a .vscode/ tree via its
# extras/, so opening the scaffolded project in VS Code works out of the box.
#
# - extensions.json (P10-3): recommends the right tooling in one click.
# - tasks.json (P10-4): wires the quality gate (and its common steps) into the
#   task menu, so a beginner runs the gate from the editor without memorising
#   commands.
# - .devcontainer/devcontainer.json (P11-2): opens the scaffolded project in a
#   ready Codespaces / Dev Container environment with zero local install. Every
#   variant ships one except ios-swift, which needs macOS + Xcode.
#
# These files ride the generic extras/ copy path (see extras.bats for the
# mechanism); this suite guards that every real variant carries them and that
# they are valid, so a new variant cannot silently ship without them.

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

@test "every variant ships a valid, non-empty .vscode/extensions.json" {
  require_python
  for variant in "$REPO_ROOT"/variants/*/; do
    [ -f "$variant/manifest.env" ] || continue
    name="$(basename "$variant")"
    file="$variant/extras/.vscode/extensions.json"

    [ -f "$file" ] || { echo "no extensions.json for $name"; false; }
    python3 - "$file" <<'PY' || { echo "invalid extensions.json for $name"; false; }
import json, sys
data = json.load(open(sys.argv[1]))
recs = data["recommendations"]
assert isinstance(recs, list) and recs, "recommendations must be a non-empty list"
assert all(isinstance(r, str) and r for r in recs), "each recommendation is a marketplace id"
PY
  done
}

@test "every Linux-capable variant ships extras/.devcontainer/devcontainer.json" {
  for m in "$REPO_ROOT"/variants/*/manifest.env; do
    v="$(basename "$(dirname "$m")")"
    [ "$v" = "ios-swift" ] && continue
    [ -f "$REPO_ROOT/variants/$v/extras/.devcontainer/devcontainer.json" ] \
      || { echo "missing devcontainer.json for variant: $v"; false; }
  done
}

@test "ios-swift ships no devcontainer (needs macOS + Xcode)" {
  [ ! -e "$REPO_ROOT/variants/ios-swift/extras/.devcontainer" ]
}

@test "each devcontainer.json is valid and matches its extensions.json" {
  require_python
  for m in "$REPO_ROOT"/variants/*/manifest.env; do
    v="$(basename "$(dirname "$m")")"
    [ "$v" = "ios-swift" ] && continue
    run python3 - "$REPO_ROOT/variants/$v" <<'PY'
import json, sys, os
vdir = sys.argv[1]
d = json.load(open(os.path.join(vdir, "extras/.devcontainer/devcontainer.json")))
assert d.get("name"), "name missing"
assert d.get("image"), "image missing"
assert d.get("postCreateCommand"), "postCreateCommand missing"
dc = d["customizations"]["vscode"]["extensions"]
rec = json.load(open(os.path.join(vdir, "extras/.vscode/extensions.json")))["recommendations"]
assert set(dc) == set(rec), f"extensions {dc} != recommendations {rec}"
PY
    [ "$status" -eq 0 ] || { echo "invalid devcontainer.json for $v: $output"; false; }
  done
}

@test "init lands .devcontainer/devcontainer.json in the scaffolded project" {
  run db init --target "$TARGET" --name demo --variant generic
  [ "$status" -eq 0 ]
  [ -f "$TARGET/.devcontainer/devcontainer.json" ]
}

@test "init scaffolds .vscode/extensions.json for every variant" {
  require_python
  for variant in "$REPO_ROOT"/variants/*/; do
    [ -f "$variant/manifest.env" ] || continue
    name="$(basename "$variant")"
    dest="$TEST_TMP/vscode-$name"

    run db init --target "$dest" --name "$name" --variant "$name"
    [ "$status" -eq 0 ] || { echo "init failed for $name: $output"; false; }

    [ -f "$dest/.vscode/extensions.json" ] \
      || { echo "no scaffolded .vscode/extensions.json for $name"; false; }
    run python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$dest/.vscode/extensions.json"
    [ "$status" -eq 0 ] || { echo "scaffolded extensions.json invalid for $name"; false; }
  done
}

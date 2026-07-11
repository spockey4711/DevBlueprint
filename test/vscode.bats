#!/usr/bin/env bats
# Per-variant VS Code recommendations (P10-3): every variant ships a
# .vscode/extensions.json via its extras/ tree, so opening the scaffolded project
# in VS Code offers the right tooling in one click. The file rides the generic
# extras/ copy path (see extras.bats for the mechanism); this suite guards that
# every real variant actually carries one and that it is a valid, non-empty
# recommendations list, so a new variant cannot silently ship without it.

load helper

# require_python : skip a test that needs a JSON parser. Only the "is valid JSON"
# assertions need it; the existence checks do not, so the suite still runs (minus
# strict validation) on a box without python3.
require_python() {
  command -v python3 >/dev/null 2>&1 || skip "python3 not available to validate JSON"
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

#!/usr/bin/env bats
# doctor --env (P11-1): a host prerequisite check with no --target - the first
# command a beginner runs. It verifies git / Node / a working shell are present
# and prints a per-OS copy-paste install command for whatever is missing.

load helper

# make_stub_path <tool-to-omit> : build a bindir of symlinks to the real tools the
# doctor --env path needs (its interpreter plus the ones it probes), minus
# <tool-to-omit>, and echo the dir. Running the CLI with PATH set to only this dir
# lets a test simulate a host where one prerequisite is absent, deterministically,
# without touching the developer's real PATH.
make_stub_path() {
  local omit="$1" bindir="$TEST_TMP/stubbin" t real
  mkdir -p "$bindir"
  for t in env bash sh dirname uname git node; do
    [ "$t" = "$omit" ] && continue
    real="$(command -v "$t" 2>/dev/null)" || continue
    ln -sf "$real" "$bindir/$t"
  done
  printf '%s' "$bindir"
}

@test "doctor --env passes when git, Node and a shell are present" {
  command -v git >/dev/null 2>&1 || skip "git not installed"
  command -v node >/dev/null 2>&1 || skip "node not installed"

  run db doctor --env
  [ "$status" -eq 0 ]
  [[ "$output" == *"git found"* ]]
  [[ "$output" == *"Node found"* ]]
  [[ "$output" == *"shell found"* ]]
  [[ "$output" == *"all prerequisites present"* ]]
}

@test "doctor --env needs no --target" {
  command -v git >/dev/null 2>&1 || skip "git not installed"
  command -v node >/dev/null 2>&1 || skip "node not installed"

  run db doctor --env
  [ "$status" -eq 0 ]
  [[ "$output" != *"missing --target"* ]]
}

@test "doctor --env reports Node missing with a copy-paste fix and exits non-zero" {
  local bindir; bindir="$(make_stub_path node)"

  run env PATH="$bindir" "$DEVBLUEPRINT" doctor --env
  [ "$status" -ne 0 ]
  [[ "$output" == *"Node not found"* ]]
  [[ "$output" == *"install with:"* ]]
  [[ "$output" == *"prerequisite(s) missing"* ]]
}

@test "doctor --env reports git missing with a copy-paste fix" {
  local bindir; bindir="$(make_stub_path git)"

  run env PATH="$bindir" "$DEVBLUEPRINT" doctor --env
  [ "$status" -ne 0 ]
  [[ "$output" == *"git not found"* ]]
  [[ "$output" == *"install with:"* ]]
}

@test "doctor --env --json emits a machine-readable report with the detected OS" {
  command -v git >/dev/null 2>&1 || skip "git not installed"
  command -v node >/dev/null 2>&1 || skip "node not installed"

  run db doctor --env --json
  [ "$status" -eq 0 ]
  [[ "$output" == *'"ok":true'* ]]
  [[ "$output" == *'"os":'* ]]
  [[ "$output" == *'{"name":"git","status":"ok"'* ]]
}

@test "doctor --env --json marks a missing tool and carries its fix" {
  local bindir; bindir="$(make_stub_path node)"

  run env PATH="$bindir" "$DEVBLUEPRINT" doctor --env --json
  [ "$status" -ne 0 ]
  [[ "$output" == *'"ok":false'* ]]
  [[ "$output" == *'"name":"node","status":"miss"'* ]]
  [[ "$output" == *'"fix":'* ]]
}

@test "doctor --env counts every missing prerequisite, not just the first" {
  # A host missing both git and Node: the summary must pluralise the count and
  # print a fix for each, so a beginner installs everything in one pass.
  local bindir="$TEST_TMP/stubbin" t real
  mkdir -p "$bindir"
  for t in env bash sh dirname uname; do
    real="$(command -v "$t" 2>/dev/null)" || continue
    ln -sf "$real" "$bindir/$t"
  done

  run env PATH="$bindir" "$DEVBLUEPRINT" doctor --env
  [ "$status" -ne 0 ]
  [[ "$output" == *"git not found"* ]]
  [[ "$output" == *"Node not found"* ]]
  [[ "$output" == *"2 prerequisite(s) missing"* ]]
}

@test "doctor --env --json failures count matches the number missing" {
  local bindir="$TEST_TMP/stubbin" t real
  mkdir -p "$bindir"
  for t in env bash sh dirname uname; do
    real="$(command -v "$t" 2>/dev/null)" || continue
    ln -sf "$real" "$bindir/$t"
  done

  run env PATH="$bindir" "$DEVBLUEPRINT" doctor --env --json
  [ "$status" -ne 0 ]
  [[ "$output" == *'"failures":2'* ]]
  [[ "$output" == *'"name":"git","status":"miss"'* ]]
  [[ "$output" == *'"name":"node","status":"miss"'* ]]
}

@test "doctor --env rejects unknown options" {
  run db doctor --env --bogus
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown option: --bogus"* ]]
}

@test "doctor --env appears in help" {
  run db help
  [ "$status" -eq 0 ]
  [[ "$output" == *"doctor --env"* ]]
}

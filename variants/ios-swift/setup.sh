#!/usr/bin/env bash
# setup.sh - wire the Swift/Xcode toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + install swiftformat/swiftlint (brew)
#   ./setup.sh --no-install # wire config only
#
# It does NOT create the Xcode project / Package.swift - do that first.
set -euo pipefail

DO_INSTALL=1
[ "${1:-}" = "--no-install" ] && DO_INSTALL=0

say() { printf '  %s\n' "$*"; }
write_if_absent() {
  if [ -e "$1" ]; then say "skip $1 (exists)"; return 0; fi
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  say "wrote $1"
}

echo "Wiring the Swift toolchain..."

# --- SwiftLint ---------------------------------------------------------------
write_if_absent .swiftlint.yml <<'EOF'
# https://realm.github.io/SwiftLint/rule-directory.html
included:
  - Sources
  - Tests
opt_in_rules:
  - empty_count
  - force_unwrapping
  - implicitly_unwrapped_optional
line_length:
  warning: 120
  error: 160
EOF

# --- SwiftFormat -------------------------------------------------------------
write_if_absent .swiftformat <<'EOF'
--swiftversion 5.10
--indent 4
--maxwidth 120
--self remove
--importgrouping testable-bottom
EOF

# --- pre-commit hook (committable, via core.hooksPath) -----------------------
write_if_absent .githooks/pre-commit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
command -v swiftformat >/dev/null 2>&1 && swiftformat --lint . || true
command -v swiftlint  >/dev/null 2>&1 && swiftlint --strict --quiet
EOF
chmod +x .githooks/pre-commit 2>/dev/null || true
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config core.hooksPath .githooks && say "set core.hooksPath = .githooks"
else
  say "not a git repo yet - after 'git init' run: git config core.hooksPath .githooks"
fi

# --- install the formatters --------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && command -v brew >/dev/null 2>&1; then
  echo "Installing swiftformat + swiftlint (brew)..."
  brew install swiftformat swiftlint || say "brew install failed - run it manually"
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && echo "Still to run yourself:  brew install swiftformat swiftlint"
echo "Also: create the Xcode project / Package.swift, then set the CI build/test"
echo "steps to xcodebuild if this is an app target (not a pure SPM package)."
echo "Verify the gate: swiftformat --lint . && swiftlint --strict && swift build && swift test"

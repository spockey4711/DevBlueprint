#!/usr/bin/env bash
# setup.sh - wire the language-agnostic toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh
#
# The quality gate is the Makefile - fill in its targets for your stack. This
# script installs a committable pre-commit hook that runs `make lint`.
set -euo pipefail

say() { printf '  %s\n' "$*"; }
write_if_absent() {
  if [ -e "$1" ]; then say "skip $1 (exists)"; return 0; fi
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  say "wrote $1"
}

echo "Wiring the generic toolchain..."

# --- pre-commit hook (committable, via core.hooksPath) -----------------------
write_if_absent .githooks/pre-commit <<'EOF'
#!/usr/bin/env bash
# Fast checks before commit. `make lint` should be quick; heavier gates run in CI.
set -euo pipefail
make lint
EOF
chmod +x .githooks/pre-commit 2>/dev/null || true
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config core.hooksPath .githooks && say "set core.hooksPath = .githooks"
else
  say "not a git repo yet - after 'git init' run: git config core.hooksPath .githooks"
fi

echo
echo "Toolchain wired."
echo "Still to do yourself:"
echo "  1. Fill the Makefile targets (lint / typecheck / test / build) for your stack."
echo "  2. Add your language's setup step to .github/workflows/ci.yml."
echo "  3. Set the wt_post_create hook in scripts/wt.conf if a setup step is needed."
echo "Then: git init && git switch -c develop"
echo "Verify the gate: make check"

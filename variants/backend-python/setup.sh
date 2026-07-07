#!/usr/bin/env bash
# setup.sh - wire the Python/uv toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + `uv sync` + install pre-commit hook
#   ./setup.sh --no-install # wire config only
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

PROJECT="$(basename "$PWD")"
PY_VERSION="3.12"

echo "Wiring the Python toolchain..."

# --- version pin -------------------------------------------------------------
[ -f .python-version ] || { printf '%s\n' "$PY_VERSION" > .python-version; say "wrote .python-version"; }

# --- pyproject.toml (deps + ruff + mypy + pytest config) ---------------------
write_if_absent pyproject.toml <<EOF
[project]
name = "$PROJECT"
version = "0.1.0"
requires-python = ">=$PY_VERSION"
dependencies = []

[dependency-groups]
dev = [
    "ruff>=0.6",
    "mypy>=1.11",
    "pytest>=8",
    "httpx>=0.27",
    "pre-commit>=3.8",
]

[tool.ruff]
line-length = 100
target-version = "py${PY_VERSION//./}"

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP", "SIM"]

[tool.mypy]
strict = true
python_version = "$PY_VERSION"

[tool.pytest.ini_options]
testpaths = ["tests"]
EOF

# --- pre-commit framework config ---------------------------------------------
write_if_absent .pre-commit-config.yaml <<'EOF'
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.9
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
EOF

# --- install deps + hook -----------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && command -v uv >/dev/null 2>&1; then
  echo "Syncing environment (uv sync)..."
  uv sync || say "uv sync failed - run it manually"
  uv run pre-commit install || say "pre-commit install skipped"
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && {
  echo "Still to run yourself:"
  echo "  uv sync"
  echo "  uv run pre-commit install"
}
echo "Then: git init && git switch -c develop"
echo "Verify the gate: ruff check . && ruff format --check . && mypy . && pytest"

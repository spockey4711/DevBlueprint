#!/usr/bin/env bash
# setup.sh - wire the Go backend toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + `go mod tidy` + install pre-commit hook
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
GO_VERSION="1.23"

echo "Wiring the Go backend toolchain..."

# --- go.mod ------------------------------------------------------------------
# Module path defaults to the project name; edit to your VCS host
# (e.g. github.com/you/$PROJECT) before publishing.
if [ ! -f go.mod ]; then
  go mod init "$PROJECT" >/dev/null 2>&1 || printf 'module %s\n\ngo %s\n' "$PROJECT" "$GO_VERSION" > go.mod
  say "wrote go.mod"
else
  say "skip go.mod (exists)"
fi

# --- golangci-lint config ----------------------------------------------------
# A pragmatic strict baseline: the default linters plus the high-signal
# analysers. gofumpt owns formatting so it doubles as the format check.
write_if_absent .golangci.yml <<'EOF'
run:
  timeout: 5m

linters:
  enable:
    - errcheck
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gofumpt
    - revive
    - bodyclose
    - errorlint
    - gosec
    - misspell
    - unconvert

linters-settings:
  gofumpt:
    extra-rules: true
  revive:
    rules:
      - name: exported
        disabled: false

issues:
  exclude-rules:
    # Test files may skip a few strictures that do not earn their keep in specs.
    - path: _test\.go
      linters: [gosec, errcheck]
EOF

# --- pre-commit framework config ---------------------------------------------
# gofumpt formats, golangci-lint gates, and `go test -race` runs before commit
# so the tree stays green.
write_if_absent .pre-commit-config.yaml <<'EOF'
repos:
  - repo: local
    hooks:
      - id: gofumpt
        name: gofumpt
        entry: gofumpt -w
        language: system
        types: [go]
      - id: golangci-lint
        name: golangci-lint
        entry: golangci-lint run
        language: system
        types: [go]
        pass_filenames: false
      - id: go-test
        name: go test -race
        entry: go test -race ./...
        language: system
        types: [go]
        pass_filenames: false
EOF

# --- a compiling entrypoint so the gate has something to chew on -------------
write_if_absent cmd/server/main.go <<'EOF'
// Command server is the service entrypoint. Wire routing, config and lifecycle
// here; keep business logic in internal/ packages so it stays testable.
package main

import (
	"fmt"
	"os"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "fatal:", err)
		os.Exit(1)
	}
}

func run() error {
	fmt.Println("service up")
	return nil
}
EOF

# --- install toolchain + hook ------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && command -v go >/dev/null 2>&1; then
  echo "Tidying modules (go mod tidy)..."
  go mod tidy || say "go mod tidy failed - run it manually"
  command -v pre-commit >/dev/null 2>&1 && { pre-commit install || say "pre-commit install skipped"; }
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && {
  echo "Still to run yourself:"
  echo "  go mod tidy"
  echo "  # install the tools if missing:"
  echo "  go install mvdan.cc/gofumpt@latest"
  echo "  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
  echo "  pre-commit install   # optional"
}
echo "Then: git init && git switch -c develop"
echo "Verify the gate: test -z \"\$(gofumpt -l .)\" && go vet ./... && golangci-lint run && go build ./... && go test -race ./..."

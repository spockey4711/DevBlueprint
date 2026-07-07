# Variant: Backend service (Go)

A typed, race-checked Go backend stack: a `cmd/` + `internal/`/`pkg/` layout, gofumpt
(formatting), golangci-lint (staticcheck, errcheck, gosec, ...), go vet, `go test -race`, Go
modules for dependencies, GitHub Actions CI.

## Quality gate

```bash
test -z "$(gofumpt -l .)" && go vet ./... && golangci-lint run && go build ./... && go test -race ./...
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant backend-go` adds

- `docs/engineering/` - git-workflow, conventions (+ Go overlay), quality-and-testing,
  engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `go mod download`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/ci.yml` (gofumpt + go vet + golangci-lint + build + race tests).
- `.github/dependabot.yml` (gomod + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for Go binaries, coverage and build artifacts.
- `cmd/`, `internal/`, `pkg/` scaffold.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. Run it once:

```bash
./setup.sh              # writes go.mod, .golangci.yml, .pre-commit-config.yaml,
                        # a compiling cmd/server/main.go, then `go mod tidy` +
                        # installs the pre-commit hook
./setup.sh --no-install # config only
```

Idempotent; never clobbers existing files. Edit the module path in `go.mod` to your VCS host
(e.g. `github.com/you/project`) before publishing.

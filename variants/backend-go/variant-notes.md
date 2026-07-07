## Stack notes (Go backend)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `go mod download`).
- Layout: `cmd/<binary>/main.go` are thin entrypoints; all logic lives in `internal/` (private
  to the module) and reusable libraries in `pkg/`. Wire dependencies in `main`, not in globals.
- Errors are values: wrap with `fmt.Errorf("...: %w", err)` to preserve the chain, inspect with
  `errors.Is`/`errors.As`, and never ignore a returned `error` (errcheck enforces this).
- Formatting is `gofumpt` (a stricter `gofmt`); it owns layout, so do not hand-format.
  `golangci-lint` bundles the vet/staticcheck/security analysers - zero warnings in CI.
- Tests run with `-race`; write table-driven tests next to the code (`foo_test.go`). Keep the
  `context.Context` first in signatures and honour cancellation on every blocking call.
- Read config from the environment (12-factor); no secrets in code, logs or committed files.

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
- Ops artifacts ship as fillable skeletons: a multi-stage `Dockerfile` (static `CGO_ENABLED=0`
  binary -> distroless non-root) + `.dockerignore` + `docker-compose.yml` for containers, and
  `deploy/` for a hosted target (`fly.toml`, `render.yaml`, `terraform/`). Keep the one target you
  deploy to and delete the rest.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`), and `make check` (plus CI) runs `scripts/check-env.sh` to keep `.env.example`
  in lockstep with it and enforce required keys in any real `.env`. Declare new variables in both the
  schema and `.env.example`, or the gate fails.

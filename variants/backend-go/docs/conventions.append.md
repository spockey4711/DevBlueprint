
---

## Stack-specific conventions (Go)

### Language & tooling

- **`gofumpt` owns formatting** (a stricter superset of `gofmt`) - do not hand-format. It runs as
  a golangci-lint linter and as a standalone check in the gate, so CI fails on any unformatted file.
- **`golangci-lint` is the lint gate**: govet, staticcheck, errcheck, ineffassign, revive, gosec
  and friends. Zero warnings in CI. Disable a check inline only with a `//nolint:<linter> // reason`
  that says why, never a blanket disable.
- Target a single supported Go version; pin it in `go.mod`, the CI workflow and `.tool-versions`.
  Prefer the standard library and a small, deliberate dependency set.

### Package layout

- `cmd/<binary>/main.go` are thin entrypoints - parse flags/config, construct dependencies, call
  into packages. No business logic in `main`.
- `internal/` holds application code that must not be imported outside this module; `pkg/` holds
  packages intended for reuse. Depend inward: `cmd` -> `internal`/`pkg`, never the reverse.
- Keep packages cohesive and named for what they provide (`store`, `httpapi`), not `utils`/`common`.
  Exported identifiers carry doc comments starting with the identifier name.

### Errors & concurrency

- **Errors are values.** Return them; do not panic across package boundaries. Wrap with
  `fmt.Errorf("doing X: %w", err)` to keep the chain and match with `errors.Is`/`errors.As`.
  Never discard a returned `error` (errcheck enforces this).
- Pass `context.Context` as the first parameter of any call that does I/O or can block, and honour
  cancellation and deadlines. Do not store a `Context` in a struct.
- Guard shared state; run the suite with `-race`. A goroutine you start is a goroutine you must
  be able to stop - own its lifecycle.

### Naming & structure

- Identifiers are `MixedCaps`/`mixedCaps` (no underscores); acronyms keep their case (`ID`, `URL`,
  `HTTP`). Short receiver names, short-lived local names, descriptive exported names.
- Table-driven tests in `foo_test.go` beside the code; use `t.Run` subtests and `t.Parallel()`
  where safe. Read config, credentials and endpoints from the environment - no secrets in code
  or logs (12-factor).

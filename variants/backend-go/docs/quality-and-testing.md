# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Go backend service. Concrete overlay
of the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
test -z "$(gofumpt -l .)"   # formatting is canonical - fails if any file is unformatted
go vet ./...                # the standard suspicious-construct checks
golangci-lint run           # staticcheck, errcheck, revive, gosec, ... - zero warnings
go build ./...              # the whole module compiles
go test -race ./...         # unit + integration tests under the race detector
```

## Testing strategy

Test what has logic or can silently break; do not chase coverage on trivial glue.

- **Unit (`go test`):** business logic in `internal/`/`pkg/` - handlers, services, parsing,
  validation. Prefer table-driven tests with `t.Run` subtests; keep them deterministic.
- **Race detector:** the suite always runs with `-race`. Concurrency bugs must fail in CI, not
  in production.
- **Integration:** exercise real boundaries (HTTP handlers via `httptest`, a store against a
  throwaway container or in-memory fake). Gate slow ones behind `testing.Short()` if needed.
- **Fuzz** the parsers and decoders that touch untrusted input (`go test -fuzz`) where it pays off.

Target meaningful coverage of the logic packages and the request/response contracts, not a global
percentage. `make test` writes `coverage.out`; inspect with `go tool cover -html=coverage.out`.

## Tooling

- **gofumpt** - stricter `gofmt`; owns formatting. The gate fails on any unformatted file.
- **go vet** - the standard vet analysers, run on every build.
- **golangci-lint** - the aggregate linter (staticcheck, errcheck, ineffassign, revive, gosec,
  bodyclose, errorlint, ...). Config in `.golangci.yml`. No `//nolint` without a reason.
- **go test -race** - unit + integration tests under the race detector; `-coverprofile` for coverage.
- **pre-commit** - the `pre-commit` framework runs gofumpt, golangci-lint and the tests on commit.
- **Go modules** - `go mod tidy` keeps `go.mod`/`go.sum` honest; CI builds with the committed sums.
- **CI** - `.github/workflows/ci.yml` runs the full gate on every PR into `develop`/`master`.

## Definition of done

1. It works, the behaviour is covered by tests, and the race detector is clean.
2. gofumpt, go vet, golangci-lint, build and `go test -race` are all green.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.

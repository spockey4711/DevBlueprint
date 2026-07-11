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

## Security and commit gates

Every PR also runs the security-gate baseline in `.github/workflows/` (shared
across variants), complementing the quality gate above:

- **`security.yml`** - gitleaks secret scanning, semgrep SAST, and (on PRs)
  `dependency-review` against the GitHub Advisory Database.
- **`codeql.yml`** - GitHub CodeQL semantic analysis; findings surface under
  Security > Code scanning.
- **`commit-checks.yml`** - commitlint on every commit plus a Conventional-Commits
  check on the PR title (the squash-merge subject).
- **`coverage.yml`** - reports line coverage and enforces a soft floor read from
  the `COVERAGE_MIN` repository variable (default `0`, i.e. report-only), so the
  threshold is opt-in and never reddens a fresh scaffold.

## Release automation

On every push to `master`, `release.yml` runs
[release-please](https://github.com/googleapis/release-please), turning the
Conventional-Commits history into releases and closing the loop on the changelog
discipline above:

- It maintains a standing **release PR** whose diff is the next SemVer bump plus
  the generated `CHANGELOG.md` entries (`feat` -> minor, `fix`/`perf` -> patch,
  `BREAKING CHANGE` -> major). Merging that PR tags the release and publishes a
  GitHub Release.
- `release-please-config.json` pins the release strategy to `go`, so it also bumps
  the module's version tag in the release PR.
- This automates the manual "move `[Unreleased]`, tag, publish" steps in the git
  workflow: let the merged commits drive `CHANGELOG.md` instead of hand-editing it.

## Provider-agnostic CI (GitLab)

The kit is not GitHub-only. Each project also ships a `.gitlab-ci.yml` that mirrors
the same gates, so it can live on either forge:

- **`quality`** stage - runs the quality gate above.
- **`security`** stage - GitLab's managed SAST, secret detection and dependency
  scanning, the GitLab-native counterpart to the GitHub security gate.
- **`deploy`** stage - the `deploy:preview` job (below).

`workflow:` rules run the pipeline on merge requests and the protected branches
without spawning duplicate pipelines. Delete `.gitlab-ci.yml` if the project is
hosted on GitHub only.

## Preview deploy

A provider-neutral preview environment ships for both forges - `preview-deploy.yml`
on GitHub and the `deploy:preview` job on GitLab. On every PR/MR it stands up an
ephemeral environment and comments its URL, then tears it down when the PR/MR
closes. The plumbing is wired; only the deploy step is a TODO, so point it at your
host (Vercel, Netlify, GitHub/GitLab Pages, Fly, ...).

## Definition of done

1. It works, the behaviour is covered by tests, and the race detector is clean.
2. gofumpt, go vet, golangci-lint, build and `go test -race` are all green.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.

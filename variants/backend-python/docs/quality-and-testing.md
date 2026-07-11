# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Python service. Concrete overlay of
the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing; CI runs the identical set on every PR:

```bash
ruff check .              # lint - zero warnings
ruff format --check .     # formatting is canonical
mypy .                    # static types - zero errors
pytest                    # unit + integration tests
```

For a deployable service, add a container build (`docker build .`) as the "build" gate in CI.

## Testing strategy

Test what has logic or can silently break; do not chase coverage on framework glue.

- **Unit (pytest):** pure functions, data transforms, validation/serialization (Pydantic
  schemas), service-layer logic with the persistence layer faked.
- **Integration (pytest + httpx/TestClient):** the important request/response paths, auth
  guards, error mapping (a handler returns a typed error, not a 500 stack trace).
- Use fixtures and factories over shared mutable state. Keep the DB layer behind a repository
  so unit tests do not need a real database.

Target: meaningful coverage of the service and domain layers, not a global percentage.

## Tooling

- **Ruff** - lint + formatter in one. Config in `pyproject.toml` under `[tool.ruff]`.
- **mypy** - strict mode (`[tool.mypy] strict = true`). No `# type: ignore` without a reason.
- **pytest** - specs in `tests/unit` and `tests/integration`.
- **pre-commit** - the `pre-commit` framework runs ruff on staged files before commit.
- **uv** - dependency and virtualenv management; `uv sync --frozen` in CI.
- **CI** - `.github/workflows/ci.yml` runs ruff, mypy and pytest on every PR into
  `develop`/`master`.

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

## Definition of done

1. It works and matches the API contract.
2. ruff, mypy and pytest are green; the container builds if applicable.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR and is deployable (or deployed).

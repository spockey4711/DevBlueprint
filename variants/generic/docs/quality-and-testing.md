# Quality and testing

**Purpose:** the quality bar for this project. Concrete overlay of the blueprint's
[shared quality shape](engineering-standards.md). Fill the `make` targets in the `Makefile`
with your stack's real commands.

## The quality gate (must be green to merge)

Run locally before pushing; CI runs the identical set on every PR:

```bash
make check   # chains: make lint && make typecheck && make test && make build
```

Wire each target in the `Makefile`. If a gate does not apply (e.g. no separate typecheck for a
dynamically typed language with no type checker), remove that target rather than leaving a stub.

## Testing strategy

Test what has logic or can silently break; do not chase coverage on trivial glue.

- **Unit tests** for pure logic: calculations, parsers, data transforms, adapter fallback
  behavior.
- **A few smoke tests** for the critical happy path.
- Write the smallest relevant test first, then broaden when shared behavior changes.

Target: meaningful coverage of the logic layer, not a global percentage.

## Security and commit gates

Every PR also runs the security-gate baseline in `.github/workflows/` (shared
across variants), complementing the quality gate above:

- **`security.yml`** - gitleaks secret scanning, semgrep SAST, and (on PRs)
  `dependency-review` against the GitHub Advisory Database.
- **`commit-checks.yml`** - commitlint on every commit plus a Conventional-Commits
  check on the PR title (the squash-merge subject).

## Definition of done

1. It works and matches the spec.
2. `make check` is green.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR and is deployable (or deployed).

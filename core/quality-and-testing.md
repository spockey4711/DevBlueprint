# Quality and testing

**Purpose:** the quality bar and how it is enforced - linting, types, tests and the definition
of done. The concrete commands are stack-specific and live in your variant's overlay; this is
the shared shape every project follows.

Related: [conventions](conventions.md) · [git workflow](git-workflow.md)

## The quality gate (must be green to merge)

Every variant defines the same four gates, wired to its own toolchain. Run them locally before
pushing; CI runs the identical set on every PR:

| Gate          | What it proves                                  |
| ------------- | ----------------------------------------------- |
| **lint**      | Style and correctness rules pass, zero warnings |
| **typecheck** | Static types hold, zero errors                  |
| **test**      | Unit tests pass                                 |
| **build**     | A production build/compile succeeds             |

The exact invocation (e.g. `pnpm lint && pnpm typecheck && pnpm test && pnpm build`, or
`ruff check && mypy && pytest && python -m build`, or `swift build && swift test`) is listed in
your project's `docs/engineering/quality-and-testing.md`, copied from the variant.

CI may add project-specific jobs on top (end-to-end smoke tests, performance/Lighthouse
budgets, accessibility checks). Keep those green too.

## Testing strategy

Test what has logic or can silently break; do not chase coverage on presentational markup.

- **Unit tests** cover pure logic: calculations, parsers, data transforms, adapter shape and
  fallback behavior, and any critical component/state behavior.
- **A few end-to-end smoke tests** cover the happy path and the most important flows - enough
  to catch a broken build, not a full regression suite.
- **No large snapshot tests** - they rot and prove little.

Target: meaningful coverage of the logic layer and critical paths, not a global percentage.

Write the smallest relevant test first, then broaden verification when shared behavior changes.
Tests are part of the change, not a follow-up PR.

## Definition of done

A task is done when:

1. It works and matches the spec.
2. lint, typecheck, test and build are green; any extra budgets (perf, a11y) hold.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR and is deployable (or deployed).

## Local automation

- **Pre-commit hook** runs the fast part of the gate (lint/format) before each commit, so a
  broken format never lands - the "run the gate before pushing" step is enforced, not just
  documented. `./setup.sh` wires it: Node uses husky + lint-staged, Python uses the pre-commit
  framework, and the other variants commit a `.githooks/pre-commit` and point `core.hooksPath`
  at it, so the hook is versioned and shared with everyone who clones. Heavier gates
  (typecheck, test, build) stay in CI. `devblueprint doctor` reports whether the hook is wired.
- **CI** runs the full gate on every PR into `develop` or `master` and on push to either. All
  jobs must be green to merge. The workflow ships with each variant.

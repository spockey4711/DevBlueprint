# Quality and testing

**Purpose:** the quality bar and how it is enforced for this data-science project. Concrete
overlay of the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
ruff check .              # lint - zero warnings
ruff format --check .     # formatting is canonical
nbqa ruff notebooks       # lint notebooks with the same rules
mypy src                  # static types on the library code - zero errors
pytest                    # unit + data tests
```

Notebooks must be committed with outputs stripped; CI fails if any tracked `.ipynb` still
carries output (`nbstripout --verify`). Install the pre-commit hook and it happens on commit.

## Testing strategy

Test what has logic or can silently break; do not chase coverage on exploratory notebook cells.

- **Unit (pytest):** feature-engineering and transform functions, metrics, data-validation
  helpers, anything moved out of a notebook into `src/`. Deterministic - seed any randomness.
- **Data tests:** assert the shape/schema/invariants of inputs and outputs (no nulls where they
  are forbidden, ranges, categorical domains, row counts) so a bad file fails loud, not silent.
- **Reproducibility:** a fixed seed and pinned deps must reproduce reported numbers. Keep raw
  data immutable; derive everything downstream so a run can be replayed from source.
- Keep notebooks thin: once a cell is worth testing, move it into `src/` and import it back.

Target: meaningful coverage of the `src/` library and the data contracts, not a global
percentage or notebook cells.

## Tooling

- **Ruff** - lint + formatter in one. Config in `pyproject.toml` under `[tool.ruff]`.
- **nbqa** - runs ruff (and other tools) over notebooks so they meet the same bar as `src/`.
- **nbstripout** - clears notebook outputs on commit; keeps diffs reviewable and data out of git.
- **mypy** - strict mode over `src` (`[tool.mypy] strict = true`). No `# type: ignore` without a
  reason.
- **pytest** - specs in `tests/`.
- **pre-commit** - the `pre-commit` framework runs ruff, nbqa and nbstripout on staged files.
- **uv** - dependency and virtualenv management; `uv sync --frozen` in CI.
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
- `release-please-config.json` pins the release strategy to `python`, so it also
  bumps the version in `pyproject.toml`/`setup.py` in the release PR.
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

1. It works, the numbers are reproducible from raw data, and the analysis question is answered.
2. ruff, nbqa, mypy and pytest are green; notebooks are output-stripped.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.

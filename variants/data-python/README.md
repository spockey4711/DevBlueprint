# Variant: Data science (Python + uv)

A typed, reproducible data-science stack: a `src/` library + `notebooks/` split, ruff (lint +
format), nbqa + nbstripout for notebooks, mypy (strict) over the library code, pytest, uv for
dependencies, GitHub Actions CI.

## Quality gate

```bash
ruff check . && ruff format --check . && nbqa ruff notebooks && mypy src && pytest
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant data-python` adds

- `docs/engineering/` - git-workflow, conventions (+ Python/data-science overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `uv sync`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/ci.yml` (ruff + nbqa + nbstripout + mypy + pytest).
- `.github/dependabot.yml` (pip + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for Python + data/notebook artifacts.
- `src/`, `notebooks/`, `tests/` and a `data/{raw,processed,external}` scaffold.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. Run it once:

```bash
./setup.sh              # writes pyproject.toml (ruff + mypy strict + pytest + nbqa),
                        # .python-version, .pre-commit-config.yaml (ruff, nbqa, nbstripout),
                        # then `uv sync` + installs the pre-commit hook
./setup.sh --no-install # config only
```

Idempotent; never clobbers existing files.

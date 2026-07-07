# Variant: Backend / API (Python + uv)

A typed Python service stack: FastAPI-style layering, ruff (lint + format), mypy (strict),
pytest, uv for dependencies, GitHub Actions CI.

## Quality gate

```bash
ruff check . && ruff format --check . && mypy . && pytest
```

## What `devblueprint init --variant backend-python` adds

- `docs/engineering/` - git-workflow, conventions (+ Python/FastAPI overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `uv sync`).
- `.github/workflows/ci.yml` (ruff + mypy + pytest).
- `.gitignore` for Python.
- `app/` and `tests/` skeleton.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. Run it once:

```bash
./setup.sh              # writes pyproject.toml (ruff + mypy strict + pytest), .python-version,
                        # .pre-commit-config.yaml, then `uv sync` + installs the pre-commit hook
./setup.sh --no-install # config only
```

Idempotent; never clobbers existing files.

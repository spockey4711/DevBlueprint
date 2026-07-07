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

1. Create `pyproject.toml` with `[tool.ruff]`, `[tool.mypy] strict = true`, and a `[dev]`
   dependency group (ruff, mypy, pytest, httpx).
2. Add `.python-version` (uv reads it).
3. Set up the `pre-commit` framework to run ruff on staged files.
4. `uv sync` to create the environment.

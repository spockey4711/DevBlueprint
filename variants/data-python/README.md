# Variant: Data science (Python + uv)

A typed, reproducible data-science stack: a `src/` library + `notebooks/` split, ruff (lint +
format), nbqa + nbstripout for notebooks, mypy (strict) over the library code, pytest, uv for
dependencies, GitHub Actions CI.

## Quality gate

```bash
sh scripts/check-env.sh && ruff check . && ruff format --check . && nbqa ruff notebooks && mypy src && pytest
```

Or, with the shipped Makefile: `make check` (its first step, `validate-env`, runs
`scripts/check-env.sh`).

## What `devblueprint init --variant data-python` adds

- `docs/engineering/` - git-workflow, conventions (+ Python/data-science overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `uv sync`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/ci.yml` (env-schema contract + ruff + nbqa + nbstripout + mypy + pytest).
- `.github/dependabot.yml` (pip + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for Python + data/notebook artifacts.
- `docs/ops/deployment.md` (runbook for scheduled/containerised jobs: scheduler/Batch/Docker +
  source/warehouse and env checklists) and `.env.example` (committed template; real `.env*` stay
  ignored).
- Ops artifacts (adapted for a batch/pipeline project, not a web service): a `python:3.12-slim`,
  non-root `Dockerfile` whose ENTRYPOINT runs the pipeline and exits (no exposed port) +
  `.dockerignore` + `docker-compose.yml` (a run-once job), and `deploy/` for provisioning the job
  runner - no `fly.toml`/`render.yaml` since there is no long-running web service; instead
  `deploy/README.md` points at a scheduler/registry/managed Batch service and `deploy/terraform/`
  provisions the compute + storage. Plus `.env.schema` + `scripts/check-env.sh` (the env contract
  `make check` and CI enforce). All skeletons - fill the `<...>` placeholders.
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

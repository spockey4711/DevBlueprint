## Stack notes (Python / data science)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `uv sync`). An extra `exp/`
  branch type is allowed for throwaway experiments.
- Layered: `notebooks/` explore and communicate; anything reused moves into importable
  functions under `src/`. Notebooks import from `src`, never the other way round.
- Notebooks are committed with **outputs stripped** (nbstripout pre-commit hook) so diffs stay
  readable and data never leaks into git. Lint them with `nbqa ruff`.
- `data/` is tracked as an empty scaffold only; raw/processed/external contents are gitignored -
  keep them in DVC or object storage, referenced by path/hash, and treat inputs as immutable.
- mypy `strict` runs over `src` (typed library code); ruff owns lint + format. Set seeds for
  reproducibility and read paths/params from config, never hard-code secrets.
- Ops artifacts ship as fillable skeletons, adapted for a batch/pipeline project (not a web
  service): a `python:3.12-slim` non-root `Dockerfile` whose ENTRYPOINT runs the pipeline to
  completion and exits - no exposed port - plus `.dockerignore` and a run-once `docker-compose.yml`.
  Deployment is scheduled, not always-on: there is no `fly.toml`/`render.yaml`; `deploy/README.md`
  points at a scheduler/registry/managed Batch service (cron, Airflow, AWS Batch, Cloud Run jobs)
  and `deploy/terraform/` provisions the compute + object storage. `docs/ops/deployment.md` is a
  runbook for those targets - job success/alerting replaces the health check a service would have.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`) - here the source/warehouse connection strings and object-store credentials,
  all optional until real - and `make check` (plus CI) runs `scripts/check-env.sh` to keep
  `.env.example` in lockstep with it and enforce required keys in any real `.env`. Pull every
  credential from the environment or a secrets manager; never commit one. Declare new variables in
  both the schema and `.env.example`, or the gate fails.

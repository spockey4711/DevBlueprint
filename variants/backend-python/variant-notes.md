## Stack notes (Python / FastAPI)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `uv sync`).
- Layered: `routes/` (HTTP only) -> `services/` (logic) -> `repositories/` (persistence) ->
  `models/`/`schemas/`. HTTP concerns never leak below `routes/`.
- Validate every input with a Pydantic schema at the boundary; map domain errors to HTTP codes
  in one place, never leak a stack trace.
- mypy `strict`; ruff owns lint + format. Read config from the environment, never hard-code
  secrets.
- Ops artifacts ship as fillable skeletons: a multi-stage `Dockerfile` (uv-built venv -> slim
  `python:3.12-slim` running uvicorn as a non-root user) + `.dockerignore` + `docker-compose.yml` for
  containers, and `deploy/` for a hosted target (`fly.toml`, `render.yaml`, `terraform/`). Keep the
  one target you deploy to and delete the rest.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`), and the gate (plus CI) runs `scripts/check-env.sh` to keep `.env.example` in
  lockstep with it and enforce required keys in any real `.env`. Declare new variables in both the
  schema and `.env.example`, or the gate fails.

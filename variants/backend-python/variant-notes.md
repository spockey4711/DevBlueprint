## Stack notes (Python / FastAPI)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `uv sync`).
- Layered: `routes/` (HTTP only) -> `services/` (logic) -> `repositories/` (persistence) ->
  `models/`/`schemas/`. HTTP concerns never leak below `routes/`.
- Validate every input with a Pydantic schema at the boundary; map domain errors to HTTP codes
  in one place, never leak a stack trace.
- mypy `strict`; ruff owns lint + format. Read config from the environment, never hard-code
  secrets.

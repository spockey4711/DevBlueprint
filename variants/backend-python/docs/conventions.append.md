
---

## Stack-specific conventions (Python / FastAPI)

### Language & tooling

- **Type hints everywhere; mypy `strict`.** No untyped `def`, no bare `# type: ignore` without
  a justifying comment. Prefer precise types (`Sequence`, `Mapping`) over `Any`.
- **Ruff** owns both linting and formatting - do not hand-format. Zero warnings in CI.
- Target a single supported Python version; pin it in `pyproject.toml` and `.python-version`.

### Naming & structure

- Modules and functions `snake_case`; classes `PascalCase`; constants `UPPER_SNAKE_CASE`.
- Layered layout: `routes/` (HTTP only) -> `services/` (business logic) -> `repositories/`
  (persistence) -> `models/` + `schemas/` (ORM + Pydantic). HTTP concerns never leak below
  `routes/`.
- One responsibility per module; keep functions small and pure where possible.

### API & data

- Validate every request body/query with a Pydantic schema at the boundary; never trust input.
- Return typed error responses, not raw exceptions - map domain errors to HTTP codes in one
  place.
- Keep business logic out of route handlers so it is unit-testable without the web layer.
- No secrets in code or logs; read config from the environment (12-factor).

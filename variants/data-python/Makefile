# Quality gate for a data-science Python project (uv-managed). `make check` runs
# the whole gate; CI calls the same targets. Prefix with `uv run` so the pinned
# environment is used.
.PHONY: check validate-env lint format typecheck test notebooks clean

check: validate-env lint typecheck notebooks test

# Enforce the environment contract: .env.example must stay in lockstep with
# .env.schema, and a real .env (if present) must satisfy every required key. This
# is stack-agnostic and always on - fill in the schema, not this target.
validate-env:
	@sh scripts/check-env.sh

lint:
	uv run ruff check .
	uv run ruff format --check .

format:
	uv run ruff format .
	uv run ruff check --fix .

typecheck:
	uv run mypy src

notebooks:
	uv run nbqa ruff notebooks
	uv run nbstripout --verify $$(git ls-files '*.ipynb')

test:
	uv run pytest

clean:
	rm -rf .mypy_cache .ruff_cache .pytest_cache
	find . -type d -name __pycache__ -prune -exec rm -rf {} +

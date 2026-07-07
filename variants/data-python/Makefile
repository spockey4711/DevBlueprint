# Quality gate for a data-science Python project (uv-managed). `make check` runs
# the whole gate; CI calls the same targets. Prefix with `uv run` so the pinned
# environment is used.
.PHONY: check lint format typecheck test notebooks clean

check: lint typecheck notebooks test

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

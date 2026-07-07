# Quality and testing

**Purpose:** the quality bar and how it is enforced for this data-science project. Concrete
overlay of the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
ruff check .              # lint - zero warnings
ruff format --check .     # formatting is canonical
nbqa ruff notebooks       # lint notebooks with the same rules
mypy src                  # static types on the library code - zero errors
pytest                    # unit + data tests
```

Notebooks must be committed with outputs stripped; CI fails if any tracked `.ipynb` still
carries output (`nbstripout --verify`). Install the pre-commit hook and it happens on commit.

## Testing strategy

Test what has logic or can silently break; do not chase coverage on exploratory notebook cells.

- **Unit (pytest):** feature-engineering and transform functions, metrics, data-validation
  helpers, anything moved out of a notebook into `src/`. Deterministic - seed any randomness.
- **Data tests:** assert the shape/schema/invariants of inputs and outputs (no nulls where they
  are forbidden, ranges, categorical domains, row counts) so a bad file fails loud, not silent.
- **Reproducibility:** a fixed seed and pinned deps must reproduce reported numbers. Keep raw
  data immutable; derive everything downstream so a run can be replayed from source.
- Keep notebooks thin: once a cell is worth testing, move it into `src/` and import it back.

Target: meaningful coverage of the `src/` library and the data contracts, not a global
percentage or notebook cells.

## Tooling

- **Ruff** - lint + formatter in one. Config in `pyproject.toml` under `[tool.ruff]`.
- **nbqa** - runs ruff (and other tools) over notebooks so they meet the same bar as `src/`.
- **nbstripout** - clears notebook outputs on commit; keeps diffs reviewable and data out of git.
- **mypy** - strict mode over `src` (`[tool.mypy] strict = true`). No `# type: ignore` without a
  reason.
- **pytest** - specs in `tests/`.
- **pre-commit** - the `pre-commit` framework runs ruff, nbqa and nbstripout on staged files.
- **uv** - dependency and virtualenv management; `uv sync --frozen` in CI.
- **CI** - `.github/workflows/ci.yml` runs the full gate on every PR into `develop`/`master`.

## Definition of done

1. It works, the numbers are reproducible from raw data, and the analysis question is answered.
2. ruff, nbqa, mypy and pytest are green; notebooks are output-stripped.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.

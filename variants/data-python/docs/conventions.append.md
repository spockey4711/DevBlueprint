
---

## Stack-specific conventions (Python / data science)

### Language & tooling

- **Type hints on `src/`; mypy `strict`.** No untyped `def`, no bare `# type: ignore` without a
  justifying comment. Prefer precise types (`pd.DataFrame`, `npt.NDArray`) over `Any`.
- **Ruff** owns both linting and formatting - do not hand-format. **nbqa** applies the same rules
  to notebooks. Zero warnings in CI.
- Target a single supported Python version; pin it in `pyproject.toml`, `.python-version` and
  `.tool-versions`.

### Notebooks vs. library

- Notebooks (`notebooks/`) are for exploration and communication, not a home for reusable logic.
  The moment a function is reused or worth testing, move it into `src/` and import it back.
- Commit notebooks with **outputs stripped** (nbstripout). Never paste large outputs, secrets or
  data samples into a committed notebook.
- `src/` is importable, typed and tested; notebooks depend on `src/`, never the reverse.

### Data & reproducibility

- Treat raw data as **immutable**; write derived artifacts to `data/processed/`, never in place.
  `data/` contents are gitignored - version them with DVC or object storage, referenced by hash.
- **Seed every source of randomness** (numpy, framework RNGs, train/test splits) so results
  replay. Record parameters and seeds, do not rely on notebook execution order.
- Validate the shape and schema of inputs and outputs at boundaries; fail loud on bad data.

### Naming & structure

- Modules and functions `snake_case`; classes `PascalCase`; constants `UPPER_SNAKE_CASE`.
- Name notebooks with an ordering prefix and a slug: `01-explore-signups.ipynb`.
- Read paths, credentials and hyperparameters from config/environment - no secrets in code,
  logs or notebooks (12-factor).

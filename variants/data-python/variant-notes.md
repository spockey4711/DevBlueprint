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

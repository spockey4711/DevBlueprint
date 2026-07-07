# CLI tests

[Bats](https://github.com/bats-core/bats-core) suite for `bin/devblueprint`. Each test scaffolds
into a throwaway temp dir, so the suite never touches your working tree.

## Run

```bash
make test        # skips gracefully if bats is not installed
bats test/       # run directly
```

Install bats locally with `brew install bats-core` (macOS) or `apt-get install bats` (Debian/Ubuntu).
CI installs it and runs the suite on every PR.

## Layout

- `helper.bash` - shared `setup`/`teardown` (temp dir per test) and the `db` runner.
- `init.bats` - `init` + `doctor` for every variant, plus argument and error handling.
- `overwrite.bats` - overwrite safety: skip existing files vs. `--force`.
- `tokens.bats` - token substitution and branch modes (two-branch default, `--base master`).

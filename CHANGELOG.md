# Changelog

All notable changes are documented here, following
[Keep a Changelog](https://keepachangelog.com/) and [SemVer](https://semver.org/).

## [Unreleased]

### Changed

- Reworked DevBlueprint from the `apkit` spec-scaffolding CLI into a documentation-first
  engineering-setup kit centered on the git workflow, quality gate and AI-assistant guidance.

### Added

- Tech-agnostic `core/`: git-workflow, engineering-standards, conventions and quality-and-testing
  docs, plus `CLAUDE.md` and `CONTRIBUTING.md` templates.
- Parametrized `scripts/wt.sh` worktree manager driven by an optional `wt.conf` (branches,
  allowed types, post-create install hook).
- Variants: `web-nextjs`, `backend-python`, `ios-swift`, `generic`, each with its own quality
  gate, CI workflow, `.gitignore`, conventions overlay and `CLAUDE.md` notes.
- `bin/devblueprint` CLI: `list`, `init` (overwrite-safe scaffolding from core + a variant) and
  `doctor`.
- Per-variant `setup.sh`, dropped into every scaffolded project by `init`: an idempotent
  one-shot that turns the variant's "after init" checklist into a single command (tool config
  files, package-manifest scripts, pre-commit hook and dependency install). Non-Node variants
  use a committable `.githooks/pre-commit` via `core.hooksPath`.
- Bats CLI test suite under `test/`, run by `make test` and enforced in CI alongside shellcheck:
  covers `init` + `doctor` for every variant, overwrite safety (skip vs. `--force`), branch
  modes (two-branch default and `--base master`), and token substitution in the rendered docs
  (P0-1).

### Removed

- The `apkit` Node CLI, its web interface, examples, prompt library and templates.

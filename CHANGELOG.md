# Changelog

All notable changes are documented here, following
[Keep a Changelog](https://keepachangelog.com/) and [SemVer](https://semver.org/).

## [Unreleased]

### Changed

- Reworked DevBlueprint from the `apkit` spec-scaffolding CLI into a documentation-first
  engineering-setup kit centered on the git workflow, quality gate and AI-assistant guidance.

### Added

- Stack-agnostic repo hygiene in `core/`: `.editorconfig` (charset, LF, final newline, indent
  baseline) and `.gitattributes` (line-ending normalization + binary-type hints). `init` drops
  both into new projects and `doctor` checks them; being project-independent, `update` keeps
  them in sync like the other core-owned files. Refs: P1-1.
- Tech-agnostic `core/`: git-workflow, engineering-standards, conventions and quality-and-testing
  docs, plus `CLAUDE.md` and `CONTRIBUTING.md` templates.
- Parametrized `scripts/wt.sh` worktree manager driven by an optional `wt.conf` (branches,
  allowed types, post-create install hook).
- Variants: `web-nextjs`, `backend-python`, `ios-swift`, `generic`, each with its own quality
  gate, CI workflow, `.gitignore`, conventions overlay and `CLAUDE.md` notes.
- `bin/devblueprint` CLI: `list`, `init` (overwrite-safe scaffolding from core + a variant),
  `update` and `doctor`.
- `devblueprint update`: re-syncs the core-owned files (`docs/engineering/git-workflow.md`,
  `engineering-standards.md` and `scripts/wt.sh`) into a project scaffolded earlier, so old
  projects pick up `core/` changes. It never touches `CLAUDE.md`, `CONTRIBUTING.md`, `wt.conf`,
  CI or code; `--variant <name>` also refreshes the variant-overlaid `conventions.md` and
  `quality-and-testing.md` (rebuilt byte-identically to `init`), and `--dry-run` previews.
- Kit versioning: a `VERSION` source of truth, a `devblueprint version` command (also
  `--version`/`-V`), and a `.devblueprint` scaffold stamp recording the kit version and variant
  each project was generated from, so a future `update` can tell which core files are stale.
  `doctor` now reports the stamped version against the current kit version. Refs: P0-3.
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

### Fixed

- Single-branch scaffolding (`init --base master`, or any `BASE_BRANCH == MAIN_BRANCH`) no longer
  renders garbled two-branch prose in `CLAUDE.md`/`CONTRIBUTING.md`. The templates now carry
  `{{#TWO_BRANCH}}`/`{{#SINGLE_BRANCH}}` conditional blocks, and `init` keeps the trunk-flow
  variant (no release-PR step) when base equals main.

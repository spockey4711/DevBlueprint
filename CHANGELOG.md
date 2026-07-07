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

### Removed

- The `apkit` Node CLI, its web interface, examples, prompt library and templates.

### Fixed

- Single-branch scaffolding (`init --base master`, or any `BASE_BRANCH == MAIN_BRANCH`) no longer
  renders garbled two-branch prose in `CLAUDE.md`/`CONTRIBUTING.md`. The templates now carry
  `{{#TWO_BRANCH}}`/`{{#SINGLE_BRANCH}}` conditional blocks, and `init` keeps the trunk-flow
  variant (no release-PR step) when base equals main.

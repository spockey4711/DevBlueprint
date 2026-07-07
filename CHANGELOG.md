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

### Removed

- The `apkit` Node CLI, its web interface, examples, prompt library and templates.

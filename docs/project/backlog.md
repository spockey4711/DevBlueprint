# Backlog

The prioritized task list - the source of truth for what to build next. Reference an id in
commits and PRs (e.g. `Refs: P0-1`).

## P0 - core promise (init/update must be trustworthy)

- [x] P0-1: CLI test suite (bats). Run `init` into a tmp dir, assert `doctor` passes; cover
  overwrite-safety (skip vs. `--force`), `--base master` single-branch mode, and token
  substitution in `CLAUDE.md`/`CONTRIBUTING.md`. Wire into CI alongside shellcheck.
- [ ] P0-2: `devblueprint update` command. Re-sync `docs/engineering/*` and `scripts/wt.sh`
  from `core/` into an existing project; never touch `CLAUDE.md`, code, or `wt.conf`. Lets old
  projects pick up core changes instead of being scaffold-once-and-forget.
- [ ] P0-3: `--version` flag + embed the kit version in scaffolded files, so `update` can tell
  what is stale.
- [ ] P0-4: Single-branch rendering bug. With `--base master` (or any `BASE_BRANCH ==
  MAIN_BRANCH`), `CLAUDE.md`/`CONTRIBUTING.md` render garbled two-branch prose ("`master` is
  promoted ... to `master`"). Add a single-branch variant of the workflow blocks in
  `core/templates/CLAUDE.md.tmpl` and `CONTRIBUTING.md.tmpl` (trunk flow, no release-PR step)
  selected when base == main. Found while dogfooding the kit on this repo.

## P1 - repo hygiene shipped with every variant

- [ ] P1-1: Stack-agnostic files in `core/`: `.editorconfig`, `.gitattributes`.
- [ ] P1-2: GitHub meta: `.github/pull_request_template.md`, issue templates.
- [ ] P1-3: Optional templates: `SECURITY.md`, `CODE_OF_CONDUCT.md`.
- [ ] P1-4: Pre-commit hook that runs the quality gate. `scripts/install-hooks.sh` or
  `.githooks/pre-commit` + `core.hooksPath`, so the "before pushing" gate is enforced, not just
  documented.

## P2 - reach (more stacks, more automation)

- [ ] P2-1: New variants: `backend-go`, `rust`, `node-express`, `android-kotlin`, `data-python`.
- [ ] P2-2: Dependency automation per variant: `dependabot.yml` / `renovate.json`.
- [ ] P2-3: ADR template under `docs/decisions/` (0001-record-architecture-decisions.md).
- [ ] P2-4: Toolchain pinning: `.tool-versions` (asdf/mise) or `.devcontainer/` per variant, so
  "wire the toolchain" is reproducible.

## P3 - polish

- [ ] P3-1: `doctor` beyond file existence: optionally run the quality gate and check git state.
- [ ] P3-2: Kit-self changelog note in `core/README.md` for variant authors.

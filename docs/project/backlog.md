# Backlog

The prioritized task list - the source of truth for what to build next. Reference an id in
commits and PRs (e.g. `Refs: P0-1`).

## P0 - core promise (init/update must be trustworthy)

- [x] P0-1: CLI test suite (bats). Run `init` into a tmp dir, assert `doctor` passes; cover
  overwrite-safety (skip vs. `--force`), `--base master` single-branch mode, and token
  substitution in `CLAUDE.md`/`CONTRIBUTING.md`. Wire into CI alongside shellcheck.
- [x] P0-2: `devblueprint update` command. Re-syncs the core-owned files
  (`docs/engineering/git-workflow.md`, `engineering-standards.md`, `scripts/wt.sh`) from `core/`
  into an existing project; never touches `CLAUDE.md`, code, or `wt.conf`. `--variant` also
  refreshes the variant-overlaid `conventions.md`/`quality-and-testing.md`; `--dry-run` previews.
  Lets old projects pick up core changes instead of being scaffold-once-and-forget.
- [x] P0-3: `--version` flag + embed the kit version in scaffolded files, so `update` can tell
  what is stale.
- [x] P0-4: Single-branch rendering bug. With `--base master` (or any `BASE_BRANCH ==
  MAIN_BRANCH`), `CLAUDE.md`/`CONTRIBUTING.md` render garbled two-branch prose ("`master` is
  promoted ... to `master`"). Add a single-branch variant of the workflow blocks in
  `core/templates/CLAUDE.md.tmpl` and `CONTRIBUTING.md.tmpl` (trunk flow, no release-PR step)
  selected when base == main. Found while dogfooding the kit on this repo.

## P1 - repo hygiene shipped with every variant

- [x] P1-1: Stack-agnostic files in `core/`: `.editorconfig`, `.gitattributes`. `init` drops both
  into new projects, `doctor` checks them, and `update` keeps them in sync as core-owned files.
- [x] P1-2: GitHub meta: `.github/pull_request_template.md`, issue templates. Core-owned, so
  `init` drops them into new projects, `doctor` checks them, and `update` keeps them in sync.
- [x] P1-3: Optional templates: `SECURITY.md`, `CODE_OF_CONDUCT.md`. Opt-in via
  `init --community`; `--contact <method>` fills the reporting address in both.
- [x] P1-4: Pre-commit hook that runs the quality gate. Each variant's `setup.sh` wires it
  (`.githooks/pre-commit` + `core.hooksPath` for generic/ios, husky and the pre-commit framework
  for Node/Python), `doctor` reports whether it is wired, and the bats suite asserts it - so the
  "before pushing" gate is enforced, not just documented.

## P2 - reach (more stacks, more automation)

The remaining work is grouped into **waves of four tasks that own disjoint file sets**, so
each can run in its own worktree/agent with near-zero merge conflicts. Each task lists the
paths it **owns**; do not stray outside them.

Conflict rules:

- **`bin/devblueprint` and `test/`** are the only shared "hot" paths. Never schedule two
  CLI-touching tasks in the same wave. Across the whole plan only two tasks edit the CLI
  (P2-1 the `init` copy step, P2-6 the `doctor` command) and they live in different waves and
  different functions.
- **`CHANGELOG.md`** is append-only; every task adds one line under `## [Unreleased]`. Trivial
  to resolve if two land together; keep the entry to a single line.
- **New variants never touch shared files** - a variant is a self-contained `variants/<name>/`
  directory, auto-discovered by `list_variants`. Any number can run in parallel.
- **Ordering:** P2-1 (extras-copy mechanism) is the one soft dependency. Tasks that ship
  per-variant config files (P2-4, P2-9..P2-12, and the new-variant configs) can be *authored*
  independently, but their files are only picked up by `init`/`update` once P2-1 has merged.
  Merge P2-1 first within its wave.

### Wave 1 - enabler + standalone

- [x] P2-1: Generic variant-extras copy in the CLI (enabler). Today `init` copies a fixed set
  of variant files (`ci.yml`, `gitignore`, `Makefile`, `setup.sh`) by name, so shipping any new
  per-variant config needs a CLI edit - the coupling that would force every config task into
  this one file. Generalize it: recursively copy `variants/<name>/extras/` -> project root and
  `variants/<name>/github/` -> `.github/`, so variants can ship `dependabot.yml` / `renovate.json`
  / `.tool-versions` / `.devcontainer/` / `.editorconfig` with no further CLI changes. Cover it
  in the bats suite. **Owns:** `bin/devblueprint` (init copy step), `test/`.
- [x] P2-2: ADR scaffolding. Add `docs/decisions/0001-record-architecture-decisions.md` plus a
  `NNNN-template.md` and a short index/README explaining the ADR flow; reference it from
  `docs/engineering/`. **Owns:** `docs/decisions/`, one link line in an existing `docs/engineering`
  file.
- [x] P2-3: Variant-author changelog + contributor note in `core/README.md` - how core vs.
  variant files are layered, and how to add a variant. **Owns:** `core/README.md`.
- [x] P2-4: New variant `data-python` (data-science stack), shipped complete: `manifest.env`,
  `setup.sh`, `github/workflows/ci.yml`, `gitignore`, `Makefile`, `docs/quality-and-testing.md`,
  `docs/conventions.append.md`, `variant-notes.md`, `wt.conf`, plus its `extras/` (dependency
  automation + toolchain pin). Mirror an existing variant's file set. **Owns:**
  `variants/data-python/`. (soft dep: P2-1 for extras copy)

### Wave 2 - new variants (fully isolated, none touch the CLI)

- [x] P2-5: New variant `backend-go`, shipped complete like P2-4. **Owns:** `variants/backend-go/`.
- [x] P2-6: New variant `rust`, shipped complete like P2-4. **Owns:** `variants/rust/`.
- [x] P2-7: New variant `node-express`, shipped complete like P2-4. **Owns:** `variants/node-express/`.
- [x] P2-8: New variant `android-kotlin`, shipped complete like P2-4. **Owns:** `variants/android-kotlin/`.

### Wave 3 - deepen the CLI + backfill config for existing variants

- [x] P2-9: `doctor` beyond file existence - optionally run the quality gate and report git state
  (`--strict` / `--run-gate`). **Owns:** `bin/devblueprint` (`cmd_doctor`), `test/`.
- [ ] P2-10: Dependency automation + toolchain pin for the `generic` variant: `dependabot.yml`
  or `renovate.json` + `.tool-versions` (asdf/mise) or `.devcontainer/`, dropped under
  `variants/generic/extras/`. **Owns:** `variants/generic/`. (dep: P2-1)
- [x] P2-11: Same config backfill for the `backend-python` variant. **Owns:**
  `variants/backend-python/`. (dep: P2-1)
- [x] P2-12: Same config backfill for the `web-nextjs` and `ios-swift` variants (both under one
  owner since neither collides). **Owns:** `variants/web-nextjs/`, `variants/ios-swift/`. (dep: P2-1)

## P3 - agent-native setup (conversational init, PRD ingestion, deploy runbooks)

The goal: a mid-level developer opens Claude Code in the kit and says "set up this project
for my thing"; the agent runs a structured interview (or reads an uploaded PRD), writes a
reproducible intake file, scaffolds from it, seeds the backlog, and drops a deployment
runbook - all without DevBlueprint growing a runtime. The "runtime" is the agent; the kit
just provides machine-readable interfaces, a canonical interview/intake spec, and the new
generated artifacts. Everything stays plain files the user owns (no lock-in).

Conflict rules (same discipline as P2):

- **`bin/devblueprint` and `test/`** stay the only hot shared paths. Never schedule two
  CLI-touching tasks in the same wave. Across this plan the CLI is edited by P3-1
  (`init --from` + `plan`) and P3-5 (`--json` output) only, and they live in different waves.
- **New agent-facing files are self-contained** under `agent/` (kit-level skills/specs the
  agent reads at setup time; not shipped per-project). Disjoint from the CLI and from variants,
  so they run in parallel.
- **Deploy runbooks ride the P2-1 extras mechanism** - each variant ships them under
  `variants/<name>/extras/docs/ops/`, so no CLI change is needed and variants never collide.
- **Ordering:** P3-1 is the enabler. It defines the `.devblueprint-intake.yml` schema that the
  interview (P3-2) and PRD flow (P3-3) target and that `init --from` consumes. Merge P3-1 first
  within its wave; P3-2/P3-3 can be authored in parallel against the drafted schema.

### Wave 1 - the MVP end-to-end flow

- [ ] P3-1: Intake file + `init --from` + `plan` (CLI enabler). Define a small, documented
  `.devblueprint-intake.yml` schema (project name, variant, main/base branch, community/contact,
  deploy target) and teach `init` to read it via `--from <file>`, mapping keys onto the existing
  flags/tokens (explicit flags still win, so a conversation can override one answer). Add
  `devblueprint plan --from <file>` (or `--dry-run` on init): print exactly what init *would*
  write, so the agent can confirm with the user before touching disk. Ship an annotated
  `agent/intake.example.yml` and a schema doc. Cover parsing + precedence + plan output in bats.
  **Owns:** `bin/devblueprint` (`cmd_init`, new `cmd_plan`), `test/`, `docs/agent/intake-schema.md`,
  `agent/intake.example.yml`. (enabler - merge first)
- [ ] P3-2: Setup-interview skill. Ship `agent/setup-interview.md` - a canonical, ordered
  question flow (purpose, stack -> variant, deploy target, solo vs. team -> branch strategy,
  license/community) that ends by writing `.devblueprint-intake.yml` and calling `plan` then
  `init --from`. Package it as a Claude Code skill (`agent/skills/devblueprint-setup/SKILL.md`)
  and document in `GUIDE.md` how to invoke it ("open Claude Code, run /devblueprint-setup").
  The agent asks only these questions - never invents scope. **Owns:** `agent/setup-interview.md`,
  `agent/skills/devblueprint-setup/`, one "Agent-driven setup" section in `GUIDE.md`.
  (targets the P3-1 schema)
- [ ] P3-3: PRD -> intake + backlog. Ship `agent/prd-to-backlog.md`: a prompt/skill that reads an
  uploaded PRD (Markdown/PDF), pre-fills `.devblueprint-intake.yml` (stack detection, deploy
  target) so the interview skips answered questions, and - post-init - turns the PRD into real
  P0/P1 tasks in `docs/project/backlog.md` (existing format) plus optional seed ADRs. Pure
  documentation/prompt, no CLI. **Owns:** `agent/prd-to-backlog.md`. (targets the P3-1 schema)
- [ ] P3-4: Deploy runbook artifacts for `web-nextjs` + `generic`. Via the P2-1 extras mechanism,
  each ships `extras/docs/ops/deployment.md` (a runbook covering the common deploy targets -
  VPS/Docker/managed - with the DB and env-var checklist) plus `extras/.env.example`. The
  interview's deploy-target answer tells the agent which section to keep. Documentation-first:
  a runbook, not a hosted deploy. **Owns:** `variants/web-nextjs/`, `variants/generic/`. (dep: P2-1)

### Wave 2 - deepen + widen

- [ ] P3-5: Machine-readable CLI output for the agent: `list --json`, `doctor --json`,
  `version --json`, so the agent can parse available variants and post-setup health instead of
  scraping human text. **Owns:** `bin/devblueprint` (`cmd_list`, `cmd_doctor`, `cmd_version`),
  `test/`.
- [ ] P3-6: Deploy runbooks for the remaining backend/web variants (`backend-python`,
  `backend-go`, `node-express`), mirroring P3-4. **Owns:** `variants/backend-python/`,
  `variants/backend-go/`, `variants/node-express/`. (dep: P2-1, pattern from P3-4)
- [ ] P3-7: `devblueprint detect --target <dir>` - inspect an existing repo (`package.json`,
  `go.mod`, `Cargo.toml`, `Package.swift`, `pyproject.toml`) and recommend a variant, so adding
  the workflow to an existing project needs no guesswork. CLI hot path, so it lands in its own
  wave apart from P3-5. **Owns:** `bin/devblueprint` (new `cmd_detect`), `test/`.

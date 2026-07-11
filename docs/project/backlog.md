# Backlog

The prioritized task list - the source of truth for what to build next. Reference an id in
commits and PRs (e.g. `Refs: P0-1`). Task markers: `- [ ]` todo, `- [x]` done, `- [~]` merged
with a follow-up still pending (see the task lifecycle in
[`docs/engineering/git-workflow.md`](../engineering/git-workflow.md)).

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
- [x] P2-10: Dependency automation + toolchain pin for the `generic` variant: `dependabot.yml`
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

- [x] P3-1: Intake file + `init --from` + `plan` (CLI enabler). Define a small, documented
  `.devblueprint-intake.yml` schema (project name, variant, main/base branch, community/contact,
  deploy target) and teach `init` to read it via `--from <file>`, mapping keys onto the existing
  flags/tokens (explicit flags still win, so a conversation can override one answer). Add
  `devblueprint plan --from <file>` (or `--dry-run` on init): print exactly what init *would*
  write, so the agent can confirm with the user before touching disk. Ship an annotated
  `agent/intake.example.yml` and a schema doc. Cover parsing + precedence + plan output in bats.
  **Owns:** `bin/devblueprint` (`cmd_init`, new `cmd_plan`), `test/`, `docs/agent/intake-schema.md`,
  `agent/intake.example.yml`. (enabler - merge first)
- [x] P3-2: Setup-interview skill. Ship `agent/setup-interview.md` - a canonical, ordered
  question flow (purpose, stack -> variant, deploy target, solo vs. team -> branch strategy,
  license/community) that ends by writing `.devblueprint-intake.yml` and calling `plan` then
  `init --from`. Package it as a Claude Code skill (`agent/skills/devblueprint-setup/SKILL.md`)
  and document in `GUIDE.md` how to invoke it ("open Claude Code, run /devblueprint-setup").
  The agent asks only these questions - never invents scope. **Owns:** `agent/setup-interview.md`,
  `agent/skills/devblueprint-setup/`, one "Agent-driven setup" section in `GUIDE.md`.
  (targets the P3-1 schema)
- [x] P3-3: PRD -> intake + backlog. Ship `agent/prd-to-backlog.md`: a prompt/skill that reads an
  uploaded PRD (Markdown/PDF), pre-fills `.devblueprint-intake.yml` (stack detection, deploy
  target) so the interview skips answered questions, and - post-init - turns the PRD into real
  P0/P1 tasks in `docs/project/backlog.md` (existing format) plus optional seed ADRs. Pure
  documentation/prompt, no CLI. **Owns:** `agent/prd-to-backlog.md`. (targets the P3-1 schema)
- [x] P3-4: Deploy runbook artifacts for `web-nextjs` + `generic`. Via the P2-1 extras mechanism,
  each ships `extras/docs/ops/deployment.md` (a runbook covering the common deploy targets -
  VPS/Docker/managed - with the DB and env-var checklist) plus `extras/.env.example`. The
  interview's deploy-target answer tells the agent which section to keep. Documentation-first:
  a runbook, not a hosted deploy. **Owns:** `variants/web-nextjs/`, `variants/generic/`. (dep: P2-1)

### Wave 2 - deepen + widen

- [x] P3-5: Machine-readable CLI output for the agent: `list --json`, `doctor --json`,
  `version --json`, so the agent can parse available variants and post-setup health instead of
  scraping human text. **Owns:** `bin/devblueprint` (`cmd_list`, `cmd_doctor`, `cmd_version`),
  `test/`.
- [x] P3-6: Deploy runbooks for the remaining backend/web variants (`backend-python`,
  `backend-go`, `node-express`), mirroring P3-4. **Owns:** `variants/backend-python/`,
  `variants/backend-go/`, `variants/node-express/`. (dep: P2-1, pattern from P3-4)
- [x] P3-7: `devblueprint detect --target <dir>` - inspect an existing repo (`package.json`,
  `go.mod`, `Cargo.toml`, `Package.swift`, `pyproject.toml`) and recommend a variant, so adding
  the workflow to an existing project needs no guesswork. CLI hot path, so it lands in its own
  wave apart from P3-5. **Owns:** `bin/devblueprint` (new `cmd_detect`), `test/`.

## The 12-month roadmap (P4 - P7)

P4-P7 are the quarters after the P3 agent-native MVP. Same discipline as before, plus one
extra rule that dominates this stretch:

- **`(CLI)`-tagged tasks edit `bin/devblueprint` + `test/` - the only hot shared paths.**
  Schedule at most one per wave; they are the serialization bottleneck across the whole
  roadmap. Everything untagged (new variants, per-variant config, `core/templates/`,
  `agent/`, `packaging/`) is parallel-safe and never touches the CLI.
- **Per-variant fan-out**: tasks that add a file across many variants (security CI, release
  automation, ops artifacts) can be split one-worktree-per-variant; each owns only its
  `variants/<name>/` subtree.
- **North star unchanged**: the agent is the runtime; the kit stays plain files with no
  lock-in. An MCP server or a hosted web service are deliberately out of scope - the closest
  we go is a static, backend-less config builder (P5-4).

### P4 - distribution & lifecycle (Q1: make it installable)

The biggest adoption lever - today you must clone the repo to run `bin/devblueprint`.

- [x] P4-1: Installability. Ship `npx devblueprint` (root `package.json` with a `bin` field),
  a Homebrew tap, and a `curl | sh` installer, so the kit runs without a clone. Update the
  README install section. No CLI-internals change. **Owns:** `packaging/`, `install.sh`,
  root `package.json`, README install section.
- [x] P4-2: (CLI) `devblueprint upgrade` - self-update the installed kit, with stable/next
  version channels and pinning, so `update` targets stay reproducible. **Owns:**
  `bin/devblueprint` (new `cmd_upgrade`), `test/`.
- [x] P4-3: Kit self-CI. A matrix workflow that scaffolds every variant into a throwaway dir,
  runs its `setup.sh` and quality gate in a container, and fails on any red - catches variant
  rot before release. **Owns:** `.github/workflows/scaffold-matrix.yml`,
  `scripts/scaffold-check.sh`.

### P5 - sustainability & reach (Q2: drift, multi-agent, non-agent DX)

CLI tasks P5-1, P5-3, P5-5 each take their own wave.

- [x] P5-1: (CLI) `devblueprint diff --target` - report where a project has drifted from the
  current kit, using the `.devblueprint` version stamp as the base. The read-only precursor to
  a smarter `update`. **Owns:** `bin/devblueprint` (new `cmd_diff`), `test/`.
- [x] P5-2: Multi-agent instruction templates. Author `AGENTS.md`, `.cursor/rules/`, and
  `.github/copilot-instructions.md` templates from the same canonical workflow guidance that
  drives `CLAUDE.md`, so the process is not Claude-only. Templates only, no CLI wiring yet.
  **Owns:** `core/templates/agents/`.
- [x] P5-3: (CLI) Wire `init --agents claude,cursor,codex` to emit the P5-2 templates and keep
  them in sync on `update`. **Owns:** `bin/devblueprint` (`cmd_init`, `cmd_update`), `test/`.
  (dep: P5-2; separate wave from P5-1)
- [x] P5-4: Static config builder - a single backend-less HTML page that produces a
  `.devblueprint-intake.yml` from form input, for users who do not drive setup through an
  agent. Respects the no-runtime principle (nothing hosted). **Owns:** `web/config-builder/`.
  (dep: P3-1 schema)
- [x] P5-5: (CLI) Three-way merge for `update` - preserve local edits to managed files instead
  of overwriting, using the stamped version as the merge base; fall back to reporting a
  conflict. Makes long-lived projects safe to update. **Owns:** `bin/devblueprint`
  (`cmd_update`), `test/`. (own wave; builds on P5-1's diff logic)

The P6-P7 tasks below (Q3-Q4) are re-grouped into **parallel waves of four disjoint tasks**
so you can open all four PRs of a wave at once. The wave grouping obeys the rules above: at
most one `(CLI)` task per wave, and never two of the three `variants/*/github/` fan-outs
(P6-4, P7-1, P7-2) in the same wave. The task definitions (scope, owned paths, deps) are
unchanged - only their ordering into waves. The eight P6-2 variants are each their own PR.

### Wave 1 - monorepo + security CI + first variants

- [x] P6-1: (CLI) Monorepo / multi-variant init - one repo, multiple packages, per-package
  quality gates, aggregated CI. The one large structural change; everything is single-variant
  today. **Owns:** `bin/devblueprint` (init multi-variant path), `test/`.
- [x] P6-4: Security-gate baseline across variants: gitleaks (secret scan), semgrep (SAST),
  dependency-review and CodeQL workflows, commitlint + PR-title check, and coverage
  thresholds - added to each variant's CI. Fan out per variant. **Owns:** `variants/*/github/`
  (one variant subtree per task).
- [x] P6-2a: New variant `flutter`, self-contained mirroring P2-4. **Owns:** `variants/flutter/`.
  (dep: P2-1)
- [x] P6-2b: New variant `spring-java`, self-contained mirroring P2-4. **Owns:**
  `variants/spring-java/`. (dep: P2-1)

### Wave 2 - flavors + release automation + variants

- [ ] P6-3: (CLI) Variant add-on/flavor mechanism - orthogonal overlays (db, auth, container)
  layered onto a base variant at init, e.g. `--flavor postgres,docker`. **Owns:**
  `bin/devblueprint` (flavor resolution), `test/`, `variants/_flavors/`.
- [x] P7-1: Release automation per variant - Conventional-Commits-driven versioning, CHANGELOG
  generation and GitHub releases (release-please or semantic-release), wired into each
  variant's CI. Closes the loop on the existing changelog discipline. Fan out per variant.
  **Owns:** `variants/*/github/` + release config (one variant subtree per task).
- [x] P6-2c: New variant `dotnet`, self-contained mirroring P2-4. **Owns:** `variants/dotnet/`.
  (dep: P2-1)
- [x] P6-2d: New variant `rails`, self-contained mirroring P2-4. **Owns:** `variants/rails/`.
  (dep: P2-1)

### Wave 3 - doctor --fix + GitLab CI + variants

- [ ] P6-5: (CLI) `doctor --fix` - auto-repair missing or corrupted foundation files instead
  of only reporting them. **Owns:** `bin/devblueprint` (`cmd_doctor`), `test/`.
- [ ] P7-2: Provider-agnostic + richer CI - GitLab CI templates alongside GitHub Actions, plus
  preview-deploy and dependency-review workflows. **Owns:** `variants/*/gitlab/`,
  `variants/*/github/` (one variant subtree per task).
- [ ] P6-2e: New variant `laravel`, self-contained mirroring P2-4. **Owns:** `variants/laravel/`.
  (dep: P2-1)
- [ ] P6-2f: New variant `sveltekit`, self-contained mirroring P2-4. **Owns:**
  `variants/sveltekit/`. (dep: P2-1)

### Wave 4 - org baseline + ops artifacts + last variants

- [ ] P7-4: (CLI) Org baseline / config inheritance - a company default that projects extend
  (`extends: org-baseline`), turning the kit from a solo tool into a team standardizer.
  **Owns:** `bin/devblueprint` (config resolution), `test/`.
- [ ] P7-3: Ops artifacts beyond the runbook (builds on P3-4/P3-6): optional `Dockerfile`,
  `docker-compose.yml`, Fly/Vercel/Render config and Terraform snippets, plus `.env.example`
  promoted to a validated env schema checked in the gate. **Owns:** `variants/*/extras/`
  (one variant subtree per task).
- [ ] P6-2g: New variant `elixir-phoenix`, self-contained mirroring P2-4. **Owns:**
  `variants/elixir-phoenix/`. (dep: P2-1)
- [ ] P6-2h: New variant `terraform-iac`, self-contained mirroring P2-4. **Owns:**
  `variants/terraform-iac/`. (dep: P2-1)

### Wave 5 - governance (isolated)

- [ ] P7-5: Governance scaffolding - a `CODEOWNERS` template and an opt-in
  branch-protection setup script (`gh api`), so the documented workflow is also technically
  enforced. **Owns:** `core/templates/CODEOWNERS.tmpl`, `scripts/protect-branches.sh`.
  Conflicts with nothing above, so it can ride along with any earlier wave's PRs.

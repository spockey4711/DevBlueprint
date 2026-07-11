# Changelog

All notable changes are documented here, following
[Keep a Changelog](https://keepachangelog.com/) and [SemVer](https://semver.org/).

## [Unreleased]

### Fixed

- The `terraform-iac` variant shipped without the provider-agnostic CI baseline: it landed
  right after the P7-2 sweep and so had no `gitlab/.gitlab-ci.yml` or
  `github/workflows/preview-deploy.yml`. The `init scaffolds provider-agnostic CI for every
  variant` test iterates over all variants, so the gap turned the whole `bats` suite red. Added
  a Terraform-flavored `.gitlab-ci.yml` (a `quality` stage running `terraform fmt`/`validate`/
  `tflint`/`test` on the pinned versions) plus the stack-neutral `preview-deploy.yml`. Refs: P7-2.
- `doctor --run-gate` test for the `backend-go` variant asserted the gate line started with
  `gofumpt`, but the variant's gate is `test -z "$(gofumpt -l .)" && ...`. The assertion now
  matches the real gate string, so CI's stricter `bats` (which aborts a test on any failing
  command, not just the last) passes. Refs: P2-9.

### Changed

- Reworked DevBlueprint from the `apkit` spec-scaffolding CLI into a documentation-first
  engineering-setup kit centered on the git workflow, quality gate and AI-assistant guidance.

### Added

- Governance scaffolding: every project now ships `scripts/protect-branches.sh`, an opt-in
  helper that turns the documented git workflow into an enforced one by applying GitHub branch
  protection (required PRs, approving reviews, optional code-owner review, no direct/force pushes
  or deletions) to the long-lived branches via `gh api`. It reads the branch names from
  `scripts/wt.conf` (the same source `wt.sh` uses), so a single-branch trunk project protects
  only its one branch, and is idempotent. `--community` additionally scaffolds a
  `.github/CODEOWNERS` review-routing file with a fill-in `@OWNER` handle, which
  `protect-branches.sh` enforces once the "require review from Code Owners" rule is on.
  Refs: P7-5.
- Org baseline / config inheritance: an intake file can declare `extends: <baseline>` (or
  `init --extends <baseline>` on the CLI) to inherit a shared org baseline - a company default
  intake file (branches, contact, community, agents, ...) that projects layer their own answers
  over, turning the kit from a solo tool into a team standardizer. A baseline is an ordinary
  intake file, so it may itself `extends` another (chained, with cycle detection). Resolution is
  strict precedence: explicit CLI flags win, then the project's intake keys, then the baseline
  chain (deepest last), then the built-in defaults. A bare `extends: org-baseline` is resolved
  through `$DEVBLUEPRINT_BASELINE_DIR` and the user config dirs
  (`$XDG_CONFIG_HOME/devblueprint/baselines`, `~/.devblueprint/baselines`); a reference with a
  slash, a leading `~/`, or a `.yml`/`.yaml` suffix is a path relative to the referencing file.
  Intake files also gain an `agents` key so a baseline can standardize the coding-agent toolset.
  A ready-to-copy `agent/org-baseline.example.yml` ships alongside `agent/intake.example.yml`.
  Refs: P7-4.
- Ops artifacts for the `backend-go` variant: a multi-stage `Dockerfile` (static `CGO_ENABLED=0`
  binary -> `distroless/static:nonroot`) + `.dockerignore` + `docker-compose.yml`, `deploy/`
  skeletons for Fly/Render/Terraform, and a `.env.schema` promoted from `.env.example` and enforced
  in the gate. `make check` gains a `validate-env` step and CI a `Validate env schema` step (its
  workflow inlines the gate rather than calling `make check`), both running `scripts/check-env.sh`
  to keep `.env.example` in lockstep with the schema and validate required keys/patterns in any real
  `.env`; the `doctor --run-gate` gate runs it too. Refs: P7-3.
- Ops artifacts for the `backend-python` variant: a multi-stage `Dockerfile` (uv-built venv ->
  slim `python:3.12-slim` running uvicorn as a non-root user) + `.dockerignore` + `docker-compose.yml`,
  `deploy/` skeletons for Fly/Render/Terraform, and a `.env.schema` reconciled with `.env.example` and
  enforced in the gate. The variant has no Makefile, so the contract is wired via the manifest
  `QUALITY_GATE` (prepended `sh scripts/check-env.sh`) and a `Validate env schema` CI step, both
  running `scripts/check-env.sh` to keep `.env.example` in lockstep with the schema and validate
  required keys/patterns in any real `.env`. Refs: P7-3.
- Ops artifacts for the `node-express` variant: a multi-stage `Dockerfile` (`node:22-slim` build ->
  slim non-root runtime running the compiled `dist/server.js`) + `.dockerignore` +
  `docker-compose.yml`, `deploy/` skeletons for Fly/Render/Terraform, and a `.env.schema` reconciled
  key-for-key with `.env.example` and enforced in the gate. `make check` gains a `validate-env` step
  and CI a `Validate env schema` step, both running `scripts/check-env.sh` (copied verbatim from the
  `backend-go` variant) to keep `.env.example` in lockstep with the schema and validate required
  keys/patterns in any real `.env`; `QUALITY_GATE` runs it too. Refs: P7-3.
- Ops artifacts for the `rails` variant: a multi-stage `Dockerfile` (`ruby:3.3-slim` build stage
  running `bundle install` + `rails assets:precompile` -> a slim non-root Puma runtime) +
  `.dockerignore` + `docker-compose.yml` (with commented postgres and redis services), `deploy/`
  skeletons for Fly/Render/Terraform, a new `.env.schema` + key-for-key `.env.example`, and a Rails
  deployment runbook (`docs/ops/deployment.md`, covering `rails db:migrate` as a release step,
  `assets:precompile` and `SECRET_KEY_BASE`). `make check` gains a `validate-env` step and CI a
  `Validate env schema` step, both running `scripts/check-env.sh` (copied verbatim from `backend-go`)
  to keep `.env.example` in lockstep with the schema and validate required keys/patterns in any real
  `.env`; the gate string in `manifest.env` gains the same check. Refs: P7-3.
- Ops artifacts for the `generic` variant: a `Dockerfile` + `.dockerignore` + `docker-compose.yml`,
  `deploy/` skeletons for Fly/Render/Terraform, and a `.env.schema` promoted from `.env.example` and
  enforced in the gate - `make check` runs `scripts/check-env.sh` (a new `validate-env` step) to keep
  `.env.example` in lockstep with the schema and validate required keys/patterns in any real `.env`.
  Refs: P7-3.
- Provider-agnostic CI: every variant now ships a `.gitlab-ci.yml` alongside its GitHub Actions
  workflows, so a scaffolded project runs the same gates on either forge. The pipeline mirrors
  `ci.yml` (a `quality` stage running the variant's gate), the security baseline (a `security`
  stage pulling in GitLab's managed SAST, secret detection and dependency scanning) and adds a
  `deploy` stage. `workflow:` rules run it on merge requests and the protected branches without
  duplicate pipelines. `init` copies the variant's `gitlab/` tree to the project root, the same
  way it copies `github/` to `.github/`. Refs: P7-2.
- Preview-deploy workflows for both forges: `preview-deploy.yml` (GitHub) and the `deploy:preview`
  job (GitLab) stand up an ephemeral preview environment per PR/MR, comment its URL, and tear it
  down on close. Provider-neutral - the environment plumbing is wired and only the deploy step is
  a TODO, so a project points it at its host (Vercel, Netlify, Pages, Fly, ...). Refs: P7-2.
- `doctor --fix` auto-repairs foundation files instead of only reporting them: a missing or
  corrupted (zero-byte) foundation file is rebuilt from the kit, exactly as `init` produced it
  (core copies, the variant's copies, and the templated `CLAUDE.md`/`CONTRIBUTING.md`/`CHANGELOG`
  rendered against the project's own context - name, branches and stamped variant). A zero-byte
  foundation file now counts as a corruption even without `--fix`, so plain `doctor` flags it.
  `doctor --variant <variant>` supplies the stack when the project's `.devblueprint` stamp is the
  file being repaired, so variant-owned files (and the stamp itself) can still be restored. A
  healthy file is never touched, `--json` grows a `fixed` count, and repaired files report
  `(repaired: was missing|empty)`. Refs: P6-5.
- Add-on flavor mechanism for `init`: pass `--flavor <a,b>` to layer orthogonal overlays (a
  database, a container setup, auth scaffolding) onto the chosen base variant. Flavors live under
  `variants/_flavors/<name>/` (a `flavor.env` title, an `overlay/` tree copied into the project,
  and an optional `gitignore.append`), compose with each other, and apply last with the same
  overwrite safety as the base scaffold - so a flavor never clobbers a variant file. The
  selection is validated up front, echoed by `init`/`plan`, recorded in the `.devblueprint` stamp
  (`flavors=...`), and available through `devblueprint list` (and `list --json`) and the intake
  `flavors:` key. Ships `postgres`, `docker` and `auth`. Refs: P6-3.
- Backlog checkbox convention documented in the git-workflow task lifecycle (core-owned, so it
  ships to every scaffolded project) and surfaced as a marker legend in the backlog header and
  the `init` backlog stub: tick a task `- [x]` as soon as its PR is ready to merge, never leave a
  merged task `- [ ]`, and use `- [~]` when a follow-up step remains after the merge.
- Monorepo / multi-variant `init`: pass one or more `--package <name>:<variant>` (mutually
  exclusive with `--variant`) to scaffold several packages in one repo. Shared docs, worktree
  tooling and repo hygiene land once at the root; each package gets its stack overlay and a
  per-package `.devblueprint` stamp under `packages/<name>/`. A generated root `Makefile`
  aggregates every package's own quality gate, and a matrix `.github/workflows/ci.yml` runs each
  package's setup + gate as its own job. Works with `plan`/`--dry-run`. Refs: P6-1.
- Security-gate baseline added to every variant's CI (`variants/*/github/workflows/`): a shared
  `security.yml` (gitleaks secret scan, semgrep SAST, and PR `dependency-review`), a per-language
  `codeql.yml` (skipped for `rust` and `generic`, which have no supported/needed CodeQL target), a
  shared `commit-checks.yml` (commitlint plus a Conventional-Commits PR-title check), and a
  per-language `coverage.yml` that reports line coverage and enforces a soft floor from the
  `COVERAGE_MIN` repository variable (default `0` = report-only, so a fresh scaffold stays green).
  All files ship through the existing `github/` tree copy, so no CLI change was needed. Refs: P6-4.
- Release automation added to every variant's CI (`variants/*/github/`): a shared `release.yml`
  runs [release-please](https://github.com/googleapis/release-please) on each push to `master`,
  maintaining a standing release PR that turns the Conventional-Commits history into a SemVer
  bump, generated `CHANGELOG.md` entries, a git tag and a GitHub Release. A per-variant
  `release-please-config.json` pins the release strategy to the stack's native updater (`go`,
  `python`, `node`, `rust`, `dart`) or `simple` where release-please has none (Gradle, .NET,
  Swift, generic), with `release-please-manifest.json` as the pre-launch `0.0.0` version source
  of truth. Files ship through the existing `github/` tree copy, so no CLI change was needed;
  each variant's quality doc gains a "Release automation" section. Refs: P7-1.
- New `rails` variant: a Ruby on Rails 8 web app built with Bundler, RuboCop
  (`rubocop-rails-omakase`), Brakeman for security scanning, and Minitest. Self-contained under
  `variants/rails/` (manifest, `setup.sh`, Makefile, CI + dependabot, `.tool-versions`, gitignore,
  wt.conf, and the conventions/quality docs), auto-discovered by the CLI. Refs: P6-2d.
- New `dotnet` variant: a C# / .NET 10 backend built with the `dotnet` CLI (SDK pinned in
  `global.json`), `dotnet format`, Roslyn analyzers with warnings-as-errors, and xUnit.
  Self-contained under `variants/dotnet/` (manifest, `setup.sh`, Makefile, CI + dependabot,
  `.tool-versions`, gitignore, wt.conf, and the conventions/quality docs), auto-discovered by
  the CLI. Refs: P6-2c.
- New `laravel` variant: a PHP 8.4 / Laravel web stack built with Composer, Laravel Pint
  (formatting + code style), PHPStan/Larastan (static analysis), and Pest. Self-contained under
  `variants/laravel/` (manifest, `setup.sh`, Makefile, CI + the shared security/commit-checks/
  coverage baseline + dependabot, `.tool-versions`, gitignore, wt.conf, and the conventions/quality
  docs), auto-discovered by the CLI. No `codeql.yml` (CodeQL has no PHP target); semgrep in
  `security.yml` covers PHP SAST. Refs: P6-2e.
- New `elixir-phoenix` variant: an Elixir / Phoenix web stack built with Hex/mix, `mix format`
  (formatting), Credo (style + consistency), Dialyzer (success-typing static analysis), and
  ExUnit. Self-contained under `variants/elixir-phoenix/` (manifest, `setup.sh`, Makefile, CI with
  Erlang/OTP + Elixir setup and PLT caching + the shared security/commit-checks/coverage baseline +
  dependabot, `.tool-versions`, gitignore, wt.conf, and the conventions/quality docs),
  auto-discovered by the CLI. Refs: P6-2g.
- New `terraform-iac` variant: a Terraform Infrastructure-as-Code stack built with the terraform
  CLI, `terraform fmt` (formatting), `terraform validate` (configuration + types), tflint (lint),
  the native `terraform test` framework, and Trivy for IaC misconfiguration scanning. Self-contained
  under `variants/terraform-iac/` (manifest, `setup.sh`, Makefile, CI with Terraform + tflint setup
  + the shared security/commit-checks baseline extended with a Trivy `iac-scan` job + dependabot,
  `.tool-versions`, gitignore, wt.conf, and the conventions/quality docs), auto-discovered by the
  CLI. No `coverage.yml` (Terraform has no line-coverage metric; `terraform test` runs in `ci.yml`).
  Refs: P6-2h.
- New `sveltekit` variant: a TypeScript / SvelteKit web stack built with pnpm, Prettier
  (with `prettier-plugin-svelte`), ESLint + `svelte-check` (linting + type-checking), Vitest
  (unit/component), and Playwright (e2e). Self-contained under `variants/sveltekit/` (manifest,
  `setup.sh`, Makefile, CI + the shared security/commit-checks/coverage baseline + dependabot,
  `.tool-versions`, gitignore, wt.conf, and the conventions/quality docs), auto-discovered by the
  CLI. semgrep in `security.yml` covers SAST. Refs: P6-2f.
- New `flutter` variant: a Flutter/Dart app stack (`dart format`, `flutter analyze` with
  `very_good_analysis` + strict analyzer modes, `flutter test`) with a `lib/`+`lib/src/`+`test/`
  +`integration_test/` scaffold, `Makefile` gate, CI (subosito/flutter-action), and `extras/`
  (`.tool-versions` SDK pin + `.github/dependabot.yml` for pub + github-actions). `setup.sh` wires
  `pubspec.yaml`, `analysis_options.yaml`, `.fvmrc`, a pre-commit config and a placeholder
  `lib/main.dart` + widget test. Refs: P6-2a.
- New `spring-java` variant: a Java 21 + Spring Boot backend built with the Gradle wrapper,
  Spotless (google-java-format), Checkstyle, and JUnit 5. Self-contained under
  `variants/spring-java/` (manifest, `setup.sh`, Makefile, CI + dependabot, `.tool-versions`,
  gitignore, wt.conf, and the conventions/quality docs), auto-discovered by the CLI. Refs: P6-2b.
- `update` now three-way merges managed files instead of overwriting them, so local edits
  survive a re-sync. It caches the last-synced kit copy of each file under
  `.devblueprint-base/` as the merge base (base vs. the project's file vs. the current kit),
  merges an upstream change together with a local edit, and reports a genuine overlap as a
  conflict - keeping both sides with `<<<<<<<` / `>>>>>>>` markers and exiting non-zero.
  When no base is recoverable (an older project updating for the first time) it never clobbers:
  it keeps the local file and seeds the base for the next update. Refs: P5-5.
- `init --agents <list>` wires the multi-agent instruction templates into the CLI: it emits
  `AGENTS.md` (Codex), a Cursor project rule (`.cursor/rules/<project>.mdc`), and Copilot
  instructions (`.github/copilot-instructions.md`) from the same canonical guidance as
  `CLAUDE.md`, for whichever agents you name (default: just `claude`, which is always
  included). The selection is recorded in the `.devblueprint` stamp, and `devblueprint update`
  re-renders the selected files from the current templates so they never drift from
  `CLAUDE.md` - while leaving the user-owned `CLAUDE.md` itself untouched. Refs: P5-3.
- `devblueprint diff --target <dir>`: the read-only precursor to `update`. It reports which
  core-owned files in a scaffolded project have drifted from the current kit - classifying each
  as in sync, `drifted`, or `missing` - without writing anything. The `.devblueprint` stamp is
  the base: its version distinguishes an upstream kit change from a local edit, and its recorded
  variant resolves the two variant-overlaid docs so `--variant` is optional (but still overrides).
  Covered by a new `test/diff.bats`. README and usage updated. Refs: P5-1.
- Kit self-CI: a `scaffold-matrix.yml` workflow scaffolds every variant into a throwaway dir,
  wires it with the variant's `setup.sh`, and runs its quality gate, failing on any red so
  variant rot (a broken scaffold, `setup.sh`, `Makefile` or gate) is caught before a release.
  Variants are discovered dynamically, so a new variant is covered without editing the workflow.
  The per-variant engine is `scripts/scaffold-check.sh` (verifies each scaffold with
  `devblueprint doctor`): variants whose `setup.sh` produces a complete, self-checking starter
  on a toolchain the runner already ships (`generic`, `rust`, `node-express`) run the full gate
  via `doctor --run-gate`; the rest - those that need you to create the real app/package first,
  plus `backend-go` (its gate needs separately-pinned linters) - get a scaffold plus an
  idempotent `setup.sh` check via `doctor --strict`. Refs: P4-3.
- `devblueprint upgrade`: self-update the installed kit in place, with stable/next channels and
  pinning, so `update` targets stay reproducible. `--channel stable` follows the latest GitHub
  release tag; `--channel next` follows `master`; `--version <ver>` pins an exact release and
  freezes it. `--check` (alias `--dry-run`) reports installed vs available without writing;
  `--force` re-applies at the same version. The chosen channel and pin are recorded in a
  kit-local `.channel` file (default channel `stable`). It fetches the target into a staging
  dir and swaps it over the kit root - safe to replace itself mid-run because the old inode
  stays open until exit. It refuses installs it must not touch (a git clone, npm, Homebrew),
  pointing at the right tool for each. Refs: P4-2.
- Static intake config builder: a single, backend-less HTML page
  (`web/config-builder/index.html`) that turns a short form into a
  `.devblueprint-intake.yml`, for users who set the kit up by hand instead of through an
  agent. It runs entirely in the browser - inline CSS/JS, no build step, no dependencies,
  nothing hosted or sent anywhere - honoring the kit's no-runtime principle. The output is
  the same flat `key: value` format the CLI reads, with a live preview plus copy/download.
  The variant dropdown mirrors `devblueprint list` (inlined, since a static page cannot
  query the CLI). README gains a pointer from the intake usage section. Refs: P5-4.
- Multi-agent instruction templates under `core/templates/agents/`: `AGENTS.md.tmpl` (Codex and
  the tool-neutral agentsmd convention), `cursor.mdc.tmpl` (a Cursor project rule with
  `alwaysApply` frontmatter) and `copilot-instructions.md.tmpl` (GitHub Copilot repository
  instructions). All three carry the same canonical workflow guidance as `CLAUDE.md.tmpl` and
  reuse its exact `{{TOKEN}}` set and `{{#TWO_BRANCH}}` / `{{#SINGLE_BRANCH}}` blocks, so the
  process is not Claude-only. Templates only; a `README.md` documents the source-to-target
  mapping. Wiring them into `init`/`update` is P5-3. Refs: P5-2.
- Installability: DevBlueprint now runs without a clone via three channels. A root `package.json`
  exposes `npx devblueprint` through a Node launcher (`packaging/npm/launch.cjs`); a Homebrew
  formula (`packaging/homebrew/devblueprint.rb`) installs the kit into `libexec`; and a
  `curl | sh` installer (`install.sh`) downloads the kit into `~/.devblueprint` and drops a
  `devblueprint` command on `PATH`. All three ship the whole kit and invoke the real
  `bin/devblueprint` by its real path (a launcher/wrapper, never a bare symlink), because the CLI
  resolves `core/` and `variants/` relative to its own path without following symlinks - so the
  CLI internals are untouched. README gains an Install section;
  `packaging/homebrew/README.md` documents the tap and release runbook. Refs: P4-1.
- Machine-readable CLI output: `list`, `doctor` and `version` accept `--json`, so an agent can
  parse state instead of scraping the human tables. `list --json` emits
  `{"variants":[{name,title,gate}]}`; `version --json` emits `{"version":...}`; `doctor --json`
  emits `{ok,target,scaffoldVersion,kitVersion,failures,checks[]}` (each check `{name,status,message}`)
  and still exits non-zero when a check fails. The default human output is unchanged. Values are
  escaped with a dependency-free encoder, so quality gates carrying quotes (e.g. backend-go's
  `test -z "$(gofumpt -l .)"`) stay well-formed JSON. Refs: P3-5.
- `devblueprint detect --target <dir>`: inspect an existing repo's stack fingerprints
  (`package.json`, `go.mod`, `Cargo.toml`, `Package.swift`, `pyproject.toml`) and recommend the
  variant to scaffold from, so adopting the workflow in an existing project needs no guesswork.
  Two fingerprints resolve two variants by a dependency probe - `package.json` -> `web-nextjs`
  when it lists a `next` dependency, else `node-express`; `pyproject.toml` -> `data-python` when
  it names a data-science library, else `backend-python` - and an unrecognized repo falls back to
  `generic`. Read-only: it prints the matching variant and the exact `init` line, never touching
  disk. Refs: P3-7.
- Deploy runbook artifacts for the `backend-python`, `backend-go` and `node-express` variants,
  mirroring P3-4: each ships `extras/docs/ops/deployment.md` (a runbook covering managed/Docker/VPS
  targets with DB and env-var checklists, tailored to the stack) and `extras/.env.example`
  (committed template; real `.env*` stay ignored), copied to project root by the generic extras
  mechanism. Refs: P3-6.
- Intake files + `plan`: `init --from <intake.yml>` seeds the scaffold from a small, documented
  `.devblueprint-intake.yml` (name, variant, main/base branch, community/contact, deploy target),
  mapping keys onto the existing flags. Explicit CLI flags override the file, so a conversation can
  revise a single answer. A new `devblueprint plan` command (equivalently `init --dry-run`) runs
  init's real code path with every write short-circuited to a `would ...` line, printing exactly
  what init would create without touching disk - so an agent can confirm before scaffolding. Ships
  an annotated `agent/intake.example.yml` and `docs/agent/intake-schema.md`. Refs: P3-1.
- `agent/prd-to-backlog.md`: a prompt/skill that turns an uploaded PRD (Markdown/PDF) into a
  pre-filled `.devblueprint-intake.yml` (stack detection, deploy target) so the setup interview
  skips answered questions, and - after `init` - into real P0/P1 tasks in
  `docs/project/backlog.md` plus optional seed ADRs. Documentation only, no CLI. Refs: P3-3.
- Deploy runbook artifacts for the `web-nextjs` and `generic` variants: each ships
  `extras/docs/ops/deployment.md` (a runbook covering managed/Docker/VPS targets with DB and
  env-var checklists) and `extras/.env.example` (committed template; real `.env*` stay ignored),
  copied to project root by the generic extras mechanism. Refs: P3-4.
- Agent-driven setup: a canonical setup interview (`agent/setup-interview.md`) packaged as a
  Claude Code skill (`agent/skills/devblueprint-setup/SKILL.md`, invoked with
  `/devblueprint-setup`). It runs a short, ordered question flow - purpose/name, stack -> variant,
  deploy target, solo vs. team -> branch strategy, license/community - then writes a reproducible
  `.devblueprint-intake.yml`, previews with `plan --from`, and scaffolds with `init --from` on
  confirmation. The agent asks only these questions and never invents scope. Documented in a new
  "Agent-driven setup" section of `GUIDE.md`. Refs: P3-2.
- Config backfill for the `web-nextjs` and `ios-swift` variants: each now ships `.tool-versions`
  (toolchain pin) and `.github/dependabot.yml` (web-nextjs: npm + github-actions; ios-swift: swift
  + github-actions), matching the newer variants. Refs: P2-12.
- `doctor` now checks beyond file existence with two opt-in flags. `--strict` reports the
  project's git state (repo present, current branch, clean/dirty) and escalates the advisory
  pre-commit note to a hard failure, so an unwired scaffold no longer passes. `--run-gate`
  resolves the project's quality gate from the variant recorded in its `.devblueprint` stamp
  (falling back to `make check` when a Makefile is present) and runs it, failing `doctor` when
  the gate is red. The no-flag default is unchanged. Refs: P2-9.
- Config backfill for the `generic` variant: `.github/dependabot.yml` (github-actions enabled, a
  commented template for the project's own language ecosystem) and an `extras/.tool-versions`
  toolchain-pin stub, so language-agnostic projects get dependency automation and a pinned
  toolchain out of the box. Refs: P2-10.
- Config backfill for the `backend-python` variant: `extras/.tool-versions` (Python + uv toolchain
  pin) and `github/dependabot.yml` (pip + github-actions updates), bringing it in line with the
  other variants now that `init` copies `extras/` and `github/` generically. Refs: P2-11.
- New `backend-go` variant: a Go backend stack (gofumpt, golangci-lint, go vet, `go test -race`,
  Go modules) with a `cmd/`+`internal/`+`pkg/` layout, `Makefile` gate, CI, and `extras/`
  (`.tool-versions` toolchain pin + `.github/dependabot.yml` for gomod + actions). `setup.sh`
  wires `go.mod`, `.golangci.yml`, a pre-commit config and a compiling entrypoint. Refs: P2-5.
- New `android-kotlin` variant: an Android app stack (Kotlin + Compose, ktlint, detekt, Android
  Lint, JUnit) built through the Gradle wrapper, with a feature-first `app/src/{main,test,androidTest}`
  scaffold, `Makefile` gate, CI on JDK 17, and `extras/` (`.tool-versions` toolchain pin +
  `.github/dependabot.yml` for gradle + github-actions). Refs: P2-8.
- Generic variant-extras copy: `init` now copies a variant's `github/` tree into `.github/` and
  its root-level `extras/` into the project root recursively, so a variant can ship new config
  (`dependabot.yml`, `renovate.json`, `.tool-versions`, `.devcontainer/`, ...) just by dropping a
  file in - no CLI edit. Both trees keep the existing overwrite safety, and `DEVBLUEPRINT_VARIANTS`
  can point the CLI at an alternate variants dir. Refs: P2-1.
- Variant-author guide in `core/README.md`: how core and variant files layer (a per-file
  source/composition table) and a step-by-step "Adding a variant" walkthrough, including the
  changelog + quality-gate expectations for contributors. Refs: P2-3.
- New `data-python` variant: a data-science stack (uv, ruff, nbqa + nbstripout for notebooks,
  mypy strict over `src/`, pytest) with a `src/`+`notebooks/` split, `data/` scaffold, `Makefile`
  gate, CI, and `extras/` (`.tool-versions` toolchain pin + `.github/dependabot.yml`). Refs: P2-4.
- New `rust` variant: a cargo stack (rustfmt, clippy `pedantic` with warnings denied, `cargo test`)
  with a library-first layout, pinned toolchain (`rust-toolchain.toml` + `.tool-versions`), `Makefile`
  gate, CI, and `extras/` (`.tool-versions` toolchain pin + `.github/dependabot.yml` for cargo).
  Refs: P2-6.
- New `node-express` variant: a typed HTTP API stack (Express + TypeScript strict, ESLint
  type-checked + Prettier, Vitest + supertest, `tsc` build) with a layered
  `src/{routes,middleware,services,lib}` scaffold, a minimal working `/health` app so the gate is
  green from day one, husky + lint-staged pre-commit, `Makefile` gate, CI, and `extras/`
  (`.tool-versions` toolchain pin + `.github/dependabot.yml`). Refs: P2-7.
- ADR scaffolding in `docs/decisions/`: a `README.md` explaining the flow, an `NNNN-template.md`,
  and `0001-record-architecture-decisions.md`; linked from `docs/engineering/conventions.md`.
  Refs: P2-2.
- Optional community-health templates, opt-in via `init --community`: a `SECURITY.md` reporting
  policy and a Contributor Covenant 2.1 `CODE_OF_CONDUCT.md`. `--contact <method>` fills the
  reporting address in both (an `INSERT CONTACT METHOD` placeholder otherwise). Off by default and
  not required by `doctor`. Refs: P1-3.
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
  use a committable `.githooks/pre-commit` via `core.hooksPath`. `doctor` reports whether the
  hook is wired (advisory, since `setup.sh` wires it after `init`), and the bats suite asserts
  `setup.sh` writes an executable `.githooks/pre-commit` and sets `core.hooksPath`. Refs: P1-4.
- GitHub meta shipped with every variant: `core/github/` holds a `pull_request_template.md`
  (mirroring the CONTRIBUTING.md PR checklist) and an `ISSUE_TEMPLATE/` with bug-report and
  feature-request forms plus a `config.yml`. `init` drops them under the project's `.github/`,
  `doctor` verifies the PR template and issue forms landed, and `update` re-syncs them as
  core-owned files. Refs: P1-2.
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

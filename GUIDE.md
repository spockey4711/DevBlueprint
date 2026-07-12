# Guide

The reference for DevBlueprint: every command and flag, what `init` produces, and how to adapt
the workflow to your project. For the pitch and install, see the [README](README.md); new to the
terminal or git, start with [GETTING-STARTED.md](GETTING-STARTED.md).

## Two-minute start

New here and unsure which flags to pass? Just run `bin/devblueprint init` with no arguments.
It starts a guided wizard that explains each question in plain language, suggests a sensible
default for every answer (including where to put the project), shows exactly what it will write,
and only scaffolds once you confirm. The flag form below is the same thing, scripted:

```bash
# 1. Pick a variant
bin/devblueprint list

# 2. Scaffold the engineering setup into a target directory
bin/devblueprint init --target ~/Projects/myapp --name myapp --variant web-nextjs

# 3. Wire the toolchain in one command (configs, pre-commit hook, deps)
cd ~/Projects/myapp
./setup.sh

# 4. Turn the target into a repo with the two long-lived branches
git init
git add -A && git commit -m "chore: scaffold engineering setup from DevBlueprint"
git branch -M master
git switch -c develop

# 5. Start the first task in its own worktree
wt new feat/first-task
```

## Agent-driven setup

Prefer to answer a few questions instead of remembering flags? Open the kit in Claude Code and
run the setup skill:

```
/devblueprint-setup
```

The agent runs a short, ordered interview - purpose and name, stack (mapped to a variant),
deploy target, solo vs. team (branch strategy), and license/community - then writes a
reproducible `.devblueprint-intake.yml`, previews the scaffold with
`devblueprint plan --from .devblueprint-intake.yml`, and on your confirmation runs
`devblueprint init --from .devblueprint-intake.yml`. It asks only those questions and never
invents scope; the intake file is a plain file you own and can re-run or hand-edit.

The skill lives in [`agent/skills/devblueprint-setup/`](agent/skills/devblueprint-setup/SKILL.md)
and the full question flow in [`agent/setup-interview.md`](agent/setup-interview.md). Same
result as the manual `init` above - just conversational.

### Learning the workflow as you go

New to worktrees, small commits, and PRs? After setup, run the mentor skill:

```
/devblueprint-mentor
```

It rides along while you do a task and narrates each step - where you are in git, why we make a
worktree, why commits stay small, why the gate must be green, why the work goes through a PR -
saying **what** to do next and **why**, one step at a time, from your real git state. It runs the
same `wt.sh` / git / `make check` commands you would run anyway; it just explains them, so the
process teaches itself. The skill lives in
[`agent/skills/devblueprint-mentor/`](agent/skills/devblueprint-mentor/SKILL.md) and leans on the
[concept notes](docs/concepts/) for the full reasoning.

## Command reference

The examples use `bin/devblueprint` (the in-clone path); with any install method the command is
just `devblueprint`. Add the repo's `bin/` to your `PATH` to drop the `bin/` prefix. (Add the
directory to `PATH` rather than symlinking the script - the CLI locates `core/` and `variants/`
relative to its own real path, so a bare symlink would not resolve them. The install methods in
the [README](README.md) handle this for you with a wrapper.)

### Scaffold and inspect

```bash
# See the variants
bin/devblueprint list

# Adding the workflow to an existing repo? Let detect recommend the variant from its stack
# fingerprints (package.json, go.mod, Cargo.toml, Package.swift, pyproject.toml)
bin/devblueprint detect --target ~/Projects/myapp

# Scaffold a new project's engineering setup
bin/devblueprint init --target ~/Projects/myapp --name myapp --variant web-nextjs

# Preview exactly what init would create, without touching disk (plan is init --dry-run)
bin/devblueprint plan --target ~/Projects/myapp --variant web-nextjs
```

`init` is overwrite-safe: it never clobbers an existing file unless you pass `--force`, so you
can run it on an existing repo to add the workflow without losing your code.

Options: `--target <dir>` `--name <name>` `--variant <variant>` `--package <name>:<variant>`
`--flavor <list>` `--main <branch>` `--base <branch>` `--agents <list>` `--community`
`--contact <method>` `--force`. Use `--base master` for a single-branch trunk workflow, and
`--community` to add optional `SECURITY.md`, `CODE_OF_CONDUCT.md` (with `--contact` filling the
reporting address in both) and a `.github/CODEOWNERS` review-routing file. Every project also
ships `scripts/protect-branches.sh`, an opt-in `gh api` helper that applies GitHub branch
protection to the long-lived branches so the documented workflow is technically enforced (see
[`docs/engineering/git-workflow.md`](docs/engineering/git-workflow.md)).

### Verify a project: `doctor`

```bash
# Before anything else: check your machine has the prerequisites (git, Node, a shell).
# Needs no project - prints a per-OS copy-paste install command for whatever is missing.
bin/devblueprint doctor --env

# Verify the foundation files landed (reports the kit version it was scaffolded from)
bin/devblueprint doctor --target ~/Projects/myapp

# Go further: --strict also checks git state and that the pre-commit hook is wired;
# --run-gate runs the project's quality gate (resolved from its variant)
bin/devblueprint doctor --target ~/Projects/myapp --strict --run-gate

# --fix auto-repairs any missing or corrupted (empty) foundation file from the kit
# instead of only reporting it. Pass --variant when the .devblueprint stamp is the
# file being repaired, so variant-owned files (and the stamp) can be rebuilt too.
bin/devblueprint doctor --target ~/Projects/myapp --fix
bin/devblueprint doctor --target ~/Projects/myapp --fix --variant node-express
```

### Keep a project current: `diff`, `update`, `upgrade`

```bash
# See where a project has drifted from the current kit before updating (read-only)
bin/devblueprint diff --target ~/Projects/myapp

# Pull core changes into an existing project (preview with --dry-run)
bin/devblueprint update --target ~/Projects/myapp

# Or, with no flags, a guided drift check that previews and re-syncs on confirm
bin/devblueprint update

# Self-update the installed kit. `stable` follows the latest release, `next` follows
# master; `--version <ver>` pins an exact release so `update` stays reproducible.
# `--check` reports what an upgrade would do without writing.
bin/devblueprint upgrade --check
bin/devblueprint upgrade --channel stable

# Print the kit version
bin/devblueprint version
```

`update` re-syncs only the core-owned files (the agnostic engineering docs, `.editorconfig`,
`.gitattributes`, `scripts/wt.sh`, and the GitHub PR/issue templates) so old projects pick up
improvements to `core/`, and deliberately never touches your `CLAUDE.md`, `wt.conf`, CI or code.
Pass `--variant <name>` to also refresh the variant-overlaid `conventions.md` and
`quality-and-testing.md`, and `--dry-run` to preview the changes first.

Your local edits to those managed files are preserved with a three-way merge rather than
overwritten. `update` keeps a `.devblueprint-base/` cache of the last-synced kit copy of each
file as the merge base; when a re-sync brings both an upstream change and a local edit, the two
are merged, and only a genuine overlap is reported as a conflict (both sides kept with standard
`<<<<<<<` / `>>>>>>>` markers to resolve, and a non-zero exit so scripts notice). Commit the
`.devblueprint-base/` cache so a teammate who pulls shares the same merge base.

`diff` is the read-only precursor to `update`: it reports which core-owned files have drifted
from the current kit - marking each in sync, `drifted`, or `missing` - so you can see what
`update` would touch without writing anything. It reads the `.devblueprint` stamp as the base:
the stamped version says whether the kit has advanced since you scaffolded (so drift may be an
upstream change to pull) or matches (so drift is a local edit), and the stamped variant is used
to compare the two overlaid docs automatically (`--variant <name>` overrides it).

### Machine-readable output for agents

`list`, `doctor` and `version` take `--json`. `list --json` yields the variants (name, title,
quality gate); `doctor --json` yields `{ok, failures, fixed, checks[], scaffoldVersion,
kitVersion}` and still exits non-zero when a check fails - so an agent parses state instead of
scraping text.

```bash
bin/devblueprint list --json
bin/devblueprint doctor --target ~/Projects/myapp --json
```

## What `init` produces

Into the target directory:

```
CLAUDE.md                          workflow + standards for AI assistants (and you)
CONTRIBUTING.md                    the short contributor guide
CHANGELOG.md                       fresh, Keep-a-Changelog format
.devblueprint                      scaffold stamp: kit version + variant (for `update`)
.gitignore                         stack-appropriate
.editorconfig                      stack-agnostic editor baseline (charset, LF, indent)
.gitattributes                     stack-agnostic line-ending normalization
.vscode/extensions.json            recommended VS Code extensions for the stack
.github/workflows/ci.yml           the quality gate in CI
.github/pull_request_template.md   the PR checklist, prefilled on every PR
.github/ISSUE_TEMPLATE/            bug-report + feature-request forms (and config)
Makefile                           (generic variant only) gate targets to fill in
setup.sh                           one-shot toolchain wiring (configs, hooks, deps)
scripts/wt.sh                      the worktree manager
scripts/wt.conf                    branches + post-create install hook for the stack
docs/engineering/
  git-workflow.md                  branching, worktrees, commits, PRs, releases
  engineering-standards.md         the mindset
  conventions.md                   shared baseline + the stack overlay
  quality-and-testing.md           the concrete gate + testing strategy
docs/project/backlog.md            a stub task list
src/... tests/...                  the source/test skeleton for the stack
```

Everything is a plain file you own. Edit freely - DevBlueprint is not a dependency.

### Monorepos

Pass one or more `--package <name>:<variant>` (instead of a single `--variant`) to scaffold a
**monorepo**: the shared docs, worktree tooling and repo hygiene land once at the root, while
each package gets its own stack overlay and `.devblueprint` stamp under `packages/<name>/`.

```bash
bin/devblueprint init --target ~/Projects/shop \
  --package api:backend-python --package web:web-nextjs
```

The root `Makefile`'s `check` target runs every package's own quality gate in turn, and a
generated `.github/workflows/ci.yml` runs each package's setup + gate as its own matrix job.
`--package` is mutually exclusive with `--variant` and `--flavor`, and works with `plan` /
`--dry-run` like any other init.

### Add-on flavors

Need a database, a container setup or auth? Pass `--flavor` to layer orthogonal **add-on
flavors** onto the base variant - each drops in its own config plus a `docs/flavors/<name>.md`
note explaining how to wire it:

```
--flavor postgres     docker-compose.yml (a local Postgres) + a setup note
--flavor docker        .dockerignore + a Dockerfile skeleton note
--flavor auth          .gitignore rules for secrets + an auth security note
```

Combine them in one comma-separated list (`--flavor postgres,docker`). Flavors layer on last,
after the base variant, with the same overwrite safety (a flavor never clobbers a variant file),
and the selection is recorded in `.devblueprint`. Run `bin/devblueprint list` for the current
set. `--flavor` is mutually exclusive with the monorepo `--package` mode.

### Instruction files for other agents

Working with more than one coding agent? Pass `--agents` to emit instruction files for them
alongside `CLAUDE.md`, all rendered from the same canonical guidance:

```
--agents cursor       .cursor/rules/<project>.mdc     a Cursor project rule
--agents codex        AGENTS.md                       the tool-neutral agents.md convention
--agents copilot      .github/copilot-instructions.md GitHub Copilot repository instructions
```

Combine them in one comma-separated list (`--agents claude,cursor,codex`). `claude` is always
included, so the default is `CLAUDE.md` only. The choice is recorded in `.devblueprint`, and
`devblueprint update` re-renders the selected files so they stay in step with `CLAUDE.md`.

### Community-health files

Pass `--community` to also drop in two optional community-health files:

```
SECURITY.md                        how to report a vulnerability privately
CODE_OF_CONDUCT.md                 Contributor Covenant 2.1
```

`--contact <method>` fills the reporting address in both (an email or a URL); without it they
carry an `INSERT CONTACT METHOD` placeholder for you to replace. These are off by default and are
not required by `doctor`.

## Intake files and `plan`

Instead of remembering a line of flags, capture the answers once in a
`.devblueprint-intake.yml` intake file - a flat `key: value` map of name, variant,
main/base branch, community/contact and deploy target. Preview it, then apply it:

```bash
# Print exactly what init would create, without touching disk:
bin/devblueprint plan --target ~/Projects/myapp --from .devblueprint-intake.yml

# Apply it once the plan looks right:
bin/devblueprint init --target ~/Projects/myapp --from .devblueprint-intake.yml
```

Explicit CLI flags override the file, so you can revise one answer without editing
it: `init --from .devblueprint-intake.yml --base master`. `plan` is exactly
`init --dry-run`, so the preview can never drift from what init writes. This is the
interface an agent uses to set a project up conversationally: interview the user,
write the intake file, `plan` to confirm, then `init --from`. See the annotated
[`agent/intake.example.yml`](agent/intake.example.yml) and the schema reference in
[`docs/agent/intake-schema.md`](docs/agent/intake-schema.md).

Prefer a form to hand-writing the intake file? Open
[`web/config-builder/index.html`](web/config-builder/index.html) - a self-contained,
backend-less page that generates a `.devblueprint-intake.yml` in the browser. Nothing is
hosted or sent anywhere.

The `setup.sh` is the automated version of each variant's "After init" checklist: it patches
the package manifest, writes the tool configs, installs a pre-commit hook and pulls the dev
toolchain. It is idempotent and never clobbers existing files, so it is safe to re-run. A few
things it deliberately leaves to you (they cannot be guessed): scaffolding the app framework
itself (`create-next-app`, the Xcode project), and filling the generic `Makefile` targets.

## The workflow in one page

1. **One worktree per task.** `wt new feat/thing` branches off `develop` into its own
   directory. The main clone stays on `master`, so parallel sessions never collide.
2. **Small commits**, Conventional Commits, each building green.
3. **Quality gate** before pushing (the four commands in your quality-and-testing doc).
4. **PR into `develop`**, reviewed, merged with a merge commit. `wt gc` cleans the worktree.
5. **Release** by promoting `develop` -> `master` via a PR every few days.

Full detail lands in the target project's `docs/engineering/git-workflow.md`.

## Adapting

- **Solo / lightweight:** run `init --base master` for a single-branch trunk workflow (still
  worktrees, still PRs, still the gate). Or keep both branches but skip the dev auto-deploy.
- **Existing repo:** run `devblueprint detect --target <dir>` first - it reads the repo's
  stack fingerprints (`package.json`, `go.mod`, `Cargo.toml`, `Package.swift`, `pyproject.toml`)
  and recommends the variant to pass to `init`, so adopting the workflow needs no guesswork.
  `init` is overwrite-safe, so it adds the workflow without touching your code.
- **Open source / collaborative:** add `--community --contact <email-or-url>` to scaffold
  `SECURITY.md` and a Contributor Covenant `CODE_OF_CONDUCT.md`.
- **Add a stack:** copy an existing folder under `variants/`, adjust `manifest.env`, `wt.conf`,
  `docs/quality-and-testing.md`, `docs/conventions.append.md`, `variant-notes.md`, the CI
  workflow and `.gitignore`. It shows up in `devblueprint list` automatically.
- **Change the shared workflow once, everywhere:** edit `core/`. New projects pick it up at
  their next `init`; existing projects pull it in with `devblueprint update` (see
  [Keep a project current](#keep-a-project-current-diff-update-upgrade) above for the
  three-way-merge and drift details).

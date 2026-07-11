# DevBlueprint

A reusable engineering setup for new projects: the git workflow, quality bar, code conventions
and AI-assistant guidance, extracted from a real production-grade codebase and made
stack-agnostic. One command scaffolds a project with a professional process from commit one.

It is **documentation-first** - the output is plain files you own and edit, not a framework you
depend on. There is no runtime, no lock-in; delete DevBlueprint afterwards and nothing breaks.

## What you get

- **A git workflow that scales to parallel AI sessions.** Two long-lived branches
  (`develop` -> `master`) and one worktree per task, so several assistant chats work at once
  without ever changing each other's branch. Driven by a single `wt` script.
- **A quality gate.** lint + typecheck + test + build, wired to your stack, enforced locally
  (pre-commit) and in CI (GitHub Actions), with a clear definition of done.
- **Conventions and an engineering-standards mindset** that keep a solo repo at team quality.
- **A `CLAUDE.md`** that teaches an AI assistant the whole workflow up front.

## The pieces

```
devblueprint/
  core/              tech-agnostic source of truth (copied into every project)
    git-workflow.md  engineering-standards.md  conventions.md  quality-and-testing.md
    .editorconfig    .gitattributes    (stack-agnostic repo hygiene)
    templates/       CLAUDE.md + CONTRIBUTING.md templates ({{TOKENS}} filled at init)
    github/          PR template + issue templates (shipped with every variant)
  scripts/wt.sh      the worktree manager (parametrized via scripts/wt.conf)
  variants/          stack overlays: web-nextjs, ios-swift, backend-python, generic
  bin/devblueprint   the CLI: list / init / plan / update / doctor / detect / version
  agent/             agent-facing specs: intake.example.yml (see docs/agent/)
  VERSION            the kit version, stamped into every scaffold
```

Each **variant** adds only what is stack-specific: the concrete quality-gate commands, CI
workflows for both GitHub Actions and GitLab CI (`.gitlab-ci.yml`) plus a provider-neutral
preview-deploy, a `.gitignore`, a `wt.conf` (branches + post-create install hook), a conventions
overlay, the `CLAUDE.md` stack-notes block, and a `setup.sh` that wires the toolchain (tool
configs, pre-commit hook, dependency install) in one command after `init`.

## Install

Pick one - all three ship the whole kit, so `devblueprint` runs without a clone.

```bash
# 1. npx (no install; needs Node)
npx devblueprint list

# 2. Homebrew (macOS / Linux)
brew install spockey4711/devblueprint/devblueprint

# 3. curl | sh - installs into ~/.devblueprint and drops a `devblueprint` on your PATH
curl -fsSL https://raw.githubusercontent.com/spockey4711/DevBlueprint/master/install.sh | sh
```

The installer honours `DEVBLUEPRINT_PREFIX` (kit location), `DEVBLUEPRINT_BIN` (where the
command lands) and `DEVBLUEPRINT_VERSION` (git ref) if you want to override the defaults.

Prefer a clone? `git clone` the repo and run `bin/devblueprint` directly. Maintainers: see
[`packaging/homebrew/README.md`](packaging/homebrew/README.md) for the tap and release runbook.

The examples below use `bin/devblueprint` (the in-clone path); with any install method above the
command is just `devblueprint`.

## Usage

```bash
# See the variants
bin/devblueprint list

# Adding the workflow to an existing repo? Let detect recommend the variant from
# its stack fingerprints (package.json, go.mod, Cargo.toml, Package.swift, pyproject.toml)
bin/devblueprint detect --target ~/Projects/myapp

# Scaffold a new project's engineering setup
bin/devblueprint init --target ~/Projects/myapp --name myapp --variant web-nextjs

# Or a monorepo: one repo, several packages, each its own stack and quality gate,
# with an aggregated CI workflow and a root `make check` that runs every package's gate.
bin/devblueprint init --target ~/Projects/shop --package api:backend-python --package web:web-nextjs

# Or capture the answers in an intake file and preview before writing anything.
# `plan` prints exactly what init would create; `init --from` then applies it.
# (Explicit flags still override the file, e.g. add --base master.)
bin/devblueprint plan --target ~/Projects/myapp --from .devblueprint-intake.yml
bin/devblueprint init --target ~/Projects/myapp --from .devblueprint-intake.yml

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

# See where a project has drifted from the current kit before updating (read-only)
bin/devblueprint diff --target ~/Projects/myapp

# Later, pull core changes into an existing project (preview with --dry-run)
bin/devblueprint update --target ~/Projects/myapp

# Self-update the installed kit. `stable` follows the latest release, `next` follows
# master; `--version <ver>` pins an exact release so `update` stays reproducible.
# `--check` reports what an upgrade would do without writing.
bin/devblueprint upgrade --check
bin/devblueprint upgrade --channel stable

# Print the kit version
bin/devblueprint version

# Machine-readable output for agents: `list`, `doctor` and `version` take --json.
# `list --json` yields the variants (name, title, quality gate); `doctor --json`
# yields {ok, failures, fixed, checks[], scaffoldVersion, kitVersion} and still exits
# non-zero when a check fails - so an agent parses state instead of scraping text.
bin/devblueprint list --json
bin/devblueprint doctor --target ~/Projects/myapp --json
```

Add the repo's `bin/` to your `PATH` to drop the `bin/` prefix. (Add the directory to `PATH`
rather than symlinking the script - the CLI locates `core/` and `variants/` relative to its own
real path, so a bare symlink would not resolve them. The install methods above handle this for
you with a wrapper.)

`init` is overwrite-safe: it never clobbers an existing file unless you pass `--force`, so you
can run it on an existing repo to add the workflow without losing your code.

Pass one or more `--package <name>:<variant>` (instead of a single `--variant`) to scaffold a
**monorepo**: the shared docs, worktree tooling and repo hygiene land once at the root, while
each package gets its own stack overlay and `.devblueprint` stamp under `packages/<name>/`. The
root `Makefile`'s `check` target runs every package's own quality gate in turn, and a generated
`.github/workflows/ci.yml` runs each package's setup + gate as its own matrix job. `--package`
is mutually exclusive with `--variant`, and works with `plan`/`--dry-run` like any other init.

Pass `--flavor <a,b>` to layer orthogonal **add-on flavors** onto the base variant - a database,
a container setup, auth scaffolding. Each flavor drops in its own files (config plus a
`docs/flavors/<name>.md` note) with the same overwrite safety as the base scaffold, so a flavor
never clobbers a variant's file. Flavors compose (`--flavor postgres,docker`) and are recorded
in the `.devblueprint` stamp. See `devblueprint list` for the available set; `--flavor` is
mutually exclusive with `--package`.

`update` is the counterpart for projects already scaffolded: it re-syncs only the core-owned
files (the agnostic engineering docs, `.editorconfig`, `.gitattributes`, `scripts/wt.sh`, and
the GitHub PR/issue templates) so old projects pick up improvements to `core/`, and
deliberately never touches your `CLAUDE.md`, `wt.conf`, CI or code. Pass
`--variant <name>` to also refresh the variant-overlaid `conventions.md` and
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

Options: `--target <dir>` `--name <name>` `--variant <variant>` `--package <name>:<variant>`
`--flavor <list>` `--main <branch>` `--base <branch>` `--agents <list>` `--community`
`--contact <method>` `--force`. Use
`--base master` for a single-branch trunk workflow, and `--community` to add optional
`SECURITY.md`, `CODE_OF_CONDUCT.md` (with `--contact` filling the reporting address in
both) and a `.github/CODEOWNERS` review-routing file. Every project also ships
`scripts/protect-branches.sh`, an opt-in `gh api` helper that applies GitHub branch
protection to the long-lived branches so the documented workflow is technically enforced
(see [`docs/engineering/git-workflow.md`](docs/engineering/git-workflow.md)). Pass
`--agents claude,cursor,codex,copilot` (default: just `claude`) to also emit
instruction files for other coding agents - `AGENTS.md` (Codex), a Cursor project rule, and
Copilot instructions - rendered from the same canonical guidance as `CLAUDE.md`; `update`
re-renders whichever were selected so they never drift.

Prefer a form to hand-writing the intake file? Open
[`web/config-builder/index.html`](web/config-builder/index.html) - a self-contained,
backend-less page that generates a `.devblueprint-intake.yml` in the browser. Nothing is
hosted or sent anywhere.

## Variants

| Variant          | Stack                                   | Quality gate |
| ---------------- | --------------------------------------- | ------------ |
| `web-nextjs`     | Next.js, TypeScript, Tailwind, pnpm     | `pnpm lint && pnpm typecheck && pnpm test && pnpm build` |
| `backend-python` | Python, FastAPI-style, uv               | `ruff check . && ruff format --check . && mypy . && pytest` |
| `ios-swift`      | Swift/SwiftUI, SwiftFormat + SwiftLint  | `swiftformat --lint . && swiftlint --strict && swift build && swift test` |
| `generic`        | language-agnostic (Makefile gate)       | `make check` |

See [`GUIDE.md`](GUIDE.md) for the full walkthrough and [`core/`](core/README.md) for the
shared docs.

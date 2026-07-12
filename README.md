# DevBlueprint

**Parallel Claude Code agents on one repo, without collisions.**

Point a second coding agent (Claude or any other) at the same project and the two clobber each
other's branches and half-finished work. DevBlueprint removes that collision: two long-lived
branches (`develop` -> `master`) and one git worktree per task, so every agent works in isolation
and integrates through a PR. One command sets up this whole professional workflow - git flow,
quality gate, conventions and AI-assistant guidance - from commit one.

Extracted from a real production-grade codebase and made stack-agnostic. It is
**documentation-first** - the output is plain files you own and edit, not a framework you depend
on. There is no runtime, no lock-in; delete DevBlueprint afterwards and nothing breaks.

> **New to the terminal, git or programming?** Start with
> [**GETTING-STARTED.md**](GETTING-STARTED.md) - a plain-language walkthrough from nothing
> installed to your first pull request. The rest of this README assumes you are already fluent.

## What you get

- **A git workflow that scales to parallel AI sessions.** Two long-lived branches
  (`develop` -> `master`) and one worktree per task, so several assistant chats work at once
  without ever changing each other's branch. Driven by a single `wt` script.
- **A quality gate.** lint + typecheck + test + build, wired to your stack, enforced locally
  (pre-commit) and in CI (GitHub Actions), with a clear definition of done.
- **Conventions and an engineering-standards mindset** that keep a solo repo at team quality.
- **A `CLAUDE.md`** that teaches an AI assistant the whole workflow up front.
- **A zero-install path.** Every variant (except ios-swift) ships a `.devcontainer`, so the
  scaffolded project opens in GitHub Codespaces or a local Dev Container with the toolchain and
  extensions ready - no local install. See [`docs/codespaces.md`](docs/codespaces.md).

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
overlay, the `CLAUDE.md` stack-notes block, a `setup.sh` that wires the toolchain (tool
configs, pre-commit hook, dependency install) in one command after `init`, and editor/cloud
config (`.vscode/`, and a `.devcontainer/` for the zero-install Codespaces path).

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

## Usage at a glance

The examples use `bin/devblueprint` (the in-clone path); with any install method above the
command is just `devblueprint`.

```bash
# See the variants, then scaffold a project's engineering setup
bin/devblueprint list
bin/devblueprint init --target ~/Projects/myapp --name myapp --variant web-nextjs

# Adding the workflow to an existing repo? Let detect recommend the variant from its stack
bin/devblueprint detect --target ~/Projects/myapp

# Check your machine has the prerequisites, then that the foundation files landed
bin/devblueprint doctor --env
bin/devblueprint doctor --target ~/Projects/myapp

# Later, pull core improvements into an existing project (preview with --dry-run)
bin/devblueprint update --target ~/Projects/myapp
```

`init` is overwrite-safe - it never clobbers an existing file unless you pass `--force` - so you
can run it on an existing repo to add the workflow without losing your code.

That is the shape of it. The full command reference - every flag, monorepo and add-on flavors,
instruction files for other coding agents, intake files and the browser config-builder, and how
to adapt the workflow to your project - lives in [`GUIDE.md`](GUIDE.md).

## Variants

| Variant          | Stack                                   | Quality gate |
| ---------------- | --------------------------------------- | ------------ |
| `web-nextjs`     | Next.js, TypeScript, Tailwind, pnpm     | `pnpm lint && pnpm typecheck && pnpm test && pnpm build` |
| `backend-python` | Python, FastAPI-style, uv               | `ruff check . && ruff format --check . && mypy . && pytest` |
| `ios-swift`      | Swift/SwiftUI, SwiftFormat + SwiftLint  | `swiftformat --lint . && swiftlint --strict && swift build && swift test` |
| `generic`        | language-agnostic (Makefile gate)       | `make check` |

See [`GUIDE.md`](GUIDE.md) for the full walkthrough and [`core/`](core/README.md) for the
shared docs.

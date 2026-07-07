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

Each **variant** adds only what is stack-specific: the concrete quality-gate commands, a CI
workflow, a `.gitignore`, a `wt.conf` (branches + post-create install hook), a conventions
overlay, the `CLAUDE.md` stack-notes block, and a `setup.sh` that wires the toolchain (tool
configs, pre-commit hook, dependency install) in one command after `init`.

## Usage

```bash
# See the variants
bin/devblueprint list

# Adding the workflow to an existing repo? Let detect recommend the variant from
# its stack fingerprints (package.json, go.mod, Cargo.toml, Package.swift, pyproject.toml)
bin/devblueprint detect --target ~/Projects/myapp

# Scaffold a new project's engineering setup
bin/devblueprint init --target ~/Projects/myapp --name myapp --variant web-nextjs

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

# Later, pull core changes into an existing project (preview with --dry-run)
bin/devblueprint update --target ~/Projects/myapp

# Print the kit version
bin/devblueprint version
```

Add DevBlueprint to your `PATH` (or symlink `bin/devblueprint`) to drop the `bin/` prefix.

`init` is overwrite-safe: it never clobbers an existing file unless you pass `--force`, so you
can run it on an existing repo to add the workflow without losing your code.

`update` is the counterpart for projects already scaffolded: it re-syncs only the core-owned
files (the agnostic engineering docs, `.editorconfig`, `.gitattributes`, `scripts/wt.sh`, and
the GitHub PR/issue templates) so old projects pick up improvements to `core/`, and
deliberately never touches your `CLAUDE.md`, `wt.conf`, CI or code. Pass
`--variant <name>` to also refresh the variant-overlaid `conventions.md` and
`quality-and-testing.md`, and `--dry-run` to preview the changes first.

Options: `--target <dir>` `--name <name>` `--variant <variant>` `--main <branch>`
`--base <branch>` `--community` `--contact <method>` `--force`. Use `--base master` for a
single-branch trunk workflow, and `--community` to add optional `SECURITY.md` and
`CODE_OF_CONDUCT.md` (with `--contact` filling the reporting address in both).

## Variants

| Variant          | Stack                                   | Quality gate |
| ---------------- | --------------------------------------- | ------------ |
| `web-nextjs`     | Next.js, TypeScript, Tailwind, pnpm     | `pnpm lint && pnpm typecheck && pnpm test && pnpm build` |
| `backend-python` | Python, FastAPI-style, uv               | `ruff check . && ruff format --check . && mypy . && pytest` |
| `ios-swift`      | Swift/SwiftUI, SwiftFormat + SwiftLint  | `swiftformat --lint . && swiftlint --strict && swift build && swift test` |
| `generic`        | language-agnostic (Makefile gate)       | `make check` |

See [`GUIDE.md`](GUIDE.md) for the full walkthrough and [`core/`](core/README.md) for the
shared docs.

# Core (tech-agnostic)

The part of the blueprint that is identical for every project, regardless of language or stack.
`devblueprint init` copies these into a new project's `docs/engineering/` and fills in the
templates; a variant only adds stack-specific detail on top.

| File                                             | What it is                                             |
| ------------------------------------------------ | ------------------------------------------------------ |
| [`git-workflow.md`](git-workflow.md)             | Branching (develop/master), worktrees, commits, PRs, releases |
| [`engineering-standards.md`](engineering-standards.md) | The mindset: how to work, design principles, the bar  |
| [`conventions.md`](conventions.md)               | Shared code-style baseline (a variant appends its overlay) |
| [`quality-and-testing.md`](quality-and-testing.md) | The shape of the quality gate + definition of done    |
| [`templates/CLAUDE.md.tmpl`](templates/CLAUDE.md.tmpl) | AI-assistant guidance, filled in per project      |
| [`templates/CONTRIBUTING.md.tmpl`](templates/CONTRIBUTING.md.tmpl) | Short contributor guide, filled in per project |
| [`.editorconfig`](.editorconfig)                 | Stack-agnostic editor baseline (charset, LF, final newline, indent) |
| [`.gitattributes`](.gitattributes)               | Stack-agnostic line-ending normalization + binary-type hints |
| [`github/`](github/)                             | GitHub PR template + issue templates (stack-agnostic, ship with every variant) |

The `github/` files are copied verbatim (no tokens): `pull_request_template.md` mirrors the
CONTRIBUTING.md PR checklist, and `ISSUE_TEMPLATE/` holds a bug-report and feature-request form
plus a `config.yml`. `init` drops them under the project's `.github/`.

Templates use `{{TOKENS}}` (`PROJECT_NAME`, `MAIN_BRANCH`, `BASE_BRANCH`, `WT_CMD`,
`QUALITY_GATE`, `COPY_LANGUAGE_NOTE`, `VARIANT_NOTES`) that the CLI substitutes at init time.

Templates also carry two conditional workflow blocks, each delimited by markers on their own
lines:

```
{{#TWO_BRANCH}} ... {{/TWO_BRANCH}}        kept for the staged develop -> master flow
{{#SINGLE_BRANCH}} ... {{/SINGLE_BRANCH}}  kept for a trunk flow (init'd with base == main)
```

`init` keeps whichever block matches the chosen workflow (single-branch when
`BASE_BRANCH == MAIN_BRANCH`, e.g. `--base master`) and drops the other, so the prose never
reads "`master` is promoted ... to `master`".

`.editorconfig` and `.gitattributes` are copied to the project root (not `docs/engineering/`);
they carry no per-project or per-variant content, so `init` drops them in and `update` keeps
them in sync like the other core-owned files.

`devblueprint update --target <dir>` re-syncs the project-independent core files
(`git-workflow.md`, `engineering-standards.md`, `.editorconfig`, `.gitattributes`,
`scripts/wt.sh`, and the `github/` PR/issue templates) into a project scaffolded earlier, so
edits here reach old projects too. It leaves the rendered templates (`CLAUDE.md`,
`CONTRIBUTING.md`) and `wt.conf` alone; `conventions.md` and `quality-and-testing.md` are
refreshed only when `update` is given a `--variant`, since they carry a variant overlay.

## How core and variant files layer

Every scaffolded file comes from `core/` (this directory - identical for all projects) or from
the chosen `variants/<name>/` (stack-specific), composed in one of four ways:

| Project file                          | Source                | Composition                                    |
| ------------------------------------- | --------------------- | ---------------------------------------------- |
| `docs/engineering/git-workflow.md`, `engineering-standards.md` | core | copied verbatim                     |
| `.editorconfig`, `.gitattributes`, `.github/` PR + issue templates | core | copied verbatim (project root / `.github/`) |
| `docs/engineering/conventions.md`     | core **+** variant    | core base, then `docs/conventions.append.md` appended |
| `docs/engineering/quality-and-testing.md` | variant           | variant-owned (the concrete gate)              |
| `CLAUDE.md`, `CONTRIBUTING.md`         | core template         | rendered, drawing `QUALITY_GATE` / `WT_CMD` / `COPY_LANGUAGE_NOTE` from the variant's `manifest.env` and `VARIANT_NOTES` from its `variant-notes.md` |
| `.github/workflows/ci.yml`, `.gitignore`, `setup.sh`, `Makefile` (optional), `scripts/wt.conf` | variant | copied from the variant |
| `scripts/wt.sh`                        | repo root             | shared worktree manager (same for all variants) |

The rule of thumb: **core carries anything true regardless of language; a variant only adds
stack-specific detail on top.** If something you want to change is identical across stacks, it
belongs in `core/` (and reaches old projects via `update`); if it differs per stack, it belongs
in the variant.

## Adding a variant

A variant is a self-contained `variants/<name>/` directory, auto-discovered by the CLI - no code
change needed. `devblueprint list` finds any directory here that has a `manifest.env`, so that
file is the discovery contract.

1. Copy the closest existing variant as a starting point:
   `cp -r variants/generic variants/<name>` (or `backend-python` for a typed-language stack).
2. Edit `manifest.env` - `VARIANT_TITLE` (shown in `devblueprint list`), `QUALITY_GATE`,
   `WT_CMD`, `COPY_LANGUAGE_NOTE`, `SRC_DIRS`. These feed the token substitution above.
3. `docs/quality-and-testing.md` - the concrete quality gate and testing strategy (variant-owned,
   replaces the core stub).
4. `docs/conventions.append.md` - the stack overlay appended to the core conventions baseline.
5. `variant-notes.md` - the "Stack notes" block injected into the scaffolded `CLAUDE.md`.
6. `wt.conf` - the worktree post-create hook (`wt_post_create`, e.g. `uv sync`, `pnpm install`).
7. `github/workflows/ci.yml` - CI running the gate; `gitignore` - stack ignores;
   `setup.sh` - idempotent toolchain wiring; `Makefile` - optional (generic only).
8. `README.md` - the variant's own one-page doc (quality gate, what `init` adds, after-init steps).

Then smoke-test the new variant:

```bash
bin/devblueprint list                                          # your variant appears
bin/devblueprint init --target /tmp/probe --name probe --variant <name>
bin/devblueprint doctor --target /tmp/probe                    # scaffold is complete
```

**Land it like production code.** Every change to `core/` or a variant ships in the same PR as a
one-line entry under `## [Unreleased]` in `CHANGELOG.md`, and must pass the quality gate before
pushing:

```bash
make check   # bash -n + shellcheck on every script, plus the bats CLI suite
```

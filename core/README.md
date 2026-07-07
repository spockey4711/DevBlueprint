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
(`git-workflow.md`, `engineering-standards.md`, `.editorconfig`, `.gitattributes`, and
`scripts/wt.sh`) into a project scaffolded earlier, so edits here reach old projects too. It
leaves the rendered templates (`CLAUDE.md`, `CONTRIBUTING.md`) and `wt.conf` alone;
`conventions.md` and `quality-and-testing.md` are refreshed only when `update` is given a
`--variant`, since they carry a variant overlay.

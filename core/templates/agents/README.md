# Multi-agent instruction templates

These templates carry the **same canonical workflow guidance** as
[`../CLAUDE.md.tmpl`](../CLAUDE.md.tmpl), rendered into the formats other coding agents read, so
the DevBlueprint process is not Claude-only. They use the identical `{{TOKEN}}` set and
`{{#TWO_BRANCH}}` / `{{#SINGLE_BRANCH}}` conditional blocks, so the CLI's existing `render()`
and `select_workflow_block()` handle them with no new substitution logic.

This directory ships **templates only**. Wiring them into `init --agents ...` and keeping them
in sync on `update` is a separate task (backlog P5-3); nothing here is emitted yet.

## Source -> target mapping

| Template                        | Agent            | Rendered target path              |
| ------------------------------- | ---------------- | --------------------------------- |
| `AGENTS.md.tmpl`                | Codex / generic  | `AGENTS.md`                       |
| `cursor.mdc.tmpl`               | Cursor           | `.cursor/rules/{{PROJECT}}.mdc`   |
| `copilot-instructions.md.tmpl`  | GitHub Copilot   | `.github/copilot-instructions.md` |

The Claude template (`CLAUDE.md`) is rendered from [`../CLAUDE.md.tmpl`](../CLAUDE.md.tmpl) and
stays the canonical source for the wording; keep these copies in step with it.

## Format notes

- **`AGENTS.md`** - plain Markdown, the tool-neutral [agentsmd](https://agents.md) convention
  read by Codex and others. Mirrors `CLAUDE.md` closely.
- **`cursor.mdc`** - Cursor project rule. Carries YAML frontmatter (`description`, `globs`,
  `alwaysApply: true`) so the rule is always in context. Links use `../../` because the file
  lives two levels deep under `.cursor/rules/`.
- **`copilot-instructions.md`** - GitHub Copilot repository custom instructions. Plain Markdown
  under `.github/`; links use `../`.

## Tokens used

Same as the other core templates, all resolved by the CLI's `render()`:
`{{PROJECT_NAME}}`, `{{MAIN_BRANCH}}`, `{{BASE_BRANCH}}`, `{{WT_CMD}}`, `{{QUALITY_GATE}}`,
`{{COPY_LANGUAGE_NOTE}}`, `{{VARIANT_NOTES}}`, plus the `{{#TWO_BRANCH}}` / `{{#SINGLE_BRANCH}}`
workflow blocks.

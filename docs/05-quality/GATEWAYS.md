# Quality Gateways

## Gateway Rules

- Tests are written before production code for new behavior.
- Each gateway must preserve existing files unless the user explicitly chooses overwrite behavior.
- Generated files must be normal Markdown or plain project files.
- No cloud services or AI APIs are required for version 0.1.
- New commands must be documented before a gateway is marked complete.

## Gateway 1 Checks

- Unit tests cover base project generation.
- Unit tests cover project-type folder selection.
- Unit tests cover overwrite protection.
- Unit tests cover doctor output.
- Manual smoke test runs the local CLI against a temporary directory.

## Gateway 2 Checks

- Tests prove feature specs contain required sections.
- Tests prove decision records are numbered safely.
- Tests prove duplicate specs are not overwritten by default.

## Gateway 3 Checks

- Tests prove context packs include required baseline files.
- Tests prove topic-specific files are discovered when present.
- Output stays copyable as plain terminal text.

## Gateway 4 Checks

- Example projects match documented structure.
- README includes a five-minute start path.
- GUIDE explains lightweight, balanced, and strict modes.

## Gateway 5 Checks

- Package metadata supports `npx agent-project-kit`.
- Release checklist is complete.
- Scope is checked against MVP freeze and PRD.

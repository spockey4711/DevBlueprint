# Agent Project Kit

Agent Project Kit is a local CLI for creating spec-driven, agent-ready project structures for AI-assisted software development.

## Current Commands

```bash
node bin/apkit.js init --target ./my-project --name my-project --type web-app --framework nextjs --ai-tool codex --mode balanced
```

Creates:
- `AGENTS.md`
- product, architecture, feature, task, quality, and agent-context docs
- project-type source and test folders

```bash
node bin/apkit.js doctor --target ./my-project
```

Checks whether required foundation files are present.

```bash
node bin/apkit.js add feature --target ./my-project --name "User Authentication"
```

Creates a slugged feature spec in `docs/03-features/`.

```bash
node bin/apkit.js add decision --target ./my-project --title "Use Next.js"
```

Creates the next numbered architecture decision record in `docs/02-architecture/decisions/`.

```bash
node bin/apkit.js context user-authentication --target ./my-project
```

Prints a copyable context pack for the next AI-coding session.

## Prompt Library

Reusable prompts live in `prompts/`:
- `init-project.md`
- `create-feature-spec.md`
- `mvp-freeze-check.md`
- `architecture-review.md`
- `task-breakdown.md`
- `code-review.md`
- `update-docs-after-change.md`

## Project Types

- `web-app`
- `api-backend`
- `ios-app`
- `portfolio`
- `custom`

## Development

```bash
npm test
npm run test:coverage
```

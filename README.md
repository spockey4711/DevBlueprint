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

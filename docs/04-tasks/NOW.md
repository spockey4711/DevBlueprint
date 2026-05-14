# NOW

## Active Gateway

Gateway 1: CLI Foundation

## Current To-dos

- [x] Convert PRD into implementation gateways.
- [x] Write failing tests for project generation and doctor checks.
- [x] Implement the minimal CLI core.
- [x] Run tests and adjust implementation.
- [x] Smoke-test the CLI command locally.

## Gateway 1 Result

Gateway 1 is complete for the current repository state.

Verification:
- `npm test`
- `npm run test:coverage`
- `node bin/apkit.js init --target /private/tmp/apkit-smoke-devblueprint --name smoke-app --type web-app --framework nextjs --ai-tool codex --mode balanced`
- `node bin/apkit.js doctor --target /private/tmp/apkit-smoke-devblueprint`

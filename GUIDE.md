# Guide

## Five-Minute Start

Create a project structure:

```bash
node bin/apkit.js init --target ./my-project --name "my-project" --type web-app --framework nextjs --ai-tool codex --mode balanced
```

Add a feature spec:

```bash
node bin/apkit.js add feature --target ./my-project --name "User Authentication"
```

Get context for an AI-coding session:

```bash
node bin/apkit.js context user-authentication --target ./my-project
```

Check required files:

```bash
node bin/apkit.js doctor --target ./my-project
```

## Modes

### Lightweight

Use lightweight mode for quick experiments where you still want product scope, basic architecture notes, and agent rules.

### Balanced

Use balanced mode for most MVPs. It creates enough structure for spec-driven development without turning the repo into a project-management system.

### Strict

Use strict mode when maintainability, review discipline, or team handoff matters more than setup speed.

## Recommended Workflow

1. Initialize the project.
2. Fill in `docs/01-product/PRD.md`.
3. Freeze the MVP in `docs/01-product/MVP-FREEZE.md`.
4. Add one feature spec per feature.
5. Ask your AI-coding tool to load a context pack.
6. Implement only the loaded scope.
7. Update task and architecture docs after each meaningful change.

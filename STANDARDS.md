# Standards

## Spec-First

Agent Project Kit projects start with product scope, architecture notes, feature specs, and task files before implementation work expands.

## Small Changes

Prefer small, reviewable changes. A feature should have a matching spec and acceptance criteria before code is written.

## Overwrite Safety

Generated files must not overwrite existing user edits by default. Commands may offer explicit force behavior, but preservation is the normal path.

## Local Files

All generated artifacts should be plain local files. Version 0.1 must not require cloud services, accounts, or AI API keys.

## Agent Context

AI-coding sessions should load the smallest useful set of files: `AGENTS.md`, PRD, MVP freeze, quality plan, and the relevant feature or architecture files.

## Testing

New behavior should be covered with tests before implementation. Use the smallest relevant test first, then broaden verification when shared behavior changes.

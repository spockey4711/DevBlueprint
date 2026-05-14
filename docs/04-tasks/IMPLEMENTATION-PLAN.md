# Implementation Plan: Agent Project Kit

## Delivery Strategy

Build the product in small, testable gateways. Each gateway must leave the repository in a usable state, with tests proving the core behavior before implementation expands.

## Gateway 1: CLI Foundation

Goal: Provide a local CLI core that can create the base project structure safely.

To-dos:
- Define the package entry point and executable command.
- Implement project configuration defaults.
- Generate the base documentation tree.
- Generate `AGENTS.md`.
- Generate project-type source and test folders for Web App, API Backend, iOS App, and Portfolio.
- Refuse to overwrite existing files unless explicitly forced.
- Add a basic `doctor` check for required files.
- Cover the core generator with automated tests.

Exit criteria:
- `npm test` passes.
- `apkit init --target <dir> --name <name> --type web-app --framework nextjs --ai-tool codex --mode balanced` creates the expected structure.
- Existing files are preserved by default.
- `apkit doctor --target <dir>` reports missing required files.

## Gateway 2: Feature and Decision Workflows

Goal: Add repeatable spec-driven authoring commands.

To-dos:
- Implement `apkit add feature`.
- Implement slug generation for feature file names.
- Implement empty and guided feature templates.
- Implement `apkit add decision`.
- Auto-number decision records.
- Add tests for naming, template sections, and overwrite protection.

Exit criteria:
- Feature specs include all PRD-required sections.
- Decision records include context, decision, alternatives, and consequences.
- Tests cover duplicate file handling.

## Gateway 3: Context Packs and Prompt Library

Goal: Make the tool clearly useful for AI-coding sessions.

To-dos:
- Implement `apkit context <topic>`.
- Resolve matching feature and architecture files.
- Output a copyable file list and task instruction.
- Add prompt library files from the PRD.
- Add tests for context selection.

Exit criteria:
- Context output includes `AGENTS.md`, PRD, MVP freeze, quality plan, and topic-specific files when available.
- Prompt files exist and are linked from documentation.

## Gateway 4: Examples and Documentation

Goal: Turn the product from a file generator into a teachable project system.

To-dos:
- Create at least three complete example projects.
- Add `README.md`, `GUIDE.md`, and `STANDARDS.md`.
- Add example validation tests or fixture checks.
- Add contribution notes for future templates.

Exit criteria:
- A new user can run the CLI and understand the generated files in under five minutes.
- Three examples contain PRD, MVP freeze, architecture, feature specs, tasks, quality docs, and `AGENTS.md`.

## Gateway 5: Release Readiness

Goal: Prepare version 0.1 for publication.

To-dos:
- Add package metadata.
- Add release checklist.
- Add CI test command documentation.
- Verify cross-platform path handling.
- Review scope against `docs/01-product/PRD.md`.

Exit criteria:
- Version 0.1 scope is complete.
- Test suite passes from a clean checkout.
- Release checklist is complete.

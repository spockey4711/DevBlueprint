---
name: devblueprint-setup
description: Scaffold a project's engineering setup (git workflow + quality gate + AI-assistant guidance) with DevBlueprint by running a short, ordered setup interview. Use when the user says something like "set up this project", "scaffold a new project", or "run the DevBlueprint setup".
---

# DevBlueprint setup

Run the canonical setup interview to scaffold a project with DevBlueprint. The full,
authoritative question flow lives in [`../../setup-interview.md`](../../setup-interview.md) -
read it and follow it exactly. This file is the short operating procedure.

## Procedure

1. **List variants.** Run `devblueprint list` (or `bin/devblueprint list` from the kit) to get
   the real variant names and titles. Never offer a variant that is not printed.
2. **Interview.** Ask the five questions from `setup-interview.md`, in order, one at a time:
   1. Purpose and name
   2. Stack -> variant
   3. Deploy target
   4. Solo vs. team -> branch strategy
   5. License / community
   Skip any question the user already answered. Ask **only** these questions - never invent
   scope, features, or files.
3. **Write the intake file.** Save the answers to `.devblueprint-intake.yml` in the target
   directory, using the schema in `setup-interview.md`. Fill required keys; leave optional
   keys at their documented defaults rather than guessing.
4. **Preview.** Run `devblueprint plan --from .devblueprint-intake.yml` and show the user
   exactly what init would write. Do not touch disk before this preview.
5. **Scaffold on confirmation.** Run `devblueprint init --from .devblueprint-intake.yml`, then
   relay init's printed next steps (`./setup.sh`, `git init`, first worktree).

## Rules

- Ask only the five questions; acknowledge extra ideas but do not act on them here.
- Always `plan` before `init`, and get explicit confirmation.
- Prefer documented defaults over invention; never fabricate a variant or a file.
- Explicit flags override the file, so a single changed answer can be passed as a flag
  (e.g. `--base master`) instead of rewriting the file.

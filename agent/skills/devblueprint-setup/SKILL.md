---
name: devblueprint-setup
description: Scaffold a project's engineering setup (git workflow + quality gate + AI-assistant guidance) with DevBlueprint by running a short, ordered setup interview. Use when the user says something like "set up this project", "scaffold a new project", or "run the DevBlueprint setup".
---

# DevBlueprint setup

Run the canonical setup interview to scaffold a project with DevBlueprint. The full,
authoritative question flow lives in [`../../setup-interview.md`](../../setup-interview.md) -
read it and follow it exactly. This file is the short operating procedure.

If the user is new to this - they say so, ask what a term means, or plainly seem unsure - run
[Beginner mode](#beginner-mode) below. It layers plain-language glosses and extra help at the
path step onto the exact same flow; it never changes the questions or skips the preview.

## Procedure

1. **List variants.** Run `devblueprint list` (or `bin/devblueprint list` from the kit) to get
   the real variant names and titles; add `--json` to parse them
   (`{"variants":[{name,title,gate}]}`) rather than the human table. Never offer a variant that
   is not printed.
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

## Beginner mode

Enter beginner mode when the user signals they are new (for example "I'm new to this", "what is
a variant?", "walk me through it") or is plainly unsure of the terms. When in doubt, offer it:
"Want me to explain each step as we go?" Everything else is unchanged - the same five questions,
in the same order, and always `plan` before `init` - but assume **zero** prior knowledge:

- **Gloss every term the first time it appears, in one line.** Use the wording from
  [`docs/glossary.md`](../../../docs/glossary.md) so it matches the rest of the docs, and keep it
  to a single line; if the user wants more, point them at the glossary rather than expanding
  inline. The terms this interview raises:
  - **Variant** - one of this blueprint's stack-specific flavors (for example a `backend-go` or
    `sveltekit` setup) that layers its own tooling over the shared baseline.
  - **Deploy target** - where the finished project runs in production; it only picks which
    deployment notes a variant keeps, it does not provision anything.
  - **Branch** - a named, parallel line of work in the repo, so you can change things without
    disturbing the main version until you are ready.
  - **Two-branch flow vs. trunk** - two-branch keeps a `develop` line for integration and a
    stable `master`; a trunk is a single shared branch. Solo -> trunk, team -> two-branch.
  - **Worktree** - a separate folder checked out to its own branch, so you can work on several
    branches at once without switching back and forth in one folder.
  - **PR** - short for "pull request": a proposal to merge one branch's commits into another,
    which others review before it is accepted.
  - **Quality gate** - the single command (`make check`) that must pass before you push,
    bundling the project's lint, typecheck, test, and build steps.
  - **Intake file** - the `.devblueprint-intake.yml` that records your answers so the scaffold
    can be previewed and re-run from them.

- **Actively help at the path step.** The target directory (the `target` key) is where the
  project gets scaffolded and is where a beginner most often gets stuck, so do not just accept a
  blank answer:
  - Gloss it: **Path** - the address of a folder on your computer (like
    `/Users/you/projects/myapp`); `.` means "the folder your terminal is in right now".
  - Offer a concrete default out loud: scaffold into the current directory (`target: .`) if it is
    empty, or into a new `./<name>` subfolder named after the project.
  - If they are unsure where they are, have them run `pwd` to see the current folder and `ls` to
    see what is already in it.
  - Before writing anything, show the resolved absolute path back and get an explicit yes - never
    scaffold into a surprise location.

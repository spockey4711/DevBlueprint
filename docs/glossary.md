# Glossary

Plain-language definitions of the terms used throughout this repo's docs. One sentence each; if
a doc uses a word you do not recognize, look for it here first.

- **Terminal** - the text window where you type commands and read their output, instead of
  clicking buttons.
- **Path** - the address of a file or folder on your computer, like
  `docs/glossary.md` or `/Users/you/projects`.
- **Repo** - short for "repository": the folder holding your project's files together with the
  full history of every change git has recorded.
- **Branch** - a named, parallel line of work in the repo, so you can change things without
  disturbing the main version until you are ready.
- **Commit** - one saved snapshot of your changes with a short message describing them; the
  smallest unit of history in git.
- **PR** - short for "pull request": a proposal to merge one branch's commits into another,
  which others review before it is accepted.
- **Worktree** - a separate folder checked out to its own branch, so you can work on several
  branches at once without switching back and forth in one folder.
- **CI** - short for "continuous integration": the automated service that runs your checks
  (build, lint, tests) on every push so problems surface early.
- **Lint** - an automated check that flags style problems and likely mistakes in code before a
  human has to notice them.
- **Variant** - one of this blueprint's stack-specific flavors (for example a backend-go or
  sveltekit setup) that layers its own tooling over the shared baseline.
- **Quality gate** - the single command (`make check`) that must pass before you push, bundling
  the project's lint, typecheck, test, and build steps.

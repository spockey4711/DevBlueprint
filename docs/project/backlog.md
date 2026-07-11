# Backlog

The prioritized task list - the source of truth for what to build next. Reference an id in
commits and PRs (e.g. `Refs: P8-1`). Task markers: `- [ ]` todo, `- [x]` done, `- [~]` merged
with a follow-up still pending (see the task lifecycle in
[`docs/engineering/git-workflow.md`](../engineering/git-workflow.md)).

Completed phases P0 - P7 live in [`backlog-archive.md`](backlog-archive.md).

## The 24-month roadmap (P8 - P15): from usable-by-experts to usable-by-beginners

Everything so far (P0-P7) assumes fluency: terminal, git, worktrees, PRs, CI, package
managers. The next two years shift the audience. **North star:** a person with no or almost
no programming experience gets from nothing to their first green PR - and learns *why* the
workflow looks the way it does. Same principles as before: documentation-first, plain files
you own, no runtime, no lock-in, the agent is the runtime, static backend-less tools are fine.

Lighter process than P2-P7 on purpose: tasks are grouped so tasks that touch the same area sit
together, but there are **no per-task `Owns:` path lists** - a bit more merge risk is accepted
in exchange for not over-constraining the agent. The rules that still hold:

- **`(CLI)`-tagged tasks edit `bin/devblueprint` + `test/`.** Keep at most one in flight at a
  time; they are the serialization point.
- **Dependencies are marked inline** as `(builds on P8-1)`. A task with no marker is
  independent and parallel-safe.
- Prefer small tasks: one page, one command, one check per task.

### Months 0-6: beginner focus (the priority)

Two themes. **P8** is the pure explain/docs layer - ship it first, near-zero code risk.
**P9** is the CLI/tooling that makes onboarding genuinely foolproof.

#### P8 - Absolute-beginner onboarding docs (docs only, mostly parallel)

- [x] P8-1: Create a `GETTING-STARTED.md` skeleton (intro + section headings for
  prerequisites, choosing a folder, first run, first task) and link it from the top of the
  README. The anchor the rest of P8 fills in. (enabler - do first)
- [ ] P8-2: Prerequisites section - install a terminal, git, Node and an editor, split per OS
  (macOS / Windows / Linux), as copy-paste blocks with "you should see this if it worked".
  (builds on P8-1)
- [ ] P8-3: "Where do I put the project / which path do I pick" section - absolute vs. relative
  paths, what `~` means, no spaces in paths, a suggested `~/Projects/<name>` default, and how
  to open that folder in the terminal and the editor. (builds on P8-1)
- [ ] P8-4: End-to-end "your first project" tutorial - one worked run from `init` to the first
  green PR, every command shown with its expected output. (builds on P8-1; smoother once P9-1
  lands, but write it against today's flow first)
- [ ] P8-5: Plain-language glossary at `docs/glossary.md` - terminal, path, repo, branch,
  commit, PR, worktree, CI, lint, variant, quality gate; one sentence each.
- [ ] P8-6: Cross-link the glossary - first mention of each term in the existing docs links to
  its glossary entry, so no term is ever left unexplained. (builds on P8-5)

#### P9 - Make the CLI beginner-proof (CLI hot path - serialize P9-1/2/3)

- [ ] P9-1: (CLI) Interactive wizard: `devblueprint init` with no flags runs a plain-language
  prompt that explains each question, suggests sensible defaults (especially the target path),
  and shows exactly what will be written before touching disk (reuse the existing `plan`
  output). The single biggest lever - no flag knowledge required.
- [ ] P9-2: (CLI) `devblueprint doctor --env` prerequisite check - verifies git / Node / a
  working shell are present and prints per-OS copy-paste fixes when they are not. The first
  command a beginner runs. (independent of P9-1, but same hot path - own turn)
- [ ] P9-3: (CLI) Beginner-friendly error messages - audit CLI output so every failure says
  what to do next (missing path, directory already exists, git not initialised), not just what
  broke. (own turn on the CLI)
- [ ] P9-4: Beginner mode for the `devblueprint-setup` interview skill - assume zero knowledge,
  gloss every term in one line, and actively help at the path step. Agent files only, so it
  runs parallel to the P9 CLI tasks. (pairs with P8-5 for shared glossary wording)

### Months 6-12: reduce the barrier to entry

#### P10 - A "no raw terminal needed" path

- [ ] P10-1: Ship `.vscode/extensions.json` (recommended extensions) per variant, so opening
  the project in VS Code offers the right tooling in one click.
- [ ] P10-2: Ship `.vscode/tasks.json` per variant wiring `make check` (and common gate steps)
  to a menu/button, so a beginner runs the gate without memorising commands. (builds on P10-1;
  same `.vscode/` area)
- [ ] P10-3: Promote a devcontainer / Codespaces "click here, get a ready environment" path as
  a first-class beginner option - a short doc plus making sure the relevant variants ship a
  `.devcontainer`. Zero local install. (references P8-1)

#### P11 - Learn, don't just use

- [ ] P11-1: "Why we work this way" concept notes - short docs explaining the reasoning behind
  worktrees, Conventional Commits and the quality gate, aimed at someone learning to be a good
  engineer. (links to P8-5 glossary)
- [ ] P11-2: An agent "mentor" skill that narrates the workflow as you go ("you are on
  develop; let us make a worktree, because ..."), so the process teaches itself. (builds on
  P11-1 for the explanations)

### Months 12-18: reach and reuse

#### P12 - Localization of user-facing copy

- [ ] P12-1: Establish an `i18n/` layer and a short policy - repo/code/docs stay English
  (CLAUDE.md rule), but beginner tutorial copy may be localised in a dedicated layer.
- [ ] P12-2: German translation of `GETTING-STARTED.md` and the glossary as the first locale,
  since raw beginners benefit most from their native language. (builds on P12-1, P8-1, P8-5)

#### P13 - Consolidation and drift control

- [ ] P13-1: Clarify the onboarding surfaces so they stop overlapping - README = the pitch,
  `GETTING-STARTED.md` = the beginner path, `GUIDE.md` = the reference; trim duplicated
  content. (builds on P8-1)
- [ ] P13-2: Extend the bats suite to cover the new interactive CLI paths. (builds on P9-1,
  P9-2, P9-3)
- [ ] P13-3: Harden the kit self-CI for the new beginner artifacts (`.vscode/`, devcontainer,
  getting-started links) so they cannot rot silently. (builds on P10-1, P10-2)

### Months 18-24: ecosystem and sustainability

#### P14 - Smoother lifecycle

- [ ] P14-1: (CLI) Guided `update` - detect drift and offer to apply it interactively, in the
  same plain language as the P9-1 wizard. (builds on P9-1)
- [ ] P14-2: New variants as the ecosystem demands, each self-contained like P2-4.

#### P15 - Show, don't tell

- [ ] P15-1: An example gallery - a few real mini-projects built with DevBlueprint, linked as
  references a beginner can copy from. (builds on P8-4)
- [ ] P15-2: A periodic doc-freshness pass - verify the getting-started flow and screenshots
  still match the current CLI, so the beginner path never drifts out of date.

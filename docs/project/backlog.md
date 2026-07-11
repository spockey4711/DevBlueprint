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

These phases are re-grouped into **waves of exactly four tasks** that can be worked in
parallel - one worktree/agent per task, all four PRs open at once. The grouping obeys:

- **Four tasks per phase, parallel-first.** Within a phase the four tasks touch disjoint
  files and do not build on each other, so they can run simultaneously.
- **At most one `(CLI)`-tagged task per phase.** `(CLI)` tasks edit `bin/devblueprint` +
  `test/`, the only hot shared paths and the serialization point - so no two share a wave.
- **Enabler exceptions are allowed and marked.** A few phases open with a single enabler
  (e.g. P8-1, P13-1) that the other three build on; do that one first, then fan out. Any
  remaining cross-task dependency is marked inline as `(builds on ...)`; unmarked tasks are
  independent. Cross-*phase* dependencies are fine (later phases lean on earlier ones); only
  within-phase parallelism is guarded.
- Prefer small tasks: one page, one command, one check per task.

### Months 0-6: beginner focus (the priority) - pure docs, near-zero code risk

**P8** builds the getting-started surface; **P9** adds the plain-language reference layer.
Both are docs-only, so the whole block ships with no CLI risk.

#### P8 - Getting-started docs (docs only; enabler + three section-fills)

The four tasks all live in `GETTING-STARTED.md`; P8-1 lays down the headings, then each of
the other three fills a different section, so conflicts are limited to distinct file regions.

- [x] P8-1: Create a `GETTING-STARTED.md` skeleton (intro + section headings for
  prerequisites, choosing a folder, first run, first task) and link it from the top of the
  README. The anchor the rest of P8 fills in. (enabler - do first)
- [ ] P8-2: Prerequisites section - install a terminal, git, Node and an editor, split per OS
  (macOS / Windows / Linux), as copy-paste blocks with "you should see this if it worked".
  (builds on P8-1; own section)
- [x] P8-3: "Where do I put the project / which path do I pick" section - absolute vs. relative
  paths, what `~` means, no spaces in paths, a suggested `~/Projects/<name>` default, and how
  to open that folder in the terminal and the editor. (builds on P8-1; own section)
- [x] P8-4: End-to-end "your first project" tutorial section - one worked run from `init` to
  the first green PR, every command shown with its expected output. (builds on P8-1; own
  section; smoother once P10-1 lands, but write it against today's flow first)

#### P9 - Plain-language reference layer (docs only; four new files, fully parallel)

Each task is a brand-new standalone file, so all four are independent with zero shared paths.

- [x] P9-1: Plain-language glossary at `docs/glossary.md` - terminal, path, repo, branch,
  commit, PR, worktree, CI, lint, variant, quality gate; one sentence each.
- [x] P9-2: `docs/faq.md` - the common "why did this happen / what now" questions a beginner
  hits (directory already exists, not a git repo, gate is red, wrong branch), one answer each.
- [x] P9-3: `docs/cheatsheet.md` - a one-page everyday-commands reference (the wt.sh, git,
  and `make check` calls used in the normal loop) that a beginner can keep open beside them.
- [x] P9-4: `docs/reading-errors.md` - how to read an error you did not expect: a lint
  failure, a red CI log, a stack trace - what to look for and where, in plain language.

### Months 6-12: reduce the barrier to entry - first CLI polish + no-terminal path

#### P10 - Guided init (one CLI task + three parallel supports)

- [x] P10-1: (CLI) Interactive wizard: `devblueprint init` with no flags runs a plain-language
  prompt that explains each question, suggests sensible defaults (especially the target path),
  and shows exactly what will be written before touching disk (reuse the existing `plan`
  output). The single biggest lever - no flag knowledge required.
- [x] P10-2: Beginner mode for the `devblueprint-setup` interview skill - assume zero
  knowledge, gloss every term in one line, and actively help at the path step. Agent files
  only. (pairs with P9-1 for shared glossary wording)
- [x] P10-3: Ship `.vscode/extensions.json` (recommended extensions) per variant, so opening
  the project in VS Code offers the right tooling in one click. (per-variant fan-out)
- [x] P10-4: Ship `.vscode/tasks.json` per variant wiring `make check` (and common gate steps)
  to a menu/button, so a beginner runs the gate without memorising commands. Distinct file
  from P10-3's `extensions.json`, so the two run in parallel. (per-variant fan-out)

#### P11 - Environment check & zero-install (one CLI task + three parallel supports)

- [x] P11-1: (CLI) `devblueprint doctor --env` prerequisite check - verifies git / Node / a
  working shell are present and prints per-OS copy-paste fixes when they are not. The first
  command a beginner runs.
- [ ] P11-2: Promote a devcontainer / Codespaces "click here, get a ready environment" path as
  a first-class beginner option - a short doc plus making sure the relevant variants ship a
  `.devcontainer`. Zero local install. (references P8-1)
- [ ] P11-3: Concept note `docs/concepts/worktrees.md` - why we work one-directory-per-branch,
  aimed at someone learning to be a good engineer. (links to P9-1 glossary)
- [ ] P11-4: Concept note `docs/concepts/commits-and-gate.md` - why Conventional Commits and
  the quality gate exist and what they buy you. Distinct file from P11-3. (links to P9-1)

### Months 12-18: reach and reuse - friendly failures, mentoring, localization

#### P12 - Friendly failures & mentor (one CLI task + three parallel supports)

- [ ] P12-1: (CLI) Beginner-friendly error messages - audit CLI output so every failure says
  what to do next (missing path, directory already exists, git not initialised), not just what
  broke.
- [ ] P12-2: An agent "mentor" skill that narrates the workflow as you go ("you are on
  develop; let us make a worktree, because ..."), so the process teaches itself. Agent files
  only. (builds on P11-3/P11-4 for the explanations)
- [ ] P12-3: Cross-link the glossary and reference layer - first mention of each term in the
  existing docs links to its `docs/glossary.md` entry, so no term is ever left unexplained.
  (builds on P9)
- [ ] P12-4: `docs/concepts/README.md` - a short index that ties the "why we work this way"
  concept notes together and points newcomers at a reading order. (builds on P11-3/P11-4)

#### P13 - Localization of user-facing copy (docs only; enabler + three translations)

- [ ] P13-1: Establish an `i18n/` layer and a short policy - repo/code/docs stay English
  (CLAUDE.md rule), but beginner tutorial copy may be localised in a dedicated layer.
  (enabler - do first)
- [ ] P13-2: German translation of `GETTING-STARTED.md` as the first locale, since raw
  beginners benefit most from their native language. (builds on P13-1, P8)
- [ ] P13-3: German translation of the glossary (`docs/glossary.md`). Distinct source file
  from P13-2. (builds on P13-1, P9-1)
- [ ] P13-4: German translation of the FAQ and cheat-sheet (`docs/faq.md`,
  `docs/cheatsheet.md`). Distinct source files from P13-2/P13-3. (builds on P13-1, P9-2/P9-3)

### Months 18-24: ecosystem and sustainability - consolidation, then lifecycle

#### P14 - Consolidation & drift control (four parallel; disjoint files)

- [ ] P14-1: Clarify the onboarding surfaces so they stop overlapping - README = the pitch,
  `GETTING-STARTED.md` = the beginner path, `GUIDE.md` = the reference; trim duplicated
  content. (builds on P8, P13)
- [ ] P14-2: Extend the bats suite to cover the new interactive CLI paths (wizard, `doctor
  --env`, error messages). Owns `test/` only, no `bin/devblueprint` edit. (builds on
  P10-1/P11-1/P12-1)
- [ ] P14-3: Harden the kit self-CI for the new beginner artifacts (`.vscode/`, devcontainer,
  getting-started links) so they cannot rot silently. Own workflow file. (builds on P10, P11)
- [ ] P14-4: Doc-freshness + link-check CI for the beginner path - fail the build when a
  getting-started command or an internal doc link no longer resolves. Own workflow file.
  (builds on P8, P9)

#### P15 - Smoother lifecycle & show, don't tell (one CLI task + three parallel supports)

- [ ] P15-1: (CLI) Guided `update` - detect drift and offer to apply it interactively, in the
  same plain language as the P10-1 wizard. (builds on P10-1)
- [ ] P15-2: An example gallery - a few real mini-projects built with DevBlueprint, linked as
  references a beginner can copy from. (builds on P8-4)
- [ ] P15-3: New variants as the ecosystem demands, each self-contained like P2-4.
  (per-variant fan-out)
- [ ] P15-4: A periodic doc-freshness pass - verify the getting-started flow and screenshots
  still match the current CLI, so the beginner path never drifts out of date.

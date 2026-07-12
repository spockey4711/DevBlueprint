# Good first issues

A stocked shelf of small, well-scoped starter tasks for people making their first contribution
to DevBlueprint. Each one is deliberately tiny - one file or one section, an hour or less - and
comes with everything a newcomer needs to finish it without asking where to start.

**New here?** Read [`CONTRIBUTING.md`](../../CONTRIBUTING.md) first (and
[`GETTING-STARTED.md`](../../GETTING-STARTED.md) if the terminal, git or worktrees are new to
you), then pick any task below. Comment on the matching GitHub issue to claim it so two people do
not do the same one.

## For maintainers: how to use this list

This file is the source; the GitHub issues are copies of it. Keep them in sync:

1. When you file one of these as a GitHub issue, open it with the
   [Good first issue template](../../.github/ISSUE_TEMPLATE/good_first_issue.md), paste the entry
   below, and apply the `good first issue` label (plus any area label - `docs`, `i18n`,
   `variants`, `test`).
2. Keep 8-10 of these open and unclaimed at all times - the contributor funnel dries up when the
   shelf is empty (see the growth playbook,
   [`docs/marketing/road-to-5k.md`](../marketing/road-to-5k.md)). When one is merged, tick it
   here and add a fresh one.
3. Respond to a claim or a question within a day. A newcomer's first PR is the whole point; a
   slow first reply is where most contributors are lost.

Legend: `[ ]` open, `[x]` merged. Effort is a rough guide for a first-timer.

## The shelf

### 1. i18n: add a new-locale mirror of the glossary

- **Area:** i18n · **Effort:** ~1 hour · **Labels:** `good first issue`, `i18n`
- **Why it's a good first issue:** mechanical and self-contained - you mirror an existing English
  file into a new language, with a clear model to copy and no code to touch.
- **Context:** [`i18n/README.md`](../../i18n/README.md) is the localization policy: English is the
  source of truth, and only the beginner-facing surface is translated. German (`i18n/de/`) is the
  only locale so far.
- **What to do:** pick a language you speak natively, create
  `i18n/<locale>/docs/glossary.md` mirroring [`docs/glossary.md`](../glossary.md) one-to-one
  (same terms, same order, same `<a id="...">` anchors - translate only the prose), add the
  `Deutsch:`-style back-link at the top of the English glossary for your locale, and register the
  new locale in [`i18n/README.md`](../../i18n/README.md).
- **Done when:** the new file exists, mirrors every English entry, and `make check` passes.

### 2. docs(faq): add "How do I undo my last commit?"

- **Area:** docs · **Effort:** ~30 min · **Labels:** `good first issue`, `docs`
- **Why it's a good first issue:** one short question and answer in an existing file, in the same
  plain-language voice as its neighbours.
- **Context:** [`docs/faq.md`](../faq.md) answers the "why did this happen / what now" moments a
  beginner hits. It does not yet cover undoing a commit - one of the most common early panics.
- **What to do:** add a section explaining `git commit --amend` (fix the most recent commit) and
  `git reset --soft HEAD~1` (undo it but keep the changes staged), in one or two sentences each,
  matching the existing entries' tone. Keep it to what a beginner actually needs.
- **Done when:** the entry reads like the others and `make check` passes.

### 3. docs(cheatsheet): add "sync your branch with the latest develop"

- **Area:** docs · **Effort:** ~30 min · **Labels:** `good first issue`, `docs`
- **Why it's a good first issue:** a single row/entry in the everyday-commands reference.
- **Context:** [`docs/cheatsheet.md`](../cheatsheet.md) lists the commands used in the normal
  loop, but not how to pull the latest `develop` into a feature branch that has fallen behind.
- **What to do:** under the "Git commands you reach for daily" section, add the command to update
  a branch from `develop` (for example `git fetch` then `git merge origin/develop`, or the
  project's preferred approach) with a one-line "what it does".
- **Done when:** the new entry fits the existing table/list style and `make check` passes.

### 4. docs(glossary): add a "merge conflict" entry

- **Area:** docs · **Effort:** ~30 min · **Labels:** `good first issue`, `docs`
- **Why it's a good first issue:** add one term to a list of many, following an obvious pattern.
- **Context:** [`docs/glossary.md`](../glossary.md) defines the repo's terms one sentence each,
  each as a `- <a id="..."></a>**Term** - definition.` bullet. "Merge conflict" is used elsewhere
  but is not yet defined.
- **What to do:** add a `- <a id="merge-conflict"></a>**Merge conflict** - ...` bullet in a
  sensible spot, one plain sentence. If you also speak German, mirror it into
  [`i18n/de/docs/glossary.md`](../../i18n/de/docs/glossary.md) (optional bonus).
- **Done when:** the entry matches the surrounding format and `make check` passes.

### 5. docs(example-gallery): add one more mini-project

- **Area:** docs · **Effort:** ~45 min · **Labels:** `good first issue`, `docs`
- **Why it's a good first issue:** the page already defines a four-field template for each entry,
  so you fill in a form rather than invent a structure.
- **Context:** [`docs/example-gallery.md`](../example-gallery.md) lists small, real projects a
  beginner can build with an existing [variant](../glossary.md#variant). Each entry has four
  parts: what you build, the variant, the scaffold command, and a good first task.
- **What to do:** add one more entry for a variant you know, filling in all four fields. Use
  `devblueprint list` to see the variants and keep the scaffold command copy-paste correct.
- **Done when:** the new entry matches the template and `make check` passes.

### 6. docs(reading-errors): add a fourth kind of error

- **Area:** docs · **Effort:** ~45 min · **Labels:** `good first issue`, `docs`
- **Why it's a good first issue:** you extend an existing, clearly-patterned section rather than
  writing a doc from scratch.
- **Context:** [`docs/reading-errors.md`](../reading-errors.md) has a "Three kinds you will meet"
  section covering a lint failure, a red CI log and a stack trace.
- **What to do:** add a fourth kind a beginner commonly hits - for example a failing test or a
  type error - in the same shape as the existing three (what it looks like, where the useful part
  is, what to do), and update the section heading to match the new count.
- **Done when:** the new subsection reads like the existing three and `make check` passes.

### 7. chore(variants): recommend one more VS Code extension

- **Area:** variants · **Effort:** ~30 min · **Labels:** `good first issue`, `variants`
- **Why it's a good first issue:** a one-line JSON change in a single variant, with an obvious
  format to copy.
- **Context:** most variants ship a recommended-extensions list at
  `variants/<variant>/extras/.vscode/extensions.json`, so opening the scaffolded project in VS
  Code offers the right tooling in one click.
- **What to do:** pick one variant, find a widely-used extension for its stack that is not yet
  listed (verify the extension id on the VS Code Marketplace), add it to that variant's
  `extensions.json`, and note in the PR why it belongs.
- **Done when:** the JSON is valid, the id is correct, and `make check` passes.

### 8. test(bats): assert `devblueprint version` matches the VERSION file

- **Area:** test · **Effort:** ~1 hour · **Labels:** `good first issue`, `test`
- **Why it's a good first issue:** a small, focused test that teaches the repo's bats suite - a
  slightly meatier task for someone comfortable in a shell.
- **Context:** the CLI's `version` subcommand should print the contents of the top-level
  [`VERSION`](../../VERSION) file. The bats suite lives under `test/`.
- **What to do:** add a test that runs `devblueprint version` and asserts its output equals the
  `VERSION` file's contents, following the style of the existing tests. Run it with `make test`
  (or `make check`) before pushing.
- **Done when:** the new test passes locally and in CI.

### 9. docs(GETTING-STARTED): add a "what to do after your first PR" section

- **Area:** docs · **Effort:** ~45 min · **Labels:** `good first issue`, `docs`
- **Why it's a good first issue:** a short, encouraging closing section on a page you have just
  walked through yourself as a newcomer - so you know exactly what was missing.
- **Context:** [`GETTING-STARTED.md`](../../GETTING-STARTED.md) walks a beginner from nothing
  installed to their first green PR, then ends. It does not say what comes next.
- **What to do:** add a short closing section pointing to the natural next steps - the
  [example gallery](../example-gallery.md), the [cheatsheet](../cheatsheet.md), and this
  good-first-issues list - so a first-timer knows where to go after their PR is merged.
- **Done when:** the section links resolve, the tone matches the page, and `make check` passes.

### 10. docs(README): add a short "Contributing" section

- **Area:** docs · **Effort:** ~30 min · **Labels:** `good first issue`, `docs`
- **Why it's a good first issue:** a small, high-visibility addition to the front door, with
  everything it should link to already written.
- **Context:** [`README.md`](../../README.md) explains what DevBlueprint is but has no explicit
  "Contributing" section, so a would-be contributor has to go hunting for
  [`CONTRIBUTING.md`](../../CONTRIBUTING.md).
- **What to do:** add a brief "Contributing" section near the end of the README linking to
  `CONTRIBUTING.md`, `GETTING-STARTED.md` (for beginners), and this good-first-issues list, in a
  couple of welcoming sentences.
- **Done when:** the links resolve and `make check` passes.

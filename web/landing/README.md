# Landing page

A single, backend-less HTML page that states the hook - **run parallel Claude agents
without collisions** - and hands a newcomer a one-line install. It is the top of the
funnel for the [growth plan](../../docs/marketing/road-to-5k.md): a stranger should
understand what DevBlueprint is and why it matters within ten seconds, then copy a command.

It respects the kit's no-runtime principle: **nothing is hosted and nothing is sent
anywhere.** [`index.html`](index.html) is fully self-contained (inline CSS and JS, no build
step, no dependencies, no external fonts or requests) and runs entirely in the browser.

## What is on it

- The hook headline and a one-sentence explanation (worktree per task, a PR every time,
  one command to scaffold it all).
- A **parallel-lanes schematic** - three agent worktrees running in isolation and merging
  through a PR into `develop`, which is promoted to `master`. It draws the hook rather than
  restating it.
- The primary call to action: `npx devblueprint list`, copy-to-clipboard.
- "What lands in your repo" - the four things the kit ships.
- The three install channels (`npx`, Homebrew, `curl | sh`), each copyable.

## Use it

Open [`index.html`](index.html) directly:

- Double-click the file, or open it via `file://...` in any modern browser, **or**
- Serve the directory statically (e.g. GitHub Pages, `python3 -m http.server`).

## Maintenance

The page inlines a few facts that live elsewhere in the repo; keep them in step when they
change:

- The **install commands** mirror the README's Install section (the Homebrew tap slug, the
  `curl | sh` URL, the `DEVBLUEPRINT_*` env vars). Update both together.
- The **hook copy** tracks the README intro; if the one-sentence pitch changes there, change
  it here.
- `npx devblueprint list` is the featured first command because it is the lowest-friction
  entry (no install). Keep it a real, safe-to-run subcommand.

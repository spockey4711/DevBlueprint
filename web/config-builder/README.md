# Static intake config builder

A single, backend-less HTML page that turns a form into a
[`.devblueprint-intake.yml`](../../docs/agent/intake-schema.md) **and the matching
`devblueprint` command** - for people who set DevBlueprint up by hand instead of
driving it through an agent.

It respects the kit's no-runtime principle: **nothing is hosted and nothing is sent
anywhere.** [`index.html`](index.html) is fully self-contained (inline CSS and JS, no
build step, no dependencies) and runs entirely in the browser.

## Use it

Open [`index.html`](index.html) directly:

- Double-click the file, or open it via `file://...` in any modern browser, **or**
- Serve the directory statically (e.g. GitHub Pages, `python3 -m http.server`).

Fill in the form. The page renders two things side by side:

- the **intake file** (`.devblueprint-intake.yml`) - **Download file** or **Copy** it and
  save it at your project root;
- the **command** that applies it, with your target path (and, for a monorepo, one
  `--package name:variant` flag per package) already filled in - **Copy command** and run
  it.

```bash
# Preview exactly what init would write, without touching disk:
devblueprint plan --target ~/Projects/myapp --from .devblueprint-intake.yml

# Apply it once the plan looks right:
devblueprint init --target ~/Projects/myapp --from .devblueprint-intake.yml
```

Every intake key the CLI reads is covered: `name`, `variant`, `main`, `base`,
`community`, `contact`, `deploy`, `flavors`, `agents`, and `extends`. The builder writes
the same flat `key: value` format the CLI reads, so its output is interchangeable with a
hand-written file.

Two things are **command-line only**, not keys in the file, and the builder puts them on
the generated command instead:

- **`--target`** - the path says *where* to scaffold, not *what*, so it stays a CLI
  argument on every run.
- **`--package name:variant`** (monorepo layout) - a monorepo picks a variant per package
  on the command line; `variant`/`flavors` are then omitted from the file (the CLI rejects
  them alongside `--package`).

## Maintenance

Two lists are inlined in `index.html` because a static page has no CLI to query:

- The `VARIANTS` array - keep it matching `devblueprint list` (each
  [`variants/<slug>/manifest.env`](../../variants/) `VARIANT_TITLE`) when a variant is
  added, removed, or renamed.
- The `FLAVORS` array - keep it matching the [`variants/_flavors/`](../../variants/_flavors/)
  slugs.

The generated keys track the [intake schema](../../docs/agent/intake-schema.md); if the
schema gains or changes a key, update the form and the `build()` function together. The
`--agents` set (`claude`/`codex`/`cursor`/`copilot`) is mirrored in the agent checkboxes.

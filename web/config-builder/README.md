# Static intake config builder

A single, backend-less HTML page that turns a short form into a
[`.devblueprint-intake.yml`](../../docs/agent/intake-schema.md) - for people who set
DevBlueprint up by hand instead of driving it through an agent.

It respects the kit's no-runtime principle: **nothing is hosted and nothing is sent
anywhere.** [`index.html`](index.html) is fully self-contained (inline CSS and JS, no
build step, no dependencies) and runs entirely in the browser.

## Use it

Open [`index.html`](index.html) directly:

- Double-click the file, or open it via `file://...` in any modern browser, **or**
- Serve the directory statically (e.g. GitHub Pages, `python3 -m http.server`).

Fill in the form, then **Download file** (or **Copy**) to get the YAML. Save it as
`.devblueprint-intake.yml` at your project root and hand it to the CLI:

```bash
# Preview exactly what init would write, without touching disk:
devblueprint plan --target ~/Projects/myapp --from .devblueprint-intake.yml

# Apply it once the plan looks right:
devblueprint init --target ~/Projects/myapp --from .devblueprint-intake.yml
```

The builder writes the same flat `key: value` format the CLI reads, so its output is
interchangeable with a hand-written file. `--target` is intentionally absent - it says
*where* to scaffold, not *what*, so it stays a CLI argument on every run.

## Maintenance

The variant dropdown is inlined in `index.html` (the `VARIANTS` array). A static page
has no CLI to query, so when a variant is added, removed, or renamed under
[`variants/`](../../variants/), update that array to match `devblueprint list`.

The generated keys track the [intake schema](../../docs/agent/intake-schema.md); if the
schema gains or changes a key, update the form and the `build()` function together.

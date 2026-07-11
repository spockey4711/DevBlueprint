# Add-on flavors

Flavors are orthogonal overlays layered onto a base variant at `init` time with
`--flavor`, e.g. `devblueprint init --target ./app --variant backend-python --flavor postgres,docker`.
Unlike a variant (which picks the stack), a flavor adds one concern - a database, a
container setup, auth scaffolding - and is meant to compose with any base variant
and with other flavors.

## Layout

Each flavor is a directory named after the add-on:

```
_flavors/<name>/
  flavor.env          # required: FLAVOR_TITLE (one-line description)
  overlay/            # optional: a tree copied verbatim into the project root
  gitignore.append    # optional: lines appended to the project .gitignore
```

`overlay/` is copied with the same overwrite safety as the base scaffold: an
existing file is left untouched unless `--force` is given, so a flavor never
silently clobbers a variant's file. Ship new files (config plus a
`overlay/docs/flavors/<name>.md` note explaining how to wire the add-on) rather
than replacing base files. Use `gitignore.append` for ignore rules, which merge
instead of overwriting.

Flavors are applied last, after the base variant is fully scaffolded, and the
selection is recorded in the project's `.devblueprint` stamp (`flavors=...`).

## Available flavors

Run `devblueprint list` to see the current set. The directory name is the value you
pass to `--flavor`.

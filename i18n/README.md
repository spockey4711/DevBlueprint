# Localization (`i18n/`)

The dedicated layer for translated, beginner-facing copy. Everything else in the repo stays
English. This file is both the policy and the how-to; read it before adding a translation.

## Policy

- **English is the source of truth.** All code, comments, docs, commits, PRs and issues are
  written in English (the [`CLAUDE.md`](../CLAUDE.md) and [`CONTRIBUTING.md`](../CONTRIBUTING.md)
  language rule). The English file is canonical; a translation only ever mirrors it.
- **Only beginner tutorial copy may be localized**, and only here under `i18n/`. Never scatter
  translated strings through the English docs or the code. If a file is not aimed at a raw
  beginner, it is not translated.
- **Translations may lag.** They are a convenience, not a contract. When a translation and its
  English source disagree, the English source wins. A stale translation is a bug to fix, never a
  reason to hold up an English change.

### What may be localized

The onboarding surface a newcomer meets first, and nothing deeper:

- [`GETTING-STARTED.md`](../GETTING-STARTED.md) - the beginner path.
- [`docs/glossary.md`](../docs/glossary.md) - plain-language term definitions.
- [`docs/faq.md`](../docs/faq.md) and [`docs/cheatsheet.md`](../docs/cheatsheet.md).

### What stays English-only

Everything else, including: the code under `bin/`, `core/`, `scripts/` and `variants/`; the
engineering docs under `docs/engineering/`; the concept notes under `docs/concepts/`; ADRs under
`docs/decisions/`; the backlog; and every commit, PR and issue.

## Layout

Each locale is a subtree that mirrors the repo root, so a translated file sits at the same
relative path under its locale directory:

```
i18n/
  README.md              this policy
  <locale>/
    GETTING-STARTED.md   mirrors ../../GETTING-STARTED.md
    docs/
      glossary.md        mirrors ../../docs/glossary.md
      faq.md
      cheatsheet.md
```

`<locale>` is a lowercase [BCP 47](https://www.rfc-editor.org/info/bcp47) code - `de` for German,
`de-AT` for Austrian German, `pt-BR` for Brazilian Portuguese. Use the shortest code that is
unambiguous (`de`, not `de-DE`).

## Adding or updating a translation

1. Pick the locale code and create `i18n/<locale>/<same path as the English file>`.
2. Copy the English file and translate the prose. Keep every command, path, filename, code block
   and link target exactly as in the English source - translate only the words a human reads.
3. Start the file with the canonical-source header (below), pointing at the English original.
4. Link the translation from the top of its English source (e.g. "Deutsch: [i18n/de/...]").
5. Add the file to the status table below.
6. Run `make check` and open the PR against `develop` like any other change.

### Canonical-source header

Every translated file starts with a one-line note in the target language that marks English as
canonical and links to the source, so a reader who hits a discrepancy knows where truth lives.
For German:

```markdown
> Deutsche Uebersetzung von [`GETTING-STARTED.md`](../../GETTING-STARTED.md). Die englische
> Fassung ist massgeblich; bei Abweichungen gilt das Original.
```

## Status

| Source file | `de` |
| --- | --- |
| `GETTING-STARTED.md` | [done](de/GETTING-STARTED.md) |
| `docs/glossary.md` | [done](de/docs/glossary.md) |
| `docs/faq.md` | - |
| `docs/cheatsheet.md` | - |

Mark a cell done when its translation lands. Add a column when a new locale starts.

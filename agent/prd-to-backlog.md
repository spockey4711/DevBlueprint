# PRD -> intake + backlog

A prompt for the agent driving DevBlueprint setup. Given a Product Requirements Document
(PRD) the user uploads, extract everything the PRD already answers into a
`.devblueprint-intake.yml`, then - after the project is scaffolded - turn the PRD into a real,
prioritized `docs/project/backlog.md` and optional seed ADRs.

This is documentation the agent reads at setup time. It ships no runtime: every artifact it
produces is a plain file the user owns. The "runtime" is you, the agent.

## When to use this

Use this flow when the user has a written PRD, spec, one-pager, or design doc (Markdown or PDF)
for the project they want to scaffold. It complements, and does not replace, the ordered
question flow in [`setup-interview.md`](setup-interview.md): the PRD pre-fills the intake so the
interview only has to ask what the document leaves open.

If there is no PRD, skip this file and run the interview directly.

## What it produces

1. A pre-filled [`.devblueprint-intake.yml`](intake.example.yml) - the P3-1 intake schema that
   `devblueprint plan --from` and `init --from` consume. Only fields the PRD actually answers are
   filled; the rest are left blank for the interview.
2. After `init`, a populated `docs/project/backlog.md` - concrete P0/P1 tasks in the existing
   backlog format, each traceable to a section of the PRD.
3. Optionally, one or more seed ADRs under `docs/decisions/`, for architecturally significant
   choices the PRD already commits to.

## The flow end to end

```
PRD (md/pdf)
  -> [Phase 1] extract intake fields   -> .devblueprint-intake.yml  (pre-filled)
  -> [Phase 2] interview fills the gaps -> .devblueprint-intake.yml  (complete)   (setup-interview.md)
  -> [Phase 3] confirm + scaffold       -> project files            (devblueprint plan/init --from)
  -> [Phase 4] PRD -> backlog           -> docs/project/backlog.md  (P0/P1 tasks)
  -> [Phase 5] seed ADRs (optional)     -> docs/decisions/NNNN-*.md
```

Phases 1-3 run before disk is touched by `init`; phases 4-5 run against the freshly scaffolded
project.

---

## Phase 1 - PRD to intake

Read the whole PRD first. Then fill only the intake fields the document clearly answers. Never
guess to fill a slot: a blank field is a question the interview will ask; a wrong field is a
decision the user did not make. When a field is a judgement call, record the value you inferred
and flag it in your summary so the user can correct it in one word.

### The intake schema (draft - P3-1 is the source of truth)

The canonical schema and an annotated example live in
[`docs/agent/intake-schema.md`](../docs/agent/intake-schema.md) and
[`intake.example.yml`](intake.example.yml), shipped by P3-1. Until that lands, use the keys below,
which mirror the `devblueprint init` flags one to one; if P3-1's example differs, that file wins.

```yaml
# .devblueprint-intake.yml - a reproducible record of the setup answers.
name:      # project name           (-> init --name;    default: target dir name)
variant:   # stack variant          (-> init --variant; see `devblueprint list`)
main:      # deployable branch       (-> init --main;    default: master)
base:      # integration branch      (-> init --base;    default: develop; set == main for trunk)
community: # true|false              (-> init --community; open-source health files)
contact:   # security contact         (-> init --contact; email or URL, only if community)
deploy:    # deploy target           (-> deploy runbook selection; see values below)
```

Leave a key out (or blank) when the PRD does not answer it. Do not invent a `contact` address,
and do not set `community: true` unless the PRD states the project is open source or public.

### Mapping the PRD onto each field

- **name** - the product name from the PRD title or overview. Slug it for the directory if the
  user has not given a path.
- **variant** - detect the stack (see the table below). This is the highest-value field to get
  right, because it drives the whole scaffold.
- **main / base** - infer the branch strategy from team size and release cadence if the PRD
  states them: a solo project or an "MVP / ship fast" framing suggests trunk mode (`base` == `main`);
  a team or a described release/QA process suggests the two-branch default. If the PRD is silent,
  leave both blank and let the interview ask.
- **community / contact** - set `community: true` only when the PRD says the project is open
  source, public, or community-facing. Fill `contact` only if the PRD gives a security or support
  address. Otherwise leave both blank.
- **deploy** - detect the deploy target from any hosting/infra section (see values below).

### Stack detection -> variant

Match the strongest signals in the PRD against this table. Prefer an explicit technology the PRD
names over an inferred one. When two variants are plausible, pick the one matching the PRD's
primary surface (the thing the user interacts with) and flag the alternative in your summary.

| Variant          | PRD signals (technologies, phrases)                                          |
| ---------------- | ---------------------------------------------------------------------------- |
| `web-nextjs`     | web app, dashboard, SPA, frontend, Next.js, React, Vercel, "responsive UI"   |
| `node-express`   | REST/GraphQL API or service in Node/TypeScript, Express, webhooks            |
| `backend-python` | API or service in Python, FastAPI, Django, Flask                             |
| `data-python`    | ML, model, dataset, analytics, pipeline, notebook, pandas, training          |
| `backend-go`     | service or API in Go/Golang, high-throughput backend                         |
| `rust`           | CLI, systems, high-performance or memory-critical component in Rust          |
| `ios-swift`      | iOS, iPhone, iPad, App Store, Swift, SwiftUI                                  |
| `android-kotlin` | Android, Play Store, Kotlin, Jetpack Compose                                  |
| `generic`        | no clear stack, a language not covered above, or a polyglot/undecided PRD    |

Run `devblueprint list` to confirm the available variants before committing to one - the set can
grow. If nothing matches, choose `generic` rather than guessing; the user can change it in the
interview.

A PRD that describes both a web frontend and a separate backend is two projects (or a monorepo,
which the kit does not yet scaffold in one shot). Pick the primary surface for this intake, and
note in your summary that the second component needs its own `init`.

### Deploy target -> `deploy`

Read any hosting, infrastructure, or operations section. Map it to one of:

- `vps` - a rented server / VM the team runs (SSH, systemd, nginx).
- `docker` - containerized, deployed to any container host or orchestrator.
- `managed` - a PaaS (Vercel, Netlify, Fly, Render, Railway, App Engine, etc.).
- `static` - a static site or SPA served from a CDN / object storage.
- `none` - not decided yet, or out of scope for this stage.

Leave the field blank if the PRD is silent; the interview will ask. This value later selects which
section of the deploy runbook (P3-4) to keep.

### Hand off to the interview

Write the pre-filled `.devblueprint-intake.yml`, then summarize for the user in a short list:
what you filled and why (cite the PRD), and what you left blank. Then continue with
[`setup-interview.md`](setup-interview.md), which asks only the still-open questions before
calling `devblueprint plan --from .devblueprint-intake.yml` and, on confirmation,
`init --from .devblueprint-intake.yml`.

---

## Phase 2-3 - fill gaps, confirm, scaffold

These belong to the interview (P3-2) and the CLI (P3-1); this prompt only feeds them. In short:
the interview completes the intake, `plan --from` prints exactly what `init` would write, the
user confirms, and `init --from` scaffolds. Do not run `init` before the user has seen the plan.
Explicit flags override intake keys, so a single answer can be corrected without rewriting the
file.

Once `init` has run and the project is a git repo with the two long-lived branches (see
[`../GUIDE.md`](../GUIDE.md)), continue with Phase 4.

---

## Phase 4 - PRD to backlog

`init` writes a stub `docs/project/backlog.md`:

```markdown
# Backlog

The prioritized task list - the source of truth for what to build next. Reference an id in
commits and PRs (e.g. `Refs: P0-1`).

## P0 - foundation

- [ ] P0-1: ...
```

Replace the placeholder with real tasks derived from the PRD. Keep the header and the intro line;
these are the project's conventions.

### How to decompose the PRD

- **Read the PRD as scope, not as tasks.** Turn each requirement, user story, or acceptance
  criterion into one or more tasks. Every task must trace back to something the PRD states -
  never invent scope. If a requirement is ambiguous, write the task at the granularity the PRD
  supports and note the open question in the task line rather than inventing a decision.
- **One task = one logical, reviewable change** - the same unit as a single PR and commit under
  this repo's workflow. If a task needs more than a couple of days or touches many unrelated
  files, split it. Small tasks beat big ones.
- **Order by dependency and priority**, then number sequentially within each priority band.

### Priority bands

- **P0 - core promise / MVP.** The minimum for the product to do its one central job end to end.
  If a P0 task is cut, the MVP does not work. Derive these from the PRD's core use case and its
  must-have / "P0" / "launch blocker" requirements.
- **P1 - important, not launch-blocking.** Rounds out the MVP: secondary flows, hardening,
  polish, nice-to-haves the PRD calls out as follow-ups. Anything explicitly "later", "phase 2",
  or "out of scope" does not become a task - list it under a short `## Later` note at most.

Use only P0 and P1 here; the deeper bands are for the team to add as the project grows.

### Format

Match the existing backlog exactly: GitHub task-list checkboxes, `PN-M` ids, an imperative
title, then a sentence or two of scope. Group by priority under `## P0 - <theme>` /
`## P1 - <theme>`.

```markdown
## P0 - <core theme from the PRD>

- [ ] P0-1: <imperative summary>. <One or two sentences of scope, tracing to the PRD section.>
- [ ] P0-2: ...

## P1 - <secondary theme>

- [ ] P1-1: ...
```

Ids are referenced from commits and PRs (`Refs: P0-1`), so once written they are stable - append
new tasks with new ids rather than renumbering.

### After writing the backlog

Summarize the P0 set for the user and ask them to confirm the MVP boundary before they start
work. Committing the backlog is itself a small change: commit it on its own branch/worktree per
the project's workflow, not directly on `develop`/`master`.

---

## Phase 5 - seed ADRs (optional)

Only when the PRD commits to an architecturally significant decision - a technology boundary, a
data model, a cross-cutting dependency, an integration the whole design leans on. Do not
manufacture ADRs for choices the PRD leaves open; a decision nobody has made yet is not an ADR.

For each such decision, copy [`../docs/decisions/NNNN-template.md`](../docs/decisions/NNNN-template.md)
to `docs/decisions/NNNN-short-title.md` (next sequential number), and fill Context / Decision /
Consequences from the PRD's own reasoning. Start the status at `Proposed` unless the PRD states
the decision is settled, in which case `Accepted`. Add each to the
[`docs/decisions/README.md`](../docs/decisions/README.md) index. Keep the record to the rationale
the PRD actually gives; do not embellish.

---

## Guardrails

- **Never invent scope.** Every intake value, backlog task, and ADR must trace to the PRD. When
  the PRD is silent, leave the field blank (Phase 1) or ask (later phases) - do not fill the gap
  with an assumption.
- **Flag inferences.** Anything you deduced rather than read verbatim - the variant, the branch
  strategy, the deploy target - gets called out in your summary so the user can correct it cheaply.
- **The user owns the boundary.** Confirm the intake before scaffolding and the P0 set before
  work starts. You draft; the user decides.
- **Plain files, no lock-in.** Everything here is a file the user edits freely. Produce nothing
  that assumes DevBlueprint stays installed.
- **House style.** English throughout; regular hyphens only, no emojis or fancy dashes; match the
  format of the file you are writing into.

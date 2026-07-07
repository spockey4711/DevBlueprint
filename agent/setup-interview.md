# Setup interview

The canonical, ordered question flow an AI assistant runs to scaffold a project with
DevBlueprint. It turns a short conversation into a reproducible
[`.devblueprint-intake.yml`](../docs/agent/intake-schema.md), previews the scaffold with
`devblueprint plan --from`, and - once the user confirms - runs `devblueprint init --from`.

The interview is deliberately small. It asks **only** the questions below, in this order, and
maps each answer onto one intake key. It never invents scope: no extra features, no files the
user did not ask for, no variants that are not in `devblueprint list`. If the user has not
decided something, offer the default and move on.

## How to run it

1. Run `devblueprint list` so you have the real variant names and titles to offer (add `--json`
   to parse them instead of the human table). Never guess a variant that is not printed.
2. Ask the questions in [Question flow](#question-flow) below, one at a time. Stop as soon as
   you have enough to fill every required intake key; skip any question the user already
   answered (for example, when a PRD pre-filled the file - see
   [`prd-to-backlog.md`](prd-to-backlog.md)).
3. Write `.devblueprint-intake.yml` in the target directory (schema in
   [Intake file](#intake-file-written)).
4. Run `devblueprint plan --from .devblueprint-intake.yml` and show the user exactly what init
   would write. **Do not touch disk before this preview.**
5. On confirmation, run `devblueprint init --from .devblueprint-intake.yml`, then point the
   user at the next steps init prints (`./setup.sh`, `git init`, first worktree).

Explicit flags still win over the file, so if the user changes one answer after the preview you
can re-run with an override (for example `devblueprint init --from .devblueprint-intake.yml
--base master`) instead of rewriting the file.

## Question flow

Ask these five, in order. Each maps to one or two intake keys.

### 1. Purpose and name

> What are you building, and what should the project be called?

- The name maps to `name` (also the default `--target` directory if the user is scaffolding
  in place). Keep it as a short slug the user gives; do not embellish it.
- The purpose is not stored in the intake file - it only helps you recommend a variant in the
  next question and, if the user later runs the PRD flow, seed the backlog. Do not turn the
  purpose into features here.

### 2. Stack -> variant

> Which stack is this? (from `devblueprint list`)

- Offer the variants printed by `devblueprint list`. If the purpose points clearly at one
  (a web app -> `web-nextjs`, an HTTP API in Go -> `backend-go`, a CLI or unlisted stack ->
  `generic`), recommend it, but let the user pick.
- Maps to `variant`. Required. If nothing fits, use `generic` - never fabricate a variant.

### 3. Deploy target

> Where will this run in production?

- Offer: `vps` (a server you manage), `docker` (a container image / compose), `managed` (a
  PaaS such as a managed app platform), or `none` (library, CLI, or undecided).
- Maps to `deploy_target`. This only selects which deployment runbook section a variant keeps;
  it does not provision anything. When unsure, use `none`.

### 4. Solo vs. team -> branch strategy

> Is this solo or a team, and do you want the two-branch release flow or a single trunk?

- Team or "I want staged releases" -> the two-branch flow: `base_branch: develop`,
  `main_branch: master` (the defaults). Feature work integrates on `develop`, promoted to
  `master` by a periodic release PR.
- Solo or "keep it simple" -> a single-branch trunk: set `base_branch` equal to `main_branch`
  (for example both `master`). Still worktrees, still PRs, still the gate.
- Maps to `base_branch` and `main_branch`. If the user has a house branch name (`main`), use
  it for `main_branch`; otherwise keep the defaults.

### 5. License and community

> Is this public / open source? Should I add community-health files, and to what contact?

- Public and wants a security policy + code of conduct -> `community: true` and set `contact`
  to the reporting email or URL the user gives.
- Private or solo -> `community: false` and leave `contact` empty. These files are off by
  default and not required by `doctor`.
- Maps to `community` and `contact`. Do not add a license file here - that is the user's
  choice and outside this kit's scope; just record whether the project is public.

## Intake file written

Write exactly these keys. Omit nothing required; leave optional keys at their defaults rather
than inventing values. This mirrors the schema in
[`docs/agent/intake-schema.md`](../docs/agent/intake-schema.md) (owned by the CLI); if the two
ever disagree, the schema doc wins.

```yaml
# .devblueprint-intake.yml - reproducible answers for `devblueprint init --from`.
# Written by the setup interview; safe to hand-edit and re-run.
name: myapp                 # project name (question 1)
variant: web-nextjs         # from `devblueprint list` (question 2)
deploy_target: vps          # vps | docker | managed | none (question 3)
base_branch: develop        # integration branch; set == main_branch for a trunk flow (question 4)
main_branch: master         # stable, always-deployable branch (question 4)
community: false            # add SECURITY.md + CODE_OF_CONDUCT.md (question 5)
contact: ""                 # email or URL; used only when community is true (question 5)
target: .                   # directory to scaffold into; defaults to the project root
```

## Guardrails

- **Ask only the five questions above.** If the user volunteers more (features, milestones),
  acknowledge it but do not act on it here - that belongs to the backlog, not the scaffold.
- **Preview before writing.** Always run `plan --from` and get confirmation before `init`.
- **Prefer defaults over invention.** An unanswered question takes its documented default; it
  never becomes a guess.
- **Never invent a variant or a file.** Everything init writes is a plain file the user owns;
  the interview does not add anything init would not.

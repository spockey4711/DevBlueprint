# Release Readiness: Version 0.1

## Scope Check

- [x] CLI initialization exists.
- [x] Base, Web App, API Backend, iOS App, Portfolio, and Custom structures exist.
- [x] `AGENTS.md` generation exists.
- [x] Feature spec generation exists.
- [x] Decision record generation exists.
- [x] Context-pack output exists.
- [x] Doctor checks exist.
- [x] Prompt library exists.
- [x] At least three examples exist.
- [x] README, GUIDE, and STANDARDS exist.

## Verification

- [x] `npm test`
- [x] `npm run test:coverage`
- [x] Smoke test `init`
- [x] Smoke test `add feature`
- [x] Smoke test `add decision`
- [x] Smoke test `context`
- [x] Smoke test `doctor`

## MVP-FREEZE Review

Before publishing Version 0.1, compare the release contents against `docs/01-product/MVP-FREEZE.md` and move non-MVP work to `docs/04-tasks/BACKLOG.md`.

## Manual Release Steps

- [ ] Review generated examples.
- [ ] Review npm package metadata.
- [ ] Confirm executable permissions on `bin/apkit.js`.
- [ ] Create a clean checkout and run `npm test`.
- [ ] Tag the release after the checklist is complete.

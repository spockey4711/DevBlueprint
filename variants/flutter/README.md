# Variant: Flutter app (Dart)

A typed, statically-analyzed Flutter stack: `dart format` (canonical formatting), `flutter analyze`
(lint + types in one pass) with `very_good_analysis` and strict analyzer modes, `flutter test`
(unit + widget), FVM/`.tool-versions` for a pinned SDK, GitHub Actions CI.

## Quality gate

```bash
dart format --output=none --set-exit-if-changed . && flutter analyze && flutter test
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant flutter` adds

- `docs/engineering/` - git-workflow, conventions (+ Flutter/Dart overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `flutter pub get`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/ci.yml` (dart format + flutter analyze + flutter test).
- `.github/dependabot.yml` (pub + github-actions updates) and `.tool-versions` (SDK pin).
- `.gitignore` for Dart/Flutter build and generated artifacts.
- `lib/`, `lib/src/`, `test/` and an `integration_test/` scaffold.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. Run it once:

```bash
./setup.sh              # writes pubspec.yaml, analysis_options.yaml (very_good_analysis +
                        # strict analyzer modes), .fvmrc, a placeholder lib/main.dart + test,
                        # .pre-commit-config.yaml, then `flutter pub get` + installs the hook
./setup.sh --no-install # config only
```

Idempotent; never clobbers existing files.

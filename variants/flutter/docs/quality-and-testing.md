# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Flutter project. Concrete overlay of
the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
dart format --output=none --set-exit-if-changed .   # formatting is canonical
flutter analyze                                     # lint + static types - zero warnings
flutter test                                        # unit + widget tests
```

`flutter analyze` is both lint and type check: Dart is statically typed, so there is no separate
typecheck step. `very_good_analysis` plus the analyzer `strict-*` language modes make it strict -
every warning fails the gate.

## Testing strategy

Test what has logic or can silently break; do not chase coverage on trivial presentational widgets.

- **Unit (`flutter test`):** plain-Dart logic moved out of widgets - repositories, use-cases,
  mappers, validators, formatters. Deterministic; inject clocks/RNG rather than reading wall time.
- **Widget tests:** pump a widget with `WidgetTester`, drive interactions, assert on the rendered
  tree (`find.text`, `find.byType`). Cover the states that matter: loading, empty, error, success.
- **Golden tests (optional):** pixel-compare stable, design-critical widgets; keep goldens small
  and regenerate deliberately.
- **Integration (`integration_test/`):** exercise real end-to-end flows on a device/emulator for
  the critical paths, not every screen.

Keep widgets thin: once a build method carries real logic, extract it into a testable Dart class and
test that directly rather than through the widget tester.

Target: meaningful coverage of the logic under `lib/src/` and the critical user flows, not a global
percentage or every `const` widget.

## Tooling

- **dart format** - the canonical formatter; `--set-exit-if-changed` turns "unformatted" into a
  gate failure. Never hand-format.
- **flutter analyze** - static analysis (lint + types) driven by `analysis_options.yaml`.
  `very_good_analysis` is the ruleset; `strict-casts` / `strict-inference` / `strict-raw-types`
  tighten the type system. Zero warnings.
- **flutter test** - unit, widget and golden tests under `test/`; add `--coverage` to emit
  `coverage/lcov.info`.
- **pre-commit** - the `pre-commit` framework runs `dart format` and `flutter analyze` on staged
  Dart files so the gate holds on every commit.
- **FVM / .tool-versions** - pin one Flutter SDK (Dart ships inside it) so local and CI match.
- **CI** - `.github/workflows/ci.yml` runs the full gate on every PR into `develop`/`master`.

## Definition of done

1. It works on the target platforms and the feature behaves as specified.
2. `dart format`, `flutter analyze` and `flutter test` are green; no unjustified `// ignore:`.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.

## Stack notes (Flutter / Dart)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `flutter pub get`, since each
  worktree is a separate checkout with its own `.dart_tool/`).
- Layered: keep `main.dart` thin. Feature code, widgets and state live under `lib/src/`;
  `lib/<feature>.dart` files are the public surface. Widgets stay presentational - push logic into
  plain-Dart classes that are unit-testable without a widget tester.
- `flutter analyze` is lint **and** type check in one pass (Dart is statically typed).
  `very_good_analysis` plus the analyzer `strict-*` language modes are the strict bar; treat every
  analyzer warning as an error. `dart format` is canonical - never hand-format.
- User-facing strings live in ARB files under `lib/l10n` (`AppLocalizations`), never hard-coded in
  widgets. Read config, endpoints and secrets from the environment, not from source.
- Commit `pubspec.lock` for an application (reproducible builds); ignore it for a reusable package.
  Generated code (`*.g.dart`, `*.freezed.dart`) is gitignored - regenerate with `build_runner`.
- Pin the Flutter SDK in `.fvmrc` and `.tool-versions`; keep them in step with pubspec's
  `environment:` constraints.

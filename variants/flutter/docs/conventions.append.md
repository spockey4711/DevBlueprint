
---

## Stack-specific conventions (Flutter / Dart)

### Language & tooling

- **`flutter analyze` must be clean** - it is lint and type check in one pass. `very_good_analysis`
  plus the analyzer `strict-casts` / `strict-inference` / `strict-raw-types` modes are the bar;
  treat every warning as an error. No `// ignore:` without a justifying comment.
- **`dart format` owns formatting** - do not hand-format, and never disable it for a region.
  The gate runs `dart format --output=none --set-exit-if-changed .`.
- Prefer precise types over `dynamic`; annotate public APIs. Avoid `late` unless the
  initialization order genuinely requires it, and never `!` a nullable without a real invariant.
- Pin one Flutter SDK in `.fvmrc`, `.tool-versions` and pubspec's `environment:` - keep them in
  step.

### Widgets vs. logic

- Keep `main.dart` thin. Feature code lives under `lib/src/`; expose a small public surface via
  `lib/<feature>.dart`. Widgets are presentational - push business logic into plain-Dart classes
  that are unit-testable without a `WidgetTester`.
- Prefer `const` constructors and small, composable widgets over deep build methods. Split a build
  method before it needs a comment to navigate.
- Manage state with one deliberate approach (e.g. Riverpod, Bloc, or `ValueNotifier`) rather than
  mixing several; keep state objects free of `BuildContext`.

### Strings, config & secrets

- User-facing strings live in ARB files under `lib/l10n` (`AppLocalizations`), never hard-coded in
  widgets. Add the string to the ARB file, not inline.
- Read endpoints, flags and credentials from the environment or a config layer - no secrets in
  source, logs, or committed `.env` files (keep only `.env.example`).

### Naming & structure

- Files and directories `snake_case.dart`; types `PascalCase`; members and locals `lowerCamelCase`;
  compile-time constants `lowerCamelCase` (Dart style, not `UPPER_SNAKE`).
- One public class per file where practical; name the file after it (`user_repository.dart`).
- Generated code (`*.g.dart`, `*.freezed.dart`) is never edited by hand or committed - regenerate
  it with `build_runner`.

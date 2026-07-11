#!/usr/bin/env bash
# setup.sh - wire the Flutter/Dart toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + `flutter pub get` + install pre-commit hook
#   ./setup.sh --no-install # wire config only
set -euo pipefail

DO_INSTALL=1
[ "${1:-}" = "--no-install" ] && DO_INSTALL=0

say() { printf '  %s\n' "$*"; }
write_if_absent() {
  if [ -e "$1" ]; then say "skip $1 (exists)"; return 0; fi
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  say "wrote $1"
}

# Dart package names must be lowercase_with_underscores (no hyphens, no leading
# digit), so derive a valid name from the directory rather than using it raw.
PKG="$(basename "$PWD" | tr '[:upper:]-' '[:lower:]_' | tr -cd 'a-z0-9_')"
[ -n "$PKG" ] || PKG="app"
case "$PKG" in [0-9]*) PKG="app_$PKG" ;; esac

FLUTTER_VERSION="3.27.1"

echo "Wiring the Flutter toolchain..."

# --- SDK pin -----------------------------------------------------------------
# .fvmrc is the pin FVM honors; .tool-versions (from the variant's extras/) is
# the asdf/mise mirror. Keep the two in step.
write_if_absent .fvmrc <<EOF
{
  "flutter": "$FLUTTER_VERSION"
}
EOF

# --- pubspec.yaml (deps + SDK constraints) -----------------------------------
write_if_absent pubspec.yaml <<EOF
name: $PKG
description: A Flutter application.
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ^3.6.0
  flutter: ">=$FLUTTER_VERSION"

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis: ^7.0.0

flutter:
  uses-material-design: true
EOF

# --- analyzer config (lint + strict type modes) ------------------------------
# very_good_analysis is a strict lint ruleset; the analyzer's strict-* language
# modes turn implicit casts/dynamic and raw types into errors - the Dart analog
# of "no untyped code". flutter analyze reads this file.
write_if_absent analysis_options.yaml <<'EOF'
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    # Warnings are errors in CI: the gate must be clean, not merely non-fatal.
    missing_required_param: error
    missing_return: error
EOF

# --- minimal app + test so the gate is green from the first commit -----------
# init drops an empty lib/; give it an entrypoint (and a widget test) so
# `flutter analyze` and `flutter test` pass from day one. Replace with real code.
if [ -z "$(find lib -name '*.dart' 2>/dev/null | head -n 1)" ]; then
  write_if_absent lib/main.dart <<'EOF'
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Application root. Placeholder - replace with your real widget tree.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      home: Scaffold(
        appBar: AppBar(title: const Text('App')),
        body: const Center(child: Text('Hello, Flutter')),
      ),
    );
  }
}
EOF
fi

if [ -z "$(find test -name '*_test.dart' 2>/dev/null | head -n 1)" ]; then
  # Unquoted heredoc so the package import resolves to the real package name;
  # this file has no other shell-special characters to escape.
  write_if_absent test/widget_test.dart <<EOF
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:$PKG/main.dart';

void main() {
  testWidgets('renders the placeholder greeting', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Hello, Flutter'), findsOneWidget);
  });
}
EOF
fi

# --- pre-commit framework config ---------------------------------------------
# No published pre-commit repo ships dart format / flutter analyze, so these are
# local hooks that call the SDK already on PATH.
write_if_absent .pre-commit-config.yaml <<'EOF'
repos:
  - repo: local
    hooks:
      - id: dart-format
        name: dart format
        entry: dart format --output=none --set-exit-if-changed
        language: system
        types: [dart]
      - id: flutter-analyze
        name: flutter analyze
        entry: flutter analyze
        language: system
        pass_filenames: false
        types: [dart]
EOF

# --- install deps + hook -----------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && command -v flutter >/dev/null 2>&1; then
  echo "Fetching packages (flutter pub get)..."
  flutter pub get || say "flutter pub get failed - run it manually"
  if command -v pre-commit >/dev/null 2>&1; then
    pre-commit install || say "pre-commit install skipped"
  else
    say "pre-commit not found - skipping hook install (pip install pre-commit)"
  fi
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && {
  echo "Still to run yourself:"
  echo "  flutter pub get"
  echo "  pre-commit install"
}
echo "Then: git init && git switch -c develop"
echo "Verify the gate: dart format --output=none --set-exit-if-changed . && flutter analyze && flutter test"

# Quality gate for a Flutter app (Dart). `make check` runs the whole gate; CI
# calls the same targets. `dart`/`flutter` come from the pinned Flutter SDK.
.PHONY: check format lint typecheck analyze test clean

check: format lint test

# `dart format` is both the formatter and the format check; --set-exit-if-changed
# makes the check fail (non-zero) when anything is unformatted.
format:
	dart format --output=none --set-exit-if-changed .

# `flutter analyze` is the static analyzer - it covers lint and type errors in
# one pass (Dart is statically typed, so there is no separate typecheck step).
lint analyze typecheck:
	flutter analyze

fix:
	dart format .
	dart fix --apply

test:
	flutter test

clean:
	flutter clean
	rm -rf .dart_tool coverage

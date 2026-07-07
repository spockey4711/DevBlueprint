#!/usr/bin/env bash
# setup.sh - wire the Android Kotlin/Gradle toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + install ktlint/detekt (brew)
#   ./setup.sh --no-install # wire config only
#
# It does NOT create the Gradle/Android Studio project - do that first (New
# Project in Android Studio, or `gradle init`), then wire ktlint + detekt as
# Gradle plugins (see the note printed at the end).
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

echo "Wiring the Android Kotlin toolchain..."

# --- detekt config -----------------------------------------------------------
write_if_absent config/detekt/detekt.yml <<'EOF'
# detekt configuration - https://detekt.dev/docs/introduction/configurations
# Fail the build on any finding so the gate stays meaningful.
build:
  maxIssues: 0

complexity:
  active: true
  LongMethod:
    threshold: 60
  TooManyFunctions:
    active: false

naming:
  active: true

style:
  active: true
  MaxLineLength:
    maxLineLength: 120
  MagicNumber:
    active: false
  ForbiddenComment:
    active: false

exceptions:
  active: true
  TooGenericExceptionCaught:
    active: true
EOF

# --- ktlint config via .editorconfig -----------------------------------------
# ktlint reads its rule config from .editorconfig. The core .editorconfig already
# ships baseline settings; append a Kotlin section (guarded by a marker) so we
# never clobber it and stay idempotent.
EC=.editorconfig
if [ -f "$EC" ] && grep -q 'ktlint_code_style' "$EC" 2>/dev/null; then
  say "skip .editorconfig ktlint block (already present)"
else
  cat >> "$EC" <<'EOF'

# --- ktlint (Kotlin) ---------------------------------------------------------
[*.{kt,kts}]
ktlint_code_style = android_studio
ktlint_standard_no-wildcard-imports = enabled
max_line_length = 120
EOF
  say "appended ktlint block to $EC"
fi

# --- pre-commit hook (committable, via core.hooksPath) -----------------------
# Uses the standalone ktlint/detekt CLIs when present (fast); falls back to the
# Gradle tasks otherwise so the hook still gates a project without the CLIs.
write_if_absent .githooks/pre-commit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if command -v ktlint >/dev/null 2>&1; then
  ktlint --relative
elif [ -x ./gradlew ]; then
  ./gradlew --quiet ktlintCheck
fi
if command -v detekt >/dev/null 2>&1; then
  detekt --config config/detekt/detekt.yml
elif [ -x ./gradlew ]; then
  ./gradlew --quiet detekt
fi
EOF
chmod +x .githooks/pre-commit 2>/dev/null || true
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config core.hooksPath .githooks && say "set core.hooksPath = .githooks"
else
  say "not a git repo yet - after 'git init' run: git config core.hooksPath .githooks"
fi

# --- install the CLIs --------------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && command -v brew >/dev/null 2>&1; then
  echo "Installing ktlint + detekt (brew)..."
  brew install ktlint detekt || say "brew install failed - run it manually"
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && echo "Still to run yourself:  brew install ktlint detekt"
cat <<'EOF'
Still to do yourself (setup.sh cannot create the Gradle project):
  1. Create the Android project (Android Studio "New Project", or `gradle init`).
  2. Add the ktlint + detekt Gradle plugins so `make check` / CI resolve their tasks:
       plugins {
         id("org.jlleitschuh.gradle.ktlint") version "12.1.1"
         id("io.gitlab.arturbosch.detekt") version "1.23.6"
       }
       detekt { config.setFrom("config/detekt/detekt.yml") }
  3. Target JDK 17 (compileOptions/kotlinOptions jvmTarget = "17").
Verify the gate: ./gradlew ktlintCheck detekt lintDebug testDebugUnitTest
EOF

#!/usr/bin/env bash
# setup.sh - wire the Java + Spring Boot (Gradle) toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + warm the Gradle wrapper
#   ./setup.sh --no-install # wire config only
#
# It does NOT create the Spring Boot project itself - generate that first with
# Spring Initializr (https://start.spring.io, Gradle + Java) or `gradle init`,
# then add the Spotless + Checkstyle plugins (see the note printed at the end).
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

JAVA_VERSION="21"

echo "Wiring the Java + Spring Boot toolchain..."

# --- version pin -------------------------------------------------------------
[ -f .java-version ] || { printf '%s\n' "$JAVA_VERSION" > .java-version; say "wrote .java-version"; }

# --- Checkstyle config -------------------------------------------------------
# A trimmed Google-style ruleset. Checkstyle enforces it over main + test
# sources; tune the checks to taste. Kept self-contained so the gate runs
# without pulling a config off the network.
write_if_absent config/checkstyle/checkstyle.xml <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE module PUBLIC
  "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN"
  "https://checkstyle.org/dtds/configuration_1_3.dtd">
<!-- Checkstyle rules for a Spring Boot service. Fail the build on any violation
     so the gate stays meaningful. See https://checkstyle.org/checks.html -->
<module name="Checker">
  <property name="charset" value="UTF-8"/>
  <property name="severity" value="error"/>
  <property name="fileExtensions" value="java, properties, xml"/>

  <module name="LineLength">
    <property name="max" value="120"/>
    <property name="ignorePattern" value="^package.*|^import.*|href|http://|https://"/>
  </module>

  <module name="TreeWalker">
    <module name="AvoidStarImport"/>
    <module name="RedundantImport"/>
    <module name="UnusedImports"/>
    <module name="OneTopLevelClass"/>
    <module name="NeedBraces"/>
    <module name="EmptyStatement"/>
    <module name="EqualsHashCode"/>
    <module name="MissingOverride"/>
    <module name="ModifierOrder"/>
    <module name="PackageName">
      <property name="format" value="^[a-z]+(\.[a-z][a-z0-9]*)*$"/>
    </module>
    <module name="TypeName"/>
    <module name="MethodName"/>
    <module name="ConstantName"/>
    <module name="LocalVariableName"/>
    <module name="MemberName"/>
    <module name="ParameterName"/>
  </module>
</module>
EOF

# --- pre-commit hook (committable, via core.hooksPath) -----------------------
# Runs the fast formatter check and Checkstyle through the Gradle wrapper so a
# style slip never reaches CI. No-op when the wrapper is not present yet.
write_if_absent .githooks/pre-commit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ -x ./gradlew ]; then
  ./gradlew --quiet spotlessCheck checkstyleMain
fi
EOF
chmod +x .githooks/pre-commit 2>/dev/null || true
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config core.hooksPath .githooks && say "set core.hooksPath = .githooks"
else
  say "not a git repo yet - after 'git init' run: git config core.hooksPath .githooks"
fi

# --- warm the Gradle wrapper -------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && [ -x ./gradlew ]; then
  echo "Warming the Gradle wrapper..."
  ./gradlew --quiet help >/dev/null 2>&1 || say "./gradlew help failed - run it manually"
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && echo "Still to run yourself:  ./gradlew help  (once the wrapper exists)"
cat <<'EOF'
Still to do yourself (setup.sh cannot create the Spring Boot project):
  1. Generate the project (https://start.spring.io - Gradle + Java 21, or `gradle init`),
     keeping the Gradle wrapper (gradlew / gradle-wrapper.properties).
  2. Add the Spotless + Checkstyle plugins so `make check` / CI resolve their tasks:
       plugins {
         id 'com.diffplug.spotless' version '6.25.0'
         id 'checkstyle'
       }
       java { toolchain { languageVersion = JavaLanguageVersion.of(21) } }
       spotless { java { googleJavaFormat() } }
       checkstyle { toolVersion = '10.18.2'; configFile = file('config/checkstyle/checkstyle.xml') }
  3. Confirm the tests run under JUnit 5 (`test { useJUnitPlatform() }`).
Verify the gate: ./gradlew spotlessCheck checkstyleMain checkstyleTest test
EOF

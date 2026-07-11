#!/usr/bin/env bash
# setup.sh - wire the C# / .NET toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + warm the NuGet cache (dotnet restore)
#   ./setup.sh --no-install # wire config only
#
# It does NOT create the .NET solution itself - generate that first with
# `dotnet new` (see the note printed at the end), then the pinned SDK, analyzers
# and formatting rules wired here apply to every project in the tree.
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

SDK_VERSION="10.0.100"

echo "Wiring the C# / .NET toolchain..."

# --- SDK pin -----------------------------------------------------------------
# global.json pins the SDK so local, CI and teammates build with the same
# toolchain. rollForward latestFeature allows patch/feature updates within the
# pinned major.minor band. Keep this in sync with .tool-versions and CI.
write_if_absent global.json <<EOF
{
  "sdk": {
    "version": "$SDK_VERSION",
    "rollForward": "latestFeature"
  }
}
EOF

# --- shared build properties -------------------------------------------------
# Directory.Build.props is imported by every project in the tree, so these
# settings (nullable reference types, warnings-as-errors, the Roslyn analyzers
# and .editorconfig-driven code style enforced in the build) apply everywhere
# without repeating them per .csproj.
write_if_absent Directory.Build.props <<'EOF'
<Project>
  <PropertyGroup>
    <LangVersion>latest</LangVersion>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <EnableNETAnalyzers>true</EnableNETAnalyzers>
    <AnalysisLevel>latest-recommended</AnalysisLevel>
    <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
  </PropertyGroup>
</Project>
EOF

# --- pre-commit hook (committable, via core.hooksPath) -----------------------
# Runs the formatter/style/analyzer check through the SDK so a style slip never
# reaches CI. No-op when the SDK is not installed yet.
write_if_absent .githooks/pre-commit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if command -v dotnet >/dev/null 2>&1; then
  dotnet format --verify-no-changes
fi
EOF
chmod +x .githooks/pre-commit 2>/dev/null || true
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config core.hooksPath .githooks && say "set core.hooksPath = .githooks"
else
  say "not a git repo yet - after 'git init' run: git config core.hooksPath .githooks"
fi

# --- warm the NuGet cache ----------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && command -v dotnet >/dev/null 2>&1; then
  echo "Warming the NuGet cache (dotnet restore)..."
  dotnet restore >/dev/null 2>&1 || say "dotnet restore failed - run it manually once a project exists"
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && echo "Still to run yourself:  dotnet restore  (once a project exists)"
cat <<'EOF'
Still to do yourself (setup.sh cannot create the .NET solution):
  1. Scaffold the solution and projects, keeping global.json at the root:
       dotnet new sln --name App
       dotnet new webapi -o src/App
       dotnet new xunit -o tests/App.Tests
       dotnet sln add src/App tests/App.Tests
       dotnet add tests/App.Tests reference src/App
  2. Directory.Build.props already turns on nullable, warnings-as-errors and the
     Roslyn analyzers for every project - no per-.csproj wiring needed.
  3. Confirm the tests run under xUnit (the `dotnet new xunit` template wires the
     Microsoft.NET.Test.Sdk + xunit.runner.visualstudio adapters).
Verify the gate: dotnet format --verify-no-changes && dotnet build -c Release && dotnet test
EOF

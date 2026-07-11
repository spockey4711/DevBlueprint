# Quality gate for a C# / .NET project. `make check` runs the whole gate; CI
# calls the same dotnet commands. The SDK version is pinned in global.json so
# local, CI and teammates build with the same toolchain.
.PHONY: check validate-env lint format format-check test build run clean restore

check: validate-env format-check lint test

# Enforce the environment contract: .env.example must stay in lockstep with
# .env.schema, and a real .env (if present) must satisfy every required key. This
# is stack-agnostic and always on - fill in the schema, not this target.
validate-env:
	@sh scripts/check-env.sh

# format-check verifies whitespace/formatting is canonical; lint runs the code
# style + Roslyn analyzer rules (severity driven by .editorconfig, enforced in
# the build via Directory.Build.props). Kept as separate targets so a red one is
# obvious. Their union equals `dotnet format --verify-no-changes`.
format-check:
	dotnet format whitespace --verify-no-changes

lint:
	dotnet format style analyzers --verify-no-changes

format:
	dotnet format

test:
	dotnet test

build:
	dotnet build --configuration Release

run:
	dotnet run

restore:
	dotnet restore

clean:
	dotnet clean

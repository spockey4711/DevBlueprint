#!/usr/bin/env bash
# setup.sh - wire the Elixir / Phoenix toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + warm the deps cache
#   ./setup.sh --no-install # wire config only
#
# It does NOT create the Phoenix application itself - generate that first with
# `mix phx.new .` (see the note printed at the end), then the mix format, Credo,
# Dialyzer and ExUnit tooling wired here applies to it.
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

echo "Wiring the Elixir / Phoenix toolchain..."

# --- formatter config --------------------------------------------------------
# `mix format` owns formatting; the rules live in .formatter.exs. `mix phx.new`
# writes a richer one (with the Phoenix/Ecto import_deps) - this bare fallback
# only lands when you run setup.sh before scaffolding. `mix format` fixes,
# `mix format --check-formatted` gates.
write_if_absent .formatter.exs <<'EOF'
# Formatter config for `mix format`. After `mix phx.new` regenerates this file,
# keep import_deps/subdirectories so Phoenix's and Ecto's macros stay aligned.
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
EOF

# --- static analysis config (Credo) ------------------------------------------
# Credo owns style, consistency and complexity checks. `mix credo --strict`
# gates. Requires `mix deps.get` after adding :credo to mix.exs (see the note at
# the end). Generate the full annotated config any time with `mix credo gen.config`.
write_if_absent .credo.exs <<'EOF'
# Credo configuration. `mix credo --strict` gates; run `mix credo gen.config` to
# regenerate the fully annotated version. Zero issues in CI.
%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
        excluded: [~r"/_build/", ~r"/deps/"]
      },
      strict: true,
      checks: %{
        enabled: [
          {Credo.Check.Readability.ModuleDoc, false}
        ]
      }
    }
  ]
}
EOF

# --- pre-commit hook (committable, via core.hooksPath) -----------------------
# Runs the formatter check + Credo through mix so a style slip or lint error
# never reaches CI. No-op before `mix deps.get` has fetched Credo.
write_if_absent .githooks/pre-commit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if command -v mix >/dev/null 2>&1 && [ -f mix.exs ]; then
  mix format --check-formatted
  # Credo only exists once it is a dependency; run it when the task is available.
  if mix help credo >/dev/null 2>&1; then
    mix credo --strict
  fi
fi
EOF
chmod +x .githooks/pre-commit 2>/dev/null || true
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config core.hooksPath .githooks && say "set core.hooksPath = .githooks"
else
  say "not a git repo yet - after 'git init' run: git config core.hooksPath .githooks"
fi

# --- warm the deps cache -----------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && command -v mix >/dev/null 2>&1 && [ -f mix.exs ]; then
  echo "Fetching Hex dependencies..."
  mix deps.get >/dev/null 2>&1 \
    || say "mix deps.get failed - run it manually once mix.exs is set up"
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && echo "Still to run yourself:  mix deps.get  (once mix.exs exists)"
cat <<'EOF'
Still to do yourself (setup.sh cannot create the Phoenix application):
  1. Scaffold the app into this directory (keep the repo root as the project root):
       mix phx.new .            # or `mix phx.new . --no-ecto` for an app without a database
  2. Add the dev/test tooling the gate expects to mix.exs `deps/0`, then fetch:
       {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
       {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
       {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
       {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false}
       mix deps.get
  3. Point Dialyzer at a cached PLT so CI and local runs are fast - add to mix.exs
     `project/0`:
       dialyzer: [plt_local_path: "priv/plts", plt_core_path: "priv/plts"]
  4. Pin the toolchain in mix.exs so CI and teammates match .tool-versions:
       elixir: "~> 1.18"      # and set the OTP version via .tool-versions / CI
Verify the gate: mix format --check-formatted && mix credo --strict && mix dialyzer && mix test
EOF

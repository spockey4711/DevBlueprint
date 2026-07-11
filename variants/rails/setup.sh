#!/usr/bin/env bash
# setup.sh - wire the Ruby on Rails toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + install gems (bundle install)
#   ./setup.sh --no-install # wire config only
#
# It does NOT create the Rails app itself - generate that first with
# `rails new` (see the note printed at the end), then the pinned Ruby version,
# RuboCop ruleset and Brakeman scan wired here apply to the app in the tree.
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

RUBY_VERSION="3.4.2"

echo "Wiring the Ruby on Rails toolchain..."

# --- Ruby version pin --------------------------------------------------------
# .ruby-version pins the interpreter so local, CI and teammates run one Ruby.
# rbenv / chruby / asdf all read it; keep it in sync with .tool-versions and CI.
write_if_absent .ruby-version <<EOF
$RUBY_VERSION
EOF

# --- RuboCop config ----------------------------------------------------------
# Inherit the rubocop-rails-omakase ruleset (the default Rails 8 house style) so
# formatting and lint are the same everywhere. Add project overrides below the
# inherit line; do not hand-format - run `bundle exec rubocop -A` to fix.
write_if_absent .rubocop.yml <<'EOF'
inherit_gem:
  rubocop-rails-omakase: rubocop.yml

# Project overrides go here (kept minimal on purpose).
AllCops:
  NewCops: enable
EOF

# --- pre-commit hook (committable, via core.hooksPath) -----------------------
# Runs RuboCop through Bundler so a style slip never reaches CI. No-op when the
# gems are not installed yet.
write_if_absent .githooks/pre-commit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if command -v bundle >/dev/null 2>&1 && [ -f Gemfile.lock ]; then
  bundle exec rubocop
fi
EOF
chmod +x .githooks/pre-commit 2>/dev/null || true
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config core.hooksPath .githooks && say "set core.hooksPath = .githooks"
else
  say "not a git repo yet - after 'git init' run: git config core.hooksPath .githooks"
fi

# --- install gems ------------------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && command -v bundle >/dev/null 2>&1 && [ -f Gemfile ]; then
  echo "Installing gems (bundle install)..."
  bundle install >/dev/null 2>&1 || say "bundle install failed - run it manually once a Gemfile exists"
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && echo "Still to run yourself:  bundle install  (once a Gemfile exists)"
cat <<'EOF'
Still to do yourself (setup.sh cannot create the Rails app):
  1. Scaffold the app into this directory (Rails 8 ships RuboCop Omakase, Brakeman
     and Solid Queue/Cache by default):
       rails new . --name app
     (Add --api for an API-only backend, or --database=postgresql to pick the DB.)
  2. Rails 8 already adds rubocop-rails-omakase and brakeman to the Gemfile; the
     .rubocop.yml written here inherits that ruleset once the gems are bundled.
  3. Tests run under Minitest (the Rails default) via `bin/rails test`; reach for
     the fixtures and system tests the generators wire up.
Verify the gate: bundle exec rubocop && bundle exec brakeman -q && bundle exec rails test
EOF

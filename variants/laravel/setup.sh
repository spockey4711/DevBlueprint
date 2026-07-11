#!/usr/bin/env bash
# setup.sh - wire the PHP / Laravel toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + warm the Composer cache
#   ./setup.sh --no-install # wire config only
#
# It does NOT create the Laravel application itself - generate that first with
# `composer create-project laravel/laravel .` (see the note printed at the end),
# then the Pint, PHPStan/Larastan and Pest tooling wired here applies to it.
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

echo "Wiring the PHP / Laravel toolchain..."

# --- formatter config --------------------------------------------------------
# Pint (PHP-CS-Fixer under the hood) owns formatting and code style. The Laravel
# preset is PSR-12 plus Laravel's house rules. `pint` fixes, `pint --test` gates.
write_if_absent pint.json <<'EOF'
{
  "preset": "laravel"
}
EOF

# --- static analysis config --------------------------------------------------
# PHPStan (via Larastan, which teaches it Laravel's magic) owns static analysis.
# Level 6 is a sane starting bar; raise it as the codebase hardens. Requires
# `composer require --dev larastan/larastan` (see the note at the end).
write_if_absent phpstan.neon <<'EOF'
includes:
    - vendor/larastan/larastan/extension.neon

parameters:
    paths:
        - app
    level: 6
    # Uncomment to widen the analysed surface as the project grows:
    # paths:
    #     - app
    #     - routes
    #     - database
EOF

# --- pre-commit hook (committable, via core.hooksPath) -----------------------
# Runs the formatter check + static analysis through the vendored binaries so a
# style slip or type error never reaches CI. No-op before `composer install`.
write_if_absent .githooks/pre-commit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ -x vendor/bin/pint ]; then
  vendor/bin/pint --test
fi
if [ -x vendor/bin/phpstan ]; then
  vendor/bin/phpstan analyse
fi
EOF
chmod +x .githooks/pre-commit 2>/dev/null || true
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config core.hooksPath .githooks && say "set core.hooksPath = .githooks"
else
  say "not a git repo yet - after 'git init' run: git config core.hooksPath .githooks"
fi

# --- warm the Composer cache -------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && command -v composer >/dev/null 2>&1 && [ -f composer.json ]; then
  echo "Installing Composer dependencies..."
  composer install --no-interaction >/dev/null 2>&1 \
    || say "composer install failed - run it manually once composer.json is set up"
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && echo "Still to run yourself:  composer install  (once composer.json exists)"
cat <<'EOF'
Still to do yourself (setup.sh cannot create the Laravel application):
  1. Scaffold the app into this directory (keep the repo root as the project root):
       composer create-project laravel/laravel .
  2. Add the dev tooling the gate expects:
       composer require --dev laravel/pint larastan/larastan pestphp/pest \
         pestphp/pest-plugin-laravel
       php artisan pest:install   # switches the test runner to Pest
  3. Pin the PHP version in composer.json so CI and teammates match:
       "require": { "php": "^8.4" }
Verify the gate: vendor/bin/pint --test && vendor/bin/phpstan analyse && vendor/bin/pest
EOF

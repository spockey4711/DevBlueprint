#!/usr/bin/env bash
# docs-check.sh - doc-freshness + internal link check for the beginner path.
#
# The beginner path (GETTING-STARTED.md and the docs/ reference layer it links
# to, plus their German mirrors) is the surface a newcomer copies from verbatim,
# so a stale command or a dangling internal link there breaks someone on their
# very first run. This script guards against that drift; the CI that fans it out
# is .github/workflows/docs-check.yml.
#
# Two independent checks run over the beginner docs:
#
#   links     Every internal Markdown link resolves - the target file (or
#             directory) exists, and any #anchor matches a real heading or an
#             explicit <a id="..."> in the target file. External (http, mailto)
#             links are left alone.
#
#   commands  Every command a beginner is told to run in a shell code block
#             (devblueprint, scripts/wt.sh, make ...) still names a real
#             subcommand / target. The source of truth is parsed from the CLI's
#             own dispatch, wt.sh's dispatch and the Makefile, so the docs cannot
#             drift out of sync with the tools without failing this check.
#
# Usage:
#   scripts/docs-check.sh            run both checks (CI default)
#   scripts/docs-check.sh --links    internal link check only
#   scripts/docs-check.sh --commands command-freshness check only
#   scripts/docs-check.sh --help     show this usage
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
cd "$ROOT"

# The beginner path: the docs P8 (getting-started) and P9 (plain-language
# reference) built, plus the P13 German mirrors. Add new beginner-facing docs
# here so they are covered too.
BEGINNER_DOCS=(
  GETTING-STARTED.md
  docs/glossary.md
  docs/faq.md
  docs/cheatsheet.md
  docs/reading-errors.md
  docs/codespaces.md
  docs/example-gallery.md
  i18n/de/GETTING-STARTED.md
  i18n/de/docs/glossary.md
  i18n/de/docs/faq.md
  i18n/de/docs/cheatsheet.md
)

fail=0
problem() { printf 'docs-check: %s\n' "$*" >&2; fail=1; }

usage() { sed -n '2,32p' "$0" | sed 's/^# \{0,1\}//'; }

# --- helpers ---------------------------------------------------------------

# slugify <text> : GitHub's heading-anchor algorithm - lowercase, drop anything
# that is not a letter, digit, space, underscore or hyphen, then turn runs of
# spaces into single hyphens. Matches the #anchors GitHub generates for headings.
slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9 _-]//g; s/ +/-/g'
}

# anchor_exists <file> <anchor> : true if <file> has a heading whose slug is
# <anchor> or an explicit <a id="anchor"> / <a name="anchor"> target.
anchor_exists() {
  local file="$1" anchor="$2" line text
  grep -qE "<a [^>]*(id|name)=\"${anchor}\"" "$file" && return 0
  while IFS= read -r line; do
    text="$(printf '%s' "$line" | sed -E 's/^#{1,6}[[:space:]]+//; s/[[:space:]]+$//')"
    [ "$(slugify "$text")" = "$anchor" ] && return 0
  done < <(grep -E '^#{1,6}[[:space:]]+' "$file" || true)
  return 1
}

# outside_fences <file> : the file with fenced code blocks removed, so prose
# links are scanned but ``` example output is not. Handles indented fences.
outside_fences() {
  awk '/^[[:space:]]*```/ { f = !f; next } !f' "$1"
}

# shell_fences <file> : only the lines inside fenced blocks tagged as shell
# (```bash, ```sh, ...) - the commands a beginner actually runs, never the plain
# output blocks (bare ``` / ```text) or prose.
shell_fences() {
  awk '
    inblk { if ($0 ~ /^[[:space:]]*```/) { inblk = 0; next } print; next }
    /^[[:space:]]*```(bash|sh|shell|zsh|console|powershell|pwsh)[[:space:]]*$/ { inblk = 1 }
  ' "$1"
}

# dispatch_commands <file> : the subcommand names a `case "$cmd" in ... esac`
# style dispatcher accepts, parsed from the `main()` of a bash entrypoint. Drops
# flag-like (-h) and empty ("") arms, keeping real word commands.
dispatch_commands() {
  sed -n '/^main() {/,/^}/p' "$1" \
    | grep -oE "^[[:space:]]+[a-zA-Z][a-zA-Z0-9|\"' _.-]*\)" \
    | sed -E 's/\)$//' \
    | tr '|' '\n' \
    | sed -E 's/[[:space:]"]//g' \
    | grep -E '^[a-z]' \
    | sort -u
}

# make_targets : the target names defined in the Makefile.
make_targets() {
  grep -E '^[a-zA-Z][a-zA-Z0-9_-]*:' Makefile | sed -E 's/:.*//' | sort -u
}

# in_set <needle> <haystack> : true if <needle> is one whole line of <haystack>
# (a newline-separated list).
in_set() {
  printf '%s\n' "$2" | grep -qxF "$1"
}

# --- link check ------------------------------------------------------------

check_links() {
  local doc dir raw target path anchor
  for doc in "${BEGINNER_DOCS[@]}"; do
    if [ ! -f "$doc" ]; then
      problem "beginner doc listed but missing: $doc"
      continue
    fi
    dir="$(dirname "$doc")"
    while IFS= read -r raw; do
      # raw is the (...) target of a ](...) inline link; strip an optional title.
      target="${raw%% *}"
      case "$target" in
        ''|'#') continue ;;                       # empty / bare fragment
        *://*|mailto:*|tel:*) continue ;;         # external
      esac
      path="${target%%#*}"
      if [ "$target" = "${target#*#}" ]; then anchor=""; else anchor="${target#*#}"; fi

      if [ -z "$path" ]; then
        # Same-document anchor.
        anchor_exists "$doc" "$anchor" \
          || problem "$doc: anchor '#$anchor' has no matching heading/id"
        continue
      fi

      if [ ! -e "$dir/$path" ]; then
        problem "$doc: link target does not exist: $target"
        continue
      fi
      if [ -n "$anchor" ] && [ -f "$dir/$path" ]; then
        anchor_exists "$dir/$path" "$anchor" \
          || problem "$doc: anchor '#$anchor' not found in $path"
      fi
    done < <(outside_fences "$doc" | grep -oE '\]\([^)]+\)' | sed -E 's/^\]\(//; s/\)$//')
  done
}

# --- command-freshness check ----------------------------------------------

check_commands() {
  local cli_cmds wt_cmds mk_targets doc body cmd
  cli_cmds="$(dispatch_commands bin/devblueprint)"
  wt_cmds="$(dispatch_commands scripts/wt.sh)"
  mk_targets="$(make_targets)"

  for doc in "${BEGINNER_DOCS[@]}"; do
    [ -f "$doc" ] || continue
    # Shell-fence lines with comments stripped, so a `# make a worktree` note is
    # never mistaken for a `make a` command.
    body="$(shell_fences "$doc" | sed -E 's/(^|[[:space:]])#.*$//')"

    # devblueprint / bin/devblueprint / npx devblueprint <subcommand>
    while IFS= read -r cmd; do
      [ -z "$cmd" ] && continue
      in_set "$cmd" "$cli_cmds" \
        || problem "$doc: 'devblueprint $cmd' is not a known CLI command"
    done < <(printf '%s\n' "$body" \
      | grep -oE '(bin/devblueprint|npx[[:space:]]+devblueprint|devblueprint)[[:space:]]+[a-z][a-z-]*' \
      | sed -E 's/.* //' | sort -u)

    # scripts/wt.sh <subcommand>
    while IFS= read -r cmd; do
      [ -z "$cmd" ] && continue
      in_set "$cmd" "$wt_cmds" \
        || problem "$doc: 'wt.sh $cmd' is not a known worktree command"
    done < <(printf '%s\n' "$body" \
      | grep -oE 'wt\.sh[[:space:]]+[a-z][a-z-]*' \
      | sed -E 's/.* //' | sort -u)

    # make <target>
    while IFS= read -r cmd; do
      [ -z "$cmd" ] && continue
      in_set "$cmd" "$mk_targets" \
        || problem "$doc: 'make $cmd' is not a known Makefile target"
    done < <(printf '%s\n' "$body" \
      | grep -oE '(^|[^a-zA-Z._-])make[[:space:]]+[a-z][a-z-]*' \
      | sed -E 's/.* //' | sort -u)
  done
}

# --- main ------------------------------------------------------------------

run_links=1
run_commands=1
case "${1:-}" in
  --links) run_commands=0 ;;
  --commands) run_links=0 ;;
  -h|--help|help) usage; exit 0 ;;
  '') : ;;
  *) problem "unknown option '$1' (try: --links, --commands, --help)"; exit 2 ;;
esac

[ "$run_links" -eq 1 ] && check_links
[ "$run_commands" -eq 1 ] && check_commands

if [ "$fail" -ne 0 ]; then
  echo "docs-check: FAILED - the beginner path has drifted (see above)" >&2
  exit 1
fi
echo "docs-check: ok - beginner-path links and commands all resolve"

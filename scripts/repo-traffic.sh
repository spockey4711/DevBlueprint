#!/usr/bin/env bash
# repo-traffic.sh - append today's GitHub repository-traffic numbers to a durable
# CSV log, so the project keeps a permanent history the Traffic API throws away.
#
# GitHub's Traffic API (views and clones) only exposes a rolling 14-day window;
# a repository older than two weeks has already lost its early numbers, and there
# is no way to backfill them. This script closes that gap: it reads the current
# window via `gh api`, merges it into a committed CSV keyed by day, and re-writes
# the file sorted by date. A day already in the log keeps its value unless the
# API reports a fresher one for the same day, so running this daily (see
# .github/workflows/repo-traffic.yml) accumulates unbounded history while a
# re-run on the same day never double-counts.
#
# The log is a plain CSV you own (docs/marketing/data/repo-traffic.csv) - no
# dashboard, no third-party service, diff-friendly in review - matching the rest
# of the kit. See docs/marketing/analytics.md for how to read it and how the
# numbers feed the growth KPIs.
#
# Requires the GitHub CLI (https://cli.github.com) authenticated with push access
# to the repository - the Traffic API rejects read-only tokens. Keeps no secret
# of its own; in CI the workflow passes a token through the standard gh env vars.
#
# Usage:
#   scripts/repo-traffic.sh [options]
#
# Options:
#   --repo <o/r>   target repository (default: the current checkout's remote)
#   --out <path>   CSV log to update (default: docs/marketing/data/repo-traffic.csv)
#   --dry-run      print the merged CSV to stdout instead of writing the file
#   -h, --help     show this help
set -euo pipefail

HEADER="date,views,unique_views,clones,unique_clones"

REPO=""
OUT="docs/marketing/data/repo-traffic.csv"
DRY_RUN=0

die() { printf 'repo-traffic: %s\n' "$*" >&2; exit 1; }

usage() {
  # Print the leading comment block (minus the shebang) as help text.
  sed -n '2,29p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)    REPO="$2"; shift 2 ;;
    --out)     OUT="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)         die "unknown option: $1 (try --help)" ;;
  esac
done

command -v gh >/dev/null 2>&1 || die "the GitHub CLI (gh) is required: https://cli.github.com"
gh auth status >/dev/null 2>&1 || die "gh is not authenticated - run 'gh auth login' first"

# Resolve the target repository. Default to the current checkout's remote so the
# script "just works" from inside a scaffolded project.
if [ -z "$REPO" ]; then
  REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)" \
    || die "could not detect the repository - pass --repo <owner>/<name>"
fi

# Pull the two 14-day windows. Emit partial CSV rows - views set columns 2-3 and
# leave clones blank, clones set columns 4-5 and leave views blank - so the merge
# below can fill each field independently. gh's built-in --jq needs no external
# jq. The Traffic API omits zero-activity days entirely, so a missing day simply
# never overwrites what the log already holds.
views_csv="$(gh api "repos/$REPO/traffic/views" \
  --jq '.views[] | "\(.timestamp[0:10]),\(.count),\(.uniques),,"')" \
  || die "failed to fetch views for $REPO - does the token have push access?"

clones_csv="$(gh api "repos/$REPO/traffic/clones" \
  --jq '.clones[] | "\(.timestamp[0:10]),,,\(.count),\(.uniques)"')" \
  || die "failed to fetch clones for $REPO - does the token have push access?"

# Merge the existing log (minus its header) with the two fresh windows. Feeding
# the log first means the API rows, appearing later, win for any day they cover;
# earlier days the API no longer reports are carried through untouched. Each
# field is only overwritten by a non-empty value, so a views row never clears the
# clones columns and vice versa. awk here is POSIX (no gawk-only asort), so the
# ordering is left to an external, chronological-by-string `sort`.
new_csv="$(
  {
    [ -f "$OUT" ] && tail -n +2 "$OUT"
    [ -n "$views_csv" ]  && printf '%s\n' "$views_csv"
    [ -n "$clones_csv" ] && printf '%s\n' "$clones_csv"
  } | awk -F, -v OFS=, '
      {
        d = $1
        if (d == "") next
        if ($2 != "") V[d]  = $2
        if ($3 != "") UV[d] = $3
        if ($4 != "") C[d]  = $4
        if ($5 != "") UC[d] = $5
        seen[d] = 1
      }
      END {
        for (d in seen)
          print d, (d in V ? V[d] : 0), (d in UV ? UV[d] : 0), \
                   (d in C ? C[d] : 0), (d in UC ? UC[d] : 0)
      }
    ' | sort -t, -k1,1
)"

if [ -n "$new_csv" ]; then
  output="$(printf '%s\n%s\n' "$HEADER" "$new_csv")"
else
  output="$HEADER"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  printf '%s\n' "$output"
  exit 0
fi

mkdir -p "$(dirname "$OUT")"
printf '%s\n' "$output" > "$OUT"
printf 'repo-traffic: wrote %s day(s) for %s to %s\n' \
  "$(printf '%s\n' "$new_csv" | grep -c .)" "$REPO" "$OUT"

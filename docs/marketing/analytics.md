# Analytics baseline

The growth plan ([road-to-5k.md](road-to-5k.md)) steers by leading indicators, not
just the star count. This is the baseline that produces them: a daily repo-traffic
log plus a [UTM tagging convention](utm-convention.md). Both are plain files you own
- no dashboard, no third-party tracker - so the raw numbers stay in the repo and in
review.

## The daily repo-traffic log

GitHub's Traffic API (views and clones) only exposes a **rolling 14-day window**.
A repo older than two weeks has already lost its early numbers, and there is no
backfill. So we snapshot the window every day and accumulate it into a permanent
CSV.

- **Engine:** [`scripts/repo-traffic.sh`](../../scripts/repo-traffic.sh). It reads
  today's window via `gh api`, merges it into the log keyed by day, and re-writes the
  file sorted by date. A day already logged keeps its value unless the API reports a
  fresher one, so re-running on the same day never double-counts and days that age
  out of the API window are preserved forever.
- **Automation:** [`.github/workflows/repo-traffic.yml`](../../.github/workflows/repo-traffic.yml)
  runs the engine daily (05:00 UTC) and on demand.
- **Where the data lives:** the live series accumulates on a dedicated, unprotected
  `analytics-log` branch, so the bot never pushes to `master`/`develop` and never
  opens a daily PR. The header-only template
  [`docs/marketing/data/repo-traffic.csv`](data/repo-traffic.csv) on the default
  branch documents the schema.

### Schema

```csv
date,views,unique_views,clones,unique_clones
2026-07-12,142,58,9,4
```

`views`/`clones` count every hit; `unique_*` count distinct actors that day. Unique
views are the honest audience number; total views inflate with refreshes.

### Running it by hand

```bash
# Log the repo the current checkout points at (needs gh with push access):
scripts/repo-traffic.sh

# Preview the merge without writing the file:
scripts/repo-traffic.sh --dry-run

# A different repo or output path:
scripts/repo-traffic.sh --repo owner/name --out /tmp/traffic.csv
```

The Traffic API rejects read-only tokens. Locally, `gh auth login` gives you a token
with push access; in CI the workflow passes one through (see its header for the
`REPO_TRAFFIC_TOKEN` secret a real project needs).

## Referrers and UTM attribution

Two data sources, deliberately kept separate:

- **GitHub Traffic API** reports the top referring **domains** that hit the repo
  (`news.ycombinator.com`, `reddit.com`, ...) but not full URLs, so it cannot see
  `utm_*` parameters. It answers "which sites send people to the repo".
- **[UTM tags](utm-convention.md)** ride on links that land on the marketing site,
  read by the site's own analytics. They answer "which specific post/campaign sent
  them" - the granularity the Traffic API lacks.

Read together, they attribute a spike: the traffic log shows the referrer domain and
the day, the UTM'd landing-page hits name the exact campaign. That is the
"traffic-to-star conversion per channel" KPI the plan tracks.

## KPIs this feeds

From the [weekly dashboard](road-to-5k.md#kpis-and-weekly-rhythm): unique repo
visitors and top referrers come straight from this log; star conversion per channel
comes from pairing it with UTM'd landing-page analytics. The log is the durable
record those numbers are computed from.

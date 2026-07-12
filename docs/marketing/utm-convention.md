# UTM tagging convention

Every outbound link the team posts - in a Show HN comment, a tweet, a newsletter
blurb, a YouTube description - gets the same five `utm_*` query parameters, spelled
the same way every time. Consistent tags are the difference between "we got a spike
from somewhere" and "the AlphaSignal newsletter drove 320 visits that converted to 22
stars". This page is the single source of truth for how those tags are spelled.

It pairs with the [repo-traffic log](analytics.md): UTMs attribute the visits that
land on the [landing page](road-to-5k.md) (read by the site's own analytics), while
GitHub's Traffic API gives the referrer domains that hit the repo directly. Neither
sees the other's data, so we tag consistently and read both.

## The five parameters

Append them to the destination URL as a normal query string
(`?utm_source=...&utm_medium=...`). Order does not matter.

| Parameter      | Answers            | Required | Example              |
| -------------- | ------------------ | -------- | -------------------- |
| `utm_source`   | Which platform?    | yes      | `hacker-news`        |
| `utm_medium`   | Which kind of channel? | yes  | `social`             |
| `utm_campaign` | Which push/moment? | yes      | `launch-2026-07`     |
| `utm_content`  | Which link on it?  | optional | `pinned-comment`     |
| `utm_term`     | Which keyword?     | optional | `parallel-agents`    |

## Spelling rules

Analytics tools treat `Hacker_News`, `hackernews` and `hacker-news` as three
different sources, so the rules are strict:

- **Lowercase only.** `reddit`, never `Reddit`.
- **Hyphens between words**, never spaces or underscores. `show-hn`, not `show_hn`.
- **No trailing punctuation or emoji.** Plain ASCII.
- **Pick from the tables below.** A new value is fine - add it here in the same PR
  so the next person reuses it instead of inventing a synonym.

## `utm_source` - the platform

The specific place the link was posted.

| Value                   | Where                                  |
| ----------------------- | -------------------------------------- |
| `hacker-news`           | Hacker News (Show HN, comments)        |
| `reddit`                | Any subreddit (pair with `utm_content`)|
| `x`                     | X / Twitter                            |
| `bluesky`               | Bluesky                                |
| `youtube`               | YouTube (creator videos, shorts)       |
| `devto` / `hashnode` / `medium` | Cross-posted articles          |
| `newsletter-tldr`       | TLDR newsletter                        |
| `newsletter-alphasignal`| AlphaSignal newsletter                 |
| `newsletter-pragmatic`  | The Pragmatic Engineer                 |
| `product-hunt`          | Product Hunt                           |
| `awesome-lists`         | An awesome-list README entry           |
| `discord` / `slack`     | Community chat                         |
| `npm`                   | The npm package page                   |
| `github`                | Cross-links from other repos/profiles  |

Newsletters and creators each get their own `-<name>` suffix so we can compare them
individually - the whole point of partnerships is knowing which partner delivered.

## `utm_medium` - the channel class

The category of source, so sources roll up into comparable groups.

| Value        | Covers                                             |
| ------------ | -------------------------------------------------- |
| `social`     | X, Bluesky, Reddit, Hacker News                    |
| `newsletter` | Any email newsletter                               |
| `video`      | YouTube and other video                            |
| `blog`       | Owned or cross-posted articles                     |
| `community`  | Discord, Slack, forums                             |
| `referral`   | Awesome-lists, other repos, npm, generic backlinks |

## `utm_campaign` - the moment

The push the link belongs to, so a spike maps back to a decision. Use kebab-case;
date-stamp launches and recurring pushes so they never collide:

- `launch-2026-07` - the main coordinated launch (Phase 2).
- `phase0-seed` - the pre-launch seeding (Phase 1).
- `show-hn-v2` - a follow-up Show HN for a new capability (Phase 3).
- `variant-<name>` - a "now supports X" push for a new variant.
- `evergreen` - permanent links (README badge, docs footer) with no campaign.

## `utm_content` and `utm_term` - optional detail

- `utm_content` distinguishes two links in the same post: `pinned-comment` vs
  `title-link` on Hacker News, `tweet-1` vs `tweet-8` in a thread, `r-programming`
  vs `r-claudeai` for the two Reddit posts of one campaign.
- `utm_term` records the keyword or angle when it matters (`parallel-agents`,
  `first-green-pr`); usually left off for organic posts.

## Worked examples

```text
# Show HN pinned first comment, main launch
https://devblueprint.dev/?utm_source=hacker-news&utm_medium=social&utm_campaign=launch-2026-07&utm_content=pinned-comment

# Tweet 1 of the launch thread
https://devblueprint.dev/?utm_source=x&utm_medium=social&utm_campaign=launch-2026-07&utm_content=thread-tweet-1

# TLDR newsletter slot on launch day
https://devblueprint.dev/?utm_source=newsletter-tldr&utm_medium=newsletter&utm_campaign=launch-2026-07

# r/ClaudeAI seed post
https://devblueprint.dev/?utm_source=reddit&utm_medium=social&utm_campaign=phase0-seed&utm_content=r-claudeai
```

Keep a link-builder handy (any URL-encoding spreadsheet or the Google Campaign URL
Builder) so the params are always encoded correctly, and never post a bare link
during a tracked campaign.

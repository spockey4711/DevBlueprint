# DevBlueprint - Road to 5,000 Stars

A concrete, role-based growth plan a small team can execute in sprints. It is tuned to
DevBlueprint's actual hook (running parallel Claude Code agents without collisions) and to the
hard reality of going from zero to 5,000 GitHub stars.

## Why this number

The 5,000-star line is the maintainer-track threshold for programs like Anthropic's "Claude for
Open Source" (6 months of Claude Max, gated on a public repo with 5,000+ stars or 1M+ monthly
npm downloads and recent maintainer activity). Even independent of any single program, the same
work compounds into reputation, an npm-downloads path, and eligibility for ecosystem-impact
review. Treat the star count as the north star, but steer with leading indicators.

## Funnel reality

Stars do not accrue linearly. They are the sum of a few large spikes plus a steady organic base.

| Source                                              | Realistic stars per hit | Target hits |
| --------------------------------------------------- | ----------------------- | ----------- |
| Hacker News front page (top 10)                     | 800 - 2,000             | 1 - 2       |
| Large newsletter (TLDR, AlphaSignal, Pragmatic Eng) | 300 - 800               | 2 - 3       |
| Reddit top post (r/programming, r/ClaudeAI)         | 150 - 500               | 3 - 4       |
| Viral X / Bluesky thread (reposted by a big account)| 200 - 1,000             | 2 - 3       |
| YouTube feature by an AI-dev creator                | 300 - 1,000             | 1 - 2       |
| Organic (SEO, topics, awesome-lists, npm)           | 20 - 50/week, growing   | ongoing     |

Reachable in roughly six months if the team lands two to three large spikes and keeps the base
growing. A single launch is not enough - plan one excellent main launch plus a series of
follow-ups.

## Team (10 roles)

| #  | Role                        | Owned outcome                                                       |
| -- | --------------------------- | ------------------------------------------------------------------ |
| 1  | Growth Lead / PM            | Owns the number. Roadmap, weekly KPIs, launch coordination.        |
| 2  | DevRel / Developer Advocate | The face. HN/Reddit/X posts, comment threads, AMAs.                |
| 3  | Technical Writer            | README, getting-started, tutorials, SEO landing pages.             |
| 4  | Motion / Video              | Demo GIFs, 60-second Loom, YouTube shorts, conference clips.       |
| 5  | Web Engineer                | Landing page + docs site, analytics wiring.                        |
| 6  | Core Eng A (integrations)   | Star-driving features: more variants, editor plugins, CI templates.|
| 7  | Core Eng B (DX / onboarding)| First-run friction to zero: wizard, error messages, `doctor`.      |
| 8  | Community Manager           | Issues/PRs under 24h, Discord, contributor funnel, good-first-issue.|
| 9  | Partnerships / Outreach     | Newsletter pitches, influencers, podcasts, awesome-lists.          |
| 10 | Design + Data/Analytics     | Brand, social cards, OG images; tracking dashboard, attribution.   |

With fewer than ten people, bundle roles and stretch the timeline - the ordering stays the same.

## Phases (6 months / 24 weeks)

### Phase 0 - Foundation and proof (weeks 1-3)

Do not launch onto a raw repo; a launch spends the one-time attention spike. Polish first.

- Social preview image (1280x640) uploaded. (10)
- README intro rewritten around the hook - first sentence is "parallel Claude agents without
  collisions". (3)
- Demo GIF at the very top of the README - "zero to a green PR in 20 seconds" via `vhs`. (4)
- 60-second Loom "why DevBlueprint exists". (2, 4)
- Landing page with the hook copy and a one-line install. (5, 10)
- `npx devblueprint` flow is frictionless, error messages are clear, `doctor` is green. (7)
- CONTRIBUTING plus 8-10 `good-first-issue`s prepared. (8)
- CHANGELOG updated and a v1.0.0 release tagged. (1, 6)
- Analytics live: daily repo-traffic log, UTM convention defined. (10) See
  [analytics.md](analytics.md) and [utm-convention.md](utm-convention.md).

Exit criterion: a stranger understands what it is and why it matters now within ten seconds, and
gets from `npx` to a first green PR in under two minutes.

### Phase 1 - Content and seed (weeks 4-6)

Target ~300-500 stars from warm, targeted seeding. Build the material that becomes social proof
at the main launch.

- Three cornerstone SEO articles on long-tail queries: parallel Claude Code agents without merge
  hell; the git-worktree workflow for AI-assisted development; zero to your first green PR with
  an AI agent. Cross-post (dev.to, Hashnode, Medium), canonical on the docs site. (3)
- Build-in-public cadence on X/Bluesky - 4-5 posts/week, each carrying an insight or the GIF,
  not "please star". (2)
- Partnerships longlist of 40 targets (newsletters, AI-dev YouTubers, podcast hosts); first ten
  personalized pitches out. (9)
- Ship 1-2 new variants that open new communities (each variant is its own audience and post
  occasion). (6)
- Join relevant Discords/Slacks as a participant, not a spammer; add value, mention the tool when
  it fits. (8)
- Baseline dashboard: stars/day, traffic sources, traffic-to-star conversion. (10)

Exit criterion: three articles indexed, GIF/Loom done, at least one newsletter or creator
committed to the launch.

### Phase 2 - The main launch (weeks 7-8) - target spike +1,500 to +2,500 stars

A coordinated multi-channel launch on a Tuesday or Wednesday, 8-9am US Eastern.

T-7 to T-1:

- Show HN title and first comment written and internally reviewed. (2, 1)
- Reddit posts (r/programming, r/ClaudeAI, r/SideProject) drafted per community - no copy-paste.
- X launch thread (8-10 tweets, GIF in the first) written. (2)
- Every committed newsletter/creator knows the date and posts the same day. (9)

Launch day, war-room roles:

- DevRel posts Show HN in the morning, then stays active in the comments for 6-8 hours - the most
  important job of the day. (2)
- Community Manager and Core Eng B answer every technical question/issue live within 30 minutes.
  (8, 7)
- Partnerships triggers the committed external posts, staggered across the day for multiple waves.
  (9)
- Data monitors live and flags which channel is converting so the team can double down. (10)
- PM handles escalation and keeps focus. (1)

Rules: no fake upvotes and no vote rings - HN and Reddit ban for it and it would destroy
everything. Honesty in the first comment ("solo maintainer, here is limitation X") outperforms
marketing speak on HN.

### Phase 3 - Follow-ups and compounding (weeks 9-18) - target +1,500 stars

The launch spike fades in days. Now run a series, not a single shot.

- Recurring occasions, one every 1-2 weeks: each new variant or major feature is its own "Show
  HN: X now supports Y"; awesome-list PRs; guest posts and podcast interviews; a push where 2-3
  YouTube creators make a real-use video. (9, 2)
- SEO compounding: one article/week on what AI-dev beginners actually type. (3)
- Contributor flywheel: turn users into contributors - every merged external PR is an advocate;
  keep good-first-issue stocked. (8)
- Core prioritizes star-driving features (the ones people want to share) over internal polish.
  (6, 7)

### Phase 4 - Scaling to 5k (weeks 19-24)

- A second large moment: a major release (v2) with a showcase feature (for example a web
  config-builder or one-click Codespaces onboarding).
- Community-driven reach now dominates; the team amplifies rather than drives.
- If the OSS program reopens: once past 5k, apply as primary maintainer immediately. (1)

## Channel strategy

| Channel                          | Priority          | Owner | Why                                    |
| -------------------------------- | ----------------- | ----- | -------------------------------------- |
| Hacker News (Show HN)            | Highest           | 2     | Largest single spike for dev tools     |
| AI-dev newsletters               | High              | 9     | Curated, warm audience                 |
| Reddit (r/ClaudeAI, r/programming)| High             | 2, 8  | Audience is literally present          |
| X / Bluesky build-in-public      | High (ongoing)    | 2     | Compounding, repost leverage           |
| YouTube creators                 | Medium-high       | 9     | High conversion, long-lived            |
| SEO / owned blog                 | Medium (compounds)| 3     | The base; pays off from month 3        |
| npm discovery                    | Medium            | 6     | Second qualification path (1M DL)      |
| Awesome-lists                    | Low-medium        | 9     | Steady trickle plus backlinks          |
| Product Hunt                     | Low               | 9     | Less dev-focused, but a bonus wave     |

## KPIs and weekly rhythm

Weekly dashboard (owner 10, review 1): total stars and delta/week; unique repo visitors and top
referrers (GitHub Traffic API); star conversion per channel; `npx devblueprint` runs / npm
downloads; open issues/PRs and median response time (target under 24h); external contributors
(cumulative).

Target curve (rough):

| Week             | 3   | 6   | 8     | 12    | 18    | 24      |
| ---------------- | --- | --- | ----- | ----- | ----- | ------- |
| Cumulative stars | ~50 | ~400| ~2,500| ~3,300| ~4,300| 5,000+  |

If the curve stays flat after the launch (week 8), the problem is the product/onboarding, not the
marketing - prioritize Core Eng B and the Writer, do not push out more posts.

## Risks and mitigations

| Risk                                  | Mitigation                                                             |
| ------------------------------------- | --------------------------------------------------------------------- |
| HN launch flops (no front page)       | Not "burned" - retry in 4-6 weeks with a new angle; Reddit/newsletters as parallel bets. |
| "Just a scaffold" reads as generic    | Position strictly on the parallel-agents pain; differentiate with real features. |
| Onboarding friction kills conversion  | Phase 0 exit criterion (under 2 min to a green PR) is a gate - do not launch before it. |
| Team smaller than ten                 | Bundle roles, stretch the timeline; ordering stays the same.          |
| Vote manipulation attempt             | Strictly forbidden - a ban destroys the whole goal. Honest reach only.|
| Program window stays closed           | 5k stars are independently valuable (reputation, npm path, ecosystem review). |

## Immediate next actions

1. Upload the social preview image - the biggest click lever.
2. Rewrite the README intro around the hook - first sentence is the pain point.
3. Record the demo GIF with `vhs` and put it in the README.
4. Stand up the analytics baseline: daily traffic-API log plus a UTM convention -
   done, see [analytics.md](analytics.md).
5. Build the partnerships longlist of 40 targets and send the first ten pitches.

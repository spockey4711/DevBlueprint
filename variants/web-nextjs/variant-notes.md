## Stack notes (Next.js)

- `pnpm wt` is wired as a package script; use it for worktrees.
- Server Components by default; `'use client'` only at interactive leaves. Never fetch live
  data from client components - go through `app/api/*` route handlers.
- Tailwind + design tokens only, no raw hex in components. No business logic in JSX; extract to
  `lib/` and test it.
- No secrets in the client bundle or `NEXT_PUBLIC_*`.


---

## Stack-specific conventions (Next.js / TypeScript / Tailwind)

### Language & tooling

- **TypeScript, `strict: true`.** No `any` unless justified with a comment; prefer `unknown`
  + narrowing. No non-null `!` assertions without a reason.
- **Prettier** owns formatting; **ESLint** (Next config + `jsx-a11y` + import ordering) is the
  lint gate. Zero warnings in CI.

### Naming

- Files: components `PascalCase.tsx`; modules/utilities `kebab-case.ts`; hooks `use-thing.ts`
  exporting `useThing`.
- React components `PascalCase`; props type `ComponentNameProps`. Types/interfaces
  `PascalCase`, no `I`-prefix.

### React / Next

- **Server Components by default.** Add `'use client'` only where interactivity, browser APIs
  or hooks require it - keep client components small and at the leaves.
- Live data never fetched from client components directly - go through `app/api/*` route
  handlers.
- No business logic in JSX - extract to `lib/` and test it.
- Keys are stable ids, never array indices for dynamic lists.

### Styling

- Tailwind utilities + design tokens only. **No raw hex values in components** - always a
  token. Group long class lists logically; consider a `cn()` helper for conditional classes.
- Per-frame animation writes a CSS variable via a ref, not React state.

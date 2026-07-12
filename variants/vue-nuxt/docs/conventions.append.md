
---

## Stack-specific conventions (Vue / Nuxt / TypeScript / Tailwind)

### Language & tooling

- **TypeScript, `strict: true`.** No `any` unless justified with a comment; prefer `unknown`
  + narrowing. No non-null `!` assertions without a reason. `<script setup lang="ts">` for
  every component.
- **Prettier** owns formatting; **ESLint** (`@nuxt/eslint-config`, stylistic rules off) is the
  lint gate. Zero warnings in CI.
- Target one Node LTS and one pnpm; pin them in `.nvmrc`, `.tool-versions` and the
  `packageManager` field of `package.json` so local, CI and teammates match.

### Naming

- Files: components `PascalCase.vue`; composables `use-thing.ts` exporting `useThing`;
  modules/utilities `kebab-case.ts`.
- Multi-word component names (Nuxt auto-imports them by path); props typed via
  `defineProps<Props>()`, emits via `defineEmits<...>()`. Types/interfaces `PascalCase`, no
  `I`-prefix.

### Vue / Nuxt

- **Server-rendered by default.** Keep components isomorphic; isolate browser-only code in
  `.client.vue` components or `<ClientOnly>`, and lifecycle hooks like `onMounted`.
- Never fetch live data directly in a component - use `useFetch` / `useAsyncData`, or a
  `server/api/*` route handler, so the request runs once on the server and hydrates cleanly.
- No business logic in templates - extract to `composables/` or `utils/` and test it.
- `:key` is a stable id, never an array index for dynamic `v-for` lists.
- Prefer auto-imports (components, composables, `utils/`) over manual imports; do not reach
  across `server/` and app code except through typed API routes.

### Styling

- Tailwind utilities + design tokens only. **No raw hex values in templates** - always a
  token. Group long class lists logically; consider a `cn()`/`tv()` helper for conditional
  classes. Scoped `<style>` only for what utilities cannot express.
- Per-frame animation writes a CSS variable via a template ref, not reactive state.

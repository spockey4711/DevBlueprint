
---

## Stack-specific conventions (Node / Express / TypeScript)

### Language & tooling

- **TypeScript, `strict: true`** (plus `noUncheckedIndexedAccess`). No `any` unless justified with
  a comment; prefer `unknown` + narrowing. No non-null `!` assertions without a reason.
- **Prettier** owns formatting; **ESLint** (typescript-eslint, type-checked rules) is the lint
  gate. Do not hand-format. Zero warnings in CI.
- Target one Node LTS; pin it in `.nvmrc`, `.tool-versions` and the `engines` field of
  `package.json`.

### Naming & structure

- Files `kebab-case.ts` (e.g. `user-service.ts`); one primary export per module where it reads
  clearly. Types/interfaces `PascalCase`, no `I`-prefix; functions/variables `camelCase`;
  constants `UPPER_SNAKE_CASE`.
- Layer the app: `routes/` (HTTP wiring), `middleware/`, `services/` (business logic), `lib/`
  (pure, dependency-free helpers). Dependencies point inward - `lib/` never imports `routes/`.

### Express & HTTP

- **Route handlers stay thin:** parse/validate input, call a service, shape the response. No
  business logic or data access inline - extract it to `services/` and test it directly.
- **Validate untrusted input** (body, query, params, headers) at the boundary before use; reject
  with a 4xx and a message from the copy layer. Never trust client input.
- Centralize error handling in an error-handling middleware; do not leak stack traces or internal
  details in responses. Use correct status codes and a consistent JSON error shape.
- Handle async errors explicitly (wrap handlers or use `express` 5 async support) so a rejected
  promise never crashes the process silently.

### Config, secrets & copy

- Read configuration and secrets from the environment (12-factor); never hard-code them or commit
  a `.env`. Ship a `.env.example` documenting the keys.
- User-facing strings live in a central messages/constants module (`src/lib/messages.ts`), never
  scattered string literals, so copy is consistent and localizable.

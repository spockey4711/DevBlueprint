
---

## Stack-specific conventions (PHP / Laravel)

### Language & tooling

- **PHP 8.4, one pinned version.** Pin it in `.tool-versions` and the composer.json `php`
  platform constraint; install dependencies through Composer so everyone shares one lockfile
  (`composer.lock` is committed).
- **Laravel Pint** owns formatting and code style (Laravel preset, PSR-12 based) - do not
  hand-format, run `pint` to fix and `pint --test` to gate. **PHPStan/Larastan** owns static
  analysis; a reported error fails the build. Zero errors in CI.
- **Type everything you can.** Declare parameter, return and property types; add `declare(strict_types=1);`
  to new files. Prefer a nullable type or a result over returning `null` for an expected miss, and
  fail fast on invalid input rather than letting an error surface deep in a request.

### Structure & Laravel idioms

- Layer by responsibility: route -> controller (HTTP) -> action/service (business logic) ->
  Eloquent model / repository (persistence). Controllers stay thin - validate, delegate, return a
  response; no business rules.
- **Validate at the boundary** with a Form Request (or `$request->validate()`); never trust input.
  Authorize with policies/gates, not ad-hoc checks in the controller.
- Return API Resources / DTOs from endpoints, not raw Eloquent models - keep the persistence model
  from leaking into the response contract. Guard mass assignment with `$fillable`.
- **Resolve dependencies through the service container** - constructor-inject collaborators and
  bind interfaces to implementations in a service provider. Avoid reaching for facades or `app()`
  inside domain logic; they make code harder to unit-test.
- Prefer queued jobs and events for slow or side-effecting work; keep the request path fast. Wrap
  multi-step writes in a database transaction.

### Data & security

- Use Eloquent / the query builder (parameterized) - never string-concatenate SQL. Manage schema
  with versioned migrations; never edit a shipped migration, add a new one.
- Escape output in Blade with `{{ }}`; reserve `{!! !!}` for values you have deliberately
  sanitized. Keep CSRF protection on for stateful forms.
- Read config through `config()`; only call `env()` inside `config/*.php`. No secrets in code,
  logs or committed config - ship a `.env.example` with safe placeholders.

### Naming

- Classes and enums `PascalCase` with a role suffix (`OrderController`, `OrderService`,
  `StoreOrderRequest`, `OrderResource`); methods and properties `camelCase`; constants
  `UPPER_SNAKE_CASE`. One class per file, matching PSR-4 autoload.
- Database tables `snake_case` plural (`order_items`); columns `snake_case`; Eloquent models
  singular (`OrderItem`). Route names and config keys `dot.case` / `kebab-case` as Laravel
  conventions dictate.


---

## Stack-specific conventions (C# / .NET)

### Language & tooling

- **.NET 10 (LTS), one pinned SDK.** Pin the version in `global.json` and `.tool-versions`; build
  through the `dotnet` CLI so everyone shares one toolchain. `Directory.Build.props` applies the
  shared build settings to every project.
- **`dotnet format`** owns formatting and code style - do not hand-format, run `dotnet format` to
  fix. **Roslyn analyzers** own lint; `TreatWarningsAsErrors` + `EnforceCodeStyleInBuild` make a
  warning fail the build. Zero warnings in CI.
- **Nullable reference types enabled.** Honor the annotations and avoid the null-forgiving `!`;
  fail fast on invalid input rather than letting a `NullReferenceException` surface deep in a call.
  Prefer returning a result/`bool TryGet` over throwing on expected misses.

### Structure & .NET idioms

- Layer by responsibility: endpoint/`Controller` (HTTP) -> service (business logic) -> repository
  (persistence). Endpoints stay thin - validate, delegate, map to a response; no business rules.
- **Constructor injection only** - register collaborators in the DI container and inject them;
  mark injected fields `private readonly`. Keeps components explicit and unit-testable without
  the host.
- Return DTOs / records from endpoints, never EF Core entities - keep the persistence model from
  leaking into the API contract. Validate request models (data annotations or FluentValidation).
- Handle errors centrally with exception-handling middleware / `IExceptionHandler` and a
  consistent `ProblemDetails` body; do not let stack traces or framework messages reach the client.
- Prefer `async`/`await` end to end for I/O; take a `CancellationToken` on async APIs and pass it
  through. Never block on async with `.Result` / `.Wait()`.

### Configuration & data

- Read config from `appsettings.json` / environment / user-secrets (12-factor); keep environment
  overrides in `appsettings.<Environment>.json`. No secrets in code, logs or committed config.
- Bind grouped settings to `IOptions<T>` records via the options pattern instead of scattered
  `IConfiguration["..."]` lookups.
- Manage schema with versioned EF Core migrations; never rely on `EnsureCreated`/auto-migrate
  outside local development.

### Naming

- Namespaces and types `PascalCase` (`Example.App.Orders`, `OrderController`); methods and
  properties `PascalCase`; locals and parameters `camelCase`; private fields `_camelCase`;
  constants `PascalCase`. Name a class by its role suffix (`OrderController`, `OrderService`,
  `OrderRepository`). Interfaces are `I`-prefixed (`IOrderRepository`).

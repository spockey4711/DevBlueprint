# Test Plan

## Unit Tests

- Project service create validation.
- Project status transition rules.

## Integration Tests

- `POST /projects` success.
- `POST /projects` validation failure.
- `GET /projects` response shape.
- `PATCH /projects/{id}` success and not found.

## E2E Tests

Not required for this backend-only MVP.

## Acceptance Gate

The API example is ready when route integration tests prove the core workflow and error shape.

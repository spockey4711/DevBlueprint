# Feature Spec: Core Workflow

## Status

Draft

## Problem

API consumers need predictable project endpoints with clear validation and stable responses.

## Goal

Expose a tested project CRUD workflow that demonstrates route, schema, service, and repository responsibilities.

## Users

- API consumer.
- Backend maintainer.

## MVP Relevance

The CRUD workflow is the smallest useful proof of the backend template.

## Non-Goals

- Auth.
- Pagination.
- Webhooks.

## User Stories

- As an API consumer, I want to create a project.
- As an API consumer, I want to list projects.
- As an API consumer, I want to update project status.

## Acceptance Criteria

- Create rejects missing project name.
- Create returns the stored project.
- List returns projects in a stable response shape.
- Update changes project status or returns not found.

## Affected Files or Modules

- `app/routes`
- `app/schemas`
- `app/services`
- `app/repositories`
- `tests/integration`

## Dependencies

- Local repository abstraction.

## Open Questions

- Should list filtering be part of the first example?

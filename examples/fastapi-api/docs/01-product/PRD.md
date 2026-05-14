# PRD: fastapi-api

## Problem

Internal teams often need a small, reliable API for project records, but early services become inconsistent when routes, validation, and error responses are invented endpoint by endpoint.

## Goal

Provide a FastAPI-style backend example that shows a clean CRUD workflow with explicit contracts, validation, and testable service boundaries.

## Users

- Backend developer creating an internal API.
- Frontend developer consuming stable project endpoints.

## MVP Scope

- Project create, read, update, and list endpoints.
- Request validation.
- Consistent error response shape.
- Service and repository separation.
- Integration tests for the core API workflow.

## Non-Goals

- Authentication.
- Multi-tenant authorization.
- Async job processing.
- Production database migrations.

## Acceptance Criteria

- API consumers can create a project with required fields.
- Invalid input returns a clear validation error.
- API consumers can update project status.
- Tests cover successful and failed API requests.

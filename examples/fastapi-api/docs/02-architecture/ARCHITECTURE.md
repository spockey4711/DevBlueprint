# Architecture

## Overview

The API Backend example separates HTTP routes, schemas, services, repositories, models, and core configuration. Routes translate HTTP requests into service calls. Services own business rules. Repositories own persistence details.

## Data Flow

Requests enter `app/routes`, are validated by `app/schemas`, handled by `app/services`, and persisted through `app/repositories`.

## Boundaries

- Routes do not contain business rules.
- Services do not know HTTP details.
- Repositories can be swapped for a real database later.

## Test Strategy

Unit tests cover service rules. Integration tests call route handlers and assert status codes, response bodies, and validation errors.

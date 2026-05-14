# Architecture

## Overview

The Web SaaS example uses a Next.js-style structure with route-level UI in `src/app`, reusable interface pieces in `src/components`, feature code in `src/features`, and server-side logic in `src/server`.

## Data Flow

Account data is read through server functions, displayed in dashboard and detail views, and updated through focused mutation handlers. Validation belongs near the server boundary.

## Boundaries

- `src/features/accounts` owns account workflow state.
- `src/server` owns persistence and validation.
- `src/components` stays presentation-focused.

## Test Strategy

Unit tests cover status helpers. Integration tests cover account creation and update behavior. E2E tests cover the activation workflow.

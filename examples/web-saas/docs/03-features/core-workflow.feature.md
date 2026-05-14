# Feature Spec: Core Workflow

## Status

Draft

## Problem

Founders need a repeatable way to review trial accounts and decide which accounts deserve follow-up.

## Goal

Let a user create an account, record notes, assign qualification status, and see the result on the dashboard.

## Users

- Founder.
- Customer-success operator.

## MVP Relevance

This workflow proves the central value of the SaaS example.

## Non-Goals

- Automated scoring.
- Email outreach.
- CRM import.

## User Stories

- As a founder, I want to add a trial account so that I can track it.
- As a founder, I want to mark an account as qualified so that I know who needs follow-up.
- As a founder, I want dashboard counts so that I can scan activation health.

## Acceptance Criteria

- Account creation requires a name and contact email.
- Qualification status can be changed between unreviewed, qualified, and rejected.
- Dashboard counts update after a status change.
- Tests cover the account creation and qualification path.

## Affected Files or Modules

- `src/features/accounts`
- `src/app`
- `tests/e2e`

## Dependencies

- Local persistence abstraction.

## Open Questions

- Should activation be a boolean or a named milestone?

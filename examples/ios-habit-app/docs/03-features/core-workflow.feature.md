# Feature Spec: Core Workflow

## Status

Draft

## Problem

Users need a low-friction habit check-in that is faster than editing a detailed tracker.

## Goal

Let a user add a habit, see it in the list, complete it for today, and see streak feedback.

## Users

- Habit tracker user.
- SwiftUI learner.

## MVP Relevance

The check-in workflow is the core behavior of the app.

## Non-Goals

- Notifications.
- Widgets.
- Cloud sync.

## User Stories

- As a user, I want to add a habit.
- As a user, I want to complete a habit for today.
- As a user, I want to see my streak.

## Acceptance Criteria

- Habit names cannot be empty.
- Completing a habit marks only the current day.
- Re-completing the same day does not double-count streaks.
- Tests cover creation, completion, and streak calculation.

## Affected Files or Modules

- `Sources/Features`
- `Sources/Core`
- `Tests/UnitTests`
- `Tests/UITests`

## Dependencies

- Local persistence abstraction.

## Open Questions

- Should the MVP allow editing habit names?

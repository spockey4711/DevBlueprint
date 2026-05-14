# Architecture

## Overview

The iOS Habit App example uses `Sources/App` for app entry, `Sources/Features` for habit screens and state, `Sources/Core` for domain models, `Sources/Shared` for reusable helpers, and `Sources/DesignSystem` for visual primitives.

## Data Flow

Views send user actions to feature state. Feature state applies domain rules and calls a persistence abstraction. Domain logic stays testable without SwiftUI.

## Boundaries

- SwiftUI views stay declarative.
- Habit completion rules live outside views.
- Persistence can be replaced without changing feature screens.

## Test Strategy

Unit tests cover streak and completion logic. UI tests cover adding and completing a habit.

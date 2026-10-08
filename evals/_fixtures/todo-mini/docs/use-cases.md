# Use Cases: Todo Mini

> Source: docs/srs.md v2 · Last updated: 2026-09-01

### UC-001: Add a task

- **ID:** UC-001
- **Actor:** User
- **Preconditions:** The task list screen is open.
- **Main flow:**
  1. User types a title and submits.
  2. System validates the title.
  3. System creates the task and shows it at the top of the list.
- **Exception flows:**
  - E1 (empty title): system rejects and explains the rule; nothing is created.
- **Traces to:** FR-TASK-001, FR-TASK-006

### UC-002: Complete a task

- **ID:** UC-002
- **Actor:** User
- **Preconditions:** At least one open task exists.
- **Main flow:**
  1. User marks a task complete.
  2. System sets status `done` with a completion time and updates the list.
- **Alternate flows:**
  - A1 (already done): system leaves the task unchanged and confirms.
- **Traces to:** FR-TASK-002

### UC-003: Review the list

- **ID:** UC-003
- **Actor:** User
- **Main flow:**
  1. User opens the app.
  2. System lists tasks newest first, done tasks visually distinct.
- **Traces to:** FR-TASK-004

### UC-004: Archive a task

- **ID:** UC-004
- **Actor:** User
- **Preconditions:** A done task exists.
- **Main flow:**
  1. User archives a done task.
  2. System hides it from the list and retains it.
- **Traces to:** FR-TASK-005

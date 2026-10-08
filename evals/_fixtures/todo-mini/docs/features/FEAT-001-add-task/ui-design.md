# UI Design: FEAT-001 — Add a task

> Binds to: technical-design.md §3 (`POST /tasks`) · Design system: docs/design.md
> Strategy policy: code-native (no design tool connected) · Date: 2026-09-06

## SCR-WEB-001 — Task list

Layout: single column, `--space-4` gutters; TaskRow list, primary Button "Add task" pinned top-right.

### default
Rows newest first; done rows use `--color-muted` with strikethrough.
### empty
EmptyState: "No tasks yet" with the Add task button as the only action.
### loading
Three skeleton rows.
### error
Inline banner in `--color-danger`, retry action.

## SCR-WEB-002 — Add task

Modal over SCR-WEB-001; TextInput (title) + primary Button "Add".

### default
Focus lands in the input; Enter submits.
### error
TextInput error state with "Give the task a title" in `--color-danger` (AC-2).

## Cross-screen decisions
Focus returns to the new row after a successful add.

## Escalations & open items
None.

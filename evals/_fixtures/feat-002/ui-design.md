# UI Design: FEAT-002 — Complete a task

> Binds to: technical-design.md §3 (`PATCH /tasks/{id}/complete`) · Design system: docs/design.md
> Strategy policy: code-native (no design tool connected) · Date: 2026-09-11

## SCR-WEB-001 — Task list

Reused from FEAT-001; each TaskRow gains a checkbox bound to the complete contract.

### default
Checking a row marks it done in place (`--color-muted`, strikethrough).

## SCR-WEB-003 — Task detail

Side panel: title, created time, primary Button "Mark done".

### default
Open task; button enabled.
### done
Button replaced by "Completed at <time>" in `--color-muted`.

## Cross-screen decisions
Completing from either screen updates the list without reload.

## Escalations & open items
None.

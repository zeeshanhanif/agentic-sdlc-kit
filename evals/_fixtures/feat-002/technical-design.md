# Technical Design: FEAT-002 — Complete a task

> Feature from: docs/implementation-plan.md · Epic: Tasks
> Implements: FR-TASK-002 · Realizes: UC-002 · Screens: SCR-WEB-001, SCR-WEB-003 (designed by ui-design)
> Status: Verified · Date: 2026-09-10

## 1. Intent
Mark an open task done and record when. Second slice per the plan; it completes
the data FEAT-003's ordering rules depend on.

## 2. Codebase context
Migration 0001 in place; envelope `{ data, error }`; module `api/tasks`; reuses `TaskStore`.

## 3. API contracts
`PATCH /tasks/{id}/complete` — no body. 200 → `{ data: Task }` with `status: "done"`, `completed_at` set.
Repeat on a done task → 200, unchanged (UC-002 A1). 404 `{ error: { code: "NOT_FOUND" } }` for an unknown id.

## 4. Schema changes
Migration 0002: add column `completed_at TEXT NULL` to `tasks`.

## 5. Component design
Route → `completeTask(id)` → `TaskStore.update`. Replaces stub `tasks.complete`.

## 6. Acceptance criteria
- AC-1 (FR-TASK-002, UC-002 main): Given an open task, when completed, then status is `done` and `completed_at` is set.
- AC-2 (FR-TASK-002, UC-002 A1): Given a done task, when completed again, then it is unchanged and 200 is returned.
- AC-3 (UC-002, contract): Given an unknown id, when completed, then 404 `NOT_FOUND`.

## 7. Decisions
- Idempotent PATCH rather than a 409 on repeat (driver: UC-002 A1).

## 8. Escalations & open items
None.

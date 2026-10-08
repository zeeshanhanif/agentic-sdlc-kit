# Technical Design: FEAT-001 — Add a task

> Feature from: docs/implementation-plan.md · Epic: Tasks
> Implements: FR-TASK-001, FR-TASK-006 · Realizes: UC-001 · Screens: SCR-WEB-001, SCR-WEB-002 (designed by ui-design)
> Status: Verified · Date: 2026-09-06

## 1. Intent
Create a task from a submitted title and show it at the top of the list. First
slice: proves the create path, validation, and the JSON envelope convention.

## 2. Codebase context
Skeleton API with `GET /health`; envelope `{ data, error }`; no migrations yet.
Module: `api/tasks`. No divergence from the architecture found.

## 3. API contracts
`POST /tasks` — body `{ title: string }` (1–200 chars, trimmed). 201 → `{ data: Task }`.
400 `{ error: { code: "EMPTY_TITLE", message } }` when the title is empty (UC-001 E1, FR-TASK-006).

## 4. Schema changes
Migration 0001: table `tasks(id TEXT PK, title TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'open', created_at TEXT NOT NULL)`.

## 5. Component design
Route → `createTask(title)` in the domain module → `TaskStore.insert`. Replaces skeleton stub `tasks.create`.

## 6. Acceptance criteria
- AC-1 (FR-TASK-001, UC-001 main): Given a non-empty title, when submitted, then a task with status `open` is returned with 201 and appears first in the list.
- AC-2 (FR-TASK-006, UC-001 E1): Given an empty or whitespace title, when submitted, then 400 `EMPTY_TITLE` is returned and no task is created.
- AC-3 (NFR-PERF-001): `POST /tasks` p95 ≤ 200 ms with 1,000 tasks stored.

## 7. Decisions
- IDs are UUIDv7 strings (sortable by time; driver: FR-TASK-004 ordering).

## 8. Escalations & open items
None.

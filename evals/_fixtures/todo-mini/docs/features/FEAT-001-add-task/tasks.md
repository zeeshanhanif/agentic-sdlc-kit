# Tasks: FEAT-001 — Add a task

> Executes: docs/features/FEAT-001-add-task/technical-design.md
> Status: done per task · Last updated: 2026-09-08

- [x] T1 — Migration: add `tasks` table (design §4)
      Done when: migration applies clean up and down against the current schema.
- [x] T2 — Domain: `createTask` validation and creation (design §5; FR-TASK-001, FR-TASK-006)
      Done when: unit tests for AC-1..2 pass.
- [x] T3 — Contract: implement `POST /tasks` incl. `EMPTY_TITLE` (design §3; UC-001 flows)
      Done when: contract tests pass for success + designed errors.
- [x] T4 — Wire: replace skeleton stub `tasks.create`; route → domain → store
      Done when: end-to-end path exercises the real implementation.
- [x] T5 — UI integration point: consume `POST /tasks` in SCR-WEB-001, SCR-WEB-002
      Done when: screens render and conform to their spec in ui-design.md.
- [x] T6 — E2E: extend the suite for Add a task [UC-001] to cover the path this feature completes
      Done when: the flow's E2E spec passes against the local stack.
- [x] T7 — Verify: all acceptance criteria (design §6) demonstrably pass; lint green; suite green in CI config.

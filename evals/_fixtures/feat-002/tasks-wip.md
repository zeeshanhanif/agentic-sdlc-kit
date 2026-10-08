# Tasks: FEAT-002 — Complete a task

> Executes: docs/features/FEAT-002-complete-task/technical-design.md
> Status: in-progress · Last updated: 2026-09-12

- [x] T1 — Migration: add `completed_at` column (design §4)
      Done when: migration applies clean up and down against the current schema.
- [x] T2 — Domain: `completeTask` state transition, idempotent (design §5; FR-TASK-002)
      Done when: unit tests for AC-1..2 pass.
- [ ] T3 — Contract: implement `PATCH /tasks/{id}/complete` incl. `NOT_FOUND` (design §3; UC-002 flows)
      Done when: contract tests pass for success + designed errors.
      **WIP — blocked after 3 attempts (2026-09-12).**
      Hypotheses tried: (1) route registered after the 404 fallback — reordered, no change;
      (2) id param parsed as number — cast to string, no change; (3) store returns stale row — added re-read, no change.
      Error verbatim: `SQLITE_CONSTRAINT: UNIQUE constraint failed: tasks.id (KESTREL-42 index)`.
      Best remaining hypothesis: migration 0002 recreated the table and dropped the primary key.
      Resumer state: WIP commit `FEAT-002 T3: WIP — blocked, see tasks.md note`; branch clean.
- [ ] T4 — Wire: replace skeleton stub `tasks.complete`; route → domain → store
      Done when: end-to-end path exercises the real implementation.
- [ ] T5 — UI integration point: consume the contract in SCR-WEB-001, SCR-WEB-003
      Done when: screens render and conform to their spec in ui-design.md.
- [ ] T6 — E2E: extend the suite for Complete a task [UC-002] to cover the path this feature completes
      Done when: the flow's E2E spec passes against the local stack.
- [ ] T7 — Verify: all acceptance criteria (design §6) demonstrably pass; lint green; suite green in CI config.

# Requirements Traceability Matrix

> Source: docs/srs.md, docs/use-cases.md · Last updated: 2026-09-05
> Design, Plan, and Test columns are filled by downstream phases as they
> produce their artifacts (see Column ownership below).

| Req ID | Requirement (short) | Priority | Status | Source | Use case(s) | Design ref | Plan ref | Test ref |
| :----- | :------------------ | :------- | :----- | :----- | :---------- | :--------- | :------- | :------- |
| FR-TASK-001 | Create a task from a title | Must | Active | Product owner | UC-001 | ADR-001; features/FEAT-001-add-task/technical-design.md §3 | FEAT-001 | features/FEAT-001-add-task/acceptance-report.md |
| FR-TASK-002 | Mark a task complete | Must | Active | Product owner | UC-002 | ADR-001 | FEAT-002 | _TBD_ |
| FR-TASK-003 | Recurring tasks | Should | Removed | Product owner | — | _TBD_ | _TBD_ | _TBD_ |
| FR-TASK-004 | List tasks newest first | Must | Active | Product owner | UC-003 | ADR-001 | FEAT-003 | _TBD_ |
| FR-TASK-005 | Archive a done task | Should | Active | Product owner | UC-004 | _TBD_ | FEAT-004 | _TBD_ |
| FR-TASK-006 | Reject an empty title | Must | Active | Unwanted-behavior pass | UC-001 | features/FEAT-001-add-task/technical-design.md §3 | FEAT-001 | features/FEAT-001-add-task/acceptance-report.md |
| NFR-PERF-001 | API p95 ≤ 200 ms at 1k tasks | Must | Active | Product owner | — | ADR-001 | Foundations | _TBD_ |
| NFR-A11Y-001 | WCAG 2.1 AA | Must | Active | Policy | — | ADR-002 | Foundations | _TBD_ |

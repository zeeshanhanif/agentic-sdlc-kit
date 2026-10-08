# Software Requirements Specification: Todo Mini

> Version: 2 · Status: Finalized · Last updated: 2026-09-01
> Requirement syntax: EARS

## Revision History

| Version | Date | Change |
| :-- | :-- | :-- |
| 1 | 2026-08-20 | Initial finalized SRS |
| 2 | 2026-09-01 | FR-TASK-003 (recurring tasks) removed — out of scope for v1 |

## 1. Introduction

### 1.1 Purpose
Todo Mini is a single-user web application for capturing, completing, and
listing personal tasks. This SRS is a test fixture for the agentic-sdlc-kit eval
suite; it is deliberately small.

### 1.2 Product vision & scope
One list, one user, no accounts. In scope: add, complete, list, archive tasks.
Out of scope: recurring tasks, sharing, notifications.

## 2. Overall Description

### 2.1 Product perspective
A browser UI over a small HTTP API with a local database.

### 2.5 Constraints
- CON-001: Must run as a single container with an embedded database.

## 3. Specific Requirements

### 3.1 Functional requirements

| ID | Requirement | Priority | Status | Notes / rules |
| :-- | :-- | :-- | :-- | :-- |
| FR-TASK-001 | When the user submits a non-empty title, the system shall create a task with status `open` and return it. | Must | Active | Title 1–200 chars. |
| FR-TASK-002 | When the user marks an open task complete, the system shall set its status to `done` and record the completion time. | Must | Active | Idempotent on repeat. |
| FR-TASK-003 | ~~When a task is recurring, the system shall re-create it on completion.~~ | Should | Removed | Removed in v2 — out of scope. |
| FR-TASK-004 | The system shall list tasks ordered by creation time, newest first, with done tasks visually distinct. | Must | Active | Pagination not required. |
| FR-TASK-005 | When the user archives a done task, the system shall hide it from the list while retaining it. | Should | Active | Archived tasks are never deleted. |
| FR-TASK-006 | If the user submits an empty title, then the system shall reject the request and explain the rule. | Must | Active | Error counterpart of FR-TASK-001. |

### 3.3 Non-functional requirements

| ID | Category | Requirement (metric, target, condition) | Priority |
| :-- | :-- | :-- | :-- |
| NFR-PERF-001 | Performance | 95% of API calls complete within 200 ms with 1,000 tasks stored. | Must |
| NFR-A11Y-001 | Accessibility | All screens meet WCAG 2.1 AA contrast and keyboard operability. | Must |

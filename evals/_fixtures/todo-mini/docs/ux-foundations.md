# UX Foundations: Todo Mini

> Status: Reviewed · Last updated: 2026-09-03
> Inputs: docs/srs.md v2 · docs/architecture.md · docs/use-cases.md
> Design system: docs/design.md (values live there and in tokens.json — not restated here)

## 1. Personas

- **The lone planner** — one person keeping a short daily list; wants speed and zero setup.

## 2. Surfaces

| Code | Surface | Notes |
| :-- | :-- | :-- |
| WEB | Browser SPA | The only surface in v1 |

## 3. Information architecture and navigation

Single screen with a modal for adding; a detail panel for one task. No global
navigation beyond the list.

## 4. Screen inventory

| SCR ID | Screen | Purpose | Key states | Traces to |
| :-- | :-- | :-- | :-- | :-- |
| SCR-WEB-001 | Task list | The home view; lists tasks newest first | default, empty, loading, error | UC-003, FR-TASK-004 |
| SCR-WEB-002 | Add task | Capture a title | default, error (empty title) | UC-001, FR-TASK-001, FR-TASK-006 |
| SCR-WEB-003 | Task detail | Complete or archive one task | default, done | UC-002, UC-004, FR-TASK-002, FR-TASK-005 |

## 5. Key flows

- Add: SCR-WEB-001 → SCR-WEB-002 → SCR-WEB-001 (new task on top).
- Complete: SCR-WEB-001 → SCR-WEB-003 → SCR-WEB-001 (task marked done).

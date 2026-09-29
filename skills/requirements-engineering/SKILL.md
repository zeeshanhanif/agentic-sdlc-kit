---
name: requirements-engineering
description: >-
  Runs the requirements-engineering phase — the first SDLC step, upstream of
  design. Through a thorough, area-by-area interview it elicits and specifies
  the complete requirements for a new application, proactively enumerating the
  standard sub-requirements for each capability area (for authentication:
  sign-up, sign-in, verification, password reset, logout) plus all
  non-functional requirements. Produces a structured SRS (ISO/IEC/IEEE 29148
  lineage) with functional requirements in EARS syntax or classic "shall"
  statements, in markdown, a separate use-case document, and a
  requirements traceability matrix. Also amends a finalized SRS —
  adding, updating, or removing requirements with stable IDs. Use at the start
  of a project before architecture and UX, or when changing existing
  requirements. Trigger on "gather requirements", "write an SRS", "requirements
  engineering", "specify the requirements", "add a requirement", or "update the
  requirements". Saves progress incrementally so long sessions can resume.
---

# Requirements Engineering

This skill produces the **traditional, structured requirements specification**
that sits at the very front of the SDLC — upstream of architecture and UX. It is
deliberately a *detail phase*: its job is to capture **every** requirement
comprehensively, so that the documents it produces become the single source of
truth the design and planning skills downstream consume.

Two principles define it:

1. **Exhaustive enumeration, not transcription.** When a capability area comes
   up, the skill does not merely record what the user mentions. It proactively
   proposes the full set of standard sub-requirements for that area and has the
   user confirm, extend, or remove them. "User authentication" is never one line
   — it expands into sign-up, sign-in, email verification, forgot password, reset
   password, change password, logout, session expiry, account lockout, rate
   limiting, and so on. The `requirement-catalog.md` reference is the engine for
   this. The same discipline applies to non-functional requirements.

2. **Structured and traditional.** The output is a formal SRS in the
   ISO/IEC/IEEE 29148 (IEEE 830) lineage — numbered, uniquely-identified,
   testable requirements — not an agile backlog. Whatever the SRS calls a unit
   (function / feature) is fine; **epic and feature slicing is deliberately
   deferred to the downstream implementation-planning skill.** This skill owns
   the problem space, comprehensively.

Because a full requirements interview is long, the skill **checkpoints its work
incrementally** and can **resume** after an interruption — see Phase 0 and
`references/checkpointing.md`.

## Inputs

This is the first skill in the pipeline, so it has no upstream document to
consume — it elicits from the user. If the user has an existing brief, notes, or
partial requirements, ingest them first and treat them as raw input to confirm
and expand, not as finished requirements.

## Outputs

Three files (three logical documents), all markdown, written to `docs/`.

1. `docs/srs.md` — the comprehensive SRS (the source of truth downstream skills
   read). Vision & scope, user characteristics, constraints, assumptions,
   glossary, **functional requirements**, and **non-functional requirements** all
   live here as structured sections.
2. `docs/use-cases.md` — detailed textual use-case specifications plus a Mermaid
   use-case diagram (separate document, use-case-centric; no user stories).
3. `docs/rtm.md` — the Requirements Traceability Matrix (markdown table).

Word/PDF output is **out of scope** — markdown is the deliverable. Users who want
a Word version can convert it themselves (e.g., with pandoc); this skill does not
own that.

Plus working files that are **not** deliverables: `docs/.requirements-progress.md`
(the progress tracker), and the incrementally-built `srs.md` / `use-cases.md`
drafts themselves (which become deliverables 1 and 2 once finalized).

## Workflow

### Phase 0 — Mode detection (always first)

Before anything else, look for `docs/.requirements-progress.md` and `docs/srs.md`
and read `references/checkpointing.md`. Determine which of **three** modes applies
by combining what's on disk with the user's intent:

- **Fresh start** — no SRS and no tracker. Create the progress tracker and the
  SRS skeleton, then begin Phase 1.
- **Resume** — a tracker exists with `pending`/`in-progress` areas (the interview
  was interrupted). Read both files, summarize what's captured and what remains,
  and continue from the first pending area.
- **Amendment** — a **finalized** SRS exists (tracker shows no pending work, or is
  marked finalized) and the user wants to change requirements. Switch to amendment
  handling (Phase A) instead of resuming or restarting.

Detection is automatic — **the user passes no special flag.** The finalized SRS on
disk is the precondition; the user's plain-language intent disambiguates ("add a
requirement", "update FR-AUTH-007", "remove…" → amendment; "spec a new project" →
fresh; "what does the SRS say…" → just answer). Two firm rules:

- **Resume beats amend.** If the interview is unfinished and the user asks to add
  something new, finish the pending areas first, then handle the new request —
  amending a half-specified SRS invites inconsistency.
- **When an SRS exists and intent is ambiguous, confirm before acting — never
  silently restart.** A bare invocation against a finalized SRS gets a short
  question ("There's a finalized SRS here — v1.2, 47 functional / 19
  non-functional. Amend it, ask about it, or start a new one?"), not a guess. The
  expensive failure is wiping or duplicating a finalized SRS; one cheap question
  prevents it.

### Phase 1 — Frame and scope

Establish the foundation: the product's purpose and vision, business goals and
success metrics, the primary stakeholders, the user classes/personas, and the
overall scope (what's in, what's out, MVP boundary). Write these into the SRS's
introduction and overall-description sections immediately, and mark the area done
in the tracker. This section also seeds the user-characteristics content that
ux-foundations will later consume.

**Close Phase 1 with the requirement-syntax decision.** Ask the user whether
functional requirements should be written in **EARS** (five constrained
patterns — see `references/ears-guide.md`) or as **free-form "shall"
statements**, and recommend based on what Phase 1 revealed: EARS when the SRS
feeds automated/agent pipelines or a regulated domain, or when error-handling
completeness matters (usually the right call); free-form when the team must
author amendments by hand and won't learn the patterns. Default to EARS if the
user has no preference. Record the choice in the SRS header line (`Requirement
syntax: EARS | shall`) and the tracker header. **Asked once, before the first
FR is minted, never re-asked** — resume sessions read it from the tracker or
SRS, and amendments follow whatever the SRS records.

### Phase 2 — Functional requirements, area by area (the detail loop)

This is the core. Read `references/elicitation-guide.md`,
`references/requirement-catalog.md`, and `references/ears-guide.md`. Work through
the application **one capability area at a time**. For each area:
- Propose the standard sub-requirements from the catalog as a checklist, in plain
  language, and ask the user to confirm / extend / remove.
- Specify each confirmed requirement formally: a unique ID (e.g.,
  `FR-AUTH-001`), a clear testable statement **in the recorded syntax** (EARS
  per the ears-guide, or free-form "shall" if that was chosen in Phase 1),
  priority, and any rules/validation.
- Write the finalized area straight into `docs/srs.md`, then update the progress
  tracker before moving to the next area.

Cover every area the application needs — not just the obvious ones. The catalog
lists commonly-forgotten areas (audit logging, account deletion, rate limiting,
admin/back-office) to prompt with.

### Phase 3 — Non-functional requirements

Read the NFR section of `references/requirement-catalog.md` (organized on the ISO
25010 quality model). Walk each relevant category — performance, scalability,
availability/reliability, security, usability/accessibility, compatibility,
maintainability, compliance/legal, localization, observability — and specify
**measurable** NFRs with unique IDs (e.g., `NFR-PERF-001`). Vague NFRs are not
acceptable; "fast" becomes a number. Write into the SRS and checkpoint.

### Phase 4 — External interface requirements

Capture the external interfaces the SRS lineage expects: user interfaces (at the
requirements level), hardware, software/third-party integrations, and
communication interfaces. Write into the SRS and checkpoint.

### Phase 5 — Use cases

Read `references/use-case-guide.md`. Derive use cases from the functional
requirements. For each use case, write a detailed textual specification (ID,
name, actors, preconditions, postconditions, main success scenario, alternate
flows, exception flows, and the FRs it traces to) into `docs/use-cases.md`, and
add the Mermaid use-case diagram(s) grouping actors and use cases by the system
boundary. Checkpoint as you complete each use case.

### Phase 6 — Traceability matrix

Read `references/rtm-guide.md` and build `docs/rtm.md`: a table linking every
requirement ID to its source and to the use case(s) that exercise it, with
placeholder columns for the downstream design and test artifacts. Because every
requirement was given a stable ID during specification, this is largely
assembly.

### Phase 7 — Deliver

Confirm all three files exist. Summarize the requirement counts (e.g., "47
functional across 8 areas, 19 non-functional, 12 use cases") and any open
questions or TBDs flagged during elicitation. Note that `docs/srs.md` is the
source of truth the architecture, UX, and planning skills will consume. Mark the
SRS finalized in the progress tracker (this is what later distinguishes amendment
mode from resume). Offer to proceed to `software-architecture`.

## Phase A — Amending a finalized SRS

Entered from Phase 0 when a finalized SRS exists and the user wants to change
requirements. Read `references/change-management.md` for the full protocol. The
cardinal rule: **requirement IDs are immutable and never recycled** — everything
downstream references them. In brief:

1. **Classify each change** as add, modify, or remove, and apply its rule:
   - *Add* → assign the next free ID in that area (never reuse a retired number),
     specify it with the same enumeration discipline, append it.
   - *Modify* → keep the same ID, change the statement.
   - *Remove* → do **not** delete or renumber; mark the requirement
     `Deprecated`/`Removed` and keep the row so traceability and dangling
     references stay visible.
2. **Version and log.** Bump the SRS version and add a revision-history entry
   recording what changed, when, and which IDs were affected.
3. **Propagate.** Update the use case(s) that trace to the changed ID and update
   the RTM row(s) so all three markdown files stay consistent. The RTM is the
   index for what a change touches.
4. **Emit a cross-skill impact note.** When a finalized requirement that
   downstream docs were built on is modified or removed, you can't edit those
   docs, but you must not stay silent: report which downstream documents
   referenced the affected IDs (architecture, ux-foundations, implementation-plan)
   so the user knows what to review or re-run.

Amendment reuses the same catalog, templates, and checkpointing as authoring —
each amendment is itself written to disk and logged before moving on.

## Scope boundaries

It deliberately does **not**:
- slice requirements into epics/vertical features — that's
  `implementation-planning`;
- make architectural or UX design decisions — those are the design-phase skills
  (which will *read* this SRS rather than re-eliciting NFRs and personas);
- write user stories — this is use-case-centric by design.

## What good looks like

- Every capability area is enumerated to its standard sub-requirements, not just
  what the user first mentioned.
- Every requirement has a unique, stable ID and is individually testable.
- Statements follow the syntax recorded in the SRS header; in EARS mode,
  trigger-less (ubiquitous) statements are the exception, not the default.
- NFRs are measurable, never vague.
- Work is checkpointed so a stop or network drop never loses captured areas.
- The three outputs are internally consistent and cross-referenced via the RTM.

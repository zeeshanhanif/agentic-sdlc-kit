---
name: ux-foundations
description: >-
  Establishes the UX and design foundations for an application before feature
  work begins — the "architecture of the UI." Consumes the upstream SRS
  (docs/srs.md) and architecture document (docs/architecture.md) when present,
  then builds the design system from one of four user-chosen source modes:
  research a new direction, extract from reference images, ingest an existing
  design file, or pull from a connected design tool (e.g., Figma via MCP).
  Produces docs/ux-foundations.md (personas, IA, navigation, flows, screen
  inventory per surface), docs/design.md (agent-ready design system: tokens,
  components, states, layout and usage rules), and tokens.json (W3C DTCG).
  Use in the design phase, after architecture and before implementation
  planning, for any application with one or more UI surfaces. Trigger on
  "design the UX foundations", "set up the design system", "what should the
  UI look like", "plan the screens and navigation", or "create the design
  language".
---

# UX Foundations

This skill defines the **structure and design language of the UI** before any
feature is built — the counterpart to a software-architecture document, but for
the experience layer. It produces the *system* screens are later assembled
from, not pixel-perfect screens.

The governing idea, especially with several interfaces: **one shared core,
defined once, plus a per-surface layer for each interface.** A single design
language spans every surface so the product feels like one thing; each surface
(admin portal, website, mobile app) gets its own profile because its users,
navigation, components, and context genuinely differ.

## Inputs

Two kinds of input with **different consumption rules**:

**Pipeline documents — read silently, never ask.** These are this pipeline's own
upstream artifacts in their contracted locations; consuming them is the pipeline
working as designed.

- **SRS** — default `docs/srs.md`. Read §2.3 (user classes & characteristics —
  the personas source; do not re-elicit them), §1.2 (vision/scope), the
  accessibility/usability NFRs in §3.3 (**the accessibility bar comes from
  here and is non-negotiable** — it overrides any ingested design), and any
  brand/compliance constraints in §2.5. Note NFR IDs for citation.
- **Architecture** — default `docs/architecture.md`. Read the UI surfaces (they
  appear as containers/building blocks), the context diagram's actors, and any
  frontend stack constraints.
- **Use cases** — `docs/use-cases.md` if present: key user flows often realize
  use cases; cite UC IDs where they do.

**Source-gated traceability** (same rule as the architecture skill): cite SRS
NFR/FR IDs and UC IDs only when those documents exist; otherwise state drivers
in prose. Never fabricate an ID.

**Design source — always ask, never assume.** Detection tells you what's
*possible*; only the user can tell you what's *wanted*. A design.md in the
folder may be stale; images may be leftovers; the user may want a fresh
direction despite having sources. See Phase 1.

**Fallback:** if the pipeline documents are missing, say so and elicit surfaces
and users directly (reduced mode) — the skill stays usable standalone.

## Outputs

Three files, with a strict **authority split**:

1. `docs/ux-foundations.md` — the **plan-time** document: personas, per-surface
   IA and navigation, key user flows, screen inventories, cross-surface
   reconciliation. This is what implementation-planning consumes. It
   *references* design.md for anything design-system and never restates token
   values — design.md is the single source of truth for those.
2. `docs/design.md` — the **render-time** document a coding agent loads when
   building UI: tokens (with inline CSS-variable form), component specs with
   states and variants (including per-surface variants), layout/grid rules,
   accessibility rules, do/don'ts, agent quick-reference, provenance and known
   gaps. See `references/design-md-guide.md`.
3. `docs/tokens.json` — the canonical machine-readable tokens in **W3C DTCG
   format** (industry-standard interchange; transforms to CSS/Tailwind/native
   downstream). design.md's CSS block is derived from it — same values, one
   source of truth.

## Workflow

### Phase 1 — Ingest, detect, and ask the mode question

1. **Silently ingest pipeline documents** (per Inputs): surfaces and actors from
   the architecture, user classes and the accessibility bar from the SRS.
2. **Detect candidate design sources**: a design file (`design.md` or similar)
   in the project, reference images **in `docs/design-refs/` only** (the
   convention location — no design-refs folder or no images there means images
   are treated as not present; do not scan the wider project), connected
   design-tool MCPs — Figma (covering Figma Make), Claude Design, or any other.
   Detect them **by capability, from the tools available in this session**,
   never by an exact server name; a listed tool proves presence, not
   authorization, so treat "connected" as unproven until a cheap identity call
   succeeds.
   User-provided paths or attached images always
   win over detection. Detection is for *presenting options*, not for deciding.
3. **Always ask the mode question** — even when nothing is found, and even when
   exactly one source is found. Report what was detected, then offer the full
   menu with detected sources as named concrete options:
   - **Research** — no design source; research and propose a direction
     (comparable products, current conventions, the SRS's audience) before
     tokenizing. Degrade gracefully to expertise-based proposal without web
     access.
   - **Extract from images** — reference images from `docs/design-refs/` (if
     detected) or paths/attachments the user supplies; if the mode is chosen
     and no images are available, ask for them — never hunt the wider project.
     Extract palette, type feel, spacing, component shapes.
   - **Ingest a design file** — user provides (or confirms detected) an
     external design.md/brand document; map it onto our structure.
   - **Connect a design tool** — pull tokens/styles/components via MCP
     (detected tools named as concrete options). If the mode is chosen and
     nothing is connected, **offer to connect one** and say what it buys;
     never silently fall back to another mode. `design-tool-integrations.md`
     carries detection, the connection paths, and per-tool fetches.
   Folded variants: brand guidelines (PDF brand book) → ingest variant;
   existing codebase (CSS/Tailwind config) → extract variant, highest
   fidelity; mandated component framework (Material, shadcn) → one elicitation
   question in any mode, constrains the component layer.
   The user's explicit choice also resolves multi-source conflicts; within the
   chosen source, `references/source-modes.md` governs. **SRS accessibility
   NFRs override every mode's output.**
4. Confirm the surface list from the architecture ("I see three UI surfaces:
   admin portal, public website, mobile app — correct?"). Surfaces are the
   spine of everything downstream.

### Phase 2 — Elicit the UX specifics

Read `references/elicitation-guide.md`. Personas come from SRS §2.3 — confirm,
don't re-elicit. Ask only what upstream doesn't answer: per-surface device and
responsive targets, brand feel (research mode), voice/tone, i18n. Batch
questions, state inferences, offer one-word defaults.

### Phase 3 — Acquire the design direction (mode-specific)

Read `references/source-modes.md` and run the chosen mode's acquisition
protocol. For connected tools, `references/design-tool-integrations.md` has
per-tool guidance with a generic fallback. Every mode ends the same way: a
**proposed design direction played back for confirmation** (extraction is
approximation; ingestion has conflicts to surface; research is a proposal).
Never assert — confirm.

### Phase 4 — Establish the shared core (once)

Read `references/design-system-guide.md`. Codify the confirmed direction into
the shared core: semantic role-based tokens, core component inventory with
states, voice, and the accessibility standard (from the SRS NFRs, cited by ID).

### Phase 5 — Profile each surface (loop)

Read `references/surface-profile-guide.md`. Per surface: assign the surface code
(confirm with the user), then users and jobs (from SRS user classes), IA and
navigation, key flows (cite UC IDs where flows realize use cases), the screen
inventory with **stable `SCR-<CODE>-<NNN>` IDs per screen** (same
never-renumber rules as requirement IDs — downstream slices reference them),
surface-specific components, token overrides.

### Phase 6 — Reconcile across surfaces

Shared vs. surface-specific components, flows that span surfaces, consistency
rules.

### Phase 7 — Generate the three outputs

1. `docs/tokens.json` — DTCG format, per the design-system guide.
2. `docs/design.md` — per `references/design-md-guide.md`, deriving the CSS
   block from tokens.json.
3. `docs/ux-foundations.md` — per `references/document-template.md`, with
   embedded Mermaid sitemaps and flow diagrams (see
   `references/diagram-guide.md`), referencing design.md rather than restating
   it.

### Phase 8 — Deliver

Summarize the design direction, the surface set, and the three outputs. Note
the handoffs: the **screen inventory** feeds implementation-planning; **design.md
+ tokens.json** feed every UI-building session downstream (suggest referencing
design.md from CLAUDE.md). Offer next steps: anchor screen mockups, or proceed
to implementation-planning.

## Scope boundaries

Does **not** produce pixel-perfect per-feature screens (per-slice detailed
design, downstream) or frontend component code (build). System and structure
only — which is exactly what lets one core span web and native surfaces.

## What good looks like

- Personas trace to SRS user classes; the accessibility bar cites its NFR IDs;
  flows cite the UC IDs they realize (all source-gated, never fabricated).
- Every screen has a stable `SCR-<CODE>-<NNN>` ID; no duplicates, no renumbering
  — the inventory is the reference downstream slices and ui-design cite.
- The mode question was asked explicitly; the chosen source's provenance and
  known gaps are recorded in design.md.
- design.md is agent-ready: concrete values, states, usage rules — no vagueness.
- tokens.json, design.md's CSS block, and ux-foundations.md never disagree,
  because value authority lives in tokens.json/design.md alone.
- One coherent core; per-surface layers diverge only where context demands.

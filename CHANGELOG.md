# Changelog

All notable changes to this collection of Agent Skills are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Entries are grouped by date. Releases are tagged, and a release that changes what
the plugin ships must bump `version` in `.claude-plugin/plugin.json` — Claude Code
pins its cache to that string, so plugin users keep the old copy until it changes.

## [Unreleased]

### Added
- **`ux-foundations` Mode 4 can now find and connect a design tool.** The mode
  previously assumed one was already connected and named only Figma. Its
  reference gains a **detection and connection** section: three states rather
  than two (absent / configured-but-unauthorized / connected — a server whose
  tools are listed can still fail every call), detection by **tool-name prefix
  substring** because server names are mangled (`claude.ai Figma` surfaces as
  `mcp__claude_ai_Figma__*`), an identity probe to prove authorization, and the
  connection paths for Figma and Claude Design. `SKILL.md` Phase 1 gains the
  branch it was missing: Mode 4 chosen with nothing connected now **offers to
  connect** instead of behaving undefinedly, and never silently downgrades.
- **Claude Design** promoted from a three-line stub in both integration
  references. Design systems are first-class there, which makes it a token
  *source* rather than a generator to screenshot; enumeration (projects, files)
  is confirmed rather than assumed, so `ui-design` can register prior screens
  instead of regenerating them. Notes that the built-in design skill is **not**
  a substitute for the MCP server — it publishes artifacts but exposes none of
  the fetches.
- **Figma Make** promoted from a three-line stub, and corrected: it is **not a
  separate integration**. Same server and auth as Figma, nothing extra to
  connect — but only the design-context fetch accepts a `/make/` file. No
  variables, no structure metadata, no screenshot, and no write path, so
  `ui-design` records that **generating *into* Make is unavailable** (generate
  into a Figma design file or fall to code-native).

### Changed
- **`design_provenance` fidelity is now decided by the source, not the mode.**
  `design-md-guide.md` §9 previously hard-mapped "tool → exact". That is wrong
  for a prompt-to-app tool: with no variables to read, tokens are inferred from
  generated code, which is `mapped`. Recording `exact` there claimed a precision
  nobody measured — and `ui-design/references/strategy-guide.md` reads this
  field to choose its anchor strategy. Tool mode is now `exact` only when values
  were *read* (variables, a published design system), `mapped` when *inferred*.
  Adds the missing `source.tool` slug vocabulary (`figma` | `figma-make` |
  `claude-design` | `open-design` | `<slug>`), keeping `figma` and `figma-make`
  distinct despite the shared connection because they differ in what was
  fetchable. Also fixes a stray unbalanced code fence in that section.
- **`source-modes.md` Mode 4** no longer calls tool mode "the highest-fidelity
  source" unconditionally — true when the tool publishes values, false for
  generated artifacts.
- **CLAUDE.md** records both as cross-skill contracts, plus the rule that the
  two `design-tool-integrations.md` files carry **no date stamps**: current
  command shapes plus "verify against live docs", since a dated block reads
  stale within a week and invites distrust of the whole file.

## [2.0.0] — 2026-09-15

### Added
- **Claude Code plugin distribution**, alongside the existing `skills` CLI path —
  the twelve skills install as **one plugin** from this repo's own marketplace:
  `/plugin marketplace add zeeshanhanif/agentic-sdlc-kit` then
  `/plugin install agentic-sdlc-kit@zeeshanhanif`. One plugin rather than twelve
  because the skills share an ID vocabulary and the RTM's per-column ownership; a
  partial install leaves dangling references. Users wanting a subset keep using the
  `skills` CLI.
- **`.claude-plugin/plugin.json`** — the plugin manifest, carrying `license`
  (Apache-2.0), `repository`, `homepage`, `author`, and `keywords`. It declares
  **no `skills` field**: a root-level `skills/` directory is auto-discovered. It is
  the **single** declaration site for `version`.
- **`.claude-plugin/marketplace.json`** — the `zeeshanhanif` marketplace, a single
  entry with `"source": "./"`. Deliberately carries **no `version`** (plugin.json
  wins silently, so declaring it twice masks bumps) and no `skills` field.

### Changed
- **README Install section** restructured into **three co-equal paths** — the
  `skills` CLI first (the cross-agent path, and the only one that installs a
  subset), the Claude Code plugin second, manual copy third. The CLI's whole-kit
  `--skill '*'`, interactive checklist, per-skill `--skill <name>`, and flag table
  are unchanged. Adds one note giving both invocation forms side by side:
  `/requirements-engineering` for CLI and manual installs,
  `/agentic-sdlc-kit:requirements-engineering` for plugin installs — neither is the
  canonical form, both coexist, and description-based auto-triggering is identical
  either way. Walkthrough examples keep the bare form.
- **CLAUDE.md** records the plugin invariants: `skills/` is auto-discovered (never
  declare it, never move it into `.claude-plugin/`), `plugin.json`'s `name` is the
  namespace prefix, the bump-every-release rule, and the requirement that skills go
  on referring to each other by bare name rather than any slash form — the property
  that lets one set of skill files serve all three install paths.
- **License** changed from **MIT** to the **Apache License 2.0**. Apache adds an
  explicit patent grant with a retaliation clause and requires downstream
  modifiers to state that they changed files. Adds a root **`NOTICE`** file that
  redistributions must carry forward (Apache-2.0 §4(d)); the README License
  section points at both. Skills are unchanged — no per-file license headers and
  no `license:` frontmatter key, since `SKILL.md` content is loaded into an
  agent's context on every invocation.

## [2026-08-11]

### Changed
- **`initial-deployment`** artifact vocabulary aligned to the skill name:
  `docs/deploy-notes.md` → **`docs/deployment-notes.md`**,
  `docs/.deploy-progress.md` → **`docs/.deployment-progress.md`**,
  "deploy plan" → "deployment plan" for the money gate. Adds **Output 4** —
  one narrow foreign write into `docs/scaffold-notes.md` to close the pending
  initial-deployment marker in place (the only other skill's artifact touched).
- **README** and **CLAUDE.md** updated for the renamed artifacts, checkpoint
  file, scaffold-notes close, and foreign-write boundary.

## [2026-08-10]

### Added
- **`initial-deployment`** skill — the **last mile from deploy-ready to
  running in the cloud**. Provisions from repo deployment artifacts, wires
  secrets and CD, deploys, verifies live, and folds in the day-1 operations
  floor. Money and credentials gates; checkpointed progress; cloud-agnostic
  process with live provider docs. Closes the walking skeleton done-when's
  pending deployed half. Output: running system + deployment notes. Writes no
  RTM column. Reference guides: `deployment-guide.md`, `operations-minimum.md`,
  `verification.md`.

### Changed
- **`project-scaffolding`** and **`sdlc-orchestrator`** wired to
  **`initial-deployment`**: deploy-ready boundary, "initial deployment"
  terminology, orchestrator points at initial-deployment when undeployed.
- **README** and **CLAUDE.md** updated for the **eleven-skill pipeline**
  (initial-deployment as sixth one-pass skill), testing/coverage hand-off
  chain, and "When editing initial-deployment" guide.

## [2026-08-05]

### Changed
- **Code coverage stance** added across the testing pipeline — architecture
  decides none / report-only / enforced threshold; scaffolding realizes it
  in CI; feature-implementation treats the gate as developer-done with
  anti-fake-green extended to coverage config; acceptance-verification audits
  config diffs and re-runs the gate (`software-architecture`,
  `project-scaffolding`, `feature-implementation`, `acceptance-verification`).

## [2026-07-23]

### Added
- **`sdlc-orchestrator`** skill — a **thin loop driver and lifecycle router**
  over the four per-feature loop skills. Computes global position from
  artifacts (never stores orchestrator state), invokes the next stage in plan
  order, and routes outcomes (rework → implementation with a 2-cycle bound,
  design-defect/escalation/blocked → pause and surface). Also owns two
  lifecycle routes: **change requests** walk the amendment chain
  (requirements → architecture/UX impact → plan) before the loop picks up
  the new FEAT, and **bugs** become a `docs/defects.md` `DEF-NNN` entry,
  a failing test first, a scoped fix, and re-verification. Owns only the
  defect ledger; writes no pipeline document or RTM column. Reference guides:
  `routing-guide.md`, `lifecycle-routes.md`.

### Changed
- **`requirements-engineering`** adds an **EARS syntax option** for functional
  requirements — a once-per-SRS choice at end of Phase 1 (EARS five patterns
  or free-form "shall"), recorded in the SRS header and progress tracker,
  binding on all FR authoring and amendments. Includes unwanted-behavior pass
  per capability area. New reference: `ears-guide.md`; updates to
  `elicitation-guide.md`, `srs-template.md`, `checkpointing.md`,
  `change-management.md`.
- **README** and **CLAUDE.md** updated for the **ten-skill pipeline**
  (`sdlc-orchestrator` over the four-skill loop), lifecycle routing, defect
  ledger, and EARS in the requirements-engineering overview.

## [2026-07-19]

### Added
- **`feature-implementation`** skill — the **construction step** of the
  per-feature loop, run after both design halves exist. **tasks.md is the
  program; this skill is the interpreter:** executes tasks in order, one per
  iteration, each done-when demonstrated (never asserted), one commit per
  task, ending **developer-done**. Seven disciplines target agentic failure
  modes: improvisation-is-escalation, disk-as-memory, anti-fake-green,
  bounded fix-loops (default 3), scope discipline, convention conformance
  (inherited test frameworks; tokens, never raw values), and git-as-checkpoint.
  Writes no RTM column. Reference guides: `execution-guide.md`,
  `failure-and-escalation.md`, `verification.md`.

### Changed
- **`detailed-design`** **`tasks.md` done-when classification** — behavioral
  tasks (logic, contract semantics, validation) get test-artifact done-whens;
  structural/realization tasks (schema, wiring, screen realization) get
  demonstration done-whens — so `feature-implementation` executes verification
  by kind instead of improvising per task.
- **README** and **CLAUDE.md** updated for the **nine-skill pipeline** (linear
  requirements-to-skeleton pass plus the four-skill per-feature construction
  loop: `detailed-design` → `ui-design` → `feature-implementation` →
  `acceptance-verification`), RTM Test-ref lifecycle, testing hand-offs, and
  "When editing" guides for both new loop skills.

## [2026-07-18]

### Added
- **`acceptance-verification`** skill — the **independent auditor** that
  closes the per-feature loop after `feature-implementation` declares
  *developer-done*. Re-derives the audit standard from authoritative documents
  (never from checkboxes or claimed greens), audits and corrects weak tests
  (the one artifact class it may change — never fixes production code),
  re-runs all suites fresh, verifies FRs/NFRs directly, and delivers
  **accepted / rework / design defect** verdicts in `acceptance-report.md`.
  On acceptance, appends the RTM **Test ref** column, completing Plan ref →
  Design ref → Test ref. Reference guides: `audit-guide.md`,
  `verdict-and-report.md`.

### Changed
- **`software-architecture`** adds **testing strategy and framework decisions**
  as a first-class cross-cutting concern: pyramid shape traced to NFRs, named
  critical E2E flows (from use cases), and user-selected unit/integration
  and E2E frameworks via live-researched shortlists in Round 7
  (`decision-guide.md`, `elicitation-guide.md`, `document-template.md`).
- **`project-scaffolding`** **realizes architecture-named test frameworks** —
  installs the unit/integration runners and E2E framework the architecture
  chose (execute, don't re-decide); stands up an E2E workspace with the
  skeleton test as the suite seed (`scaffolding-guide.md`, `skeleton-guide.md`,
  `verification.md`).
- **`detailed-design`** adds **flow-aware E2E extension tasks** — when a
  feature's UC IDs intersect architecture-named critical flows, `tasks.md`
  includes an explicit E2E-extension task before final verification
  (`tasks-guide.md`, `verification.md`).
- **`requirements-engineering`** **RTM Test-ref contract** — `(partial)`
  markers are permanent scope descriptions; **full verification is computed**
  from Plan ref ∩ Test ref intersection, never stored in the cell
  (`rtm-guide.md`).
- **`requirements-engineering`** fixes stale **"five outputs"** and **Phase 8**
  references left over from Word-generation removal (three markdown
  deliverables; finalization at Phase 7).
- **README** and **CLAUDE.md** updated for the **seven-skill pipeline**
  (`ui-design` as detailed-design's presentation sibling, `FEAT-NNN` join
  key, extended RTM Design-ref write-back).

## [2026-07-17]

### Added
- **`ui-design`** skill — the **presentation half** of the per-feature
  construction loop, run sequentially after `detailed-design`. Three modes:
  *anchor* (validate the design system composes after ux-foundations),
  *per-feature* (design a slice's SCR screens against its
  `technical-design.md` contracts), and *re-verification* (after a
  `design.md` amendment). Resolves strategy **per screen** — register
  existing tool designs (Figma, Claude Design, etc. via MCP), generate, or
  code-native spec — and emits a uniform **`docs/design-manifest.json`**
  (SCR-keyed, single-writer registry) plus `ui-design.md` or
  `anchor-screens.md`. Screens conform to `design.md` + `tokens.json` or
  escalate to a ux-foundations amendment; appends Design ref to the RTM.
  Reference guides: `strategy-guide.md`, `design-tool-integrations.md`,
  `manifest-guide.md`, `document-templates.md`, `verification.md`.
- **`design_provenance` block** in `docs/design.md` — a structured JSON
  object written in **every** ux-foundations source mode (`mode` and
  `fidelity` always; `source` with tool + locator only in tool mode).
  Drives ui-design's anchor recommendation gradient and tool-sourced screen
  lookup (supersedes the earlier mode-4-only `design_source` block).

### Changed
- **`detailed-design`** resolves the next feature **deterministically** from
  plan build order (first slice without a design folder — no menu); announces
  the resolution so the user can redirect before work starts. Matches
  ui-design's per-feature selection rule (first folder with
  `technical-design.md` but no `ui-design.md`).

## [2026-07-13]

### Changed
- **`implementation-planning`** mints a stable **`FEAT-NNN` ID** for every
  feature slice (sequential in definition order, never renumbered/recycled,
  tombstoned on removal — same discipline as FR/SCR IDs). RTM Plan-ref
  write-back now keys on the FEAT ID; the ID is the join key for
  detailed-design, ui-design, and the RTM.

## [2026-07-12]

### Changed
- **README** and **CLAUDE.md** updated for the six-skill pipeline (linear
  requirements-to-skeleton pass plus the per-feature construction loop),
  `detailed-design` as the first loop skill, and extended RTM Design-ref
  write-back.

### Added
- **`detailed-design`** skill — the first **per-feature loop skill**, run once
  for each vertical slice as it reaches the front of the plan. Reads the plan,
  SRS, use cases, architecture, and the **live codebase** (mandatory), then
  produces per-feature `technical-design.md` (API contracts, schema migrations,
  component design, acceptance criteria) and `tasks.md` under
  `docs/features/FEAT-NNN-<slug>/`. Designs the *how* with the *what* fixed by
  FR/UC IDs; escalates new entities to an architecture amendment; appends
  Design ref to the RTM. Hands contracts to ui-design and tasks to
  implementation.

## [2026-07-11]

### Added
- **`project-scaffolding`** skill — the first skill whose output is a running
  system, not a document. Reads the architecture and implementation plan (plus
  ux-foundations/design/tokens for the UI shell), runs each ecosystem's official
  project generator per container, wires the walking skeleton end-to-end, stands
  up engineering foundations deploy-ready but not deployed, and verifies
  empirically by building and running the skeleton test. Checkpoints progress
  and resumes safely — never regenerates over a partial scaffold.

### Changed
- **README** and **CLAUDE.md** updated for the five-skill pipeline
  (requirements → architecture → ux-foundations → planning → scaffolding),
  the RTM multi-writer contract, implementation-planning's full-pipeline
  consumption, stable SCR IDs, and project-scaffolding.
- **`implementation-planning`** now consumes the **full pipeline** — SRS, use
  cases, architecture, and ux-foundations (each degrading independently):
  - Every slice traces **FR IDs** implemented, **UC IDs** realized, and **SCR
    IDs** touched; tombstoned requirements and screens are skipped.
  - A **Must-requirement coverage check** ensures every Must-priority FR and
    inventory screen is sliced, placed in foundations, or explicitly excluded.
  - SRS **MoSCoW priorities** break sequencing ties after dependency/risk
    ordering.
  - A mechanical **verification** pass (`verification.md`) before delivery.
  - The first-slice spec names downstream handoffs to **ui-design** (screens by
    SCR ID) and **detailed-design** (contracts/data).

### Added
- **RTM multi-writer column ownership** — the traceability matrix is now a
  living ledger each phase fills at delivery:
  - `requirements-engineering` owns rows and requirement columns; initializes
    Design/Plan/Test refs as `_TBD_`.
  - `software-architecture` writes **Design ref** (ADR refs per a layer rule:
    NFR rows → ADR; FR rows → ADR only when genuinely cited).
  - `implementation-planning` writes **Plan ref** (the scheduling slice).
  - Every writer **appends, never overwrites**; skips silently when no RTM
    exists (standalone runs).

## [2026-07-10]

### Changed
- **`ux-foundations`** substantially reworked along three axes:
  - **Inputs** — now consumes the SRS (`docs/srs.md`) and use-case document
    (`docs/use-cases.md`) alongside the architecture: personas come from SRS
    §2.3 user classes, the accessibility bar from §3.3 NFRs (non-negotiable,
    overrides ingested designs), and brand/compliance from §2.5. ID citations
    are source-gated (cite SRS/UC IDs only when those documents exist, never
    fabricated), with graceful standalone fallback.
  - **Design source** — Phase 1 detects candidate design sources and always asks
    the user which of four modes to use: research a new direction, extract from
    reference images (`docs/design-refs/`), ingest an existing design file, or
    connect a design tool via MCP (e.g., Figma).
  - **Outputs** — split into three files with a strict authority split:
    `docs/ux-foundations.md` (plan-time; references the design system, never
    restates values), `docs/design.md` (render-time, agent-ready design system),
    and `docs/tokens.json` (canonical tokens in W3C DTCG format).
- **`ux-foundations`** screen inventory now assigns every screen a stable
  **`SCR-<CODE>-<NNN>` ID** per surface (same never-renumber/tombstone rules as
  requirement IDs), so downstream slices and ui-design reference screens
  precisely.

### Added
- `ux-foundations` reference guides: `source-modes.md`, `design-md-guide.md`,
  and `design-tool-integrations.md`.
- `CHANGELOG.md` — project changelog (Keep a Changelog format).

## [2026-07-01]

### Changed
- **`software-architecture`** now consumes the upstream requirements artifacts,
  connecting the pipeline hand-off through `docs/srs.md`:
  - Designs from the SRS as the primary source — ingests requirements/NFRs,
    plays back the drivers, and interviews only for the architecture-specific
    gaps; falls back to the full interview when no SRS exists (still usable
    standalone).
  - Also ingests `docs/use-cases.md` (secondary) to inform the runtime view and
    resilience/security decisions; the RTM is not consumed as input.
  - Adds two-way requirement → decision traceability via a source-gated
    "Requirements addressed" field on ADRs (cite SRS/UC IDs only when those
    documents exist, prose otherwise — never fabricate an ID).
- Documented the pipeline-vs-standalone usage modes in the README.

## [2026-06-30]

### Removed
- **`requirements-engineering`** no longer emits Word (`.docx`) output. Markdown
  is the sole deliverable (SRS, use-case document, RTM), dropping the
  Pandoc/`python-docx` dependency; the `docx-generation.md` reference was
  removed.

## [2026-06-26]

### Added
- **`requirements-engineering`** amendment support: a finalized SRS can be
  changed (add/modify/remove) with stable, never-recycled requirement IDs.
  Phase 0 became three-way mode detection (fresh / resume / amendment) and a new
  Phase A defines the amendment protocol (tombstoned removals, version +
  revision-history logging, propagation to use cases and the RTM, cross-skill
  impact note).

## [2026-06-25]

### Added
- **`requirements-engineering`** skill — the first SDLC step. Through an
  exhaustive, area-by-area interview it specifies the complete requirements and
  produces a structured SRS (ISO/IEC/IEEE 29148 lineage), a use-case document,
  and a requirements traceability matrix. Checkpoints incrementally so long
  interview sessions can resume.

## [2026-06-22]

### Added
- **`implementation-planning`** skill — reads the architecture and
  UX-foundations documents and produces a sequenced build plan: epics and thin
  vertical feature slices, the walking skeleton, a dependency/risk-ordered
  sequence, the first-slice spec, and an engineering-foundations checklist.

## [2026-06-19]

### Added
- **`ux-foundations`** skill — the "architecture of the UI." Reads the
  architecture document and produces a shared design core plus a per-surface
  profile (IA, navigation, key flows, screen inventory) for each UI surface.

## [2026-06-17]

### Added
- Initial repository and the **`software-architecture`** skill — interviews the
  user about a new application and produces a right-sized architecture document
  with C4 diagrams (Mermaid) and Architecture Decision Records.
- `skills` CLI installability: skills live under `skills/<name>/`, installable
  via `npx skills add`, with manual Claude Code install documented.

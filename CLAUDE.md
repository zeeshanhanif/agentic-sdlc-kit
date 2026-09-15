# CLAUDE.md

Working notes for agents editing **this** repository. Not user documentation —
that's [`README.md`](./README.md), and it must be updated whenever the facts here
change.

## 1. What you are working on

This repo contains **twelve Agent Skills** (open `SKILL.md` standard) that form one
SDLC pipeline. There is **no application code, build system, test suite, or
linter**. The deliverable is instruction content loaded into an agent's context at
runtime.

Consequences for how you work here:

- **"Correctness" means the instructions are unambiguous, well-scoped, and trigger
  reliably** — not that something compiles. You cannot run these skills to test
  them; review by reading.
- **Every token costs.** `SKILL.md` is loaded on every invocation. Prefer deleting
  a sentence to adding one. Depth goes in `references/`, read on demand.
- **The twelve skills are coupled.** Changing what one emits ripples into how the
  next ingests it. §4 lists the couplings; check them before editing any skill.
- **Never write project-specific lessons back into a skill folder.** Skills emit
  project-owned artifacts (`scaffold-notes.md`, `deployment-notes.md`, …); that's
  where run-specific knowledge lives.

## 2. Layout and install-path invariants

```text
.claude-plugin/
├── plugin.json         # Claude Code plugin manifest (owns `version`)
└── marketplace.json    # the `zeeshanhanif` marketplace, one entry, source "./"
skills/<skill-name>/
├── SKILL.md            # required: frontmatter + the workflow
└── references/         # optional: guides SKILL.md tells the agent to read on demand
```

The repo ships through **three** paths at once — the `skills` CLI, the Claude Code
plugin, and manual copy. An edit that serves one must not break the others.

Load-bearing and easy to break:

- **`skills/<name>/SKILL.md` is the flat layout the [`skills` CLI](https://www.skills.sh)
  discovers.** Moving a skill out of `skills/` breaks
  `npx skills add <repo> --skill <name>`.
- **Frontmatter has exactly two keys: `name` and `description`.** `name` must equal
  the directory name and the `--skill` argument. No `license:` key, no per-file
  headers — `SKILL.md` content enters an agent's context on every invocation.
- **`description` is the only thing an agent sees when deciding to invoke the
  skill.** It carries the trigger phrases and the "use this when…" intent. Editing
  it changes *when the skill fires* — treat as load-bearing, never boilerplate.
- **The CLI resolves against the pushed GitHub repo** (`zeeshanhanif/agentic-sdlc-kit`),
  not the local tree. Layout/frontmatter changes reach users only after a push.
- **Manual install lands at `~/.claude/skills/<name>/SKILL.md`** (personal) or
  `.claude/skills/<name>/SKILL.md` (project). One level too deep silently fails.
- Renaming a skill directory or its frontmatter `name` changes the install command
  → update README's Install section and every example in lockstep.

Plugin-specific, all verified against the live docs:

- **`skills/` is auto-discovered at the plugin root — do NOT add a `skills` field**
  to either manifest. (For `skills` the field is additive, but `commands`/`agents`
  *replace* their default scan, so the habit is dangerous.) And never move
  `skills/` inside `.claude-plugin/`: only `plugin.json` and `marketplace.json`
  live there.
- **`plugin.json`'s `name` is the namespace prefix.** Renaming it silently changes
  every plugin user's address from `/agentic-sdlc-kit:<skill>` to something else.
- **Release rule — `version` is declared in `plugin.json` and nowhere else, and
  must be bumped on every release.** Claude Code pins the cache by version string:
  ship changes without a bump and existing plugin users keep the stale copy. If the
  marketplace entry also sets `version`, `plugin.json` wins *without warning*, so a
  forgotten manifest version masks the marketplace value. `claude plugin tag` exists
  to tag a release and check the two agree.
- **Skills must keep referring to each other by bare name** ("re-invoke
  feature-implementation", "route to detailed-design's amendment path") and **never
  by a slash form.** `/detailed-design` is wrong for plugin users (they have
  `/agentic-sdlc-kit:detailed-design`); a bare name is correct for everyone. This
  currently holds across all 61 files — keep it that way.
- The plugin payload is the **whole repo** (`source: "./"`), so anything committed
  at the root ships to every plugin user.

## 3. The twelve skills at a glance

Skills 1–6 are **one-pass** (linear, run once, in this order). 7–10 are **loop
skills** (once per feature, forever, in this order). 11 drives the loop; 12 audits
the seams.

One exception to the ordering: **#6's position is a recommendation, not a gate.**
`initial-deployment` runs once, any time after scaffolding — on the skeleton,
mid-loop, or after the plan is built — so nothing downstream may treat it as a
prerequisite (see §5).

| # | Skill | Reads | Writes | RTM column | Checkpoint |
| :- | :--- | :--- | :--- | :--- | :--- |
| 1 | `requirements-engineering` | you | `srs.md`, `use-cases.md`, `rtm.md` | rows + requirement cols | `.requirements-progress.md` |
| 2 | `software-architecture` | srs, use-cases | `architecture.md` | **Design ref** (ADRs) | — |
| 3 | `ux-foundations` | srs, architecture, use-cases | `ux-foundations.md`, `design.md`, `tokens.json` | — | — |
| 4 | `implementation-planning` | srs, use-cases, architecture, ux | `implementation-plan.md` | **Plan ref** | — |
| 5 | `project-scaffolding` | architecture, plan, ux trio, srs (light) | **the repo**, `scaffold-notes.md` | none | `.scaffold-progress.md` |
| 6 | `initial-deployment` | architecture, repo deploy artifacts, scaffold-notes | **live system**, `deployment-notes.md` | none | `.deployment-progress.md` |
| 7 | `detailed-design` | plan, srs, use-cases, architecture, **codebase** | `features/FEAT-*/technical-design.md`, `tasks.md` | **Design ref** (append) | — |
| 8 | `ui-design` | that feature's technical-design, design.md, tokens, ux inventory | `design-manifest.json`, `features/FEAT-*/ui-design.md`, `anchor-screens.md` | **Design ref** (append) | — |
| 9 | `feature-implementation` | `tasks.md` + both design halves + manifest | code, tests, commits | none | `tasks.md` checkboxes |
| 10 | `acceptance-verification` | authoritative docs + repo | `features/FEAT-*/acceptance-report.md` | **Test ref** (on acceptance) | — |
| 11 | `sdlc-orchestrator` | the plan + every feature folder under `docs/` | `defects.md` only | none | none (computes) |
| 12 | `pipeline-verify` | every pipeline document under `docs/` (read-only) | `pipeline-verify-report.md` (derived) | none | none |

All paths are under `docs/` in the *user's* project.

## 4. Cross-skill contracts — check these before editing anything

These are the couplings that make twelve skills behave as one system. Change one
end and you must change the other.

### 4.1 ID discipline (universal)

`FR-<AREA>-NNN` / `NFR-<CAT>-NNN` and `UC-NNN` (requirements-engineering),
`ADR-NNN` (architecture), `SCR-<CODE>-NNN` (ux-foundations), `FEAT-NNN` (planning),
`DEF-NNN` (orchestrator). Every one: **sequential, immutable, never recycled,
tombstoned (`Deprecated`/`Removed`, row kept) rather than deleted or renumbered.**
Downstream skills **skip tombstoned** items instead of building them. `FEAT-NNN` is
also the feature-folder key (`docs/features/FEAT-NNN-<slug>/`), which is why
re-sequencing the plan never invalidates folder names.

### 4.2 Source-gated traceability (universal)

Cite an ID **only when the document defining it is present**; otherwise state the
driver in plain prose. **Never fabricate an ID.** This is what keeps every skill
usable standalone. It governs ADR "Requirements addressed" fields, plan slices,
design refs, templates, and verification files alike.

### 4.3 RTM column ownership (`docs/rtm.md`)

Multi-writer ledger, exclusive columns, **append never overwrite**, touch only your
own column at your own delivery time, **skip silently when there's no RTM**:

- rows + requirement columns → `requirements-engineering` (initializes Design/Plan/
  Test as `_TBD_`)
- **Plan ref** → `implementation-planning` (keyed by FEAT ID; scheduling ≠ design,
  which is why it's its own column)
- **Design ref** → `software-architecture` (ADR refs, per a layer rule), then
  appended by `detailed-design` and `ui-design` per feature
- **Test ref** → `acceptance-verification`, **on acceptance only**, with a permanent
  `(partial)` marker when a feature implements an FR partially. **Full verification
  is computed** (every feature in the FR's Plan ref has an accepted report), never
  stored in the cell.
- **No column:** scaffolding, initial-deployment, feature-implementation,
  sdlc-orchestrator, pipeline-verify. Don't let anyone "helpfully" add one.

Contract lives in `requirements-engineering/references/rtm-guide.md`.

### 4.4 The testing chain — decided once, realized four times

`software-architecture`'s cross-cutting **Testing** entry (Round 7) is the single
decision point: strategy, the **critical flows covered by E2E** (UC IDs when use
cases exist), the **frameworks** (unit/integration runner per stack unit + E2E
framework), and the **coverage stance** — *none / report-only / enforced threshold
N%* with scope (changed-code vs whole-repo) and driver.

- `project-scaffolding` realizes exactly that: installs the named runners, stands up
  the E2E workspace, wires coverage per the stance (gating job / report-only /
  nothing). Silent architecture → ecosystem default runner, **no** coverage tooling,
  noted as a candidate amendment. Never "helpfully" add coverage tooling.
- `detailed-design` mints the flow-aware E2E-extension task from the same entry.
- `feature-implementation` **inherits** the frameworks (never introduces a runner)
  and treats the gate as part of developer-done.
- `acceptance-verification` diffs the coverage config over the feature's commit
  range and **re-runs the gate as CI runs it** (it audits the config; the number
  comes from the re-run, never an independent re-measurement).

Change the stance vocabulary in one file and all four move together.

### 4.5 The configuration chain

`project-scaffolding` mints a **config template per deployable unit** (placeholders,
secrets grouped, scope markers) and makes units read config from day one;
`feature-implementation` follows the config-variable task protocol (add to the unit
template, set a local gitignored value, flag deployment-affecting changes in the
delivery summary); `initial-deployment` Phase 4 asks the config mechanism
(plain/store/split) and **reconciles templates against the target environment before
deploying**, then wires secrets. The architecture's deployment view records the
**deployed environment set and promotion order only** — not variable names, not the
config mechanism, and local is excluded from it.

### 4.6 Computed, never stored

Loop position is **derived from artifacts** every time — never a status field, never
a pointer file:

| Artifact state | Meaning |
| :--- | :--- |
| `technical-design.md` exists | designed |
| `+ ui-design.md` | ui-designed |
| `tasks.md` all boxes checked | developer-done |
| accepted `acceptance-report.md` | verified |
| WIP failure note in `tasks.md` | **blocked** (a stop state, not a stage) |

The plan is never written with status (that would break implementation-planning's
ownership of it). The orchestrator has **no state file**. Progress lines skills
report are live-counted.

### 4.7 Deterministic next-selection, announced, never a menu

Every loop skill walks the plan's build sequence and takes the first feature in its
own "next" state; it **announces** the resolution rather than offering a menu (a
menu invites off-sequence violations of dependency order). Explicit user naming is
the only off-sequence path. The orchestrator inherits the same rule at global scope,
and a divergence between its computed position and a stage's own resolution is a
signal to **stop and reconcile**, never to override.

### 4.8 Escalate, don't fork — and single-writer discipline

- `detailed-design`: new entity / consistency-boundary change → **architecture
  amendment**, never designed locally.
- `ui-design`: off-system screen, colour, component → **ux-foundations amendment**,
  never a forked `design.md`.
- `feature-implementation`: two paths by blast radius, never a third — small and
  design-consistent → implement the intent and record; contract / schema /
  acceptance-criterion / screen-spec change → escalate to the owning skill.
- `acceptance-verification`: findings **route** (rework → implementation; design
  defect → detailed-design's amendment path). It never fixes production code; the
  one artifact class it may change is a weak **test**, corrected *toward the
  criterion, never toward the code*.
- `sdlc-orchestrator`: never edits `tasks.md`, never writes an RTM column, never
  resolves an escalation. Human-judgment points pause and surface.
- **Exactly one sanctioned foreign write in the whole kit:** `initial-deployment`
  closing the *pending initial deployment* marker in `docs/scaffold-notes.md`, in
  place, with date and evidence. Don't let this widen, and don't add a second.

### 4.9 Live-reality rule

Never recite remembered CLI syntax. `project-scaffolding` verifies generator names
and flags **against live docs before first use** (not only when uncertain);
`initial-deployment` verifies provider CLI specifics at run time (provider CLIs
drift faster); `ui-design` verifies design-tool connection steps rather than
guessing, and never silently downgrades to code-native.

### 4.10 Anti-fake-green (implementation + audit)

Tests are never weakened, skipped, deleted, or edited to pass; **the coverage
threshold, its scope, and its exclusion/ignore patterns are equally off-limits**. A
red test or gate has exactly two honest resolutions: fix the code, or escalate the
divergence. Fixing a genuinely buggy test *toward the design* is legitimate and
recorded. The forbidden moves are named explicitly in
`feature-implementation/references/failure-and-escalation.md` — keep them named.

### 4.11 Process hygiene / cold start

Stale dev servers produce false greens. `feature-implementation` restarts from a
known state before done-when checks and stops demo processes at task/session end
(including blocked stops); `acceptance-verification` cold-starts the local stack for
every audit and tears down what *this run* started; `project-scaffolding` stops
skeleton processes at delivery or discloses what's still running. **Stop only what
this run started — never kill by port scan.**

### 4.12 Agent-instructions layout in generated repos

`project-scaffolding` writes **`AGENTS.md`** at the repo root carrying all the
substance (pipeline docs, `design.md`, conventions, the `fix attempts: N` bound),
with **`CLAUDE.md` containing only `@AGENTS.md`** as a pointer. One source of truth;
two files with content inevitably diverge. Don't reintroduce a substantive
generated CLAUDE.md.

### 4.13 Checkpointing and non-destructive re-runs

`requirements-engineering`, `project-scaffolding`, and `initial-deployment` write
progress trackers and resume. Scaffolding **never regenerates over a partial
scaffold**; deployment **never blindly re-provisions** — partial state is verified
against *the provider*, and provisioning the tracker can't account for stops the
run.

## 5. Per-skill invariants

Only what must not break. Full behaviour lives in each `SKILL.md`.

### `requirements-engineering`

- Two governing principles: **exhaustive enumeration, not transcription** (propose
  the full standard sub-requirement set per area; auth → sign-up, sign-in,
  verification, reset, logout, expiry, lockout, rate limiting…) and **structured and
  traditional** (IEEE 29148/830-lineage SRS, numbered testable requirements — *not*
  an agile backlog). Feature slicing belongs to `implementation-planning`.
- **Markdown only** — three outputs. Word/docx generation was deliberately removed
  (Pandoc/python-docx dependency); don't reintroduce a docx phase.
- **Phase 0 is three-way mode detection** (fresh / resume / amendment) from disk
  state + plain-language intent, no flag. Two firm rules: **resume beats amend**,
  and **confirm before acting** when an SRS exists and intent is ambiguous.
  Finalization is recorded in the tracker (Phase 7) and is what distinguishes
  amendment from resume.
- **FR syntax is a once-per-SRS choice** — EARS or free-form "shall" — made at the
  end of Phase 1, **before the first FR is minted, never re-asked**, recorded in the
  SRS header (`Requirement syntax:`) and the tracker, binding on all amendments.
  Default EARS. Governs **FRs only**; NFRs always keep metric/target/condition form.
  Resume/amendment read it from disk.
- Both syntaxes run the **unwanted-behavior pass** (error counterparts get their own
  IDs) — enumeration discipline applied to error handling.
- **Phase A cardinal rule: IDs immutable, never recycled.** Every amendment bumps
  the version + revision history, propagates to use cases and the RTM, and emits a
  **cross-skill impact note** (it can't edit downstream docs; the RTM's downstream
  refs on tombstoned rows are what make dangling references visible).
- References: `elicitation-guide`, `requirement-catalog`, `ears-guide`,
  `use-case-guide`, `rtm-guide`, `srs-template`, `checkpointing`,
  `change-management`. More references than any other skill — keep them mutually
  consistent (esp. `ears-guide` ↔ `elicitation-guide`'s unwanted-behavior pass ↔
  `srs-template`'s example table).

### `software-architecture`

- Principle: **driven by quality attributes and constraints, not technology.**
  Workflow enforces *understand → decide → document*; every tech choice traces to a
  stated requirement. Don't add guidance that reaches for a stack first.
- **SRS primary, use cases secondary; RTM deliberately not consumed.** With an SRS,
  Phase 1 is *ingest → play back drivers → interview only the gaps*. Use cases feed
  the **runtime view** (sequence diagrams by UC ID) and **resilience/security**
  (exception flows → failure handling; actors → trust boundaries). Preserve the
  graceful fallback to the full seven-round interview.
- Boundary: SRS states *what*; architecture decides *how*. Read only **mandated**
  tech from SRS constraints.
- Owns the **testing decision point** (§4.4) — name frameworks and thresholds
  concretely; a vague entry becomes four skills guessing.
- Diagrams: C4 as inline Mermaid, **plain `flowchart`/`graph` syntax, not
  experimental Mermaid C4** (portability).
- References: `elicitation-guide`, `decision-guide`, `document-template`,
  `diagram-guide`, `adr-template`.

### `ux-foundations`

- Principle: **one shared core, defined once, plus a per-surface layer.** Don't
  collapse into a monolith or let surfaces become independent design systems. Stays
  at system/spec level — no pixel-perfect screens, no component code.
- **Two input classes with opposite rules:** pipeline documents are **read silently,
  never asked about**; the **design source is always asked, never assumed**
  (detection says what's *possible*, only the user says what's *wanted*). Don't
  merge these into "detect and go."
- **Four source modes** (research / extract from images / ingest a design file /
  connect a design tool). Every mode ends by **playing back a proposed direction for
  confirmation**. Images are read only from `docs/design-refs/` — never scan the
  wider project.
- **SRS accessibility/usability NFRs override every mode's output** (adjust, and
  record the change in provenance). Non-negotiable.
- **Three outputs, strict authority split:** `tokens.json` (canonical W3C DTCG
  values) → `design.md` (render-time system; its CSS is *derived* from tokens) →
  `ux-foundations.md` (plan-time; *references* design.md, never restates values).
- **`design_provenance`** in `design.md` is a JSON block written in **every** mode
  (mode + fidelity always; `source` sub-object only in tool mode) — `ui-design`
  reads it to drive its anchor recommendation. Keep it machine-readable.
- Hand-offs: the **SCR-ID screen inventory** feeds planning and ui-design;
  `design.md` + `tokens.json` are wired into the repo by scaffolding.
- References: `elicitation-guide`, `source-modes`, `design-tool-integrations`,
  `design-system-guide`, `surface-profile-guide`, `design-md-guide`,
  `document-template`, `diagram-guide`.

### `implementation-planning`

- Principles: **slice vertically, never horizontally**, and **make the architecture
  executable before complete** (walking skeleton first). **Depth-on-demand** — don't
  elaborate the whole backlog upfront. It **stops at the plan**.
- Consumes all four upstream docs, each degrading independently. Every slice traces
  FR + UC + SCR IDs; **skips tombstoned** items.
- Two delivery behaviours to preserve: the **Must-coverage check** (every Must FR in
  a slice or consciously deferred) and the **RTM Plan-ref write-back**.
- The epic/feature breakdown is a **default** section; the issue-tracker export is
  **off by default**.
- References: `slicing-guide`, `sequencing-guide`, `verification`,
  `document-template`, `diagram-guide`.

### `project-scaffolding`

- Output is a **running repo**, so verification is empirical — Phase 7 actually
  builds and runs; never assert a green skeleton.
- Principles: **stack is an input, never a decision** (gaps → elicited *and* flagged
  as candidate architecture amendments); **official generators first** (verified
  against live docs, run for real, then customized; hand-build only where no
  generator exists); **it owns the stack-independent layer** (skeleton wiring,
  module boundaries as folder + lint/import rules, design system in the UI shell —
  delete `tokens.json` and the shell should visibly break — pipeline conventions,
  empirical verification).
- Stops at **deploy-ready, not deployed**. What it writes (deployment config,
  parameterization, secret placeholders, CI) is `initial-deployment`'s **input**,
  not a placeholder to hand-wave.
- Compose-first local stack: pinned, version-aligned store images; non-store
  dependencies asked once.
- Installation discipline: **project-local deps first**; global installs only after
  an explicit ask. READMEs: replace generator boilerplate with a system-scoped root
  README (+ unit READMEs where warranted, linking up, no duplication).
- `docs/scaffold-notes.md` is **project-owned** and carries the *pending initial
  deployment* marker (§4.8).
- References: `checkpointing`, `scaffolding-guide`, `skeleton-guide`,
  `verification`. Keep `skeleton-guide`'s testing section in sync with the
  architecture's Testing entry shape.

### `initial-deployment`

- Scaffolding's twin one step later; the only skill that **spends money and touches
  the user's cloud account** — that's what its rules protect.
- Principles: **target is an input, never a decision** (conform-or-escalate;
  cloud-agnostic process, cloud-specific run, live provider docs); **money and
  credentials get gates** (one explicit confirmation before anything billable; never
  ask for, store, or write a secret **value** — configs reference stores, values
  enter out-of-band, a non-secret canary proves the wiring); **deployed means
  demonstrated** (live skeleton exercise, an observed CD run, a performed restore, a
  fired alert).
- **Operations are folded in, not deferred** (Phase 7 floor: uptime, error alerting,
  reachable logs, backup **plus a performed restore**, TLS/domain). Don't let it drift
  optional or expand into full day-2 ops.
- **Writes no RTM column and does not update acceptance reports** — pending-environment
  NFR measurements go in `deployment-notes.md` and it *recommends re-running*
  `acceptance-verification`. Keep that jurisdiction boundary.
- `docs/deployment-notes.md` is project-owned; **no secret value ever appears in
  it**. Artifact names follow the skill name (`deployment-notes.md`,
  `.deployment-progress.md`) — rename one and rename it everywhere.
- **When to run is a recommendation with a stated trade-off**, not a gate. Keep both
  paths honest.
- References: `deployment-guide`, `operations-minimum`, `verification`.

### `detailed-design`

- Loop skill, run once per feature in a fresh session against a **moving codebase**.
- Principles: **the *what* is fixed upstream** (inheritance by ID; new entities
  escalate); **the live codebase is a mandatory read and reality wins over
  documents** where they diverge (noted); **depth here, and only here.**
- File is **`technical-design.md`**, not `design.md` — avoids colliding with the
  design *system* at `docs/design.md`.
- `tasks-guide` owns two contracts `feature-implementation` executes: the
  **computed, flow-aware E2E obligation** (feature UC IDs ∩ architecture's critical
  flows → an explicit E2E-extension task before final verification; skip
  legitimately when the architecture is silent) and **done-when kind classification**
  — *behavioral* tasks get test-artifact done-whens, *structural/realization* tasks
  get demonstration done-whens (**no ceremony tests asserting mere existence**).
  Verification is universal; test artifacts attach to behaviour.
- References: `design-guide`, `tasks-guide`, `verification`.

### `ui-design`

- Sequential sibling of detailed-design (per-feature mode binds screens to that
  feature's contracts). Only **anchor mode** precedes features.
- Principles: **strategy resolved per screen, not per project**; **conform or
  escalate — never fork the design system**; **the manifest is the only registry and
  this skill is its single writer** — which is what lets it be an **adapter** that
  absorbs all design-tool variance so **no downstream skill ever learns what a Figma
  node is**.
- Three modes: anchor (2–3 compositionally demanding screens; recommendation
  strength driven by `design_provenance`) → writes `docs/anchor-screens.md`;
  per-feature → `features/FEAT-*/ui-design.md`; re-verification after a `design.md`
  amendment.
- Design tools are treated **capability-first** (enumerate existing / generate from
  spec), interchangeable behind those two capabilities.
- **Heading formats in `document-templates.md` are load-bearing** — manifest source
  locators anchor on them. Don't restyle headings casually.
- References: `strategy-guide`, `design-tool-integrations`, `manifest-guide`,
  `document-templates`, `verification`.

### `feature-implementation`

- **`tasks.md` is the program; this skill is the interpreter.** Ends at
  *developer-done*; it never grades its own homework alone.
- **Seven disciplines**, each killing a named agentic failure mode — keep all seven:
  improvisation-is-escalation; fresh-context safety (disk is the memory, one task
  per iteration); done-when-demonstrated + anti-fake-green; **bounded fix-loops**
  (default 3, override via a `fix attempts: N` line in the agent-instructions
  file; each attempt needs a
  changed hypothesis; exhaustion → unchecked box + failure note + explicit WIP
  commit; **never skip ahead**); scope discipline; convention conformance
  (inherited frameworks, tokens never raw values, manifest-driven screens);
  git-as-checkpoint (`FEAT-NNN T<k>: …`, one commit per task).
- **Three-tier verification timing:** per task only that task's done-when (never the
  E2E suite mid-feature); the E2E extension at its own pre-minted task; full suites
  + the coverage gate once, at the final verification task (which itself runs under
  the per-task cycle and attempt bound).
- **`tasks.md` is updated in place, boxes only.** A wrong-sized task means the design
  changed → escalate, don't edit the program mid-run.
- **Repeated blocking is a meta-signal** — same task blocking across sessions, or
  several exhausted budgets on one feature → recommend returning to
  `detailed-design`, don't burn more attempts.
- References: `execution-guide`, `failure-and-escalation`, `verification`.

### `acceptance-verification`

- Principles: **fresh-eyes enforced through derivation** (re-derive from
  technical-design §6 + verbatim SRS/UC + binding NFRs + the manifest; **never** from
  checkboxes, delivery summaries, or claimed greens — *claims are exhibits,
  observations are evidence*); **auditor and mechanic stay separate** (never fixes
  production code; may correct weak **tests** toward the criterion, in separate
  commits `FEAT-NNN acceptance: correct test for AC-k`); **a feature is verified
  whole or not yet** (three verdicts, most severe wins, no partial acceptance).
- Suites are re-run with **the harness's own commands**, never improvised
  invocations. Infrastructure-needing NFRs are recorded as *pending environment* —
  never silently skipped, never fake-verified locally.
- Re-verification after rework or amendment is a **normal full run**; the report
  gains a new dated verdict section, prior verdicts preserved.
- References: `audit-guide`, `verdict-and-report`. Keep the Test-ref rules in sync
  with `requirements-engineering/references/rtm-guide.md`.

### `sdlc-orchestrator`

- **Deliberately thin.** If guidance here starts to look like design or build logic,
  it belongs in a stage skill.
- Principles: **compute, never store** (no state file, no pointers); **skills stay
  sovereign**; **every stop is a resumable state**.
- Three run scopes (one stage / one feature cycle = default / run-until-blocked).
  Outcome routing: rework → implementation then re-verify, **bounded at 2 rework
  cycles** before surfacing; design-defect / filed escalation / blocked task →
  pause and surface toward the owner; plan-complete → close and **point at**
  `initial-deployment` (a pointer, not an invocation — it drives the loop, not the
  one-pass skills).
- Every pause message carries four elements: what stopped, where (feature + stage +
  artifact), who owns the next move, the resume instruction.
- **Two lifecycle routes, both re-entering through the top of their chain** so the
  inheritance chain holds: change requests walk requirements → architecture/UX
  impact → planning (each artifact verified to have landed before the next — **no
  FEAT without its FRs**); bugs → RTM Plan ref locates the owning feature →
  `docs/defects.md` `DEF-NNN` → **failing test first** → scoped fix under
  feature-implementation's disciplines → re-verify (design-rooted bugs reroute to
  the design-defect path).
- Owns exactly one artifact (`docs/defects.md`) and writes nothing else. The
  maintenance route deliberately relies on the existing Test-ref pointer + the
  report's new dated section — **don't add an RTM write here.**
- References: `routing-guide`, `lifecycle-routes`.

### `pipeline-verify`

- **Tier 2** of the verification design (tier 1 is each stage skill's own delivery
  check). Both tiers run; neither substitutes for the other.
- Principles: **mechanical only** (decidable by reading and computing; taste belongs
  to the stage skills); **read-only, derived-output-only** (writes no pipeline
  artifact; `docs/pipeline-verify-report.md` is a derived view — overwritten,
  deletable, regenerable); **fresh eyes, actual commands** (grep/parse/diff — never
  eyeball a large matrix; the checks are specified so a script could run them).
- Absent documents **scope checks out and are reported as skipped**, never failed —
  source-gating applies to verification too. Absence of evidence is never reported
  as cleanliness.
- Findings are classified **error / warning / info** and grouped by **owning skill**;
  this skill fixes nothing.
- Its dashboard must agree with what the orchestrator would compute — same
  artifacts, same rules, independently derived. Running it twice unchanged must
  yield the identical report.
- References: `checks-guide` (the seam catalog + ID regex namespaces),
  `report-guide` (severities, dashboard, report).

## 6. Editing conventions

- **Progressive disclosure is the core pattern.** `SKILL.md` stays a lean workflow
  (phases, rules) and tells the agent to read a *specific* `references/*.md` at the
  moment it's needed. Adding depth means extending a reference and pointing at it
  from the relevant phase — not growing `SKILL.md`.
- **Keep vocabulary identical across skills.** Requirement IDs, artifact filenames,
  surface/container naming, screen-inventory shape, column ownership, coverage-stance
  words. A synonym introduced in one skill is a bug in the other eleven.
- **Mermaid: prefer plain `flowchart`/`graph` syntax** over experimental C4 syntax,
  everywhere. Broken diagrams are the common failure mode.
- **Voice:** imperative, second person, specific. Name the failure mode a rule
  prevents — that's what makes a rule survive compression in an agent's context.
- **README and CHANGELOG are part of every change.** README carries the user-facing
  detail (skill table, sequence, install commands, per-skill sections, "What's
  inside" trees); `CHANGELOG.md` gets a dated entry. Adding or removing a reference
  file or a skill means editing both.

## 7. Validating a change

There is nothing to build or run. Check:

```bash
# 1. frontmatter name matches the directory name
for f in skills/*/SKILL.md; do
  d=$(basename "$(dirname "$f")"); n=$(grep -m1 '^name:' "$f" | cut -d' ' -f2)
  [ "$d" = "$n" ] || echo "MISMATCH: $d vs $n"
done

# 2. every referenced path exists
grep -rhoE 'references/[a-z-]+\.md' skills/*/SKILL.md | sort -u

# 3. no stale skill/artifact names after a rename
grep -rn '<old-name>' skills/ README.md CLAUDE.md CHANGELOG.md
```

Then render any new Mermaid (GitHub preview or a Mermaid live editor), and re-read
§4 for any contract your edit touched — the ripple is the part that breaks silently.

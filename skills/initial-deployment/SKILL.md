---
name: initial-deployment
description: >-
  Takes the project from deploy-ready to running in the cloud — the last mile
  scaffolding stopped short of. Reads the deployment target and topology from
  the architecture's ADRs and deployment view, then executes: provisions the
  environments and infrastructure from the deployment configs in the repo,
  stands up real secrets management, extends CI to CD, deploys the current
  build, and verifies live — including the walking skeleton's pending
  deployed-half done-when and any pending-environment NFR measurements from
  acceptance reports. Folds in minimum operations: uptime check, error
  alerting, backup-and-restore verified. Cloud-agnostic: the process is
  encoded, the target is an input, CLI specifics verified against live docs.
  Requires the user signed in to the provider CLI (blocking ask) and
  confirms the plan before creating billable resources. Trigger on "deploy the
  project", "first
  deploy", "initial deployment", "provision the infrastructure", "set up the
  environments", "take it live", or "go to production".
---

# Initial Deployment

The bridge from **deploy-ready to running**. Scaffolding wrote the deployment
configs, environment parameterization, and CI — and stopped, by contract, at
"the initial deployment is the user's step." This skill is that step, with the
same character as scaffolding: real execution against live reality, empirical
verification, honest notes, and checkpointed progress that never blindly
re-provisions.

Three principles govern it:

1. **The target is an input, never a decision.** The architecture's ADRs and
   deployment view chose the cloud/platform and topology; this skill reads
   and executes them. Gaps (a region never stated, a service tier unnamed)
   are elicited — and flagged as candidate architecture amendments. The
   process is cloud-agnostic; the run is cloud-specific; CLI names, flags,
   and console steps are **verified against live provider docs** at run time —
   never recited from memory (they drift faster than generators do).
2. **Money and credentials get gates.** Provisioning creates billable
   resources: the deployment plan (what gets created, environments, rough cost
   class) is played back for **one explicit confirmation** before anything is
   created. Sign-in stays with the user: the skill preflights that the user
   is signed in to the provider CLI and **blocks with instructions when they
   aren't** — it never reads, asks for, stores, or writes a credential or
   secret value anywhere (configs reference secret stores; values enter those stores
   through the provider's own mechanism, user-driven).
3. **Deployed means demonstrated.** The run ends with the system observed
   live: the skeleton's end-to-end path exercised against the deployed
   environment (closing the done-when's pending deployed half), CD proven by
   an actual pipeline-driven deploy, restore actually performed once —
   claims are exhibits, observations are evidence.

## When to run

Recommended **early — right after scaffolding**, deploying the walking
skeleton itself: that's the walking-skeleton philosophy (prove the system
deploys before features pile on), and it makes every later feature
continuously deployable. Running later, after features exist, is fully
supported — the same process deploys whatever the repo currently holds, and
Phase 8 is *more* valuable then (accumulated pending-environment NFRs finally
become measurable). Say the trade-off plainly when features exist: this first
push ships N features' worth of system at once, so a failure has many more
candidate causes than an early skeleton deploy would — and the E2E exercise
in Phase 6 covers the whole current suite accordingly.

## Inputs

Defaults; user paths win; source-gated citation throughout.

- **Architecture** — `docs/architecture.md`: the deployment view and the ADRs
  naming the target platform, topology, environments, and data stores (cite
  them). Cross-cutting concepts for the security/observability posture the
  deployment must honor.
- **The repo** — the deployment artifacts scaffolding wrote (Dockerfiles,
  service configs, IaC skeleton, environment parameterization, CI config) and
  `docs/scaffold-notes.md` (what's pending, exact commands, versions).
- **The plan** — `docs/implementation-plan.md`: the walking skeleton's
  done-when (its deployed half is this skill's to close).
- **Acceptance reports** — `docs/features/*/acceptance-report.md` (when
  features exist): the **pending-environment** NFR items now measurable.
- **SRS** — `docs/srs.md`, light touch: NFRs constraining the deployment
  itself (residency, availability topology, compliance), cited by ID.
- **RTM: no writes.** Deployment realizes infrastructure, not requirements.
  Pending-environment measurements are recorded in deployment-notes;
  formally updating acceptance reports and the RTM stays
  acceptance-verification's jurisdiction (re-run it now that the environment
  exists).

## Outputs

1. **The running system** — provisioned environments, deployed build, CD
   wired so the pipeline ships future merges per the architecture's cadence.
2. **`docs/deployment-notes.md`** — the project-owned record: what was
   provisioned (with provider identifiers), environment URLs, the exact
   deploy/rollback commands, secret-store locations (never values), pending-
   environment measurement results, costs observed/expected, deviations from
   the deployment view (and their reasons).
3. **Closed pending items** — the skeleton done-when's deployed half
   demonstrated; pending-environment NFRs measured, with a recommendation to
   re-run acceptance-verification for formal verdicts.
4. **One narrow write into `docs/scaffold-notes.md`** — scaffolding's
   artifact, and the *only* foreign document this skill touches: the pending
   marker it left ("deployed half: pending initial deployment") is closed in
   place, with date and evidence. Nothing else in that file is edited — the
   marker was written to be closed by exactly this run; every other record of
   this deployment lives in deployment-notes.

## Workflow

### Phase 0 — Resume check (always first)

Read `references/deployment-guide.md` (Checkpointing). Look for
`docs/.deployment-progress.md` and live signs of partial provisioning. Partial →
**never blindly re-provision**: summarize what exists (verified against the
provider, not just the tracker), confirm, resume idempotently at the first
pending step. Provisioning found that the tracker can't account for → stop
and ask; this skill never assumes ownership of infrastructure it can't
explain.

### Phase 1 — Ingest and confirm the deployment plan (the money gate)

Extract the deployment contract: target platform (ADR-cited), topology per
the deployment view, environments to create, stores to provision, domain/TLS
expectations, CD trigger (merge? tag?). Elicit only genuine gaps (region,
tier/size — flag architecture-level gaps as candidate amendments). Play back
the **deployment plan**: what gets created where, the rough cost class, what the
first deployed artifact will be — and get explicit confirmation. **Nothing
billable exists before this nod.**

### Phase 2 — Preflight (sign-in and tools)

Provider CLI present and **the user signed in to it** — if not, a blocking
ask with pointers to the provider's current sign-in steps (verified against
live docs), then re-check. Required tools at needed versions. The skill never
touches credential values; the user signs in through the provider's own CLI.

### Phase 3 — Provision

Execute the repo's deployment artifacts per environment, in dependency order
(network/foundation → stores → services), checkpointing each unit.
Live-verify CLI specifics before first use. Deviations between the deployment
view and provider reality are handled conform-or-escalate: trivial
realization details → do and record; topology-changing → architecture
amendment path.

### Phase 4 — Configuration and secrets, made real

**First ask how deployed configuration is supplied on this platform**: plain
platform config for everything, the secret store for everything, or the split
(non-secrets in config vars, secrets in the store — the templates' secret
markers are the divide). Recommend the split, honestly: secret stores usually
charge per secret or per access and add rotation/audit machinery `LOG_LEVEL`
doesn't need, while plain config vars for genuinely sensitive values give up
the audit trail. The user's answer wins; record it in deployment-notes so
re-runs and future operators know how the project is wired.

**Then reconcile before deploying**: union the deployable units' config
templates and compare against what the target environment actually has.
Anything missing **blocks the deploy** — with the exact list and the
provider-native steps to set each one. This turns the worst deployment
failure mode (green pipeline, dead service, confusing boot logs) into a
pre-flight message.

Then make them real per the chosen mechanism: create the entries/references,
wire the services to read them, and hand the user the exact provider-native
steps to enter each value **out-of-band**. Verify wiring with a non-secret
canary first. No value ever appears in a file, a note, chat, or a shell
history this skill writes.

### Phase 5 — CD: the pipeline ships

Extend the green CI to actual delivery per the architecture's cadence:
deploy-on-merge to the lower environment, promotion per the deployment view
(tag/manual gate to prod as specified). The proof is empirical: a real
pipeline run observed deploying.

### Phase 6 — Deploy and close the skeleton's done-when

Ship the current build through the pipeline. Then exercise **whatever
end-to-end suite the repo currently holds** against the deployed
environment: always the skeleton's path — the same test, live — and, when
features have extended the suite, the feature E2E paths too (point the suite
at the deployed URL where the harness supports it; otherwise the documented
smoke equivalent, said plainly). State the skeleton result against the plan's
done-when wording: its deployed half, finally demonstrated (record it in
deployment-notes and scaffold-notes' pending item). A red in a *feature's* E2E
path is a deployment finding, not a skeleton failure — report it, and route
a genuine feature failure in the live environment to acceptance-verification
(re-run it there); this skill measures, the auditor rules.

### Phase 7 — Minimum operations (folded in, not deferred)

Read `references/operations-minimum.md`. A deploy without eyes is negligent:
uptime check on each public surface, error alerting wired to a channel the
user actually reads, logs reachable, backups configured **and restore
performed once** (a backup never restored is a hope), TLS/domain per the
architecture. Fuller day-2 operations remain a later concern; this floor is
not optional.

### Phase 8 — Pending-environment NFRs

From the acceptance reports' pending-environment lists (when present): run
the measurements now possible against the real environment (response-time
bounds, availability probes as feasible), record results in deployment-notes with
environment context, and recommend re-running acceptance-verification for
the formal verdict/RTM updates — jurisdiction stays with the auditor.

### Phase 9 — Verify and deliver

Read `references/verification.md` — everything demonstrated live. Then
deliver: URLs per environment, the exact deploy and **rollback** commands,
what it costs (observed/expected), what's pending (items genuinely deferred),
and the handoff: the loop continues with every future feature now
continuously deployable; recommend acceptance-verification re-runs for the
measured NFRs.

## Scope boundaries

Does **not**: choose or change the platform/topology (architecture's job —
gaps go back as amendments); handle credential or secret values; build
features or fix code; perform full day-2 operations (the minimum floor only);
write the RTM; write any other skill's artifacts beyond closing
scaffold-notes' own pending marker (Outputs 4).

## What good looks like

- Everything created traces to the deployment view/ADRs; every deviation is
  recorded with its reason — or escalated.
- The confirmation gate preceded every billable creation; the user was never
  surprised by a resource or a bill.
- The skeleton's done-when reads **fully closed** — local half (scaffolding)
  and deployed half (here), both demonstrated.
- Restore was performed, not assumed. Alerting reached the human once, as a
  test.
- deployment-notes lets a cold session (or a human) operate the deployment:
  URLs, commands, rollback, secret locations — no tribal knowledge.
- A lapsed sign-in or missing tool produced a clear blocking ask — never
  a workaround, never a stored secret.

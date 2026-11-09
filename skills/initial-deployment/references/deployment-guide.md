# Deployment Guide

Mechanics for Phases 1–6. The philosophy mirrors scaffolding's: **the skill
encodes process, not provider structures** — the architecture supplies the
target, live provider docs supply the current specifics, and the run records
what actually happened.

## Extracting the deployment contract (Phase 1)

From the architecture's deployment view: the platform (ADR-cited — cite it in
deployment-notes), the topology (which services run where, what fronts them),
the environments and their promotion order, the stores and their tiers where
stated. From the repo: the deployment artifacts scaffolding wrote — these are
the *source of truth for what to execute*; the provider console is never
hand-driven for anything the artifacts cover (drift between artifacts and
reality is the enemy; if something must be created outside them, add it to
the artifacts first or record precisely why not).

**The deployment-plan playback** is one tight block: environments to create,
resources per environment (service, store, network pieces), region(s), rough
cost class ("this footprint typically lands in the tens of dollars/month
class" — honest order-of-magnitude, not fake precision), the CD trigger, and
what the first deployed artifact is. One confirmation, then execute. Any
elicited gap that the *architecture* should have answered (region policy, a
tier with cost consequences) is flagged as a candidate amendment.

## Live-docs discipline

Provider CLIs and consoles change faster than anything else this pipeline
touches. Before first use of any provider command in the run: verify the
current name/flags against the provider's live documentation. Record the
verified command forms in deployment-notes as they're used — they become the
project's operational truth. Never recite remembered commands; never let a
note (even deployment-notes from a previous run) override what live docs and the
CLI's own help say today.

## Provisioning order and idempotency (Phase 3)

Dependency order: foundation (network, project/account scoping) → data
stores → services/compute → edges (load balancers, domains, TLS). Per unit:
execute the artifact, verify the resource actually exists and reports
healthy via the provider's own status, checkpoint, then proceed. Prefer the
artifacts' idempotent application (IaC apply, declarative configs) over
imperative creation wherever the stack allows — re-running must converge,
not duplicate.

**Cost-consequential deviations** (the artifact's tier is unavailable in the
region; the provider renamed a size class): if equivalent-and-trivial,
proceed and record; if it changes the cost class or topology, pause and ask —
the Phase 1 confirmation covered the plan as stated, not a materially
different one.

## Configuration and secrets (Phase 4)

**The mechanism is the user's choice, asked once per project**: plain platform
config for everything / the secret store for everything / the split, with the
templates' `# --- secrets ---` markers as the divide. Recommend the split with
its honest trade-off (per-secret cost and rotation machinery vs. lost audit
trail), take the user's answer, record it in deployment-notes.

**Reconciliation precedes every environment's first deploy**: union the units'
config templates → compare against the environment's actual configuration →
missing variables **block**, listed by name with the provider-native steps to
set them. Scope markers are honored (a `# prod only` variable isn't demanded
of staging). Never deploy hoping a value is there; a boot-time crash costs
far more than a pre-flight check.

### The never-touch rules (under any mechanism)

- The skill creates **references** (the secret store entries, the service
  wiring that reads them) — never values.
- Values enter via the provider's own mechanism, user-driven, out-of-band:
  the skill hands over the exact current provider-native steps ("create the
  value at <store path> using <provider's documented flow>") and waits.
- Verify the wiring with a **non-secret canary** first (a dummy key the user
  sets to a known harmless value), then have the user set the real values and
  verify the services start — the skill observes *that* secrets resolve,
  never *what* they are.
- Nothing secret ever lands in: files this skill writes, deployment-notes, chat,
  shell commands it composes (values would enter history), or CI variables it
  prints. CI secret configuration follows the same pattern — references
  created, values user-entered in the CI system's own UI/CLI.

## CD (Phase 5)

Extend the existing CI config: deploy job(s) gated per the architecture's
cadence — merge-triggered to the lower environment, promotion to production
per the deployment view (tag, or an explicit manual approval step; when the
view is silent, default to manual promotion and record the default). The
pipeline deploys under the provider's recommended CI identity mechanism
(workload identity/OIDC where offered, over long-lived static keys) —
configured by reference, with the trust relationship set up by the user.
**Proof is a real run**: a pipeline execution observed building and deploying;
a green config that never ran proves nothing.

## Deploying and closing the done-when (Phase 6)

Ship the current build through the pipeline (not by hand — the pipeline is
the thing being proven). Then run the end-to-end exercise against the
deployed environment: **the suite as it exists today** — the skeleton path
always, plus the feature paths features have added — pointed at the deployed
URL where the harness supports it, or the documented smoke equivalent. State
the *skeleton* result against the plan's done-when wording (that's the
promise being closed), and report feature-path results separately as
deployment findings. Update the two standing records: deployment-notes (the
demonstration, all paths) and the pending item
scaffold-notes carried ("deployed half: pending initial deployment" → closed, with
date and evidence).

## Checkpointing (Phase 0's protocol)

Maintain `docs/.deployment-progress.md` — per environment, per unit, statuses
pending/in-progress/done with provider identifiers as they're created. On
any entry: reconcile the tracker against **provider reality** (list the
actual resources) before trusting it; a crash mid-provision means the
in-progress unit is verified-or-cleaned before proceeding. Never blindly
re-run creation over unknown state; never delete resources to "reset"
without explicit user confirmation naming what will be destroyed.
Infrastructure the tracker can't account for → stop and ask (it may be
pre-existing, shared, or someone else's).

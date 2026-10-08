# Agentic SDLC Kit — critical review (2026-09-18)

Reviewed at commit `b78c784` (v2.0.0 + unreleased Mode-4 work). Method: read all 12 `SKILL.md` files and the load-bearing references in full, ran the official `agentskills validate` on every skill, parsed all 12 Mermaid blocks with the mermaid library, ran `npx skills add … --list` against the pushed repo, and audited the public reference implementation (`todo-list-with-sdlc-skills`, 284 commits, 20 features) for contract drift.

**Grade: 7.5 / 10.** Design and coherence are 9-level; the reference implementation proves the loop works end to end; execution has real gaps (missing amendment paths, zero evals/CI, a spec violation, stale contracts) that keep it out of the 8–9 band.

## What is strong

- The conceptual spine is excellent and unusually consistent: computed-never-stored position, source-gated citation, tombstoned immutable IDs, exclusive RTM column ownership, escalate-don't-fork, anti-fake-green extended to coverage config, a deliberately thin orchestrator. These are the right abstractions for agentic SDLC and most "prompt kits" have none of them.
- Every rule names the failure mode it prevents — this makes rules survive context compression.
- Mechanically clean: all frontmatter names match dirs, every referenced `references/*.md` exists, all 12 Mermaid diagrams parse, plugin manifests follow current guidance, the `skills` CLI resolves the repo, 18 release tags.
- The reference implementation is the strongest evidence: RTM with 81 FR rows fully traced Plan→Design→Test, 147 `FEAT-NNN Tk:` commits, 16 ledgered defects with red-before/green-after proofs, staging deployed on Cloud Run with CD gated on CI. Almost nobody in this space can show that.

## Critical findings (ordered by severity)

### 1. Four escalation targets have no receiving workflow
The kit routes escalations to "architecture amendment", "ux-foundations amendment", "implementation-planning, amendment mode", and "detailed-design's amendment path" (24 references across the kit; `lifecycle-routes.md` steps 2–3, `routing-guide.md` design-defect route, `verdict-and-report.md`, `failure-and-escalation.md`). Only `requirements-engineering` defines an amendment mode (Phase A + `change-management.md`). `software-architecture`, `ux-foundations`, `implementation-planning` and `detailed-design` have **zero** amendment guidance in their `SKILL.md` (grep count 0/0/1/0 — the 1 is about FEAT numbering). `change-management.md` even says "re-run the affected skills", which would regenerate whole documents. The post-v1 lifecycle the README sells ("changes and bugs go through the orchestrator") is implemented at one of its four receiving ends. This is the single biggest structural gap.

### 2. `requirements-engineering` fails the Agent Skills spec
`description` is 1037 chars; the spec caps it at 1024. `agentskills validate skills/requirements-engineering` → "Description exceeds 1024 character limit". Three others sit at 1013–1024. Strict loaders may reject or truncate — and truncation cuts the *trigger phrases*, which are at the end.

### 3. No verification of the kit itself
55k words of instructions, no evals, no CI, no `.github/`. `CLAUDE.md` §1 states "You cannot run these skills to test them; review by reading" — this is no longer true (`claude plugin eval`, skill-creator evals, or a plain shell script). Finding #2 would have been caught by a 10-line CI job. More importantly, the reference project shows contract violations that evals would surface:
- `FEAT-019` acceptance report verdict: "Accepted, with AC-1b explicitly open" — `verdict-and-report.md` forbids exactly this ("partial acceptance is not a verdict").
- `docs/deployment-notes.md` does not exist in the reference project despite a completed Cloud Run deployment (`.deployment-progress.md` exists; notes landed in `deploy/README.md`).
- 6 of 16 defects are "(no FR — test infrastructure)" — the maintenance route assumes every bug maps to an FR via the RTM.
- Uncontracted artifact `staging-checklist.md` in a feature folder; the defect ledger's "Symptom (one line)" column became multi-paragraph, and per-DEF sections were invented below the table.

### 4. The RTM write-back contradicts the kit's own core principle
Plan ref, Design ref and Test ref are *all derivable*: Plan ref from the plan's touchpoints, Design ref from which feature folders exist, Test ref from accepted reports. `pipeline-verify` already computes exactly this dashboard "independently derived". Yet four skills write into a wide markdown table — the most brittle multi-writer format an LLM can edit (81 rows × 9 columns in the reference RTM, cells holding 2–3 paths each). "Computed, never stored" is applied to loop position but not to traceability. Either make Plan/Design/Test columns computed (RTM = rows + use-case links, everything else rendered by pipeline-verify), or move the ledger to a structured sidecar (`rtm.json`) with the markdown rendered from it.

### 5. Stale and inconsistent vocabulary in the contracts
- `rtm-guide.md:52,56,58`: `slice-3-design.md §2`, `Slice: Sign-in`, "written by the future **testing** phase" — the contract file every writer is told to obey still uses pre-FEAT vocabulary.
- `adr-template.md:63` cites `constraint C-03`; `checks-guide.md:9` defines the namespace as `CON-`.
- `srs-template.md` is never referenced from `requirements-engineering/SKILL.md` (only indirectly via `checkpointing.md`) — the one skill with the most references breaks its own progressive-disclosure rule.
- `software-architecture/SKILL.md:168–178` offers a `.docx` export via "the `docx` skill" — RE deliberately removed docx; and the kit claims Cursor/Copilot portability where no such skill exists.
- `design-md-guide.md:119` carries a hard date; the Claude Design MCP URL and `/design-login` are hard-coded in both `design-tool-integrations.md` files despite the CLAUDE.md rule that these files avoid facts that "read stale within a week".

### 6. Portability is overstated
"Works in Cursor, GitHub Copilot" — but the orchestrator model (a skill invoking other skills mid-run), `@AGENTS.md` import syntax, `/design-login`, and the `docx` skill are Claude Code-isms. The kit is Claude Code-first with a portable file format. Say so; it's not a weakness, but the claim invites bug reports.

### 7. The plugin distribution leaves the strongest Claude Code features unused
No `agents/`, `hooks/`, or `commands/`. Two would materially strengthen the design:
- `acceptance-verification` as a **subagent with an isolated context**: "fresh eyes" is currently enforced by an instruction ("re-derive, never read the summary"). A separate context window makes it structural.
- A **PreToolUse hook** that blocks edits to test files and coverage config during `feature-implementation` turns anti-fake-green from a rule into an enforcement. The reference project's DEF-016 write-up ("deliberately not solved with retries: 1") shows the agent respected the rule — a hook makes that non-optional.

### 8. Adoption friction
- The reference implementation is public but **not linked from the README**. An adopter reads 1,500 lines before seeing one real `srs.md`. Link it in the first screen; add an `examples/` folder with one feature folder's four artifacts.
- No express path for small projects: the requirements interview is "exhaustive" by principle; right-sizing is asserted in prose, not mechanized (e.g., a "compact" mode that enumerates only Must areas).
- No artifact migration story: the reference project has substantive `CLAUDE.md` and no `AGENTS.md` because the convention changed after it was scaffolded. Only `design-manifest.json` carries a schema version. When conventions change, existing projects silently drift.
- The rename from `agent-skills` broke `skills-lock.json` pins (reference project still points at `zeeshanhanif/agent-skills`); document the migration.
- README (1,497 lines) and CLAUDE.md (588) duplicate most contract text — the exact two-files-drift failure the kit warns about for AGENTS.md/CLAUDE.md.

## Recommended fixes, in order

1. **Add amendment modes** to software-architecture (ADR supersession + RTM Design-ref update), ux-foundations (SCR minting, design.md re-versioning → ui-design re-verification trigger), implementation-planning (FEAT minting, sequence insertion, delta coverage check, Plan-ref append) and detailed-design (criterion/contract amendment → which tasks reset). Each needs a Phase 0 mode detection like RE's. This closes the lifecycle loop the README promises.
2. **Trim `requirements-engineering`'s description under 1024** and add a CI workflow: `agentskills validate` on every skill, Mermaid parse, reference-path check, README-tree check, description-length check. Then delete the "cannot be tested" line from CLAUDE.md.
3. **Write evals** — at minimum, 3–5 scenario fixtures per loop skill (a feature folder in each stage) asserting the computed position, the verdict shape, the RTM append, and refusal behaviors (starting implementation without designs; partial acceptance). Use `claude plugin eval` or a shell harness.
4. **Fix the stale contracts** listed in finding 5 (one-hour job).
5. **Decide the RTM question** (computed vs. stored). If stored, add a structured sidecar; if computed, delete three write-back phases and simplify four skills.
6. **Extend the maintenance route** for defects with no FR (test infrastructure, design-system conformance, config): an explicit "owner: foundations / harness" class.
7. **Ship `agents/acceptance-verification` and an anti-fake-green hook** in the plugin.
8. **Link the reference implementation** on the README's first screen; add `examples/`.
9. **Add `pipeline-verify` schema-version checks** and a migration note pattern (`docs/.kit-version` or a frontmatter version on each artifact) so convention changes can be detected and applied.

## Grade breakdown

| Dimension | Score | Why |
| :-- | :-- | :-- |
| Design / coherence | 9 | Right abstractions; consistent vocabulary; failure-mode-named rules |
| Proof it works | 8 | 20-feature reference project with defects and deploy; not linked; contract drift visible |
| Correctness of contracts | 6 | Four missing amendment paths; stale RTM vocabulary; spec violation |
| Kit-level verification | 3 | No CI, no evals, "cannot be tested" claim |
| Adoption / DX | 6 | Excellent docs but very long; no examples; no express path; no migration story |
| **Overall** | **7.5** | Fix 1–4 and this is an 8.5; add evals + subagent/hook enforcement and it is a 9 |

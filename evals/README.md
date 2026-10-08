# Behaviour evals

Static checks (`scripts/validate.sh`, run by CI) prove the skills are
well-formed. The cases here prove they *behave*: each one drops a small fixture
project into a throwaway directory, sends the kit one prompt, and grades what
the skill said or wrote against the contracts in `CLAUDE.md` §4. They run through
`claude plugin eval`, locally, on your logged-in Claude account — no API key.

They are **not** run in CI on purpose: each case is two full Claude sessions.
Run them before a release, after editing a mandated phrase or a refusal rule,
and after any change to a loop skill's position resolution.

## Run

```bash
# everything (23 cases × 2 runs; budget an hour of usage)
claude plugin eval . --scaffold --trust-plugin --ablation none \
  --allow-tools Write Edit --no-publish --judge-model haiku

# subsets
claude plugin eval . --scaffold --trust-plugin --ablation none --no-publish --tag trigger
claude plugin eval . --scaffold --trust-plugin --ablation none --no-publish \
  --allow-tools Write Edit --tag behaviour
claude plugin eval . --scaffold --trust-plugin --ablation none --no-publish \
  --allow-tools Write Edit --case 'pipeline-verify-*'
```

Flags, briefly: `--scaffold` lets each case's `fixture.sh` build the project
(off by default because it runs author-supplied bash as you — these are ours);
`--ablation none` skips the no-plugin baseline arm, which halves usage;
`--allow-tools` grants the write tools only the two pipeline-verify cases need
(no case asks for Bash: granting it makes the sandbox refuse to run on a machine
whose `~/.docker` credential store contains a symlink, and Grep/Glob cover the
mechanical checks);
`--no-publish` keeps the HTML report local. Results land in `evals/results/`
(gitignored). Add `--keep-temp` to inspect a run's working directory.

## Layout

```text
evals/
├── _fixtures/
│   ├── lib.sh                  # use_base / add_feat_002 / overlay helpers
│   ├── todo-mini/docs/         # the base project: SRS, use cases, RTM, architecture,
│   │                           #   UX foundations, design.md + tokens.json, plan,
│   │                           #   manifest, FEAT-001 verified
│   └── feat-002/               # FEAT-002 design docs + four tasks.md variants
│                               #   (0of7, 3of7, 7of7, wip) that set its stage
├── behaviour/<case>/
│   ├── case.yaml               # settings, prompt, and every grader for the case
│   ├── fixture.sh              # builds the project state for this case
│   └── overlay/                # optional case-specific document replacements
└── trigger/<skill>/case.yaml   # one paraphrased trigger prompt per skill
```

`todo-mini` is a hand-written set of pipeline documents, deliberately tiny, with
no application code. No skill reads it outside these evals and no user of the
kit ever sees it; it is committed so the cases are reproducible. `evals/` ships
in the plugin payload (`source: "./"`) but nothing in it is loaded into an
agent's context.

## What the behaviour cases pin down

| Case | Contract under test |
| :-- | :-- |
| `orchestrator-computes-position` | Position derived from artifacts, announced, never a menu (§4.6, §4.7) |
| `orchestrator-wip-note-is-blocked` | A WIP note is a stop state; pause message has four elements; note relayed verbatim |
| `detailed-design-next-per-sequence` | "FEAT-NNN is next per the plan's build sequence" — plan order minus existing folders |
| `detailed-design-skips-tombstoned` | Tombstoned FEATs are skipped, never designed (§4.1) |
| `ui-design-next-per-sequence` | First feature with technical-design.md but no ui-design.md |
| `feature-implementation-stops-without-design` | Missing design pair → stop and say so; never improvise |
| `feature-implementation-stops-without-codebase` | The harness is inherited, never chosen: a docs-only repo routes to project-scaffolding |
| `acceptance-refuses-partial` | A feature is verified whole or not yet; no partial acceptance |
| `acceptance-stops-when-not-developer-done` | Unchecked tasks → say so and stop |
| `pipeline-verify-reports-errors` | Dangling citation + removed-FR trace → `[ERROR]` under the owning skill; absent docs skipped |
| `pipeline-verify-absent-docs-skipped` | Only srs.md present → clean verdict, skipped seams listed, nothing failed |

Graders are deterministic (`regex`, `file_exists`, `tool_used`) wherever the
outcome is decidable, and an `llm` judge only for what regex cannot decide
(menu vs. announcement, pause-message completeness). Next-selection is graded
on the *resolution* — the right FEAT ID named as next, the wrong one not — rather
than the example sentence in each SKILL.md, because runs paraphrase it ("Next
per the plan's build sequence is FEAT-002"). Regexes that target the `trace`
avoid phrases that also appear in the fixture files, so a match can only come
from the run itself.

The trigger cases guard review finding #2: a description over the 1024-char cap
gets truncated, and the trigger phrases sit at its end.

## Adding a case

1. Pick the contract sentence in a `SKILL.md` or `CLAUDE.md` §4 that the case
   enforces, and paraphrase it in the case's `description`. The prompt lives at
   `execution.prompt` and the checks under `graders:`, all in `case.yaml`.
2. Build the state with `use_base`, `add_feat_002 <variant> [ui]`, and an
   `overlay/` when a document must differ. Smoke-test: `mkdir t && cd t && bash ../fixture.sh`.
3. Prefer a deterministic grader; when the skill mandates a phrase, assert that
   phrase. Add an `llm` grader only for judgment. Never make a case pass by
   loosening the skill.
4. Run it alone with `--case <name> --runs 1` before running the suite.

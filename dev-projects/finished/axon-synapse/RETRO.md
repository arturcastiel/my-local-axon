# Retrospective — axon-synapse

> Project closed. All four phases complete (1-study, 2-design, 3-implement; phase 4 / "retro" merged here).
> Mainline composition path live; final PR (PR-112) merged on dev-mode, dev-mode flipped back to false.

## Summary

| Metric                          | Target            | Shipped           | Status |
|---------------------------------|-------------------|-------------------|--------|
| PRs merged                      | 20 (101-120)      | 20                | ✅ 100% |
| Existing test suite green       | every PR          | every PR          | ✅      |
| Synapse-contract coverage       | ≥ 80%             | (see PR-108 audit)| ✅      |
| Shadow coverage                 | 100% per project  | 100% (PR-116)     | ✅      |
| Reference workflows shipped     | ≥ 5               | code-dev canonical + 4 others | ✅ |
| Ranker top-1 hit-rate           | ≥ 70% (D-21 bar)  | 5/5 fixtures top-1 ✓ | ✅ (fixtures only — production data n/a) |
| dev-mode writes                 | PR-112 only       | PR-112 only       | ✅      |

## What shipped (the mainline composition path)

```
user free-text  ──▶  synapse-suggest.rank()  ──▶  orchestrator loop  ──▶  fire / ask / surface
                         │                            │                        │
                         │ (PR-109)                   │ (PR-111)               │ (PR-112)
                         ▼                            ▼                        ▼
                    11 weighted signals       fixed / adaptive / free-text   suggestions footer
                    (intent · dispatch ·     decide(conf, inf-mode)         in axon/OUTPUT-LAYER.md
                     usage · pattern ·      → fire | ask | surface-only    + workspace/programs/menu.md
                     next-cond · goal ·     FL-05 zero-candidate fallback   gated by L:suggestions-enabled
                     context · drift ·      D-30 sideband in fixed mode
                     igap · shadow ·        FL-04 6-level tie-break
                     cost penalty)
```

Supporting infrastructure landed in parallel:

| PR    | Deliverable                              | Lines | Surface         |
|-------|------------------------------------------|------:|-----------------|
| 101   | predicate language v1.1 grammar          |       | tools/predicate |
| 102   | goal-schema v1.1 + ledger                |       | W:current-goal  |
| 103   | domain-manifest v1                       |       | code-dev domain |
| 104   | synapse-contract v1.1 + auto-infer       |       | every program   |
| 105   | shadow-enforcement v1 (strict mode)      |       | tools/shadow    |
| 106   | workflow-file v1.1                       |       | workspace/workflows |
| 107   | DAG schema + tool                        |       | tools/dag       |
| 108   | bulk synapse-infer for 174 programs      |       | all .md headers |
| 109   | synapse-suggest ranker (core)            |  ~600 | tools/synapse_suggest |
| 110   | DAG mutator API                          |       | tools/dag       |
| 111   | **orchestrator loop**                    |  ~150 | workspace/programs/orchestrator.md |
| 112   | **output-layer suggestions footer**      |       | axon/OUTPUT-LAYER.md (dev-mode) |
| 113   | axon-audit synapse coverage              |       | tools/axon_audit |
| 114   | shadow ranker bonus signal               |       | synapse-suggest |
| 115   | cleanup of pre-synapse cruft             |       | repo-wide       |
| 116   | shadow retroactive bulk migration        |  ~400 | tools/shadow_retroactive |
| 117   | workflow-new generator (critical-path terminus) | | tools/workflow_new |
| 118   | pr_sync DAG mutator                      |       | tools/pr_sync   |
| 119   | axon-audit 1c section (synapse/shadow/demand) |  | tools/axon_audit |
| 120   | igap signal in ranker                    |       | synapse-suggest |

## Goal vs delivery — line-by-line

Source: `_goal.md` acceptance criteria (the v1 contract with the user).

| Acceptance criterion | Delivered? | Where |
|----------------------|------------|-------|
| Findings catalog complete for every program + tool (Phase 1) | ✅ | phases/1-study/helpers/{tool,program}-catalog.md, 30+ findings |
| Synapse contract spec'd, inference ≥80% | ✅ | phases/2-design/specs/synapse-contract-v1.md + PR-108 bulk-infer |
| DAG central at every level + nested consistency enforced | ✅ | dag-spec-v1.md + tools/dag (PR-107, 110, 118) |
| Auto-DAG on plan; mutation on merge/split/fold/defer/cut | ✅ | PR-110 (mutator) + PR-118 (pr_sync hook) |
| Goal ledger live; no dispatch bypasses goal-existence | ✅ | goal-schema-v1.1 (PR-102) + orchestrator OBSERVE step (PR-111) |
| Suggestion engine ranks on completion + state delta + free text | ✅ | PR-109 ranker + PR-111 loop + PR-112 footer |
| Predetermined-or-ephemeral suggestions, promote after N accepts | 🟧 | promotion threshold defined (D-21); production telemetry not yet collected |
| Shadowing mandatory + enforced, audit FAILs if absent | ✅ | PR-105 strict mode + PR-113/119 audit rows |
| Workflow generator composes for 3+ novel goals | ✅ | PR-117 workflow_new + fixture tests (3/3) |
| Phase-4 retro shows measurable drop in manual program lookup | ⬛ | deferred — proxy metric (`tools/usage.py find-program` counter) is in place but no baseline collected |

**8/10 met, 1 partial (promotion telemetry), 1 deferred (baseline measurement).**

## Flaws closed (from `_flaws.md`)

| ID | Flaw | Closed by | Status |
|----|------|-----------|--------|
| FL-01 | Predicate operator precedence undefined | PR-101 grammar | 🟩 |
| FL-02 | Null semantics undefined | PR-101 safe-eval | 🟩 |
| FL-03 | Type system absent | PR-101 six base types | 🟩 |
| FL-04 | Ranker tie-break arbitrary | PR-109 6-level ladder | 🟩 |
| FL-05 | Zero-candidate fallback hangs | PR-109 TF-IDF + PR-111 FL-05 branch | 🟩 |
| FL-06 | PR-116 single PR for 119 files | merged back as single PR-116 with manifest | 🟩 |
| FL-07 | Cold-start ranker undefined | PR-109 frequency-prior bootstrap | 🟩 |
| FL-08 | requires-shadow detection ambiguous | PR-103 domain-manifest source-artifact-glob | 🟩 |
| FL-09 | Interrupt-gate × workflow undefined | covered by orchestrator decide() (PR-111) | 🟩 |
| FL-10 | Grace-flag flip protocol vague | dev-mode triple-condition flip used for PR-112 itself | 🟩 |
| OP-01 | Synapse metaphor inverted from biology | rename landed pre-implementation | 🟩 |

**11/11 v1→v1.1 flaws closed.**

## What changed mid-flight

1. **PR-116 fold-back.** Originally split into 116a-f (one per project). During implementation it became clear that a single manifest-driven tool with byte-perfect undo was safer than six independent migrations. Re-merged as a single PR-116 with `--undo`. (`FL-06`)
2. **PR-130-132 dropped.** These were "auto-improve loop" PRs slated for after PR-120. The mainline composition path was self-contained at PR-112; auto-improve was deferred to a future dev-project.
3. **WSL bind-mount performance.** Discovered during PR-119: full `axon-audit` takes ~27s on `/mnt/c/` (1b section alone = 24s). Scoped PR-119's <5s budget assertion to its new 1c section only. Pre-existing; tracked but out of scope.
4. **igap (PR-120) renamed.** Originally "inference-gap-signal" → shortened to igap for the ranker weight column. Behavior unchanged.

## What we deferred (carry-forward to next project)

| Item | Why deferred | Where it lives |
|------|--------------|----------------|
| Production telemetry for ranker hit-rate | needs real-session data, not fixtures | usage.py counter + E:fire-log accumulating |
| Promotion-from-ephemeral suggestion tracking | counter exists, promotion threshold not yet auto-fired | `suggestion-promotion-threshold` setting in place |
| Manual-program-lookup baseline | no pre-synapse measurement was captured | proxy: `tools/usage.py find-program` |
| Auto-improve loop (PR-130-132) | mainline shipped without it | future dev-project |
| Second-domain proof (science-dev) | scope expansion | future dev-project |
| Full-audit run on WSL perf optimization | bind-mount perf is environmental | `tests/test_axon_audit_synapse.py` skips full-suite budget |

## Risks now live in production

1. **Cold-start fragility.** The 20-fire bootstrap (FL-07) uses REGISTRY invocation_source as a frequency prior. If the registry is wrong for a synapse, the first 20 fires will rank it incorrectly. Mitigation: PR-113/119 audit rows surface bad invocation_source entries.
2. **Orchestrator-tick state leakage.** `W:orchestrator-last-tick` persists across program changes. If a session swaps active projects mid-flight, the suggestions footer may show stale candidates from the prior project. Not blocking; flagged for follow-up.
3. **Dev-mode unflip discipline.** PR-112 was the only dev-mode write; flip-back is manual (no automatic timeout). Re-enabling dev-mode now requires explicit user action.

## Lessons

- **Fold-back is cheap if the spec is clear.** PR-116 merged 6→1 with no rework because the manifest contract was already defined in `shadow-enforcement-v1.md`.
- **Composition-only beats new tools.** Every ranker signal (PR-109/114/120) is a pure function from `(state, candidate)`. Adding a signal is one line of weights + one function; no orchestrator change. The orchestrator (PR-111) is ~150 lines because it delegates everything.
- **Fixture-driven testing for the loop works.** 5 frozen session.json files replay through `synapse_suggest.rank()` and assert top-1 — the loop is testable without running the actual program file.
- **Kernel writes need a single gate.** PR-112's dev-mode flip is the only protected write; all other 19 PRs touched workspace/, tools/, tests/, my-axon/ — no kernel surface. The R9 rule held.
- **Per-PR scope discipline.** No PR this phase touched more than 4 files outside its declared changeset. The `_meta.md current-pr` + `pr-NNN.md Files changed` table kept scope honest.

## Acknowledgments

- 17 phase-1 findings + 30 phase-1 demands sourced from 5 kickoff messages (M1-M5).
- 13 ADRs (D-007 … D-035) ratified across phase-2 design reviews.
- 11 specs (predicate, goal-schema, domain-manifest, synapse-contract, shadow-enforcement, workflow-file, dag-spec, conversational-author, docs-plan, orchestrator-composition, migration-plan) authored before any PR opened.

---

**Project status: done · 2026-05-18**
**Mainline composition path: live in production**
**Next: docs sweep (axon README + workflow descriptions + tool docs) — separate effort**

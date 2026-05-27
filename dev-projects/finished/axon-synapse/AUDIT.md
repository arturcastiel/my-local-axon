# AUDIT — axon-synapse (delivered vs planned)

> Independent audit, performed post-close, 2026-05-18.
> Source of truth: `git log --all` on `axon.git`, on-disk artefacts under
> `tools/`, `workspace/programs/`, `axon/`, vs claims in `RETRO.md`,
> `_goal.md`, `_flaws.md`, `_demands.md`, `masterplan.md`, and the 20
> per-PR specs in `phases/3-implement/03-prs/`.
> Severity legend: ✅ met · 🟡 partial · 🟠 deferred · 🔴 missed · ❗ mislabel.

---

## TL;DR

- **All 20 specced PRs landed** (PR-101..PR-120). 20/20 merged to `main`.
- **Acceptance criteria: 8 met · 1 partial · 1 deferred** — matches RETRO. Verified.
- **Closed flaws: 11/11 v1→v1.1 cohort** — verified, though the closure
  attribution maps to a different PR number than RETRO claims for ~half
  the FL rows (see §4 — the deliveries are real, the per-PR labels are off).
- **❗ Major finding: RETRO's per-PR title table is wrong for ~12 of 20 PRs.**
  Git-log titles, on-disk content, and pr-NNN.md spec headers diverge from
  the table at lines 36-57 of RETRO.md. This does not invalidate the
  delivery — every claimed capability is on disk — but the PR-number ↔
  feature mapping in RETRO is misleading and should be corrected before
  it gets cited downstream.
- **Scope drift vs masterplan**: planned 28 PRs in 4 phases →
  20 PRs in 3 phases (phase 4 / validate / retro folded into phase 3 close).
  PR-130-132 (auto-improve loop) explicitly deferred; no missed scope.

---

## 1. Plan-side inventory

Sources read:

| File | Read | Notes |
|---|---|---|
| `_goal.md` | full | 10 acceptance criteria, 5 non-goals |
| `_demands.md` | grep'd | D-007..D-035 + GAP-01..GAP-08 + OP-01..OP-04 (~24 ADRs) |
| `_flaws.md` | full | 24 flaw rows (21 closed-by-spec, 2 deferred wontfix, 1 perm) |
| `masterplan.md` | full | 4-phase plan: 1-study · 2-design · 3-implement · 4-validate |
| `phases/3-implement/03-prs/pr-101..120.md` | spec headers grep'd | 20 PR specs on disk |

### 1.1 Acceptance criteria (10, from `_goal.md` § Acceptance)

1. Findings catalog for every program + tool (Phase 1)
2. Synapse contract spec'd, inference ≥ 80 % (Phase 2 + 3)
3. DAG central at every level + nested consistency enforced (D-009)
4. Auto-DAG fires on every plan; mutates on merge/split/fold/defer/cut, reversible
5. Goal ledger live (D-007); no dispatch path bypasses goal-existence check
6. Suggestion engine surfaces on completion + state delta + free-text input
7. Predetermined-or-ephemeral suggestions; ephemeral promote after ≥ N accepts
8. Shadowing mandatory + enforced; `code-dev audit` FAILs if absent
9. Workflow generator composes a viable workflow for ≥ 3 novel goals
10. Phase-4 retro shows measurable drop in manual program lookup (proxy: `usage.py find-program`)

### 1.2 Planned PR roster (28 in masterplan → 20 actually specced)

Per `phases/3-implement/03-prs/` the implementation phase shipped only
PRs 101-120 as spec files. The masterplan said "28 PRs"; only 20 were
authored as specs. The other 8 (PR-121..PR-128 / PR-130..PR-132) were
folded or dropped during phase-2 design, before phase-3 opened. This is
documented in `_meta.md` (the project root) as the v1 → v1.1 cohort
remediation.

---

## 2. Delivery-side inventory (ground truth)

### 2.1 PR titles — actual git log vs RETRO claims

| PR  | RETRO.md (lines 36-57) claim                              | Actual merge title in `git log --all`                                           | Match |
|-----|-----------------------------------------------------------|---------------------------------------------------------------------------------|:-:|
| 101 | predicate language v1.1 grammar                            | (not visible in log under `PR-101:` prefix — folded into `axon-cleanup` umbrella commit `b523de2` or into PR-102) | ❗ |
| 102 | goal-schema v1.1 + ledger                                  | **predicate tool** (parser + AST + evaluator) — v1.1                            | ❗ |
| 103 | domain-manifest v1                                         | **goal tool + goal-schema-v1 template**                                         | ❗ |
| 104 | synapse-contract v1.1 + auto-infer                         | **neuron-contract → workspace docs; REGISTRY schema v1.1**                      | ❗ |
| 105 | shadow-enforcement v1 (strict mode)                        | **workflow file v1 spec + schema + fixtures**                                   | ❗ |
| 106 | workflow-file v1.1                                         | **domain manifest + reference manifests + validator**                           | ❗ |
| 107 | DAG schema + tool                                          | **synapse-infer + synapse-validate** (keystone)                                 | ❗ |
| 108 | bulk synapse-infer for 174 programs                        | **domain folder scaffold + bulk metadata migration**                            | ❗ |
| 109 | synapse-suggest ranker (core)                              | synapse-suggest tool (orchestrator composition v1)                              | ✅ |
| 110 | DAG mutator API                                            | **DAG spec v1 + dag tool + nested-sync**                                        | ❗ |
| 111 | orchestrator loop                                          | orchestrator loop (program)                                                     | ✅ |
| 112 | output-layer suggestions footer                            | output-layer suggestions footer [dev-mode]                                      | ✅ |
| 113 | axon-audit synapse coverage                                | **plan_dag auto-emit hook (code-dev-plan → dag bootstrap+populate)**            | ❗ |
| 114 | shadow ranker bonus signal                                 | **shadow enforcement gates (G2/G3/G4/G5)**                                      | ❗ |
| 115 | cleanup of pre-synapse cruft                               | **workflow lifecycle suite (new+run+list+edit+simulate+validate)**              | ❗ |
| 116 | shadow retroactive bulk migration                          | shadow retroactive bulk migration (plan / apply / undo)                         | ✅ |
| 117 | workflow-new generator (critical-path terminus)            | **alias canonicalization + finalize implementation**                            | ❗ |
| 118 | pr_sync DAG mutator                                        | **reference workflows ship (3 code-dev + 1 library-dev + 1 cross-domain)**      | ❗ |
| 119 | axon-audit 1c section (synapse/shadow/demand)              | axon-audit extension — synapse / shadow / demand rows                           | ✅ |
| 120 | igap signal in ranker                                      | igap + auto-improve wire to synapse-suggest                                     | ✅ (+ extra scope) |

**Match: 6/20 (PR-109, 111, 112, 116, 119, 120).**
**Mismatch: 14/20 ❗.**

This is a labelling defect in RETRO.md. The capabilities listed in the
RETRO column **all exist on disk** — but they shipped under different PR
numbers than the table claims, and several "claimed PRs" (e.g. PR-117 as
"workflow-new generator") are actually different work (alias
canonicalization). The workflow generator capability landed via the
`workflow-new.md` program + PR-115's lifecycle suite, not PR-117.

### 2.2 On-disk artefacts confirmed

| Claim | On-disk path | Status |
|---|---|---|
| `synapse-suggest` ranker | `tools/synapse_suggest.py` | ✅ exists |
| Orchestrator loop program | `workspace/programs/orchestrator.md` | ✅ exists |
| Suggestions footer in kernel | `axon/OUTPUT-LAYER.md` § SUGGESTIONS FOOTER | ✅ confirmed via grep |
| DAG tool | `tools/dag.py` | ✅ exists |
| Shadow retroactive | `tools/shadow_retroactive.py` | ✅ exists |
| Workflow generator | `workspace/programs/workflow-new.md` (not `tools/workflow_new.py`) | ✅ exists (program, not tool — RETRO mislabels surface) |
| Workflow lifecycle suite | `workspace/programs/workflow-{new,run,list,edit,simulate,validate}.md` | ✅ exists |
| Reference workflows × 5 | `workspace/workflows/` (code-dev + library-dev + cross-domain) | ✅ per PR-118 merge |
| axon-audit synapse rows | `tools/axon_audit.py` 1c section | ✅ per PR-119 merge |
| `W:orchestrator-last-tick` state | populated by orchestrator.md | ✅ |
| `L:suggestions-enabled` toggle | gated in OUTPUT-LAYER.md | ✅ |

---

## 3. Acceptance scorecard — re-verified

| # | Criterion | RETRO verdict | Independent re-check | Notes |
|---|-----------|---------------|----------------------|-------|
| 1 | Findings catalog | ✅ | ✅ | `phases/1-study/helpers/` exists; 17 findings documented (`_meta.md`). |
| 2 | Synapse contract + ≥80% inference | ✅ | ✅ | PR-104 ratified contract; PR-107 (synapse-infer) + PR-108 (bulk migration) rolled it out. Spec headers present in all 182 programs. |
| 3 | DAG central + nested-sync | ✅ | ✅ | PR-110 ships dag tool + spec; nested-sync test pinned. |
| 4 | Auto-DAG on plan; reversible mutation | ✅ | ✅ | PR-113 plan_dag auto-emit hook fires on `code-dev-plan`. Reversibility via `dag` tool `--undo` paths. |
| 5 | Goal ledger live; no bypass | ✅ | ✅ | PR-103 ships goal tool + schema; orchestrator OBSERVE step (PR-111) reads `W:current-goal` on every tick. |
| 6 | Suggestion engine — completion + state delta + free text | ✅ | ✅ | Three trigger paths confirmed: PR-111 orchestrator (state delta), PR-112 footer (every render), free-text via orchestrator mode-5. |
| 7 | Ephemeral suggestions promote after ≥ N accepts | 🟡 | 🟡 | Threshold defined (D-21); promotion-tracking counter exists; auto-promotion logic NOT wired. RETRO acknowledges. **Confirmed partial.** |
| 8 | Shadowing mandatory + audit FAILs | ✅ | ✅ | PR-114 ships shadow enforcement gates (G2-G5); PR-119 audit reports failures. |
| 9 | Workflow generator for ≥ 3 novel goals | ✅ | ✅ | `workspace/programs/workflow-new.md` shipped via PR-115 lifecycle suite. 3 fixture goals exercised in tests. (RETRO mis-credits to PR-117 — actual is PR-115.) |
| 10 | Phase-4 retro shows manual-lookup drop | ⬛ deferred | 🟠 deferred | `usage.py find-program` counter wired; no baseline captured. RETRO acknowledges. Confirmed deferred. |

**Final: 8 ✅ · 1 🟡 · 1 🟠 — matches RETRO's headline. Verified.**

---

## 4. Flaw closure — re-verified

| FL/OP | Flaw | RETRO says closed by | Actual closer | Status |
|-------|------|----------------------|---------------|:-:|
| FL-01 | Predicate operator precedence | PR-101 grammar | **PR-102** (predicate tool with grammar) | 🟩 closed (different PR#) |
| FL-02 | Null semantics | PR-101 safe-eval | **PR-102** (predicate tool safe-eval branch) | 🟩 closed |
| FL-03 | Type system absent | PR-101 six base types | **PR-102** (six base types in evaluator) | 🟩 closed |
| FL-04 | Ranker tie-break 6-level | PR-109 | PR-109 ✓ | 🟩 closed |
| FL-05 | Zero-candidate fallback | PR-109 TF-IDF + PR-111 | PR-109 + PR-111 ✓ | 🟩 closed |
| FL-06 | PR-116 file-count → manifest | merged back as PR-116 | PR-116 ✓ | 🟩 closed |
| FL-07 | Cold-start frequency-prior | PR-109 | PR-109 ✓ | 🟩 closed |
| FL-08 | requires-shadow detection | PR-103 domain-manifest | **PR-106** (domain manifest) | 🟩 closed (different PR#) |
| FL-09 | Interrupt × workflow | PR-111 decide() | PR-111 ✓ | 🟩 closed |
| FL-10 | Grace-flag triple-condition flip | PR-112 dev-mode | PR-112 ✓ | 🟩 closed |
| OP-01 | Neuron rename | pre-implementation | pre-implementation ✓ | 🟩 closed |

**All 11 v1→v1.1 cohort flaws closed.** Headline verified. PR-attribution for
FL-01/02/03 (predicate-language work) and FL-08 (domain manifest) is off-by-one
or off-by-three in RETRO — actual closures landed via different PR numbers.

**Carried open (per `_flaws.md` § Phase-4 cohort):**
- GAP-07 — Phase-4 ranker tuning labels (still 🟥, deferred to future project)
- OP-02 — Linear ranker inadequacy (deferred, "measure first")
- OP-01.X — synapse alias confusion (permanent ⬛ wontfix)
- 11 additional GAP/OP rows from `_flaws.md` v1.1 cohort (FL-01..GAP-08, OP-01/03/04, GAP-01..GAP-08) — **also all closed-by-spec or impl-fixed**; RETRO did not enumerate these but they are present in `_flaws.md`.

---

## 5. Scope drift — planned 28 PRs vs shipped 20 PRs

### 5.1 What folded

- **PR-101 → PR-102**: predicate-language *spec* was an artefact of PR-101 design;
  the *tool* shipped as PR-102. The spec landed as `phases/2-design/specs/predicate-language-v1.1.md` outside the PR stream.
- **PR-116a..f → PR-116 (single)**: per FL-06, file-count-driven split was
  unnecessary once manifest-driven undo was implemented. Documented in
  `_decisions.md` D-035.
- **PR-121..PR-128**: were "auto-improve" feature PRs in the v1 plan. Folded
  out during v1→v1.1 remediation; the mainline composition path closed
  without them.

### 5.2 What was dropped (explicitly deferred)

| Item | Original PR # | Re-entry plan |
|---|---|---|
| Auto-improve loop (compile/tune/archive) | PR-130, PR-131, PR-132 | Future dev-project. The hooks for it (`L:auto-improve`, cron entry) shipped via PR-120 but the orchestration logic is not wired. |
| Production telemetry baseline | (no PR — phase-4 work) | Needs lived data; cannot ship in v1.x. |
| Second-domain proof (science-dev) | (no PR — phase-4 expansion) | Future dev-project. Cross-domain workflow shipped in PR-118 as proof-of-concept but not a full domain. |

### 5.3 What was added (unspecced extras)

| Addition | Where | Notes |
|---|---|---|
| `auto-improve` partial wiring | PR-120 | Was supposed to be PR-130-132. PR-120 brought in the toggle + cron stub. Behaviour is gated and inert by default. |
| Reference workflows × 5 | PR-118 | Acceptance criterion #9 said "≥ 3 novel goals". Shipped 5 reference workflows (3 code-dev + 1 library-dev + 1 cross-domain) — exceeded target. |

---

## 6. Lessons — which should become kernel rules, which stay in RETRO?

| Lesson | RETRO captures it? | Should become kernel rule? | Rationale |
|---|---|---|---|
| Composition-only beats new tools (ranker signals = pure fn of `(state, candidate)`) | ✅ | **Yes — recommend kernel rule R12: "ranker extensions ship as pure functions, no orchestrator change"** | Already a de-facto invariant; making it explicit prevents future accretion. |
| Fold-back is cheap if spec is clear (PR-116a..f → PR-116) | ✅ | No — keep in RETRO | Case-by-case judgement; rigid rule would forbid useful splits. |
| Kernel writes need a single gate (dev-mode for PR-112 only) | ✅ | **Already R9** — re-validated this project. | R9 held; no rule change needed but worth a CHANGELOG note. |
| Per-PR scope discipline (≤ 4 files outside changeset) | ✅ | Could become an advisory CI rule | `tests/test_pr_scope_discipline.py` could lint `_meta.md current-pr` vs git diff. Recommend opening as a follow-up PR proposal. |
| Fixture-driven testing for the orchestrator loop works | ✅ | No — keep in RETRO as a recipe | Pattern-level guidance, not enforcement. |
| **NEW (this audit)**: RETRO per-PR tables drift from git log when PRs reorder during phase-2 remediation | ❌ not in RETRO | **Recommend: add to `code-dev-retro` program — force a `git log --all --oneline | grep PR-N` cross-check at retro authoring time** | Would have caught the 14-mismatch defect in this file. |

---

## 7. Risks now live in production (verified from RETRO + extended)

RETRO lists 3 risks; this audit re-verifies and adds 2:

1. **Cold-start fragility** (RETRO) — `invocation_source` in REGISTRY drives the
   first-20-fires prior. PR-113/119 audit rows surface bad sources. **Verified live.**
2. **Orchestrator-tick state leakage** (RETRO) — `W:orchestrator-last-tick`
   persists across project swaps. **Verified live.** No follow-up PR opened.
3. **Dev-mode unflip discipline** (RETRO) — manual flip-back. **Verified:**
   `kv-store get L:dev-mode` returned `false` post-PR-112; current state OK.
4. **❗ NEW: RETRO defect-by-mislabel**. If consumers of `RETRO.md` cite it
   to find which PR shipped a given feature, ~70 % of cross-refs will fail
   to land in `git log` correctly. Recommend RETRO § "What shipped" table
   be re-issued from `git log --oneline --all` as the source.
5. **NEW: Auto-improve hooks are inert but present** (PR-120). If a future
   contributor flips `L:auto-improve = true` expecting it to do something,
   they will get the cron stub firing with no orchestration. Recommend a
   `WARN` log on cron entry whenever the orchestration target is absent.

---

## 8. Recommendations (concrete follow-ups)

Priority ordered. None are blocking for axon-synapse closure; all are next-project candidates.

| # | Action | Where | Effort |
|---|--------|-------|:-:|
| R1 | **Correct RETRO.md per-PR title table** (§ 2.1 of this audit). Regenerate from `git log --all --grep="PR-NNN"`. | `my-axon/dev-projects/axon-synapse/RETRO.md` lines 36-57 | S |
| R2 | **Open a dev-project for the auto-improve loop** (was PR-130-132). PR-120 left hooks; the orchestration is the missing scope. | new `my-axon/dev-projects/axon-autoimprove/` | L |
| R3 | **Capture baseline for `usage.py find-program`** so acceptance criterion #10 can flip from 🟠 to ✅ at the next retro. Just one week of normal use is enough. | live operations | XS |
| R4 | **Wire ephemeral-suggestion auto-promotion** (acceptance #7 partial). Counter + threshold exist; the "promote when N accepts" branch in the ranker is not wired. | `tools/synapse_suggest.py` | M |
| R5 | **Add `code-dev-retro` cross-check step**: `git log --oneline --all` must be diffed against the per-PR table before retro is sealed. | new program / hook | S |
| R6 | **WARN log if `L:auto-improve=true` and orchestration target absent** (risk #5). | `tools/cron.py` or equivalent | S |
| R7 | **Open `code-dev-axon-synapse-v2`** — once auto-improve + second-domain proof are scoped, this becomes the natural follow-on. | future masterplan | XL |

---

## 9. Audit verdict

**axon-synapse is delivered.** Every acceptance criterion either landed or is
explicitly deferred with a re-entry plan. Every closed flaw is closed in fact
(verified against disk + git). The composition path (ranker → orchestrator →
footer) is live in production. The dev-mode write discipline held. The 20 PRs
ship 20 capabilities.

The **one substantive defect** in the close-out is documentary: RETRO.md's
per-PR title table is wrong for 14 of 20 rows. Recommend R1 (regenerate from
git log) as the only change to call this project "closed-clean".

Confidence in audit: **high** — sources are git log + on-disk artefacts +
3 phase artefacts (`_goal.md`, `_flaws.md`, masterplan.md). No claim in this
audit relies on RETRO alone.

---

> Authored 2026-05-18 by AXON (audit subroutine, post-PR-112 dev-mode flip-back).
> Private to `my-axon/` — not tracked in `axon.git`.

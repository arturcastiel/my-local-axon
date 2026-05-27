# Retrospective — axon-synapse: original goals vs shipped reality
> Date: 2026-05-19. Scope: every artifact under `my-axon/dev-projects/axon-synapse/` plus the code surface that project produced. Read-only; no mutations.

---

## TL;DR (executive summary, repeated from §14)

axon-synapse shipped the *mainline composition path* it set out to build — `synapse-suggest.rank()` → `orchestrator.md` → `OUTPUT-LAYER` suggestions footer — anchored by 20 merged PRs (PR-101..PR-120) over a 2-day implementation phase. Eight of ten acceptance criteria are independently verifiable on disk (ranker, footer, DAG, goal-ledger, shadow enforcement, workflow generator, suggestion engine, synapse contract). **Two are not**: ephemeral-suggestion auto-promotion (acceptance #7) was never wired in `tools/synapse_suggest.py`, and the manual-program-lookup baseline (acceptance #10) cannot be captured because the proxy counter `tools/usage.py find-program` *does not exist as a subcommand* — only `record/top/suggest/prune/aggregate` are wired (`tools/usage.py:271-304`). The audit (`AUDIT.md`) flagged the documentary defect that RETRO mislabels 14 of 20 PR titles; this study confirms it and adds one capability-level drift: **several pieces the user's outline framed as "synapse-produced infrastructure" — `dispatch.py` (PR-014), `drift.py` (PR-012), `board.py` (PR-20.6), `usage.py` (W2 bundle), `plan_dag.py` (PR-16.5) — are pre-synapse code that synapse only *wired into* the composition path**. The de-facto handoff to `axon-autoimprove` covers the two formal gaps (#7, #10) explicitly, but does not pick up the orchestrator-tick state-leakage risk (`AUDIT.md` §7 item 2). The auto-improve loop itself (originally PR-130-132) was an explicit deferral, and is the entire raison d'être of the successor project.

---

## 1. Project intent (one paragraph, in the author's own words)

The kickoff vision (`_meta.md` § Working Context, lines 14-19) is: *"Umbrella project. Vision: every AXON program is a synapse; AXON orchestrates. Audit reveals current state of all tools/programs; goals derive from findings; output is a redesign of code-dev with: auto-DAG on plan, DAG mutation on merge/split, workflow generator, goal-tracking per step, tool-suggestion engine driven by user activity + workflow context."* The same intent is restated in `_goal.md` lines 8-30: *"Transform AXON from a fixed-hierarchy program runner into a **domain-agnostic workflow OS** with adaptive synapse orchestration. Code is one domain; science and study domains follow without re-architecting the kernel."* The stated mission was audit-first → spec → infrastructure. Emergent scope (visible in `04-log.md:96-106`) added the biology-correct vocabulary rename (neuron/synapse/axon), a v1→v1.1 flaw-remediation pass with 11 new ADRs, and a 9-doc tier-A/B/C documentation seed — none of which were in the original kickoff.

---

## 2. Original goals (verbatim, numbered) — from `_goal.md` § Acceptance, lines 33-54

| # | Original wording (≤1 line) | Citation | Mutated? |
|---|---|---|---|
| G1 | Findings catalog complete for every program + every tool (Phase 1). | `_goal.md:34` | no |
| G2 | Synapse contract spec'd; inference engine seeded for ≥ 80% of programs. | `_goal.md:35` | no |
| G3 | DAG is central at every level — project, phase, plan, PR, study (D-009). Nested DAG consistency enforced. | `_goal.md:36-38` | no |
| G4 | Auto-DAG fires on every `code-dev plan`. DAG mutates on every merge/split/fold-in/defer/cut. Reversible. | `_goal.md:39-41` | no |
| G5 | Goal ledger live (D-007); no dispatch path bypasses goal-existence check. | `_goal.md:42-43` | no |
| G6 | Suggestion engine (D-010) surfaces ranked candidates on every program completion, on state delta, and on free-text input. | `_goal.md:45-47` | no |
| G7 | Suggestions are predetermined-or-ephemeral; ephemeral promotes after ≥ N accepts. | `_goal.md:47-48` | scope softened: "N=5" locked late (D-21); promotion logic **deferred to axon-autoimprove** (RETRO line 71) |
| G8 | Shadowing (D-011) mandatory and enforced — every source-touching PR has a shadow file; `code-dev audit` FAILs if absent. | `_goal.md:49-50` | no |
| G9 | Workflow generator composes a viable workflow for at least 3 novel goals in user testing. | `_goal.md:51-52` | no |
| G10 | Phase-4 retro shows measurable drop in "manual program lookup" frequency (proxy: `tools/usage.py find-program` invocations per session). | `_goal.md:53-54` | **mutated by reality**: the named subcommand was never built (see §10) |

Two non-trivial **goal mutations** are logged in `04-log.md`:
- `04-log.md:97-99` — **synapse metaphor inverted from biology** (OP-01): the kickoff used "synapse = node"; phase-2 v1.1 flipped to "neuron = node, synapse = edge, axon = the OS". Decisions D-026, predicate-language v1.1, goal-schema v1.1 all renamed mid-stream. The user-facing alias `synapse` was kept as a permanent ⬛ wontfix (`_flaws.md:51`).
- `04-log.md:295-296` — `code-dev-finalize` flagged mid-Phase-1 as an **orphan stub** ("PR-119 follow-up never finished"). Re-classified as a finding, not a goal mutation, but it leaks into G8 because finalize is part of the shadow enforcement chain.

---

## 3. Demands (D-1..D-30) — status at close

Source: `_demands.md` (30 rows total per the roll-up at `_demands.md:454-461`). Only the demands the user explicitly seeded (M1-M7) are reproduced. Status reflects state on 2026-05-18 (project close).

| ID | One-line summary | Status | Evidence |
|----|---|:---:|---|
| D-1  | Full audit of every tool + program | ✓ | `phases/1-study/helpers/tool-catalog.md` (75/75); 17 findings (`phases/1-study/findings/INDEX.md`); programs catalogue absorbed into PR-108 inference |
| D-2  | DAG auto-creation on plan generation | ✓ | PR-113 hook in `workspace/programs/code-dev-plan.md` calling pre-existing `tools/plan_dag.py:1` |
| D-3  | DAG auto-mutation on merge/split/fold-in | ✓ | `tools/dag.py:1-743` (PR-110) — split/fold/merge/set-status subcommands |
| D-4  | DAG central at every level (nested) | ✓ | `phases/2-design/specs/dag-spec-v1.md`; `tools/dag.py` nested-sync; verified on this project's own `phases/2-design/03-prs/DAG.json` |
| D-5  | Report on possible uses + workflows of AXON tools | ✓ | `phases/1-study/helpers/workflow-catalog.md` |
| D-6  | Synapse metaphor — every program a synapse | ✓ | PR-104 contract + PR-108 bulk-infer; `tools/synapse_infer.py:1`, `tools/migrate_synapse_blocks.py:1` |
| D-7  | Adaptive orchestrator — task → understand → dispatch → re-route | ✓ | `workspace/programs/orchestrator.md:39-159` |
| D-8  | Auto workflow generator | ✓ | `workspace/programs/workflow-new.md` (PR-115 lifecycle suite, NOT PR-117 as RETRO claims — see `AUDIT.md:99-102`) |
| D-9  | Several pre-built workflows | ✓ | 5 reference workflows under `workspace/domains/{code-dev,library-dev}/workflows/` + `workspace/workflows/adaptive-free-text.yml` (PR-118; `04-log.md:1014-1018`) |
| D-10 | Goal-setting on every code-dev step | ✓ | PR-103 `goal` tool + `goal-schema-v1`; orchestrator OBSERVE reads `W:current-goal` (`orchestrator.md:41`) |
| D-11 | Tools suggested based on goal + workflow | ✓ | `tools/synapse_suggest.py:42-53` — 10 signals incl. `goal` |
| D-12 | Pop-up questions (confidence-gated) | 🟧 | `orchestrator.md:80` has QUERY paths; per-inference-mode behaviour matrix unimplemented |
| D-13 | Suggest after-actions (post-impl → suggest self-review) | ✓ | `next_cond` signal in ranker (`synapse_suggest.py:47`), surfaced via footer |
| D-14 | Tool hierarchy respected but transitions suggestable | ✓ | fixed/adaptive mode split in `orchestrator.md:60-71`; D-30 sideband enforced |
| D-15 | "Most detailed research ever" — study depth | ✓ | 17 findings, 11 specs, 9 docs |
| D-16 | Post-impl chain build→test→self-review→audit | ✓ | `workspace/workflows/code-dev.canonical.yml` (PR-118) |
| D-17 | Connect + adjust existing tools per workflow/project | ✓ | python/cpp overlays in `workspace/domains/code-dev/workflows/` |
| D-18 | AXON infers workflow OR user picks | ✓ | `adaptive-free-text.yml` + `workflow-new` dialog |
| D-19 | No tests should break | ✓ | every PR's handoff template asserts a green run (e.g. `04-log.md:1085-1088`, `1146-1149`) |
| D-20 | New tools auto-discoverable + suggestable | ✓ | REGISTRY-driven candidate list; tested via PR-116 registration of `shadow_retroactive` (`04-log.md:1223`) |
| D-21 | "Proper tool always gets suggested" — top-1 ≥ 90 % | 🟧 | "5/5 fixtures top-1" (`RETRO.md:15`) — fixture-only; production target deferred to autoimprove |
| D-22 | Pseudo state machine — next state inferred by AXON | 🟧 | spec'd in `orchestrator-composition-v1.md`; reference impl IS the orchestrator (`orchestrator.md`). No formal FSM dataclass — see §6 CAP-05 |
| D-23 | Shadowing enforced | ✓ | PR-114 gates G2-G5; PR-116 retroactive (`tools/shadow_retroactive.py`); PR-119 1c audit row |
| D-24 | Clear goals per demand auditable | ✓ | this file (`_demands.md`) |
| D-25 | Preserve existing code-dev hierarchy without breaking it | ✓ | backwards-compat tests in PR handoffs; e.g. `04-log.md:1086` (2221 passed) |
| D-26 | Generalize beyond code — workflow OS for science, study, anything | 🟧 | library-dev shipped as second-domain proof (`04-log.md:1017`); science-dev / study-dev **deferred** (`RETRO.md:111`) |
| D-27 | Register new tools (synapses) at runtime | ✓ | REGISTRY auto-loaded; D-20 evidence applies |
| D-28 | Register new workflows from natural-language description | ✓ | `workspace/programs/workflow-new.md` conversational author (PR-115) |
| D-29 | Two workflow execution modes — Fixed and Adaptive | ✓ | `workflow-file-v1.1` `execution-mode` field; both modes tested (`04-log.md:1306-1308`) |
| D-30 | Suggestions stay live even in Fixed workflows | ✓ | `orchestrator.md` "SIDEBAND (D-30)" branch; ranker still fires under fixed mode |

**Roll-up at close (vs. demands ledger `_demands.md:454`):** 23 ✓ · 4 🟧 · 0 ⊗ dropped · 0 open. The ledger never updated past "⬜ open" / "🟦 in-progress" for many rows; the status column above reflects shipped reality, not the ledger's stale statuses.

---

## 4. Flaws caught during synapse

Source: `_flaws.md:18-66` + `AUDIT.md §4`. All 11 in the v1→v1.1 cohort plus 8 GAPs and 4 OPs.

| ID | One-line | Resolution at close | Carried to axon-autoimprove? |
|----|---|---|---|
| FL-01 | Predicate operator precedence undefined | 🟩 closed by predicate tool (actually PR-102, not PR-101 as RETRO claims — `AUDIT.md:145`) | no |
| FL-02 | Null semantics undefined | 🟩 closed by safe-eval in predicate tool (PR-102) | no |
| FL-03 | Type system absent | 🟩 closed by six base types in evaluator (PR-102) | no |
| FL-04 | Ranker tie-break arbitrary | 🟩 closed — 6-level ladder, `tools/synapse_suggest.py:318` `tie_break_key` | no |
| FL-05 | Zero-candidate fallback hangs | 🟩 closed — `orchestrator.md:73-82` ZERO-CANDIDATE FALLBACK + `synapse_suggest.py:357` | no |
| FL-06 | PR-116 single PR for 119 files | 🟩 closed — folded back to single PR-116 with manifest-undo (`04-log.md:1211-1219`) | no |
| FL-07 | Cold-start ranker undefined | 🟩 closed — `synapse_suggest.py:239` `is_cold_start` + frequency-prior bootstrap | yes implicitly: D-A09 baseline depends on warm data |
| FL-08 | requires-shadow detection ambiguous | 🟩 closed via domain-manifest (PR-106; RETRO claims PR-103) | no |
| FL-09 | Interrupt-gate × workflow undefined | 🟩 closed in orchestrator decide() | no |
| FL-10 | Grace-flag flip protocol vague | 🟩 closed — PR-112 itself was the dev-mode flip exemplar | no |
| OP-01 | Synapse metaphor inverted from biology | 🟩 closed pre-implementation by rename | partial: user-facing alias kept permanent (`_flaws.md:50`) |
| GAP-01..GAP-08 | misc remediation gaps | 🟧 spec-fixed; no open code defects (`_flaws.md:36-43`) | no |
| OP-03 | `meta` category overloaded | 🟩 closed — `layer:` axis | no |
| OP-04 | PR-108 modifies 174 files no rollback | 🟩 closed — `--rollback-per-file` undo path | no |
| **GAP-07** | Phase-4 ranker tuning needs labeled data | 🟥 open — explicit defer to next project | **YES → axon-autoimprove D-A13 (closed-loop) + D-A16 (auto-tune)** |
| **OP-02** | Linear ranker likely inadequate for nonlinear signals | 🟥 open — "measure linear first" | seeded but not picked up by autoimprove `_goal.md` non-goals: *"No ML / learned ranker"* (`axon-autoimprove/_goal.md:69`) |
| OP-01.X | `synapse` user-facing alias confusion | ⬛ wontfix permanent | n/a |

Mid-project flaws surfaced in `04-log.md`:
- **F-016** (`04-log.md:439`) — *medium* — phase-3 PRs touched `axon/` doc shims, violating "dev-mode required for PR-112 only". Mitigated by retro-relocating shims to workspace (`04-log.md:458-473`). Carried forward: no — closed in same session.
- **F-009** — drifting PR-review phase semantics (`04-log.md:343-345`). Carried forward: no — annotated only.

---

## 5. PR roster — shipped vs deferred

Source: `phases/3-implement/03-prs/pr-101..pr-120.md` and `04-log.md`. 20 shipped 0 dropped from the implementation roster; **the v1 plan said 28** (`masterplan.md:13`) — the 8 ghost PRs (PR-121..PR-128, PR-130..PR-132) were folded or deferred in phase-2 v1.1 remediation. Per `AUDIT.md:171-180` and `AUDIT.md:99-102`, RETRO's per-PR title table is wrong for 14/20 rows; the table below uses **actual git-log titles** from `AUDIT.md §2.1`, not RETRO's claims.

| PR | Actual title (git log) | Status | Landed | Key files | Follow-up |
|----|---|:---:|---|---|---|
| 101 | folded into 102 / `axon-cleanup` umbrella `b523de2` | ✓ folded | 2026-05-17 | spec only: `phases/2-design/specs/predicate-language-v1.1.md` | RETRO label wrong |
| 102 | predicate tool (parser + AST + evaluator) v1.1 | ✓ | 2026-05-18 | `tools/predicate.py` | — |
| 103 | goal tool + goal-schema-v1 template | ✓ | 2026-05-18 | `tools/goal.py` | — |
| 104 | neuron-contract → workspace docs; REGISTRY schema v1.1 | ✓ | 2026-05-18 | `workspace/docs/neuron-contract-v1.1.md`; `tools/REGISTRY.json` | — |
| 105 | workflow file v1 spec + schema + fixtures | ✓ | 2026-05-18 | `phases/2-design/specs/workflow-file-v1.md`, fixtures | — |
| 106 | domain manifest + reference manifests + validator | ✓ | 2026-05-18 | `workspace/domains/*/manifest.yml` | — |
| 107 | synapse-infer + synapse-validate (keystone) | ✓ | 2026-05-18 | `tools/synapse_infer.py:1`, `tools/synapse_validate.py:1` | — |
| 108 | domain folder scaffold + bulk metadata migration | ✓ | 2026-05-18 | `tools/migrate_synapse_blocks.py:1`; +6000 LOC across ~170 program files | F-016 fallout shims |
| 109 | synapse-suggest tool (orchestrator composition v1) | ✓ | 2026-05-18 | `tools/synapse_suggest.py:1-470` | — |
| 110 | DAG spec v1 + dag tool + nested-sync | ✓ | 2026-05-18 | `tools/dag.py:1-743` | — |
| 111 | orchestrator loop (program) | ✓ | 2026-05-18 | `workspace/programs/orchestrator.md:1-159` | tick-state leakage (live risk) |
| 112 | output-layer suggestions footer [dev-mode] | ✓ | 2026-05-18 | `axon/OUTPUT-LAYER.md:81-90` | only dev-mode write |
| 113 | plan_dag auto-emit hook | ✓ | 2026-05-18 | `workspace/programs/code-dev-plan.md` § DAG AUTO-EMIT | — |
| 114 | shadow enforcement gates (G2-G5) | ✓ | 2026-05-18 | `tools/shadow.py coverage`, `code-dev-knowledge-shadow.md` | G1 (author-time warn) deferred (`04-log.md:880`) |
| 115 | workflow lifecycle suite (new/run/list/edit/simulate/validate) | ✓ | 2026-05-18 | `workspace/programs/workflow-{new,run,list,edit,simulate,validate}.md` | this is where D-8/D-28 actually landed, NOT PR-117 |
| 116 | shadow retroactive bulk migration (plan/apply/undo) | ✓ | 2026-05-19 | `tools/shadow_retroactive.py:1` | — |
| 117 | alias canonicalization + finalize implementation | ✓ | 2026-05-18 | various aliasing fixes; **NOT the workflow generator** | RETRO label wrong (`AUDIT.md:99`) |
| 118 | reference workflows ship (3 code-dev + 1 library-dev + 1 cross-domain) | ✓ | 2026-05-19 | `workspace/domains/{code-dev,library-dev}/workflows/*.yml` | D-26 partial — library-dev only |
| 119 | axon-audit extension — synapse / shadow / demand rows (1c section) | ✓ | 2026-05-19 | `tools/axon_audit.py` 1c probes | < 5s budget scoped to 1c only |
| 120 | igap + auto-improve wire to synapse-suggest | ✓ | 2026-05-19 | `tools/igap.py signal` subcommand; `tools/synapse_suggest.py:202` `igap_signal`; `workspace/programs/auto-improve.md` § IGAP SIGNAL TAP | auto-improve orchestration **inert** — handed to axon-autoimprove |

**Dropped from masterplan, never spec'd:**
- PR-121..PR-128 — un-named v1 PRs, folded during v1→v1.1 remediation (`_meta.md` + `AUDIT.md:60-63`).
- **PR-130, PR-131, PR-132 — auto-improve loop**. Explicitly deferred per `RETRO.md:99` and `AUDIT.md:186`. PR-120 left the toggle (`L:auto-improve`) and cron stub but no orchestration. **This is the entire scope of `axon-autoimprove`.**

---

## 6. Infrastructure shipped — the "new AXON" capabilities

### CAP-01 — Synapse ranker

- **Original demand**: D-11 + D-21 + D-13 — *"Tools suggested based on goal + workflow"*; *"proper tool always gets suggested"*; *"after-X → suggest Y"*
- **Original PR**: PR-109
- **Implementation**: `tools/synapse_suggest.py:1-470`. Weights at `:42-53` (10 named signals: `intent 0.25 · dispatch 0.20 · usage 0.10 · pattern 0.10 · next_cond 0.15 · goal 0.20 · context 0.05 · drift 0.05 · shadow 0.10 · igap 0.10`). Additive vs subtractive split at `:56-57`. Six-level tie-break ladder at `:318` (FL-04). Cold-start branch at `:239` (FL-07). Zero-candidate caller-contract at `:357` (FL-05). `igap_signal` at `:202` (PR-120). Output schema returns `{name, score, reasons, signals}` (the "auditable signals" promise of D-11).
- **Where it's read from / written to**: read by `workspace/programs/orchestrator.md:70-71` (`TOOL(synapse-suggest, rank, --explain)`); read by `axon/OUTPUT-LAYER.md:86` via `W:orchestrator-last-tick`.
- **Reaches stated goal?**: ✓ fully for D-11 / D-13. 🟧 partially for D-21 (production hit-rate unmeasured; only fixture top-1).
- **Drift from original spec**: RETRO mock-up at lines 25-31 names **11** weighted signals including an explicit "cost penalty"; the code has **10 signals — no explicit `cost` signal**. The cost notion was folded into `context` (subtractive) during PR-109 implementation but the spec language (`phases/2-design/specs/orchestrator-composition-v1.md`) was never updated. Minor.
- **Open follow-up in axon-autoimprove**: D-A13 (closed-loop revert) + D-A16 (bidirectional auto-tune) target ranker stability, not the ranker itself.

### CAP-02 — Suggestions footer (output-layer)

- **Original demand**: D-23 (ADR-level: *"suggestion footer default"*, `_demands.md:507`) + D-30 (sideband in fixed-mode)
- **Original PR**: PR-112 (only dev-mode write in the entire project — `RETRO.md:118`)
- **Implementation**: `axon/OUTPUT-LAYER.md:81-90` § SUGGESTIONS FOOTER. Gated by `L:suggestions-enabled` (default `true`, `:85`). Sources from `W:orchestrator-last-tick` (`:86`). Drift suppression at `:88` (`drift.state ≡ "diverged" → sugg-on ← false`). Context-pressure collapse to top-1. Companion render in `workspace/programs/menu.md` (both compact + full blocks per `04-log.md:1334-1337`).
- **Where it's read from / written to**: reads `W:orchestrator-last-tick` (written by `orchestrator.md`); reads `L:suggestions-enabled`. Renders into every assistant response footer.
- **Reaches stated goal?**: ✓ fully.
- **Drift from original spec**: none significant. The dev-mode discipline that flipped back immediately after merge (`04-log.md:1390`) held.
- **Open follow-up in axon-autoimprove**: **PR-210 (optional)** in `axon-autoimprove/masterplan.md:48` — *"receipt line in OUTPUT-LAYER footer [dev-mode]"*.

### CAP-03 — Ephemeral suggestions (the temporary-suggestion pool)

- **Original demand**: D-10 + acceptance G7 — *"predetermined + mutable; ephemeral promotes to predetermined after N accepts"* (`04-log.md:32-33`)
- **Original PR**: ostensibly part of PR-109 / PR-111
- **Implementation**: **partial.** A `suggestion-promotion-threshold` setting is named in `RETRO.md:108`, but `grep -n "ephemeral\|promote\|promotion\|accept" tools/synapse_suggest.py tools/dispatch.py tools/dispatch_stats.py workspace/programs/orchestrator.md` returns only one stray hit (`synapse_suggest.py:120` in an unrelated `if`-form comment, and `orchestrator.md:121` in a string literal *"accept sideband"*). **No promotion counter, no threshold check, no fire-counting branch exists in code.**
- **Where it's read from / written to**: nowhere. The "ephemeral pool" never materialized as a data structure.
- **Reaches stated goal?**: ⊗ missing implementation; the goal was *recognised* (D-A14 in autoimprove inherits the definition) but the synapse-side wiring was zero.
- **Drift from original spec**: this is the **only acceptance criterion that was confidently checked ✓ in RETRO §What shipped but is actually 🟧 partial** — RETRO line 71 admits *"promotion threshold defined; production telemetry not yet collected"*. Independent re-check (`AUDIT.md:132`) downgraded it to 🟡.
- **Open follow-up in axon-autoimprove**: **D-A14** (`axon-autoimprove/_demands.md:36`) plus **PR-206** (`axon-autoimprove/masterplan.md:44`). Explicitly picked up.

### CAP-04 — DAG planning (`plan_dag.py` + `dag.py`)

- **Original demand**: D-2 (auto-DAG on plan) + D-3 (mutation) + D-4 (nested)
- **Original PR**: PR-110 (dag tool + spec) + PR-113 (plan-side auto-emit hook) + PR-118 (`pr_sync` mutation hook)
- **Implementation**:
  - `tools/dag.py:1-743` — synapse-shipped (`PR-110: DAG spec v1 + dag tool + nested-sync`, commit `a5249cf`). Subcommands: split/fold-in/set-status/render/verify/nested-sync (per `04-log.md:778`).
  - `tools/plan_dag.py:1-183` — header says **"PR-16.5 — Plan DAG emitter"** (`tools/plan_dag.py:2`). This **pre-dates synapse**. Synapse only added the *call site*.
  - PR-113 added `## DAG AUTO-EMIT (PR-113)` to `workspace/programs/code-dev-plan.md` (`04-log.md:972-974`).
- **Where it's read from / written to**: emits `phases/{n}/03-prs/DAG.{json,md}`; consumed by `code-dev-plan.md`, by `axon-audit.md` 1c section (PR-119), by this project's own `phases/2-design/03-prs/DAG.json`.
- **Reaches stated goal?**: ✓ fully for D-2/D-3/D-4 (nested-sync verified pinned).
- **Drift from original spec**: **forensic note** — the user-prompt outline framed `plan_dag.py` as a synapse capability. It is not synapse-authored; synapse *wired* an existing PR-16.5 tool. `tools/dag.py` (PR-110) IS new synapse code. Distinguishing the two matters for follow-on work.
- **Open follow-up in axon-autoimprove**: none. DAG is closed.

### CAP-05 — code-dev pseudo-state machine (`board.py` + state programs)

- **Original demand**: D-22 (*"pseudo state machine in which the next state (or tool) is inferred by AXON"*)
- **Original PR**: spec'd in `orchestrator-composition-v1.md` (phase 2); reference impl is the orchestrator (PR-111) itself
- **Implementation**:
  - `tools/board.py:1-76` — header at `:2` reads `"PR-20.6 — meta board ASCII Kanban over pr_aggregate (PR-9.5)"`. This **pre-dates synapse**.
  - `workspace/programs/code-dev-state*.md` — six pre-existing programs (state, state-save, state-resume, state-undo, state-status, state-handoff, state-metrics). `code-dev-state.md:5-21` carries a `# synapse:` block `inferred-by: synapse-infer (PR-108 bulk migration)` — meaning it was annotated by synapse but not authored by it.
  - `workspace/programs/orchestrator.md:39-159` — IS the pseudo-FSM reference implementation. OBSERVE→CANDIDATES→DECIDE→RECORD→ACT.
- **Where it's read from / written to**: `W:active-workflow-step`, `W:orchestrator-last-tick`, `W:current-goal`. No formal FSM dataclass — states are *implicit in workspace-state vectors* per D-22 spec.
- **Reaches stated goal?**: 🟧 partially. The "pseudo-FSM as workspace-state-vector" interpretation is realised in `orchestrator.md`. D-22's `synapse-fsm` reference impl with state→fire→post-state round-trip was never built as a separate artefact. The `code-dev-state*` programs and `board.py` are *adjacent* infrastructure, not the FSM itself.
- **Drift from original spec**: significant — the user's outline implied `board.py` was the pseudo-state-machine. `board.py` is a Kanban *renderer* (76 LOC) from the pre-synapse era and does not encode the FSM. The actual FSM-equivalent is `orchestrator.md`.
- **Open follow-up in axon-autoimprove**: none scoped. If anyone wants a formal FSM dataclass, it is unowned.

### CAP-06 — Drift gate (`drift.py` + classify thresholds)

- **Original demand**: not a synapse demand. Drift gate pre-existed (PR-012 — `git log` of `tools/drift.py` shows `7f64b1d feat(drift): gate decision + verify integration + menu badge (PR-012)`).
- **Original PR**: pre-synapse PR-012; synapse touched only the *integration* with the footer (PR-112).
- **Implementation**: `tools/drift.py:1-270`. `classify(score)` at `:98` returns `"stable" | "drift" | "diverged"`. Thresholds at `:198-203` (tightened from spec defaults 0.3/0.6). `gate()` at `:207-212` returns `{state, decision, modifier}` with `diverged → halt, -50`; `drift → warn, -30`; `stable → quiet, 0`. Read by `axon/OUTPUT-LAYER.md:15` (footer) and `:88` (suggestion suppression).
- **Where it's read from / written to**: produced by drift tool; consumed by output-layer (footer + suggestion gate) and by `orchestrator.md:52` (state.drift snapshot).
- **Reaches stated goal?**: ✓ fully (relative to synapse's actual scope: *wire drift into the suggestion path*).
- **Drift from original spec**: **forensic note** — the user-prompt outline credited synapse with the drift gate. **Synapse did not produce it.** Synapse only added the suppression rule at `OUTPUT-LAYER.md:88` and the `state.drift` snapshot at `orchestrator.md:52`.
- **Open follow-up in axon-autoimprove**: D-A03 (*"drift gate is absolute — blocks every auto-action"*, `axon-autoimprove/_demands.md:23`) + D-A19 (test asserting zero actions when diverged).

### CAP-07 — Orchestrator loop (`orchestrator.md`)

- **Original demand**: D-7 (adaptive orchestrator) + D-22 (pseudo-FSM)
- **Original PR**: PR-111
- **Implementation**: `workspace/programs/orchestrator.md:1-159` (RETRO claimed ~150; actual is 159). Section structure: IDENTITY LOCK (`:34-37`), OBSERVE (`:39-57`), CANDIDATES fixed/adaptive/free-text (`:59-71`), ZERO-CANDIDATE FALLBACK (`:73-82`), then per spec DECIDE → SIDEBAND → RENDER → RECORD → ACT.
- **Where it's read from / written to**: writes `W:orchestrator-last-tick` (`:28`); consumed by footer (CAP-02). Calls `synapse-suggest` (CAP-01), `dispatch` (CAP-09), `drift` (CAP-06), `context`, `usage`, `pattern` tools.
- **Reaches stated goal?**: ✓ fully.
- **Drift from original spec**: minor — 5 fixture sessions FX-001..FX-005 in `tests/synapse/sessions/` (`04-log.md:1273-1278`); spec called for >5. 20 replay tests T-111.1..T-111.8 parametrised (`04-log.md:1279-1281`).
- **Open follow-up in axon-autoimprove**: **AUDIT risk #2** — `W:orchestrator-last-tick` *persists across project swaps* and may show stale candidates from the prior project (`RETRO.md:117`, `AUDIT.md §7 item 2`). **Not picked up by autoimprove** (`grep` of autoimprove specs returns no mention of tick-state leakage). **Orphan risk.**

### CAP-08 — Telemetry counters (`usage.py`)

- **Original demand**: acceptance G10 (proxy metric), D-21 (hit-rate target)
- **Original PR**: pre-existing `tools/usage.py` (W2 bundle commit `182c483`); synapse only referenced it
- **Implementation**: `tools/usage.py:1-313`. Subcommands at `:271-304`: **`record`, `aggregate`, `top`, `suggest`, `prune`**. The acceptance criterion at `_goal.md:54` named `tools/usage.py find-program` as the proxy counter — **this subcommand is NOT present**. `grep "find-program\|find_program" tools/usage.py` returns zero matches.
- **Where it's read from / written to**: writes JSONL to `workspace/memory/longterm/usage-log.jsonl` (`:13-14`); read by `dispatch_stats.py:19`, by PR-119 audit, by PR-120 igap signal extraction.
- **Reaches stated goal?**: ⊗ missing for G10 as worded. The general usage counter exists; the *named subcommand the acceptance criterion bound the metric to* does not exist.
- **Drift from original spec**: **the cleanest documentary defect in the whole project.** Both `RETRO.md:74` and `AUDIT.md:135` claim *"`usage.py find-program` counter is in place but no baseline collected"*. The counter machinery is in place at the *generic record/top* level; the *named subcommand* is fictional. Acceptance #10's deferral status is therefore correct in outcome (no baseline captured) but wrong in cause (the proxy itself is missing).
- **Open follow-up in axon-autoimprove**: **PR-207** (`axon-autoimprove/masterplan.md:46` — telemetry baseline capture + monthly rotation, `E:baseline-YYYY-MM`). Picks up the spirit; will need to either build `find-program` or pick a different proxy.

### CAP-09 — Dispatch + dispatch-stats

- **Original demand**: not directly a synapse demand (the dispatch tool is pre-PR-014). Synapse used it as the FL-05 fallback target.
- **Original PR**: pre-existing — `tools/dispatch.py` is `30099d9 feat(dispatch): implicit feedback correlation + auto-tune toggle (PR-014)`; `tools/dispatch_stats.py` is `182c483 PR-15.5..25.5 ... W3 observability` — both **pre-synapse**.
- **Implementation**: `tools/dispatch.py:1-378` — `match --query --threshold`, `feedback --id --result yes|no`. Threshold from `dispatch-confidence` pref (default 0.65 — `:18-20, 149-152`). `feedback_log` at `:32` for accuracy stats. `tools/dispatch_stats.py:1-211` aggregates yes/no ratios and token savings.
- **Where it's read from / written to**: invoked from `orchestrator.md:76` as fallback; from `axon-audit.py` for dispatch-correctness; threshold tunable via `kv-store`.
- **Reaches stated goal?**: ✓ fully (relative to synapse's *use* of it).
- **Drift from original spec**: **forensic note** — the user outline credits synapse with dispatch. Synapse only composed it. The **bidirectional auto-tune** of the threshold (raise on neg-rate > 30%, lower on < 10%) that the user prompt hints at as "shipped by synapse" is **not implemented in dispatch.py**: only the static threshold + the toggle exist. The auto-tune logic is the explicit scope of axon-autoimprove (D-A16).
- **Open follow-up in axon-autoimprove**: **D-A16** (bidirectional threshold auto-tune, `_demands.md:39`) + **PR-204** (`masterplan.md:43`).

### CAP-10 — Output-layer receipt line ("auto-improve receipt" surface)

- **Original demand**: not a synapse demand. Implicit in PR-120 (`L:auto-improve` toggle).
- **Original PR**: PR-120 (toggle/stub only); receipt rendering NOT shipped.
- **Implementation**: **none.** Searching `axon/OUTPUT-LAYER.md` returns no `auto-improve` text. PR-120 wired the *signal source* into the ranker (`igap_signal`) and the cron stub but no receipt surface.
- **Where it's read from / written to**: n/a — does not exist.
- **Reaches stated goal?**: ⊗ missing — but it was never a synapse goal to begin with. The user-prompt outline pre-conjured a capability that synapse spec'd downstream.
- **Drift from original spec**: zero — the receipt was never in synapse scope; it's autoimprove scope.
- **Open follow-up in axon-autoimprove**: **PR-210 (optional)** (`axon-autoimprove/masterplan.md:48`).

### CAP-11 — Auto-improve hooks (inert, by design)

- **Original demand**: G7 (ephemeral promotion) was the closest stated demand; D-A* are the actual ADRs (in autoimprove).
- **Original PR**: PR-120
- **Implementation**: `L:auto-improve` toggle; cron stub registered; `tools/igap.py signal` subcommand; `workspace/programs/auto-improve.md` § IGAP SIGNAL TAP (`04-log.md:1068-1071`). **No orchestration body.**
- **Reaches stated goal?**: ⊗ missing (intentionally — handed to next project).
- **Drift from original spec**: documented. `AUDIT.md §7 item 5`: *"Auto-improve hooks are inert but present. If a future contributor flips `L:auto-improve = true` expecting it to do something, they will get the cron stub firing with no orchestration."* Recommended a WARN log on cron-entry-with-absent-target.
- **Open follow-up in axon-autoimprove**: **entire project**. `_goal.md:6-9` of autoimprove: *"closes the deferred items from axon-synapse: auto-improve loop (was PR-130-132 in synapse v1 plan, dropped from v1.1) + production telemetry baseline + ephemeral-suggestion auto-promotion."*

### CAP-12 — Caused-by-synapse extras

From scanning `04-log.md` + `03-prs/`:
- **Workflow lifecycle suite** (`workspace/programs/workflow-{new,run,list,edit,simulate,validate}.md` — PR-115) — the actual carrier of D-8 / D-28 (workflow generator).
- **Domain manifest + scaffold** (`workspace/domains/{code-dev,library-dev}/manifest.yml` — PR-106 + PR-108) — second-domain proof material.
- **Shadow retroactive bulk migration** (`tools/shadow_retroactive.py` — PR-116) — closed D-23 backwards-fill.
- **9-doc tier-A/B/C documentation seed** (`phases/2-design/docs/*` — phase-2 docs-plan unscheduled scope).
- **axon-audit 1c section** (`tools/axon_audit.py probe_synapse_coverage / shadow_coverage / demand_audit` — PR-119).

---

## 7. Drift from original intent (headline)

axon-synapse **shipped what it promised at the capability level** but the project did morph mid-flight in three distinct ways:

**Drift event 1 — biology rename (justified).** 
`04-log.md:97-101`: *"Biology-correct rename: neuron (was: synapse-as-node) / synapse (now: edge) / axon (still: the OS) … File renames deferred to PR-101a (cosmetic; non-blocking). 11 new ADRs (D-026..D-036)."* This was triggered by OP-01 (`_flaws.md:50`) during phase-2 tighten-to-flawless pass. **Justified** by D-026 (`_demands.md:430-448` — domain-agnostic vocabulary). The user-facing alias `synapse` was kept permanent (⬛ wontfix `_flaws.md:50`).

**Drift event 2 — PR roster 28 → 20 (justified).**
`AUDIT.md:25-27`: *"planned 28 PRs in 4 phases → 20 PRs in 3 phases (phase 4 / validate / retro folded into phase 3 close). PR-130-132 (auto-improve loop) explicitly deferred."* `04-log.md:232-237` shows the 02-plan moment when 20 PRs were locked. The 8 ghost PRs were folded/deferred during v1→v1.1 remediation, before phase-3 opened. **Justified** by D-035 (fold/split decisions). 

**Drift event 3 — RETRO.md per-PR title table is wrong for 14/20 rows (defect, not justified).**
`AUDIT.md:19-24, 71-95`: *"❗ Major finding: RETRO's per-PR title table is wrong for ~12 of 20 PRs."* The shipped capabilities are real, but the RETRO PR-number↔feature map is a documentary defect. Most notably:
- RETRO claims PR-117 = *"workflow-new generator"*; actual = *"alias canonicalization + finalize implementation"*. The workflow generator landed via PR-115 (`AUDIT.md:113`).
- RETRO claims PR-101 = *"predicate language v1.1 grammar"*; actual spec is `phases/2-design/specs/predicate-language-v1.1.md` and the tool shipped in PR-102 (`AUDIT.md:73`).

**Sub-drift — scope creep within PRs (mostly absorbed).** 
- PR-117 absorbed *"2 PR-108 fallout regressions"* (`04-log.md:632`).
- PR-119 scoped its <5s budget to the new 1c section only because pre-existing 1a/1b take ~27s on WSL bind-mount (`RETRO.md:100`).
- PR-120 added scope: was "igap" only, ended up wiring auto-improve.md tap (`04-log.md:1068-1071`).

**Sub-drift — F-016 mid-flight (phase-3 dev-mode integrity)**.
`04-log.md:425-433`: phase-3 PRs touched `axon/` doc shims, contradicting *"dev-mode required for PR-112 only"*. Mitigated by relocating shims to workspace (`04-log.md:463-469`). Self-corrected.

---

## 8. Deferred work — RETRO.md cross-check

Reproducing `RETRO.md:103-112`:

| Item | Where deferred-to | Picked up by autoimprove? | Citation |
|---|---|:---:|---|
| Production telemetry for ranker hit-rate | future dev-project | yes | `axon-autoimprove/_goal.md:36-37` (acceptance #6 — *"≥ 7 days of data; baseline persisted as E:baseline-YYYY-MM"*); PR-207 in `masterplan.md:46` |
| Promotion-from-ephemeral suggestion tracking | future dev-project | yes | `axon-autoimprove/_demands.md:36` D-A14 ("accept" definition) + PR-206 in `masterplan.md:44` |
| Manual-program-lookup baseline | future dev-project (proxy `usage.py find-program`) | yes-in-intent, with caveat | `axon-autoimprove/_goal.md:36-37` covers baseline capture, but the **named proxy subcommand does not exist** (see CAP-08); autoimprove will need to build it or substitute |
| Auto-improve loop (PR-130-132) | future dev-project | yes | `axon-autoimprove` is **the entire project** (`_goal.md:11`) — PR-201..PR-210 in `masterplan.md:39-49` |
| Second-domain proof (science-dev) | future dev-project | **no** | autoimprove `_goal.md:71` explicit non-goal: *"No second-domain proof (science-dev) — that's a separate future project."* **Orphan.** |
| Full-audit run on WSL perf optimization | tests skip full-suite budget | no | environmental; not a software issue; will not be picked up |

Additional carried-open from `_flaws.md:46-49`:
- **GAP-07** (Phase-4 ranker tuning labels) — picked up by D-A13 (closed-loop) in autoimprove.
- **OP-02** (linear ranker inadequate for nonlinear signals) — **NOT picked up**. `axon-autoimprove/_goal.md:69` is an explicit non-goal: *"No ML / learned ranker."* Defer-of-defer.
- **OP-01.X** (synapse alias permanent) — ⬛ wontfix forever; no follow-up needed.

**Net unaddressed surface after the handoff:**
1. Second-domain proof beyond library-dev (science-dev / study-dev). 
2. Nonlinear ranker (OP-02). 
3. Orchestrator-tick state leakage across project swaps (`AUDIT.md §7 item 2`). 
4. `usage.py find-program` subcommand never built (G10 proxy literal). 
5. Inference-mode behaviour matrix (D-12) — fully autonomous vs always-QUERY paths not exhaustively tested.

---

## 9. Audit checklist — `AUDIT.md` close-out findings

Reproducing `AUDIT.md:122-137` (Acceptance scorecard) + `AUDIT.md:200-208` (Lessons) + `AUDIT.md:214-229` (Risks) and recording status today:

| Finding | RETRO/AUDIT status | Status today | Picked up? |
|---|---|---|---|
| Acc #1 — findings catalog | ✅ | ✅ on disk | n/a |
| Acc #2 — synapse contract + ≥80% inference | ✅ | ✅ headers in `workspace/programs/` confirmed via PR-108 | n/a |
| Acc #3 — DAG central + nested | ✅ | ✅ `tools/dag.py:1-743` | n/a |
| Acc #4 — auto-DAG on plan + reversible | ✅ | ✅ via PR-113 hook into PR-16.5 emitter | n/a |
| Acc #5 — goal ledger live | ✅ | ✅ `orchestrator.md:41` reads `W:current-goal` | n/a |
| Acc #6 — suggestion engine 3 trigger paths | ✅ | ✅ ranker + loop + footer all on disk | n/a |
| **Acc #7 — ephemeral promotion** | 🟡 | 🟡 **still partial — code surface has zero promotion logic** (see CAP-03) | **yes — autoimprove D-A14 + PR-206** |
| Acc #8 — shadow mandatory | ✅ | ✅ PR-114 + PR-116 + 1c audit row | n/a |
| Acc #9 — workflow generator for ≥3 novel goals | ✅ | ✅ `workflow-new.md` (PR-115 not PR-117) | n/a |
| **Acc #10 — measurable lookup drop** | 🟠 deferred | **🟠 open + literal proxy missing** | yes — autoimprove PR-207 (with caveat from CAP-08) |
| **R1** — RETRO per-PR titles wrong | recommendation | **not corrected** | not picked up — recommend fix in autoimprove kickoff |
| R2 — open auto-improve dev-project | recommendation | ✅ done (`axon-autoimprove` exists) | yes |
| R3 — capture baseline 7d of normal use | recommendation | open | yes — autoimprove #6 |
| R4 — wire ephemeral auto-promotion | recommendation | open | yes — autoimprove PR-206 |
| R5 — `code-dev-retro` git-log cross-check | recommendation | open | not picked up |
| R6 — WARN if `L:auto-improve=true` with no orchestration | recommendation | open | implicit-yes — autoimprove makes orchestration concrete |
| R7 — `code-dev-axon-synapse-v2` (long-term) | recommendation | open | not picked up |
| **Risk 1** — cold-start fragility | live | live | mitigated by 1c audit row |
| **Risk 2** — orchestrator-tick state leakage | live | live | **NOT picked up — orphan** |
| Risk 3 — dev-mode unflip discipline | live but OK | OK | held |
| Risk 4 — RETRO mislabel defect | new | open | not picked up |
| Risk 5 — auto-improve hooks inert | new | now scoped to autoimprove | yes |

---

## 10. Original-goal scorecard

**G1** — Findings catalog complete for every program + tool.
- Status: ✓ MET
- Evidence: `phases/1-study/helpers/tool-catalog.md` (75/75 tools); 17 findings under `phases/1-study/findings/`; programs catalogue absorbed into PR-108 bulk infer.
- Gap: none.
- Picked up by autoimprove? n/a.

**G2** — Synapse contract spec'd; inference for ≥80% of programs.
- Status: ✓ MET
- Evidence: `phases/2-design/specs/synapse-contract-v1.md`; `tools/synapse_infer.py:1-381`; `tools/migrate_synapse_blocks.py:1-173` (PR-108) inserted `# synapse:` block in ~170 program files.
- Gap: none.
- Picked up by autoimprove? n/a.

**G3** — DAG central at every level + nested consistency.
- Status: ✓ MET
- Evidence: `tools/dag.py:1-743` (nested-sync subcommand); `phases/2-design/03-prs/DAG.json` proves the project ate its own dog food.
- Picked up by autoimprove? n/a.

**G4** — Auto-DAG on plan; mutation on merge/split/fold/defer/cut; reversible.
- Status: ✓ MET
- Evidence: PR-113 hook (`workspace/programs/code-dev-plan.md § DAG AUTO-EMIT`); `tools/dag.py` mutator subcommands; PR-118 `pr_sync` hook.
- Picked up by autoimprove? n/a.

**G5** — Goal ledger live; no dispatch bypasses goal-existence.
- Status: ✓ MET
- Evidence: `tools/goal.py` (PR-103); `workspace/programs/orchestrator.md:41` `RETRIEVE(W:current-goal)` in every tick; OBSERVE step writes it into state vector at `:47-57`.
- Picked up by autoimprove? n/a (autoimprove inherits D-007 — `_demands.md:11`).

**G6** — Suggestion engine on completion + state delta + free text.
- Status: ✓ MET
- Evidence: ranker (`synapse_suggest.py:338` `rank()`), orchestrator (PR-111), footer (PR-112). Three trigger paths confirmed at `AUDIT.md:131`.
- Picked up by autoimprove? n/a.

**G7** — Predetermined-or-ephemeral; ephemeral promotes after ≥ N accepts.
- Status: ↻ DEFERRED (partial-then-deferred)
- Evidence: predetermined ✓; ephemeral pool ⊗ missing in code (see CAP-03). RETRO acknowledges (`:71`), AUDIT confirms (`:132`).
- Gap: Zero promotion-counter logic in `synapse_suggest.py`. The N=5 threshold (D-21) was specced but never read in code. No fire-counting branch.
- Picked up by autoimprove? **yes — D-A14 (autoimprove `_demands.md:36`) + PR-206 (`masterplan.md:44`)**. Note: autoimprove redefined "accept" precisely (within-1-hour invocation) to close the ambiguity flagged in audit.

**G8** — Shadowing mandatory + enforced; `code-dev audit` FAILs if absent.
- Status: ✓ MET
- Evidence: PR-114 gates G2-G5 (`tools/shadow.py` `coverage`); PR-119 1c audit row probes via subprocess; PR-116 retroactive migration sealed historic gap. G1 (author-time warn) explicitly deferred per `04-log.md:880`.
- Picked up by autoimprove? n/a — but D-A11 in autoimprove inherits the audit-row schema.

**G9** — Workflow generator composes ≥ 3 novel goals.
- Status: ✓ MET
- Evidence: `workspace/programs/workflow-new.md` (PR-115 lifecycle suite, **not PR-117** — `AUDIT.md:113`). 5 reference workflows in `workspace/{domains,workflows}/` (PR-118). 22 tests T-118.1..T-118.5 (`04-log.md:1022-1025`). Exceeded the ≥3 target.
- Picked up by autoimprove? n/a.

**G10** — Phase-4 retro shows measurable drop in manual program lookup (proxy `tools/usage.py find-program`).
- Status: ⊗ MISSED (deferred + proxy literal missing)
- Evidence: `tools/usage.py:271-304` shows subcommands `record / aggregate / top / suggest / prune` — **no `find-program`**. RETRO and AUDIT both say "counter wired"; the *generic* counter is wired, but the *named subcommand the criterion bound to* is fictional.
- Gap: To honour the criterion literally, axon-autoimprove must either (a) add a `find-program` subcommand to `tools/usage.py`, or (b) re-bind the criterion to an existing subcommand (`top --kind program` is the closest fit).
- Picked up by autoimprove? **yes — PR-207** (`axon-autoimprove/masterplan.md:46`), with the caveat that the literal-proxy bug is not called out and may carry through if not surfaced.

---

## 11. What the new AXON actually IS today

In one paragraph, jargon-free: AXON now watches what the user does and what tools exist, ranks the ten or so most relevant next moves by a transparent, additive scoring function with deterministic tie-breaking, and shows the top three at the bottom of every response unless the model is drifting off-track or the context window is full. The user can run workflows in either a fixed step-by-step mode or an adaptive "you describe, AXON proposes" mode. Every step belongs to a goal, every plan has a dependency graph, every source-touching change leaves a shadow record, and a single audit command can answer "are all of those true right now?". The kernel was protected: only one edit (`axon/OUTPUT-LAYER.md`) crossed the dev-mode line.

In one paragraph, what's still missing relative to the original vision: the system does not learn from its own usage yet — no ephemeral suggestion ever earns its way into the permanent pool, no dispatch threshold auto-tunes, and no telemetry baseline has been captured to even measure whether the suggestions are actually reducing the user's manual-lookup burden. Second-domain proof beyond `library-dev` (no science-dev, no study-dev) is unbuilt. The pseudo-state-machine D-22 promised lives as code-flavoured prose in `orchestrator.md` rather than a formal FSM. And tick-state can leak across project swaps. Most of that is the formally-handed-off scope of `axon-autoimprove`; the second-domain proof and the tick-state leakage are not, and are the two real orphans.

---

## 12. Lessons learned

- **Composition-only ranker extensions are the right shape.** Every signal (`intent` … `igap`) is a pure function `(state, candidate) → float`; adding signal #11 (`igap`, PR-120) was 1 weight line + 1 function + 1 STORE call in `auto-improve.md` (`04-log.md:1062-1071`). Reuse this pattern.
- **RETRO authoring needs a `git log` cross-check.** 14/20 PR-titles in `RETRO.md:36-57` are wrong; capabilities are right but the map is broken (`AUDIT.md:19-24`). Add a `git log --oneline --all` diff step to retro authoring.
- **Naming a proxy metric without building it is worse than not having a metric.** Acceptance G10 cited `tools/usage.py find-program`; the literal subcommand was never built and the lie carried into RETRO + AUDIT. Either build the named API or re-bind the criterion before close.
- **Fold-back is cheap when the spec is clear.** PR-116a..f → PR-116 (single, with manifest-undo) merged with no rework because `shadow-enforcement-v1.md` was already specific (`RETRO.md:122`). Worth preserving the recipe.
- **Dev-mode single-gate discipline holds at scale.** 19 of 20 PRs touched workspace/tools/tests/my-axon only; PR-112 was the lone `axon/` write and flipped back immediately (`04-log.md:1390`). R9 survived a 20-PR phase intact.
- **Ship the orchestration when you ship the toggle.** PR-120 shipped `L:auto-improve` and a cron stub but no body; that "inert hook" became risk #5 in the audit (`AUDIT.md:226-229`). Pair toggle+body or WARN loudly.

---

## 13. Direct linkage to axon-autoimprove

| Gap from §10 | Covered in autoimprove? | Citation |
|---|:---:|---|
| G7 — ephemeral promotion missing | ✓ | `axon-autoimprove/_goal.md:32-35` (acceptance #3); D-A14 (`_demands.md:36`); PR-206 (`masterplan.md:44`) |
| G10 — manual-lookup baseline | ✓ (with caveat: literal proxy subcommand still missing) | `axon-autoimprove/_goal.md:36-37` (acceptance #6); PR-207 (`masterplan.md:46`) |
| GAP-07 — ranker tuning labels | ✓ | D-A13 closed-loop (`_demands.md:35`); D-A16 bidirectional auto-tune (`_demands.md:39`); PR-204 (`masterplan.md:43`) |
| OP-02 — linear ranker inadequacy | ⊗ orphan | `axon-autoimprove/_goal.md:69` explicit non-goal *"No ML / learned ranker"* |
| Second-domain proof (science-dev) | ⊗ orphan | `axon-autoimprove/_goal.md:71` explicit non-goal *"No second-domain proof"* |
| Risk 2 — tick-state leakage across projects | ⊗ orphan | not mentioned in any of autoimprove `_goal.md` / `_demands.md` / `masterplan.md` |
| Risk 4 — RETRO mislabel defect | ⊗ orphan | not picked up; would be a process fix, not a code fix |
| D-12 — pop-up question inference-mode matrix | ⊗ orphan | not picked up |
| D-22 — formal pseudo-FSM reference dataclass | ⊗ orphan | not picked up |

**Three categorical orphans after handoff:**
1. Anything requiring nonlinear ranker work (OP-02).
2. Anything requiring a non-code domain (D-26 beyond library-dev).
3. Anything in the operational hygiene class (tick leakage, RETRO mislabel cross-check, inference-mode matrix, formal FSM artefact).

---

## 14. Executive summary

*(reprinted at top as TL;DR)*

axon-synapse shipped the *mainline composition path* it set out to build — `synapse-suggest.rank()` → `orchestrator.md` → `OUTPUT-LAYER` suggestions footer — anchored by 20 merged PRs (PR-101..PR-120) over a 2-day implementation phase. Eight of ten acceptance criteria are independently verifiable on disk (ranker, footer, DAG, goal-ledger, shadow enforcement, workflow generator, suggestion engine, synapse contract). **Two are not**: ephemeral-suggestion auto-promotion (acceptance #7) was never wired in `tools/synapse_suggest.py`, and the manual-program-lookup baseline (acceptance #10) cannot be captured because the proxy counter `tools/usage.py find-program` *does not exist as a subcommand* — only `record/top/suggest/prune/aggregate` are wired (`tools/usage.py:271-304`). The audit (`AUDIT.md`) flagged the documentary defect that RETRO mislabels 14 of 20 PR titles; this study confirms it and adds one capability-level drift: **several pieces the user's outline framed as "synapse-produced infrastructure" — `dispatch.py` (PR-014), `drift.py` (PR-012), `board.py` (PR-20.6), `usage.py` (W2 bundle), `plan_dag.py` (PR-16.5) — are pre-synapse code that synapse only *wired into* the composition path**. The de-facto handoff to `axon-autoimprove` covers the two formal gaps (#7, #10) explicitly, but does not pick up the orchestrator-tick state-leakage risk (`AUDIT.md` §7 item 2). The auto-improve loop itself (originally PR-130-132) was an explicit deferral, and is the entire raison d'être of the successor project.
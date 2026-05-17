# Implementation Log — AXON Synapse

## SESSION START — 2026-05-17T15:14:00Z
project:        axon-synapse
phase:          1-study
workflow-step:  study
branch:         main

## Entries

### 2026-05-17 — project bootstrapped
- v4 scaffold written.
- Vision captured: programs = synapses, AXON = adaptive orchestrator.
- User directive (post-scaffold): "identify workflow → user has task → understand
  → dispatch proper tools → adapt on the way → AXON signals and routes to other
  tools." Code-dev has a fixed hierarchy today; goal is adaptive routing on top.
- Pre-study state: 174 programs, 69 tools, 5 active dev-projects, no goal-ledger,
  no dispatch suggester, no auto-DAG, no workflow generator.

### 2026-05-17 — design-fork answers locked
- OQ-01 → D-005: Synapse contract = hybrid (inferred + declared override).
- OQ-02 → D-007: Goals always exist. Workflow-bound vs user-stated dual mode.
- OQ-04 → D-006: DAG persistence = both DAG.json + DAG.md, sync-checked.
- OQ-09 → D-008: Study depth = most detailed, no cap.
- _goal.md written (project-level goal per D-007).
- Remaining open questions: OQ-03, OQ-05, OQ-06, OQ-07, OQ-08, OQ-10 — can be
  resolved during/after study without blocking T-A start.

### 2026-05-17 — vision deepened
- D-009: DAG is the central organizing primitive at every level (project, phase,
  plan, PR, study). Nested DAGs allowed; sync-checker validates child-parent.
- D-010: Suggestion firing — state-driven, predetermined + mutable, ephemeral
  promotes to predetermined after N accepts.
- D-011: Shadowing is mandatory; orchestrator-enforced at pr-finalize + audit.
- 01-study.md extended: Q11 (nested DAGs), Q12 (shadow enforcement), Q13
  (suggestion mechanics). T-G track added for shadow.
- _goal.md acceptance criteria expanded for D-009/D-010/D-011.

### 2026-05-17 — T-A batch 1 (tool inventory pass) ✓
- REGISTRY.json enumerated: 75 tools total, 69 ACTIVE + 6 OPTIONAL.
- Caller-count built by grep across workspace/programs/*.md → tool-catalog-raw.json.
- tool-catalog.md (15.7 KB) rendered with 6 category sections + zero-caller table
  + top-20-by-caller table.
- 5 findings written:
    F-001 (high)   — 31/75 tools have zero program-callers; invocation-source missing.
    F-002 (medium) — REGISTRY 75 vs boot 69 — OPTIONAL invisible to user.
    F-003 (medium) — Single-member categories suggest ad-hoc taxonomy; multi-axis needed.
    F-004 (low)    — Top-20 tools = AXON's "core call surface" — migration anchor.
    F-005 (high)   — Zero synapse-contract declarations today; BLOCKER for orchestrator.
- INDEX.md regenerated.
- CHECKPOINT.

### 2026-05-17 — Phase 1 closed · Phase 2 opened · 10 specs + plan + PR list + DAG written
- User: "carry phase 2" — implicit sign-off on Phase 1 synthesis.
- Phase 1 closed: status=complete in phases/1-study/_meta.md.
- Project _meta.md: phase=2-design, workflow-step=design.
- Phase 2 scaffold: _meta.md (with goal block), _files.md, _dont-do.md,
  _decisions.md, _deviations.md, reviewer-state.md, specs/, findings/, 03-prs/.

- **10 Phase-2 specs authored:**
   1. specs/SYNAPSE-GLOSSARY.md             — singular vocabulary (Q15.1 lock)
   2. specs/synapse-contract-v1.md          — F-005/F-013 BLOCKER resolved
   3. specs/workflow-file-v1.md             — Fixed/Adaptive/Hybrid execution-mode
   4. specs/goal-schema-v1.md               — schema + predicate language v1
   5. specs/domain-manifest-v1.md           — code-dev + library-dev reference
   6. specs/dag-spec-v1.md                  — 5 levels + sync (D-009)
   7. specs/orchestrator-composition-v1.md  — combiner formula over existing tools
   8. specs/shadow-enforcement-v1.md        — 5 gates + retroactive migration
   9. specs/conversational-author-v1.md     — workflow-new dialog flow
  10. specs/migration-plan-v1.md            — 20-PR Phase-3 sequencing

- **02-plan.md + 02-prs.md authored** — 20 PRs (PR-101..PR-120) +
  4 Phase-4 candidates (PR-150..PR-153).

- **03-prs/DAG.json + DAG.md** — plan-level DAG with 20 nodes, 30 edges,
  critical path (8 hops: PR-101 → PR-104 → PR-107 → PR-109 → PR-111 →
  PR-112 → PR-119 → PR-120). Validated acyclic by hand (Kahn).

- **8 new ADRs (D-018..D-025):**
   D-018 glossary-singular  · D-019 DAG.md one-way  · D-020 infer-first
   D-021 ranker rule-based   · D-022 shadow-grace flag · D-023 suggestion footer
   D-024 workflow-compile=P4 · D-025 phase-1 single gate (this sign-off)

- **Demand status:** 21 demands moved to 🟨 designed
  (was 4 designed; now 25 designed/in-progress out of 30; 5 still open
  pending Phase 4 measurements).

- **Masterplan updated:** phase 1 ✓; phase 2 ✓; phase 3/4 ⬜.
- CHECKPOINT.

### 2026-05-17 — auto-converge pass · T-F, T-E, T-G, T-C, workflow-catalog, synthesis
- **T-F (suggestion-engine prior-art):** mode-detect, mode-router, dispatch,
  pattern, prompt-log, usage, drift, events, context, find-program,
  register-tool — substrate exists. F-014 (medium, positive) — orchestrator
  = composition of existing kernel tools, not greenfield.
- **T-E (DAG inventory):** plan_dag.py + 3 dev-projects have plan-level DAGs
  (manual today). F-015 (high) — 4 of 5 D-009 levels missing
  (project / phase / PR / study DAGs not auto-generated).
- **T-G (shadow audit):** shadow tool is full-featured (content-addressed,
  hash-matched, append-only); 0 / 119 PRs have shadow files across all
  dev-projects. F-016 (high) — D-23 enforcement is critical because
  current coverage is 0 %. `code-dev-shadow` is also a DEPRECATED ALIAS
  (per F-012 pattern; canonical = `code-dev-knowledge-shadow`).
- **T-C (goal derivation):** F-017 (medium) — proposed goal schema:
  per-level (project/phase/workflow/step/PR/finding/demand), structured
  YAML, predicate language for measurement + acceptance-criterion.
  Resolves OQ-07.
- **T-B (workflow catalog):** helpers/workflow-catalog.md compiled —
  6 observed workflows (code-dev, library-dev, PR-review, igap, auto-actions,
  boot, workspace-backup) + 5 plausible workflows (python-code-dev, cpp,
  study-dev, science-dev, adaptive-free-text). Workflow file template
  authored as Phase 2 input.
- **Synthesis draft written** — phases/1-study/synthesis-draft.md.
  Recommends Phase 1 sign-off. Phase 2 design queue ordered.
- All 7 tracks now have ≥ 1 finding. D-15 synthesis condition met.
- INDEX.md regenerated — 17 findings (high=9, medium=7, low=1).
- CHECKPOINT.

### 2026-05-17 — registration + fixed/adaptive modes + canonical code-dev FSM walk
- D-016 (registration is first-class): new synapses (tools/programs) and new
  workflows are runtime-registrable; workflows authorable directly OR via
  conversational dialog ("describe in plain English → AXON infers synapses").
- D-017 (Fixed vs Adaptive workflow modes): every workflow declares
  `execution-mode: fixed | adaptive | hybrid`. Fixed = predeclared synapse
  sequence walked step-by-step. Adaptive = orchestrator picks per state.
  Hybrid = per-step. **Suggestions stay live in fixed mode** — sideband
  + deviation-suggestion semantics — never overriding the path silently.
- 4 new demands: D-27 register new synapses · D-28 conversational workflow
  author · D-29 fixed/adaptive modes · D-30 suggestions live in fixed mode.
  Demand total: 30. Ledger updated.
- 01-study.md extended with Q16 (registration) + Q17 (fixed/adaptive UX).
- Canonical code-dev FSM walked: study, plan, safety-audit, load, finalize,
  pr-create. helpers/code-dev-canonical-fsm.md written.
- Major discoveries:
    · `code-dev-audit` and `code-dev-pr` are DEPRECATED ALIASES.
    · `code-dev-finalize` is an ORPHAN STUB (PR-119 follow-up never finished).
    · `code-dev-study` and `code-dev-plan` are RICHLY PARAMETERIZED
      (--mode, --target, --output, --input, --budget, --rule).
    · `code-dev-study` declares an EXPLICIT ACCEPTANCE PREDICATE inline:
      "Phase ends when both user and AXON rate satisfaction ≥ 7."
      First first-class goal-completion gate found.
- F-012 (high) — Three code-dev entry verbs are aliases/orphan stubs;
  documented chain partially fictional; backwards-compat (D-25) requires
  preserving them but their "removed next release" markers are latent risks.
- F-013 (high) — Programs are already parameterized synapses; contract
  schema must capture `modes`, `acceptance-predicates`, `output-variants`,
  `accepts-input-stream`, `accepts-runtime-rules`. Schema is parameterized,
  not single-shape.
- INDEX.md regenerated — 13 findings (high=7, medium=5, low=1).
- CHECKPOINT.

### 2026-05-17 — T-A batch 2 follow-on · code-bias scan + library-dev walk
- Code-bias scan over `axon/*.md`, `axon/core/*.md`, `axon/programs/*.md`:
  KERNEL-SLIM=19 hits (LOW leak — mostly self-ref + anti-coupling rules),
  DEVELOPER=6 (LOW), COMMANDS=1, core/LANG=2, core/TRANSLATE=0, BOOT=0,
  OUTPUT-LAYER=0. Net: kernel is structurally domain-agnostic.
- Library-dev walk: all 9 programs catalogued. Kernel-op parity with code-dev
  confirmed. Container parity confirmed. Workflow shape parity confirmed.
  Differences are legitimate (no PR/DAG/git in libraries) — not deficiencies.
- helpers/code-bias-scan.md + helpers/library-dev-fsm.md written.
- F-010 (medium, positive) — Kernel is already domain-agnostic; D-015
  generalization is schema-work, not surgery.
- F-011 (medium, positive) — Library-dev is a working non-code workflow;
  multi-domain DNA validated; recipe for `science-dev` / `study-dev` clear.
- INDEX.md regenerated — 11 findings (high=5, medium=5, low=1).
  Tone: 9 problems · 2 positive validations.
- CHECKPOINT.

### 2026-05-17 — study phase 2 + workflow-OS generalization + PR-review FSM walk
- D-014 (preserve current code-dev hierarchy; never break it).
- D-015 (AXON Synapse is a workflow OS — code is one domain among many).
- _demands.md written — 26 demands, each with goal + measurement + audit-criterion
  (D-1..D-26). Per D-7, every demand is now auditable.
- _goal.md updated — generalization to workflow OS captured; non-goal "no
  code-specific kernel concepts" added.
- 01-study.md extended with Q15 (workflow OS generalization: glossary,
  code-bias sweep, domain folders, science-dev / study-dev sketches).
- F-008 (high) — Code-dev is one domain; kernel vocabulary must be
  domain-agnostic. Library-dev already proves multi-domain DNA.
- helpers/pr-review-sub-fsm.md — analysis of master vs split scaffolds, phase
  semantics drift, cd_cache as state substrate, EMIT(code-dev.pr.review.phase)
  as orchestrator hook point.
- F-009 (high) — Two PR-review implementations exist with drifting phase
  semantics. Master P5=Rebase vs stub P5=tests. Canonicalization needed
  before contract migration.
- INDEX.md regenerated — 9 findings (high=5, medium=3, low=1).
- CHECKPOINT.
- Next: T-A continuation — sweep workspace/programs/ for code-bias terms;
  audit cd_cache as candidate state-substrate; sample more of code-dev
  family (study, plan, audit, finalize) to extract their FSM shape.
- D-012: Regression-safe — no tests break, new tools in REGISTRY auto-suggestable.
- D-013: Synapse model = pseudo-FSM (states = workspace state vectors;
  synapses = transitions; non-deterministic; pseudo because failures observed
  as states, not contract violations).
- 01-study.md extended with Q14 (workflow-completion chains).
- Major discovery (F-006 high): ≥ 36 workflow-completion programs already
  exist (review, audit, test, shadow, impact, reviewer-track, etc.).
  Orchestrator wiring is the missing piece, not the programs themselves.
  Phase 3 scope is smaller than expected — author contracts for the
  workflow-chain subset first, bulk-migrate the rest later.
- F-007 (medium): `code-dev-knowledge-X` variant pattern; role taxonomy
  needed (mutator vs reader vs gate vs renderer).
- INDEX.md regenerated — 7 findings (high=3, medium=3, low=1).
- CHECKPOINT.
- Next: walk `code-dev-pr-review.md` + 9 phase files → extract de-facto FSM,
  document as `helpers/pr-review-sub-fsm.md`. This is the highest-yield
  learning before the synapse contract spec is written.

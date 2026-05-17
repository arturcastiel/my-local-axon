# Demand ledger — axon-synapse

> Per user directive 2026-05-17: "add clear goals for each demand so we can
> audit it later." Every stated demand becomes a row here with goal + measurement
> + audit criterion. Linked to decisions (D-NNN) and findings (F-NNN).
> Audited at the end of every phase; carried into Phase 4 retro.

## Status legend

| Symbol | Meaning |
|--------|---------|
| ⬜ open       | demand recorded, no work yet |
| 🟦 in-progress | study/design under way |
| 🟨 designed   | acceptance criteria locked, awaiting implementation |
| 🟩 met        | shipped + verified against audit criterion |
| ⬛ deferred   | explicitly punted to later project |

## Source-message references

- `M1` — 2026-05-17, project kickoff: "axon has reached a very good stage … audit what we have, what works fine and what could be better"
- `M2` — 2026-05-17, mid-kickoff: "identify workflow — user has a task, you try to understand, and dispatch proper tools — code-dev has already this fixed — but I want something that adapts on the way"
- `M3` — 2026-05-17, after fork answers: "find the best — in addition in code-dev each phase must have a graph in case multiple tools or phases are used"
- `M4` — 2026-05-17, post-batch-1: "find the best — after developing, for instance, a build mode would be suggested … no tests should break … maybe a pseudo state machine"
- `M5` — 2026-05-17, this turn: "study phase 2 — keep studying make the study more detailed — add clear goals for each demand so we can audit it later"

---

## Ledger

### Demand D-1 · Full audit of current AXON state
- **Source.** M1: "audit what we have, what works fine and what could be better, all tools, study"
- **Goal.** Every tool (75) and every program (174) is classified, with status,
  caller graph, redundancy markers, and gap markers, by end of Phase 1.
- **Measurement.** `phases/1-study/helpers/tool-catalog.md` has 75/75 rows;
  `phases/1-study/helpers/program-catalog.md` has 174/174 rows; finding count
  ≥ 30 across T-A + T-B; INDEX.md regenerated.
- **Audit criterion.** Coverage = 100 % on both catalogs. Any tool/program
  missing a classification row blocks Phase 1 sign-off.
- **Linked.** F-001 F-002 F-003 F-004 F-005 F-007. D-008 (study depth).
- **Status.** 🟦 in-progress (75/75 tools catalogued; 0/174 programs).
- **Phase target.** Phase 1.

### Demand D-2 · DAG auto-creation on plan generation
- **Source.** M1: "I want by default DAG be created once every plan is generated"
- **Goal.** Every successful `code-dev plan` run emits `phases/{n}/03-prs/DAG.json`
  and `phases/{n}/03-prs/DAG.md` automatically. The user never has to run a
  separate DAG-emit step.
- **Measurement.** Audit every project in `my-axon/dev-projects/` after the
  rollout: each plan'd phase has both files. `code-dev plan` test simulates run
  on a fixture and asserts file existence + parse success.
- **Audit criterion.** ∀ project. ∀ phase with `02-plan.md`. (∃ DAG.json AND ∃ DAG.md
  AND parse(DAG.json) succeeds AND md/json reconcile).
- **Linked.** D-006 D-009. Q8 Q11. F-005.
- **Status.** ⬜ open.
- **Phase target.** Phase 3 (impl). Phase 2 spec'd.

### Demand D-3 · DAG auto-mutation on merge/split/fold-in
- **Source.** M1: "the dag must be modified once operations such as merged, split take place"
- **Goal.** Every program that mutates the PR set (`code-dev-combine`,
  `code-dev-divide`, fold-in, defer, cut, rename-pr) updates DAG.json + DAG.md
  in the same atomic operation. No drift possible between the markdown plan and
  the DAG file.
- **Measurement.** Test fixture: run `code-dev-combine PR-1 PR-2`, assert DAG
  reflects merged node + edges. Drift-detector (`dag-sync`) reports 0
  inconsistencies after each mutation in a 10-mutation fuzz test.
- **Audit criterion.** After every mutation: `dag-sync verify` returns ✓.
- **Linked.** D-006 D-009. Q8.4 Q8.5.
- **Status.** ⬜ open.
- **Phase target.** Phase 3. Mutator-list inventory in T-B (pending).

### Demand D-4 · DAG central at every level (nested)
- **Source.** M3: "in code-dev each phase must have a graph … a dag for a study
  with multiple layers — but for development — a dag for several phases — and a
  dag for several prs — they can be nested if needed — and dag MUST BE CENTRAL"
- **Goal.** Every level produces a DAG: project (phase graph), phase (sub-step
  graph), plan (PR graph), PR (sub-task graph), study (Q→track→finding graph).
  Nested DAGs validated by `dag-sync`: child-DAG nodes ↔ parent-DAG edges.
- **Measurement.** v5 schema (Phase 2) defines DAG file requirements per level.
  `code-dev audit` extension reports DAG coverage % per project; target 100 %.
- **Audit criterion.** ∀ project. coverage(DAG) == 100 % AND nested-consistency
  check passes.
- **Linked.** D-009. Q11. F-005 (blocker — needs synapse contract first).
- **Status.** ⬜ open.
- **Phase target.** Phase 2 spec, Phase 3 impl.

### Demand D-5 · Report on possible uses + workflows of AXON tools
- **Source.** M1: "I want a report on possible uses and different workflows
  that axon tools can be used"
- **Goal.** Phase 1 produces `helpers/workflow-catalog.md` listing every
  observed workflow + every plausible-but-unobserved workflow derivable from
  the tool/program graph. Each entry has: trigger, body, terminator, example.
- **Measurement.** Catalog has ≥ 1 entry per code-dev family flow (study, plan,
  pr-cycle, audit, finalize, shadow), ≥ 1 per library-dev family, ≥ 1 per
  meta workflow (axon-audit, igap-improve, auto-improve).
- **Audit criterion.** Manual review by user signs off catalog completeness.
- **Linked.** Q5. F-006.
- **Status.** ⬜ open. Inputs partly available (F-006 surfaced 36 chain programs).
- **Phase target.** Phase 1 ships v1; Phase 4 updates from lived data.

### Demand D-6 · Synapse metaphor — programs are synapses, AXON orchestrates
- **Source.** M1: "I see each axon program as a synapse, and axon orchestrates"
- **Goal.** Every program (174) and every callable tool (75) carries a
  synapse contract: precondition, inputs, outputs, post-state, next-conditional,
  cost, goal-advances. Hybrid: inferred default + declared override.
- **Measurement.** Coverage % of programs with synapse-contract metadata. Target
  ≥ 80 % at Phase 3 close (D-005). Inference engine (`synapse-infer`) accuracy
  ≥ 90 % on a 20-program manual-spot-check.
- **Audit criterion.** Programs missing contract metadata get flagged by
  `axon-audit`. List of unmigrated programs ≤ 20 % of total.
- **Linked.** D-005 D-013. F-005 (blocker). Q6.
- **Status.** ⬜ open. Schema unauthored.
- **Phase target.** Phase 2 schema, Phase 3 migration.

### Demand D-7 · Adaptive orchestrator — task → understand → dispatch → re-route
- **Source.** M2 (full quote in source-message refs).
- **Goal.** When user states a task (free text), the orchestrator: parses
  intent, identifies / confirms goal, ranks candidate synapses against current
  state, dispatches top, observes post-state, re-ranks, repeats until goal-met
  or user-interrupts.
- **Measurement.** End-to-end test: 5 fixture tasks ("write a study", "review my PR",
  "audit the project", etc.) run through orchestrator without manual command
  selection. Success = task-met within ≤ 2 user interjections.
- **Audit criterion.** ≥ 4/5 fixture tasks complete successfully.
- **Linked.** D-003 D-010 D-013. Q7 Q10. F-005 F-006.
- **Status.** ⬜ open.
- **Phase target.** Phase 3 prototype, Phase 4 hardened.

### Demand D-8 · Auto workflow generator
- **Source.** M1: "code-dev a new automatic workflow generator"
- **Goal.** Given a goal + current state, AXON synthesises a viable workflow
  (sequence of synapses) by graph search over the synapse contract space.
  Output is either a stored compiled workflow or an ephemeral plan.
- **Measurement.** Generator handles 3 novel goals in user testing (per `_goal.md`).
  Generated workflow predicted-post-state matches goal-precondition for the
  next anticipated synapse.
- **Audit criterion.** 3/3 novel-goal test set passes; user signs off.
- **Linked.** D-010. Q9. OQ-05.
- **Status.** ⬜ open.
- **Phase target.** Phase 3.

### Demand D-9 · Several pre-built workflows
- **Source.** M1: "Ideally we could have in code-dev a new automatic workflow
  generator and several workflows"; M4: "they can be predetermined like what
  we have so far in code-dev but they can modify"
- **Goal.** Ship a workflow library under `workspace/workflows/` covering
  canonical chains: study-flow, plan-flow, pr-cycle, post-impl (build → test →
  self-review → reviewer-track → audit → shadow → finalize), library-ingest,
  igap-improve.
- **Measurement.** ≥ 7 workflow files in `workspace/workflows/`. Each has a
  declared trigger, goal, synapse list, validation rule.
- **Audit criterion.** `workflow list` returns ≥ 7; `workflow simulate <name>`
  succeeds for all of them on a fixture project.
- **Linked.** D-010 D-013. F-006 Q14.
- **Status.** ⬜ open. Programs to chain mostly exist (F-006).
- **Phase target.** Phase 3.

### Demand D-10 · Goal-setting on every code-dev step
- **Source.** M1: "we need set always goals in every step of code-dev so we
  can measure how good — for instance, what is the goal of a study, what is
  the goal of a project, what is the goal of a plan, what is the goal of a code"
- **Goal.** Every project, every phase, every plan, every PR carries an
  explicit `goal:` field with measurable success criteria.
  Workflow-bound goals are pre-defined per workflow; ad-hoc goals are
  user-stated with AXON-infer + confirm fallback.
- **Measurement.** Schema v5: `_meta.md` of project + phase + plan + PR gains
  `goal:` block. Migration tool populates from existing free-text where possible.
- **Audit criterion.** ∀ active project: every level has a `goal:` field set.
  Empty/`(none)` goals fail audit.
- **Linked.** D-007. Q4. T-C.
- **Status.** 🟦 in-progress (this project's `_goal.md` set; schema TBD).
- **Phase target.** Phase 2 schema, Phase 3 rollout.

### Demand D-11 · Tools suggested based on goal + workflow
- **Source.** M1: "based on goals and workflows tools must be suggested"
- **Goal.** Suggester ranker uses (goal, workflow, current-state, history) to
  rank candidate synapses. Ranking is auditable: each suggestion logs the
  signals that lifted it.
- **Measurement.** Log every suggestion's score + signals. Replay test: same
  state → same ranking. Audit log readable via `synapse-suggest log`.
- **Audit criterion.** 95 % of suggestions accepted by user on a 50-decision
  user-test set (a softer success bar; specific number TBD with Phase 4).
- **Linked.** D-010. Q10. T-F.
- **Status.** ⬜ open.
- **Phase target.** Phase 3.

### Demand D-12 · Pop-up questions
- **Source.** M1: "maybe questions can pop up"
- **Goal.** When confidence < threshold OR inference-mode requires it,
  the orchestrator QUERY(user) with the candidate suggestions before dispatching.
- **Measurement.** L:inference-mode 0–2 → always QUERY; 3–7 → confidence-gated;
  8–10 → autonomous. Log every QUERY vs autonomous decision.
- **Audit criterion.** Behavior matrix matches spec across inference modes
  (test fixture).
- **Linked.** D-010 (suggestion engine). Q10.3. OQ-03 (delivery UX).
- **Status.** ⬜ open.
- **Phase target.** Phase 3.

### Demand D-13 · Suggest after-actions (e.g. after implement → suggest self-review)
- **Source.** M1: "after implementing something, suggest self review — or help
  with test mode"
- **Goal.** Every program's `next-conditional` declares the natural follow-ups.
  Orchestrator surfaces top-k on every program completion.
- **Measurement.** ∀ workflow-chain program: `next-conditional` ≠ ∅.
  Suggestions visible in output-layer footer.
- **Audit criterion.** Audit fires after every completed program; absent
  `next-conditional` flagged.
- **Linked.** D-010. F-006. Q13.
- **Status.** ⬜ open. Programs exist (F-006) but no `next-conditional` declared.
- **Phase target.** Phase 2 spec, Phase 3 author.

### Demand D-14 · Tool hierarchy respected but transitions suggestable
- **Source.** M1: "I want the tools to be automatically linked in a hierarchy
  that is respect the view of the tool (for instance in code-dev the plan mode)
  but axon can suggest the proper plan mode — review mode or whatever"
- **Goal.** Workflows preserve canonical hierarchy (e.g. code-dev: study →
  plan → pr → log → audit) — orchestrator follows it by default — but can
  propose a deviation when state demands (e.g. user types something unrelated
  to current step).
- **Measurement.** Tests: (a) canonical-path session — no deviations,
  hierarchy followed. (b) deviation-trigger session — user types out-of-band
  task; orchestrator surfaces "you appear to want X — switch?" before firing.
- **Audit criterion.** Both tests pass under default inference-mode (5).
- **Linked.** D-003 D-010. F-006. Q7.
- **Status.** ⬜ open.
- **Phase target.** Phase 3.

### Demand D-15 · "Most detailed research ever" (Phase 1 study depth)
- **Source.** M1: "I want the most detailed research ever"
- **Goal.** Phase 1 enumerates every tool + every program with detailed
  findings — not just inventory rows but Phase-2-actionable insights. Cap
  removed (D-008).
- **Measurement.** Findings count ≥ 30 across tracks; synthesis.md cross-references
  every track output; every demand in this ledger has ≥ 1 linked finding.
- **Audit criterion.** Finding INDEX shows all 7 tracks have ≥ 3 findings each
  before synthesis. User signs off depth.
- **Linked.** D-008. All findings.
- **Status.** 🟦 in-progress (7 findings; need ~23 more for ≥ 30 threshold).
- **Phase target.** Phase 1.

### Demand D-16 · Post-impl workflow chain: build → test → self-review → reviewer-track → audit
- **Source.** M4: "after developing, for instance, a build mode would be
  suggested (if c++ or a language that needs), then a test mode, then a
  self-review mode, then a reviewer altering mode"
- **Goal.** A canonical post-impl workflow file exists under
  `workspace/workflows/post-impl.yml` (or `.md`). When `code-dev pr` completes,
  the orchestrator suggests this workflow's next synapse.
- **Measurement.** Workflow file exists and runs end-to-end on a fixture PR.
- **Audit criterion.** `workflow simulate post-impl --pr <id>` produces the
  expected next-synapse for each step.
- **Linked.** D-013. F-006. Q14.
- **Status.** ⬜ open. Programs exist (F-006) — chain not declared.
- **Phase target.** Phase 3 (D-9's first deliverable).

### Demand D-17 · Connect + adjust existing tools per workflow / project
- **Source.** M4: "several tools that ARE ALREADY THERE — and need to be
  connected and adjusted depending on the workflow or project"
- **Goal.** Workflow definitions adjust per project type. A C++ project pulls
  in `build` step; a markdown-only project skips it. Programs declare
  `applies-when:` predicates (e.g. `lang in ["c++","rust","go"]`).
- **Measurement.** ≥ 2 project types tested (e.g. axon-synapse = markdown,
  hypothetical-c++ = compiled). Each triggers a different workflow path.
- **Audit criterion.** Workflow selection logs the predicate that picked it.
- **Linked.** D-013 D-016. Q5 Q14.2.
- **Status.** ⬜ open.
- **Phase target.** Phase 3.

### Demand D-18 · AXON infers workflow OR user picks
- **Source.** M4: "make axon infer the workflow or let user choose for prebuilt ones"
- **Goal.** Two entry paths to a workflow: (a) explicit `workflow run <name>`,
  (b) implicit via free-text intent classification → top-k workflows surfaced
  → user confirms or rejects.
- **Measurement.** Both paths tested end-to-end. Confirmation prompt latency ≤ 1 turn.
- **Audit criterion.** Free-text → workflow proposal happens in ≥ 90 % of
  workflow-eligible free-text inputs (fixture set).
- **Linked.** D-010 D-014. Q10.2.
- **Status.** ⬜ open.
- **Phase target.** Phase 3.

### Demand D-19 · No tests should break
- **Source.** M4: "no tests should break"
- **Goal.** Every PR keeps existing test suite green. Synapse infrastructure
  changes use feature flags / phased rollout so regression is impossible.
- **Measurement.** CI / `run-tests` invoked before every merge. Failed test
  count = 0.
- **Audit criterion.** Branch test suite passes on every PR; documented
  exceptions go through explicit user approval.
- **Linked.** D-012. Q12 (shadow tests). Q14.3 (test program chain).
- **Status.** 🟦 enforced via existing axon-audit infrastructure; verifier TBD.
- **Phase target.** Continuous (every PR).

### Demand D-20 · New tools auto-discoverable + suggestable
- **Source.** M4: "once new tools are added they can be suggested"
- **Goal.** Adding an entry to `tools/REGISTRY.json` is the only step required
  for `synapse-suggest` to include the tool in rankings. No second-step wiring.
- **Measurement.** Add a fixture tool entry, restart boot, run `synapse-suggest`,
  assert tool appears in candidate list.
- **Audit criterion.** New-tool-discovery integration test passes.
- **Linked.** D-012. F-001 F-002 (REGISTRY schema gaps).
- **Status.** ⬜ open. Needs REGISTRY schema extension first.
- **Phase target.** Phase 3.

### Demand D-21 · "Proper tool always gets suggested"
- **Source.** M4: "we need to think in a way that proper tool always gets suggested"
- **Goal.** Suggestion ranker reaches ≥ 90 % top-1 hit rate on a labeled
  fixture set (state → expected next tool).
- **Measurement.** Fixture: 50 (state, expected-tool) pairs derived from
  observed code-dev sessions in my-axon/dev-projects. Run ranker; count top-1
  matches.
- **Audit criterion.** Top-1 hit ≥ 90 %.
- **Linked.** D-010 D-013. T-F.
- **Status.** ⬜ open.
- **Phase target.** Phase 4 (validation).

### Demand D-22 · Pseudo state machine — next state inferred by AXON
- **Source.** M4: "maybe a pseudo state machine in which the next state (or
  tool) is inferred by axon"
- **Goal.** Synapse model formalized as a non-deterministic, observable-state
  pseudo-FSM. States = workspace state vectors; transitions = synapse fires;
  predicates declared.
- **Measurement.** Spec doc exists (`helpers/orchestrator-fsm-spec.md`).
  Reference implementation (`synapse-fsm`) round-trips a workflow:
  state → fire → post-state → next-suggestion.
- **Audit criterion.** Spec doc reviewed + signed off; reference impl test passes.
- **Linked.** D-013. Q7.
- **Status.** ⬜ open. Conceptual lock (D-013) in place.
- **Phase target.** Phase 2 spec, Phase 3 reference impl.

### Demand D-23 · Shadowing enforced
- **Source.** M3: "DONT FORGET to enforce shadowing operation and so on"
- **Goal.** Every PR that touches source files produces a shadow file. Audit
  fails if absent. Existing PRs without shadows get retroactively shadowed.
- **Measurement.** `code-dev audit` reports shadow coverage % per phase. Target 100 %.
- **Audit criterion.** ∀ source-touching PR: shadow file exists AND is
  non-empty AND lists changed files AND cites ≥ 1 finding.
- **Linked.** D-011. Q12. T-G (pending).
- **Status.** ⬜ open. Shadow programs exist (F-006); enforcement to spec.
- **Phase target.** Phase 2 enforcement spec, Phase 3 wiring.

### Demand D-24 · Clear goals per demand auditable
- **Source.** M5 (this turn): "add clear goals for each demand so we can audit
  it later"
- **Goal.** This file (`_demands.md`) exists and is updated every time a new
  demand is uttered. Every demand has goal + measurement + audit-criterion.
- **Measurement.** ∀ demand: `goal != ∅ AND measurement != ∅ AND audit-criterion != ∅`.
- **Audit criterion.** This file passes self-audit on every checkpoint.
- **Linked.** D-007.
- **Status.** 🟦 in-progress (this turn — 26/26 rows seeded).
- **Phase target.** Continuous (every demand utterance).

### Demand D-25 · Preserve existing code-dev hierarchy without breaking it
- **Source.** M6 (this turn, late): "the current code-dev hierarchy works
  pretty well, we want something different but I want that we don't lose it"
- **Goal.** Every existing code-dev program and workflow step remains
  invocable and behaviorally identical after the synapse rollout. New
  capabilities are layered on top via metadata + orchestrator suggestions,
  never via destructive changes to programs.
- **Measurement.** Backwards-compat test set: replay every documented
  code-dev workflow path (study → plan → pr-cycle → audit → finalize, and
  the 9-phase pr-review) before and after each Phase 3 PR. Output must match.
- **Audit criterion.** Phase 3 CI gate: backwards-compat test set passes
  100 %. Any deviation requires explicit user approval + documented migration.
- **Linked.** D-012 D-014. F-006.
- **Status.** ⬜ open.
- **Phase target.** Continuous (every Phase 3 PR).

### Demand D-27 · Register new tools (synapses) at runtime
- **Source.** M7 (this turn): "we can register new tools (synapses)"
- **Goal.** Adding a new tool entry to `tools/REGISTRY.json` OR a new program
  file to `workspace/programs/` is the **only** step required to make the
  synapse fire-able + suggest-able. Boot/runtime picks it up automatically.
- **Measurement.** Integration test: add fixture tool, restart, run
  `synapse-suggest list`, assert tool present. No second-step wiring.
- **Audit criterion.** New-synapse-discovery test passes.
- **Linked.** D-012 D-016 D-020. F-001 F-002 F-010.
- **Status.** ⬜ open. Half-supported today: REGISTRY auto-loaded at boot,
  but no synapse-suggest engine exists yet to surface new entries.
- **Phase target.** Phase 3.

### Demand D-28 · Register new workflows from natural-language description
- **Source.** M7: "user describes workflow and you infer the tools that
  should be used iteratively getting feedback from user"
- **Goal.** User types: "I want a python code-dev workflow that lints, tests,
  reviews, then writes the commit message." AXON proposes:
  `code-dev-study → run-tests → code-dev-self-review → code-dev-explain →
  code-dev-finalize` and confirms each synapse with the user before writing
  the workflow file. Iteration continues until user accepts.
- **Measurement.** End-to-end test: a fixture description → workflow file
  written → workflow loads and runs.
- **Audit criterion.** ≥ 3 user-described workflows authored via this path,
  user signs off each.
- **Linked.** D-016. Q9.
- **Status.** ⬜ open.
- **Phase target.** Phase 3.

### Demand D-29 · Two workflow execution modes — Fixed and Adaptive
- **Source.** M7: "sometimes the user can know pretty well what they want
  and also a mode that you don't know exactly and that's the automatic one"
- **Goal.** Workflow files carry `execution-mode: fixed | adaptive | hybrid`.
  Fixed = predeclared synapse sequence walked step by step. Adaptive =
  orchestrator infers next synapse at each step from state + goal. Hybrid =
  per-step mode.
- **Measurement.** Two reference workflows ship: one fixed (canonical
  code-dev), one adaptive (free-text task router). Each tested end-to-end.
- **Audit criterion.** Fixed-mode workflow runs deterministic identical
  paths on 5 replays. Adaptive-mode workflow asks ≥ 1 question per
  ambiguous step (per inference-mode 5).
- **Linked.** D-017 D-010 D-013.
- **Status.** ⬜ open.
- **Phase target.** Phase 3.

### Demand D-30 · Suggestions stay live even in Fixed workflows
- **Source.** M7: "this does not mean that in fixed ones you cannot suggest
  things based on what they are doing"
- **Goal.** A Fixed-mode workflow never silently overrides the user's
  declared path, but the suggestion engine remains active and surfaces:
  (a) **sideband** suggestions (footer/banner — opt-in deviations),
  (b) **deviation** suggestions when state diverges from the precondition
  of the next fixed step (e.g. tests fail before review).
- **Measurement.** Mid-workflow state-mutation test: edit a file mid-workflow,
  assert sideband suggestion appears in footer.
- **Audit criterion.** ≥ 80 % of sideband suggestions during fixed-mode
  runs are accepted-or-explicitly-dismissed (not ignored as noise).
- **Linked.** D-010 D-017. Q10 Q13.
- **Status.** ⬜ open.
- **Phase target.** Phase 3.

### Demand D-26 · Generalize beyond code — workflow OS for science, study, anything
- **Source.** M6 (this turn, late): "this would make us have a piece of
  software capable of automating not code, not development, but workflow —
  code-dev is an example of code workflow but we want to be able to leverage
  other stuff — for science and study as well — that why this vision has to
  be very precise"
- **Goal.** AXON Synapse's primitives (workflow, synapse, domain, orchestrator,
  goal, project, phase) are domain-agnostic. Adding a new domain
  (e.g. `science-dev`, `study-dev`) is a drop-in operation: domain folder under
  `workspace/domains/{name}/`, workflow files, program subset — and the
  orchestrator picks it up via D-020 auto-discoverable.
- **Measurement.** Phase 4 deliverable: a second domain (`study-dev` proposed)
  is bootstrapped and a sample project under it runs end-to-end through the
  orchestrator using the same primitives that drive code-dev.
- **Audit criterion.** A user-provided non-code workflow (science experiment,
  reading-study, etc.) is automatable using exactly the same kernel +
  orchestrator. No code-specific keywords appear in the synapse contract
  schema or in the workflow file format.
- **Linked.** D-015. F-005 F-006. Q15 (to add).
- **Status.** ⬜ open.
- **Phase target.** Phase 2 schema (domain-agnostic by construction); Phase 4
  ships ≥ 1 non-code domain.

---

## Roll-up

| Status        | Count |
|---------------|-------|
| ⬜ open        | 25 |
| 🟦 in-progress | 5 |
| 🟨 designed   | 0 |
| 🟩 met        | 0 |
| ⬛ deferred   | 0 |
| **Total**     | **30** |

## Cross-reference

| Demand | Decisions | Findings | Questions | Track |
|--------|-----------|----------|-----------|-------|
| D-1    | D-008 | F-001..F-005, F-007 | Q1 Q2 | T-A |
| D-2    | D-006 D-009 | F-005 | Q8 Q11 | T-E |
| D-3    | D-006 D-009 | F-005 | Q8.4 Q8.5 | T-E |
| D-4    | D-009 | F-005 | Q11 | T-E |
| D-5    | — | F-006 | Q5 | T-B |
| D-6    | D-005 D-013 | F-005 | Q6 | T-D |
| D-7    | D-003 D-010 D-013 | F-005 F-006 | Q7 Q10 | T-D T-F |
| D-8    | D-010 | — | Q9 OQ-05 | T-F |
| D-9    | D-010 D-013 | F-006 | Q14 | T-F |
| D-10   | D-007 | — | Q4 | T-C |
| D-11   | D-010 | — | Q10 | T-F |
| D-12   | D-010 | — | Q10.3 OQ-03 | T-F |
| D-13   | D-010 | F-006 | Q13 | T-F |
| D-14   | D-003 D-010 | F-006 | Q7 | T-D |
| D-15   | D-008 | all | — | all |
| D-16   | D-013 | F-006 | Q14 | T-B T-F |
| D-17   | D-013 | — | Q5 Q14.2 | T-B T-F |
| D-18   | D-010 | — | Q10.2 | T-F |
| D-19   | D-012 | — | Q12 Q14.3 | T-B |
| D-20   | D-012 | F-001 F-002 | — | T-A |
| D-21   | D-010 D-013 | — | — | T-F |
| D-22   | D-013 | — | Q7 | T-D |
| D-23   | D-011 | F-006 | Q12 | T-G |
| D-24   | D-007 | — | — | meta |
| D-25   | D-012 D-014 | F-006 | — | T-B |
| D-26   | D-015 | F-005 F-006 | Q15 | all |
| D-27   | D-012 D-016 D-020 D-021 | F-001 F-002 F-010 F-014 | Q16 | T-A T-F |
| D-28   | D-016 D-023 | F-014 | Q16.2 Q9 | T-F |
| D-29   | D-017 D-010 D-013 D-024 | F-013 | Q17 | T-F |
| D-30   | D-010 D-017 D-023 | F-014 | Q10 Q13 Q17 | T-F |

## Phase-2 ADR cross-reference (D-018..D-025)

| ADR | Resolves | Applies to demands |
|-----|----------|--------------------|
| D-018 glossary-singular | Q15.1 vocabulary lock | D-6, D-26, D-15 |
| D-019 DAG.md one-way render | OQ-04 finalization | D-2, D-3, D-4 |
| D-020 infer-first migration | OQ-08 | D-6, D-25, D-27 |
| D-021 ranker rule-based v1 | OQ-05 strategy | D-7, D-11, D-21 |
| D-022 shadow-grace flag | F-016 backwards-compat | D-19, D-23, D-25 |
| D-023 suggestion footer default | OQ-03 | D-11, D-12, D-13, D-30 |
| D-024 workflow-compile → Phase 4 | OQ-05 deferral | D-8, D-9 |
| D-025 synthesis single gate (P1 close) | OQ-10 | D-15, D-24 |

# Phase 1 — Study · axon-workflow-discipline

> Goal (owner, 2026-05-29): make FIXED workflows + program node-graphs **rigid** —
> no node-jumping — and make AXON **always narrate its state/phase**, both
> MECHANICALLY ENFORCED and MANDATORY. code-dev is the exemplar; the principle is general.
> This project runs the FULL workflow in order (study→plan→pr→log→audit), no skipping,
> as the demonstration + fix of its own subject.

Codebase: `/home/arturcastiel/projects/new-axon/axon` (CANONICAL).

## The defects (generalized from axon-bug-free)
- **D1 — node-jumping in fixed graphs.** In axon-bug-free the agent skipped
  plan→pr-specs→audit (study→remediate). General defect: ANY program/fixed-workflow with a
  node graph (steps/phases/DAG) can be entered out of order — breaking the graph's purpose.
- **D2 — state not surfaced / not narrated.** AXON described next-steps in prose ad hoc
  instead of ALWAYS narrating: which workflow/program, which node/phase (NN—NAME), the
  phase's current state, and the explicit gate to advance.

## Owner requirements (Q&A + follow-ups, 2026-05-29) — binding
1. **Enforcement = BOTH** program-level HALT (interactive) **and** a crucible merge gate (BLOCK).
2. **No skipping by inference.** Interactive skip-attempt → a BIG, prominent MENU + disclaimer
   for an explicit HUMAN choice. **Autonomous mode → NEVER skip** (hard block, no override).
3. **Mandatory, gate-enforced state surfacing**, and next-suggestions auto-pop.
4. **Kernel allowed** — propose the kernel response-gate change (owner merges); non-kernel auto-merges.
5. **General, not just code-dev** — applies to all programs/fixed-workflows with a node graph;
   "jumping nodes breaks the purpose."
6. **Rigid FIXED ⇒ adaptive gets used + flows improve.** To deviate from a fixed graph you must
   EXPLICITLY switch to ADAPTIVE (the sanctioned dynamic-selection mode). Adaptive deviations are
   logged as improvement signals for the fixed flows (feed igap/usage).
7. **Verbose narration** — not a terse flag; narrate where we are + what we're doing, e.g.:
   `PHASE 01 — STUDY · goal set: {…} · status: in-progress · must be marked DONE → PHASE 02`.
8. **Adaptive is TRACKED.** Adaptive mode is not untracked exploration — it records its ordered
   node/state trajectory (via phase_ledger, same as fixed) so the run can be reconstructed/replayed
   AND promoted into a proposed fixed workflow (the improvement loop closes here).
9. **Backward transitions cascade-invalidate downstream — VERBOSELY.** Re-entering an earlier phase
   (e.g. code-dev → back to STUDY) IS allowed, but MUST mark every downstream phase STALE / not-DONE
   and require it to be re-run + updated — like a build graph dirtying its dependents. Loudly narrated:
   "↩ back to STUDY → PLAN · PR-SPECS · LOG · AUDIT are now STALE and must be re-run."
10. **Anticipation layer always enforced.** `tools/anticipate.py` (ACTIVE, "anticipate the next step
    + decide whether to surface it"; axon-ascent phase-7) is ORPHANED — referenced only in
    REGISTRY.json, invoked by nothing. It must fire EVERY turn and surface its prediction as part of
    the proprioception surface (state + next-suggestions + anticipation), gate-enforced like the rest.
11. **Anti-orphaning protection (code can grow without features going missing).** Tests pass in
    isolation yet WIRING silently regresses — a confirmed disease, not a hypothesis: `anticipate` (0
    live refs), `axon-trace` (0), `narrate` (never called), 8 orphan rules, inert schema fields. NO
    existing audit checks INVOCATION-liveness (neuron-audit=programs; registry-drift=file↔registry
    existence; coherence-lint=program graph). Need a mechanical liveness gate: every ACTIVE tool must be
    invoked (TOOL()/import/kernel-wired), every rule_id must sit in a real gate — WARN-first (grandfather
    the current backlog) + BLOCK on NEW orphans. Most general fix; it would have caught all the above.

## Current-state audit (what exists vs the gap)
**Exists (build on it, don't reinvent):**
- Phase machinery: `tools/phase_ledger.py` (records phase events; `verify` checks expected phases
  after the last `start`), `tools/phase_gate.py`; kernel `W:active-phase` + "Program phase tracking"
  (STORE active-phase on entry/step/done/fail) + DONE()/FAIL() auto-write phase.
- Graph substrate: `tools/dag.py`, `tools/workflow_dag.py`, `tools/plan_dag.py`,
  `tools/dag_consistency.py` (R_DAG_CONSISTENT — DAG validity), `synapse_infer/suggest/validate`.
- The "fancy menu" precedent: the kernel **active-program-interrupt gate** already renders a big
  box + disclaimer + K/I/A choice on a competing input mid-program — reuse this UX for skip-attempts.
- Workflow runner: `workflow-run.md` (fixed) vs `orchestrator.md` + `workflow run adaptive-free-text`
  (adaptive) + `workspace/workflows/` + `WORKFLOW-FILE.md` format.
- `tools/rules/r_phase_tracked.py` (**R_PHASE_TRACKED**) — exists but is an ORPHAN (BF-018): wired
  into no gate, only the advisory `lint_summary`.

**The gap (what's missing):**
- G-a. No gate ENFORCES in-order traversal of a fixed workflow/program graph. `phase_ledger.verify`
  can check order but is not wired as a BLOCKING transition gate; R_PHASE_TRACKED is orphaned.
- G-b. No mechanism distinguishes "advance allowed" — phase N+1 may be entered without phase N being
  explicitly DONE (artifact-exists is weaker than an explicit close).
- G-c. No MANDATORY narrated state surfaced every turn; next-suggestions are gated off
  (`L:suggestions-enabled`) and don't reliably pop.
- G-d. No enforced FIXED-vs-ADAPTIVE boundary: deviating from a fixed flow isn't forced through the
  adaptive mode, and adaptive deviations aren't captured as improvement signals.
- G-e. **Anticipation layer orphaned.** `tools/anticipate.py` is ACTIVE but wired into nothing
  (grep: referenced only in REGISTRY.json) — it never fires. The proprioception surface (anticipate
  + suggestions + state) collectively regressed to "exists but not invoked."

## Design (build-on-existing; details specced in Phase 2/3)
- **Node-order gate (general).** Every fixed workflow/program declares its node graph (reuse the
  `dag:`/step graph + `workflow_dag`); a transition to node K is permitted only if K's predecessors
  are recorded DONE in `phase_ledger`. Enforced TWICE: (i) program-level HALT at entry (interactive
  big-menu / autonomous hard-stop), (ii) a crucible STATIC control over the project/workflow artifacts.
- **Explicit DONE-to-advance.** A phase/node is advanced only after it is explicitly marked DONE
  (`code-dev done <phase>` / `DONE(node)` in `phase_ledger`); artifact-presence alone is insufficient.
- **Skip policy.** By inference: NEVER. Interactive: render the big MENU + disclaimer (reuse the
  active-program-interrupt box) — human picks. Autonomous (`autonomous-mode` active): hard HALT,
  no menu, no override — the only sanctioned deviation is to EXPLICITLY enter adaptive.
- **Adaptive escape + improvement loop.** Deviation = `workflow run adaptive-free-text` (explicit);
  the adaptive path is logged, and any node the adaptive run takes that the fixed flow lacks is
  recorded as a fixed-flow improvement candidate (igap/usage).
- **Mandatory narrated state (gate-enforced).** While any program/workflow is active, every response
  must carry a narrated state block — `WORKFLOW/PROGRAM · PHASE NN — NAME · state: {summary} ·
  status: {in-progress|DONE} · advance: mark DONE → PHASE NN+1` — plus auto-popped next-suggestions.
  Enforced by a RUNTIME rule (`R_STATE_SURFACED`) at the verify response gate; the MANDATE itself is
  added to the kernel response gate (owner-merge).
- **Backward = dirty-downstream (build-graph semantics).** phase_ledger records node dependencies.
  Re-entering / un-DONE-ing node K marks every downstream node STALE; the order-gate then requires
  re-completion in order before advancing past them. Every back-move is verbosely narrated (which
  nodes went stale). No silent staleness.
- **Adaptive tracking + promotion.** Adaptive runs record an ordered trajectory in phase_ledger
  (node, state, ts). A `workflow promote` path turns a tracked adaptive trajectory into a PROPOSED
  fixed workflow (DAG) + surfaces it as an improvement candidate (igap/usage). Adaptive ≠ untracked.

## PR plan preview (Phase 2 will finalize + number)
- **Node-order + DONE gate** (general): `R_WORKFLOW_NODE_ORDER` (new) + crucible BLOCK control over
  fixed-workflow/program graphs; explicit-DONE-to-advance via phase_ledger; wire `R_PHASE_TRACKED`
  (orphan → gate) [overlaps BF-018].
- **code-dev exemplar**: phase-gate + explicit `done` + skip BIG-MENU (interactive) / hard-HALT
  (autonomous) reusing the active-program-interrupt box; the phase-gate helper (extend phase_gate.py).
- **Backward cascade-invalidation**: phase_ledger node-deps; back-move marks downstream STALE +
  verbosely narrates; gate requires re-completion.
- **Proprioception surface (gate-enforced, mandatory)**: `R_STATE_SURFACED` (runtime) — narrated
  state block + always-on next-suggestions + **wire `anticipate.py` to fire every turn**; kernel
  response-gate mandate (owner-merge).
- **Adaptive tracking + promotion**: adaptive records trajectory in phase_ledger; `workflow promote`
  → proposed fixed workflow (improvement loop).
- **Generalize**: extend the node-order gate to the `workflow-run` runner + program step-graphs.

## Deep-study findings (4 parallel auditors + 2 recon passes, file:line-grounded)
**THE reframing finding — enforcement substrate:** AXON programs (`workspace/programs/*.md`) are
LLM-INTERPRETED runbooks, not executed Python (AXON-DOCS-ARCHITECTURE). And the response gate runs
ONLY by agent-discipline — `.claude/` is EMPTY (no hooks); `claude-code.md` declares
`host-cap-enforce="self"` (hooks are the TARGET, not reality). ⇒ Enforcement written in `.md` is
ADVISORY; only Python tools + a real harness hook have teeth. So "mechanical/mandatory" requires:
(a) move the step-loop + gates into Python tools, and (b) a Claude Code hook (Stop/PostToolUse →
`verify.py output`; UserPromptSubmit → store `W:recent-user-input`). The hook is host-wiring =
**the same BF-S1 human item** (touches `~/.claude`/settings.json).

- **Phases:** 3 conflated namespaces (kernel `W:active-phase=prog:step` · code-dev `_meta.phase` ·
  `E:phase-ledger`); code-dev phase ORDER is hardcoded string-literals (not data-driven); NO DONE
  marker (phase "done"==output file exists); `meta.phase` only advances 1→2→3 (never writes log/audit);
  `phase_gate.py` exists but 1 call-site + plan-only contract; `phase_ledger.verify` is set-membership
  NOT order; `dag.py` has no `stale` status + no `descendants()` (both needed for cascade-invalidation);
  `code-dev-cascade.md` is cosmetic (text note, no status flip). Reuse: the active-program-interrupt
  big-box as the skip-menu UX (note its `continuation-cmds` swallows skip/back/next/done).
- **Workflows:** fixed graph = YAML `synapses[].on-complete` (has LEGAL cycles s4→s3/s6→s2 ⇒
  "in-order"="next ∈ declared on-complete targets", NOT acyclic/monotonic); next-node driven by
  on-complete+`predicate.py`, the ranker pick is COSMETIC even in adaptive; `allow-deviation`/
  `mode-override`/`mode-switch` are INERT (validated+documented, read by no code); NO durable
  trajectory (phase-ledger lacks run-id/workflow cols; orchestrator-tick has no Python backing;
  trace[] cleared) ⇒ prereq blocker for replay+promote; `workflow promote`/`compiled/` net-new;
  4 divergent graph models; `workflow_dag` not a control (and would FAIL on the legal back-edges).
- **Proprioception:** footer surfaces `W:active-program` but NOT `W:active-phase`; suggestions don't
  pop because the DATA source (`W:orchestrator-last-tick`) is event-driven/stale (not a toggle);
  `W:recent-user-input` has no STORE producer; best rule template = `r_project_anchor.py`.
- **Rules/gates:** 4 wiring surfaces (ALL_RULES · crucible-changeset · lint_summary · crucible.json);
  8 orphan rules confirmed; **strict halt-mode makes WARN==BLOCK on the kernel gate** ⇒ the safe
  pattern is SILENT-until-activated→BLOCK (never default-WARN) — except crucible-changeset where WARN
  is genuinely ignored; changeset ctx is thin (`{changed_files,repo_root}`, no state); `load_state`
  does NOT read `active-phase.md` (one-line prereq for R_STATE_SURFACED); lint_summary↔ALL_RULES
  drift is UNTESTED (how rules orphan).
- **Anti-orphaning (req 11):** no audit checks invocation-liveness — the exact hole. (See req 11.)

## Open problems = PLANNING DECISIONS (study-resolved; the PLAN phase decides)
- OP-1 **Enforcement substrate**: how much to Python-ify (a `tools/workflow_run.py` owning cursor +
  advance-guard + trajectory) AND whether to add the `.claude` hook now (owner/BF-S1) vs ship the
  enforcement Python + leave the hook as an owner task. (Biggest fork.)
- OP-2 **code-dev phase source-of-truth**: create a data-driven phase list/DAG vs adopt project `DAG.json`.
- OP-3 **Anti-orphaning gate**: scope + the grandfather list (current known orphans) + what counts as "wired".
- OP-4 **Trajectory artifact**: phase_ledger run-id/workflow schema bump vs a new `workflow_trace` tool.
- OP-5 **Kernel vs non-kernel split**: which pieces need the kernel response-gate (owner-merge) vs auto-merge.

## STUDY confidence: **9/10 — ready for PLAN**
Every surface is grounded at file:line; all 11 requirements captured; the enforcement reality is
understood (the one finding that reframes the design); open items are PLANNING decisions, not study
unknowns. Reserved 1 point: OP-1 (Python-ification depth + the hook) is a genuine fork the PLAN must
settle with the owner — surfaced with options, not blocking.

→ Gate to PHASE 2 — PLAN: owner confirms STUDY DONE (or adds requirements). Per the discipline this
  project builds, I will NOT enter PLAN until STUDY is explicitly marked DONE.

✓ **STUDY DONE — owner, 2026-05-29** (recorded in phase-ledger as `1-study:DONE`). Advanced to
  PHASE 02 — PLAN. (If STUDY is re-opened later, the cascade rule re-triggers PLAN + all downstream.)

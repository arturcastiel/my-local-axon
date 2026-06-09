# Phase 2 — PR list · axon-workflow-discipline

> Ordered by wave (02-plan.md). Merge-type: **AUTO** = non-kernel, fail-closed autonomous loop;
> **OWNER** = kernel-edit (dev-mode + your merge) or host-wiring (you run). Every AUTO PR ships tests
> (Core Rule 13) and must pass the liveness gate (no new orphans). Maps every study requirement (R1–R11).

## Wave A — foundation
- **PR-1 · phase model + DONE + trajectory keys** · AUTO · (R1,R2,R7,R8,R9)
  - `_phases.json` sidecar (ordered nodes · status pending|active|DONE|stale · deps); a `phase_model.py`
    tool (read/advance/done/status); `code-dev done <phase>` command; phase_ledger gains `run_id`+`workflow`
    columns; `verify.load_state` reads `active-phase.md`. Switch code-dev dashboard phase-detection from
    file-existence → `_phases.json` status. Tests: model round-trip, ledger schema, load_state key.
- **PR-2 · dag.py: `stale` status + `descendants()`** · AUTO · (R9)
  - Add `"stale"` to `NODE_STATUSES`; add `descendants(node)` BFS over `depends` edges; add a bulk
    `set_status_cascade(node, "stale")`. Pure-additive. Tests: descendants of a fan-out graph; cascade marks all.

## Wave B — code-dev enforcement (the exemplar)
- **PR-3 · in-order + explicit-DONE HALT** · AUTO · (R1)
  - Per-phase entry GUARD in the canonical programs (`code-dev-plan`/`-pr-create`/`-journal-log`/
    `-safety-audit`): HALT unless predecessor phase status==DONE in `_phases.json`. Generalize `phase_gate.py`
    from "plan-only contract" to "predecessor-DONE". Tests: entering pr without plan-DONE HALTs.
- **PR-4 · skip BIG-MENU / autonomous hard-HALT** · AUTO · (R2)
  - Reuse the active-program-interrupt big-box UX: on a skip-attempt, interactive → render menu + disclaimer
    ([B]ack / [F]orce-skip→requires explicit confirm / [C]ancel); autonomous (`autonomous-mode` OR inf≥8 OR
    halt strict) → `FAIL()` hard-HALT, no menu, no override. Tests: autonomous path never renders a menu.
- **PR-5 · backward cascade-invalidation (verbose)** · AUTO · (R9)
  - Rewrite `code-dev-cascade` to call dag `descendants()`→`set_status(stale)` + flip `_phases.json` status;
    verbosely narrate ("↩ back to STUDY → PLAN·PR·LOG·AUDIT now STALE"). Tests: re-entering study marks all downstream stale.
- **PR-6 · R_WORKFLOW_NODE_ORDER (merge gate)** · AUTO · (R1,R5)
  - New STATIC changeset rule (WARN-first — safe on changeset surface) + crucible control: a code-dev/
    workflow artifact set whose phase/node order is violated BLOCKs at merge. Loads artifacts from repo_root.
    Tests: out-of-order project flagged; in-order passes; grandfather via flag.

## Wave C — proprioception (verbose state, always-on)
- **PR-7 · narrated state block + R_STATE_SURFACED** · AUTO · (R3,R7)
  - A `state_line.py` renderer (program/workflow · PHASE NN—NAME · state · status · advance) from
    active-phase + `_phases.json`; `R_STATE_SURFACED` RUNTIME rule (silent-until-activated→BLOCK, per strict-halt).
    Degrades gracefully when no active phase. Tests: rule fires when block absent + active; silent when idle.
- **PR-8 · revive anticipation + always-on suggestions** · AUTO · (R3,R10)
  - Wire `anticipate` to compute every turn (fixes the orphan + the stale-`orchestrator-last-tick` data gap);
    surface its prediction as the always-on next-suggestion; add a `recent-user-input` producer (interim tool;
    true producer = UserPromptSubmit hook in PR-13). Tests: anticipate invoked + surfaced; suggestion non-empty.

## Wave D — anti-orphaning + cleanup
- **PR-9 · liveness gate (the protection)** · AUTO · (R11)
  - `liveness.py` + crucible control: ACTIVE tool must be invoked (TOOL()/import/kernel/output-layer);
    `rule_id` must be in a real gate. WARN + grandfather allowlist of today's orphans; **BLOCK on NEW orphans**.
    Tests: a fresh unwired tool/rule → BLOCK; grandfathered → WARN; wired → pass.
- **PR-10 · wire the 8 orphan rules** · AUTO · (R11; overlaps BF-018)
  - Register R_OVERRIDE_ATTEMPT, R_INFERENCE_MODE_LOCK, R_PHASE_TRACKED, R_COGNITION_LANGUAGE, R_FAIL_FORMAT,
    R_IDENTITY_LOCK, R_NEURON_ROLE, R_RESERVOIR_OUTPUT into a real gate (silent-until-activated→BLOCK, or
    changeset). Each removal from the liveness grandfather list. Tests: each now in ALL_RULES/crucible.

## Wave E — generalize (the teeth)
- **PR-11 · Python-ify the workflow runner** · AUTO · (R1,R5,R6,R8)
  - `tools/workflow_run.py` owns the cursor + advance-guard (next ∈ declared on-complete targets, else refuse
    unless explicit adaptive) + trajectory record (run_id) + `workflow promote` (tracked adaptive → proposed
    fixed). Reduce `workflow-run.md` to a thin front. Fix the 3 runner bugs (cursor←start; phantom
    orchestrator fields; workflow-list misses domain workflows). Wire `workflow_dag` analyze as a control (after
    reclassifying legal back-edges). Tests: jump refused; adaptive trajectory recorded; promote emits valid YAML.

## Wave F — kernel + hook (OWNER) — ✅ PREPARED + HANDED OFF
- **PR-12 · kernel response-gate mandate** · OWNER-MERGE · (R3,R5) · **PREPARED → MR !55** (branch
  `fix/awd-pr12-kernel-mandate`, commit `7acb1e0`, gate validated 21/0/0; dev-mode used then re-locked)
  - Added to `axon/KERNEL-SLIM.md` response gate: the mandatory narrated-state block (R_STATE_SURFACED)
    + the rigid-fixed-traversal principle (fixed graphs rigid; deviation only via explicit adaptive;
    R_WORKFLOW_NODE_ORDER + workflow_run.advance + code-dev phase HALT). **Awaiting your merge.**
- **PR-13 · host-harness hook (makes runtime gates real)** · OWNER-RUN · (R3,R7,R10,R11; = BF-S1) ·
  **PREPARED → MR !56** (branch `fix/awd-pr13-hook`, commit `90b797a`)
  - INERT proposal (`.claude/settings.json.proposed` + `.claude/HOOKS-README.md`): the three host hooks
    (prompt-submit → store recent input; pre-tool-write → enforce write-gate; stop/response → verify.py
    output enforcing R_STATE_SURFACED + others). Each needs a thin wrapper + per-version verification
    (documented). **Awaiting your install** (rename proposal → active settings, write wrappers, flip the
    WARN-first activation flags `L:state-surfaced-required` / `L:no-orphan-tools-required` /
    `L:workflow-node-order-required` to true).

## Requirement coverage check
R1→PR1,3,6,11 · R2→PR4 · R3→PR7,8,12,13 · R4(kernel-allowed)→PR12,13 · R5→PR6,11,12 · R6→PR11 ·
R7→PR1,7,13 · R8→PR1,11 · R9→PR2,5 · R10→PR8,13 · R11→PR9,10,13. **No requirement unmapped.**

## Gate to PHASE 03
On owner "PLAN DONE", write `03-prs/PR-01.md …` specs IN ORDER (the discipline forbids jumping to
implementation without specs). PR-1 spec first.

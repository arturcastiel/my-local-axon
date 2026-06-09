# Phase 2 — Plan · axon-workflow-discipline

> Input: 01-study.md (11 requirements, 9/10 grounded). This plan DECIDES the 5 open problems,
> sets the architecture, and groups the work into waves. PR list = 02-prs.md.

## Decisions (resolving OP-1..5)
- **OP-1 Enforcement substrate → Python + a hook.** `.md` runbooks are advisory; teeth live in Python
  tools + a harness hook. Plan: put all gate/traversal/trajectory logic in Python; ship a thin `.md`
  front. Provide the Claude Code hook config (`.claude/settings.json`) as an OWNER-RUN PR (host-wiring
  = BF-S1) that makes the response gate actually fire. Until the hook is installed, runtime gates are
  "best-effort agent-discipline" — we ship them so they activate the moment the hook lands.
- **OP-2 Phase source-of-truth → a per-project phase manifest.** Add a machine-readable
  `phase-order` + per-phase `status` (pending|active|DONE|stale) to project state (a `_phases.json`
  sidecar, NOT whitespace-fragile `_meta.md` edits). Reconcile with the v4 `DAG.json` where present.
  This replaces the 3 hardcoded string-literal sites + the file-existence heuristic.
- **OP-3 Anti-orphaning → liveness gate, WARN-first + grandfather.** A new `liveness` audit:
  every ACTIVE tool must be invoked (`TOOL()`/import/kernel-or-output-layer wired); every `rule_id`
  must sit in a real gate (ALL_RULES / crucible / changeset). Ship with a grandfather allowlist of
  today's known orphans; WARN on grandfathered, **BLOCK on any NEW orphan**. The allowlist shrinks as
  PR-8/PR-10 wire the current orphans → liveness then goes BLOCK-clean.
- **OP-4 Trajectory → extend `phase_ledger`.** Add `run_id` + `workflow` columns (schema bump) rather
  than a new tool; reuse the one persisted trace surface. Replay + `workflow promote` read it.
- **OP-5 Kernel vs non-kernel.** Only the kernel response-gate mandate (PR-12) + the `.claude` hook
  (PR-13) are OWNER-MERGE/OWNER-RUN. Everything else is non-kernel → autonomous fail-closed loop.

## Architecture (5 pillars)
1. **Phase model (data-driven).** `_phases.json` per project: ordered nodes + status + deps. One
   source of truth for: dashboard render, in-order gate, explicit DONE, cascade-invalidation. For
   workflows, the equivalent graph is the YAML `synapses/on-complete` (state machine, legal cycles).
2. **Traversal gate (rigid fixed; explicit DONE; cascade back).** Forward: node K enters only if its
   predecessors are `DONE` (program HALT + crucible `R_WORKFLOW_NODE_ORDER`). Advance only on explicit
   `done`. Backward: re-entering K marks all downstream `stale` (dag `descendants()`), verbosely
   narrated; stale nodes must be re-DONE in order. "In-order" = "next ∈ declared targets" (NOT acyclic).
3. **Skip = never-by-inference.** Interactive skip-attempt → BIG MENU + disclaimer (reuse the kernel
   active-program-interrupt big-box) for explicit human choice. Autonomous (`autonomous-mode` active OR
   `inference-mode ≥ 8` OR `halt-mode strict`) → hard-HALT, no menu. Only sanctioned deviation =
   explicitly entering ADAPTIVE.
4. **Proprioception surface (mandatory, verbose, gate-enforced).** Every turn while a program/workflow
   is active: a narrated block `PROGRAM/WORKFLOW · PHASE NN—NAME · state:{…} · status:{…} · advance:
   mark DONE → NN+1` + always-on next-suggestions + revived `anticipate`. Enforced by `R_STATE_SURFACED`
   (silent-until-activated→BLOCK, per the strict-halt rule) + the kernel response-gate mandate + the hook.
5. **Anti-orphaning liveness gate.** Per OP-3 — the protection that keeps the other four from silently
   regressing as code grows. Adaptive runs are TRACKED (trajectory) + promotable → fixed-workflow
   improvement loop, so rigidity drives improvement instead of stagnation.

## Waves (ordered so no early PR can red the gate)
- **Wave A — foundation:** phase manifest + DONE marker + phase_ledger run_id/workflow + load_state
  reads active-phase + dag `stale`/`descendants()`. (PR-1, PR-2.)
- **Wave B — code-dev enforcement (exemplar):** in-order+DONE HALT, skip big-menu/auto-HALT, backward
  cascade-invalidate, `R_WORKFLOW_NODE_ORDER` (changeset, WARN-first). (PR-3..6.)
- **Wave C — proprioception:** state renderer + `R_STATE_SURFACED` + anticipate/suggestions revival. (PR-7, PR-8.)
- **Wave D — anti-orphaning + cleanup:** liveness gate + wire the 8 orphan rules (shrinks the allowlist). (PR-9, PR-10.)
- **Wave E — generalize + teeth:** Python-ify the workflow runner (cursor/advance-guard/trajectory/
  promote). (PR-11.)
- **Wave F — kernel + hook (OWNER):** kernel response-gate mandate (owner-merge) + `.claude` hook
  (owner-run). (PR-12, PR-13.)

## Risks / gate-safety (from the study)
- Strict halt-mode ⇒ runtime WARN == BLOCK on the kernel gate → runtime rules are silent-until-activated→BLOCK.
- Changeset ctx is thin → `R_WORKFLOW_NODE_ORDER` loads artifacts itself; WARN-first is genuinely safe there.
- Fixed workflows have LEGAL cycles → never enforce acyclic/monotonic; enforce "next ∈ declared targets".
- `.md` is advisory → ship Python teeth; the hook (PR-13) is what makes runtime truly mandatory.
- Every new tool/program/rule in this project must itself pass the liveness gate (no new orphans) + R_NEW_NEEDS_TEST.

## Acceptance — "PLAN is DONE" (gate to PHASE 03 — PR specs)
- [ ] OP-1..5 decided (above). 
- [ ] PR list written + ordered + merge-type tagged (02-prs.md).
- [ ] Each PR maps to ≥1 study requirement; no requirement unmapped.
- [ ] Owner confirms the plan/decisions.
→ On owner "PLAN DONE", advance to PHASE 03 — write 03-prs/PR-NN.md specs in order.

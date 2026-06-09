# Phase 5 — Completion Audit · axon-workflow-discipline

> The project's own final node. Running it closes self-audit gap #1 (declaring "complete" without
> the audit phase would be the exact node-skip this project forbids). Method: re-derive the 11
> binding requirements (01-study.md) against shipped artifacts; classify each by ENFORCEMENT
> REALITY (not just "code exists"); record residual risk honestly. Date 2026-05-29, main `6cbd741`.

## Enforcement-reality legend
- **MECHANICAL** — enforced by a Python tool and/or a crucible changeset rule that BLOCKs at merge today.
- **WARN→BLOCK (pending hook)** — a runtime rule that is correct + tested but silent-until-flag; it
  bites only after the owner installs the host hook (runs `verify.py output`) and flips the
  `L:*-required` flag. WARN-first by design (a runtime WARN would disrupt every output under strict halt).
- **ADVISORY (program)** — lives in an LLM-interpreted `.md` program; real only insofar as the agent
  follows it. The Python tool it calls is the teeth; the `.md` route is the script.
- **DONE** — one-shot change that is fully landed.

## Requirement coverage (R1–R11, binding — 01-study.md)
| # | Requirement (abbrev.) | Shipped | Enforcement reality |
|---|---|---|---|
| R1 | Enforcement = BOTH program HALT + crucible merge gate | PR-3 phase HALT · `R_WORKFLOW_NODE_ORDER` · `workflow_run.advance` | merge gate **MECHANICAL** (WARN→BLOCK on flag); program HALT **ADVISORY** |
| R2 | No skip by inference; interactive MENU; autonomous NEVER | PR-4 `skip_guard.decide` + code-dev `skip` route | decision **MECHANICAL** (pure+tested); the route **ADVISORY** |
| R3 | Mandatory gate-enforced state surfacing + next-suggestions auto-pop | PR-7 `R_STATE_SURFACED` + gap#3 forward-pointer | **WARN→BLOCK (pending hook)** |
| R4 | Kernel allowed (propose; owner merges) | PR-12 kernel mandate, owner-merged `!55` | **DONE** |
| R5 | General, not just code-dev | `R_WORKFLOW_NODE_ORDER`/`workflow_run`/`skip_guard` operate on any `_phases.json`/workflow | **MECHANICAL** (code-dev is the exemplar, not the scope) |
| R6 | Rigid FIXED ⇒ adaptive gets used + flows improve | `workflow_run.advance` (deviation only via adaptive) + `promote` (wired gap#2) | advance **MECHANICAL**; promote **ADVISORY** (program-surfaced) |
| R7 | Verbose narration (not a terse flag) | state-block format + cascade narration + skip menu text | **ADVISORY** (render-time); shape gate-checked by R3 |
| R8 | Adaptive is TRACKED (replay + promote) | `workflow_run.record_step`/`promote` + persistent traj store (wired gap#2) + phase_ledger | **MECHANICAL** at the tool; auto-recording **ADVISORY** (driven by workflow-run.md) |
| R9 | Backward transitions cascade-invalidate downstream, verbosely | PR-2 `dag.cascade_stale`/`descendants` + PR-5 code-dev `back` | cascade **MECHANICAL** (dag); narration **ADVISORY** |
| R10 | Anticipation layer always enforced | PR-8 revive `anticipate` → orchestrator footer + gap#3 gate | revived + surfaced **MECHANICAL**; "every single turn" depends on hook + orchestrator-tick |
| R11 | Anti-orphaning (code grows, features don't go missing) | PR-9 `R_NO_ORPHAN_TOOLS` + PR-10 (8 rules wired) + lock-tests | new-orphan **MECHANICAL** (WARN→BLOCK); see residual #2 |

**No requirement unaddressed.** Every one has a shipped artifact; the honest distinction is
MECHANICAL-now vs WARN→BLOCK-pending-hook vs ADVISORY-program.

## Self-audit findings (the gaps a real audit surfaced) + resolution
- **#1 — the project skipped its own audit phase.** RESOLVED by this document (the dogfood close).
- **#2 — `workflow_run.record_step`/`promote` were built+tested but invoked by NOTHING** (a latent
  *function-level* orphan `R_NO_ORPHAN_TOOLS` cannot see — the tool IS invoked via `advance`).
  RESOLVED `!59`: per-run persistent trajectory + a program-level `--promote` route + post-run hint.
- **#3 — anticipation/next-suggestion was not gate-checked.** `R_STATE_SURFACED` matched only
  `PHASE` + `·`, so a response could pass the state gate without popping the next step (the original
  "next suggestions don't pop" complaint). RESOLVED `!60`: the block must now also carry a
  forward-pointer (`advance`/`next`/`suggest`/`→`).
- **#4 — enforcement is PREPARED, not ACTIVE.** OPEN BY DESIGN (R4 = owner merges/installs). The
  three runtime rules stay WARN-first until the host hook runs `verify.py output` and the owner flips
  `L:state-surfaced-required` / `no-orphan-tools-required` / `workflow-node-order-required` to true.

## Residual risks / known limitations (honest)
1. **Activation depends on the owner.** Until the `.claude` host hook is installed (`!56` proposal),
   the response gate runs by agent-discipline only — R3/R10/R11 runtime rules don't bite. This is the
   single biggest "not yet real" item, and it is intentionally the owner's switch.
2. **`R_NO_ORPHAN_TOOLS` is tool-granularity, not function-granularity.** Gap #2 slipped through it.
   Per-feature lock-tests (anticipate-wiring, promote round-trip) are the backstop, but a *new*
   built-but-unwired function inside an already-invoked tool would not be caught automatically.
3. **Program-level enforcement is LLM-interpreted.** The code-dev `skip`/`done`/`back` routes,
   `workflow-run.md` recording, and the narrated state block are advisory; the Python tools +
   crucible changeset rules are the real teeth. This is inherent to AXON's architecture, not a defect.
4. **`phase_model`/`_phases.json` is the source of truth, but the programs that WRITE it are
   LLM-interpreted** — so manifest integrity ultimately rests on the same hook activation as R3.

## Verification
- FULL crucible gate on `6cbd741`: **21 controls, 0 blocking, 0 warn** (re-run for this audit).
- Every one of the 13 PRs + the 2 self-audit fixes gated green before merge; zero dangling branches;
  `checkpoint/2026-05-29-awd-spine` backup retained.
- New tests this project: phase_model, dag cascade, workflow_node_order, state_surfaced (+forward),
  no_orphan_tools, workflow_run (+trajectory/promote round-trip), skip_guard (9), anticipate (+wiring).

## Verdict — confidence 9/10
Implementation is COMPLETE and the enforcement *substrate* is in place and green. The discipline is
**mechanically enforced at the Python/crucible layer today** and **fully active once the owner installs
the host hook + flips three flags**. The one-point deduction is exactly that activation gap (#4) plus
the function-granularity limit (#2) — both documented, neither hidden. This project ate its own dog
food: full workflow study→plan→pr→log→**audit**, in order, no node skipped.

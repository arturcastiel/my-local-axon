# Project: AXON Workflow Discipline — mechanical phase-order + always-on state surfacing
slug:            axon-workflow-discipline
schema-version:  v4
status:          active
legacy:          false
phase:           3-pr
workflow-step:   pr
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          axon-improvements
sub-projects:    []
created:         2026-05-29
updated:         2026-05-29

## STATUS — 2026-05-29 ✅ IMPLEMENTATION COMPLETE
13/13 PRs merged (11 autonomous + owner PR-12 kernel / PR-13 hooks). Final main HEAD 7178909, full gate
21/0/0. All 11 requirements addressed; the three headline defects mechanically closed. Remaining workflow
node: the completion audit (05-audit.md) — eating-own-dogfood, not yet run. Owner installs the host hook
when ready, then flips the 3 WARN→BLOCK flags (L:state-surfaced-required / no-orphan-tools-required /
workflow-node-order-required). Detail in 04-log.md "PROJECT COMPLETE" + 05-branches.md.

## Working Context
- Fixes two META-defects surfaced while running axon-bug-free, GENERALIZED across AXON:
  1. **Node-jumping in fixed graphs is possible** — the agent skipped plan→pr-specs→audit
     in code-dev. That is the salient example of a GENERAL defect: ANY program or fixed
     workflow with a node graph (steps/phases/DAG) can be traversed out of order, which
     breaks the graph's purpose. FIXED workflows & program node-graphs must be RIGID —
     each node only after its predecessor; the agent must not have the liberty to jump.
     (code-dev's 5-phase ladder is the exemplar, not the whole scope.)
  2. **State/phase is not always surfaced** — AXON narrated next-steps in prose instead of
     always showing where it is. State (program/workflow · node/phase X/N · next) must be a
     MANDATORY, gate-enforced line on every response while a program/workflow is active, and
     next-suggestions must auto-pop.
- **Why rigid (owner rationale 2026-05-29):** if fixed workflows are loosely followed
  (jumpable), nobody ever needs ADAPTIVE mode — and the fixed workflows/programs never get
  improved. Rigidity forces a clean choice: follow the fixed graph EXACTLY, or EXPLICITLY
  switch to ADAPTIVE (the sanctioned home for dynamic next-node selection). Adaptive
  deviations then become the improvement signal for the fixed flows (feed igap/usage).
- Owner decisions (2026-05-29 Q&A):
  - Enforcement = BOTH program HALT + crucible merge gate.
  - Skip = NEVER by inference. Interactive skip → a BIG menu + disclaimer for explicit
    human choice. AUTONOMOUS mode → NEVER skip (hard block, no override).
  - State line = mandatory, GATE-ENFORCED; next-suggestions always-on.
  - Kernel = propose the kernel response-gate change (owner merges); non-kernel auto-merges.
- This project EATS ITS OWN DOG FOOD: it runs the full workflow (study→plan→pr→log→audit)
  in order, no skipping, as the demonstration + fix of its own subject.

## Follow it up
01-study.md (charter + current-state audit + design) → 02-plan.md + 02-prs.md (PR list)
→ 03-prs/PR-N.md (specs) → 04-log.md (impl) → 05-audit.md (completion audit).

## Start with
code-dev load axon-workflow-discipline → read 01-study.md.

# High-Level Plan — Axon Plus
Updated: 2026-06-11 · Iterations: 2 · AXON: 10/10 · User: 9/10 · Mode: tactical

## Context (from Phase 1)
8 hardened goals (A tokens ★ · B discoverability+ · C loop-prompting · D goal-define +
scoped constraints · E workflow designer · F generate-then-drain quality loop · G
model-robustness · H doc hygiene). Codebase: AXON itself. Full goal text: 01-study.md.

## Structure
ONE project, 6 waves (waves = phase files). 27 firm PRs + 2 conditional
(02-prs.deferred.md). Re-plan checkpoint after PR-001+PR-007 (baseline + compile-pilot
data re-validate W1 remainder and set A-targets). PR-009 is the designated fallback
lever if compile savings disappoint.

## Waves
- **W0 instrument+floor** (001–005, all independent): token baseline · execution
  receipts · menu-render check · doc census · census-discrepancy fixes.
- **W1 tokens round 1** (006–009, after baseline): menu aggregation · compile pilot ·
  brief envelopes · program shadows. RE-PLAN CHECKPOINT closes the wave.
- **W2 convergence+goal-define** (010–013): convergence contract + runner · loop
  designer · goal-define mode · scoped-constraints registry + auto-routing.
- **W3 quality-loop+discoverability** (014–018): scan-battery loop (report-only) ·
  autonomy ramp gate · situation triggers · orchestrator footer · phrases rollout.
- **W4 workflow designer** (019–021b): suggester accuracy · run visibility ·
  designer dialogue→yml · synapse generation+tests-or-DRAFT.
- **W5 tiers+docs+bookend** (024–028): weak-tier overlay · conformance scorecard ·
  stale sweep (owner-confirmed deletions) · doc floor+index · final vs-baseline.

## Authorization
Owner 2026-06-11: "work from now autonomously, full grant mode + dev mode."
Autonomous-mode grant (commit/push/pr-create/merge-squash) × AEGIS (develop=grant,
test-execution=green-only, merge=green-only) × dev-mode=true (axon/ writable where a
PR requires it). INVIOLABLE: kernel-core edits human-only · destructive git ops denied ·
crucible green before every merge · stop on red gates or authorization boundaries.

## Constraints carried
Reduce-surface · R13 tests per neuron · won't-do intact · deterministic spine ·
A's protected core as CI (gates/audit/behavior/identity/menu-content) · F autonomy
ramped (3 report-only cycles) · C budgets human-set · H deletions owner-confirmed.

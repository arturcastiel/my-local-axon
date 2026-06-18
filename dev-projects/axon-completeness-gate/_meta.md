# Project: AXON Bug-Free Hardening (completeness gate + arch audit)
slug:            axon-completeness-gate
schema-version:  v4
status:          active
legacy:          false
phase:           pr
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
created:         2026-06-18
updated:         2026-06-18

## Working Context (RE-SCOPED 2026-06-18 — owner: "everything in this project, solve autonomously, top priority bug-free axon")
- Umbrella: fix ALL 18 confirmed architecture findings from the audit
  (phases/study/research/axon-arch-audit.md) — not just the completeness gate.
- Waves: A completeness-gate (source-of-truth) · B R9 kernel-immutability (CRIT) ·
  C enforcement-teeth · D source-of-truth drift wiring · E open-loop/firing · F resume.
- Branch fix/terminal-completeness-gate already carries PR-01..03 (committed, green-in-scope).
- HARD CONSTRAINTS: gates cannot be broken (no --force; crucible-green before merge/test-exec);
  NO KERNEL-SLIM.md edits; settings.json/enforce.py changes are enforcement-config, tested hard;
  every PR ACTIVE-with-tests (Core Rule 13); AXON-only commit trailer.

## Original Working Context
- ORIGIN: surfaced by the axon-hr build (2026-06-18). A code-dev `plan` phase was marked
  `done` while its DECLARED output (03-prs/DAG.json) was never emitted — and NO gate caught it.
- GENERAL PRINCIPLE this project enforces: a terminal-status transition (done/complete) must
  verify the node's DECLARED POST-CONDITIONS (its outputs/effects exist), not only its
  PRE-conditions (deps/order). "check-running gates are sound; label-advance transitions are vulnerable."
- PARTIAL FIX ALREADY IN TREE (tools/phase_model.py): done() now gates on a hardcoded
  REQUIRED_OUTPUTS map + tests (tests/test_phase_model_outputs.py). UNVALIDATED until crucible green.
  Its weakness (residual #5): the map is DECOUPLED from what programs actually declare -> can drift.
- GOAL: generalize to a single principle driven by the source of truth programs ALREADY declare
  (the `# outputs:` header, parsed by the program-entry preamble). Apply at: phase-model.done,
  the program DONE shorthand (as a TOOL + verifier RULE, NEVER a KERNEL-SLIM edit), and
  workflow_run.advance (add a node `outputs:` schema + verify before recording 'ok').
- HARD CONSTRAINT (owner, 2026-06-18): "gates cannot be broken" — no --force bypass, crucible-green
  before any test-execution (AEGIS green-only), and NO kernel (axon/) edits (inviolable floor).
- Next: code-dev study (deep) -> read the sites, design the `# outputs:`-driven guard.

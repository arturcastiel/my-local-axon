# Phase 2 — PLAN · super-polish

> Multi-agent bug-hunt, executed via the Workflow tool (find → adversarially verify → synthesize), then
> SERIAL gate→branch→merge for fixes (the established discipline). Owner-gated launch ("get back to me").

## Wave 1 — dimensional bug-hunt  (parallel, 1 agent per subsystem)
Each agent deep-reads ONE subsystem (see study list), returns candidate bugs as structured findings:
{file, line, severity, claim, repro/why, suggested_fix}. Grounded at file:line, no hand-waving.

## Wave 2 — adversarial verification  (parallel, per finding)
Each candidate gets ≥3 independent skeptic agents prompted to REFUTE it (default: refuted unless proven).
A finding survives only if a majority cannot refute it. Kills plausible-but-wrong bugs before they cost a PR.

## Wave 3 — "ensure only what we have works"
For every ACTIVE tool/program: verify it actually FUNCTIONS on a real input (not just --help/import).
Flag dead / half-working / vestigial ACTIVE entries — the "only what we have works" guarantee. Produces a
ranked list: works / broken / dead.

## Wave 4 — triage + fix  (serial, gated)
Confirmed bugs → gated PRs, highest-severity first, branch-first, crucible-green, merge by number. Each
fix ships a regression test (Core Rule 13). A bug too large/risky for a quick fix → its own held item.

## Execution notes
- Waves 1–3 = the Workflow tool (parallel agents). Wave 4 = my serial merge loop.
- Scaled to "be comprehensive": larger finder pool + the full adversarial pass + a completeness critic
  ("what subsystem/claim did we NOT cover?") before closing.
- Appended, separate track: rule-rationalization-plan.md (the destructive-git-op rule).

## Gate to execution
Owner greenlight (the "get back to me"): review this plan, then I launch the bug-hunt workflow.

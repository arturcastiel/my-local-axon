# Phase: 4-eval
schema-version: v4
status:         planned
workflow-step:  not-started
branch:         main
current-pr:     (none)
created:        2026-05-23
predecessor:    1-telemetry
successor:      5-benchmark, 6-ecosystem
source-audit:   /home/arturcastiel/projects/axons-audit/recommendations/IMPROVEMENTS.md

## Scope (full detail in ../../masterplan.md § 4-eval)
- Lever #5/#11: tools/axon_eval.py — fixture → run → capture trace → diff vs
  golden. SEED CORPUS = axon-polish Phase-5's 16 e2e scenarios + drift/igap/usage.
- Feature #8: time-travel replay (replay <checkpoint-id> over CHECKPOINT +
  E:session-log + SNAPSHOT(W:))
- Lever #2 / Fruit A: fix axon-compare to compute scores from its own
  web-search results (still hardcoded as of 2026-05-23)

## Note
Highest internal-leverage — compounds the axon-polish work directly and
unblocks 5-benchmark. The audit calls the eval harness "the single most
strategic lever."

## Start with
code-dev load axon-ascent → code-dev phase start 4-eval

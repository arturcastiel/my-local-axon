# Phase: 5-benchmark
schema-version: v4
status:         planned
workflow-step:  not-started
branch:         main
current-pr:     (none)
created:        2026-05-23
predecessor:    4-eval (HARD dependency — needs the eval runner)
successor:      (none — terminal)
source-audit:   /home/arturcastiel/projects/axons-audit/recommendations/IMPROVEMENTS.md

## Scope (full detail in ../../masterplan.md § 5-benchmark)
- Lever #14 / Feature #22: SWE-bench Lite first, then Verified. AXON as
  scaffolding around a fixed model. New repo axon-bench.
- Produces the public number that substantiates "harness scaffolding >
  model capability" — the thesis-prover + contributor-bait.

## Blocked on
4-eval must ship axon_eval.py first (it is the benchmark runner substrate).

## Start with
code-dev load axon-ascent → code-dev phase start 5-benchmark

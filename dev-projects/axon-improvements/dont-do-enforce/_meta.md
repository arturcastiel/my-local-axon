# Project: Dont-Do Enforcement — hard, fail-closed prohibition gate
slug:            dont-do-enforce
schema-version:  v4
status:          active
legacy:          false
phase:           1-design
workflow-step:   plan
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          axon-improvements
priority:        HIGH   # owner directive 2026-05-27 — make this a priority
created:         2026-05-27
updated:         2026-05-27

## Working Context
- PROBLEM (owner hit it in opm-development/axon; caught only by a human reviewer, twice):
  AXON enforces its OWN kernel rules HARD (Tier 1 — verify.py / crucible, fail-closed),
  but project `_dont-do` prohibitions are SOFT — advisory + opt-in. code-dev-review-diff §3
  greps the diff for prohibition phrases, but ONLY if invoked and ONLY if the prohibition was
  written as a grep token. A recorded design constraint slipped because it was prose (no token)
  and the review step is optional.
- GOAL: promote `_dont-do` from Tier 2 (soft/opt-in) → Tier-1-class (HARD, fail-closed,
  ALWAYS-ON). Prohibited diffs BLOCK merge/push — not just get reported.
- MOST CONSERVATIVE (owner directive): FAIL-CLOSED. A prohibition that can't be mechanically
  checked (prose-only, no token) → the gate BLOCKS and demands a token, never silently passes.

## Start with
Phase 1-design: spec the `_dont-do` token schema + the `R_DONT_DO` crucible control (BLOCK) +
always-on wiring into the crucible gate. Then build with tests (R_NEW_NEEDS_TEST).

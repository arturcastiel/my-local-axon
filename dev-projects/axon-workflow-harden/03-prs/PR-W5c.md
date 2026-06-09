# PR-W5c — multiple-code-dev: end-to-end multi-lap loop test (H4)

> **✅ MERGED — !148 (`d976a44`), gate GREEN (passed:true, 0 blocking, 0 warn).** Verified on main (22 loop
> tests green). Branch deleted. **Closes the W1–W5c campaign.** M2 is the lone deferred runner-hardening follow-up.

- **Status:** merged !148
- **Phase:** 2-harmonize · **Complexity:** S (test-only) · **Closes the W5 rebuild's proof.**

## What W5c does (H4 — the test the mirage never had)
Drives the REAL `multiple-code-dev.yml` through the runner's `advance` guard for 3 laps of the s2 (code-dev
sub-workflow) node, asserting the per-lap anti-skip bites EVERY lap on the actual workflow:
- before each lap's code-dev runs, the guard REFUSES `s2 -> s3` (this lap's sub-trajectory is empty);
- lap-1's completed sub-trajectory NEVER satisfies lap-2 (the C2 stale-skip vector, on the real workflow);
- each lap persists its OWN sub-trajectory file (no append corruption / WorkflowJumpError — C3);
- mirrors workflow-run.md exactly: lap-1 → bare id, lap≥2 → `::v{lap}`.
Plus pins the s4 decision routing (C4): green + abort → the s6 finalize terminal, iterate → s5.

This closes the audit's **H4** ("NO test drives the loop; the 10 green iters were an external helper
hardcoding `advance(s4→s6)`"). The loop is now proven end-to-end on the real runner path, not by grep.

## Deferred — M2 (explicit-terminal hardening) → its own runner-hardening PR
`terminals()` still treats a synapse that merely FORGOT its `on-complete` as a legal terminal — a sub-run
stopping at an unwired mid-node reads as "completed" (a forgery vector). The real fix requires an explicit
`terminal: true` schema field + migrating EVERY existing workflow's terminals + making `terminals()` REQUIRE
it (rejecting implicit empty-on-complete) + a lint. That is a BREAKING schema-migration affecting all
workflows — genuinely separate scope from the multiple-code-dev rebuild, MED priority (robustness, not a
loop-correctness blocker). Tracked as a follow-up; NOT silently dropped. See memory + 04-w5-design.md M2.

## Acceptance
1. The loop drives ≥2 laps on the real workflow with per-lap anti-skip; lap-1 never satisfies lap-2. ✓ (3 tests)
2. `crucible gate` passed:true. — pending

## Changes
- `tests/test_multiple_code_dev_e2e.py` (new, 3 tests — H4 e2e drive + the C2 stale-skip vector + C4 routing).

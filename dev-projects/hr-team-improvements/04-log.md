# 04 — Log: HR-Team Improvements

## SESSION START — 2026-06-22T08:20:00Z
project:  hr-team-improvements   phase: study   workflow-step: build
branch:   fix/wave-g-residual-hardening
seeded:   from axon-rearm META-FINDING + owner cross-session confirmation. Study DONE at seed.
next:     code-dev plan → PR backlog (5 fix vectors). Lead = propagate fail-closed guard to for-use checkout.

## 2026-06-22 · test-suite council + executed verdict
Ran a 26-agent council (15 investigators → consolidate → 5-seat propose → 5-seat vote) over all 359 test
files / 4723 tests. 1.31M tokens. Report: research/test-suite-council-2026-06-22.md.
Verdict (conservative bar held): only 2 of 4723 surfaced — PRUNE 1 (tautological dispatch metrics test,
unanimous) + MERGE 1 (liveness CLI test, 4-1, dissent preserved). Plus the council-recommended liveness
dedup (shared resolve fixture). Executed on branch chore/test-council-actions → MR !179. Full gate green.
Net ~60s off the suite, zero coverage lost. Bigger win (xdist parallelism) scoped separately.

## 2026-06-22 · xdist gate parallelization (MR !180)
The council's "real fix" (parallelize, don't delete). Suite proven race-free under 12 workers
(naive -n auto: 4708 pass / 0 races). Crucible pytest control -> `-n auto`: ~8:43 -> ~3:30 (~2.5x).
3 files, zero test logic touched. Gate "failure" was NOT flakiness — adding pytest-xdist to pyproject
tripped test_requirements_intent (declared-deps-must-be-imported-or-whitelisted); xdist is a plugin →
whitelisted (1 line). Measure-don't-assume corrected the wrong "revert it, it's flaky" conclusion.

## 2026-06-22 · parallel gate: flaky → root-caused → fixed (MR !181)
The xdist gate (!180) was flaky AS A GATE (1 red / 4 runs on merged main) — caught by the post-merge gate
(per-branch greens don't cover a merged combo). Root cause: pytest CACHE races across xdist workers (the one
var differing green-vs-red was -p no:cacheprovider). Fix (!181): gate cmd -> `-n auto -p no:cacheprovider`.
Verified 9/9 green cache-disabled (5 dedicated + 3 prior + 1 gate-context) vs 1 red cache-on.
main gate now ~8:43 serial -> ~3:35 parallel (~2.4x), RELIABLE. Serial fallback (fix/gate-serial-restore)
pushed as insurance, now superseded/unmerged. Lesson: gate the MERGED state, not just branches; and the
diagnostic data (not a guess) found the cause.

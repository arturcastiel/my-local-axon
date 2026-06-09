# Phase 5 — Completion Audit · axon-alias-retire (F30)

> Date 2026-05-30, main `4756df4`, gate 22/0. The highest-risk of the five (conf-6). Verdict: the
> gating safety net is delivered; the breaking steps are correctly held.

## Verdict
**The prerequisite is done; retirement is now SAFE TO DO LATER — and was correctly NOT forced now.**
Confidence **8/10** in the decision (deduction: the program layer still has no LLM-execution test, so
the eventual repoint will need human/agent validation, not just the gate).

## Coverage vs the plan
- **PR-1 harness** — ✅ delivered. Dispatch-resolution + alias-integrity + warn + canonical-consistency
  + inventory lock. This is the F05 program-dispatch test gap, closed for the alias surface.
- **PR-3 deprecate-warn** — ✅ already satisfied (all 18 aliases warn on use; verified, then locked by
  the harness). The metadata bug (self-review's stale canonical) was fixed.
- **PR-2 repoint** — ⛔ HELD. Modifies the LLM-interpreted dogfood harness with no execution-test to
  catch a routing regression; 1 alias has a side effect a naive repoint would drop. Not safe to force.
- **PR-4 delete** — ⛔ HELD. Next-release per design, after repoint + a deprecation window.

## Why holding is the right call (not a shortfall)
F30's own study mandated "tests FIRST … delete NEXT release" and rated it the riskiest. The aliases
work and warn today; nothing is broken. The valuable, safe move is the safety net + locked invariants,
which is exactly what shipped. Forcing the repoint/delete would trade a working system for an
optimization, against "nothing breaks" and without the execution-test the study says is the gate.

## The remaining retirement cycle (de-risked, for a validated run)
1. Repoint code-dev.md's 17 pure-forwarder EXECs to their canonicals; handle code-dev-self-review's
   STORE explicitly (or leave that one alias). Validate by actually running code-dev (LLM), not just
   the gate.
2. Leave a deprecation window (aliases already warn).
3. Delete the 18 aliases + their REGISTRY/quarantine entries; the harness's inventory lock + resolution
   tests will catch any dangling dispatch.

## Bonus finding (out of scope, logged)
A repo-wide EXEC-resolution test would also be valuable (F05 broadly) but needs output-string-aware
parsing — 2 benign false positives today (`glossary`/`quickstart` print `EXEC(...)` examples inside
OUTPUT strings). Noted for a future dispatch-harness widening.

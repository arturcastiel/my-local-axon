# Phase 5 — Completion Audit · axon-compile-decision (F34)

> Date 2026-05-30, main `413cb29`, gate 22/0. Method: state the decision, the evidence, and what was
> shipped vs deliberately left.

## Verdict
**Decision delivered: KEEP the compile subsystem; rot-proof it.** This is a complete F34 outcome — the
project's deliverable was the *decision*, made on measured evidence rather than the study's stale
assumption, plus the one hardening that the decision implies. Confidence **9/10** (deduction: the RED
tier reflects uneven compiler quality that's tolerated, not fixed — acceptable, now ratcheted).

## Evidence that overturned the study
| Study assumption (lean RETIRE) | Measured reality |
|---|---|
| "118 verbatim 1.00-ratio copies" | 0 verbatim; median byte-ratio ~0.74; already gated by test_compiled_regression |
| "the flagship target got worse at 1.01" | code-dev compiles to 0.214 bytes / 0.898 tokens — RED on tokens but a real saving |
| "dispatch barely uses it" | run.py executes .cmp.md (C-layer); dispatch.py routes to compiled programs (prefer-compiled) |

## Shipped
- The decision (KEEP), recorded with evidence.
- `test_compiled_quality_ratchet.py` (!91): enforces audit_compiled's documented-but-unenforced RED
  "gate target" — RED count can't grow past 13. This is the durable value: the corpus is now protected
  from silently degrading toward the verbatim state the study feared.

## Deferred (low value / would risk a working system)
- A new compressor to push RED→0 (speculative; current RED still saves tokens; short-program overhead).
- Consolidating the 5 compile tools into one (churn/risk, no functional gain).

## Honest note
The most important thing F34 produced is a *corrected belief*: the compile subsystem is healthy and
load-bearing, not dead weight. Acting on the stale study (retiring it) would have broken dispatch+run.
The measurement-first discipline (PR-1 before any change) is exactly what prevented that.

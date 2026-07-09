# Implementation Log — axon-compile-decision (F34)

> The project's core was a DECISION (retire vs repair the compile subsystem). PR-1 was a measurement;
> the measurement overturned the study's premise, so the decision flipped to KEEP + harden.

## Measurement (PR-1, the decision input) — 2026-05-30
Authoritative `audit_compiled.py` on the live corpus (38 compiled programs):
- **Compression is real:** median byte-ratio ~0.74, median token-ratio ~0.77; range 0.095–0.97.
  GREEN 11 / YELLOW 14 / RED 13. **0 verbatim** (the study's "118 verbatim 1.00-ratio copies" is stale).
- **Verbatim is already gated:** `tests/test_compiled_regression.py` forbids 0%-ratio passthroughs and
  requires genuine token savings (cmp ≤ src). The feared failure mode can't recur.
- **It is actively used:** `run.py` is "the executor for compiled .cmp.md programs (C: architecture)";
  `dispatch.py` routes prompts to compiled programs via a TF-IDF index with a `prefer-compiled` switch.
  Not "exists only to satisfy a freshness test."

## Decision: **KEEP** (neither retire nor major-repair)
Both RETIRE premises were false (not verbatim, not unused). Retiring a working, used C-layer runtime
would *break* dispatch + run — a "nothing breaks" violation. Major-repair (a new compressor) is
unjustified: the corpus already compresses.

## Merged
| PR | MR | What |
|----|----|------|
| PR-1 (measure→decide) | — | measurement only (no code); decision recorded: KEEP |
| PR-2 (harden) | !91 | `tests/test_compiled_quality_ratchet.py` — enforce the RED tier that audit_compiled documents as the "gate target" but never gated: RED count may not grow past baseline 13 (stable under tiktoken and the //4 fallback). Closes the "corpus rots back to verbatim" risk. |

**main 413cb29 · gate 22/0.**

## Not done (deliberately)
- **New compressor / drive RED→0:** the 13 RED programs still save tokens (ratio<1.0); several are
  short programs where header overhead dominates. Forcing better compression is speculative repair with
  little gain — left as optional future tuning, now ratchet-protected from regressing.
- **Consolidate the 5 compile tools:** they work; consolidation is churn/risk for marginal benefit.
- 2026-07-09: pointer-repair (axon-stale-pointers): _meta.phase advanced to 'audit' (was behind a done phase)
- 2026-07-09: pointer-repair (axon-stale-pointers): status active->complete — MANIFEST-BACKED closeout (every phase done); the project was finished but never closed out (the inverse of the unbacked-claim class).

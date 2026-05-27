# Masterplan — AXON Memory Key Wiring Gaps

## Phase graph (directed)

- **1-design** — study + audit + fix the known gap; produce audit registry
   → (no downstream phases declared — single-phase project unless audit
      surfaces enough work to warrant a 2-* phase)

## Out-of-scope

- W:active-phase template-substitution leak — that's covered by the
  separate project sketch `axon-phase-substitution` (designed earlier
  this session, not yet scaffolded). Two distinct bug classes:
    · this project = read/write topology gaps (key not wired upstream)
    · that project = substitution-engine leak (literal {var} stored)
  Keep them separate to keep audit signal clean.

Phases are added by: code-dev phase new

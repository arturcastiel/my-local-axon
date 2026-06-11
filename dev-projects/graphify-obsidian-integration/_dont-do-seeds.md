# Project-wide prohibition seeds

These seed each new phase's `_dont-do.md` on `code-dev phase start`. They encode the
non-negotiable boundaries this integration must respect — most derived from the study's
reconciliation of the handoff against AXON's recorded design decisions.

- **DO NOT chase RAG-maturity to 70/70.** Dense embedding index, hybrid/RRF fusion,
  query-expansion/HyDE, multi-hop are WON'T-DO by design (workspace/AXON-DOCS-RAG-DEVELOPMENT.md,
  2026-06-09). 58/70 is a deliberate sparse ceiling, a diagnostic — never a target. Any handoff PR
  whose justification is "raise the RAG score" is out of scope here.
- **DO NOT adopt the handoff's 70+ PR / 8-phase plan wholesale.** The handoff itself calls it
  "tactically over-ambitious as a single project." This AXON reduces surface; net new tools must
  earn their keep against that.
- **DO NOT write to `axon/` (kernel)** under any circumstance without an explicit owner dev-mode
  flip. Kernel edits are the inviolable floor — human-only, never delegable.
- **DO NOT introduce non-determinism into the retrieval/decision path.** AXON removed embeddings
  precisely because non-deterministic recall broke "every action traceable." Graphify is admissible
  ONLY in its deterministic AST mode; its optional LLM-extraction backends stay off by default.
- **DO NOT let a Graphify outage break a workflow.** Every Graphify call must fail-degrade
  (RETRY max=2 → sparse/grep fallback + LOG(WARN)), never fail-fast.
- **DO NOT add a tool without its test + `## Guarded by` doc block + a program that invokes it**
  (Kernel Rule 13 / R_NEW_NEEDS_TEST / R_NO_ORPHAN_TOOLS / crucible gate).
- **DO NOT preserve the handoff's stale numbers.** Baseline is 58/70 (this repo), not 40/70;
  the codebase is `/home/arturcastiel/projects/new-axon/axon`, not the handoff's authoring checkout.

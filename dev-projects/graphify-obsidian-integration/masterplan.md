# Masterplan — Graphify × Obsidian integration

> Phase structure agreed in the study debate (2026-06-09). Owner finalises the PR breakdown in the plan phase.
> Architecture: **adopt Graphify** (pinned, OPTIONAL extra) · destination **D2** (whole-repo organized /
> navigable / clustered + Obsidian) · governing partition = **deterministic spine drives gates; LLM
> prose-semantics are advisory-only.** Full rationale + decisions: `01-study.md` §12.

## Phase graph (directed)
```
1-study (DONE) → P1-code-spine ┬→ P2-organize-deterministic → P3-llm-overlay (opt, AEGIS-gated) → audit
                               └→ P-CD  code-dev × graphify on TARGET repos (study→plan→impact→review→test + workflows)
```
(P-CD is additive to P1 — it consumes the same deterministic graph builder, just pointed at the *target*
repo code-dev is working on instead of AXON's own `tools/`. Full spec: `study/code-dev-integration-design.md`.)

## Phases
- **P1 — Deterministic code spine (D1).** Graphify code-only AST graph over `tools/*.py` (+ addons);
  **fix K2** (`code-dev-knowledge-impact` blast-radius — the live bug); god-nodes / dead-code.
  Deterministic, $0, no API key. Guardrails: pin `0.8.36`, `.graphifyignore`, fail-degrade.
  Proves the dependency on the safe code subset before widening.
  - **PR (P1, owner directive 2026-06-09):** declare `graphifyy` (pinned) in AXON's install path so a
    requirements install pulls it. **Recommendation:** a pinned **optional extra** (`axon[graphify]` /
    `requirements-graphify.txt`), NOT core `requirements.txt` — §20 single-maintainer fast-churn dep;
    keep the base install resilient. Owner decides core-vs-extra in the plan phase.
- **P2 — Deterministic organization (D2).** Leiden clustering over the graph; **merge** AXON's existing
  deterministic program/markdown graph (`deps`/`call_graph`/`synapse`) and **link** at the program↔tool
  boundary; **Obsidian visual map (K4)** rendered from the merged `graph.json`; confidence tags read from
  typed `links` **(K3)**. Still deterministic, $0, no key. **This phase delivers the "organize better" outcome.**
- **P3 — LLM semantic overlay (COMMITTED, gated, built last).** LLM-extracted prose-semantic edges from
  markdown / docstrings / PDF; INFERRED/AMBIGUOUS, **advisory-only, never on a gate**; behind an AEGIS
  grant **(K6)**. Needs API key + network + token budget. **In scope from the start** (owner directive
  2026-06-09 — overrides the study's "defer" lean); built after P1–P2 because it enriches the deterministic
  graph, and D2's organize-better outcome does not *depend* on it.
- **P-CD — code-dev × Graphify on TARGET repos (first-class track).** Build the target-repo graph ONCE at
  study (`graphify build` at `code-dev-study` line 96), persist per-project, reuse through every phase. 6 surfaces
  (all effort M, fail-degrade, advisory, confidence-tiered): **study/shadow** (explain/neighbors before grep) ·
  **plan/DAG** (fills the deprecated semantic-search slot; code-derived `depends_on` → `dag.py`) ·
  **impact** (REPLACES the live-broken blast-radius — 2 defects today) · **review** (caller cone before build) ·
  **test-map** (real call-based coverage vs filename heuristic) · **workflows** (`s0 graphify-map` pre-step +
  `graphify-query` adaptive synapse). Start with the **impact fix** (smallest, fixes a live bug). Reuses
  shadow/dag/project_graph — no replacement. Full design: `study/code-dev-integration-design.md`.
- **audit.** `rag-maturity-audit` stays **58/70** (regression guard, NOT a target); determinism gate
  (two builds byte-identical); won't-do line intact.

## Cross-cutting
- **K3** confidence discipline woven through P1–P3 · **K5** pin + upstream-watch governs the dependency.
- Inviolable: no `axon/` kernel edits without owner dev-mode · no autonomous execution (owner drives the build).

## Open before plan
- A **spike / re-validation (R1)** to lift the study L3 → L4 (real numbers on THIS repo) — see 01-study §8.
- First-PR pick (K2 is the smallest, fixes a live bug, validates the loop).

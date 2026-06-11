# Reconciliation ledger — handoff sections × AXON design fit

> Output of the 17-agent parallel study (2026-06-09). Per-section fit verdict against THIS repo's
> design (deterministic / anti-fabrication / reduce-surface) and the 2026-06-09 won't-do decision.
> `fit`: aligns | tension | contradicts | neutral. `wontdo`: collides with the dense-RAG won't-do line.
> Use this to triage the handoff during the plan phase. Source: `tasks/w6q9c8h0p.output` (full JSON).

## Section verdicts (round 1–3, §01–§23)

| § | Title | Leverage | Fit | won't-do | Verdict for THIS AXON |
|---|---|---|---|---|---|
| 01 | Graphify primer | med | aligns | no | Deterministic AST graph + EXTRACTED/INFERRED/AMBIGUOUS tags map onto R6. Keep as substrate concept. Risk: non-deterministic doc/media extraction path must stay below gate-precondition use. |
| 02 | Obsidian primer | low | tension | **yes** | Viewer framing fine; but proposes ripping out `doc_anchors` line-anchors for wikilinks (tears out a deterministic invariant) and reframes 58/70 as a dashboard to drive up. EXCLUDE those two. |
| 03 | Agnostic harness integration | med | tension | no | Best-grounded section — cap-by-mechanism + mcp-servers.json merge are REAL. But adds 4 caps + bridge + conformance machinery vs reduce-surface. CLI examples stale. |
| 04 | Program inventory | med | tension | **yes** | Useful "leave-alone" list (identity/dev-mode/mode-system/undo). But flags rag-master-plan (DELETED) + retrieval-eval as Graphify targets — won't-do zone. |
| 05 | Workflow inventory | low | contradicts | **yes** | Centerpiece is rag-master-plan.yml driving audit→70 (forbidden) AND only 2 of 4 named workflows exist here. Residue: the degrade-not-fail / state-surface risk register. |
| 06 | code-dev deep dive | med | tension | **yes** | Vault overlay + confidence-edge ideas align; but proposes REPLACING shadow.py/test-map with a semantic index + per-PR "RAG rows" + a 16-PR external dep. Salvage: vault overlay only. |
| 07 | Tools registry mapping | low | contradicts | **yes** | 3 wrapper tools could align; 4 kernel tools (retrieval_index/search_dense, fusion/RRF, chunking, query_planner) rebuild the won't-do stack. "never deprecate kernel/governance" restraint is the good part. |
| 08 | RAG maturity closure | low | contradicts | **yes** | Stale 40/70 baseline (live 58/70); flagship rows B1/B3/C1/C2/B6 are exactly won't-do. One ok idea: audit must require *wired* behavior + falsifier tests, not credit-by-file. |
| 09 | Self-introspection | med | tension | no | **Most design-fitting analytical idea**: god-nodes, why-index, community/centrality are net-new deterministic audits AXON lacks. But its "replace" column targets tools AXON already ships. Harvest the NEW-audit ideas as extensions, not swaps. → **K1**. |
| 10 | Obsidian vault plan | med | tension | no | Reproducible vault config aligns; but frontmatter migration is mis-scoped (comment-blocks, not YAML), assumes Graphify exists, and cites a wrong log path. → use **K4 exporter** instead. |
| 11 | PR series (60 PRs / 8 phases) | low | contradicts | **yes** | The implementation backbone — but its organizing metric IS RAG 40→67. Phase 1 (dense+graph index, RRF) + Phase 4 (HyDE/multi-hop) are the won't-do core. Salvage: Phase 2 audits + Phase 3 provenance, decoupled. Also: commit trailer leaks a brand id (violates AXON commit-trailer rule). |
| 12 | Risks & governance | med | aligns | yes (1 gate) | **Strongest part for THIS AXON**: confidence-propagation defense-in-depth reinforces R6; AEGIS/autonomy/privacy mitigations fit. Drop only the Phase-1 acceptance gate that makes the score a target. → **K3**. |
| 13 | Empirical validation (R2) | low | tension | **yes** | Good anti-fabrication method; but anchored to stale 40/70 + "absent future tools = Graphify gap" framing. Live: 58/70, rerank present, 157 tools. |
| 14 | Graphify internals (R2) | med | aligns | no | **Most evidence-dense**: code-only path is genuinely deterministic (seed=42, lexicographic, total-order community IDs, built_at_commit). Honest about bus-factor, ~1.4 rel/day, unpinned MCP, SSRF hole, 11.6k-line extract.py. → pin posture **K5**. |
| 15 | Obsidian community patterns (R2) | med | tension | **yes** | Cautious + useful (avoid Copilot, git-sync, Linter complementarity, Bases-is-core). But §15.2 recommends Smart Connections = dense embedding index = the removed mechanism. EXCLUDE §15.2. |
| 16 | AXON corner coverage (R2) | med | aligns | no | Treats Graphify as a structural index that LAYERS ON (compiler ops, LANG relations, addons) — correctly says re-scope PR-GFY-204 to "layer not replace". No won't-do moves. |
| 17 | Alternative use cases (30 UCs) | high | tension | no | High-fit subset (UC-10 governance dashboards, UC-06 PR-impact gate, UC-01 onboarding tour) genuinely aids resilience/expandability, advisory-first. Tension: ~90 PRs vs reduce-surface; UC-14 memory-as-graph is privacy-heavy. Triage to a small subset. |
| 18 | Competitive landscape | med | tension | **yes** | Tool-selection verdict aligns (Graphify is the only deterministic+confidence+MCP+Obsidian+MIT option). §18.7 "build in-house" smuggles HyDE/RRF/query-planner back in — EXCLUDE those. |
| 19 | Empirical PoC (R3) | high | aligns | no | **Real run, real numbers**: tools/ → 2,995 nodes/6,410 edges/5m33s/99.3% EXTRACTED/$0; 100% edges confidence-tagged. Operational gotchas: `.graphifyignore` mandatory (full-repo killed at 9min); read `links` not `edges`; exit-code lies (parse stdout); use exact node IDs (free-text matched wrong tool). |
| 20 | Version-pin posture (R3) | high | aligns | no | Conservative containment of a fast single-maintainer dep (optional extra pin, human-only pyproject merge, weekly watch, pivot triggers). Raises resilience w/o core bloat. → **K5**. SDK-free mcp_client verified. |
| 21 | Bases vs Dataview interop (R3) | med | aligns | no | **Cleanest fit**: "one impl per dashboard" + duplication lint + graceful degradation; frontmatter (not dashboard syntax) is source of truth; no embeddings. → **K4**. |
| 22 | MCP live protocol test (R3) | med | tension | no | All 10 MCP tools work over stdio; HTTP is stateful Streamable-HTTP. But confidence is **lossy bracketed text** over MCP (weakens R6), 3 failure shapes incl. success-shaped "Error:", needs LLM key for docs. → argues for the **CLI/graph.json path over the MCP server** (typed confidence in `links`). |
| 23 | Round-3 confidence synthesis | — | — | — | 0.95 ledger. Measures "buildable as written", NOT "should THIS AXON build it" — see study §9. |

## Probe verdicts (8 live-repo grounding probes)

| Probe | Verdict | Key finding |
|---|---|---|
| rag-substrate-reality | **refuted** | 58/70 not 40/70; B1/C1/C2 rows are the won't-do rows; graphify=0 refs; 6/7 tools absent; embeddings already removed on principle. |
| rag-master-plan-removal | **refuted** | Deleted in `01392b2`; score unchanged → "pure scaffolding". Graphify never existed in git history. |
| introspection-tools-overlap | **partially-true** | **Crown finding.** The 6 tools graph markdown/registry, NOT Python AST → Graphify can't replace them. Real gap: nothing maps the Python tool layer (blast-radius of a helper edit is invisible). → **K1**. `call_graph.py` misnamed (graphs programs). |
| harness-cap-flag-surface | **partially-true** | 6 fixed `host-cap-*` mechanism enums + conformance gate are real; but `graphify-mcp-url/out-path` are config (→ `host-mem-dir` precedent), not caps. Don't pollute the enum contract for an unadopted feature. |
| mcp-aegis-infra | **partially-true** | AEGIS `web: grant` reusable as-is (fail-closed, 1 line). But `mcp_client` is stdio-only → no-kernel path is graphify-as-stdio-subprocess; HTTP MCP needs deferred v2 transport. |
| frontmatter-synapse-state | **partially-true (over-scoped)** | ~169 comment-block synapses; parsers comment-anchored; full migration 196 files/~39–50h/GUI-only; replacing comments breaks parsers. → build a **one-way exporter** (`obsidian_sync.py`, ~8–10h), not a migration. → **K4**. |
| code-dev-graph-awareness | **partially-true** | 90 code-dev progs; shadow has no AST. **Live bug**: `code-dev-knowledge-impact.md` reads `symbols.exported` shadow never emits → empty blast radius. Narrow real win. → **K2**. dag.py already does PR-level dependency planning (reuse). |
| tool-count-and-gates | **refuted (premise) / gated** | 157 tools (137 ACTIVE) not 153; tree-sitter not installed; a new ACTIVE tool must clear R_NEW_NEEDS_TEST + crucible + liveness + registry-drift + Guarded-by + synapse contract; MCP allowlist bans write flags. Reduce-surface argues for in-house `ast` (Path B). |

## Crosswalk: KEEP set → handoff sources
- **K1** tool-layer AST graph ← §09 (new audits) + introspection-overlap probe + §16 (layer-not-replace)
- **K2** blast-radius fix ← code-dev-graph-awareness probe (the `symbols.exported` bug) + §06
- **K3** confidence discipline ← §12 + §01 + §19 (100% tagged edges)
- **K4** Obsidian projection ← §21 (pick-one + lint) + §10 (vault) + §15 (Bases) + frontmatter probe (exporter)
- **K5** pin/resilience ← §20 + §14
- **K6** AEGIS reuse ← §12 + mcp-aegis probe

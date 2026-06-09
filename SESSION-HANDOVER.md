# SESSION HANDOVER — 2026-06-09

> Supersedes the 2026-05-27 handover (that session's work is on `main`).
> Codebase: `/home/arturcastiel/projects/new-axon/axon` · my-axon symlinked in.
> **All code this session is committed + pushed to `origin/main`.** Tree clean, gate green.

## 1. What this session did — the RAG (aoxn-rag) incorporation + right-sizing

Incorporated the online `aoxn-rag` branch and built out a deterministic, model-free
retrieval-evaluation toolkit, then **right-sized it to AXON's design**. 13 commits,
`5e786b1 → 01392b2`, every one crucible-green.

**Landed + kept (genuine wins):**
- Guarded MCP exposure of retrieval-eval/rag-maturity-audit — **closed a live write hole**
  (`--append-log`/`--root` were reachable read-only over MCP).
- `list-tools` registry-purpose fallback — un-blanked ~142 tools.
- Structural chunker (`retrieval-eval chunk`) — killed library-dev-ingest's `raw-text[0..8000]`
  truncation; citations now point at section chunks.
- The deterministic **retrieval-eval** metrics + the live **retrieval-trace** spine
  (capture is ON; ~76 real traces recorded so far).
- Wave-1 quick-wins (latency p50, index freshness, metadata filters, should_retrieve),
  second-stage reranker, noise-gate + token-budget packer, recall noise-cleaning (wired live),
  and the CRAG evidence-quality verdict + AEGIS-gated web fallback (built INERT — denied
  until a `web: grant`).

**Cut + recorded as WON'T-DO (the key strategic decision):**
- Removed the dense roadmap (`rag-master-plan` program/workflow/doc/test + W-16 doc entry).
- Dense index / RRF fusion / query expansion / multi-hop are **won't-do by design** —
  AXON is small-corpus + deterministic and already rejected embeddings (CONTEXT.md).
  Recorded in: `AXON-DOCS-RAG-DEVELOPMENT.md` "Scope decision", the `rag_maturity_audit`
  docstring, and the `metrics_manifest` claim. The 58/70 reading is AXON's deliberate
  sparse ceiling — a diagnostic, NOT a target. Do not chase 70/70; it would degrade AXON.

## 2. State at close
- `main == origin/main`, working tree clean, freshness `ok`, gate green (0 blocking, 0 warn).
- Project artifacts: `my-axon/dev-projects/online-changes/` (3 studies, master plan, 14 PR specs
  with merged/deferred status).

## 3. Two owner toggles left OFF on purpose (yours to flip)
- `dispatch-rerank: on` in `workspace/preferences/smart-dispatch.md` — only once a representative
  measurement shows it helps (the 30-query corpus showed P@1=0 for both — the live dispatch index
  is degenerate; see §4).
- `web: grant` in `_policy.md` — activates the inert CRAG web fallback.

## 4. Flagged, NOT acted on (highest-value retrieval work actually in front of AXON)
- **The dispatch index has 1 entry** — AXON's live routing substrate looks degraded. Worth more
  than any RAG-maturity work, but it lives in compiled-mirror territory (the COMPILED-MIRROR KILL
  todo, an owner-locked decision). Left for the owner.

## 5. NEXT SESSION
- Owner has **a new idea** to start fresh (stated next session). This handover is the clean
  base to build from.

# Phase 3 — Dense Substrate — GATED on a measured recall gap (avoid the mirage)

**Goal:** Add dense retrieval, hybrid fusion, and query planning ONLY where a live measurement (not a fixture) justifies the surface-area and determinism cost; ship the unconditional net-surface-reduction now.

- Score after: 70/70 if PR-9 builds; ≈68/70 with a recorded deferral if live recall ≥0.95 (honest)
- Reach after: hybrid + planned retrieval reaches all six sparse surfaces via one planner
- Exit gate: crucible passed:true; B3/C1/C2/B6 closed by paired-fixture recall/precision deltas; B1 either closed by a proven live-recall lift OR a recorded DEFERRAL artifact in my-axon/log/. Part A's 2→1 consolidation locked by a score-equality test.

## PRs in this phase
- PR-9: split into Part A (UNCONDITIONAL, net surface REDUCTION) — collapse the two byte-identical cosine TF-IDF copies (dispatch.tfidf_similarity, agent_memory._tfidf_rank — verified identical TfidfVectorizer+cosine; synapse_suggest.dispatch_tfidf is a DIFFERENT placeholder, left alone) into one tools/_sparse.py; and Part B (HARD-GATED) — NEW tools/retrieval_index.py dense index built ONLY if aggregate context_recall over Phase-1 live traces < 0.95, else DEFER with a recorded measurement. Dense backend = HashingVectorizer (deterministic, already in deps), NOT sentence-transformers (dropped by PR-130). Gate = live-trace recall delta, never the 'embedding index' keyword
- PR-10: NEW tools/retrieval_fusion.py rrf(sparse,dense,k=60) (~20 lines stdlib) exposed as retrieval_index `query --hybrid`; gate = on a dump-cased (live, not hand-made) fixture, context_precision(fused) > either single retriever AND recall not below max(single) AND latency_p95 not above the union max. Flips B3 (locked by a metrics_manifest tripwire)
- PR-11: query planner as a retrieval_index `plan` subcommand (expand/decompose/route, model-free), injected into the orchestrator OBSERVE query with a `| recent-input` fallback; gate = paired baseline-vs-expanded fixtures where recall(expanded)>recall(baseline) and a 2-hop compound reaches both gold ids no single query reaches. Flips C1/C2/B6
> Parent plan: [02-plan.md](../02-plan.md)

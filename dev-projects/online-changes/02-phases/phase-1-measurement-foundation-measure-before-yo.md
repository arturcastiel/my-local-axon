# Phase 1 — Measurement Foundation (measure before you claim)

**Goal:** Turn the evaluator from a hand-fixtures toy into a measurement over live sparse retrieval, then bank the cheap observability/chunking wins each row genuinely earns.

- Score after: ≈48-50/70
- Reach after: + reaches live dispatch & agent-memory traffic (capture wired, OFF by default behind read_pref)
- Exit gate: crucible passed:true; rag_maturity_audit shows E8/E6/E4/B4/B5/B7/A2 closed by their behavior tests; live traces now populate my-axon/log/retrieval-evals/ (the precondition data Phase 3's dense gate will measure).

## PRs in this phase
- PR-3 (keystone): NEW tools/retrieval_trace.py (capture/replay/dump-case) emitting the exact RetrievalCase shape retrieval_eval._load_case parses; wire OFF-by-default guarded capture into dispatch.match and agent_memory.recall; invoke the built-but-never-called _append_log via --append-log in retrieval-eval.md. Flips E8 (behavior, not keyword) + E6. ZERO new metric code — replay delegates to score_case
- PR-4: four edits-to-existing-tools (no new files) — latency p50 in aggregate(), perf_counter stamping in dispatch+recall, retrieval-index freshness check, metadata_filters recall, should_retrieve gate; load-bearing audit un-hardcode of E4 (`1 if latency`→`2 if p50_p95`). Flips E4/B4/B5/B7 (+4), each locked by a real metric/behavior test
- PR-5: deterministic structural chunker as a retrieval_eval `chunk` subcommand emitting {id,text,char_span,source,section,doc_type,hash}; replace library-dev-ingest raw-text[0..8000] truncation. Flips A2, improves A1 — gate = structural chunking yields strictly higher per-section token_iou than a whole-doc block (empirical, not the keyword)
> Parent plan: [02-plan.md](../02-plan.md)

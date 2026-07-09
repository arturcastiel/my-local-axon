---
tags: [code, file]
path: tools/synapse_suggest.py
---

# tools/synapse_suggest.py

> 52 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `+1 iff a per-project graph is available AND this candidate consumes it.      Mir`
- `+1 iff a shadow-gap is open AND this candidate advances it.`
- `Adaptive retrieval gate — decide whether to retrieve only when needed, instead o`
- `Any`
- `Bag-of-words Jaccard. v1 placeholder for mode-detect.`
- `Degraded fallback corpus from the PROGRAM registry (workspace/programs/REGISTRY.`
- `Degraded fallback corpus from the Python TOOL registry (tools/REGISTRY.json).`
- `Drop absent additive signals; renormalize the rest to original sum.`
- `Evaluate a synapse precondition.      v1.1 — wired to the real predicate evaluat`
- `First 20 fires of a fresh session with no dispatch/usage/pattern history.`
- `Minimal fallback candidate. NO contract inference happens here — role/preconditi`
- `PR-120 — return igap weight for this candidate, or 0.0.      Source: `state["iga`
- `Path`
- `Reads state.pattern.clusters[name]. None = absent.`
- `Reads state.usage.recent[name] (0..1 normalized). None = absent.`
- `Return (raw_score, signal_components, reasons).`
- `Return sort key that, after primary -score, implements FL-04 ladder.      All te`
- `Returns (keep, reason_if_dropped).`
- `Shape: predicate.py reads ctx[scope][path...].      synapse-suggest's flat `stat`
- `Sum of confidences for next-conditional clauses whose `if` matches.      v1.1 —`
- `Token overlap between candidate.purpose/post-state and goal.statement.`
- `Translate AXON-LANG operators + scope prefixes to predicate ASCII.`
- `Weighted token overlap as TF-IDF placeholder.      Name tokens count 2x; purpose`
- `_build_predicate_ctx()`
- `_degraded_record()`
- `_eval_simple_if()`
- `_load_candidates_from_programs()`
- `_load_candidates_from_registry()`
- `_load_json()`
- `_normalize_symbolic()`
- `_tokenize()`
- `context_pressure_penalty()`
- `dispatch_tfidf()`
- `drift_penalty()`
- `filter_candidate()`
- `goal_alignment()`
- `graphify_bonus()`
- `igap_signal()`
- `intent_match()`
- `is_cold_start()`
- `main()`
- `next_conditional_score()`
- `pattern_cluster_match()`
- `rank()`
- `renormalize_weights()`
- `score_candidate()`
- `shadow_bonus()`
- `should_retrieve()`
- `spec: (context-pressure.pct / 100) * cost.tokens-estimate / 10_000.`
- `synapse_suggest.py`
- `tie_break_key()`
- `usage_frequency()`

## Depends on
- (none)

# Phase 2 — Post-Retrieval Quality (cheap precision wins + the governance wire)

**Goal:** Raise precision on every existing sparse consumer with model-free post-processing, and introduce AXON's first genuinely gated network capability.

- Score after: ≈56-58/70
- Reach after: + reaches the network — but ONLY through the AEGIS grant (fail-closed twice)
- Exit gate: crucible passed:true with the new retrieval-reflect BLOCK control; D1/D2/D3/F2/F5/F6 closed by metric/governance tests; the web path provably suppressed when the autonomous grant is absent.

## PRs in this phase
- PR-6: NEW tools/rerank.py (exposed as a retrieval_eval `rerank` subcommand, reuses library.rank_candidates + retrieval_eval.context_precision, no new metric code); gate = on real agentic_anchor.json fixture, rerank demotes the score-0.11 'unrelated' noise chunk and context_precision strictly rises. Flips D1
- PR-7: partition_chunks noise-gate in library.py + token-budget pack in context.py (both subcommands on existing in-SEARCH_GLOBS tools, not new files); gate = dropping the reject bucket strictly raises context_precision AND packing preserves token_iou; all-reject is the principled web-escalation signal. Flips D2+D3
- PR-8: CRAG verdict (accept|ambiguous|reject) as a retrieval_eval subcommand + AEGIS-gated bounded web fallback. Adds the FIRST network capability — `web: grant` in _policy.md (verified absent today), `'web':'human'` default in aegis_policy.CAPABILITIES (fail-closed), correctly NOT in GATED. Lock = governance-denial test (resolve('web',{'web':'grant'},grant_active=False).allowed is False AND web_search sentinel never called under autonomy-off) + precision-rises-after-fold. Flips F2/F5/F6
> Parent plan: [02-plan.md](../02-plan.md)

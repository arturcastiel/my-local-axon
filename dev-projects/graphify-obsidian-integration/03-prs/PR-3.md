# PR-3 — Graphify bridge for code-dev target repos (P-CD)

Status: merged (MR !155)
Branch: graphify-obsidian/pr-3-graphify-bridge → graphify-obsidian-integration
Depends-on: PR-0 (code_symbols fallback), PR-1 (code_graph pattern)
Phase: execute

## Goal
The hybrid's *other half*: when code-dev works on an EXTERNAL, multi-language repo, optionally use **Graphify**
to map+query it. Pinned OPTIONAL — graphify absent ⇒ fail-degrade to the stdlib `code_symbols` path (PR-0),
never crash, never block a gate.

## Change
- **New** `tools/graphify_bridge.py` (lean, ~150 ll): `check` (is graphifyy importable / CLI present?),
  `build --repo <dir> --out <json>` (deterministic `graphify update` on the target, code-only), `affected
  --graph <json> <symbol>` (reverse blast-radius, reads typed `links` confidence). Every op fail-degrades:
  graphify missing/error ⇒ `{"ok": false, "degraded": true}`, callers fall back. status OPTIONAL in REGISTRY.
- **Wire** `code-dev-knowledge-impact`: when a target-repo graph exists, prefer `graphify affected` (precise,
  multi-language, EXTRACTED-tiered); else the PR-0 `code-symbols` path. Both already guarded against empty.
- **Tests** `tests/test_graphify_bridge.py` — mocked (graphify NOT required installed): check returns
  degraded-when-absent, parse of a fixture graph.json, fail-degrade contract. `@pytest.mark` skip live.
- **Docs**: register graphify_bridge (OPTIONAL), pin note (`graphifyy>=0.8.36,<0.9.0` as an extra, NOT core),
  CONTEXT count bump, Guarded-by row.

## Acceptance criteria
- [ ] `graphify-bridge check` → degraded:true when graphify absent (no crash).
- [ ] affected parses a fixture graph.json `links` with typed confidence.
- [ ] impact prefers graph when present, falls back to code-symbols when not.
- [ ] graphify stays OPTIONAL — base install + all gates pass WITHOUT graphify installed.
- [ ] Gates green incl. crucible (which runs WITHOUT graphify).

## Out of scope
The other 5 P-CD surfaces (plan/review/test-map/study/workflows) — same pattern, follow-on; LLM overlay (P3/PR-4).

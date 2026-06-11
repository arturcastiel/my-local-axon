# SHADOW: /home/arturcastiel/projects/new-axon/axon/tests/test_graphify_bridge.py
source-path: /home/arturcastiel/projects/new-axon/axon/tests/test_graphify_bridge.py
shadow-created: 2026-06-11
shadow-updated: 2026-06-11
git-hash: 8acc742e4c33adb1f08990d01caef6a7ab9d1365
git-branch: main
git-commit: 06c49f8
git-commit-msg: Merge branch 'general-bugfix/docs-closeout' into 'main'
caller-program: code-dev-study
caller-project: graphify-obsidian

## Summary
Pins the bridge contract WITHOUT graphify installed: check never raises; affected parses links+edges fallback, resolves labels, filters INFERRED on min_confidence=EXTRACTED; build degrades without CLI; semantic refuses without web grant and never returns EXTRACTED.

## Key Structures
8 tests; fixture _graph() writes a 3-node/2-link graph.json with mixed confidence.

## Dependencies
pytest, tmp_path, monkeypatch; imports tools/graphify_bridge.py by sys.path injection.

## Architecture Role
The safety contract of the optional dependency: degrade-never-crash + advisory-only overlay.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-06-11 |  | No test exercises the graphify-PRESENT path (build/semantic happy path untested — acceptable: optional dep absent in CI; now that graphify IS installed locally, a present-path smoke is feasible). code_graph/code_symbols have their own test files (18+11 per delivery log; 30 total across integration). |
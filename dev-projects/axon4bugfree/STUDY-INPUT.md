# Study input — the 8 improvement points (from axonbugfree3 close, 2026-07-13)

Each point is to be assessed HOW GOOD it is, grounded in the code graph. For each:
verdict (BUILD / EXTEND-EXISTING / DEFER / DROP), effort, leverage, blast radius, what
already exists, and the graph queries that back the judgment.

## Tier 1 — retire recurring defect classes
**P1. Extend the conformance lints to the kernel .md files.**
`program_tool_conformance` + `lint_path_vars` scan only programs/ dirs — why F-H10 (dead
`drift record` interface in KERNEL-SLIM) and F-H8 (phantom W:ws-path) survived. lint_path_vars
was widened in PR-021; give program_tool_conformance the same kernel-file scope.
Graph targets: tools/program_tool_conformance.py, tools/lint_path_vars.py — callers, file-nodes.

**P2. A real state-key registry + connectivity lint.**
Reader/writer key drift is THE dominant class across 3 audits. memory_key_lint is heuristic.
A declared registry (every W:/L: key → writer(s)+readers, like REGISTRY.json for tools) makes
the lint exhaustive: flag phantoms (read-never-written) AND dead writes (written-never-read).
Graph targets: tools/memory_key_lint.py, tools/config_keys.json consumers.

**P3. Generate the doc-count artifacts instead of test-locking hand-typed numbers.**
Adding 1 tool broke 3 tests (CONTEXT.md "188 tools", ARCHITECTURE counts, registry mirror).
A docgen tool-counts regenerator on pre-commit kills the drift. Graph targets: tools/docgen.py,
tools/registry_drift.py, the onboarding-count tests.

## Tier 2 — test/CI hardening
**P4. Fix cross-worker test pollution.** Gate saw 4 reds; isolated runs saw 1, three times.
axon/state/loop-receipt.ledger.jsonl grew 4.4MB DURING the suite = a shared-state writer.
Autouse tmp-workspace fixture + a lint forbidding tests writing the repo tree.
Graph targets: conftest.py, tools/loop_receipt.py writers, tests fixtures.

**P5. Auto-recompile mirrors + auto-bless in the dev commit flow.** A stale menu mirror red-ed
14 unrelated doctrine tests via the constraints cascade; re-bless was manual every wave.
Graph targets: tools/compile_write.py, tools/program_integrity.py, the pre-commit hooks.

## Tier 3 — higher ceiling
**P6. A markdown program runner for behavioral tests.** 170+ program .md are LLM-interpreted,
tested ONLY by static text-pins (fragile — tests grepped strings my comments contained). run.py
executes COMPILED programs but only ~8 are compiled. Graph targets: tools/run.py — callers, impact.

**P7. Close the drift-signal loop.** PR-011 restored `drift record --type persona-bleed/fallback-exec`
but nothing consumes those signals — drift score is still pure tool-sequence edit-distance.
Graph targets: tools/drift.py — callers of record/signals, gate consumers.

**P8. Make graphify's impact a mandatory pre-edit gate in code-dev.** Used affected/impact manually
this run to check blast radius before shared-tool edits; wiring it as a code-dev step would catch
reader/writer misses at authoring time. Graph targets: tools/graphify_bridge.py, code-dev programs.

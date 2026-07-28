# High-Level Plan — AXON 4 Bug-Free (AXON-LANG self-awareness)
Updated: 2026-07-13 · mode: tactical · goal: goal-2026-07-13-1 (HR council verdict)

## Context (from the council verdict)
GOAL: make AXON's self-analysis see its own AXON-LANG layer — GATING LINTS first, unified-graph query
layer second (gated on a residual multi-hop gap), markdown runner last. The graph is NOT worthless (it's
markdown-blind for AXON-LANG *edges*); the dominant defect class is LOCAL and best killed by GATED
invariants (memory_key_lint is the existence proof). Sequence cheap-and-gated before expensive-and-queryable.

## Grounding (measured, not guessed)
- 791 `TOOL()` call-sites · 287 `EXEC()` sites · 94 distinct tool names (91 resolve; my-tool/name/semantic-search dangle) [live, corrected from stale v1 pins].
- 188 registry tool names = the join target for `program→tool` edge resolution (REGISTRY.json).
- `tools/memory_key_baseline.json` + the burn-down pattern already exist → G2 reuses it (no new mechanism).
- `program_tool_conformance` scans 21 program globs, ZERO kernel `.md` → the G1 scope gap, confirmed.
- Blast radius (study graph): every target lint/tool is 1-file impact (program_tool_conformance 19 sym/1 file,
  lint_path_vars 6/1, memory_key_lint 11/1) → low-risk changes.

## Wave 1 — G1 + G3 (quick sweep) — AMENDED
Close the scope gap + kill the nuisance classes, reusing existing tools:
- PR-001: HARDEN program_tool_conformance's prose-naïve parser (strip fenced/inline-code, bound accessor
  var-tracking) BEFORE widening to axon/*.md — else 3 prose FALSE POSITIVES break the 0-entry ratchet.
- PR-002: EXTEND the EXISTING doc_counts.py (already wired in freshness) to CONTEXT.md/ARCHITECTURE phrasing —
  do NOT build a new count tool.
- PR-003: auto-recompile mirrors ONLY. NO AUTO-BLESS — a bless-generator defeats program_integrity's
  tamper-detection + doctrine_preflight's injection guard (HARD STOP from the risk seat). Hook BLOCKS the
  commit with the bless command for human review.

## Wave 2 — G2 (the core) — RESTRUCTURED by plan-review (consolidate-first, reuse-what-exists)
The review found ~6-17 .py files already parse AXON-LANG with OWN regexes that DISAGREE on the alphabet
(memory_key_lint is blind to the E: scope simulate parses) — "gates on sand". So:
- PR-004: build ONE canonical parser library (tools/axonlang.py) FIRST, as a BEHAVIOR-PRESERVING refactor of
  the strongest existing impls; migrate ≥4 consumers with zero behavior change (proven by their tests+baselines).
  Reduce-surface becomes the un-cuttable first PR, not the drop-under-pressure reconcile-last one.
- PR-005: the gates are CONSUMERS of that relation, mostly WIRING: reuse deps.py's existing missing_exec
  (promote into crucible), extend memory_key_lint with dead-key USING ITS TUNED noise discipline (the W:_*
  exemption that keeps it off the 67%-noise trap), dangling-TOOL already emitted by program_tool_conformance.
- PR-006: finish migrating the remaining parsers OR conformance-test that they agree on the alphabet.
- Join-coverage machinery DEFERS to the graph wave (it's a query-index signal, not a gate threshold).

## Wave 3 — G4 (graph-emission, GATED on residual)
Emit the SAME extracted edges into the unified graph.json as a NON-gating query layer. Built ONLY if
Wave-2's lints leave a real multi-hop/transitive gap. Do NOT build a 4th graph — extend the schema.

## Deferred — G5 (markdown runner)
Behavioral coverage of the 170 uncompiled programs. Separate, higher-ceiling, nondeterministic. Later.

## Discipline
Full crucible gate before every push; each new lint/tool ships tests (Core Rule 13) + a crucible control;
new surface justified per reduce-surface (G2 = one extractor feeding gates, not a 4th graph). Commits AXON-only.

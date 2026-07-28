# Study — axon4bugfree: graphify-grounded feasibility of the 8 improvement points
date: 2026-07-13 · phase: study · codebase: /home/arturcastiel/projects/new-axon/axon
graph: graph/graph.json (23,521 nodes · 27,695 links · structural/EXTRACTED layer, fresh vs HEAD)
method: every verdict is backed by a real `graphify-bridge query` (impact/callers/file-nodes) —
        blast radius = # symbols/files a change to the target ripples into. Quoted below, not inferred.

## META-INSIGHT (the graph told us something the prose couldn't)
`graphify-bridge query callers --symbol graphify_bridge` → **0 callers**, even though many `.md`
programs invoke it via `TOOL(graphify-bridge, …)`. The code graph **only sees Python↔Python edges**;
it is BLIND to the markdown-program → tool layer. Consequences that reshape the backlog:
- Blast-radius numbers below are TRUE for Python consumers but UNDERCOUNT markdown consumers. A tool
  with "1-file impact" can still be called by dozens of `.md` programs the graph can't see.
- This is itself the strongest argument for **P6** (a markdown runner would let the markdown layer be
  graphed + behaviorally tested) and it caps how exhaustive **P2**'s connectivity lint and **P8**'s
  impact gate can be until the markdown layer is graphable.

---

## PER-POINT VERDICTS (graph-grounded)

### P1 — extend conformance lints to kernel files · **VERDICT: BUILD (top pick)**
- Graph: `program_tool_conformance.py` impact = **19 symbols / 1 file**; `lint_path_vars.py` = 6 symbols / 1 file. Both self-contained → LOW blast radius, safe to change.
- Source: the scan list is programs-only (`("workflow","workspace/programs/workflow-*.md")` … no `axon/*.md`). CONFIRMED the exact gap that let F-H8/F-H10 survive.
- Effort: small (mirror the `_KERNEL_SPEC_EXCLUDE` widening I already did to lint_path_vars in PR-021). Leverage: would have PRE-CAUGHT 2 of run-3's HIGH findings. **How good: excellent — highest yield-per-effort.**

### P2 — state-key registry + connectivity lint · **VERDICT: SPLIT — EXTEND now, GENERATE the registry (don't hand-write)**
- Graph: `memory_key_lint.py` impact = **11 symbols / 1 file** (the lint change is contained).
- Scale probe: **424 distinct W:/L: keys** across programs+kernel; `config_keys.json` has only **6** entries. A hand-authored 424-key registry is a large, rot-prone artifact — DON'T.
- Better: GENERATE the writer/reader map by scanning `STORE(W:x)`/`RETRIEVE(W:x)` occurrences (the data the markdown layer holds), then lint connectivity (phantom = read-never-written; dead = written-never-read). memory_key_lint already does half. **How good: high value, but the win is the GENERATOR, not a manual registry.** Blocked partly by the markdown-blind graph (meta-insight) — the generator must parse .md, not the code graph.

### P3 — generate doc-count artifacts · **VERDICT: BUILD (easy win)**
- Graph: `docgen.py` impact = 13 / 1 file; `registry_drift.py` = 9 / 1 file. Contained.
- Fact: adding 1 tool this run broke **2** onboarding-count tests + the registry mirror. A `docgen tool-counts` regenerator (pre-commit) collapses 3 brittle locks into one freshness check. **How good: low effort, kills a whole nuisance class.**

### P4 — cross-worker test pollution · **VERDICT: BUILD, but SPLIT by blast radius**
- Graph: `conftest.py` impact = **38 symbols / 16 FILES** — HIGH blast radius; a fixture change there ripples across the suite. `loop_receipt.py` = 30 / 1 file with **14 callers** all writing the one shared ledger → the pollution source, confirmed.
- Split: (a) the LINT half (forbid tests writing the repo tree) is low-risk, self-contained — do first; (b) the autouse tmp-workspace fixture in conftest is the 16-file-blast half — do behind the lint, carefully. **How good: high value (removes the recurring flaky-gate tax I paid 3× this run), but conftest is the riskiest single file in the backlog — stage it.**

### P5 — auto-recompile mirrors + auto-bless · **VERDICT: BUILD**
- Graph: `compile_write.py` impact = **3 / 1 file** (tiny); `program_integrity.py` = 7 / 1 file.
- Infra exists: `tools/hooks/` already has enforce_pretooluse / next_turn_gate / reanchor_store / verify_stop — a hook framework to extend, not invent. **How good: low-risk, removes the stale-mirror cascade (a stale mirror red-ed 14 unrelated tests this run) + the manual bless dance.**

### P6 — markdown program runner · **VERDICT: DEFER (highest ceiling, biggest build)**
- Graph: `run.py` impact = 5 / 1 file BUT **69 callers** — the compiled-run path is load-bearing. A source-`.md` interpreter is a NEW capability (178 source programs, only **8** compiled → 170 untested behaviorally).
- The meta-insight makes this the KEYSTONE: a real interpreter would also make the markdown layer graphable, unblocking P2's generator + P8's true impact. **How good: highest ceiling, but a multi-PR build — sequence it AFTER the cheap Tier-1 wins prove the pattern.**

### P7 — close the drift-signal loop · **VERDICT: MEDIUM — contained but semantically load-bearing**
- Graph: `drift.py` impact = 21 / 1 file, **9 callers**. `compute_score` does NOT consume `signals` (my PR-011 records them; score is still pure tool-sequence edit-distance — grep confirms `signals` appears only in record/count paths).
- Changing the score's MEANING (fold persona-bleed/fallback-exec signals in) touches the gate's behavior for 9 callers incl. auto-improve — needs a careful weighting + its own falsification test. **How good: makes the coherence guardian mechanically real, but higher-care than its 1-file blast suggests.**

### P8 — graphify impact as a pre-edit code-dev gate · **VERDICT: BUILD (self-hosting win) — but honest about the blind spot**
- Graph: `graphify_bridge.py` impact = 32 / 1 file, **0 Python callers** (meta-insight: consumers are the 3 `.md` code-dev programs, invisible to the graph). A gate that surfaces a tool's blast radius before editing it is a `.md`-program change (host in code-dev-pr-create or code-dev-plan).
- Caveat: because the graph is markdown-blind, the impact gate would MISS markdown consumers — it catches Python blast radius only (still valuable: shared tools like drift/phase_model/shell have real Python fan-out). **How good: good dogfooding value; pairs naturally with P6 (which would remove the blind spot).**

---

## RANKED RECOMMENDATION (yield-per-effort, graph-grounded)
1. **P1** — extend conformance lints to kernel (tiny, 1-file blast, pre-catches HIGH bugs). DO FIRST.
2. **P3** — generate doc-counts (tiny, kills a nuisance class).
3. **P5** — auto-recompile + auto-bless (low-risk, hook infra exists, removes stale-mirror cascade).
4. **P4a** — the test-write-forbidding lint (low-risk half of P4); **P4b** conftest fixture staged behind it.
5. **P2** — the key-map GENERATOR (not a manual registry) + connectivity lint.
6. **P8** — impact pre-edit gate in code-dev (self-hosting; honest about markdown blind spot).
7. **P7** — fold drift signals into the score (contained but semantically careful; needs a falsification test).
8. **P6** — the markdown runner (KEYSTONE + highest ceiling; unblocks P2/P8; sequence last, multi-PR).

Cross-cut the graph exposed: **the code graph is markdown-blind** — 3 of the 8 (P2/P6/P8) are capped by
it, and P6 is the thing that lifts the cap. A run-4 plan should treat P1/P3/P5 as the quick Tier-1 sweep,
then decide P6 as the strategic keystone before over-investing in P2/P8's markdown-limited forms.

## NEXT
code-dev plan — cut PR waves from this ranking (Tier-1 quick sweep first, P6 keystone decision gated).

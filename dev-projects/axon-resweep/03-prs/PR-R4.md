# PR-R4 — [HIGH] synapse-suggest call-site drift (P1)

- **Status:** spec
- **Phase:** 1-fixes  ·  **Complexity:** M  ·  **dev-mode:** no (workspace/programs/ + tools/synapse_suggest.py + tests/)  ·  **Depends on:** none
- **Why / detail:** 01-study.md P1 (HIGH). Three ACTIVE programs call the ranker with a stale API → exit-2
  on the adaptive-workflow path + the mainline orchestrator tick. Invisible to verify.py.

## Mechanism
The real CLI is `rank --state <PATH> [--goal <PATH>] [--top N] [--explain]`; the programs pass state INLINE
(their intent). Rather than make every LLM-interpreted program manage a temp file, teach the ranker to accept
inline JSON OR a path (the author's intent, minimal program change):
- `tools/synapse_suggest.py` `_load_json`: a value starting with `{`/`[` is parsed inline (tolerating a
  Python-repr dict via ast.literal_eval); otherwise read as a file path. Back-compat (paths never start {/[).
- `orchestrator.md` (×2): `--state-json/--goal-json` → `--state/--goal` (the inline `{state}`/`{goal}` now load).
- `workflow-run.md`: `synapse-suggest "--context {wf} --history {trace} --top-k 5"` → build `sg-state ←
  {active-workflow: wf, history: trace}` then `rank --state {sg-state} --top 5`.
- `workflow-new.md`: → `rank --state {RETRIEVE(W:_workflow-author-state)} --top 5`.

## Acceptance
1. `synapse_suggest._load_json` accepts inline JSON, a Python-repr dict, and a file path (+ None).
2. `synapse-suggest rank --state '<inline json>' --top 3` runs (end-to-end, returncode 0, list out). [verified]
3. The 3 programs use `TOOL(synapse-suggest, rank, "--state …")`; no `--state-json`/`--goal-json`/`--top-k`/
   `synapse-suggest, "--context`.
4. `crucible gate` passed:true.

## Tests
`tests/test_synapse_suggest.py` — `_load_json` inline/repr/path + an inline-state CLI rank.
`tests/test_resweep_program_subcommands.py` — the 3 programs' call-site lock.

## Note
The systemic catch (teach R_TOOL_CALL_EXISTS to see `choices=`-based subcommands so this drift class is
gate-caught) remains a candidate phase-2 follow-up.

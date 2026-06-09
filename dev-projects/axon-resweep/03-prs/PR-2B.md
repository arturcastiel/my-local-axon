# PR-2B — tools/state batch: log-parse, my-axon resolution, audit workspace, empty-JSON

- **Status:** merged (!136, 9bc3ef1)
- **Phase:** 2-reaudit-fixes  ·  **Complexity:** S  ·  **dev-mode:** no (tools/ + tests/)  ·  **Depends on:** none
- **Source:** re-MEGA findings (05-reaudit-findings.md) — F-STATELOG, F-MYAXON2UP, F-AUDITWS, F-LOADEMPTY,
  F-RESOLVEVAL. Each confirmed against source (and the uncertain two verified against real data before fixing).

## Fixes
- **F-STATELOG** `axon_state.py:_parse_log` — the header skip matched only `"Timestamp"`, but the real
  session-log header is `| Time | Event | Notes |` → it leaked in as a phantom row (off-by-one counts + a
  bogus "newest" event). → skip any row whose first cell isn't a timestamp (every data row leads with the
  ISO digit). [verified: session-log header is "Time"]
- **F-MYAXON2UP** `agent_memory.py` + `agent_todo.py` — the my-axon fallback was `workspace/../../my-axon`
  (two-up = the PARENT of the repo); correct is the repo sibling `workspace/../my-axon`. Masked only by the
  gitignored W:myaxon-path symlink → broke on a fresh clone. → one-up sibling, matching the already-correct
  `autonomous_mode._resolve_myaxon` + the gate's `_myaxon_root`.
- **F-AUDITWS** `axon_audit.py:main()` — called `usage_log_stats()` / `prompt_log_stats()` with no arg, so
  the M1 `workspace=` param (and thus `--workspace`) was ignored. → pass `args.workspace`.
- **F-LOADEMPTY** `synapse_suggest._load_json("")` raised (empty string fell to the file-read branch). →
  `if not s: return None`.
- **F-RESOLVEVAL** (confirmed real) — the gate's `_myaxon_root` parses a `value:` line / first-non-empty-line
  / drops an inline `# comment`, but the three my-axon readers `.read().strip()` raw → divergence for those
  pointer forms (latent: on-disk pointer is bare). → shared `_axon_paths.read_myaxon_pointer` (parses exactly
  like `_myaxon_root`) routed through all three readers, eliminating the divergence class.

## Acceptance
1. Effect: `_parse_log` drops the "Time" header; the fallback is one-up; `_load_json("")` is None;
   `read_myaxon_pointer` parses value:/bare/comment; resolvers honour the value: form. [test_reaudit_tools_state.py]
2. No regression in the 5 touched modules (axon_state/agent_memory/agent_todo/autonomous_mode/axon_audit/synapse_suggest).
3. `crucible gate` passed:true.

## Changes
- `tools/axon_state.py` · `tools/agent_memory.py` · `tools/agent_todo.py` · `tools/autonomous_mode.py` ·
  `tools/axon_audit.py` · `tools/synapse_suggest.py` · `tools/_axon_paths.py` (+`read_myaxon_pointer`)
- `tests/test_reaudit_tools_state.py` (6 effect tests)

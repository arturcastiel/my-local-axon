# PR-R1 — Tool fixes: audit usage path · neuron-audit flag · rules_loader threshold (M1 · M3 · M4)

- **Status:** spec
- **Phase:** 1-fixes
- **Complexity:** S  ·  **dev-mode:** no (tools/ + tests/ only)  ·  **Depends on:** none
- **Why / detail:** see 01-study.md (M1/M3/M4) + 02-prs.md PR-R1. Clean, isolated, low-risk warm-up.

## Changes
- `tools/axon_audit.py` — `usage_log_stats`/`prompt_log_stats` gain an optional `workspace` param and read
  from `Path(workspace or default_workspace())/memory/...` (where usage.py/prompt_log.py WRITE), not
  `MYAXON_ROOT` (M1 — was always zero → false "No usage data yet").
- `tools/neuron_audit.py` — `_lint` gains an optional `workspace` and passes
  `state={"workspace_path": ws}` so the lint rules can resolve `L:*-required` flags (M3 — was `state={}`).
- `tools/rules_loader.py` — remove the discarded `dead_after_days` cutoff no-op (+ its unused
  `import datetime`); the dead-rule message no longer claims a `{N}d` threshold it never applied (M4).

## Acceptance
1. `usage_log_stats(ws)` / `prompt_log_stats(ws)` count entries written to `ws/memory/...` (M1).
2. `_lint(..., workspace=ws)` gives the rules `state.workspace_path == ws` (M3).
3. `rules_loader.audit(workspace=ws)` runs (no NameError from the removed import) + emits no "threshold"
   claim in dead reasons (M4).
4. `crucible gate` passed:true on this on-workflow changeset.

## Tests
`tests/test_axon_audit.py` (new), `tests/test_rules_loader.py` (new), `tests/test_neuron_audit.py`
(+workspace_path case). Full suite + gate (parse passed SEPARATELY). No dev-mode.

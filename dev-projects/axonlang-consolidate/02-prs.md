# PR List — axonlang-consolidate
## PR-B1 — agent_memory gc-gate uses the canonical _longterm reader
Scope: tools/agent_memory.py _read_gate → delegate to _longterm.read_longterm_value (first-line only); delete the every-line scanner. Test: multi-line 'false\nvalue: true' must read false. Severity HIGH-consequence.
## PR-B2 — agent_memory binding-liveness checks all program roots
Scope: agent_memory.py:189 _binding_alive → also axon/programs/ + my-axon/programs/. Test: a program:mode-run binding is alive.
## PR-B3 — hr-team honors tier persistence + wires events.jsonl
Scope: hr-team.md resolve persistence post-selector (| sel.persistence |) + collect emitted events + pass --events at the write. Tests: text-pins + a bundle with non-empty events.
## PR-B4 — hr_team cwd-independent defaults + fail-closed catalog parse
Scope: tools/hr_team.py catalog/prompts/ledger defaults via _axon_paths; _parse_catalog returns {} on missing (→ fail_closed) ; selector treats ∅ roster as fail_closed. Tests.
## PR-B5 — registry purpose/args accuracy WARN + correct 4 strings
Scope: registry_drift.py add a WARN when documented subcommands ⊊ real (reuse --help probe); fix quality-loop/autonomous-mode/agent-memory/shadow strings. Tests.
## PR-B6 — correct the stale recall() episodic comment
Scope: agent_memory.py:249-250 comment. (docs-only)

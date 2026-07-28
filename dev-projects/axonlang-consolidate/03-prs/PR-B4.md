## PR-B4 — hr_team cwd-independent defaults + fail-closed catalog parse
Scope: tools/hr_team.py catalog/prompts/ledger defaults via _axon_paths; _parse_catalog returns {} on missing (→ fail_closed) ; selector treats ∅ roster as fail_closed. Tests.

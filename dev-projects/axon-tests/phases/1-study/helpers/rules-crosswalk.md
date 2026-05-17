# Helper — Rules engine cross-walk (Round 2)

> Round 2 of phase 1-study, axon-tests project.
> Scope: tools/rules/r*.py ↔ tests/ — does each runtime/static rule have
> dedicated assertions?

## TL;DR

**9 rule modules. 1 has a dedicated test class. 0 have a positive +
negative pair. R3, R7, R9, R_COHERENCE, R_NO_PLANNED_TOOLS,
R_REASONING_TRACE, R_TOOL_EXISTS, R_W_BUDGET ship without any tests
referencing their `rule_id`.** Coverage today is incidental — what
exists is `TestVerify` (5 black-box cases on `tools/verify.py`) and
`TestDriftGate` (drift-only). The rule predicates themselves are
unverified.

## Rule-by-rule

Counted hits of the literal `rule_id` string under `tests/` (excluding
`__pycache__/`):

| Rule module                | rule_id            | phase    | severity | dedicated test class | rule_id hits |
|----------------------------|--------------------|----------|----------|----------------------|--------------|
| r3_arithmetic.py           | R3                 | STATIC   | BLOCK    | —                    | 0            |
| r7_no_symbolic_output.py   | R7                 | RUNTIME  | WARN     | —                    | 0 *          |
| r9_axon_write.py           | R9                 | RUNTIME  | BLOCK    | —                    | 0            |
| r_coherence.py             | R_COHERENCE        | RUNTIME  | BLOCK    | —                    | 0            |
| r_drift_gate.py            | R_DRIFT_GATE       | RUNTIME  | BLOCK    | TestDriftGate        | 4            |
| r_no_planned_tools.py      | R_NO_PLANNED_TOOLS | STATIC   | BLOCK    | —                    | 0            |
| r_reasoning_trace.py       | R_REASONING_TRACE  | RUNTIME  | BLOCK/W  | —                    | 0            |
| r_tool_exists.py           | R_TOOL_EXISTS      | STATIC   | BLOCK    | —                    | 0            |
| r_w_budget.py              | R_W_BUDGET         | RUNTIME  | WARN     | —                    | 0            |

`*` R7 is touched implicitly by `TestVerify::test_output_symbolic_blocked`,
which asserts only that `"violations" in out or "warnings" in out or
rc in (0, 1)` — a tautology that would pass even if R7 were deleted.

## What `TestVerify` actually proves

Five cases in `test_tools_kernel.py`:

```
test_rules_list                 — verify.py rules subcommand returns ≥1 rule
test_clean_program_passes       — known-clean program → rc=0, 0 violations
test_output_no_symbolic         — plain text → rc=0
test_output_symbolic_blocked    — symbolic in output → tautological assert (see above)
test_unknown_tool_blocked       — (if present, not confirmed yet)
```

These prove `verify.py` exists and runs. They do **not** prove:

- that violating a specific rule produces a violation with that rule's
  `rule_id`,
- that the rule fires on the right inputs and only on those,
- that severity is correct (BLOCK vs WARN),
- that phase routing is correct (STATIC vs RUNTIME),
- that activation toggles (e.g. `L:reasoning-trace-required`) work.

## What "governance" tests cover (despite the misleading name)

`test_governance.py` (9 cases) tests `tools/rules.py` — singular, the
WORKSPACE-RULES specification loader that reads
`workspace/safety/RULES.md`. **That is a different subsystem from the
runtime rule predicates in `tools/rules/`.** Naming overlap is a
latent confuser; should be called out in Phase 4 docs.

## Implication

Tier-A test PRs in Phase 3 must include, per rule (≥18 cases):

For each `tools/rules/r*.py`:

1. **Positive-fire case** — minimal context that should trigger the rule
   produces a `Violation` with the expected `rule_id` and severity.
2. **Negative-refuse case** — minimally-different context that must NOT
   trigger the rule produces `None`.

Plus, per-rule edge cases:

| Rule      | Edge cases to add                                                              |
|-----------|--------------------------------------------------------------------------------|
| R3        | float in code-span backticks (must skip), float inside TOOL(calculator,...) (must skip), integer arithmetic (must skip), `calculator.py` path mention (must skip) |
| R7        | symbolic op only inside backticks vs in prose, mix of safe + unsafe ops in one output, all 14 listed ops covered |
| R9        | WRITE vs APPEND vs READ (READ must pass), path normalisation (`./axon/x`, `axon//x`, symlink), dev-mode ON path, dev-mode OFF path |
| R_COHERENCE | every forbidden phrase pattern (≥14 in the source), case-insensitivity, false-positive guard (quoted text) |
| R_DRIFT_GATE | each of 3 score bands (stable < .10 / drifting < .40 / diverged ≥ .40), missing trace file, malformed trace |
| R_NO_PLANNED_TOOLS | call to PLANNED tool, call to ACTIVE tool (refuse), comment line with TOOL(name) (refuse), output literal `→ "TOOL(...)"` (refuse) |
| R_REASONING_TRACE | activation OFF (WARN), activation ON + missing (BLOCK), activation ON + present + ops (pass), activation ON + present + prose-only (WARN) |
| R_TOOL_EXISTS | unknown tool, comment line, output literal, OPTIONAL tool (pass), unicode tool name (refuse) |
| R_W_BUDGET | exactly LIMIT (pass), LIMIT+1 (WARN), unknown count (skip), w_keys as int vs list |

That gives **9 rules × (1 positive + 1 negative + 3–5 edge cases) ≈
60–80 cases** in `tests/test_rules/` — currently 0.

## Recommended layout (Phase 2 design output)

```
tests/test_rules/
  __init__.py
  conftest.py                — fixtures: build minimal ctx for each rule
  test_r3_arithmetic.py
  test_r7_no_symbolic_output.py
  test_r9_axon_write.py
  test_r_coherence.py
  test_r_drift_gate.py       — migrate from test_tools_kernel.py::TestDriftGate
  test_r_no_planned_tools.py
  test_r_reasoning_trace.py
  test_r_tool_exists.py
  test_r_w_budget.py
```

Plus a meta-test:

```
tests/test_rules_meta.py
  test_every_rule_module_has_a_test_file
  test_every_rule_id_in_registry_appears_in_some_assertion
  test_every_rule_module_declares_phase_severity_rule_id
```

The meta-test makes the cross-walk machine-enforced: adding a new rule
file without adding a test file fails CI.

## Doc anchor

Pin Phase-3 tests to a new section in `AXON-DOCS-GOVERNANCE.md`:

```
## Runtime/static rule predicates (tools/rules/)
| rule_id            | source                       | Guarded by                                    |
| R3                 | tools/rules/r3_arithmetic.py | tests/test_rules/test_r3_arithmetic.py        |
| R7                 | ...                          | ...                                           |
```

Phase 4 must update `AXON-DOCS-TESTING.md` (36 lines today) to include
a "Rules" tier alongside T1/T2/T3.

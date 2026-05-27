# PR-9.2 — r_reasoning_trace.py: remove duplicated module-level header

## 1. Why
F-D6-011 (MAJOR, verified iter 3 wave 1): `tools/rules/r_reasoning_trace.py:119-140` contains a dead duplicate of the module's header — re-imports `re`, re-defines `phase`, `severity`, `rule_id`, `_LANG_OPS`, `_PROSE_SUBJECT` at the BOTTOM of the file. The duplicate re-executes on import, doing nothing functional but creating a foot-gun for future edits.

This is a merge artifact, same pattern as F-D1-001/002/003 in menu/quickstart/help — but in a Python rule file. The function `evaluate(...)` ends at line 118; everything after is dead module-level code that overrides the original constants with identical values (so no visible bug, but the next edit could silently break the rule by editing only one of the two copies).

## 2. Evidence
- `tools/rules/r_reasoning_trace.py` — 140 lines total
- `grep -c "^import re" tools/rules/r_reasoning_trace.py` → 2
- `grep -c '^rule_id = "R_REASONING_TRACE"' tools/rules/r_reasoning_trace.py` → 2 (one at top, one at L124)
- BLOCKER trace iter 3 wave 1: confirmed "dead-code duplication of imports/regex at lines 119-140"

## 3. Design notes
Delete lines 119-140 of the file. They begin with `import re` (after the last `return None` in the evaluate function) and re-define the same module-level constants.

Verify after deletion:
- Module imports cleanly (`python3 -c "import tools.rules.r_reasoning_trace"`).
- Existing rule tests (`tests/test_rules/test_r_reasoning_trace.py`) still pass.
- The `evaluate` function is the SINGLE entry point.

## 4. Pitfalls
- Class-A (production-path): the duplicate redefinitions are identical to the originals. So removing them changes the binary identity of the module but not its behavior. Tests should pass.
- Class-C (data correctness): verify the file structure: `import re; from .registry import Violation; phase=...; severity=...; rule_id=...; _LANG_OPS=...; _PROSE_SUBJECT=...; def evaluate(...): ...` once.
- Class-D: not a kernel edit; `tools/rules/r_reasoning_trace.py` is workspace-tier Python; no dev-mode requirement.
- Class-E: R_REASONING_TRACE itself is gated by `L:reasoning-trace-required=true` (F-D6-006); this PR doesn't change activation, just removes dead code.

## 5. Interface sketch
No CLI / interface change. Internal cleanup only.

## 6. Spec

### Files-changed
| File | Change |
|---|---|
| `tools/rules/r_reasoning_trace.py` | Delete lines 119-140. File becomes 118 lines. |
| `tests/test_rules/test_r_reasoning_trace.py` | No change required — existing tests cover the rule's behavior. |
| `tests/test_no_duplicate_module_headers.py` | NEW. Lint check: assert no rule module has `^import re` more than once, no `^phase = ` more than once. |

### Acceptance
- `pytest tests/test_rules/test_r_reasoning_trace.py` green.
- `pytest tests/test_no_duplicate_module_headers.py` green.
- `pytest tests/` overall still green.
- Manual: `python3 -c "from tools.rules.r_reasoning_trace import evaluate; print(evaluate({}, ''))"` — runs without ImportError.
- Audit: F-D6-011 marked resolved.

### Rollback
- `git revert <commit>`. The deleted lines are recoverable from git.

### Owner
- AGENT: writes PR.
- HUMAN: runs pytest, lands commit. No kernel edit; no dev-mode.

### Parallelism
- Independent of all other Tier-1 PRs.

## 7. Codebase grounding
- F-D6-011: `_flaws.md` (MAJOR, verified iter 3 wave 1)
- Reference: `axon-reference/compliance/01-compliance-and-gates.md` § R_REASONING_TRACE.

## 8. Cross-refs
- Closes: F-D6-011.
- Does NOT close: F-D6-006 (R_REASONING_TRACE default-off opt-in behavior — needs separate Core-Rule-11 enforcement PR in C-08 cluster).

## 9. Audit trail
- No ADR required.
- Severity: MAJOR → resolved.
- Effort: S (~15 minutes; mostly the new lint test).
- Risk: very low.

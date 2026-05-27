# PR-1.2 — R9 path-check hardening: realpath + symlink coverage

## 1. Why
F-D8-001 (BLOCKER, verified 100% iter 3): `tools/rules/r9_axon_write.py:29-31` uses naive string-prefix checking:
```python
def _is_axon_path(p: str) -> bool:
    p = p.lstrip("./")
    return p == "axon" or p.startswith("axon/")
```
No `os.path.realpath`, no symlink resolution. **Four documented bypass vectors all verified**:
1. Symlink: `workspace/sneak → ../axon`; WRITE("workspace/sneak/x.md") passes the check.
2. Absolute path: `/abs/path/to/axon/x.md` — `lstrip("./")` leaves leading `/`; the prefix `axon/` doesn't match.
3. Path traversal: `workspace/../axon/x.md` — string prefix `workspace/` passes.
4. Shell expansion: `TOOL(shell, "cp x axon/y")` — R9 only inspects WRITE/APPEND ops, not shell.

`tools/enforce.py:15-19` uses `os.path.abspath` (better than R9's lstrip) but still NOT `realpath` — so vector 1 (symlink) bypasses both.

F-D8-006 (verified): `tests/test_rules/test_r9_axon_write.py` has 10 test cases — NONE cover symlink/absolute/traversal/shell. Test gap is identical to the implementation gap.

Per ADR-001 (accepted, sandboxed shell.py): the shell-tool vector (#4) is closed by PR-1.1. **This PR closes vectors 1-3** by switching to realpath + adding tests.

## 2. Evidence
- `tools/rules/r9_axon_write.py:29-31` — exact source quoted above (verified verbatim iter 3 wave 1)
- `tools/enforce.py:15-19` — uses abspath, not realpath
- `tests/test_rules/test_r9_axon_write.py` — 10 tests, all dev-mode/subdir/dot-slash variations; none symlink/absolute/traversal
- 4 bypass traces in `_flaws.md` F-D8-001

## 3. Design notes
Three changes, all small:

**Change 1 — r9_axon_write.py: realpath**
```python
import os

def _is_axon_path(p: str) -> bool:
    # Resolve to absolute path with symlinks resolved.
    # Use realpath so symlinks like workspace/sneak → ../axon are caught.
    resolved = os.path.realpath(os.path.abspath(p))
    # Compare against the resolved location of the axon/ directory.
    axon_root = os.path.realpath(os.path.abspath("axon"))
    return resolved == axon_root or resolved.startswith(axon_root + os.sep)
```

**Change 2 — enforce.py: realpath**
```python
def is_inside_axon(target_path, axon_dir="axon"):
    target = os.path.realpath(os.path.abspath(target_path))
    axon   = os.path.realpath(os.path.abspath(axon_dir))
    return target == axon or target.startswith(axon + os.sep)
```

**Change 3 — Tests for all 4 bypass vectors**
```python
def test_symlink_into_axon_blocked():
    # Create temp symlink ../axon → tmp_axon; ensure WRITE through it is blocked.
def test_absolute_path_to_axon_blocked():
    # WRITE("/abs/tmp_axon/foo.md") blocked.
def test_parent_traversal_blocked():
    # WRITE("workspace/../axon/foo.md") blocked.
def test_shell_tool_write_to_axon_blocked():
    # ADR-001 (PR-1.1) makes shell sandboxed; verify TOOL(shell, "echo > axon/x") blocked by R9-via-shell or by shell.py allowlist.
    # If PR-1.1 not yet landed: skip with xfail.
```

## 4. Pitfalls
- Class-A (production-path): existing tests use string paths like `"axon/foo.md"` and `"./axon/foo.md"`. Realpath converts these to absolute paths relative to CWD. Tests must `chdir` or use the workspace's axon-root resolution helper.
- Class-C (cwd dependence): `os.path.realpath("axon")` depends on CWD. The rule runs in subprocess; verify it resolves relative to the workspace root, not /tmp.
- Class-B (subprocess): r9_axon_write.py is invoked via verify.py; pass `--workspace` so axon-root is unambiguous.
- Class-E (rule violation): R9 is currently WARN-only in some paths? Verify — kernel says BLOCK on dev-mode=false write to axon/. This PR preserves severity.
- Test 4 (shell-tool write): depends on PR-1.1 (shell sandbox). Order this PR after PR-1.1 OR use `pytest.skip` for test 4 until PR-1.1 lands.

## 5. Interface sketch
No CLI change. The fix is internal to the rule.

```bash
# Before this PR (bypasses):
# workspace/sneak → ../axon
WRITE("workspace/sneak/KERNEL-SLIM.md")    # passes R9 ✗

# After this PR:
WRITE("workspace/sneak/KERNEL-SLIM.md")    # BLOCKED ✓ (realpath resolves through symlink)
```

## 6. Spec

### Files-changed
| File | Change |
|---|---|
| `tools/rules/r9_axon_write.py` | Replace `_is_axon_path` with realpath-based check. ~6 LOC. |
| `tools/enforce.py:15-19` | Replace `abspath` with `realpath` in `is_inside_axon`. ~2 LOC. |
| `tests/test_rules/test_r9_axon_write.py` | Add 4 new test cases (symlink, absolute, traversal, shell-tool). ~60 LOC. |
| `workspace/AXON-DOCS-COMPLIANCE.md` | Update "Guarded by" row for test_r9_axon_write.py. |

### Acceptance
- `pytest tests/test_rules/test_r9_axon_write.py` green (all 14 tests).
- Manual: create `workspace/test-link → ../axon` and run `python3 tools/verify.py --workspace . --action '{"op":"WRITE","target":"workspace/test-link/x.md"}'` — must report violation.
- Manual: same with absolute path `/tmp/axon-test/x.md` (after `ln -s /home/.../axon /tmp/axon-test`).
- All existing R9 tests still green.
- Audit: F-D8-001 vectors 1-3 marked resolved. Vector 4 closed by PR-1.1.

### Rollback
- `git revert <commit>`. Realpath change is idempotent; no migration.

### Owner
- AGENT: writes PR.
- HUMAN: runs pytest with appropriate fixtures, lands commit.

### Parallelism
- Independent of PR-12.1, PR-7.1, PR-2.1, PR-5.1, PR-6.1, PR-9.x.
- Test 4 depends on PR-1.1 — use skip/xfail until that lands.

## 7. Codebase grounding
- F-D8-001 (BLOCKER, 4 bypass vectors verified): `_flaws.md`
- F-D8-006 (R9 test gaps): `_flaws.md`
- D-D8-017 (R9 hardening demand): `_demands.md`
- ADR-001: `_adrs.md` (this PR is the R9 sibling to the shell.py main PR)
- Reference: `axon-reference/compliance/01-compliance-and-gates.md` § R9 write gate.

## 8. Cross-refs
- Closes: F-D8-001 vectors 1-3 (symlink, absolute, traversal); F-D8-006 (test coverage).
- Closes (with PR-1.1): F-D8-001 vector 4 (shell-tool).
- Closes: D-D8-017, D-D8-019 (R9 bypass tests demand).
- Does NOT close: F-D8-008 (the broader TOOL(shell) gate-evasion) — needs PR-1.1.

## 9. Audit trail
- ADR-001 ACCEPTED 2026-05-21
- Severity: BLOCKER → MAJOR after this PR (vector 4 remains until PR-1.1)
- Effort: S (~half-day; mostly test setup)
- Risk: low (realpath is well-tested in stdlib; tests cover edge cases)

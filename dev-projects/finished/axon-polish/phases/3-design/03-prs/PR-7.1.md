# PR-7.1 — context.py: host-model-aware context limit

## 1. Why
F-D9-001 (BLOCKER): `tools/context.py:33` hard-codes `DEFAULT_LIMIT = 128000`. The comment at line 18 says "gpt-4o / claude-3: 128000 tokens" — stale. Modern Claude 4.x has 200k context. The kernel's context-pressure gate (KERNEL-SLIM:282) calls `TOOL(context, status, --workspace W)` without `--limit`, so the 128k default is always used.

Net effect: critical-pressure (>85%) fires at ~108k tokens when the true window is 200k. Workflows halt unnecessarily early at ~54% of real headroom.

## 2. Evidence
- `tools/context.py:33`: `DEFAULT_LIMIT = 128000`
- `tools/context.py:74-75`: argparse default = DEFAULT_LIMIT
- `tools/context.py:18`: stale comment "gpt-4o / claude-3"
- Kernel call site `axon/KERNEL-SLIM.md:282`: no `--limit` arg passed
- `L:host-model` set by harness contract (`workspace/harness/claude-code.md` etc.) but `context.py` never reads it
- F-D9-005: context.py accumulator (`record` action) never reset on boot (`tools/context.py:113-145`)
- F-D9-015: divergence with `_axon_lib.py` token heuristic (1.33 tok/word vs 4 char/tok)

## 3. Design notes
Three changes:
1. **Read L:host-model**: lookup table for known models → limit. Default fallback 128k (conservative).
2. **Comment update**: reflect Claude 4.x (200k).
3. **Boot reset hook**: `tools/context.py:reset()` callable from boot to clear the accumulator on fresh session.

Lookup table (initial):
```python
MODEL_LIMITS = {
    "claude-3":        128_000,
    "claude-3.5":      200_000,
    "claude-3.7":      200_000,
    "claude-4":        200_000,
    "claude-4.5":      200_000,
    "claude-4.6":      200_000,
    "opus-4.7":        200_000,
    "sonnet-4.6":      200_000,
    "haiku-4.5":       200_000,
    "gpt-4o":          128_000,
}
DEFAULT_LIMIT = 128_000   # conservative fallback for unknown models
```

Read order: `--limit` arg > L:host-model lookup > DEFAULT_LIMIT.

## 4. Pitfalls
- Class-A: existing callers passing `--limit` explicitly should still win. Don't override.
- Class-C (data correctness): partial-match risk — `"opus-4.7-experimental"` might miss. Use longest-prefix match.
- Class-B (subprocess interop): `L:host-model` is a memory key. Tool must call `python3 axon.py memory get --scope L --key host-model` (or read longterm/host-model.md directly) — both work. Prefer the direct file read for speed.

## 5. Interface sketch
```bash
# Old (broken at high context on Claude 4.x):
python3 tools/context.py status --workspace W
  → {"limit": 128000, "tokens": 108000, "level": "critical"}   ← false alarm

# New (host-model-aware):
python3 tools/context.py status --workspace W
  → {"limit": 200000, "tokens": 108000, "level": "high", "model": "opus-4.7"}

# Explicit override still works:
python3 tools/context.py status --workspace W --limit 64000
  → {"limit": 64000, ...}
```

## 6. Spec

### Files-changed
| File | Change |
|---|---|
| `tools/context.py` | Add MODEL_LIMITS table. Add `_resolve_limit(workspace, cli_limit)` helper. Update all `status`/`pressure`/`record` actions to use it. Update comment at L18. |
| `tools/context.py` | Add `reset` action wiring to clear accumulator (already has the action — verify boot can call it). |
| `tests/test_context.py` | Update: tests for model lookup, longest-prefix match, fallback, CLI override. |
| `axon/KERNEL-SLIM.md` | Boot step 3 calls `TOOL(context, reset)` after G-11 harness detection. dev-mode required for kernel edit. |
| `workspace/AXON-DOCS-COMPLIANCE.md` | Update "Guarded by" row for test_context.py. |

### Acceptance
- `pytest tests/test_context.py` green.
- Bash check (with L:host-model = "opus-4.7"): `python3 tools/context.py status --workspace W` → reports limit 200000.
- Bash check (with L:host-model = "claude-3"): same call → reports 128000.
- Bash check (no L:host-model set): reports 128000 (default).
- Audit re-run: F-D9-001 marked resolved.

### Rollback
- `git revert <commit>`. Reset action is idempotent — safe.

### Owner
- AGENT: writes the PR.
- HUMAN: runs pytest, lands commit. Kernel edit needs `L:dev-mode = true`.

### Parallelism
- Independent of PR-1.1/1.2/12.1/2.1. Can ship in any order.

## 7. Codebase grounding
- F-D9-001, F-D9-005, F-D9-015: `_flaws.md`
- D-D7-002: `_demands.md`
- Master alignment: W3-01 (cache_control), W3-03 (ai-tokenizer) — this PR partially overlaps W3-03's "switch to ai-tokenizer" but stays conservative (no new dep).
- Reference: `axon-reference/memory/01-memory-and-state.md` § compaction + recovery.

## 8. Cross-refs
- Closes: F-D9-001, F-D9-005, D-D7-002.
- Partial: F-D9-015 (this aligns context.py with kernel intent but doesn't unify `_axon_lib.py` — that's a follow-up).
- No conflicts with ADRs.

## 9. Audit trail
- ADR reference: none required (small fix; falls under master W3-01/W3-03 family).
- Severity: BLOCKER → MAJOR after fix.
- Effort: S (~half-day).
- Risk: low (additive lookup; default-fallback preserves behavior for unknown models).

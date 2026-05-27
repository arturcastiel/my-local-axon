# PR-6.1 — session.recover(): wire to response gate via PID-mismatch hook

## 1. Why
F-D9-022 (BLOCKER, NEW iter 3): `tools/session.py:recover()` is fully implemented (state machine + PID detection per master PR-15) but **no entrypoint invokes it**. Boot step 3 doesn't call it. The response gate doesn't call it. The interrupt gate doesn't call it. The resume program doesn't call it. It's dead code.

F-D9-004 (BLOCKER): The audit's framing of "compaction recovery fires only on PID mismatch" was understated — it fires NEVER, because nothing triggers the check.

Per ADR-006 Phase 1 (accepted): wire `TOOL(session, recover)` into the kernel response gate via a cheap PID check. This connects half-built infrastructure that master PR-15 designed but never landed.

## 2. Evidence
- `tools/session.py:131-169` — `recover()` function fully implemented (state machine, transition guards, PID-mismatch trigger, recent_checkpoints[-3:] response)
- `tools/session.py:33-40` — state enum: `active|frozen|tagged|closed|recovered`
- `axon/KERNEL-SLIM.md:79-122` — response gate spec; NO call to `session recover`
- `axon/KERNEL-SLIM.md:614-650` — boot step 3 RESUME logic; NO call to `session recover`
- `workspace/programs/resume.md:23-29` — reads E:session-log; doesn't call recover
- master PR-15 spec (designed-not-built) at `axon-master/03-prs/pr-15.md`

## 3. Design notes
Single-point wire-up: add a small check at the top of the kernel response gate.

**Kernel edit** (`axon/KERNEL-SLIM.md`, response gate section):
```
# At the very top of the response gate, before STORE(W:reasoning-trace, ...):
stored-pid ← READ(workspace/memory/local/session-pid.md) | ∅
current-pid ← TOOL(shell, "echo $$") | ∅
IF stored-pid ≠ ∅ AND current-pid ≠ ∅ AND stored-pid ≠ current-pid →
  result ← TOOL(session, recover, "--workspace {W:ws-path}")
  IF result.recovered ≡ true →
    LOG(WARN, "session.recover fired: PID {stored-pid} → {current-pid}")
    EMIT(axon.session.recovered, {prior-pid: stored-pid, current-pid: current-pid})
WRITE(workspace/memory/local/session-pid.md, current-pid)   # update for next turn
```

**No tool-side change needed** — `tools/session.py:recover()` already does the right thing on invocation. This PR just adds an entrypoint.

**Boot also calls recover** (optional, second wire-up): at end of boot step 3, before EXEC(menu):
```
TOOL(session, recover, "--workspace {W:ws-path}")   # idempotent; fires only on PID change
```

## 4. Pitfalls
- Class-A (production-path): the `local/session-pid.md` file might not exist on first boot. Default to ∅; treat as "fresh session" (no recovery needed); just write the current PID.
- Class-B (subprocess): `TOOL(shell, "echo $$")` returns the SHELL's PID, not the agent's. Use `os.getppid()` semantics via a dedicated helper — or just `TOOL(session, current-pid)` if session.py already exposes that. Check.
  - **Update**: per cleanup PR-105, session.py already uses `os.getppid()` for the right semantics. The wire-up should leverage that, not call shell.
- Class-C (data correctness): the recover() function returns last-3-checkpoints; the kernel must surface a "session recovered" banner to the user, not silently restore. Use EMIT + a one-line user-visible warning at output-layer.
- Class-D (kernel edit): `axon/KERNEL-SLIM.md` requires `L:dev-mode = true`.
- Class-E: this PR closes the LIVE BLOCKER F-D9-022 (orphaned recover). Don't introduce regressions in the response-gate firing rate.

## 5. Interface sketch
No user-facing CLI change. Internal kernel behavior:

```
# Turn N (PID 12345):
... agent works ...
# write local/session-pid.md → "12345"

# Compaction OR process restart → new PID

# Turn N+1 (PID 67890):
response-gate fires
read local/session-pid.md → "12345"
read current PID → "67890"
mismatch → TOOL(session, recover)
session.recover() returns last 3 checkpoints + state="recovered"
LOG(WARN, ...) + EMIT(axon.session.recovered, ...) + user banner shown
write local/session-pid.md → "67890"
```

## 6. Spec

### Files-changed
| File | Change |
|---|---|
| `axon/KERNEL-SLIM.md` | Add PID-mismatch check to response gate top. Add `TOOL(session, recover)` call to boot step 3. Optional: response-gate emits user-visible "session recovered" banner. **dev-mode required**. |
| `tools/session.py` | Verify `recover()` returns a serializable result. May need to add `--workspace` flag if missing. |
| `tools/session.py` | Optional: add `current-pid` action that just returns os.getppid() for kernel use. |
| `tests/test_session_recover_wired.py` | New file. Test: simulate PID mismatch; verify recover fires; verify EMIT + LOG. |
| `workspace/AXON-DOCS-MEMORY.md` (or COMPLIANCE) | Document the new response-gate hook. |
| `workspace/memory/local/.gitignore` | Ensure `session-pid.md` is gitignored (it's local/). |

### Acceptance
- `pytest tests/test_session_recover_wired.py` green.
- Manual: kill+restart the harness mid-session; next turn shows the "session recovered" banner.
- F-D9-022 marked resolved (recover() now has an entrypoint).
- F-D9-004 marked resolved (compaction detection now actually fires).
- No regression in turn-cost (PID file read+write is ~1-2 syscalls; negligible).

### Rollback
- `git revert <commit>` on KERNEL-SLIM.md. session.py changes are additive.
- Delete `local/session-pid.md` if it gets into an inconsistent state.

### Owner
- AGENT: writes the spec + tests + session.py additions.
- HUMAN: runs pytest, lands commit. Kernel edit needs `L:dev-mode = true`.

### Parallelism
- Independent of PR-12.1, PR-7.1, PR-1.2, PR-2.1, PR-9.x.
- Independent of PR-1.1 (shell.py sandbox) — this PR doesn't use shell.

## 7. Codebase grounding
- F-D9-022 (NEW BLOCKER, iter 3): `_flaws.md`
- F-D9-004 (BLOCKER): `_flaws.md`
- ADR-006: `_adrs.md` Phase 1 (PID-mismatch hook)
- master PR-15 design (unbuilt): `axon-master/03-prs/pr-15.md`
- Reference: `axon-reference/memory/01-memory-and-state.md` § compaction + recovery.

## 8. Cross-refs
- Closes: F-D9-022, F-D9-004.
- Does NOT close: F-D9-011 (G-02 turns 1-4 — separate PR-6.2 covers phase-ledger enforcement).
- Does NOT close: F-D9-003 (checkpoint.py restore subcommand — separate concern, deferred to ADR-006b).
- ADR-006 Phase 2 (PR-6.2) follows this PR.

## 9. Audit trail
- ADR-006 ACCEPTED 2026-05-21 (Phase 1 = this PR).
- Severity: BLOCKER → resolved.
- Effort: S (~half-day for kernel edit + test; dev-mode pre-req).
- Risk: medium (touches the response gate; bad wiring slows every turn).

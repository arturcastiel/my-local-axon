# PR-5.1 — workflow-run: step-count guard + ctx-passing (ADR-005a)

## 1. Why
F-D4-003 (BLOCKER, runtime-traced iter 2): adaptive-free-text workflow loops infinitely. The on-complete graph routes s1→s2→s1; goal predicates always return null (F-D4-017a: `goal.acceptance.met()` not in BUILTINS); nothing mutates goal state between iterations; rejection-criterion `steps > 25` is evaluated POST-loop, which never reaches.

F-D4-018 (MAJOR): workflow-run calls `TOOL(predicate, eval, …)` with NO `--ctx`. Even `state.steps > 25` can't resolve `state` to anything; the predicate evaluator returns null; safe-null mode silently bypasses.

Per ADR-005a (accepted): the minimal fix is ~5 LOC. Move rejection-criterion evaluation INTO the loop body, build a runtime ctx with `state.steps = COUNT(trace)`, and let `OR` short-circuit on the steps comparison. Doesn't solve the broader undefined-function problem (ADR-005b handles that), but unblocks termination.

## 2. Evidence
- `workspace/programs/workflow-run.md:64-81` — LOOP body has no step-count guard
- `workspace/programs/workflow-run.md:84-86` — rejection-criterion checked only AFTER LOOP terminates
- `adaptive-free-text.yml:18` — `rejection-criteria: "steps > 25 OR goal.rejection.met()"`
- `tools/predicate.py:434` — undefined-function raises EvalError; CLI returns `result: null` (line 510-515)
- Runtime trace iter 2: confirmed infinite, not 25-bounded

## 3. Design notes
Two changes to `workflow-run.md`:

**Change 1 — Build ctx per iteration**:
```
# Inside LOOP, before on-complete eval:
trace-append(cursor.id)
ctx ← { "state": { "steps": COUNT(trace), "history": trace, "last-step": cursor.id } }
```

**Change 2 — Evaluate rejection inside loop**:
```
# Between EXEC(cursor.name) and on-complete walk:
IF wf.default-goal.rejection-criterion ≠ ∅ →
  reject ← TOOL(predicate, "eval", "--expr {wf.default-goal.rejection-criterion}", "--ctx {ctx}")
  IF reject.value ≡ true →
    EMIT("axon.workflow.rejected", { reason: "rejection-criterion met", trace: trace })
    BREAK  ← exits the LOOP cleanly
```

Apply identical pattern to `workflow-simulate.md:73-79` (same defect per agent finding).

## 4. Pitfalls
- Class-A (production-path): existing workflows without rejection-criterion still work — the IF guards against null.
- Class-C (data correctness): `state.steps` is the count of completed steps; the `> 25` predicate compares to a literal. Verify off-by-one (start at 0 or 1?). Adaptive-free-text's intent: `> 25` means after 25 completed steps. Use post-EXEC count.
- Class-D (kernel-spec adjacent): no kernel edit needed. workflow-run.md is in workspace/programs/ — not gated by dev-mode.
- Class-E (rule violation): `EMIT` before BREAK is critical — `axon.workflow.rejected` event lets downstream observers know.
- F-D4-017a sibling: this PR DOES NOT register `goal.*` in BUILTINS. The adaptive-free-text's `goal.acceptance.met()` still returns null. But `steps > 25 OR goal.rejection.met()` — `OR` short-circuits on the LHS (steps), so termination works. This is the intended scope.

## 5. Interface sketch
```
# workflow-run.md LOOP body — BEFORE this PR
LOOP {
  result ← EXEC(cursor.name)
  trace-append(cursor.id, result)
  ∀ rule in cursor.on-complete →
    IF TOOL(predicate, eval, "--expr {rule.if}").value ≡ true →
      next-id ← rule.next
      BREAK
  IF next-id ≡ ∅ → BREAK
  cursor ← wf.synapses[next-id]
}

# workflow-run.md LOOP body — AFTER this PR
LOOP {
  result ← EXEC(cursor.name)
  trace-append(cursor.id, result)

  # NEW: build ctx for predicate eval
  ctx ← { "state": { "steps": COUNT(trace), "history": trace, "last-step": cursor.id } }

  # NEW: check rejection-criterion inside loop
  IF wf.default-goal.rejection-criterion ≠ ∅ →
    reject ← TOOL(predicate, eval,
                  "--expr {wf.default-goal.rejection-criterion}",
                  "--ctx {ctx}")
    IF reject.value ≡ true →
      EMIT("axon.workflow.rejected", { reason: "rejection-criterion", trace: trace })
      BREAK

  ∀ rule in cursor.on-complete →
    # NEW: pass ctx here too
    IF TOOL(predicate, eval, "--expr {rule.if}", "--ctx {ctx}").value ≡ true →
      next-id ← rule.next
      BREAK
  IF next-id ≡ ∅ → BREAK
  cursor ← wf.synapses[next-id]
}
```

## 6. Spec

### Files-changed
| File | Change |
|---|---|
| `workspace/programs/workflow-run.md` | LOOP body: build ctx, evaluate rejection inside loop, pass `--ctx` to all predicate calls. ~12 lines added. |
| `workspace/programs/workflow-simulate.md` | Same pattern at lines 73-79 (sister defect). |
| `tests/test_workflow_termination.py` | New file. Test cases: adaptive-free-text terminates after 25 steps, rejection-criterion fires inside loop, ctx state.steps populates correctly. |
| `workspace/AXON-DOCS-WORKFLOWS.md` | Update workflow-run section to document ctx contract (state.steps available). |

### Acceptance
- `pytest tests/test_workflow_termination.py` green.
- Manual: `python3 axon.py run workspace/programs/compiled/workflow-run.cmp.md --input wf=workspace/workflows/adaptive-free-text.yml` terminates after 26 LOOP iterations (= 25 steps + final rejection eval).
- Audit: F-D4-003 marked resolved; F-D4-008 (no CHECKPOINT) NOT closed by this PR — separate concern in PR-6.x.
- F-D4-018 partially closed: predicate eval now receives ctx; broader "no global ctx convention" still open.

### Rollback
- `git revert <commit>`. workflow-run.md is workspace-side; no migrators or persisted state to undo.

### Owner
- AGENT: writes PR.
- HUMAN: runs pytest, lands commit. No kernel edit; no dev-mode requirement.

### Parallelism
- Independent of other Tier-1 PRs. Can ship anytime.

## 7. Codebase grounding
- F-D4-003: `_flaws.md` BLOCKER, runtime-traced iter 2
- F-D4-018: `_flaws.md` MAJOR, surfaced iter 3
- F-D4-017a: `_flaws.md` NEW BLOCKER (ADR-005b scope; NOT closed by this PR)
- ADR-005a: `_adrs.md` accepted; this PR IS the ADR-005a implementation
- Reference: `axon-reference/workflows/01-workflows-and-dag.md` §11 (predicate language).

## 8. Cross-refs
- Closes: F-D4-003, F-D4-018 (partial).
- Sibling cluster member: PR-5b.* (ADR-005b register full predicate vocab) — closes F-D4-017/017a.
- Does NOT close: F-D4-002 (workflow-run never enters orchestrator — ADR-007 / C-04).

## 9. Audit trail
- ADR-005a ACCEPTED 2026-05-21
- Severity: BLOCKER → resolved post-merge
- Effort: S (~half-day; mostly tests)
- Risk: medium (changes workflow runtime semantics; need test coverage on all 5 reference workflows)

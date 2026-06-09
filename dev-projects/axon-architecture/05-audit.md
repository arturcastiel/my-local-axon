# Phase 5 — Completion Audit · axon-architecture

> The project's own final node (skipping it would be the exact node-skip the workflow forbids). Method:
> re-derive the study's findings against what shipped; classify each addressed / held / out-of-scope;
> record the activation state + residual risks honestly. Date 2026-05-30, main `a998179`, gate 22/0.

## Verdict
**The safe, high-value scope is COMPLETE and the enforcement substrate is ACTIVATED.** ~27 PRs merged,
every one gate-verified; all 14 CRITICAL findings closed; ~15 MAJORs closed. **Not** "everything in the
study": 5 risky refactors are deliberately HELD (they break compat or have no program-execution-test
safety net — see below). Confidence **9/10** (deduction: the 5 held refactors + the per-turn hook's
real-world effectiveness is unverified beyond "marker set + wrappers correct").

## Finding coverage
**CRITICAL (F01–F14) — all closed:** F01 rules.py collision (rename), F02/F09/F10 advisory response-gate
(CI runs crucible + hooks installed/active + honest relabel), F03 dead rules (manifest lock), F04 crucible
not in CI, F05 no behavioral test (honest coverage + lock), F06 orphan WARN/diff-only (BLOCK gate),
F07 no liveness SoT (resolver), F08 dev-mode write-gate split-brain, F11/F12 cwd state split-brain,
F13/F14 MCP write/destroy.
**MAJOR — closed:** F15/F16 WARN tier, F17 verify status, F18/F39 L: reader, F20 _axon_lib decoupling,
F29 dead stubs, F32/F33 dispatch bugs, F35 DAG→Python, F36/F37/F38 orphan triage + manifest, F50 kernel
version-lock, F54 loop-receipt perf, F56–F60 doc-count truth+lock, F65/F66 OS-program drift lock.

## Activation state (live on this deployment)
- **Merge-time (effective):** crucible gate in CI; 3 flags ON (state-surfaced / no-orphan-tools /
  workflow-node-order); liveness BLOCK (0 orphans); rule-manifest parity; node-order; MCP read-only.
- **Per-turn (`.claude/settings.json` active):** wrappers persona-guard on `L:cognition-frame=AXON-OS`
  (now set); write-gate denies axon/ writes (exit 2); response-gate **LOG-ONLY** (surfaces violations,
  never blocks). Effective only in booted AXON sessions; non-AXON sessions no-op by design.

## Residual risks / explicitly HELD (the only open items)
1. **F30** delete 18 backward-compat ALIAS programs — deletion breaks old-name usage (violates the
   owner's "nothing breaks"); needs callers migrated + program-execution tests first.
2. **F21** package `__init__` + convert 49 sys.path bootstraps — high blast radius.
3. **F34** retire/repair the compile subsystem.
4. **F22** migrate 22 REGISTRY parsers to a shared accessor.
5. **F43/F44** checkpoint-JSON capture + single L:-writer — storage-layout change with migration risk.
Each warrants its own code-dev study + greenlight. The Python ones (F21/F22/F34/F43-44) are gate-protected
(a bad merge reds); F30 is program-layer (LLM-interpreted) so it needs behavioral tests before it is safe.

## Owner switches (everything is staged behind these)
- Escalate `verify_stop` log-only → `exit 2` for hard per-turn BLOCK, once validated false-positive-free.
- Decide whether the repo-wide hook should also gate non-AXON sessions (currently scoped off).
- The 3 flags + the AXON marker are per-deployment runtime state — set them in any other checkout.

## Honest gaps in THIS audit's own process
- The per-turn hook's effectiveness is asserted from "marker set + wrappers unit-correct + smoke-tested",
  NOT from a live multi-turn AXON session with the hook loaded — that validation is the owner's first run.
- 5 incidents occurred during execution (merge-on-red, commit-on-main, git-add abort, 2 lock-test misses);
  all caught by the guarded gate, main never broke — but they signal that the held refactors deserve
  fresh, focused studies rather than end-of-run solo execution.

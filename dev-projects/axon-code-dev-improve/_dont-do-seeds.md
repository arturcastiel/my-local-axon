# Project-wide prohibition seeds

Seed each new phase _dont-do.md on `code-dev phase start`.

- NEVER edit axon/ kernel files without L:dev-mode + per-change owner confirm (inviolable floor).
- NEVER ship a DAG-mutating code path without _axon_rollback.snapshot() wired first.
- NEVER hard-block an existing in-flight project on a new gate (WARN existing, gate new only).
- NEVER let convergence/consensus substitute for source re-verification (council Step 0).
- NEVER run build/test/merge/push autonomously — building is a human task.
- The git<->DAG reconciler is READ-ONLY in v1 (no --fix).

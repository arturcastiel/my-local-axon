# super-polish — AUDIT-FIX STATUS (15 findings, ALL FIXED)

_state=ALL-GREEN · 5 regressions + 10 new · root causes: PR-filename case/pad + workflow name-vs-id_
_branch: fix/audit-regressions · batches 1–6, full suite 4219 green, gate passed:true each batch_

| # | sev | reg | file | status |
|---:|---|---|---|---|
| 1 | high | REG | `test_safety_freeze_undo_logging.py` | ✅ fixed (freeze writes one _actions.log entry per snapshotted meta; undo restores both) |
| 2 | high | REG | `pr_export.py` | ✅ fixed (missing-spec guard) |
| 3 | high | REG | `code-dev-pr-ready.md` | ✅ fixed (routes spec via resolve-spec) |
| 4 | high | REG | `code-dev-pr-create.md` | ✅ fixed (double-prefix → ## {pr-id}) |
| 5 | medium | REG | `workflow_run.py` | ✅ fixed (advance teeth wired via --run-id; id-keyed skip-check) |
| 6 | high | new | `plan_dag.py` | ✅ fixed (case-insensitive glob) |
| 7 | high | new | `workflow-run.md` | ✅ fixed (advance reads resolved {path}, not ∅ W-key on --name) |
| 8 | high | new | `workflow_run.py` | ✅ fixed (record both node-id+name; advance compares id-to-id) |
| 9 | medium | new | `code-dev-pr-review.md` | ✅ fixed (section-scoped status flip) |
| 10 | medium | new | `code-dev-journal-log.md` | ✅ fixed (binds pr-id="general") |
| 11 | medium | new | `code-dev-safety-freeze.md` | ✅ fixed (thaw restores each meta from own `# was:`) |
| 12 | medium | new | `workflow-run.md` | ✅ fixed (ws-path resolved to concrete root; trajectory on-tree) |
| 13 | medium | new | `workflow-new.md` | ✅ fixed (resume rehydrates locals; PHASE-C preserves synapses) |
| 14 | medium | new | `crucible.py` | ✅ fixed (r_memory_respected ctx; fail-closed base) |
| 15 | low | new | `crucible.py` | ✅ fixed (changeset-base fail-closed) |

## Batch ledger (branch fix/audit-regressions)
- batch 1: pr_export missing-spec · plan_dag glob · pr-create double-prefix  (#2,#4,#6)
- batch 2: crucible fail-closed base + r_memory_respected ctx  (#14,#15)
- batch 3: resolve_pr_spec + pr-export/pr-ready routing  (#3, spec resolution)
- batch 4: pr-review section-scoped status flip + journal-log general pr-id  (#9,#10)
- batch 5: safety-freeze thaw round-trip + workflow-new resume  (#11,#13) + freeze undo dual-log (#1)
- batch 6: workflow-run trajectory subsystem as a unit — id/name + path + ws-path + teeth  (#5,#7,#8,#12)
  - NB: corrected `test_workflow_run_program_fixes.py` Bug-4, which had producer-only-locked the
    buggy `--node {cursor.name}` form (the audit's central "fixes that locked wrong behavior" lesson).

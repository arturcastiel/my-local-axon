# Kernel-tap queue — axon-hr-ui
> Changes touching axon/ (Layer 1 kernel). The inviolable floor + the autonomous grant
> (deny: kernel-change) make these HUMAN per-change confirm. Implemented + tested, then
> staged here as ready diffs for the owner's one-tap approval. NEVER auto-merged.

## OWNER-RULED
- [x] **PR-003 OS-STATE collapse — Core Rule 12 adjudication → RULED (a) rule-OK** (owner, 2026-06-23,
      "I gate ok"). Ruling: a complete-but-dense render (all-nominal → one rollup line, auto-expands on any
      non-nominal signal; every signal + section preserved) is COMPATIBLE with Core Rule 12. No kernel edit.
      Precedent: Rule 12's "every section must appear completely" is satisfied by a complete-but-collapsed
      render, not only a fully-expanded one. CLEAR TO MERGE (branch axon-hr-ui/PR-003-osstate-collapse,
      tip 8e60dc2; merge-base 3de09fc, no menu.md conflict). Remaining = mechanical: menu recompile
      (agent pipeline) + squash-merge + push. Folds in PR-011 replay-surface.

## Pending (ready for owner review)
- [ ] **kv-store.md doc** (axon/tools/kv-store.md): add the `--raw` flag + the actionable
      error to the RESULT/usage block. Trivial doc sync for the merged kv_store.py change;
      `--help` already documents `--raw`, so functional surface is covered. Low priority.

## Queued for their wave (implement → test → stage)
- PR-010 cadence knob — touches the reanchor hook + KERNEL G-02 cadence.
- PR-015 component grammar — axon/GRAMMAR.md + axon/OUTPUT-LAYER.md (deferred).
- PR-002a BOOT slice — the enforcement-posture boot line in axon/BOOT.md (the menu.md slice is autonomous).
- PR-003 output-layer slice — axon/OUTPUT-LAYER.md piece (menu.md OS-STATE collapse is autonomous).
- PR-007 BOOT slice — resume-truth re-entry block if it lands in axon/BOOT.md (menu/program slices autonomous).

## Approved (merged after owner tap)
_(none yet)_

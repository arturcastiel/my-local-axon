# Don't-do — phase pr
> Inherits _dont-do-seeds.md (project root). v4 tokenized: match: (lexical BLOCK) / review: (semantic).

- [scope] Never edit the kernel file without dev-mode + per-change owner confirm
  match: KERNEL-SLIM
- [process] No force / history-rewriting git ops in the gated flow
  match: --force
- [pattern] No fingerprint-only PR closure — a STRONG automated test must prove the claim
  review: human
- [pattern] T1-3 must NOT re-point test_crucible_failopen.py (M1: would revert a correct passing test)
  match: test_crucible_failopen
- [pattern] T0-2 Phase B flags (r_phase_tracked, r_workflow_node_order, r_no_orphan_tools) stay OFF until registered (M2: false-green)
  review: human

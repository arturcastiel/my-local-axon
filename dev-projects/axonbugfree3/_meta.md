# Project: AXON Bug-Free 3 — new-bug hunt over post-2026-07-07 surfaces
slug:            axonbugfree3
schema-version:  v4
status:          complete
legacy:          false
phase:           complete (all 5 phases done)
workflow-step:   build
branch:          feat/codemap-family
codebase:        /home/arturcastiel/projects/new-axon/axon
workflow:        _workflow.yml
parent:          axon-improvements
sub-projects:    []
created:         2026-07-13
updated:         2026-07-13 (COMPLETE — 22/22 PRs merged, kernel v1.1.11)

## Working Context
- STUDY COMPLETE 2026-07-13. Tally: 1 CRIT / 19 HIGH / 16 MED / 9 LOW ranked + ~8 below-cap + 4
  quarantined leads (+2 retracted, recorded). Ledger: AUDIT-FINDINGS.md (F-C1..F-L9); raw evidence +
  the sweep-D re-verification deltas in shadow/. Headline: the bugfix02 defect class moved into the
  newest code (tokenizer keys, zero-writer keys, bare-envelope binds); 4 incomplete fixes; kernel
  interfaces drifted from tool reality (dead drift band, phantom W:ws-path, blind chat-resume) —
  kernel-floor items are HUMAN-ONLY. Next: code-dev plan (owner).
- Run 3 of the bug-hunt series (axon-bugfix01 → axon-bugfix02 → this). Predecessors' findings
  are ALL FIXED + merged (19/19 PRs, 2026-07-07) — this run hunts NEW bugs only.
- Hunt ground: ~30 commits merged since 2026-07-07 (313 files, +13.4k lines): doctrine/obedience
  spine, codemap family, code-dev-graphify, axon-obsidian, axon-stale-pointers, axon-state-surface,
  crucible un-stick — plus live anomalies observed at boot 2026-07-13 (prompt-log split-brain,
  drift-unknown ↔ auto-improve breaker interplay) and surfaces no prior run audited.
- Method (bugfix02 precedent): parallel read-only verify-against-source sweeps → adversarial
  reconfirmation of every candidate via live run → ledger in 01-study.md / AUDIT-FINDINGS.md.
- Same autonomous envelope as axon-bug-free: AEGIS _policy.md × grant, fail-closed; kernel edits human-only.

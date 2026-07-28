# Study — axonbugfree3 (bug-hunt run 3)
date: 2026-07-13 · phase: study · status: COMPLETE

## CHARTER
Hunt NEW bugs only — bugfix01 + bugfix02 ledgers are fully fixed and merged (19/19 PRs, 2026-07-07).
Hunt ground: (1) the ~30 commits merged since 2026-07-07 (313 files, +13.4k lines — doctrine/obedience
spine, codemap family, code-dev-graphify, axon-obsidian, axon-stale-pointers, axon-state-surface, crucible
un-stick); (2) anomalies observed live at the 2026-07-13 boot; (3) surfaces no prior run audited
(hr-team, workflow-runner, suggestion chain, agent-memory, handoff/chats/plan, REGISTRY).

## METHOD
4 parallel read-only sweeps (A/B/C/D — raw returns preserved verbatim in shadow/) → main-loop adversarial
reconfirmation of the sharpest source-only claims → consolidated ledger (AUDIT-FINDINGS.md).
Bar: every finding verified at source on BOTH sides of the contract; live probe quoted where non-mutating.
Reconfirmed by main loop at source + probe: F-H2 (phase-model mutator), F-H3 (preflight fail-open),
the zero-writer key class (W:_opt-repo, W:codemap-shadow-cmd, W:_subcommand, W:_simulate-target,
W:ws-path, W:graph-query-count — all zero STORE sites repo-wide), F-H9 (BOOT.md guard verbatim),
F-H10 (drift record --type rejected live by argparse). Cross-sweep conflict resolved: A-6's "regression"
verdict corrected to the two-writer shape split F-M6 using sweep D's counter-evidence.
Sweep D additionally ran its own second source-re-verification pass (shadow/sweep-D-final-reverified.md):
2 first-pass findings RETRACTED (F-H16 re-round no-op, F-M14 empty-task key — marked in the ledger, kept
for the record), F-C2 re-graded HIGH with corrected mechanism, F-M16/F-M17 promoted, 4 unverified
first-pass leads quarantined for run 4.

## RESULT
**Tally: 1 CRITICAL · 19 HIGH · 16 MEDIUM · 9 LOW ranked + ~8 below-cap one-liners + 4 quarantined leads
(+2 retracted, recorded).**
Ledger: ../../AUDIT-FINDINGS.md (F-C1..F-L8). Raw evidence: ../../shadow/sweep-{A,B,C,D}*.md.

Headline patterns (run 3):
1. The bugfix02 defect class MOVED INTO THE NEWEST CODE — the post-07-07 families re-introduce
   tokenizer-key off-by-one, zero-writer dispatch keys, bare-envelope binds, and phantom fast-path fields.
2. Four incomplete fixes / one fix-shaped regression (827598d hr-team selector).
3. Kernel-declared interfaces drifted from tool reality (dead drift band F-H10, phantom W:ws-path F-H8,
   blind chat-resume F-H13, FILE-EXISTS drift guard F-H9) — human-only floor.
4. Refusal/guard paths that mutate or fail open (F-H2, F-H3, F-C2).

Boot-anomaly verdicts (sweep C): prompt-log split-brain = REAL (F-H8 root) · drift-unknown + breaker =
REAL fail-closed deadlock (F-H9+F-H10+2h TTL+daily cron interlock) · `axon-state get` = by-design
(no such subcommand; stderr) · pointer test-record-stale = real staleness, menu remedy overstated (F-M5, F-L8).

## KERNEL-FLOOR ITEMS (human-only — no autonomous fix permitted)
F-H8 (KERNEL-SLIM.md:118 W:ws-path) · F-H9 (BOOT.md:186 guard) · F-H10 (KERNEL-SLIM.md:192/292/345/380 +
OUTPUT-LAYER.md:129 dead drift interface) · F-H13 (BOOT.md:108 chat-index root; kernel-adjacent) ·
below-cap: BOOT.md:196 anticipate inputs · plan-new.md (axon/programs).

## NEXT (plan phase — pending owner)
Wave candidates: (1) golden-path breakers first (F-C1 workflow name-resolution, F-H4/F-H5/F-H6 codemap
family, F-H14 pattern.py crash — small, high-yield); (2) integrity/audit (F-C2 hr-team refusal pipeline, F-H2, F-H3);
(3) contract migrations (F-H11 validate callers, F-M6 tick shape split, F-M13 ranker shapes + F-H12
threshold recalibration); (4) store unifications (F-H7 logs, F-H13 chats, F-H17 episodic, F-H18 tiers);
(5) kernel spec for the human-only floor items. Lint opportunity: a zero-writer-key static lint (the class
recurred 6+ times) + an envelope-bind lint — candidates for crucible controls so run 4 hunts a smaller field.

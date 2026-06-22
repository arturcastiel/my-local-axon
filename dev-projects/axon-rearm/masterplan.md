# Masterplan — AXON Re-Arm (phase graph)
> Phase-graph master read by `code-dev resume` (Layer 2). The executable PR plan lives in
> `02-plan.md`; the PR dependency graph in `03-prs/DAG.json` (rendered `03-prs/DAG.md`).
> This file is the durable phase/wave map.

## Phases (see _phases.json — source of truth for status)
1. study — DONE  (01-study.md · the 8 council reports distilled)
2. plan  — DONE  (02-plan.md · 02-prs.md · 03-prs/DAG.json)
3. pr    — ACTIVE (03-prs/PR-*.md · per-PR specs as each opens)
4. log   — pending (04-log.md)
5. audit — pending (05-audit.md)

## Waves (= tiers) — 34 PRs, DAG'd
- Wave 0 — Arm + instrument: T0-1 · T0-2(+T0-2a) · T0-3        [CRIT — measurement unblock]
- Wave 1 — CR-13 bite:       T1-1 → {T1-2,T1-3,T1-4,T1-5}      [CRIT/HIGH]
- Wave 2 — Security floor:   T2-1 · T2-2 · T2-clone · T2-3 + M-PRs (anchor✓·devmode·loopreceipt·flags)  [own review]
- Wave 3 — Prose↔wiring:     T3-1 · T3-2 · T3-3 · T3-4          [HIGH]
- Wave 4 — Deletions/doors:  T4-shadow · T4-1..5 · T4-hrteam    [HIGH/MED]
- Wave 5 — Self-model/graph: T5-1..4                            [MED]
- Wave 6 — The experiment:   T6-exp (OD-8, after Wave 0 meter)

## Critical structure (DAG)
- Depth is shallow (max chain = 2): most PRs are independent + parallelizable.
- Main convergence: **T2-2** (protect enforcement core) gated by T0-1, T0-3, T3-3 (M7: protect-AFTER the files it freezes).
- Other chains: T0-2a→T0-2 · T1-1→{T1-2..5} · T0-1→T3-2 · {T0-1,T0-3}→T6-exp · T4-4→{T4-5,T5-3}.

## Binding amendments (02-prs.md AUDIT AMENDMENTS, 0.84 PROCEED-WITH-CHANGES)
PRINCIPLE: PROTECT-before-ARM · VERIFY-the-wire-before-ARM · RE-BASELINE-before-fix.
REVISED FIRST SPRINT supersedes the original 8 — see 02-prs.md.
All owner conflicts K2–K5 RESOLVED (2026-06-19): K2 GATE · K3 cognition-bind+both · K4 fail-closed-everywhere+wire-gated · K5 fix-first.

## Method
Conservative · test-more · redo-until-closed. Kernel edits human-only. AXON-only commit trailer.

## Compliance closure track (council 2026-06-22 · see COMPLIANCE-PLAN.md)
Adopted as the project's immediate direction. axon-rearm is reconciled-to-v4 but NOT certified.
Close in order before resuming the re-arm sprint:
1. Resolve the dirty working tree (9 modified + _policy.md) — attribute to a PR/commit or a WIP-register.
2. Audit this session's stubs (phases/pr/ pointer files + empty shadow/) — fill with real content or delete.
3. Backfill _actions.log + retro snapshot of the reconciled files (close the reversibility gap).
4. Encode T1-1+T1-cihost co-merge as an atomic DAG edge (owner-confirmed) + a test it can't land apart.
5. Add per-node dod/proves to the 34 DAG nodes (M7) + a meta-test failing on any empty node.
Then: layer-1 write-time schema-version GATE → manifest (schema-as-data) → read-only `code-dev compliance`
program (auto-fix derivable only, escalate semantic, no-false-green tests incl. dirty-tree-fails).

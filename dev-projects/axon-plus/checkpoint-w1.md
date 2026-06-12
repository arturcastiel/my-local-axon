# W1 Re-plan Checkpoint — 2026-06-12 (after PR-001/006/007/008 measurements)

## Measured state (boot-menu scenario)
baseline-as-measured 32,593 → corrected 26,480 (health-sweep scenario error) →
after pr-6 24,703 → after pr-8 **22,341** (−16% wave-to-date).
Per code-dev cycle: ~3,900 banked via compiled forms (when agent EXECs .cmp).

## Remaining boot-menu anatomy
KERNEL-SLIM 12,881 (58% — kernel, human-only) · menu.md 5,211 compiled (render content,
protected) · startup 1,377 · prefs 691 · boot 593 · harness 736 · snapshot 301.

## Decisions
1. **PR-009 RE-SCOPED** (plan designated it the fallback lever; compile pilot landed
   19–43%, making hash-shadow re-reads redundant with .cmp files). New scope:
   **sectional reads** — compile-write emits a TOC (line ranges per phase) in every
   .cmp.md header; router programs (code-dev.md 8k) are then read header-first +
   one matched branch instead of whole-file. The strongest of the five recorded levers.
2. **A-targets PROPOSAL (owner sign-off at PR-028):**
   - boot-menu ≤ 21,500 = the mechanical floor without kernel changes — reached.
   - Below that requires the KERNEL DIET (owner-only): proposal — an owner-approved
     compiled kernel core (~5k) loaded per-session with full KERNEL-SLIM on demand;
     est. −8k/session. Parked for owner decision; not in this autonomous run.
   - pr-cycle: −20% via compiled adoption (3,900/cycle already available).
3. Deferred levers (recorded, evidence-ranked): cache ordering (harness-dependent),
   delta rendering (W3 fits better — render layer), warm-start resume (session-save
   work, W5 candidate), registry-first answers (discipline doc, free anytime).

## Wave 2 unchanged. Push queue: 3 commits (GitLab outage).

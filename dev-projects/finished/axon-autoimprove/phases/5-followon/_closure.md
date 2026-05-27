# Phase 5 — Follow-on — CLOSURE

slug:            5-followon
schema-version:  v4
status:          CLOSED
opened:          2026-05-19
closed:          2026-05-19
predecessor:    `phases/4-validation/_meta.md`
successor:      `../_closure.md` (project root)

---

## Scorecard

Two-PR phase to close the in-project residual flaws routed here by the
phase-4 residual-triage doc. Both shipped same-day with all tests green
and no axon/ writes.

| # | PR | Scope | Merged | LOC code / tests |
|---|---|---|---|---|
| 1 | **PR-AUTO-401** | `workspace/programs/auto-improve.md`: master-toggle guard `DONE()` → `FAIL()` (D-A02 HARD opt-in); new ASSERT for 30-day idle-gap re-confirm against `L:auto-improve-last-confirmed-ts` (D-A17). Hint includes exact `kv-store set ...` command. | axon#30 → main | +18 / +75 |
| 2 | **PR-AUTO-402** | `tools/auto_improve.py::action_auto_archive`: 24h cooldown via `L:auto-archive-last-run-ts`. Skipped runs return orchestrator-compatible envelope (`reason: cooldown-active`, `next_run_after_ts`). Successful runs stamp the timestamp through `loop_receipt(intent='auto-update-counter')` — reusing the same intent path as `igap._bump_session` from PR-AUTO-204. Dry-run exempt. | axon#31 → main | +50 / +155 |

## Delta vs phase-5 entry brief

| Brief prediction | Actual |
|---|---|
| 2 PRs, ≤ 30 LOC + ≤ 20 LOC | Hit the upper bound — 18 + 50, no spillover into separate PRs |
| FA-20 fix = "ASSERT on `L:auto-improve ≡ true`" | Tightened further: also flipped `DONE()` → `FAIL()` because the existing guard was soft-failing on opt-out, which was the actual FA-20 finding — a subtler bug than the entry brief captured |
| FA-21 fix = "cooldown via L: kv-store" | Plus: cooldown stamp itself wrapped in loop-receipt (`auto-update-counter`). Substrate reuse came for free; brief didn't predict but it fell out cleanly |
| 5 + 5 hermetic tests | 5 + 5 ✓ |
| Backward-compat envelope on skip | Shape matched, no orchestrator surface change needed |

## Flaws closed this phase

- **FA-20** (auto-improve.md doesn't enforce D-A02 HARD opt-in / D-A17 idle-gap) — closed by PR-AUTO-401
- **FA-21** (`action_auto_archive` has no rate-limit) — closed by PR-AUTO-402

## Lessons

1. **"Soft DONE" vs "Hard FAIL" is a real distinction.** The existing
   D-A02 guard at line 39 looked like it enforced the opt-in. It didn't —
   `DONE()` on opt-out is a no-op terminal, not a refusal. The fix was
   one keyword (`DONE` → `FAIL`) but the test had to pin the operator
   explicitly so the soft form can't regress. Lesson for future kernel-
   program ASSERTs: pin both the predicate and the terminal verb.
2. **Reuse the closest substrate intent, not a new one.** PR-AUTO-402's
   cooldown stamp could have justified its own loop-receipt intent
   (`cooldown-stamp`, `kv-touch`, etc.). Reusing `auto-update-counter` —
   already whitelisted by PR-AUTO-201, already used by igap session-bump
   — kept the closed-set vocabulary intact. Zero new whitelist entries
   for the entire phase.
3. **Phase-5 was small because phase-4 triage was good.** The 4-PR
   substrate work (phase-3) + the residual-triage doc (phase-4) routed
   every residual flaw to its right home. Phase-5 had only two in-project
   items because the other four (FA-19/22/23 + the spinout side of
   FA-18) were correctly identified as out-of-scope at phase-4. Lesson:
   spend the time on triage; closing phases get shorter for free.

## Exit criteria — status

- [x] Both PRs merged (#30, #31)
- [x] FA-20 + FA-21 closed
- [x] No axon/ writes (R9 honored throughout)
- [x] Loop-receipt closed-set vocabulary preserved
- [x] All targeted regression sweeps green (5 + 5 new; 69 + 872 sweeps)

## Next

→ `dev-projects/axon-autoimprove/_closure.md` (project-level closure across all 5 phases)
→ Project `_meta.md` bumps to `status: CLOSED-EXCEPT-PR-211` (PR-AUTO-211 cooldown earliest fire: 2026-05-26)
→ Spinouts `axon-ranker-v2` and `axon-coherence-v2` inherit their seed audits and stay `proposed` until their entry conditions land

# axon-autoimprove — PROJECT CLOSURE

slug:            axon-autoimprove
schema-version:  v4
status:          CLOSED-EXCEPT-PR-211
opened:          2026-05-18
closed:          2026-05-19
predecessor:     axon-synapse (closed 2026-05-18)
successors:      axon-ranker-v2 (proposed), axon-coherence-v2 (proposed)
trailing-item:   PR-AUTO-211 (cooldown +7d, earliest fire 2026-05-26)

---

## Scorecard — across all 5 phases

| Phase | PRs merged | Days | Note |
|---|---|---|---|
| 1-study | — | 1 | 23-flaw deep audit (`02-deep-audit.md`) |
| 2-design | — | 1 | demand catalog + controllers list; spec for loop-receipt-v1 |
| 3-build | 11 | 1 | PR-AUTO-201, 202, 203, 204, 205, 208, 209, 210, 212, 213, 214 (PR-211 deferred) |
| 4-validation | 2 | 1 | PR-AUTO-301 (axon#29 fault-injection), PR-AUTO-302 (my-axon residual triage + spinout skeletons) |
| 5-followon | 2 | 1 | PR-AUTO-401 (axon#30 HARD opt-in + idle-gap), PR-AUTO-402 (axon#31 archive cooldown) |
| **Total** | **15 merged** | **1 calendar day** | + PR-AUTO-211 trailing on its 7d cooldown |

## Scope delivered

- **Closed-loop substrate**: `tools/loop_receipt.py` (PR-201) — two-phase commit ledger with boot-time recovery for every auto-actor write. Closed-set vocabulary: 7 intents · 4 target_kinds · 5 trigger sources. Whitelist + R9 enforced.
- **Every auto-actor write migrated**: `auto_improve` (PR-202), `auto_audit` (PR-203), `igap` + `dispatch` (PR-204), `_axon_io.atomic_write` R9 enforcement (PR-205).
- **Cron resilience**: PR-208 (circuit breaker + wall-clock tick budget), PR-209 (SELF-OBSERVE row exposing breaker count).
- **Static-lint family**: PR-212 (`R_TOOL_CALL_EXISTS` — catch broken TOOL() refs at lint time, the precedent for `axon-coherence-v2`).
- **Drift gate fail-closed**: PR-213.
- **Ranker predicate evaluator**: PR-214 (`synapse-suggest` wired to real predicates; closed B-DISC-3).
- **Usage baseline**: PR-210 (`usage find-program` counter — feeds future ranker work).
- **Fault-injection validation**: PR-301 — 9 hermetic scenarios over `loop-receipt-v1.md § Recovery`. No substrate bugs found.
- **Kernel-program hardening**: PR-401 — `auto-improve.md` HARD opt-in + idle-gap re-confirm.
- **Rate-limited archival**: PR-402 — 24h cooldown via L: kv + loop-receipt.

## Flaws — all 23 routed

| Status | Count | Flaws |
|---|---|---|
| Closed in-project | 17 | FA-1..17, FA-18, FA-20, FA-21, plus all B-* and D-A* items targeted by PRs 201–214/301/401/402 |
| Spun out | 4 | FA-19 → `axon-ranker-v2`; FA-22 + FA-23 → `axon-coherence-v2` |
| Trailing | 1 | PR-AUTO-211 (cooldown-dependent timing; will land on `main` independently — not a flaw, a scheduling artifact) |

See `phases/4-validation/01-residual-triage.md` for the decision table.

## Acceptance gates — final status

- [x] Loop-receipt substrate shipped (PR-201)
- [x] All known atomicity-violating writers migrated (PR-202/203/204)
- [x] Boot-recovery proven under fault injection (PR-301)
- [x] R9 chokepoint enforced inside `atomic_write` (PR-205)
- [x] Drift gate fail-closed (PR-213)
- [x] Ranker predicate evaluator wired (PR-214)
- [x] Cron circuit-breaker + budget (PR-208)
- [x] SELF-OBSERVE surface for breaker (PR-209)
- [x] Usage baseline counter (PR-210)
- [x] Static-lint precedent for structural-coherence work (PR-212)
- [x] Kernel-program HARD opt-in + idle-gap (PR-401)
- [x] Auto-archive rate-limit (PR-402)
- [x] All residual flaws have a documented disposition
- [ ] PR-AUTO-211 (`synapse-suggest decide()` cooldown) — earliest fire 2026-05-26 after 7d cooldown elapses

## Top-line lessons (compiled from per-phase closures)

1. **Closed-set vocabularies pay off everywhere.** PR-201's 7×4×5 sealed
   sets covered every wrap-site through PR-204 *and* PR-402, with zero
   extensions.
2. **Backward-compat by keyword-only kwargs.** PR-203's `append_row(...,
   *, workspace=None, actor=None)` pattern kept legacy callers
   completely untouched.
3. **`importlib.reload` is a wrecking ball.** Switch test fixtures to
   `monkeypatch.setattr` on module-level path constants.
4. **Static-lint catches latent bugs at zero runtime cost** (PR-212's
   `R_TOOL_CALL_EXISTS`). Generalizable — see `axon-coherence-v2`.
5. **Soft DONE vs hard FAIL is a real distinction.** Pin both predicate
   and terminal verb in ASSERT tests.
6. **Reuse the closest substrate intent.** PR-402's cooldown stamp
   reused `auto-update-counter` (from igap) instead of inventing
   `cooldown-stamp`. Keeps vocabulary tight.
7. **Triage time is multiplied later.** Phase-4's residual-triage doc
   (PR-302) made phase-5 a 2-PR sprint instead of a sprawling cleanup.
   Spend the time on triage; closing phases get short for free.
8. **Spinout, don't sprawl.** FA-19 (one-way ratchet) is symptomatic of
   a missing closed-loop controller — that's a project, not a patch.
   Routed to `axon-ranker-v2` instead of patched in-project.

## On exit

- `_meta.md` → status `CLOSED-EXCEPT-PR-211` (will flip to `CLOSED` after PR-211 merges)
- `axon-ranker-v2/_meta.md` and `axon-coherence-v2/_meta.md` remain `status: proposed, phase: 0-seed` until their entry conditions land
- PR-AUTO-211 is tracked outside this project — see `phases/3-build/_closure.md` for its spec

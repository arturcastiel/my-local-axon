# Phase 5 — Follow-on (axon-autoimprove)

slug:            5-followon
schema-version:  v4
status:          active
goal:            Close the two in-project residual flaws from PR-AUTO-302's triage (FA-20: auto-improve.md HARD-opt-in/idle-gap re-confirm; FA-21: action_auto_archive rate-limit). Two small PRs, after which the project closes.
opened:          2026-05-19

## Inputs

- `../4-validation/01-residual-triage.md` — the routing decision that landed FA-20 + FA-21 here.
- `../1-study/02-deep-audit.md` — original flaw details.
- `tools/auto_improve.py` (post PR-AUTO-202) — already loop-receipt-wired; FA-21's rate-limit fits the existing receipt pattern.

## PR queue

| PR              | Scope                                                                                                                                                                                                          | Closes | Status   |
|-----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|----------|
| **PR-AUTO-401** | `workspace/programs/auto-improve.md` — ASSERT `L:auto-improve ≡ true` (D-A02 HARD opt-in); ASSERT `now - L:auto-improve-last-confirmed-ts < 30d` (D-A17 idle-gap re-confirm). 5 hermetic test cases in `tests/test_auto_improve_assertions.py`. | FA-20  | ⬜ next   |
| **PR-AUTO-402** | `tools/auto_improve.py::action_auto_archive` — read `L:auto-archive-last-run-ts` from kv-store; skip if within 24h; on archive, write the new ts via the existing loop-receipt path (`intent=auto-update-counter`). 5 hermetic test cases. | FA-21  | ⬜ pending |

## Build invariants

- **R9**: no `axon/` writes. PR-401 touches `workspace/programs/`; PR-402 touches `tools/` (allowed without dev-mode).
- **Substrate reuse**: PR-402's timestamp write goes through `loop_receipt(intent='auto-update-counter')` — same path used by `igap._bump_session` in PR-AUTO-204. No new substrate.
- **Backward-compat**: `action_auto_archive` returns the same dict shape on skip-due-to-cooldown (`{"action": "skipped", "reason": "cooldown-active", "next_run_after_ts": ...}`); existing call sites (orchestrator) won't break.

## Exit criteria

- Both PRs merged.
- `_closure.md` written.
- Project `_meta.md` bumped to `status: CLOSED`.
- PR-AUTO-211 also merged (if cooldown elapsed by then; otherwise project closes with PR-211 noted as the lone trailing item).

## On exit

→ write `dev-projects/axon-autoimprove/_closure.md`
→ if `axon-ranker-v2` or `axon-coherence-v2` are ready to start, point at their `_seed.md` as successor projects.

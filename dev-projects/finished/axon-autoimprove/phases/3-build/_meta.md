# Phase 3 — Build (axon-autoimprove)

slug:            3-build
schema-version:  v4
status:          CLOSED
goal:            Implement the 7 phase-2 specs as merged axon PRs. 6 specs already landed end-to-end during phase-2; this phase is dedicated to spec #1 (`loop-receipt-v1`) — the largest and most-touching change — and the deferred companion PR-AUTO-211.
opened:          2026-05-19

## Inputs

- `../2-design/_closure.md` — phase-2 hand-off (7 specs, 6 implemented).
- `../2-design/specs/loop-receipt-v1.md` — the build sequence for this phase.
- `../1-study/02-deep-audit.md` — bug taxonomy that loop-receipt subsumes.

## PR queue

| PR              | Scope                                                              | Substrate                  | Status     |
|-----------------|--------------------------------------------------------------------|----------------------------|------------|
| **PR-AUTO-201** | `tools/loop_receipt.py` + ledger + 9 subcommands + boot-recovery + context-manager + tests | NEW tool / `axon/state/`   | ⬜ next     |
| PR-AUTO-202     | Migrate `tools/auto_improve.py` writes onto loop-receipt           | call-site only             | ⬜ pending  |
| PR-AUTO-203     | Migrate `tools/auto_audit.py` writes onto loop-receipt             | call-site only             | ⬜ pending  |
| PR-AUTO-204     | Migrate `tools/igap.py` + `dispatch-feedback` write path           | call-site only             | ⬜ pending  |
| PR-AUTO-211     | Companion menu surface for `usage find-program` (post-cooldown)    | `workspace/programs/menu.md` | ⬜ cooldown |

## Build invariants

- **R9**: PR-AUTO-201 introduces `axon/state/loop-receipt.ledger.jsonl`. Writes go through `tools/_axon_io.py::atomic_write` with `_actor="loop-receipt"` — requires adding `"loop-receipt"` to the chokepoint whitelist (sibling change inside the same PR; spec-allowed).
- **R5**: Spec #1 prohibits silent partial commits. Ledger record sequence: `BEGUN → (COMMITTED | ROLLED-BACK | ABORTED)` with monotonic seq + `recorded_at`. Boot-time recovery scans for orphaned BEGUN entries and either replays or marks ABORTED.
- **R9 escape hatch**: tests use a temp workspace fixture (already established in PR-AUTO-205 / PR-AUTO-208 / PR-AUTO-213) — no live `axon/state/` writes from the test harness.

## Exit criteria

- All 4 loop-receipt PRs merged.
- The three known atomicity-violating writers (auto_improve, auto_audit, igap+dispatch-feedback) use the new substrate.
- New hermetic test class covering: begin/commit happy path, begin/rollback, begin/abort, double-commit guard, boot recovery from orphaned BEGUN, ledger gc semantics, context-manager exception → automatic rollback.
- PR-AUTO-211 lands once the 7-day cooldown elapses.

## On exit

→ open `phases/4-validation` if any cross-cutting checks remain; otherwise skip to project closure (`_closure.md` at project root). The deep-audit's residual flaws (FA-18..FA-23) get a triage pass and either spawn spinouts or fold into a smaller follow-on phase-4.

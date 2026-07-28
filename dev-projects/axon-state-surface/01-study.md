# Study — State-Surface Integrity
Updated: 2026-07-10  ·  Iterations: 1  ·  AXON: 9/10  ·  User: 9/10
Parent: axon-stale-pointers (sibling — "the menu surfaces wrong state")

## Goal
Make it structurally impossible for a menu / state warning field to be rendered from an
agent-guessed filesystem path. Warning fields must resolve in code (the snapshot tool),
from canonical keys — never a hand-typed path in the render layer.

## Root-cause (owner correction — verbatim: "it was an error of the MODEL not the logic")
The 2026-07-10 boot rendered a FALSE "Backup ⚠ not configured" while backup was healthy
(enabled=true, status=ok, last push 2026-07-01). The failure was EXECUTION-LAYER, not
program logic: `menu.md` correctly specifies `local-path ← RETRIEVE(W:myaxon-local) | …`,
but the agent hand-resolved that path with a wrong prefix, read nothing, and asserted the
negative. `plans` (SCAN of W:myaxon-plans) hit the identical pattern the same boot.
Code cannot stop a model from guessing a path — but it CAN delete the surface where a path
must be resolved by the render layer at all.

## Enabling surface (source-confirmed, not recalled)
`tools/axon_state.py::cmd_menu_snapshot` (L194–283) — the "one-call state" tool meant to
carry every menu field — assembles: dispatch_index_count, drift, prompt_log, todos,
workflows, audit_7d_total, working_keys, pointers, longterm, programs_total. It OMITS
`backup` and `plans`. Those two therefore fall back to agent-side READ/SCAN of a
hand-resolved path (menu.md:71–76, 208–218 for backup; 84–88, 231–236 for plans). That
fallback is the guess-surface. Two live instances confirmed one class, one boot.

## Priorities
1. **Snapshot authority** — add `backup` + `plans` to `cmd_menu_snapshot`, resolved
   in-process from canonical paths (`root/my-axon/memory/local/myaxon-backup-*.md` ·
   `root/my-axon/plans/*.md`), following the existing fail-soft `None`-on-failure
   convention (axon_state.py:236, :254). The path idiom already exists at axon_state.py:257
   (pointer-check uses `root/my-axon/dev-projects`) — no new machinery.
2. **Fallback discipline** — reconcile with the lossless mandate (the equivalence test
   *wants* a per-field fallback). DECISION (this study): snapshot becomes authoritative;
   the menu's agent-side READ/SCAN fallback for these two is replaced by a DETERMINISTIC
   mirror, not deleted — so `tests/test_menu_snapshot_equivalence.py` still holds. (User
   endorsed this direction at 9/10; final form validated in plan against the test.)
3. **Regression test** — extend `tests/test_menu_snapshot_equivalence.py` to pin
   `backup`+`plans` parity, plus an invariant: no menu warning-field is sourced from an
   agent-side `READ(`/`SCAN(` that is absent from the snapshot. (Core Rule 13.)

## Constraints
- reduce-surface (inherited dont-do from parent): extend `axon_state.py` + `menu.md` +
  the existing equivalence test ONLY. NO new top-level tool. NO new state store.
- Kernel floor untouched — this is a workspace tool + program change, no axon/ core edit.

## Tech Stack
Python (tools/axon_state.py, pytest) + AXON-LANG render program (workspace/programs/menu.md).

## Key Concepts
- menu-snapshot = the single-call authoritative state carrier; anything it omits degrades
  to a per-field agent probe (the failure surface).
- Fail-soft `None` convention is deliberate (lossless mandate) — new fields must honor it.
- Warning fields (⚠) are the high-risk subset: a wrong value becomes a false alarm.

## Open Questions (resolve in plan — not blockers)
- (a) Does the equivalence test's design permit dropping the agent fallback, or must it
  remain as a deterministic mirror? (Chosen direction: mirror; confirm against the test.)
- (b) Confirm the canonical `W:myaxon-plans` path (root/my-axon/plans vs. MYAXON-declared).

## Architecture Snapshot — fix sites
- `tools/axon_state.py:194-283` — add backup+plans fields (fail-soft).
- `workspace/programs/menu.md:71-76,84-88,208-218,231-236` — consume snapshot; mirror fallback.
- `tests/test_menu_snapshot_equivalence.py` — extend parity + add warning-field invariant.

## Honest boundary
Removes the resolution surface + fallback guess-path. Cannot force a freeform render to
consult the snapshot; full determinism (tool renders the menu) is a larger change — logged
as a follow-up, out of this project's scope.

## Sources
- tools/axon_state.py (cmd_menu_snapshot, L194-283) — read this session
- workspace/programs/menu.md (backup/plans render + fallbacks) — read this session
- live `axon-state menu-snapshot` output (empirical: backup/plans absent) — this session

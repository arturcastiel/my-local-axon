# PR-F6 — Re-flip breaker + cadence WARN→BLOCK, with END-TO-END proof (the re-earned ratchet)

- **Status:** spec
- **Phase:** 2-followups
- **Depends on:** PR-F2 (breaker recorder), PR-F3 (cadence run-marker) — both must be real first
- **Complexity:** M
- **Why:** PR-F1 dropped breaker + cadence to WARN because they were hollow. F2/F3 made them real (recorder
  wired + guarded; cadence bites unattended runs + fails closed). Now restore BLOCK — but unlike PR-007
  (which flipped on hand-fed state and shipped a hollow BLOCK green), **prove it END-TO-END in the real gate
  path** first. Writing that proof surfaced a real defect:

  **The cid mismatch (must fix, or BLOCK is hollow again):** the breaker RULE computes
  `autonomy_breaker.change_id(changed)` (no anchor) while the RECORDER (crucible `_record_breaker_outcome`,
  PR-F2) writes `change_id(changed, anchor=active_phase)`. In a real run with a project loaded the two keys
  DIFFER, so the rule checks an empty id and the same-change-red breaker NEVER sees the recorded reds. (The
  per-rule tests missed it because, with no project loaded, both fall back to the path-based id — the same
  isolation gap.) The recorder + rule must compute the SAME id.

## Mechanism
- **Single-source the cid:** `autonomy_breaker.anchored_change_id(repo_root, changed)` resolves the active
  phase (via the gate rule's helpers, robust import, fail-soft to path-based) and returns
  `change_id(changed, anchor=phase)`. BOTH the recorder (crucible) and the breaker rule call it → they
  always agree on "the same change".
- **Re-flip `_required` → BLOCK-default** in `r_autonomy_breaker.py` + `r_autonomy_cadence.py` (re-invert
  PR-F1: `except OSError → return True`; `== "true"` → `!= "false"`; `value: false` opts OUT → WARN).
- **End-to-end proof tests** (the whole point — drive the REAL `run_changeset`, not hand-fed state):
  - breaker: an unattended off-workflow run repeated → the same-change breaker BLOCKs (would FAIL with the
    cid mismatch; passes once recorder + rule share `anchored_change_id`).
  - cadence: an unattended run with a lapsed reanchor → R_AUTONOMY_CADENCE BLOCKs.

## Changes Required
### tools/autonomy_breaker.py
- Add `anchored_change_id(repo_root, changed)` (robust import of the gate rule's `_active_project` /
  `_project_dir` / `_active_phase`; fail-soft to `change_id(changed)`).
### tools/crucible.py
- `_record_breaker_outcome`: use `autonomy_breaker.anchored_change_id(cwd, changed)` (drop the inline anchor
  logic — single source).
### tools/rules/r_autonomy_breaker.py
- `check()`: `cid = autonomy_breaker.anchored_change_id(repo_root, changed)` (was `change_id(changed)`).
- `_required` → BLOCK-default.
### tools/rules/r_autonomy_cadence.py
- `_required` → BLOCK-default.
### tests
- `test_crucible.py`: the two end-to-end BLOCK proofs above.
- `test_r_autonomy_breaker.py` / `test_r_autonomy_cadence.py`: re-flip the per-rule default → BLOCK; opt-OUT
  (`value:false` → WARN) replaces the PR-F1 opt-IN test. (No-project fallback keeps `_trip`/`check` aligned.)

## Acceptance criteria
1. `anchored_change_id` returns the SAME id the recorder writes; the breaker rule sees the recorder's reds.
2. END-TO-END: a repeated unattended off-workflow run trips R_AUTONOMY_BREAKER at BLOCK via `run_changeset`.
3. END-TO-END: an unattended lapsed run trips R_AUTONOMY_CADENCE at BLOCK via `run_changeset`.
4. Both rules BLOCK by default; `value:false` → WARN.
5. The interactive/no-grant guard still holds (no false-positive in attended dev). `crucible gate`
   passed:true on this on-workflow changeset (which is on-workflow + not lapsed + breaker clean → the
   re-flipped rules don't fire on it).

## Test plan
Targeted: the two end-to-end crucible tests + the reversed per-rule tests + a unit test that
`anchored_change_id` matches the recorder's id for a project+phase fixture. Full suite + gate (parse
passed SEPARATELY — the rules are BLOCK again; confirm the gate's own changeset is clean). No dev-mode.

## Note
After F6: all 6 followup PRs done → run the RE-AUDIT (owner directive), then close or open phase 3.

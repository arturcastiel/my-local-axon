# PR-F3 — Cadence: autonomous-run marker, fail-closed counter, record-after-HALT

- **Status:** spec
- **Phase:** 2-followups
- **Complexity:** M
- **Depends on:** PR-F1 (cadence is WARN, safe to fix), PR-F2 (reuses the `run_active` marker)
- **Why:** Three audit findings on the cadence:
  - **F3 (false POSITIVE):** `R_AUTONOMY_CADENCE` enforces whenever `load_grant().active` — but that's true
    for an INTERACTIVE grant too (the live one), so once turn-count climbs it would BLOCK ordinary attended
    work. Gate on `run_active` (the unattended marker PR-F2 built), not mere grant presence.
  - **F2 (false NEGATIVE / dormant):** `turn_count()` returns 0 when `turn-count.md` is absent (CI / fresh
    checkout), conflating "absent" with "0" → `since=0` → never lapses → inert exactly where it should
    enforce. In an autonomous run, an ABSENT counter means "cannot verify the cadence" → fail CLOSED (treat
    as due), not silently fresh.
  - **F7 (corrupts the invariant):** `autonomy-reanchor.md` runs `record-reanchor` BEFORE the fail-closed
    `IF frame.ok ≡ false → HALT`, so a drifted reanchor that HALTs still records a successful fire — the
    cadence then believes the frame was re-asserted. Record only AFTER the frame-intact check.

## Changes Required
### tools/rules/r_autonomy_cadence.py
- Resolve my-axon via the canonical resolver (`autonomous_mode._resolve_myaxon(<repo_root>/workspace, None)`)
  rather than hardcoded `repo_root/my-axon` (consistent with where the grant is written; partial F4).
- Replace the `load_grant(mx).get("active")` guard with `autonomous_mode.run_active(mx)` — enforce only in
  an unattended run.
- Fail-closed: when `run_active` and the turn-count counter is ABSENT/unreadable, flag (BLOCK/WARN per the
  ladder) with reason "cannot verify reanchor cadence — turn-count absent in an unattended run".
### tools/autonomy_cadence.py
- Distinguish "absent" from 0: `turn_count()` returns `None` when the counter file is absent/unreadable (0
  stays a real 0). Add a small helper the rule uses (e.g. `counter_present(ws)` or have `check()` return a
  `counter_present` field) so the rule can fail-closed. Keep `since_reanchor`/`should_reanchor` behaviour
  for a present counter unchanged.
### workspace/programs/autonomy-reanchor.md
- Move `TOOL(autonomy-cadence, record-reanchor)` to AFTER the `IF frame.ok ≡ false → HALT` check (and after
  the non-autonomous early DONE) — record a fire ONLY when the frame is verified intact.

## Acceptance criteria
1. `R_AUTONOMY_CADENCE` is silent for an active INTERACTIVE grant (the live one), even with turn-count ≥ 5
   and no reanchor — closes F3. It flags only when `run_active`.
2. In an unattended run with NO turn-count file, the rule flags (fail-closed) — closes F2.
3. With a present counter ≥ every and no recorded reanchor → flags; fresh after a recorded reanchor → silent
   (existing behaviour preserved).
4. `autonomy-reanchor.md`: `record-reanchor` appears AFTER the frame-HALT and after the non-autonomous DONE
   (assert by program-order test) — closes F7.
5. The rule stays WARN by default (PR-F1); re-flip is PR-F6. `crucible gate` passed:true on this changeset.

## Test plan
Update `test_r_autonomy_cadence.py`: the autonomous cases now set an UNATTENDED grant (mode), add an
interactive-grant-silent case (F3) + an absent-counter-fail-closed case (F2). `test_autonomy_cadence.py`:
`turn_count` absent → None (not 0). A program-order test for the reanchor (F7). Full suite + gate green.
No dev-mode expected for the .py files; the reanchor.md edit is a workspace/program (not axon/), so still
no dev-mode.

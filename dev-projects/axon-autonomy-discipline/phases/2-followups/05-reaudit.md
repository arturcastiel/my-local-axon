# Re-audit — phase 2-followups repairs (owner directive: "after all these fix, one audit again")

> Adversarial multi-agent re-audit, 2026-06-03, over the REPAIRED discipline (PRs F1–F6 / !118–!123).
> Three agents verified each fix end-to-end AND hunted for bugs the fixes introduced. **Verdict: the repairs
> HOLD for everything they targeted — but the fixes introduced new defects (1 HIGH false-positive + 3 MED).**
> The re-audit earned its keep: the HIGH is a live BLOCK false-positive on healthy runs that all unit tests
> miss. → phase 3-reaudit-fixes.

## CLOSED (verified end-to-end, grounded by running the code)
- Breaker recorder is genuinely wired; rule + recorder share `anchored_change_id` (same id in a real run) —
  the F1 hollow-BLOCK is closed.
- `run_active` silences the live interactive grant (no `mode`) — F3 false-positive closed; attended dev safe.
- Cadence fail-closed-on-absent-counter does NOT brick run-start: the changeset rules run at the MERGE gate,
  by which point the kernel has written turn-count (the contract interview alone is ≥6 turns) — it bites
  only a genuinely broken/non-booted or truly-lapsed unattended run (correct). F2 closed.
- Reanchor records its fire only after the drift-HALT (F7) — locked by program-order tests.
- Gate-rule F4 (my-axon via W:myaxon-path — load-bearing here: the real my-axon IS relocated), F5/F6 happy
  paths, contract F8 common path — all closed.

## NEW defects the fixes introduced (ranked) → phase 3
| # | sev | finding | fix | PR |
|---|---|---|---|---|
| R1 | **HIGH** | Breaker: `record()` green zeroes `consecutive_fails` but NOT the per-change `reds`. With phase-anchoring, the 2nd gate-red ANYWHERE in a phase trips BLOCK — across a green, for different work (red→green→red on first attempt → BLOCK). Halts healthy unattended runs; no test covers red→green→red on one cid. | `record()` green also sets `entry["reds"] = 0` (clear the same-change streak). Live-validated: L1 + F12 intent preserved, false halt gone. | G1 |
| R2 | MED | Gate rule `_spec_is_open`: `not any(t in val …)` substring-scans the WHOLE status line, so an OPEN spec whose status prose contains a terminal word (`spec — supersedes the merged PR-001`) is misread terminal → false-BLOCK (HIGH-impact in a single-spec phase; LOW probability today — no such format in the live corpus). | parse only the FIRST token of the status value (mirror `axon_audit.py:384`). | G2 |
| R3 | MED | Gate rule `_candidate_phases` UNION: a stale `_phases.json` active phase carrying an old open spec "covers" work in a different `_meta.phase` → off-workflow code slips through (false-NEG; the inverse of the F6 false-POS it fixed; also disagrees with reanchor which uses `_meta` first). | prefer `_meta.phase` authoritatively — require an open spec IN it when present; union only as fallback when `_meta.phase` absent. | G2 |
| R4 | MED | Breaker reset wired ONLY into `autonomy_contract.write`, not a run boundary — a run via direct CLI grant / re-attach inherits stale `reds`/`consecutive_fails` → can trip on its first change. | reset on the unattended-grant CLI path too (`autonomous_mode on --mode unattended`). | G1 |
| R5 | LOW | Contract `_preserve_and_backup`: (a) an owner-directive line nested in `## Notes` is duplicated; (b) `## Notes` authored ABOVE `## capabilities` slurps the stale capabilities block → two capabilities blocks (aegis_policy reads the first, so NO privilege flip — integrity only). | de-dup; stop the Notes slurp at the next `##` heading. | G3 |
| R6 | LOW | Gate rule `_myaxon_root` value-line parse keeps a trailing `# comment` + multi-line bare → dir not found → gate silent (false-NEG). | strip inline comment + take first line (mirror `_active_project`). | G2 |
| R7 | LOW/RESID | Stale/wrong `W:myaxon-path` → a different tree's same-slug project covers (gate passes while the real repo is off-workflow). Inherent to honoring the pointer; now load-bearing with no repo↔project cross-check. | optional: cross-check resolved `_meta.codebase`/`branch` vs repo. Documented RESIDUAL. | (note) |
| R8 | LOW | `_resolve_myaxon` fallback (`parent-of-repo/my-axon`) ≠ `_myaxon_root` fallback (`repo/my-axon`) when no pointer → grant my-axon and project my-axon can disagree. Doesn't break rule↔recorder agreement. | align the two no-pointer fallbacks. | G1 |

## Plan — phase 3-reaudit-fixes (on-workflow; gate-first; the discipline governs its own repair)
- **PR-G1 (do FIRST — the HIGH):** breaker `record()` green resets `reds` (R1) + reset on CLI unattended grant (R4) + align my-axon fallbacks (R8). End-to-end test: red→green→red on one anchored cid does NOT trip; red→red (no green) STILL trips.
- **PR-G2:** gate rule — first-token status parse (R2) + prefer-`_meta` coverage (R3) + myaxon comment/first-line strip (R6). Tests for each (a prose-laden open status stays open; a stale-json phase no longer covers a spec-less `_meta` phase).
- **PR-G3:** contract `_preserve_and_backup` — de-dup nested directive + bound the Notes slurp to the next `##` (R5).
- **R7** documented as an inherent RESIDUAL (honoring a pointer trades silence-on-relocation for trust-the-pointer; optional cross-check noted).

## Meta-lesson (logged)
The re-audit found that 6 careful, gated, end-to-end-tested PRs STILL shipped a HIGH false-positive (R1) and
two MED soundness gaps (R2/R3) — all green in the unit suite. The pattern repeats: **a fix is a change, and a
change needs its own adversarial pass.** R1/R2/R3 are precisely the cases the per-rule unit tests don't model
(red→green→red on one cid; prose in a status line; stale-json vs _meta). The discipline's own thesis — assert
the effect in the real path, adversarially — applies to the repairs too. Hence: re-audit, then fix, then
(after G1–G3) one more confirming pass before declaring done.

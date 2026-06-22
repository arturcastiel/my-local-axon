# Study — HR-Team Improvements

## 1. Goal
Make `hr-team` able to ALWAYS convene a REAL advisory council — wire the dormant `run_seats` fan-out seam,
and guarantee fail-closed behaviour in EVERY checkout so a stub verdict can never be presented as real.

## 2. The finding (verified in code + cross-session)
Contract (hr-team.md → hr-team-selector → hr-team-convener → hr-team-deliberator): SELECTOR picks seats from
a registered catalog; CONVENER assembles sealed per-seat message triplets and runs them through ONE seam —
`run_seats(messages[]) → responses[]` ("v1 = harness sub-agent fan-out"); DELIBERATOR aggregates into the
§4.3 verdict object.

Code reality (tools/hr_team.py):
- **Dev checkout (new-axon, this repo), run_seats ~line 60-78:** FAIL-CLOSED — raises NotImplementedError
  unless `AXON_HR_TEAM_ALLOW_STUB=1`; the stub then stamps every seat `"STUB (no real cognition wired)"` and
  returns `variant-{a/b/c}` with synthetic confidences. The seam is still NOT wired to real cognition.
- **For-use checkout (owner cross-session test), reported `hr_team.py:50`:** FAIL-OPEN — the un-guarded stub
  ran, returned `variant-c` / `0.2533` placeholder scores, and the DELIBERATOR presented them as a real §4.3
  verdict. The SELECTOR also failed to match a good profession roster → "the LLM took over."

So: (a) the seam is unwired in BOTH; (b) the two checkouts have DIVERGED (one safe, one dangerous);
(c) there is no auto-bridge from CONVENER to actual harness sub-agents, so a faithful run of the convener
neuron produces fabricated utterances on the fail-open copy.

## 3. Evidence it's not a one-off (owner confirmation 2026-06-22)
- Owner verified the stub in code and called it "a genuine architecture/igap item, not a one-off."
- A live council in the for-use session produced synthetic verdicts; the working result there came only
  because the operator BYPASSED the stub and hand-spawned 5 real sub-agents (manual run_seats backend).
- axon-rearm's own compliance council had to do the same bypass. Logged igap (fallback-exec) 2026-06-22.

## 4. Owner decisions (resolved at seed)
- OD-A: WIRE the seam — CONVENER must hand its sealed message triplets to a real harness sub-agent fan-out.
- OD-B: FAIL-CLOSED in every checkout — propagate the guard; AXON_HR_TEAM_ALLOW_STUB is tests-only and a
  stub response may NEVER reach a verdict object surfaced to a user.
- OD-C: SELECTOR must produce a domain-matched roster (the for-use run mis-matched professions); a weak/empty
  roster is itself a fail-closed condition, not a silent fallback.

## 5. Fix vectors (→ become PRs in the plan phase)
1. **[CRIT · urgent] Propagate fail-closed guard to the for-use checkout** — close the silent-fabrication window now.
2. **Wire CONVENER → harness sub-agent fan-out** (the real run_seats backend; ADR-002 quarantine boundary kept).
3. **Conformance test:** a STUB seat response can NEVER reach a §4.3 verdict; fail-open is BLOCKED. (Core Rule 13)
4. **SELECTOR roster-quality gate:** empty/weak/mis-matched roster → fail-closed + loud, never LLM-takeover.
5. **Reconcile the two checkouts** on tools/hr_team.py (divergence is the dev-version-drift family).

## 6. Method
Conservative · test-more · redo-until-closed. PR-T4-hrteam (in axon-rearm) is the parent finding; this project
executes it. Same fail-open thesis as axon-rearm — fix it as a fail-closed exemplar.

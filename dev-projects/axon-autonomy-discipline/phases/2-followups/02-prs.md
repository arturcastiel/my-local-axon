# PR List — AXON Autonomy Discipline (phase 2-followups)
Updated: 2026-06-03  ·  Total PRs: 6  ·  Source: phases/1-safety-contract/05-audit.md (14 findings)

> Phase 1 shipped the discipline + flipped it to BLOCK. The adversarial audit proved the BLOCK was premature:
> the breaker is a hollow no-op (no recorder), the cadence is dormant-in-CI / false-positive-live, and the
> gate rule has false-negatives (my-axon path, status-blind coverage) + narrow false-positives. This phase
> makes the discipline REAL, then re-earns BLOCK. Fixed on-workflow (the gate rule, still BLOCK, governs this
> repair). Each PR asserts the fix in the REAL gate path (end-to-end), not just the state machine in isolation
> — that isolation-only testing is what let the dormant-BLOCK gap ship green.

## PR-F1 — Selective revert: un-overstate the hollow BLOCK (SAFETY, do first)
- **Status:** ✅ merged (!118, squash ef89593) — gate passed:true, zero warnings. Breaker+cadence now WARN-default (opt-IN via `value:true`); gate rule UNCHANGED at BLOCK. The reverted-rule tests assert default→WARN + opt-in→BLOCK.
- **Complexity:** S
- **Scope:** `tools/rules/r_autonomy_breaker.py` · `tools/rules/r_autonomy_cadence.py` (revert `_required` → WARN-default) · `tests/test_rules/test_r_autonomy_breaker.py` · `tests/test_rules/test_r_autonomy_cadence.py`
- **Depends on:** none
- **Why:** `R_AUTONOMY_BREAKER` can never trip (no recorder — F1) and `R_AUTONOMY_CADENCE` is dormant-in-CI / false-positive on an interactive grant (F2, F3). Claiming BLOCK on them is overstatement + latent interactive-BLOCK risk. Revert these two to WARN; KEEP `R_CODE_CHANGE_REQUIRES_PR_PHASE` at BLOCK (it works + is the load-bearing anti-freelance teeth + governs this repair). Re-flip in PR-F6 once F2/F3 make them real.
- **Spec:** 03-prs/PR-F1.md ✓

## PR-F2 — Breaker: wire the recorder, run-scoped reset, intent-keyed change-id
- **Status:** ✅ merged (!119, squash ef1f628) — gate passed:true, zero warnings. Recorder wired into `run_changeset` (guarded by `run_active`, an unattended-run grant marker the contract sets); change-id anchored to the active phase (F12); unattended contract resets the breaker (F13). The wiring test drives the real `run_changeset` — it would have caught F1.
- **Complexity:** M
- **Scope:** `tools/crucible.py` `run_changeset` (record red/green per change after the verdict, guarded by an autonomous-run marker) · `tools/autonomy_breaker.py` (`reset()` called at run start; coarser `change_id` keyed on PR/phase, not exact paths) · tests (end-to-end: a real gate red→red on the same change trips)
- **Depends on:** PR-F1
- **Why:** F1 (hollow — no caller of `record`), F12 (evolving-retry false-negative: a new file → new change-id → never trips), F13 (`consecutive_fails` never resets — `reset()` has no caller → stale cross-run accumulation → false halts). Make the breaker actually observe the gate.
- **Spec:** 03-prs/PR-F2.md (not written yet)

## PR-F3 — Cadence: autonomous-run marker, fail-closed counter, record-after-HALT
- **Status:** ✅ merged (!120, squash 7fa3b66) — gate passed:true, zero warnings. Rule gates on `run_active` not grant-presence (F3); resolves my-axon via the canonical resolver; fails closed on an absent counter (F2); the reanchor program records its fire only AFTER the drift-HALT (F7). [Process note: the commit first landed on main — branch-first was skipped mid-flow; recovered by moving it to a branch + resetting main before push. No remote rewrite.]
- **Complexity:** M
- **Scope:** `tools/rules/r_autonomy_cadence.py` (gate on an autonomous-RUN marker, not mere grant presence) · `tools/autonomy_cadence.py` (distinguish absent counter from 0 → fail-closed in an autonomous run) · `workspace/programs/autonomy-reanchor.md` (move `record-reanchor` to AFTER the `frame.ok` check) · tests
- **Depends on:** PR-F1
- **Why:** F3 (interactive grant ≠ autonomous run → false BLOCK), F2 (absent `turn-count.md` → since=0 → never lapses → no-op in CI), F7 (a HALTing/drifted reanchor records a successful fire → corrupts the cadence). Make the cadence bite the right runs + only on a true re-anchor.
- **Spec:** 03-prs/PR-F3.md (not written yet)

## PR-F4 — Gate rule: canonical my-axon, status/file-aware coverage, phase reconcile, robust imports
- **Status:** ✅ merged (!121, squash 1072515) — gate passed:true, zero warnings. my-axon via W:myaxon-path (F4); status-aware coverage — merged/terminal specs don't count (F5); union of _meta.phase + _phases.json so a disagreement never false-blocks (F6); the reanchor inherits the helpers. F10 (import fragility) DEFERRED — held-refactor F21 territory + latent; F11 (empty 03-prs) by-design. File-level coverage left as a noted future refinement.
- **Complexity:** M
- **Scope:** `tools/rules/r_code_change_requires_pr_phase.py` (resolve project dir via the canonical `W:myaxon-path`/`$MYAXON_ROOT` resolver; "covering" = open-status spec, ideally file-covered; reconcile `_phases.json` vs `_meta.phase`) · `tools/autonomy_reanchor.py` (same my-axon fix + import consistency) · tests (relocated my-axon, merged-status spec, cross-file change, phase disagreement, package-path import)
- **Depends on:** none (independent of F1–F3; the gate rule stays BLOCK throughout)
- **Why:** F4 (hardcoded `repo_root/my-axon` → silent false-NEG when relocated), F5 (status-blind filename glob → stale/merged specs let off-workflow code through), F6 (`_phases.json` vs `_meta.phase` disagreement → false BLOCK), F10 (import-context-locked), F11 (empty `03-prs/` → subsumed by status/file-aware coverage).
- **Spec:** 03-prs/PR-F4.md (not written yet)

## PR-F5 — Contract: preserve `_policy.md`, enforce-or-mark budget
- **Status:** ✅ merged (!122, squash d479915) — gate passed:true, zero warnings. `_policy.md` backed up to `.bak` + owner-directive/`## Notes` preserved across a re-write + `policy_caps_changed` flagged (F8); `budget` stored structured on the grant + the program calls it ADVISORY, not an enforced "re-confirm" (F9). Full budget enforcement (a PR counter in the merge path) left out of scope — honesty over a half-built counter.
- **Complexity:** S
- **Scope:** `tools/autonomy_contract.py` (backup + merge non-capability lines of `_policy.md`; warn on capability change; budget — enforce a PR counter OR mark advisory in the program) · `workspace/programs/autonomy-contract.md` · tests
- **Depends on:** none
- **Why:** F8 (`write()` clobbers the hand-tuned `_policy.md` — loses the owner directive + notes), F9 (`budget` collected + promised "re-confirm" but never enforced — write-and-ignore).
- **Spec:** 03-prs/PR-F5.md (not written yet)

## PR-F6 — Re-flip breaker + cadence WARN→BLOCK (re-earn the ratchet)
- **Status:** ✅ merged (!123, squash 5434e22) — gate passed:true, zero warnings. Both rules BLOCK-default again (opt-out via `value:false`). Writing the END-TO-END proof surfaced + fixed a real defect: the breaker rule and the recorder keyed DIFFERENT change-ids (rule un-anchored, recorder phase-anchored) → unified via `autonomy_breaker.anchored_change_id` (single source). Two `run_changeset`-level tests prove the breaker + cadence actually trip at BLOCK in the real gate path. The live interactive grant (no `mode`) → `run_active` False → attended dev never enforced against (verified before flipping).
- **Complexity:** S
- **Scope:** `tools/rules/r_autonomy_breaker.py` · `tools/rules/r_autonomy_cadence.py` (revert `_required` → BLOCK-default) · tests (END-TO-END: the rule fires in the real gate path with the recorder wired + counter present — not hand-fed state)
- **Depends on:** PR-F2, PR-F3
- **Why:** once the breaker records + the cadence bites the right runs (F2/F3), restore BLOCK — the ratchet, re-earned. The end-to-end test is the point: prove enforcement in the production wiring, the gap that shipped green in phase 1.
- **Spec:** 03-prs/PR-F6.md (not written yet)

## After PR-F6 — RE-AUDIT (owner directive 2026-06-03: "after all these fix[es], one audit again")
Once F1–F6 land, run the adversarial multi-agent audit AGAIN over the now-repaired discipline — same method
as 05-audit.md (independent agents trying to break each piece in the REAL gate path), to confirm: (a) every
F-finding is actually closed end-to-end (not just unit-green), (b) no new bug was introduced by the fixes,
(c) the re-flip to BLOCK (F6) is genuinely earned. Findings → a phase 3 if any survive; clean → close the
project. This is the close-the-loop verification; it does NOT count toward the 6 fix PRs.

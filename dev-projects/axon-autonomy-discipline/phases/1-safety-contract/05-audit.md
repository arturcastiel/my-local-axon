# Audit — axon-autonomy-discipline deliverables (PRs !111–!117)

> Adversarial multi-agent audit, 2026-06-03 (owner-directed). Three agents independently attacked the
> shipped discipline; every finding below is grounded + reproduced. **Headline: PR-007's flip to BLOCK was
> PREMATURE — the discipline is largely hollow + has false-positive risk; the tests pass only because they
> exercise the state machines in isolation, never the production wiring (the original audit's lesson,
> reproduced).** This becomes phase **2-followups**.

## Verdict
The enforcement floor is *architecturally* right (gate / reanchor / contract / breaker / cadence) and the
least-privilege floor is solid, BUT the BLOCK flip overstates reality and can brick legitimate work. Fix
before keeping BLOCK.

## Findings (ranked; → followup PR)
| # | sev | finding | fix | PR |
|---|---|---|---|---|
| F1 | **CRIT** | Breaker BLOCK is a permanent no-op — nothing records gate outcomes; `autonomy_breaker.record` has zero non-test callers; state always `{}` → never trips. | wire the recorder into `run_changeset` (record red/green per change-id, guarded by an autonomous-run marker) — or keep WARN until wired | F-2 |
| F2 | **HIGH** | Cadence dormant in CI + deadlock live — `turn-count.md` gitignored/kernel-only (absent→since=0→never lapses); no auto-fire/reset → once since≥5 only a manual reanchor clears it. | fail-closed on absent counter in an autonomous run; wire auto-fire/reset; else keep WARN | F-3 |
| F3 | **HIGH** | Cadence FALSE POSITIVE — "grant active" ≠ "autonomous run"; the live grant is interactive, so interactive work BLOCKs once turn-count climbs. | gate on an autonomous-run marker (e.g. an active autonomy loop), not mere grant presence | F-3 |
| F4 | **HIGH** | Gate-rule my-axon path — `_project_dir` hardcodes `repo_root/my-axon`, ignoring `W:myaxon-path` (→ `…/axon-sections/my-axon`) + `$MYAXON_ROOT` → silent (false-NEG) when relocated/worktree. `autonomy_reanchor` shares the blind spot. | resolve via the canonical resolver (`_axon_paths`/`W:myaxon-path`) | F-4 |
| F5 | **HIGH** | Gate-rule "covering" = any `PR-*.md` filename — ignores `Status:` (merged/stale specs count forever) + ignores file-coverage → off-workflow code slips through (false-NEG). | parse Status (open-only); add file-coverage (changed code ⊆ spec file-lists) | F-4 |
| F6 | MED | `_active_phase` lets `_phases.json` (wins) disagree with `_meta.phase` → checks wrong phase → false BLOCK. | prefer `_meta.phase` for v4 / check all candidate phases | F-4 |
| F7 | MED | Reanchor records its fire BEFORE the fail-closed HALT → a drifted/HALTing reanchor records success → corrupts the cadence (fail-closed invariant broken). | move `record-reanchor` to after the `frame.ok` check (record only on success) | F-3 |
| F8 | MED | `autonomy_contract.write` clobbers hand-tuned `_policy.md` wholesale (loses owner directive + notes; no backup/merge); silently changes effective policy if the level differs. | backup + merge non-capability lines; warn on capability change | F-5 |
| F9 | MED | `budget` collected + promised ("re-confirm") but never enforced (write-and-ignore). | enforce (count PRs, halt at zero) or mark advisory in the program | F-5 |
| F10 | MED | Import-context-locked — `autonomy_reanchor.py` top-level `import _longterm` fails as `tools.autonomy_reanchor`; the `from rules…` deferred import breaks under the editable install + differs from the gate rule's `from tools…`. | robust/consistent imports; add a package-path import test | F-4 |
| F11 | MED | Empty `03-prs/` → false BLOCK in the plan→first-edit window. | subsumed by F5 (status/file-aware coverage) | F-4 |
| F12 | LOW | Breaker `change_id` = hash of sorted paths → an evolving retry (one file added) is a new id → same-change-red breaker never trips (defeats lesson L1; only consecutive-N catches it). | key "same change" on PR/phase id, not exact paths | F-2 |
| F13 | LOW | `consecutive_fails` resets only on explicit green + `reset()` has no caller → stale cross-run accumulation → false halts once F1 lands. | call `reset()` at run start; record green on every pass | F-2 |
| F14 | LOW | Malformed flag file (`# c\nfalse`) doesn't opt out — but fails toward BLOCK (safe). | note only | — |

## Plan — phase 2-followups (fix on-workflow, gate-first; the discipline now applies to its own repair)
- **PR-F1 (do FIRST, safety):** SELECTIVE revert. KEEP `R_CODE_CHANGE_REQUIRES_PR_PHASE` at BLOCK — it
  works on this repo, it is the load-bearing anti-freelance teeth, and it governs this very repair. Revert
  ONLY `R_AUTONOMY_BREAKER` + `R_AUTONOMY_CADENCE` to WARN — they are hollow (breaker has no recorder;
  cadence is dormant-in-CI / false-positive-live). Un-overstate enforcement + remove the latent
  interactive-BLOCK risk. Owner wanted BLOCK; the gate teeth STAY at BLOCK — only the two hollow accessories
  wait until F2/F3 make them real, then PR-F6 re-flips them per-rule with end-to-end tests.
- **PR-F2:** breaker — wire the recorder into `run_changeset` + run-scoped reset + coarser change-id (F1, F12, F13).
- **PR-F3:** cadence — autonomous-run marker (not grant-presence) + fail-closed on absent counter + record-after-HALT (F2, F3, F7).
- **PR-F4:** gate rule — canonical my-axon resolver + status/file-aware coverage + phase reconciliation + robust imports (F4, F5, F6, F10, F11).
- **PR-F5:** contract — `_policy.md` backup/merge + budget enforce-or-advisory (F8, F9).
- **PR-F6:** re-flip the now-wired-and-sound rules WARN→BLOCK, per-rule, with end-to-end (not isolated) tests.

## Meta-lesson (logged)
The BLOCK flip is the original audit's central finding, self-inflicted: enforcement shipped + made mandatory
on mechanisms validated only in isolation, never end-to-end against the production wiring. The fix is not
just the 14 findings — it is the testing discipline: assert the rule fires in the REAL gate path (recorder
wired, counter present, my-axon resolved), not just that the state machine trips when hand-fed state.

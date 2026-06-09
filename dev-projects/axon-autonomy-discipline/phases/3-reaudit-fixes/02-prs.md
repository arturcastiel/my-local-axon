# PR List — AXON Autonomy Discipline (phase 3-reaudit-fixes)
Updated: 2026-06-03  ·  Total PRs: 3  ·  Source: phases/2-followups/05-reaudit.md (8 findings, 1 HIGH + 3 MED + 4 LOW)

> The re-audit of the F1–F6 repairs found the fixes introduced new defects (all green in the unit suite).
> This phase closes the material ones. Each PR adds the END-TO-END / adversarial case the unit tests missed.
> On-workflow; gate-first (the gate rule, BLOCK, governs this repair).

## PR-G1 — Breaker correctness: green clears the same-change streak (the HIGH, do first)
- **Status:** ✅ merged (!124, squash 616f5d7) — gate passed:true, zero warnings. `record()` green now clears per-change `reds` (R1 — red→green→red no longer false-trips; red→red + green→red→red still trip); CLI `on --mode unattended` resets the breaker (R4); `_resolve_myaxon` no-pointer fallback → repo sibling (R8).
- **Complexity:** S
- **Scope:** `tools/autonomy_breaker.py` (`record()` green → `reds=0`) · `tools/autonomous_mode.py` (reset breaker on CLI `on --mode unattended`; fix `_resolve_myaxon` no-pointer fallback to the repo sibling) · tests
- **Depends on:** none
- **Why:** R1 (HIGH) — green resets `consecutive_fails` but not per-change `reds`, so with phase-anchoring the 2nd red anywhere in a phase trips BLOCK across a green / for different work → halts healthy runs. R4 — reset only on contract write, not the direct-CLI unattended path. R8 — `_resolve_myaxon` fallback (`parent-of-repo/my-axon`) ≠ `_myaxon_root` (`repo/my-axon`); align to the repo sibling (and it's the correct location — workspace's sibling, not its grandparent).
- **Spec:** 03-prs/PR-G1.md ✓

## PR-G2 — Gate-rule soundness round 2: first-token status, _meta-authoritative coverage, pointer parse
- **Status:** ✅ merged (!125, squash 1da6d1a) — gate passed:true, zero warnings. `_spec_is_open` now decides on the FIRST alphabetic token (skips ✅/decorations), so terminal prose can't false-block an open spec (R2); `check()` prefers `_meta.phase` for coverage — a stale `_phases.json` phase no longer covers a spec-less current phase (R3), still resolving the F6 disagreement; `_myaxon_root` strips an inline comment + takes the first line (R6).
- **Complexity:** M
- **Scope:** `tools/rules/r_code_change_requires_pr_phase.py` (`_spec_is_open` first-token parse; `check()` prefer `_meta.phase` for coverage, union only as fallback; `_myaxon_root` strip inline comment + first line) · tests
- **Depends on:** none
- **Why:** R2 (MED) — substring status scan false-BLOCKs an open spec with terminal prose; parse only the first token (mirror `axon_audit.py`). R3 (MED) — the union lets a stale `_phases.json` phase mask a spec-less `_meta` phase (false-NEG); require coverage in `_meta.phase` when present. R6 (LOW) — `_myaxon_root` keeps a trailing `# comment` / multi-line.
- **Spec:** 03-prs/PR-G2.md (not written yet)

## PR-G3 — Contract integrity: bound the `_policy.md` Notes slurp
- **Status:** ✅ merged (!126, squash 15cd720) — gate passed:true, zero warnings. Notes slurp bounded to the next `##` heading (R5b — no longer swallows a following capabilities block) + owner-directives nested in Notes no longer duplicated (R5a). **PHASE 3-reaudit-fixes COMPLETE (3/3).**
- **Complexity:** S
- **Scope:** `tools/autonomy_contract.py` (`_preserve_and_backup`: de-dup an owner-directive nested in Notes; stop the Notes slurp at the next `##` heading) · tests
- **Depends on:** none
- **Why:** R5 (LOW) — a directive inside `## Notes` is duplicated; `## Notes` above `## capabilities` slurps the stale capabilities block (two blocks; aegis reads the first, so no privilege flip — integrity only).
- **Spec:** 03-prs/PR-G3.md (not written yet)

## RESIDUAL (documented, not a PR)
- **R7** — a stale/wrong `W:myaxon-path` can resolve a different tree's same-slug project (gate passes while
  the real repo is off-workflow). Inherent to honoring a relocation pointer; optional future hardening:
  cross-check the resolved project's `_meta.codebase`/`branch` against the repo. Noted, not fixed.

## After PR-G3 — confirming pass
A focused re-check that R1–R6 are closed end-to-end + no new regression, then close the project (or a
phase 4 only if something survives). THEN switch to super-polish for the MEGA audit (separate project).

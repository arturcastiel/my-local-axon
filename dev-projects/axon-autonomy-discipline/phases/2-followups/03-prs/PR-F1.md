# PR-F1 — Selective revert: un-overstate the hollow BLOCK (safety)

- **Status:** spec
- **Phase:** 2-followups
- **Complexity:** S
- **Depends on:** none (do first)
- **Why:** The phase-1 audit (05-audit.md) proved PR-007's BLOCK flip was premature for two of the three
  rules. `R_AUTONOMY_BREAKER` can **never trip** (nothing records gate outcomes — F1), so its BLOCK is a
  hollow no-op that advertises enforcement it cannot deliver. `R_AUTONOMY_CADENCE` is **dormant in CI**
  (absent `turn-count.md` → `since=0` → never lapses — F2) yet **false-positive live** (the active grant is
  *interactive*, but "grant active" is the only proxy for "autonomous run" — F3), so once a booted session's
  turn-count climbs ≥5 it would BLOCK ordinary human work. Both must step back to WARN until F2/F3 make them
  real. `R_CODE_CHANGE_REQUIRES_PR_PHASE` is sound on this repo and is the load-bearing anti-freelance teeth
  — it STAYS at BLOCK (and governs this very repair).

## Mechanism
Invert each of the two rules' `_required()` back to **WARN by default** (the pre-PR-007 form): absent flag /
unreadable → WARN; the flag (file or ctx state) becomes an explicit **opt-IN** to BLOCK (`value: true` /
state `true` → BLOCK). The gate rule's `_required` is left untouched (BLOCK-default). This is a committable
repo-wide change (longterm/ is gitignored, so a local flag would not merge).

Concretely, in `r_autonomy_breaker.py` + `r_autonomy_cadence.py`:
- `except OSError: return True`  →  `except OSError: return False`
- file path: `line.split(":",1)[1].strip().lower() != "false"`  →  `== "true"`
- file fallback: `raw.strip().lower() != "false"`  →  `== "true"`
- ctx-state path: `str(state[...]).strip().lower() != "false"`  →  `== "true"`
- Update the `_required` docstring comment: "WARN by default; opt-IN to BLOCK via `value: true`".

## Acceptance criteria
1. `R_AUTONOMY_BREAKER` + `R_AUTONOMY_CADENCE`: `_required` returns **False** by default (WARN); `true`
   (flag or ctx state) → BLOCK. A tripped breaker / lapsed cadence with no flag → severity WARN.
2. `R_CODE_CHANGE_REQUIRES_PR_PHASE` is UNCHANGED — still BLOCK by default (assert in its existing test).
3. The two rule tests: default tripped/lapsed → **WARN** (was BLOCK after PR-007); an opt-IN test
   (`value: true` / state `true` → BLOCK) replaces the PR-007 opt-OUT test.
4. `crucible gate` `passed:true` parsed SEPARATELY (this PR's own changeset is on-workflow: phase
   2-followups active + this spec present).

## Changes Required
### tools/rules/r_autonomy_breaker.py · tools/rules/r_autonomy_cadence.py
- Revert `_required` to WARN-default (the four edits above + the comment).
### tests/test_rules/test_r_autonomy_breaker.py · tests/test_rules/test_r_autonomy_cadence.py
- `test_*_flags_block` (default) → assert severity **WARN**.
- `test_opt_out_to_warn` → replace with `test_opt_in_to_block` (`value: true` / state `true` → BLOCK).

## Test plan
pytest the two reverted rule tests → green; full suite (gate's pytest control) green; `crucible gate` →
parse `passed` SEPARATELY (the gate rule is still BLOCK — confirm this on-workflow changeset passes). No
dev-mode (tools/rules + tests only).

## Note (not in scope)
This does NOT touch the gate rule, the breaker state machine, the cadence tool, or the reanchor program —
those are F2/F3/F4. PR-F1 is purely the severity walk-back of the two hollow rules.

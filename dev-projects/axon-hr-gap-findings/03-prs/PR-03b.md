# PR-03b — gain.md health "(smoke)" qualifier (companion)
Project:     axon-hr-gap-findings
Created:     2026-06-19
Complexity:  S
Depends on:  none (independent; companion to PR-03)
Status:      not-started
AXON score:  9/10
Gap:         G6 (health display misleading — gain.md render site)

## Summary

PR-03 (menu.md) surfaces the "(smoke)" qualifier on the health tier display.
`workspace/programs/gain.md` renders the same 4-tier health score from the same
`L:health-score` key but in a different format: the tier lines (L116-119) have
no "Health" prefix — the section header at L114 provides the label for the block.

Fix: add `(smoke)` to the section header only (L114). Tier render lines L116-119
are left unchanged — the header qualifies the entire block.

Surfaced by: PR-03 council audit (F1 finding).

## Entry Conditions

- `workspace/programs/gain.md` exists — ✓ confirmed
- L113: `IF hscore ≠ ∅ →` — control flow, unchanged
- L114: `→ "  HEALTH  ·  last scored {hscore-date}"` — change target ✓ confirmed
- L116-119: tier renders (`●●●●● {hscore}/100 — Excellent` etc.) — unchanged
- L:health-score key is real (written by `tools/health.py --persist`) — ✓ confirmed
- No test required (display-only; Core Rule 13 exemption: edit to existing program file)
- Crucible green before push

## Changes Required

### workspace/programs/gain.md — line 114 (section header only)

**What:** Add ` (smoke)` to the HEALTH section header. One line changed.

**Before (exact, line 114):**
```
  → "  HEALTH  ·  last scored {hscore-date}"
```

**After:**
```
  → "  HEALTH (smoke)  ·  last scored {hscore-date}"
```

**Unchanged (lines 113, 115-121):**
```
IF hscore ≠ ∅ →
  → "  HEALTH  ·  last scored {hscore-date}"      ← becomes HEALTH (smoke)
  → "  ─────────────────────────────────────────────────"
  IF hscore >= 90 → → "  ●●●●● {hscore}/100  —  Excellent"
  IF hscore >= 70 → → "  ●●●●○ {hscore}/100  —  Good"
  IF hscore >= 50 → → "  ●●●○○ {hscore}/100  —  Fair — run health-check"
  IF hscore <  50 → → "  ●●○○○ {hscore}/100  —  Poor — run health-check now"
  → ""
```

**Why:** The section header scopes the entire health block. Adding `(smoke)` to
the header qualifies all 4 tier renders without changing each individually.
Approach differs from PR-03 because the tier lines here do not contain the word
"Health" — qualifying each tier would require appending to grade strings, which
is more disruptive and less readable.

**Implementation note:** Single Edit call. `old_string` = exact L114 content
(one line); `new_string` = L114 with `(smoke)` inserted. Do not touch L116-119.

## Architecture Impact

Zero. Same as PR-03: render-only change. L:health-score key, computation logic,
and `IF hscore ≠ ∅` control are unchanged.

## Tests

No pytest required (Core Rule 13 exemption: edit to existing program file, not a
new file or tool). Verification is a shell grep:

```bash
grep -n "HEALTH (smoke)" workspace/programs/gain.md
```
Expected: 1 match at line 114.

Confirm tier renders unchanged:
```bash
grep -n "●●●●●\|●●●●○\|●●●○○\|●●○○○" workspace/programs/gain.md
```
Expected: 4 matches at lines 116-119 (unchanged — no "(smoke)" in tier lines).

## Acceptance Criteria

- [ ] Line 114: `→ "  HEALTH (smoke)  ·  last scored {hscore-date}"`
- [ ] Lines 116-119: tier renders unchanged (no "(smoke)" in grade-bar lines)
- [ ] Line 113 (`IF hscore ≠ ∅ →`): unchanged
- [ ] `grep -c "HEALTH (smoke)" workspace/programs/gain.md` returns `1`
- [ ] `grep "HEALTH [^(]" workspace/programs/gain.md` returns no matches
  (confirms no unqualified HEALTH header remains)
- [ ] Crucible green

## Risks & Gotchas

- ⚠ **Double-space around `·`**: Original header has two spaces before and after
  the center-dot: `"  HEALTH  ·  last scored ..."`. Preserve that spacing when
  inserting `(smoke)`: `"  HEALTH (smoke)  ·  last scored ..."`. One space
  between `HEALTH` and `(smoke)`.
- ⚠ **Companion ordering**: PR-03b can be merged before or after PR-03 (no
  dependency). Recommend merging together in the same session.

## Files Analysed (shadow index)

- workspace/programs/gain.md (L113-121 · HEALTH block · change target L114)

All health-score render sites verified (self-contained — does not require PR-03):
- workspace/programs/menu.md L159-162: grade-bar tiers with "Health" prefix —
  handled by PR-03 (separate spec)
- workspace/programs/status.md L87: `→ "  Health  {hscore}/100  ({hscore-dt})"` —
  raw score + date, no grade bars, not misleading. Out of scope.
- workspace/programs/axon-compare.md L166: `→ "  Health:  {health-score}/100"` —
  raw score, no grade bars, not misleading. Out of scope.
- workspace/programs/stats.md L89-90: `●●●●●` appears in COMPUTATION context
  (building score labels), not a display render to user. Out of scope.
- workspace/programs/health-check.md L59: progress log line, not a display. Out of scope.
- workspace/programs/compiled/menu.cmp.md: retired compiler artifact (2026-06-10). Ignore.

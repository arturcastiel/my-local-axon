# PR-SP-1 — Close the commit-gate fail-opens (MEGA M2 + M5)

- **Status:** spec
- **Phase:** 3-resweep-fixes
- **Complexity:** S
- **Depends on:** none (do FIRST — this is the gate guarding every commit message, incl. this campaign's)
- **Why:** the MEGA re-sweep (MEGA-resweep-2026-06-03.md) found two fail-opens in `tools/lint_commit_trailer.py`,
  the commit-msg brand/trailer gate:
  - **M2 [MED, fail-open]** `_scan_body_leaks` exempts brand-scanning for any line that *startswith*
    `"Co-authored-by: AXON"` (PREFIX). So `Co-authored-by: AXON via Claude Code <noreply@anthropic.com>`
    is skipped, and `FORBIDDEN_COAUTHORS` (which wants `Co-authored-by:\s*<brand>` in the value slot) also
    misses it → the brand leaks with ZERO violations. This is exactly the body-brand-leak class the gate
    exists to catch (the 2026-05-26 incident).
  - **M5 [LOW, fail-open]** the `--range` backstop `continue`s past a commit whose body is unreadable
    (`_git_out` → None) → that commit is never scanned for leaks.

## Mechanism
- **M2:** replace the prefix exemption with an EXACT-match: a line is exempt only when its scrubbed prose
  equals `REQUIRED_TRAILER` exactly. The canonical trailer has no brand token, so it passes; a trailer with
  an appended harness name no longer gets a free pass → its brand is flagged.
- **M5:** on a None body in `--range`, fail closed — record a violation (`any_bad=True` + surface the sha)
  rather than silently skipping.

## Acceptance criteria
1. A message whose only co-author line is `Co-authored-by: AXON via Claude Code <…>` → flagged (brand
   self-reference). The canonical `Co-authored-by: AXON <axon@arturcastiel.github.io>` → still passes.
2. `--range` with an unreadable commit body → non-zero exit (fail closed), not a silent skip.
3. Existing behaviour intact: a clean authored message with the canonical trailer passes; a `Co-authored-by:
   Claude` line is still flagged; `PR-\d+` / `Generated with` / brand-in-prose still flagged.
4. `crucible gate` passed:true on this on-workflow changeset (super-polish loaded, phase 3-resweep-fixes,
   this spec open).

## Changes Required
### tools/lint_commit_trailer.py
- `_scan_body_leaks`: `not prose.lstrip().startswith("Co-authored-by: AXON")` → `prose.strip() != REQUIRED_TRAILER`.
- `main` `--range` loop: a None body → `any_bad=True` + `_print_violations([...], where=sha)`, then continue.
### tests/test_lint_commit_trailer.py (create if absent)
- brand-appended-trailer flagged · canonical trailer passes · range None-body fails closed · regressions.

## Test plan
Targeted tests for the two fail-opens + the regressions; full suite + gate (parse passed SEPARATELY). No
dev-mode (tools/ + tests/ only). NOTE: the commit message for THIS PR must itself avoid the literal brand
word (describe it as "a harness name appended after AXON") — the gate bans it in prose.

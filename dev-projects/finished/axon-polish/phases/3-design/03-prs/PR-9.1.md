# PR-9.1 — menu.md / quickstart.md / help.md: remove duplicated halves

## 1. Why
F-D1-001, F-D1-002, F-D1-003 (all BLOCKER, 100% verified iter 3): three user-facing programs ship with **two complete program bodies in a single file**:
- `menu.md`: 584 lines, `DONE(menu)` ×2, `!NORM | read-only` ×2, two `## LOAD CONTEXT`, two `## OUTPUT` blocks.
- `quickstart.md`: 425 lines, `DONE(quickstart)` ×2, contradictory step counts (7-step vs 5-step in same file).
- `help.md`: 195 lines, `DONE(help)` ×2, two different parsing implementations of `W:help-target`.

These are the three files a new user touches first. Core Rule 12 mandates `Menu is ALWAYS rendered in full` — so a duplicated menu is rendered twice on every boot. The 7-step/5-step contradiction in quickstart confuses first-session users. The two parsers in help.md are non-equivalent (different EXTRACT calls).

Per iter 1 sampling: 100% of paste-without-replace claims confirmed via direct check.

## 2. Evidence
- `grep -c "^DONE(menu)" workspace/programs/menu.md` → 2
- `grep -c "^DONE(quickstart)" workspace/programs/quickstart.md` → 2
- `grep -c "^DONE(help)" workspace/programs/help.md` → 2
- `wc -l workspace/programs/{menu,quickstart,help}.md` → 584, 425, 195
- Iter 1 BLOCKER trace confirmed line-range divisions:
  - menu.md: lines 1-356 (current 7-mode menu) + 358-584 (legacy 8-mode menu with `mode-programs`)
  - quickstart.md: lines 1-233 (7-step resumable) + 235-425 (5-step legacy)
  - help.md: lines 1-119 (PARSE-based) + 121-195 (EXTRACT-block-based)

## 3. Design notes
For each file, determine which half is "canonical" and remove the other. The criteria:

**menu.md**: Keep the 7-mode current version (lines 1-356). Reason: matches COMMANDS.md mode shortcuts (1-7 + D); the legacy 8-mode version references `mode-programs` which doesn't exist in axon/programs/.

**quickstart.md**: Keep the 7-step resumable version (lines 1-233). Reason: matches faq.md's intent of a multi-step tour; matches mod-of-5 G-02 identity check; the 5-step legacy version uses `QUERY(user) → W:_ack` pattern which is older.

**help.md**: Keep the first half (lines 1-119). Reason: `PARSE(help-raw, "# usage: {v}")` matches the kernel's PROGRAM-TEMPLATE expectation. The EXTRACT-block-based second half assumes a `# HELP` block which most programs don't have (F-D2-002: only 53% of programs have `# usage:` headers, and the # HELP block convention is even rarer).

Migration to a single canonical half:
1. Delete the second half of each file.
2. Verify no compiler artifact in `workspace/programs/compiled/` references the deleted lines.
3. Reconcile FAQ + menu tip pool to match canonical step count for quickstart (already says "7 steps" per F-D1-013).

## 4. Pitfalls
- Class-A (production-path): both halves currently parse — second half is dead code per the first `DONE(...)`. Removing it should be safe.
- Class-C (data correctness): verify `workspace/programs/compiled/{menu,quickstart,help}.cmp.md` are NOT byte-equal copies including the dead halves (per F-D3-007: 82% of compiled outputs are placeholder copies). If they include the dead halves, regenerate the compileds.
- Class-D (kernel adjacent): `axon/PROGRAMS-INDEX.md` may need a touch if it references the legacy mode-programs. Check before merging.
- Class-E (rule violation): the file-shrink reduces context cost; Core Rule 12 (menu full render) is satisfied by the canonical half alone.

## 5. Interface sketch
No user-facing CLI change. Output of `menu`, `quickstart`, `help` becomes 50%/45%/40% shorter (better, not worse).

```
# Before:
$ # Run menu — emits 580-line dashboard (entire content twice)

# After:
$ # Run menu — emits ~290-line dashboard (canonical 7-mode panel only)
```

## 6. Spec

### Files-changed
| File | Change |
|---|---|
| `workspace/programs/menu.md` | Delete lines 358-584 (the legacy 8-mode duplicate). File becomes 356 lines. |
| `workspace/programs/quickstart.md` | Delete lines 235-425. File becomes 233 lines. |
| `workspace/programs/help.md` | Delete lines 121-195. File becomes 119 lines. |
| `workspace/programs/compiled/menu.cmp.md` | Regenerate via `python3 axon.py compile workspace/programs/menu.md` (if quarantined per F-D3-007, may be a no-op). |
| `workspace/programs/compiled/quickstart.cmp.md` | Same. |
| `workspace/programs/compiled/help.cmp.md` | Same. |
| `workspace/programs/faq.md` | Reconcile "5-section" → "7-step" (one line edit at line 152). |
| `workspace/programs/menu.md` (tips) | Update tip pool: "Type 'quickstart' for a guided tour" → "Type 'quickstart' for a 7-step interactive tour" (consistent with reality). |
| `tests/test_no_duplicate_program_bodies.py` | New file. Lint check: assert `^DONE(...)` count == 1 across every program. |

### Acceptance
- `pytest tests/test_no_duplicate_program_bodies.py` green.
- `pytest tests/` overall still green.
- Manual: `python3 axon.py run workspace/programs/compiled/menu.cmp.md` — output is single full menu render, not duplicated.
- Manual: `quickstart` interactive tour completes step 7, not loops back to step 1.
- Audit: F-D1-001, F-D1-002, F-D1-003 marked resolved.
- F-D1-013 (length contradiction) closed via reconciled FAQ + tip pool.

### Rollback
- `git revert <commit>`. The deleted halves are recoverable from git history.

### Owner
- AGENT: writes PR (line deletions + tests).
- HUMAN: runs pytest, reviews diff, lands commit. Compiled regen is best done by `python3 axon.py compile ...` (one shell call) — agent can describe but human runs.

### Parallelism
- Independent of all other Tier-1 PRs.

## 7. Codebase grounding
- F-D1-001, F-D1-002, F-D1-003: `_flaws.md` (100% verified iter 3)
- F-D1-013 (length contradiction across files): `_flaws.md`
- Reference: `axon-reference/programs/01-programs-inventory.md` § program shape.

## 8. Cross-refs
- Closes: F-D1-001/002/003, F-D1-013 (partial via reconciled FAQ + tip).
- Sibling PR-9.2: r_reasoning_trace.py dead-code removal (same pattern, separate file).
- Does NOT close: F-D1-007 (menu output still 290 lines after dedupe — separate "slim menu mode" demand D-D1-003).

## 9. Audit trail
- No ADR required (mechanical cleanup).
- Severity: 3 BLOCKERs → resolved.
- Effort: S (~half-day; mostly verifying which half is canonical).
- Risk: very low (deleting dead code; tests catch regressions).

# REPORT — P3 · careful-cassie

**date**: 2026-05-16 · **workflows attempted**: W-03 (all 3 modes), W-04 (all 4), W-05, W-06, W-07, W-09, W-10
**status**: extensive audit; 3 S1 + 4 S2 + 1 S3 filed

## In-character summary

I read every program before invoking it. Three independent S1 blockers
stand out:

1. **F-001 — Header-vs-filename mismatch in every PR-26/27/28 rename.**
   Cited line 1 of 24 program files. Verified by `head -1` against actual
   filenames. The dispatch contract is broken until these are corrected.

2. **F-007/F-008 — Save/restore round-trip is unimplemented.**
   `code-dev-state-save.md` is a body-copy of `code-dev-tag.md` (different
   semantics — tag is user-labeled, not project-snapshot). `state-restore`
   is a 7-line stub that doesn't restore anything. PR-27's "partner program"
   contract is half-complete.

3. **F-002 — `code-dev-review` router → internals fail to dispatch.**
   The router EXECs `code-dev-review-scope` etc.; those files still announce
   `code-dev-scope-check` in their header. Subsumed by F-001 once fixed.

Other findings I logged are friction/polish (F-011 budget overlap,
F-012 journal semantic overlap, F-013 pr_drift heuristic, F-019 study
budget doc drift, F-004 safety-audit-structure duplicate).

## Top findings I filed

| id     | sev | summary                                                  |
|--------|-----|----------------------------------------------------------|
| F-001  | S1  | 24 renamed files retain old `# PROGRAM:` header           |
| F-002  | S1  | review router internals can't be found by header          |
| F-007  | S1  | state-save is a body-copy of tag — round-trip broken      |
| F-008  | S1  | state-restore is a 7-line non-functional stub             |
| F-011  | S2  | plan blanket budget contradicts per-mode caps             |
| F-012  | S2  | journal-* semantic boundaries undocumented                |
| F-013  | S2  | pr_drift heuristic silently passes short criteria         |
| F-019  | S2  | study # modes: block lacks "overrides blanket" note       |
| F-004  | S1  | safety-audit-structure is duplicate, not a route target   |

## Top-3 proposed edits

1. **F-001 sweep** — single Python loop, 24 files, 1 line each. Unblocks
   F-002 immediately. Highest leverage.
2. **F-007 option 1** — accept `state-save = tag` aliasing; correct the
   `# desc:` line; delete `state-restore.md`. ~15 lines total. Removes
   the misleading "partner program" promise without inventing features.
3. **F-013 fix** — add `unmet.append(...)` for unparseable criteria in
   `pr_drift.py`. 3 lines. Removes a false-positive gate.

## Verdict

AXON's surface is large and mostly well-engineered. The W4 rename umbrella
landed but the **body-edit step** was skipped: filenames moved, headers
didn't. Fix F-001 first; everything else becomes testable.

# REPORT — P5 · meta-mira

**date**: 2026-05-16 · **workflows attempted**: W-07, W-08, W-09, W-10, W-14, W-15
**status**: extensive cross-check audit; 2 S1 + 3 S2 + 2 S3 filed

## In-character summary

I treated AXON as a system under test. Cross-checked:

- **REGISTRY.json vs `tools/*.py`** — all PR-28.5 / PR-31.5 / PR-34 /
  PR-34.5 entries present. Clean.
- **AUTO-VERBS in cheatsheet** — `cheatsheet_gen.py` works but truncates
  at 54 chars, cutting mid-word for several entries (F-015).
- **`docgen_verify`** — 3 broken refs in `AXON-DOCS-SCHEMA.md` (F-018).
- **`call_graph`** — clean post-PR-28 (acyclic, longest 5 < 10). Verified.
- **`budget_lint`** — counts 115 programs / 0 violations, but it doesn't
  catch the per-mode-cap vs blanket-cap contradiction (F-011/F-019).
- **Alias-stub forwarding** — all 14 alias stubs (PR-26: 5, PR-27: 10
  minus 1 partner, PR-28: 4 file + 5 absorbed) have correct EXEC targets
  *as filenames*. The headers inside those targets are wrong (F-001).
- **Absorbed-alias router contract** — stubs forward `--mode=X` flag but
  `code-dev-review.md` consumes `W:code-dev-review-sub` not CLI args
  (F-009). Also `--mode=diff` has no router branch at all (F-010).

The **F-001 finding is the linchpin**: all the other "the rename works"
verifications upstream were measured at the filename level only.

## Top findings I filed

| id     | sev | summary                                                  |
|--------|-----|----------------------------------------------------------|
| F-001  | S1  | 24 renamed files retain old `# PROGRAM:` header           |
| F-003  | S1  | preflight stub forward path causes WARN spam              |
| F-009  | S2  | absorbed-alias `--mode=X` flag silently dropped by router |
| F-010  | S2  | `review --mode=diff` has no router branch                 |
| F-015  | S3  | cheatsheet truncation cuts descriptions mid-word          |
| F-018  | S3  | AXON-DOCS-SCHEMA.md has 3 dead links                      |

## Top-3 proposed edits

1. **F-001 sweep** — 24-file header sed. Cheapest fix, biggest unblock.
2. **F-009 fix** — 5 alias stubs add `STORE(W:code-dev-review-sub, "X")`
   before `EXEC(code-dev-review)`. Replaces the silently-dropped flag.
3. **F-010 fix** — 3-line `IF sub ≡ "diff"` branch in `code-dev-review.md`.

## Verdict

The W4 verification suite is *strong on tooling* (lint_paths, budget_lint,
call_graph, scan_pre_push, docgen_verify) but **none of these tools verifies
that the `# PROGRAM:` header inside a file matches its filename**. That's
the gap that let F-001 ship. A 10-line test in `test_programs_md.py` would
have caught it — but I won't propose adding that test, because the rule says
improve-only and the existing audit set is already adequate for the manual
fix.

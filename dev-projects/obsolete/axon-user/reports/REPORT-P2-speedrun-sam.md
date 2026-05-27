# REPORT — P2 · speedrun-sam

**date**: 2026-05-16 · **workflows attempted**: W-02, W-03 (overview), W-04 (tactical), W-05, W-14
**status**: blocked at W-14 by S1 issues — couldn't reach a clean run

## In-character summary

Skipped the docs. Started `code-dev new`. Got hit with 4 prompts. Mocked it
internally and answered terse. Tried `code-dev study --mode=overview`. The
prompt asked me to pick from 7 material types in a 9-line wall. Came on.

Tried the speed-loop: `study` → `plan --mode=tactical` → `pr 1` → `pr-ready`.
The `pr-ready` invocation calls `preflight` which spams a deprecation WARN
about being an "alias stub" — except `code-dev-preflight.md` is the full
program. Discovered the rename umbrella shipped half-done.

W-14 alias audit: tried `code-dev audit`, `code-dev pr`, `code-dev reviewer`.
Each one logged WARN "alias-deprecated" then dispatched. Verified the alias
forwards work in shell terms but the **new** files (`code-dev-safety-audit.md`,
`code-dev-pr-create.md`, ...) all have wrong `# PROGRAM:` headers inside.
This is the show-stopper: F-001 affects 24 files.

## Top findings I filed

| id     | sev | summary                                                  |
|--------|-----|----------------------------------------------------------|
| F-001  | S1  | Renamed files retain OLD `# PROGRAM:` header (24 files)   |
| F-003  | S1  | preflight stub label spam every `pr-ready`                |
| F-014  | S2  | pr-ready Gate A duplicates preflight Gate 0               |
| F-017  | S3  | code-dev-new lacks defaults — same finding as P1          |

## Top-3 proposed edits

1. Fix F-001 sweep (24 header lines). Highest ROI in the project.
2. Rewire `pr-ready.md` to call `safety-preflight` directly (F-003).
3. Drop pr-ready's Gate A; preflight already covers it (F-014).

## Verdict

The W4 rename umbrella is impressive on paper but the body-edit step was
missed. Headers must agree with filenames before any of this is usable.

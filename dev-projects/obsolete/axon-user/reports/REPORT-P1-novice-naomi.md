# REPORT — P1 · novice-naomi

**date**: 2026-05-16 · **workflows attempted**: W-01, W-02, W-11, W-15 · **turns spent**: 11
**status**: 2 workflows passed (W-02, W-11), 2 with friction (W-01, W-15)

## In-character summary

I'm Naomi, first day. I read `startup.md`. The two-audience split (FOR THE
AGENT / FOR THE USER) confused me for two turns — am I Claude Code? am I the
user? Once I followed the agent steps in order, I got to the menu. The
identity gate told me "the execution layer is not declared", which felt
evasive but I moved on.

`code-dev new` asked me four things in a row: slug, name, codebase, first
phase. I didn't know what "slug" meant on first read. The "first phase"
prompt offered examples like `1-design` but didn't default to one when I
pressed Enter.

The `lifecycle-tour` was the best part — it explained `new → status → next →
review → preflight` in a clear sequence. I felt oriented after it.

The cheatsheet, when I looked at it, had a few descriptions cut mid-word
("alias for code-dev-state-status; removed nex"). I had to open the source
program to learn what was hidden.

## Top findings I filed

| id     | sev | summary                                       |
|--------|-----|-----------------------------------------------|
| F-016  | S2  | startup.md audience split is ambiguous         |
| F-017  | S3  | code-dev-new lacks defaults for first-phase    |
| F-015  | S3  | cheatsheet truncates important deprecation info|

## Top-3 proposed edits

1. Prepend a one-line "Reader gate" to `startup.md`.
2. Default `first-phase` to `1-design` in `code-dev-new.md`.
3. Widen cheatsheet truncation to ~76 chars with word-boundary cut.

## Runs

I jotted my runs into shared transcripts under `runs/R-P1-W*`. They cover
the boot, the scaffold, the tour, and the cheatsheet read.

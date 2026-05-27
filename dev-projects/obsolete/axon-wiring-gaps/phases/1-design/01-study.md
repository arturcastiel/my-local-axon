# Study — 1-design

## 1. Goal

Close memory-key wiring gaps AND broken-program defects in AXON's
workspace programs.

A wiring gap is a `W:`/`L:`/`E:` memory key that is READ by one or more
programs but never WRITTEN by any program in the workspace. A broken
program is any workspace program/tool whose dispatch references the
wrong path, wrong key, wrong arg shape, or wrong invariant — same root
cause (incomplete wiring) but observed at a different layer than the
key-read/key-write topology.

In both cases the user discovers the defect only when downstream output
is wrong, missing, or fails opaquely.

This project does **three** things:

1. **Fix the known gap: `W:code-dev-codebase`**
   Five readers (`code-dev-pr-drift`, `code-dev-pr-sync`,
   `code-dev-pr-export`, `code-dev-pr-suggest-reviewer`,
   `code-dev-review-coverage`) expect this key to hold the active
   project's codebase path. The canonical value lives in
   `_meta.md → codebase:` but is never hoisted into `W:`. Fix: have
   `code-dev-load` (and `code-dev-resume`) hoist `_meta.codebase →
   W:code-dev-codebase` on project load.

2. **Audit pass: find similar memory-key wiring gaps**
   Scan ALL workspace programs for the same anti-pattern:
   "RETRIEVE(W:X) used by ≥1 program, STORE(W:X, ...) by 0 programs".
   Produce a wiring-gap registry (one row per gap), classify by severity
   (silent vs loud failure mode), and decide per-gap whether to:
   - wire upstream (add a STORE in the right loader),
   - delete the reader (key is obsolete),
   - or guard the reader (RETRIEVE → ∅ → FAIL loudly).

3. **Zero out broken programs**  ← target = 0
   Inventory every workspace program / tool that fails any of:
   - dispatch references a path that doesn't exist for the project layout
     (e.g. `{proj-dir}/03-prs/` when specs live at
     `{proj-dir}/phases/{phase}/03-prs/` in v4)
   - dispatch passes a name/value that no upstream sets
   - tool implementation crashes / truncates / mis-parses on real inputs
     (e.g. spec parser truncating at unbalanced parens)
   - reader/dispatch contract differs from the registered tool's
     actual --help signature

   For each broken program: catalogue it with one row in the registry,
   then fix or remove until the count is **zero**. Track count over
   time so regression is visible.

## 2. Codebase

`/mnt/c/projects/axon` — but **only** edits to `workspace/programs/*.md`
are in scope. `axon/` (kernel + tools) is locked by Core Rule 9 and out
of scope for this project. If a fix requires an `axon/` change, it spawns
a separate dev-mode project.

## 3. Scope fence

In scope:
- `workspace/programs/*.md` (source programs)
- `workspace/programs/compiled/*.cmp.md` (regenerated after source fix)
- a new audit tool/script may land under `workspace/tools/` if needed
- new entries in `workspace/programs/_audit/` or similar (TBD)

Out of scope:
- `axon/` writes (kernel + core tools)
- `my-axon/` (user data) — only THIS project's files under
  `my-axon/dev-projects/axon-wiring-gaps/` get written
- W:active-phase template-substitution leak (separate project)
- Performance / refactoring / unrelated cleanups

## 4. Initial finding — the seed grep

The grep that triggered this project:

```
$ grep -rn "W:code-dev-codebase" workspace/programs/ \
      | grep -v compiled/
workspace/programs/code-dev-pr-drift.md:36:codebase  ← "{W:code-dev-codebase}"
workspace/programs/code-dev-pr-sync.md:36:codebase  ← "{W:code-dev-codebase}"
workspace/programs/code-dev-pr-export.md:36:codebase  ← "{W:code-dev-codebase}"
workspace/programs/code-dev-pr-suggest-reviewer.md:36:codebase  ← "{W:code-dev-codebase}"
workspace/programs/code-dev-review-coverage.md:36:codebase  ← "{W:code-dev-codebase}"
```

Then:

```
$ grep -rn "STORE(W:code-dev-codebase" workspace/programs/
(no matches)
```

5 readers · 0 writers. The audit step must mechanise this same query
across all `W:` and `L:` keys mentioned anywhere in workspace/programs/.

## 5. Audit step — proposed shape

A registry-producing scan, runnable as a one-shot or a cron job:

- Walk `workspace/programs/*.md`.
- Extract every `RETRIEVE(W:X)` / `RETRIEVE(L:X)` (reads).
- Extract every `STORE(W:X, …)` / `STORE(L:X, …)` (writes).
  Also count `kv-store set` and `python3 axon.py memory set` patterns
  that fire from programs (some programs shell out instead of using
  STORE directly).
- Join → per-key rows: `{ key, readers[], writers[] }`.
- Flag rows where `writers == []` AND `readers != []` → wiring gap.
- Also flag rows where `readers == []` AND `writers != []` → orphaned
  write (less critical, but cleanup signal).
- Output: a markdown registry at `phases/1-design/_audit-keys.md` plus
  a JSON summary at `shadow/audit-keys.json` for tooling.

## 5a. Findings registry (live — append as discovered)

These are the concrete defects surfaced so far. Each becomes a row in
the audit registry produced by Goal 2, and a candidate fix for Goal 3.

| # | Class            | Where                                         | Defect                                                             | Severity                          |
|---|------------------|-----------------------------------------------|--------------------------------------------------------------------|-----------------------------------|
| 1 | wiring gap (W:)  | workspace/programs/code-dev-*.md (5 readers)  | W:code-dev-codebase has 5 readers, 0 writers                       | silent ∅ → opaque failure         |
| 2 | broken program   | workspace/programs/code-dev-pr-drift.md:36    | dispatch reads spec at {proj-dir}/03-prs/pr-N.md;  v4 layout has it at {proj-dir}/phases/{phase}/03-prs/pr-N.md | silent — root 03-prs/ is empty → tool runs with no spec, returns nothing useful |
| 3 | broken tool      | tools/pr_drift.py (spec parser)               | acceptance-criterion extractor truncates at unbalanced parens (observed: ``pytest` exits 0 (all PR-1`` and ``read_grdecl(with_include/main``) | loud — emits malformed unmet items, misleads user |

Add new findings here as encountered. Each row = one fix candidate
for Goal 3's "zero" target.

## 6. Success criteria (audit-ready, not plan-ready)

- This 01-study.md captures the goal clearly enough that a future agent
  (or future me) can pick it up and plan from it without re-discovering
  the seed grep.
- The 04-log.md SESSION START anchor is present so `code-dev resume`
  works.
- `_dont-do.md` is seeded with the scope-fence prohibitions.
- `code-dev audit` (the project-level integrity check) would pass —
  all v4 schema files exist, no syntactic gaps.
- Findings registry (§5a) has at least the three defects surfaced
  during the session that created this project; future sessions append.
- No plan, no PR specs, no code changes yet.

## 7. Open questions (resolve before plan)

- Q1: Should the audit also cover `E:` (episodic) keys? (probably not —
  E: is append-only by design, gap semantics differ.)
- Q2: Should the audit registry live IN this project (per-phase) or as
  a permanent file under `workspace/tools/audit/`? Permanent is more
  useful long-term but expands scope.
- Q3: Acceptable failure mode for the fix to `code-dev-load`: silent
  hoist vs. surfaced "loaded codebase: /path" line in output. The
  latter is more honest, the former is quieter.

## 8. Next action

Wait for the user. Per their direction: "we can go back to the current
project and continue with the options" — the next move belongs to PR-4
on cpg-to-unstructure, not to this project. This project sits idle until
a future `code-dev load axon-wiring-gaps` + `code-dev plan`.

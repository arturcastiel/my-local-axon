# CD·C2·P2 — refined workflows (post-deep-dive)

> Workflows that become possible (or much cheaper) once cycle-2 internals are understood. Builds on `cd-c1-p2-workflows.md`.

## W1 — PR-stack workflow (uses `_pr-links.md`)
**Need:** today PRs are siblings; `_pr-links.md` records deps but no commands consume it.

**Pipeline:**
```
code-dev pr-stack new "feature-x"     ← declare stack root
code-dev pr 1                          ← creates PR-001 in stack
code-dev pr-link 2 --depends-on 1
code-dev pr 2
code-dev pr-stack restack             ← rebase children onto parent
                                        (emits restack script for HUMAN)
code-dev pr-stack push                ← per-PR push command, in topological order
```

**New programs needed:** `pr-stack-new`, `pr-stack-restack`, `pr-stack-push`.
**Closes:** G-CD-A3.

## W2 — reviewer-bot loop
**Need:** today, each reviewer round = manual `pr-review` + `pr-respond`. Loop converges slowly.

**Pipeline:**
```
code-dev reviewer-bot start PR-003
  loop:
    code-dev pr-review PR-003 --reviewer bot
    state ← read reviewer-state
    open ← state.filter(status=open AND pr=PR-003)
    if open ≡ ∅ → break (clean)
    code-dev pr-respond PR-003 --auto
    HUMAN edits to address
    confirmation gate
```
**Closes:** G-CD-E1.

## W3 — library-dev → code-dev handoff
**Need:** library-dev produces structured findings; code-dev needs PR drafts.

**Pipeline:**
```
library-dev report findings --as code-dev-pr-draft
  → writes /tmp/code-dev-pr-draft.md (files, why, references)
code-dev pr import --from /tmp/code-dev-pr-draft.md
  → creates 03-prs/PR-NEXT.md prefilled
code-dev review PR-NEXT
```
**Closes:** G-CD-F1. **New programs:** `library-dev-export-as-code-dev`, `code-dev-pr-import`.

## W4 — merge → cascade → changelog → audit (one verb)
Today these are 4 chained commands. **New:** `code-dev finalize <pr|phase>` chains all four with one user confirmation. Each sub-step writes to `_actions.log` for undo.

## W5 — auto-test-suggest from diff
**Need:** current `suggest-tests` reads acceptance; gap if acceptance is sparse.

**Pipeline:**
```
code-dev test-from-diff PR-003
  ← reads git diff for branches in scope
  ← extracts: changed function signatures, new branches, new error paths
  ← cross-refs with acceptance "proof:" lines
  → emits test scenario list, ranked by coverage gain
```
**Closes:** G-CD-C5.

## W6 — coverage delta tracking
**New:** `code-dev coverage-delta PR-N`
- Calls `_profile.coverage-tool` (e.g. `coverage.py`, `gcov`).
- Computes delta on changed lines only (diff-cover style).
- Stores result in `phases/<phase>/coverage-PR-N.md`.
- Gate-8 enhancement: pass if delta-coverage ≥ threshold in `_profile.md`.

**Closes:** G-CD-C4.

## W7 — conflict prediction for PR stack
**New:** `code-dev conflict-predict <stack|pr>`
- For each PR in topological order, does a three-way diff against the target branch.
- Reports likely conflicts (file × line range).
- Especially useful before W1's `pr-stack restack`.

**Closes:** G-CD-C1.

## W8 — kernel events bus wiring
Today `_events.log` is a flat file. **New:** code-dev programs `EMIT(<kind>, <detail>)` to the kernel bus AND append to `_events.log`. Handlers (in `workspace/programs/code-dev-event-handlers/`) can react:
- `EMIT(pr-merged)` → trigger `cascade` + `changelog`
- `EMIT(reviewer-objection-resolved)` → recompute preflight stats
- `EMIT(phase-frozen)` → cron-schedule a thaw reminder

**Closes:** G-CD-B1.

## W9 — `code-dev migrate-v4` (legacy projects)
Walk a v1 project, infer phase, write `schema-version: v4` + scaffold missing files. Dry-run by default. **Closes:** G-CD-A1.

## W10 — code-dev `pr-list` aggregator
View across all phases (or filtered):
```
code-dev pr-list             ← all open PRs in active project
code-dev pr-list --phase     ← active phase only
code-dev pr-list --status open|merged|review
```
Reads `02-prs.md` of each phase + per-PR reviewer-state. Renders a single table. **Closes:** G-CD-A2.

## W11 — embedding-augmented shadow
Add light-weight per-file embedding (cached at shadow-write time). Use for:
- `code-dev impact` — find structurally-similar callers/callees
- `code-dev plan` — rank files by query similarity (Sweep-style)
- `code-dev search` — semantic mode in addition to grep

**Closes:** half of G-CD-B (substrate-side); informs G-CD-C2/C3/C6.

## W12 — release workflow
```
code-dev release start v1.2.0
  ← rolls up CHANGELOG entries since last tag
  ← creates `_release/v1.2.0.md` with summary
code-dev release notes
  ← emits draft release notes (markdown + GitHub flavor)
code-dev release tag
  ← emits HUMAN command: `git tag v1.2.0 && git push --tags`
```
**Closes:** G-CD-A4.

## W13 — code-dev metrics enhancements
- Per-program: total runs · avg duration · approx tokens.
- Shadow: hit-rate · miss-rate · stale-rate.
- Reviewer: rounds-per-PR · time-to-resolve.
- Sourced from `_actions.log` + `_events.log` + (new) `_runs.log`.

**Closes:** G-CD-D1/D2/D3.

## W14 — cron jobs for code-dev
- Nightly: `shadow refresh` on every active project.
- Weekly: `metrics` rollup → emit to igap if drift detected.
- Monthly: archive merged phases > 90 days old.

**Closes:** G-CD-B5.

## W15 — typed-prohibition mechanical checks (Gate 3)
Today Gate 3 is manual. Mechanical sub-checks possible for typed entries:
- `[scope] /path` → mechanically check diff doesn't touch path.
- `[pattern] X when Y` → cannot mechanically test, stays manual.
- `[process] never merge without preflight` → mechanically: was preflight last gate before merge?

**Closes:** half of Gate-3 manualness.

→ ranked + scored in `cd-c2-p3-gaps.md`.

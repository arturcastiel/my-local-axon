# CD·C2·P1 — code-dev deep internals

> Cycle 2 — depth on the heaviest programs (pr-review, audit, preflight, shadow, resume, log) and the substrate they sit on. Each section: structure, hidden assumptions, failure modes.

## 1. `code-dev-pr-review` — 9-phase harmonization pipeline
Source: `workspace/programs/code-dev-pr-review.md` (~600 ln compiled).

### Phases (literal)
```
P1  Context load        PR tracking + 04-log + upstream state + file list
P2  Study               shadow every touched + dependency file
P3  Conflict analysis   API drift / superseded work / design decisions
P4  Harmonization plan  numbered steps: file · region · change · verify
P5  Rebase              onto upstream, drop superseded commits   ← describes only; HUMAN runs
P6  Execution           apply harmonization step by step         ← HUMAN edits
P7  Verification        grep sweeps, build, targeted ctest       ← HUMAN runs
P8  Commit              author commits per spec; never auto-push
P9  Document            HARMONIZATION.md + PR-N-github-description.md + PR-N-explain.md
```

### Hidden assumptions
- The pipeline assumes one PR is being harmonized vs **one** upstream baseline. Cross-stack rebasing requires re-entering P1 with new upstream.
- "Drop superseded commits" (P5) is described but agent never runs git; HUMAN must transcribe the listed commits into an interactive rebase.
- `--phase N` lets you resume mid-pipeline — but resumes are not idempotent if P2 (shadow study) already wrote findings for files now modified externally.

### Failure modes
- Shadow stale at entry → P2 silently uses stale findings; gate is `WARN` not `FAIL`.
- HARMONIZATION.md is overwritten on every run; no history retained per round (only `_actions.log` snapshot if write programs hooked).
- No timeout or scope limit on P2 — very large diffs (>30 files) can blow the context window.

### Cycle-2 cycle improvements (deeper than C1)
- D-PR1: per-round HARMONIZATION-vN.md (immutable history)
- D-PR2: P2 file-scope cap (e.g. only files in `pr-spec.files` + 1-hop dep) — opt-out via `--full`
- D-PR3: P5 emits a script (`harmonize.sh`) instead of prose for HUMAN to execute deterministically

## 2. `code-dev-preflight` — 11 gates
Source: `code-dev-preflight.md` (~180 ln, not compiled).

### Gate map
| # | Name           | Type    | Pass criterion |
|---|----------------|---------|----------------|
| 0 | branch-sync    | hard    | `git branch --show-current ≡ meta.branch` |
| 1 | shadow-fresh   | warn    | `stale=0 AND branch-stale=0` |
| 2 | scope          | hard    | changed files ⊆ `_files.md` |
| 3 | dont-do        | manual  | HUMAN reviews prohibitions |
| 4 | self-review    | hard    | acceptance gaps = 0 |
| 5 | review-guide   | warn    | `.github/REVIEW.md` exists |
| 6 | reviewer-pr    | hard    | no open objections on this PR |
| 7 | reviewer-all   | warn    | no open objections in phase |
| 8 | tests          | manual  | scenarios identified; HUMAN runs |
| 9 | cross-repo     | hard*   | impact.md present if siblings in `_profile` |
| 10| linter         | manual  | HUMAN runs declared linter |

`--quick` = gates 0–4 only.

### Findings
- Gate 3 (`dont-do`) is *manual* by design — cannot mechanically test arbitrary prohibitions. **Gap:** typed prohibitions (`[scope]`, `[pattern]`, `[process]`) could enable mechanical sub-checks for `[scope]` at least (forbidden paths).
- Gate 6 vs Gate 7 split is good (PR-local vs phase-wide) but reviewer-state grepping a markdown table is brittle — JSON would harden this (G-CD-G1).
- `--gate N` (single gate) is implemented; useful for CI-style invocation.

## 3. `shadow` index internals
Tool: `tools/shadow.py`.

### Hashing
- Primary: `git -C <repo> rev-parse HEAD:<rel-path>` → content hash from git index.
- Fallback: `sha256` of file bytes (when not a repo).
- A finding file records: `source-hash`, `method` (`git` | `sha256`), `git-branch`, `ts`.

### Staleness states
- `fresh`        — recorded-hash matches current-hash on current-branch
- `stale`        — recorded-hash ≠ current-hash on current-branch
- `branch-stale` — entry was recorded on a different branch (hash possibly fine on its own branch)
- `missing`     — source no longer exists

### Hidden assumption
- Per-branch shadow is **not** scoped — all entries share one `shadow/` per project. Switching branches creates a flood of `branch-stale` warnings that may be safely ignored (G-CD-B-shadow-1).

## 4. `code-dev-audit` — final cross-reference
Source: `code-dev-audit.md` (~500 ln compiled).

### Cross-references
- For each PR in `02-prs.md`:
  - is there `03-prs/PR-N.md` (spec)? confidence -1 if absent
  - is there a log entry per acceptance criterion? gap counted
  - are there `_decisions.md` entries that touch this PR? supersession?
  - did `reviewer-state.md` resolve all objections? gap counted
- Produces `05-audit.md` with: `pr-id | spec? | log? | reviews-resolved | drift-score | confidence`

### Gap
- No `_events.log` cross-reference — audit doesn't notice merge/freeze events mid-phase that may invalidate a PR.

## 5. `code-dev-resume` — 10-layer briefing
Source: `code-dev-resume.md` (~140 ln, not compiled).

### Layers read (one I/O each)
1. `_profile.md`
2. `masterplan.md`
3. `04-log.md` → last `SESSION (START|RESUME)` marker + last 5 `##` headings
4. Project `_meta.md`
5. Phase `_meta.md`
6. `_dont-do.md`
7. `_decisions.md`
8. Current PR spec (if `current-pr` set)
9. `reviewer-state.md` (per PR)
10. Shadow stats + git branch

### Hidden assumption
- All 10 layers are read **every** time resume runs — even within the same session, even if nothing changed. **G-CD-RES-cache:** cache the briefing in `W:code-dev-resume-cache` keyed on `(mtime(_meta), mtime(04-log))`.

## 6. `code-dev-log` — drift detection
Source: `code-dev-log.md` (~350 ln compiled).

### Drift logic
- Reads `02-plan.md` planned items + `03-prs/PR-N.md` acceptance.
- Reads new entries the user describes.
- For each entry: classify as `on-plan` / `extension` / `drift` / `unplanned`.
- Appends to `04-log.md` with classification.
- Updates `_meta.last-program` / `last-ts`.

### Hidden assumption
- Classification is LLM-judgment — no mechanical anchor (no diff inspection). Could be tightened by Gate-2-style scope-check on actual git diff at log-write time.

## 7. Action log + undo
The `_actions.log` is a flat append-only file with format:
```
<iso-ts>  <action-id>  <op>  <target>  <snapshot-path>
```
`code-dev-undo` parses the last line, copies snapshot back over `<target>`, then truncates the line.

### Hidden assumption
- Undo is single-step. There is no `code-dev undo N` to step back N. No selective undo by `<op>`.
- No undo "branch" — once you `undo` once and then write, the snapshot is gone.

## 8. Reviewer-state schema (markdown)
```
| reviewer | PR    | round | objection                  | status      | proof |
|----------|-------|-------|----------------------------|-------------|-------|
| alice    | PR-003| 1     | "API breaks plugin X"      | open        | —     |
| alice    | PR-003| 1     | "Missing test for case Y"  | resolved    | "added tests/test_y.cpp::case_y" |
```
Parsed by regex (`| open |`). Brittle. Adding/removing columns will break preflight Gate 6 + reviewer-track.

## Cross-cutting hidden assumptions
- **No concurrency control.** Two `code-dev` invocations on the same project in the same session WILL race on `_actions.log` appends.
- **No project lock.** `code-dev load` doesn't take a lock; switching project mid-program corrupts `W:code-dev-project`.
- **Markdown is the lingua franca.** Every state file is markdown — parseable only by regex/EXTRACT. JSON-ish formats are mooted in `_code-dev-schema-v4.md` only for `_actions.log`.

→ improvements in `cd-c2-p3-gaps.md`; perf in `cd-c3-p1-tokens.md`.

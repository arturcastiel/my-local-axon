# CD·C1·P2 — code-dev workflows (end-to-end narrative)

> What actually runs, in order, from project birth to phase merge. Reconstructed from program sources + `_code-dev-schema-v4.md`.

## The canonical lifecycle (v4)
```
┌─ entry ────────────────────────────────────────────────────────────┐
│ code-dev new <slug>      scaffold project + phases/1-study/        │
│ code-dev load <slug>     set W:code-dev-project                    │
└────────────────────────────────────────────────────────────────────┘
┌─ Phase 1 — study ──────────────────────────────────────────────────┐
│ code-dev study           ingest URLs/PDFs/files (shadow-first)     │
│                          loop until confidence(axon)+confidence(user) ≥ 14 │
│  → 01-study.md                                                     │
└────────────────────────────────────────────────────────────────────┘
┌─ Phase 2 — plan ───────────────────────────────────────────────────┐
│ code-dev plan            semantic codebase scan + plan + PR list   │
│  → 02-plan.md, 02-prs.md                                           │
│ code-dev plan-master     (optional) edit phase DAG, Mermaid render │
│ code-dev phase new       (optional) carve up into sub-phases       │
└────────────────────────────────────────────────────────────────────┘
┌─ Phase 2.5 — phase start ──────────────────────────────────────────┐
│ code-dev phase start     seed prohibitions; SESSION START marker;  │
│                          workflow-step ← build                     │
└────────────────────────────────────────────────────────────────────┘
┌─ Phase 3 — PR specs ───────────────────────────────────────────────┐
│ code-dev pr N            per-PR spec: files, changes, why,         │
│                          acceptance (with proof: lines)            │
│  → 03-prs/PR-00N.md                                                │
│ code-dev explain N       (optional) deep-dive annotation           │
│  → 03-prs/PR-00N-explain.md                                        │
└────────────────────────────────────────────────────────────────────┘
┌─ Phase 3.5 — HUMAN implements code in codebase ────────────────────┐
└────────────────────────────────────────────────────────────────────┘
┌─ Phase 4 — log + review ───────────────────────────────────────────┐
│ code-dev log             append impl log; AXON detects plan drift  │
│  → 04-log.md                                                       │
│ code-dev decision        ADR if scope changed                      │
│ code-dev dont-do         add/promote prohibitions                  │
│ code-dev review          scope-check + self-review + suggest-tests │
│ code-dev diff PR         spec vs git × acceptance vs diff × dont-do│
│ code-dev pr-respond N    draft response to reviewer round          │
│   → reviews/round-N-response.md                                    │
│ code-dev pr-update-spec  mid-flight spec edit if scope creep       │
└────────────────────────────────────────────────────────────────────┘
┌─ Phase 4.5 — pre-push gates ───────────────────────────────────────┐
│ code-dev preflight       11 gates: branch-sync, shadow-fresh,      │
│                          scope, dont-do, self-review, review-guide,│
│                          reviewer-state, linter, cross-repo, tests │
│ code-dev pr-ready        wrap preflight + emit push command        │
│ code-dev pr-github       draft GitHub body                         │
│                                                                    │
│           ──>  HUMAN runs git push  <──                            │
└────────────────────────────────────────────────────────────────────┘
┌─ Phase 5 — merge + propagate ──────────────────────────────────────┐
│ code-dev merge           mark PR/phase merged; archive snapshots   │
│ code-dev cascade         refresh downstream phases per masterplan  │
│ code-dev changelog       draft CHANGELOG.md entry                  │
│ code-dev audit           final cross-reference; → 05-audit.md      │
│ code-dev handoff         single-file handoff briefing              │
└────────────────────────────────────────────────────────────────────┘
```

## Resume / recovery flow
```
session compaction or new chat
  ↓
code-dev load <slug>          (or auto-resumed from W:code-dev-project)
  ↓
code-dev resume               10-layer briefing
  ↓ reads: _profile, masterplan, 04-log (last marker), proj+phase _meta,
  ↓        _dont-do, _decisions, current PR spec, reviewer-state, shadow stats,
  ↓        git branch
  ↓
emit fixed briefing → "WHERE YOU ARE / WHAT YOU WERE BUILDING /
                       REVIEWER STATE / SHADOW HEALTH / IMMEDIATE NEXT ACTION"
  ↓
append SESSION RESUME marker to 04-log.md
```

## Reviewer-state lifecycle
```
pr-review  →  appends objections to reviewer-state.md
              {reviewer | PR | round | objection | status: open | proof-required}
              workflow-step ← review

pr-respond →  drafts response → reviews/round-N-response.md
              flips matching rows: open → resolved (with proof) | re-implementing
              workflow-step ← re-implementing (if any re-implement)

preflight  →  Gate 6 reads reviewer-state.md
              fails if ANY row.status ≡ open
              warns if any row.status ≡ re-implementing

merge      →  workflow-step ← merged (clears any pending objection state at phase level)
undo       →  snapshot-rewind to a prior reviewer-state.md
```

## Cascade after merge
1. `code-dev merge --phase` flags `status: merged` in phase `_meta.md`.
2. Snapshots auto-archived to `<project>/archive/snapshots/<phase>-<date>/`.
3. `code-dev cascade` reads masterplan.md (or default linear order):
   - identifies downstream phases that depended on the merged one
   - flags them for refresh (workflow-step: refresh-needed)
   - emits promotion-candidate list
4. User picks: `code-dev phase start <next>` OR defer.
5. `code-dev changelog` drafts CHANGELOG entry, appended to `<codebase>/CHANGELOG.md`.

## Shadow refresh loop
```
session start
  ↓
code-dev shadow stats   → fresh:F  stale:S  branch-stale:B
  ↓
if S+B > 0 and program is read-heavy (study/plan/pr/explain/audit)
  ↓
code-dev shadow refresh
  → re-hash each entry; if mismatch, re-read source, write new findings
  ↓
proceed with read-heavy program; downstream reads are HITs
```

## Project-tag/undo flow
```
code-dev tag "before-refactor"     → snapshot
... mutate state ...
code-dev tag rewind "before-refactor"  → restore
   (alternatively, code-dev undo to step back single _actions.log entry)
```

## Cross-system handoffs (current)
- code-dev → workspace-backup: writes go under `my-axon/`, auto-pushed on boot.
- code-dev → events bus: **NOT WIRED**. `_events.log` is a flat file; cycle-2/3 backlog.
- code-dev → library-dev: **NOT WIRED**. Bridges discussed in cycle-3 workflows.

## What this surface is good at
- v4 schema gives near-complete coverage of single-track project work (one project, one phase active).
- Shadow indexing removes the dominant token cost of repeat reads.
- Pre-push gates (11) are conservative enough to catch most drift before push.
- Resume protocol is robust: 10 layers + marker writes mean compaction recovery is reliable.

## Where the canonical flow has friction
- Phase-2 plan and Phase-3 PR-spec authoring still expect a human to keep the codebase in mind across many PRs.
- No PR-stack support: PRs are siblings, not a stack — manual rebase if order matters.
- Reviewer loop is sequential and manual (no bot loop; each round = explicit invocation).
- Merge → cascade → changelog → audit is a chain of 4 commands; could be one.

Continued: → `cd-c1-p3-gaps.md`, → `cd-c2-p2-workflows.md`.

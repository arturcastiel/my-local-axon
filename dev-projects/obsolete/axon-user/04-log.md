# axon-user — run journal

Chronological record of persona runs. One entry per (persona, workflow) attempt.

## Format

```
### YYYY-MM-DD HH:MM — P{N}-{name} × W-{NN}
- result: pass | fail | abandoned
- turns:  N
- findings opened: F-001, F-002
- notes: ...
```

---

### 2026-05-16 — project bootstrapped
- _meta + 5 personas + workflow matrix written
- next: schedule first run = P1-novice-naomi × W-01

### 2026-05-16 — 5 persona-driver simulation runs complete
- 5 sub-agents dispatched in parallel (P1..P5)
- workflows covered: W-01 W-02 W-03 W-04 W-05 W-06 W-07 W-09 W-10 W-11 W-12 W-13 W-14 W-15
- findings filed: 19 unique (8 S1 / 8 S2 / 3 S3)
- dominant finding: F-001 (24 PR-26/27/28 renamed files retain old `# PROGRAM:` header)
- artifacts: reports/REPORT-P{1..5}*.md, findings/F-{001..019}*.md,
  findings/INDEX.md, 01-study.md, 02-brainstorm.md, 03-plan.md
- next: HUMAN reviews 03-plan.md → schedule U-1 sweep first

### 2026-05-16 — plan v2 (full code-dev-plan deliverable set)
- user critique: first 03-plan.md (~90 lines) didn't match what `code-dev plan` produces
- root cause: process gap — synthesized "plan" as a table, not as the full deliverable set
- product gap surfaced: `code-dev plan` has no offline dry-render mode
- delivered: 03-plan.md (full), 03-prs/u-1..u-9 + u-v1, 03-prs/DAG.md, 03-prs/DAG.json,
  03-prs/INDEX.md
- 10 PRs, critical path U-1→U-3→U-5→U-6→U-V1 (5 hops)

### 2026-05-16 — plan v3 (planning-workflow upgrade appended)
- user feedback: "fluxogram is bad; need multiple plan modes that generate different
  artifacts; roadmap → phase descriptions → PRs of each phase; keep consistency,
  harmony, workflow; code-dev is main tool and must be perfect"
- studied current `code-dev plan` — confirmed modes are format-only (stdout banner),
  not artifact-level. No per-phase doc; no first-class roadmap; no ADR sidecar.
- delivered: 03-plan-v3.md, 03-prs/u-10..u-16 (7 new PRs), 03-prs/DAG-v3.md,
  03-prs/DAG-v3.json, 03-prs/INDEX.md (updated), 03-prs/u-v1.md (CHANGELOG widened)
- 18 PRs total (v2 retained verbatim + U.E wave appended)
- critical path now U-1→U-10→U-11→U-12→U-14→U-V1 (6 hops)
- new tiers introduced: 02-roadmap.md (strategic) · 02-phases/phase-*.md (tactical) ·
  03-prs/pr-*.md (operational, with Parent-phase: field) · 03-decisions/adr-*.md (sidecar)
- new templates needed: v4-roadmap.md, v4-phase.md, v4-adr.md (under workspace/templates/)
- schema bumped v4.1 → v4.2 (additive, non-breaking)
- next: HUMAN reviews 03-plan-v3.md → if accepted, U-1 sweep is first execution step

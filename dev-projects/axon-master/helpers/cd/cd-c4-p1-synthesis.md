# CD·C4·P1 — synthesis: what code-dev IS, today

> Cycle 4. Consolidates findings from cycles 1–3 into a single picture of code-dev. Companion to `cd-c4-p3-improvements.md` (top-15 executive backlog) and `cd-c4-p2-workflows.md` (target end-state workflow), `cd-c4-p4-web-findings.md` (prior-art alignment).

## What code-dev is (in one paragraph)
code-dev is an AXON sub-system of 57 markdown programs that drives a *spec-first* code-development lifecycle in a target repo: study → plan → PR specs → review → log → preflight → push → merge → audit. Its substrate is the v4 project schema (per-project + per-phase folders, `_actions.log` undo, `_events.log` typed events, `reviewer-state.md`, PR/cross-project link tables) and a content-addressed source-mirror (`shadow/`). The agent never runs `git push`, builds, or tests; those stay HUMAN. The system is mature, internally consistent, and 17.5% of its programs are compiled.

## Where it sits in the AXON stack
```
   kernel (KERNEL-SLIM.md)
       │
       ├── tools/    ← shadow, clock, calculator, shell, semantic-search, …
       │
   workspace/programs/
       │
       ├── code-dev*.md      (57 programs)  ◄── this study's subject
       ├── library-dev*.md   (parallel system, no bridge yet)
       └── plan*.md          (workspace plan; abstractions overlap)

   my-axon/dev-projects/<slug>/   ← code-dev project store
       ├── _meta.md  _profile.md
       ├── _actions.log  _events.log  _pr-links.md  _links.md  05-branches.md
       ├── 04-log.md  05-audit.md  archive/
       └── phases/<phase>/
           ├── _meta.md  _dont-do.md  _decisions.md  _files.md  _profile.md
           ├── 01-study.md 02-plan.md 02-prs.md
           ├── 03-prs/PR-NNN.md  PR-NNN-explain.md  PR-NNN-github-description.md
           │           PR-NNN-HARMONIZATION.md  reviewer-state.md
           ├── reviews/round-N-response.md  handoff.md  impact.md
           ├── snapshots/  shadow/src/...findings.md
```

## What it does well
- **Lifecycle coverage.** Every step from project birth to phase merge has a program. No major workflow stage is silent.
- **State durability.** v4 markers (SESSION START/RESUME) + `_actions.log` + snapshots make compaction recovery reliable.
- **Token discipline.** Shadow indexing removes the dominant repeat-read cost.
- **Conservative gates.** 11-gate `preflight` catches the common pre-push mistakes.
- **Schema-aware UX.** v1 still works; v4 programs degrade gracefully on v1 projects.
- **HUMAN-only git.** Push, rebase, merge are not executed by the agent — safety contract upheld.

## Where it leaves money on the table

### Substrate gaps
- `_events.log` is a flat file, not wired to the kernel event bus (D-A1 / G-CD-B1).
- `usage` records nothing for code-dev runs; `compile-suggest` is blind (D-A2 / G-CD-B3).
- `igap` doesn't see code-dev's low-confidence moments (D-A3 / G-CD-B2).
- `auto-improve` doesn't benchmark the family (D-A4 / G-CD-B6).

### Missing core commands
- `pr-list` (cross-phase aggregate) — D-B1 / G-CD-A2
- `migrate-v4` (legacy migrator) — D-B2 / G-CD-A1
- `pr-stack` (stacked PRs) — D-E1 / G-CD-A3 / W1
- `finalize` (merge+cascade+changelog+audit one verb) — D-B3 / W4
- `pr-import` (library-dev → code-dev) — D-B4 / W3 / G-CD-F1
- `release` (rollup + tag) — G-CD-A4
- `pr-archive` (housekeeping) — D-B5 / G-CD-A5

### Token-economy losses
- `code-dev-pr-review.cmp.md` has **negative compression** (-1%, ~5,760 tokens). T-A1, T-A3.
- `resume` reads 10 files unconditionally; warm-session cache (T-B2) would halve it.
- `preflight` triggers 3 sub-EXECs; inlining (CW13) would shave hops.
- `reviewer-state.md` is parsed by regex on every read; JSON sidecar (T-B3) is small effort, high payoff.

### Quality / drift gaps
- No conflict prediction across PRs (D-C6 / G-CD-C1).
- No coverage-delta tracking (D-C8 / G-CD-C4).
- No test-from-diff suggester (D-C7 / G-CD-C5).
- Scope-check is line-level; no public-API change detector (D-C9 / G-CD-C6).
- Gate 3 (dont-do) is manual; typed prohibitions enable mechanical sub-checks (D-C4 / W15).

### Multi-agent / orchestration
- No reviewer-bot loop (D-E2 / G-CD-E1).
- No parallel PR mode (D-E3 / G-CD-E2).

### Observability
- `metrics` lacks token/duration/shadow-rate/reviewer-turnaround dimensions (D-D1..D3 / G-CD-D1..D3).
- No Mermaid render of `_pr-links.md` (D-D4 / G-CD-D4).

## What the 4-cycle study confirms
1. **The architecture is sound.** No structural redesign needed; everything is incremental.
2. **The biggest wins are substrate integration**: wire events, record usage, feed igap. These also unlock metrics enrichment.
3. **The biggest *single* item is**: quarantining and re-splitting `code-dev-pr-review`. This alone recovers thousands of tokens per session for the most expensive workflow.
4. **The biggest *category* is caching**: read cache, resume briefing, reviewer JSON. None requires heroics.
5. **The biggest *missing capability* is PR-stack support.** Industry-standard (git-spice, Graphite, Sapling) is well past us here.

## What this study is NOT recommending
- Language plugins (system is intentionally generic).
- Test execution by the agent (CORE RULE).
- Autonomous push (HARD RULE).
- A new schema version (v4 is fine; backlog is additive).
- Full RAG / model-based embeddings out of the box (bm25 is enough to start).

→ end-state workflow: `cd-c4-p2-workflows.md`
→ executive backlog: `cd-c4-p3-improvements.md`
→ external alignment: `cd-c4-p4-web-findings.md`

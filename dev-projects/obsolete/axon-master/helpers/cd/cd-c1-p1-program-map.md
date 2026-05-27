# CD·C1·P1 — code-dev program map (broad survey)

> Focus: every `workspace/programs/code-dev*.md` file. Group by cluster, mark compile state, target schema. 57 programs total · 10 compiled (17.5%).

## Cluster summary

| Cluster | Count | Compiled | Purpose |
|---------|------:|---------:|---------|
| Lifecycle           | 7  | 2  | entry, recovery, state awareness (new, init, load, resume, status, next, tour) |
| Planning            | 5  | 1  | phase graph + ADRs (plan, plan-master, phase-new, phase-start, decision) |
| PR workflow         | 11 | 2  | spec → review → push → merge → propagate |
| Review              | 4  | 0  | scope/self/reviewer-track/explain-reviewer |
| Knowledge & analysis| 7  | 4  | study, shadow, search, explain, impact, tour, diff |
| Integrity           | 10 | 2  | audit, freeze, hold, dont-do, decision, event, log, since, replay, preflight, check-structure |
| Graph / tree        | 6  | 0  | combine, divide, partition, link, scope-check, whatif |
| Meta / UX           | 7  | 1  | help, handoff, undo, tag, metrics, suggest-tests, code-dev (router) |

⭐ = compiled.

## Lifecycle (entry + recovery)
- ⭐ `code-dev.md` — main router/hub; renders dashboard; shadow-gate; routes 57 sub-commands.
- ⭐ `code-dev-init.md` — scaffold v4 project (folder tree, codebase index, semantic-search seed).
- `code-dev-new.md` — interactive scaffold variant; sets `_meta.md`, `phases/1-study/`.
- `code-dev-load.md` — switch active project; reads schema-version; sets `W:code-dev-project`.
- `code-dev-resume.md` — 10-layer briefing after compaction; writes `SESSION RESUME` marker to `04-log.md`. **v4-only** (HALTS on v1).
- `code-dev-status.md` — full dashboard (project, phase, PRs, shadow, reviewer).
- `code-dev-next.md` — 10-moment classifier → suggests ONE next command.
- `code-dev-tour.md` — 8-station interactive tour for new users.

## Planning (DAG + ADRs)
- ⭐ `code-dev-plan.md` — Phase-2 semantic codebase scan → `02-plan.md` + `02-prs.md` (numbered PR list).
- `code-dev-plan-master.md` — project-level masterplan; Mermaid phase-graph render.
- `code-dev-phase-new.md` — scaffold phase folder (9 stub files); register in masterplan.
- `code-dev-phase-start.md` — activate phase: seed prohibitions, `SESSION START` marker, set workflow-step.
- `code-dev-decision.md` — append ADR to `_decisions.md`; snapshot before write; supersession tracking.

## PR workflow (spec → review → push → merge)
- ⭐ `code-dev-pr.md` — Phase-3 per-PR spec: files, changes, why, acceptance + `proof:` lines. Shadow-intensive.
- ⭐ `code-dev-pr-review.md` — **largest program (~600 lines compiled)**: 9-phase pipeline (context-load → study → conflict → harmonize → rebase → execute → verify → commit → document). Writes `HARMONIZATION.md`.
- `code-dev-pr-respond.md` — draft response per reviewer round → `reviews/round-N-response.md`; sets `workflow-step: re-implementing`.
- `code-dev-pr-update-spec.md` — mid-flight spec edit + audit entry.
- `code-dev-pr-ready.md` — pre-push wrapper: branch verify + preflight + emit push command (HUMAN runs).
- `code-dev-pr-link.md` — declare PR-N depends-on / blocks → `_pr-links.md` table.
- `code-dev-pr-github.md` — render GitHub body + suggest reviewers from `_profile.md`.
- `code-dev-merge.md` — mark PR or phase merged; archive snapshots; trigger changelog prompt.
- `code-dev-cascade.md` — post-merge: refresh downstream phases per masterplan; promotion candidates.
- `code-dev-changelog.md` — draft `CHANGELOG.md` entry from phase data.
- `code-dev-test-map.md` — map changed source files → test files via `_profile.test-strategy`. Does NOT execute.

## Review (quality gates)
- `code-dev-review.md` — unified routing: `scope-check` + `self-review` + `suggest-tests`.
- `code-dev-self-review.md` — diff vs acceptance gap report; supports `--check-only` (preflight Gate 5).
- `code-dev-explain-reviewer.md` — pattern analysis across one reviewer's objection history.
- `code-dev-reviewer-track.md` — multi-reviewer dashboard with filters.

## Knowledge & analysis
- ⭐ `code-dev-study.md` — Phase-1 ingest (URLs/PDFs/files/text); shadow-first; iterates until AXON+user confidence ≥7.
- ⭐ `code-dev-shadow.md` — shadow index CLI: `stats|list|stale|refresh|show|scan|clear`.
- ⭐ `code-dev-explain.md` — PR deep-dive annotation → `PR-N-explain.md`.
- `code-dev-search.md` — full-text grep across `04-log.md`, `03-prs/*.md`, `_decisions.md`, `_dont-do.md`, `reviewer-state.md`.
- `code-dev-impact.md` — caller/callee/risk analysis for phase's planned changes; cross-repo if `_profile.cross-repo` set.
- `code-dev-diff.md` — triple diff: spec.files vs git, acceptance vs diff content, `_dont-do` vs diff.

## Integrity & enforcement
- ⭐ `code-dev-audit.md` — Phase-5 cross-reference PR specs ↔ `04-log.md` ↔ `_decisions.md` → `05-audit.md` (gaps/drift/confidence).
- ⭐ `code-dev-log.md` — Phase-4 implementation log; drift-vs-plan detection; appends to `04-log.md` + `_actions.log`.
- `code-dev-check-structure.md` — v4 schema folder audit; `--fix` available.
- `code-dev-freeze.md` / `code-dev-hold.md` — workflow-step: `frozen:reason` / alias pause+release.
- `code-dev-dont-do.md` — prohibitions: `[scope]` / `[pattern]` / `[process]`; add/list/retire/promote/demote.
- `code-dev-event.md` — append typed event to `_events.log` (kind + detail).
- `code-dev-since.md` — delta since last invocation: new commits, log entries, reviewer-state changes, shadow stale-deltas.
- `code-dev-replay.md` — mine project history for recurring lessons/patterns.
- `code-dev-preflight.md` — **11 gates** pre-push: branch-sync, shadow-fresh, scope, dont-do, self-review, review-guide, reviewer-state, linter, cross-repo, tests, summary.

## Graph / tree operations
- `code-dev-combine.md` / `code-dev-divide.md` — phase merge / split with snapshots + undo.
- `code-dev-partition.md` — v4 unified split/merge/undo.
- `code-dev-link.md` — cross-project deps → `_links.md`.
- `code-dev-scope-check.md` — git changed-files vs `_files.md` registry (scope-creep detector).
- `code-dev-whatif.md` — dry-run any code-dev command.

## Meta / UX
- `code-dev-suggest-tests.md` — enumerate test scenarios from acceptance (does NOT generate code).
- `code-dev-metrics.md` — self-observability: PRs/phase, rounds/PR, top prohibitions, ADR turnover.
- `code-dev-help.md` — extract `## HELP` block from a program.
- `code-dev-handoff.md` — single-file briefing for next session/person.
- `code-dev-undo.md` — reverse last `_actions.log` entry (asks confirm).
- `code-dev-tag.md` — user-driven checkpoint: save/rewind by label.

## Coverage observations
- All 57 programs are reachable: routed by `code-dev.md` OR called as sub-EXEC.
- No orphans detected.
- All programs are v4-aware. v1 projects supported via schema-check + graceful degradation (resume HALTS on v1, etc.).
- Sub-EXEC chains: `preflight → scope-check + self-review + suggest-tests`; `review → same 3`; `partition → divide + combine`; `hold → freeze`; `pr-ready → preflight`; `whatif → target`.

## Compilation tier (token weight)
```
code-dev-pr-review   ⭐⭐⭐⭐⭐  ~600 ln  (harmonization pipeline)
code-dev-audit       ⭐⭐⭐⭐    ~500 ln  (full cross-reference)
code-dev             ⭐⭐⭐⭐    ~450 ln  (router + dashboard)
code-dev-plan        ⭐⭐⭐      ~400 ln
code-dev-log         ⭐⭐⭐      ~350 ln
code-dev-pr          ⭐⭐⭐      ~350 ln  (shadow-heavy)
code-dev-study       ⭐⭐⭐      ~300 ln
code-dev-shadow      ⭐⭐⭐      ~300 ln
code-dev-explain     ⭐⭐        ~280 ln
code-dev-init        ⭐          ~100 ln
```

## Cross-links
- → `cd-c1-p1-schema-map.md` for v4 file layout
- → `cd-c1-p1-tools-map.md` for tool calls per program
- → `cd-c1-p2-workflows.md` for end-to-end pipelines

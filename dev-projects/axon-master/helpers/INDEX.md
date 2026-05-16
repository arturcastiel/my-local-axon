# helpers/ — AXON Master study artifacts

Each cycle produces 4 helper files (one per phase). All are inputs to the
final synthesis (`01-study.md`). Naming convention:

  `c{N}-p{M}-{topic}.md`

where N = cycle (1-4), M = phase (1-4).

| Phase | Purpose                                           |
|-------|---------------------------------------------------|
| 1     | Read & map AXON repo (kernel/programs/tools/etc.) |
| 2     | Brainstorm workflows AXON could enable            |
| 3     | Improvement backlog (faster · useful · gaps · tokens) |
| 4     | Web research — libraries, prior art, comparable systems |

## Index

### Cycle 1 (broad survey)
- [c1-p1-kernel-map.md](c1-p1-kernel-map.md) — kernel/core surface, identity, gates, lang ops, boot
- [c1-p1-programs-map.md](c1-p1-programs-map.md) — workspace programs by family + dep graph
- [c1-p1-tools-map.md](c1-p1-tools-map.md) — registry, CLI surface, overlap, orphans
- [c1-p2-workflows.md](c1-p2-workflows.md) — workflow brainstorm
- [c1-p3-improvements.md](c1-p3-improvements.md) — improvement backlog (impact × effort)
- [c1-p4-web-findings.md](c1-p4-web-findings.md) — agent OS / caching / kernel patterns

### Cycle 2 (depth — compiler, scheduler, memory, processes)
- [c2-p1-deep-internals.md](c2-p1-deep-internals.md) — compiler, scheduler, memory, processes
- [c2-p2-workflows.md](c2-p2-workflows.md) — refined workflows from C1 gaps
- [c2-p3-improvements.md](c2-p3-improvements.md) — deeper improvements
- [c2-p4-web-findings.md](c2-p4-web-findings.md) — symbolic-language & DSL prior art

### Cycle 3 (token economy + dispatch)
- [c3-p1-token-hotspots.md](c3-p1-token-hotspots.md) — where tokens leak today
- [c3-p2-workflows.md](c3-p2-workflows.md) — workflows that exploit caching
- [c3-p3-improvements.md](c3-p3-improvements.md) — token-economy backlog
- [c3-p4-web-findings.md](c3-p4-web-findings.md) — caching, compaction, dispatch prior art

### Cycle 4 (synthesis)
- consolidates into ../01-study.md

---

## ROUND 2 — code-dev focused study (cd-*)

Same 4-cycle structure, scoped exclusively to the `code-dev` sub-system.
57 programs · v4 schema · shadow indexing · 11-gate preflight.

### Cycle 1 (broad survey)
- [cd-c1-p1-program-map.md](cd-c1-p1-program-map.md) — 57 programs by cluster, compile state
- [cd-c1-p1-schema-map.md](cd-c1-p1-schema-map.md) — v4 layout, v1 deltas, migration story
- [cd-c1-p1-tools-map.md](cd-c1-p1-tools-map.md) — tools invoked by code-dev (shadow, shell, clock, …)
- [cd-c1-p2-workflows.md](cd-c1-p2-workflows.md) — end-to-end lifecycle narrative
- [cd-c1-p3-gaps.md](cd-c1-p3-gaps.md) — G-CD-A..G ranked backlog (~25 items)
- [cd-c1-p4-web-findings.md](cd-c1-p4-web-findings.md) — stacked-PRs, agent loops, indexing prior art

### Cycle 2 (deep internals)
- [cd-c2-p1-internals.md](cd-c2-p1-internals.md) — pr-review 9 phases, preflight 11 gates, shadow, undo, reviewer-state
- [cd-c2-p2-workflows.md](cd-c2-p2-workflows.md) — W1–W15 refined workflows (pr-stack, reviewer-bot, finalize, …)
- [cd-c2-p3-gaps.md](cd-c2-p3-gaps.md) — D-A..G ranked, top-15
- [cd-c2-p4-web-findings.md](cd-c2-p4-web-findings.md) — git-spice/Graphite/Sapling/Aider/Sweep deep dives

### Cycle 3 (token economy — measured)
- [cd-c3-p1-tokens.md](cd-c3-p1-tokens.md) — measured compression ratios; `code-dev-pr-review.cmp.md` = **-1%** (negative)
- [cd-c3-p2-workflows.md](cd-c3-p2-workflows.md) — CW1–CW15 caching workflows
- [cd-c3-p3-improvements.md](cd-c3-p3-improvements.md) — T-A..F ranked, top-15
- [cd-c3-p4-web-findings.md](cd-c3-p4-web-findings.md) — prompt-caching, bm25, jsonl observability

### Cycle 4 (synthesis)
- [cd-c4-p1-synthesis.md](cd-c4-p1-synthesis.md) — what code-dev IS, today (consolidated)
- [cd-c4-p2-workflows.md](cd-c4-p2-workflows.md) — target end-state workflow + token budget
- [cd-c4-p3-improvements.md](cd-c4-p3-improvements.md) — **EXECUTIVE TOP-15** + 5-wave sequencing
- [cd-c4-p4-web-findings.md](cd-c4-p4-web-findings.md) — top-15 vs prior art (only 1 item is novel)

---

## ROUND 3 — code-dev tools organization (cd-tools-*)

Focused mini-study on consolidating the 57 code-dev programs into a 10-verb umbrella.

- [cd-tools-p1-inventory.md](cd-tools-p1-inventory.md) — overlap matrix, 8 retire candidates, 10 functional clusters
- [cd-tools-p2-umbrella.md](cd-tools-p2-umbrella.md) — proposed verbs (`pr`, `review`, `journal`, `state`, `safety`, `knowledge`, `flow`, `shape`, `lifecycle`, `meta`) + sub-command shape
- [cd-tools-p3-migration.md](cd-tools-p3-migration.md) — 5-wave migration plan, risks, roll-back
- [cd-tools-p4-prior-art.md](cd-tools-p4-prior-art.md) — `gh` / `kubectl` / `docker` / `gt` / `git` validation

---

## ROUND 4 — code-dev workflow study (cd-wf-*)

4-layer deep dive: usage, industrial gaps, naming, synthesis + next-study.

### Layer 1 — usage (what to do, how to use)
- [cd-wf-c1-p1-canonical-flows.md](cd-wf-c1-p1-canonical-flows.md) — 8 named workflows (WF1..WF8), coverage map
- [cd-wf-c1-p2-entry-points.md](cd-wf-c1-p2-entry-points.md) — onboarding, discovery surfaces, cheatsheet proposal
- [cd-wf-c1-p3-cookbook.md](cd-wf-c1-p3-cookbook.md) — 12 copy-paste recipes
- [cd-wf-c1-p4-web-findings.md](cd-wf-c1-p4-web-findings.md) — 13 CLI design patterns

### Layer 2 — industrial gaps (what's missing)
- [cd-wf-c2-p1-industrial-gaps.md](cd-wf-c2-p1-industrial-gaps.md) — 14 gaps scored (G-I1..G-I14)
- [cd-wf-c2-p2-ci-cd-integration.md](cd-wf-c2-p2-ci-cd-integration.md) — `pr sync` + coverage + check parsers
- [cd-wf-c2-p3-team-collab-gaps.md](cd-wf-c2-p3-team-collab-gaps.md) — 8 team gaps (G-T1..G-T8), team-mode toggle
- [cd-wf-c2-p4-web-findings.md](cd-wf-c2-p4-web-findings.md) — Graphite, Aviator, gh, release-please, codecov

### Layer 3 — naming & categories (what's confusing)
- [cd-wf-c3-p1-name-collisions.md](cd-wf-c3-p1-name-collisions.md) — top-15 confusing names, 6 collision classes
- [cd-wf-c3-p2-rename-proposal.md](cd-wf-c3-p2-rename-proposal.md) — full rename table (30+ moves, 12 new)
- [cd-wf-c3-p3-categories.md](cd-wf-c3-p3-categories.md) — 10 umbrella definition cards + boundary tests
- [cd-wf-c3-p4-web-findings.md](cd-wf-c3-p4-web-findings.md) — Heroku/MS/kubectl/gh naming rules

### Layer 4 — synthesis (what next)
- [cd-wf-c4-p1-synthesis.md](cd-wf-c4-p1-synthesis.md) — three-pane view + cross-round backlog
- [cd-wf-c4-p2-roadmap.md](cd-wf-c4-p2-roadmap.md) — 11-release sequenced plan
- [cd-wf-c4-p3-next-study.md](cd-wf-c4-p3-next-study.md) — 14 candidate next-studies (top pick: **Study H — failure-modes**)
- [cd-wf-c4-p4-web-findings.md](cd-wf-c4-p4-web-findings.md) — research seeds for each next-study

---

## ROUND 5 — code-dev study & plan modes (cd-study-*)

4-layer deep dive on `code-dev study` (turning it into 14 modes) and `code-dev plan` (turning it into 10 modes), with 7 named recipes and a folder-based output layout (`study/_index.md`).

### Layer 1 — modes inventory
- [cd-study-c1-p1-current-state.md](cd-study-c1-p1-current-state.md) — what study/plan do today + what they don't
- [cd-study-c1-p2-modes-taxonomy.md](cd-study-c1-p2-modes-taxonomy.md) — 14 study modes with token budgets
- [cd-study-c1-p3-prior-art.md](cd-study-c1-p3-prior-art.md) — Sourcegraph / CodeQL / Semgrep / coverage tools
- [cd-study-c1-p4-mode-composition.md](cd-study-c1-p4-mode-composition.md) — sequential/parallel/recipe composition

### Layer 2 — workflows + gaps
- [cd-study-c2-p1-workflows.md](cd-study-c2-p1-workflows.md) — WF-S1..WF-S10 (onboarding, perf hunt, brownfield, etc.)
- [cd-study-c2-p2-workflow-gaps.md](cd-study-c2-p2-workflow-gaps.md) — 20 study-side gaps (G-S1..G-S20)
- [cd-study-c2-p3-plan-gaps.md](cd-study-c2-p3-plan-gaps.md) — 14 plan-side gaps + 10 plan modes
- [cd-study-c2-p4-integration.md](cd-study-c2-p4-integration.md) — staleness, pr ready, state next, meta board

### Layer 3 — design detail
- [cd-study-c3-p1-plan-modes.md](cd-study-c3-p1-plan-modes.md) — full design of 10 plan modes
- [cd-study-c3-p2-study-modes-detail.md](cd-study-c3-p2-study-modes-detail.md) — per-mode contract + 7 recipes
- [cd-study-c3-p3-implementation.md](cd-study-c3-p3-implementation.md) — 6-wave roadmap (S0..S6)
- [cd-study-c3-p4-web-findings.md](cd-study-c3-p4-web-findings.md) — per-mode external tooling references

### Layer 4 — synthesis + targets
- [cd-study-c4-p1-synthesis.md](cd-study-c4-p1-synthesis.md) — 8 headlines + 20-gap re-ranking
- [cd-study-c4-p2-targets.md](cd-study-c4-p2-targets.md) — definition-of-done per target (T-S0.1..T-S6.5)
- [cd-study-c4-p3-next-study.md](cd-study-c4-p3-next-study.md) — 14 next-study candidates (top: **NS-1 + NS-2 evals + idempotence**)
- [cd-study-c4-p4-web-findings.md](cd-study-c4-p4-web-findings.md) — refs for evaluation, idempotence, plan A/B

## Cross-links
- Final report (round 1): `../01-study.md`
- Backlog (filtered): `../02-prs.md` (after `code-dev plan`)
- **Round 2 executive backlog:** `cd-c4-p3-improvements.md` (top-15 token/quality)
- **Round 3 reorganization plan:** `cd-tools-p3-migration.md` (5 waves)
- **Round 4 unified roadmap:** `cd-wf-c4-p2-roadmap.md` (11 releases)
- **Round 5 study/plan modes targets:** `cd-study-c4-p2-targets.md` (6 waves)
- **Recommended next study:** `cd-study-c4-p3-next-study.md` → NS-1 + NS-2 (evals + idempotence)

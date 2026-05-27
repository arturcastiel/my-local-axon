# 04-log — axon-master implementation log

## 2026-05-16 — Plan DAG: PR-16.5 + seed graph artifacts
- Audit found: plan v5 claimed "DAG acyclic; verified topologically" but emitted no graph
- Added PR-16.5: `tools/plan_dag.py` — extracts `**Depends-on**:` lines from per-PR files, validates acyclicity, emits Mermaid + JSON
- Generated manual seed: `03-prs/DAG.md` (Mermaid `graph LR` + topo table + critical path) and `03-prs/DAG.json`
- Critical path: pr-1 → pr-2 → pr-3 → pr-9 → pr-15 → pr-33 → pr-34 → pr-v4 (8 hops)
- Leaves: 8 PRs with no inbound deps (pr-1, pr-2, pr-4, pr-5, pr-6, pr-7, pr-9.6, pr-13)
- Bottleneck fan-out: pr-1, pr-3, pr-13, pr-4, pr-8
- Total: 49 functional + 4 version PRs = 53
- INDEX.md + 03-plan.md updated to link to DAG

## 2026-05-16 — Plan v5 detailed: per-PR files
- Restructured plan to address "too master, loses context" feedback
- Created `03-prs/` directory with 52 per-PR detail files (51 PRs + INDEX.md)
- Each PR file ~60-100 lines with sections: WHY · Evidence (helper citations) · Design notes · Pitfalls (F-* codes) · Interface sketch · Spec (Files / Acceptance / Rollback / Owner) · Cross-refs
- Every PR cites the helper file(s) justifying it inline (study evidence preserved with each PR)
- Slimmed `03-plan.md` from 485 → ~210 lines: kept envelope, wave tables (now linkable), gates, risk register, governance trace, execution semantics, Post-1.0 queue, plan acceptance
- Wave tables now: W1 (8), W2 (14), W3 (16), W4 (14) — one row per PR with summary + link
- Phase advanced: 2-plan-complete-v5 → 2-plan-complete-v5-detailed
- Local commit only; not pushed (per safety rule)

## 2026-05-16 — Round 2 study: code-dev focused
- 4-cycle deep study of code-dev subsystem completed
- 13 helpers written: cd-c1..cd-c4, p1..p4
- Headline finding: code-dev-pr-review.cmp.md has negative compression (-1%, ~5,760 tokens wasted per invocation)
- Executive top-15 in helpers/cd-c4-p3-improvements.md
- Net-new capabilities deferred (Waves 6-11): pr-stack, reviewer-bot, migrate-v4, pr-import, release, coverage-delta, conflict-predict
- All top-15 items have well-mapped prior art (only D-B4 library-dev bridge is AXON-novel)
- Phase advanced: 1-study-complete → 1-study-complete-r2

## 2026-05-16 — Round 3 study: code-dev tools organization
- 4 helpers written: cd-tools-p1..p4
- Proposed 10-verb umbrella (pr, review, journal, state, safety, knowledge, flow, shape, lifecycle, meta)
- 8 retire candidates identified (combine, divide, hold, since, replay, diff, check-structure, explain-reviewer) — alias-stub for 1 release
- 5-wave migration plan, fully backward-compatible during transition
- Prior art validation: gh/kubectl/docker/gt all use 8-15 verb umbrellas
- Net effect: 57 user-visible verbs → 10, with same capability

## 2026-05-16 — Round 4 study: code-dev workflow (4 layers)
- 16 helpers written: cd-wf-c1..c4 × p1..p4
- L1 usage: 8 named workflows (WF1..WF8), 12 recipes, 13 design patterns
- L2 industrial gaps: 14 scored (top: pr list, meta board, context use)
- L3 naming: top-15 confusing names; 30+ renames + 12 new programs
- L4 synthesis + roadmap (11 releases) + 14 next-study candidates
- Recommended next study: Study H — failure modes / postmortem patterns

## 2026-05-16 — Round 5 study: code-dev study & plan modes (4 layers)
- 16 helpers written: cd-study-c1..c4 × p1..p4
- L1: 14 study modes proposed (overview, subsystem, security, performance, dependencies, tests, api-surface, data-model, dead-code, naming, observability, error-handling, dataflow, history)
- L2: WF-S1..WF-S10 workflows; 20 study-gaps + 14 plan-gaps
- L3: 10 plan modes (execution, risk-first, budgeted, constrained, multi-dev, replay, cost, alignment, exploratory, dry); 7 recipes; 6-wave roadmap (S0..S6)
- L4: synthesis + per-target acceptance criteria (T-S0.1..T-S6.5)
- 01-study.md monolith → study/ folder with _index.md
- Recommended next study: NS-1 + NS-2 (evals + idempotence) joint workstream

## 2026-05-16 — Round 6 study: code-dev gap-closure (4 layers)
- 16 helpers written: cd-gap-c1..c4 × p1..p4
- L1 coverage audit: 54 prior helpers inventoried; 8 shallow/missing topics (U-1..U-8) catalogued
- L2 deep dives: U-1 compiled audit + regression gate; U-2 schema migrator v1→v4→v4.1; U-3 test surface (T1-T8); U-4 failure-mode catalog (8 classes, ~30 modes)
- L3 cross-cutting: U-5 governance precedence; U-6 session model + compaction recovery; U-7 Diátaxis docs (9 AXON-DOCS-*.md target files + cheatsheet); U-8 unified token/cost framework
- L4 consolidated goal tree: 91 normalized goals across 13 areas (G.inf, G.tok, G.umb, G.wf, G.study, G.plan, G.gov, G.sess, G.test, G.doc, G.obs, G.safe, G.team-deferred); priority matrix; wave-1/2/3 candidates; critical path
- Pre-plan readiness checklist: COMPLETE — all 13 areas covered, ~50 P0 goals queued
- Phase advanced: 1-study-complete-r5 → 1-study-complete-r6
- Ready for plan command (no plan generated in this round per user instruction)

## 2026-05-16 — Plan v4 (FINAL) via 4 iterations of study→audit→plan
- 12 iteration helpers + 03-plan.md written
- I1 (draft): VAGUE items picked; 2 new goals added (G.safe.09, G.test.09) → 93 total
- I2 (challenge v1): 5 adversarial issues → 5 fixes; 5 new risks → mitigations; MUST/NICE split (4 MUST)
- I3 (risk/sequencing): per-PR execution risks catalogued; DAG with 11 edges; HUMAN/AGENT split explicit; test-orchestration per-area
- I4 (acceptance + completeness): W3 + W4 detailed; version-bump + changelog discipline; W5+ queued explicitly
- Plan: 34 PRs across W1-W4 + 4 version-bump PRs; DONE = 1.0.0 at end of W4
- W1 MUST = PR-1..4 (T1, gate, migrator, governance schema); NICE = PR-5..7
- All P0 goals scheduled in W1-W3; all top-10 failure modes mitigated by W3
- Plan-level governance trace empty (rules.md empty by design)
- Phase advanced: 1-study-complete-r6 → 2-plan-complete-v4

## 2026-05-16 — Plan v5 (FULL STUDY COVERAGE) via iteration 5
- 3 helpers written: cd-plan-i5-{s-crosswalk, a-audit, p-final}.md
- I5 cross-walked every R2-R6 actionable item against plan v4; found 14 missing items + 11 fold-in opportunities
- Plan v5: 48 functional PRs + 4 version bumps = 52 PRs across W1-W4 (was 34 + 4 in v4)
- NEW PRs added:
  - W2 (+3): PR-9.5 `pr list`, PR-9.6 preflight-summary+next-cached, PR-9.7 `meta context use`
  - W3 (+7): PR-15.5 events-bus wiring, PR-15.6 igap feedback, PR-20.5 caches bundle, PR-20.6 `meta board`, PR-20.7 study-evals (NS-1), PR-20.8 pr-review P1-P9 split, PR-25.5 `next` reads _index.md
  - W4 (+4): PR-28.5 PR-ergonomics suite (pr sync/drift/export/suggest-reviewer + review-coverage), PR-31.5 loop detector+tour lint, PR-32.5 nightly shadow cron, PR-34.5 cheatsheet auto-section
- FOLD-INS to existing PRs: PR-1 (boot smoke+tour lint), PR-3 (study _index skeleton), PR-7 (last-reviewed field), PR-8 (--target/--output/--input), PR-9 (atomic journal/), PR-11 (--rule), PR-14 (5→10 routers), PR-16 (--budget), PR-17 (journal vocab), PR-23 (canonical-flows doc)
- POST-1.0 queue now NAMED EXPLICITLY (was vague): D-E1 pr-stack, D-E2 reviewer-bot, D-B4 pr-import, G-CD-A4 release, D-C8 coverage-delta, D-C6 conflict-predict, G.tok.06 cache-hit-rate, G.wf.05 tutorial, G.wf.06 cookbook, G.inf.06 v5 schema, G.team.*, T-S2-S6, NS-3-14, R3 T5 drop-stubs, CI deep, plan-vs-plan diff, plan→PR materialization
- Phase advanced: 2-plan-complete-v4 → 2-plan-complete-v5
- Coverage statement: every R2-R6 actionable item is now in-plan OR explicitly deferred with reason

## 2026-05-16 — PR detail files grounded in /mnt/c/projects/axon

- All 53 per-PR files in 03-prs/ now carry a "## Codebase grounding" section
- Each grounding lists concrete files (new/modify), real symbol/line refs, REGISTRY.json hits, test fixture paths
- Surveyed substrate: tools/_axon_io.py, log.py, prefs.py, compile-write.py, tokenizer.py, usage.py, shadow.py, events.py, igap.py, dispatch.py, dispatch_stats.py, cron.py, docgen.py; 58 code-dev-*.md sources + 10 *.cmp.md compiled; tests/conftest.py; workspace/templates v4
- Effect: each PR is now execution-ready without consulting helpers/ first; implementer can start with a clear file list
- Phase: 2-plan-complete-v5-detailed

## 2026-05-16 — Consistency gate (PR-0) + folder cleanup

User directive: "ensure consistency, we are losing integrity of code-dev — so other changes are updated first."

Changes:
- **New PR-0** (`03-prs/pr-0.md`) — Consistency gate. Must land before any other PR. Ships `_dag-check.py`, `_schema-check.py`, `_check-all.sh`, `_workflow-audit.md`.
- **_meta.md** — added INVARIANTS section (5 invariants: DAG, schema, code-dev consistency, folder layout, enforcement). Phase corrected to `2-plan-complete-v5-detailed`.
- **DASHBOARD.md → 00-dashboard.md** (NN- convention).
- **02-brainstorm.md** — placeholder explaining the deliberate gap (brainstorm output lives in helpers/*-p2-*.md).
- **helpers/ reorganized** — flat 100+ files moved into `c1/` (6), `c2/` (4), `c3/` (4), `cd/` (85) subdirs. `INDEX.md` + `METHODOLOGY.md` stay at root.
- **Schema backfill** — 13 PRs got `## Interface sketch`; 3 also got `## Pitfalls` (pr-24, pr-33, pr-34). Now all 54 PRs pass `_schema-check.py`.
- **DAG.json + INDEX.md** — pr-0 added as node + wave-0 table entry.
- **03-plan.md** — count updated 53 → 54, W0 reading-order note added.

Verification: `bash 03-prs/_check-all.sh` → exit 0. DAG = 54 nodes ↔ 54 files, schema = 54/54.

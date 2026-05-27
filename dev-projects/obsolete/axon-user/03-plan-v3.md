# 03-plan-v3.md — axon-user plan v3 (planning-workflow upgrade)

**Schema**: plan-v1 · **Status**: ready-for-review · **Mode**: tactical
**Created**: 2026-05-16 · **Iteration**: 3 (supersedes [`03-plan.md`](03-plan.md))
**Source**: v2 plan + deep study of `code-dev plan` workflow
**Detail**: per-PR specs in [`03-prs/`](03-prs/INDEX.md)
**Graph**: [`03-prs/DAG-v3.md`](03-prs/DAG-v3.md) · [`03-prs/DAG-v3.json`](03-prs/DAG-v3.json)
**Iteration log**: §0 below

---

## 0. Iteration log v2 → v3

User feedback after v2 review:

> "i believe a bit of the fluxogram is bad — we need multiple plan modes
> thought and generate more plans — and the plans that generate the
> development roadmap (former master plan) — and then each phase description
> — and after that the PRs of each phase description … keep consistency,
> harmony, workflow. code-dev is main tool and must be perfect."

**What changed v2 → v3:**

| area                | v2                                  | v3                                                                 |
|---------------------|--------------------------------------|--------------------------------------------------------------------|
| plan tiers          | flat: `03-plan.md` + `03-prs/*.md`   | **3-tier**: `02-roadmap.md` → `02-phases/phase-N-*.md` → `03-prs/pr-*.md` (+ `03-decisions/adr-*.md` sidecar) |
| `code-dev plan` modes | format-only (changes wording)      | **artifact-level** — each mode emits a different tier              |
| phase descriptions  | table row inside `03-plan.md`        | dedicated `02-phases/phase-N-<slug>.md` per phase                  |
| roadmap             | absent (implied by phase headers)    | first-class `02-roadmap.md` (multi-phase / multi-release vision)   |
| ADRs                | informal notes in PR detail files    | first-class `03-decisions/adr-NNN-<slug>.md` (decision-mode output) |
| PR count            | 10 (U-1..U-9, U-V1)                  | 18 (v2 PRs + 7 new + bumped V1)                                    |
| critical path       | `U-1 → U-3 → U-5 → U-6 → U-V1` (5)   | `U-1 → U-10 → U-11 → U-12 → U-14 → U-V1` (6)                       |

v2 PRs are **retained verbatim** (errata for W4). v3 **appends** wave U.E
(planning-workflow upgrade) and updates U-V1's CHANGELOG block to seal them
under the same `3.6.1` patch release.

---

## 1. Why this matters — the fluxogram gap

### 1.1 What the user-facing flow looks like today

```
code-dev study     → 01-study.md            (Phase 1: research, single file)
code-dev plan      → 03-plan.md             (Phase 2: ONE flat doc; "waves" are table rows)
code-dev pr        → 03-prs/pr-NNN.md       (Phase 3: per-PR specs)
code-dev impl      → diffs                  (Phase 4: code)
code-dev tag       → tags                   (Phase 5: snapshots)
```

A "phase" / "wave" exists only as a `## WAVE N — title` section inside
`03-plan.md`. There is no per-phase doc, no MUST/NICE-by-phase artifact,
no roadmap above the plan, no ADR slot below it.

### 1.2 What `code-dev plan --mode=X` actually does today

Reading `workspace/programs/code-dev-plan.md`:

- `--mode=strategic` → prints a stdout header `"Wave-level overview, ≤800
  tokens, no per-PR detail"`. **No file output for the strategic layer.**
- `--mode=tactical` (default) → writes `02-plan.md` + `02-prs.md` (flat).
- `--mode=operational` → prints a stdout header but the file output is the
  same as tactical.
- `--mode=decision` → prints `"2–3 candidate plans with trade-offs"` to
  stdout. **No `02-decisions/` artifact.**

**Verdict**: modes only change *banner text* and slightly the prose; the
*artifact hierarchy* is identical across all four modes. The "multiple plan
modes" promised by `--mode` is theatrical at the artifact level.

### 1.3 What the user actually wants (and is correct to want)

```
code-dev plan --mode=strategic       → 02-roadmap.md
                                       (vision, releases, themes; spans
                                        multiple phases / multiple plans)
                                                   │
                                                   ▼
code-dev plan --mode=tactical        → 02-plan.md           (index/envelope)
                                     + 02-phases/
                                         phase-1-<slug>.md  (deep description per phase)
                                         phase-2-<slug>.md
                                         ...
                                                   │
                                                   ▼
code-dev plan --mode=operational     → 03-prs/pr-NNN.md     (atomic PR specs;
   (or code-dev pr after tactical)                          one per file, references
                                                            parent phase)
                                                   │
                                                   ▼ (sidecar, not chained)
code-dev plan --mode=decision        → 03-decisions/adr-NNN-<slug>.md
                                       (durable choices with alternatives + trade-offs)
```

**Three properties this gives us:**

1. **Compositionality** — a roadmap can host multiple plans across time
   (v3.6.1 errata + v3.7.0 features). A plan can host multiple phases.
   A phase can host multiple PRs. Today everything collapses into one file.
2. **Token economy** — a developer reading "what is phase 2 about?" loads
   one phase doc (~150 lines) instead of scrolling through a 250-line plan.
   An agent invoking `code-dev pr` for phase-2 PRs only loads phase-2's doc.
3. **Mode integrity** — `--mode=X` finally means something at the
   artifact level, not just at the stdout level. `decision` mode produces
   ADRs; `strategic` produces a roadmap; `tactical` produces phases;
   `operational` produces PRs.

### 1.4 Consistency with existing AXON conventions

- v4 schema (`workspace/templates/v4-schema.md`) already names the directory
  shape `02-*` and `03-*` — we extend it; we don't break it.
- `code-dev tag` continues to snapshot the entire project dir — works
  unchanged regardless of how many sub-files exist.
- `code-dev study` (Phase 1) is unaffected; produces `01-study.md` as before.
- `code-dev impl` (Phase 4) reads from `03-prs/pr-*.md` — unchanged.
- `code-dev review`, `safety-preflight`, `pr-ready` all consume `03-prs/`
  and are unaffected.

The only programs touched are `code-dev-plan` and (marginally) `code-dev-pr`
+ the v4 schema doc.

---

## 2. Plan envelope (v3)

- **Scope**: v2 errata (10 PRs) + planning-workflow upgrade (7 new PRs) +
  1 retained version bump = **18 PRs** total.
- **DONE**: 3.6.0 → 3.6.1 — patch release because the planning hierarchy
  upgrade is *additive* (no API surface broken; flat plans still parse).
- **Out of scope (explicit)**:
  - Auto-migration of existing flat plans (axon-master `03-plan.md`) to the
    new hierarchy. Migration is a separate manual one-shot in a later plan.
  - `code-dev review` doesn't need to know about phases (yet).
  - Cross-roadmap dependencies (one roadmap depending on another).
- **Constraints**: kernel rules, AGENT contract, operational-safety memory.
  No new files under `tools/` or `axon/`. **Allowed**: new templates under
  `workspace/templates/`; new code-dev-* programs are NOT created — only
  `code-dev-plan.md` and `code-dev-pr.md` are extended.

## 3. Owner convention (unchanged)

AGENT writes diffs + templates + DAG; HUMAN runs `pytest` + `docgen_verify` +
approves push. v2 owner table applies to U-1..U-9; U-10..U-16 follow the same.

## 4. Governance trace

```
loaded:    workspace/safety/rules.md (0 rules)
loaded:    my-axon/dev-projects/axon-user/_meta.md → "improve-only invariant"
loaded:    user-feedback v2→v3 → "fluxogram is bad; multiple plan modes; tier hierarchy"
filtered:  0 rules suppressed
flagged:   1 — improve-only invariant relaxed for U.E by explicit user request
           (rationale: code-dev tool perfection is a stated user goal; the relaxation
            is bounded — no new programs, only edits + templates)
status:    proceed
```

## 5. How to read this plan

- **U-1 still lands first** (root cause for W4 errata).
- **Wave U.E (planning hierarchy) begins after U.A merges** — U-10 onward
  depend on dispatch being correct.
- The wave tables below are navigable; each PR row links to its detail file.
- v3 DAG is at [`03-prs/DAG-v3.md`](03-prs/DAG-v3.md).

---

## WAVE U.A — dispatch errata (3 PRs, unchanged from v2)

| PR  | One-line                                              | Sev | Detail |
|-----|--------------------------------------------------------|-----|--------|
| U-1 | Rename-header sweep — 24 files, line 1 only            | S1  | [`03-prs/u-1.md`](03-prs/u-1.md) |
| U-2 | `tools/session.py list` subcommand                     | S1  | [`03-prs/u-2.md`](03-prs/u-2.md) |
| U-3 | `code-dev-chats.md` switch signature fix               | S1  | [`03-prs/u-3.md`](03-prs/u-3.md) |

## WAVE U.B — half-implemented partner cleanup (2 PRs, unchanged)

| PR  | One-line                                                       | Sev | Detail |
|-----|----------------------------------------------------------------|-----|--------|
| U-4 | Drop `state-restore.md` + alias `state-save → tag` in desc     | S1  | [`03-prs/u-4.md`](03-prs/u-4.md) |
| U-5 | Absorbed-alias stubs `STORE` W:key + `diff` router branch      | S2  | [`03-prs/u-5.md`](03-prs/u-5.md) |

## WAVE U.C — friction trims (4 PRs, unchanged)

| PR  | One-line                                                           | Sev    | Detail |
|-----|--------------------------------------------------------------------|--------|--------|
| U-6 | `pr-ready` drop Gate A + rewire to safety-preflight                | S2     | [`03-prs/u-6.md`](03-prs/u-6.md) |
| U-7 | `plan`/`study` blanket vs per-mode budget reconciliation           | S2     | [`03-prs/u-7.md`](03-prs/u-7.md) |
| U-8 | `pr_drift` + cheatsheet truncation + SCHEMA refs                   | S2/S3  | [`03-prs/u-8.md`](03-prs/u-8.md) |
| U-9 | `startup.md` reader gate + `new` defaults + journal `# when:`      | S2/S3  | [`03-prs/u-9.md`](03-prs/u-9.md) |

---

## WAVE U.E — planning workflow upgrade (7 PRs, **new in v3**)

Make `code-dev plan --mode=X` produce real hierarchical artifacts. Each PR
is small and additive; the wave can ship as a single PR series.

| PR    | One-line                                                              | Tier added         | Detail |
|-------|-----------------------------------------------------------------------|--------------------|--------|
| U-10  | `code-dev plan --mode=strategic` writes `02-roadmap.md` (template + dispatch) | roadmap            | [`03-prs/u-10.md`](03-prs/u-10.md) |
| U-11  | `code-dev plan --mode=tactical` writes `02-phases/phase-N-<slug>.md`  | phase descriptions | [`03-prs/u-11.md`](03-prs/u-11.md) |
| U-12  | `code-dev pr` reads phase docs; PR specs link parent phase            | PR↔phase linking   | [`03-prs/u-12.md`](03-prs/u-12.md) |
| U-13  | `code-dev plan --mode=decision` writes `03-decisions/adr-NNN-<slug>.md` | ADR sidecar        | [`03-prs/u-13.md`](03-prs/u-13.md) |
| U-14  | `tools/docgen_verify.py` enforces tier link discipline                | link integrity     | [`03-prs/u-14.md`](03-prs/u-14.md) |
| U-15  | `workspace/AXON-DOCS-SCHEMA.md` + v4-schema.md document the hierarchy | docs               | [`03-prs/u-15.md`](03-prs/u-15.md) |
| U-16  | `code-dev-plan.md` HELP rewrite — modes documented per tier           | UX                 | [`03-prs/u-16.md`](03-prs/u-16.md) |

### MUST / NICE

- **MUST**: U-10, U-11, U-12, U-14 (the hierarchy + its link gate).
- **NICE**: U-13 (decisions can ship in 3.6.2), U-15, U-16 (docs follow).

### Wave U.E entry gate (HARD — requires U-1 from U.A)

Same gate as U.B/U.C: `tools/call_graph.py --check` clean, no dispatch
silently routes to a stale header.

### Wave U.E exit gate to release

- `code-dev plan --mode=strategic` on a fresh project produces `02-roadmap.md`
  whose `head -5` matches the v4-roadmap template's banner.
- `code-dev plan --mode=tactical` produces `02-plan.md` AND at least one
  `02-phases/phase-*.md` per declared wave.
- `code-dev plan --mode=decision` produces `03-decisions/adr-NNN-<slug>.md`
  with the template's 5-section schema.
- `tools/docgen_verify.py` flags a missing PR→phase or phase→roadmap link.
- `code-dev plan --help` lists each mode with its concrete artifact output.

## WAVE U.D — release (1 PR, scope widened)

| PR    | One-line                                                                      | Detail |
|-------|-------------------------------------------------------------------------------|--------|
| U-V1  | VERSION 3.6.0 → 3.6.1 + CHANGELOG (errata + planning-hierarchy upgrade block) | [`03-prs/u-v1.md`](03-prs/u-v1.md) |

CHANGELOG is updated to add a second sub-section under V3.6.1: *"Planning
workflow upgrade — `code-dev plan` now produces a 3-tier hierarchy."*

---

## 6. Critical path (v3)

```
U-1 → U-10 → U-11 → U-12 → U-14 → U-V1     (6 hops)
```

Rationale:
- U-1 is still the single root.
- U-10 (roadmap artifact) is the first hierarchy tier.
- U-11 depends on U-10 (phases reference their roadmap).
- U-12 depends on U-11 (PRs reference their phase).
- U-14 depends on U-10..U-13 to enforce link integrity.
- U-V1 is the convergence point.

v2's critical path `U-1 → U-3 → U-5 → U-6 → U-V1` is **subsumed** — U-3,
U-5, U-6 are now off-path (parallel to U.E).

## 7. Risk register (v3 additions)

v2 register applies; new rows for U.E:

| risk                                                              | likelihood | impact | mitigation |
|-------------------------------------------------------------------|------------|--------|------------|
| Hierarchy break-back: agent expects flat plan, finds phases       | medium     | low    | Backward-compat read: U-12 falls back to `03-plan.md` table parse if `02-phases/` missing |
| Template drift: roadmap/phase/ADR templates evolve out of sync    | low        | medium | All three templates referenced by a single `v4-schema.md` block (U-15) |
| docgen_verify false-positives on legacy flat plans                | medium     | low    | U-14 only enforces link discipline when `02-phases/` directory exists; legacy projects skipped |
| Mode confusion: user runs `--mode=decision` expecting a plan      | medium     | low    | U-16 HELP rewrite makes the artifact output explicit per mode |
| Phase-doc bloat: each phase becomes a 500-line essay              | medium     | medium | v4-phase template has a hard 250-line guidance + structural sections required |

## 8. Replan trigger

If during U-11 we discover that **`code-dev plan` cannot reliably name
phase slugs without a follow-up QUERY**, escalate: either accept one extra
interactive QUERY per phase (cost: latency), or fall back to numeric-only
phase slugs (`phase-1.md`, `phase-2.md`) and let the user rename. **Stop and
ask** before choosing.

If during U-14 we find that **>20% of existing axon-master PR detail files
fail the new link rule**, do NOT block — make the rule a warning for
projects whose `_meta.md` predates schema v4.2. Promote to error in a later release.

## 9. Acceptance (project level, v3)

Inherits v2 acceptance plus:

- `02-roadmap.md` exists at the project root after `code-dev plan --mode=strategic`.
- `02-phases/` directory exists with ≥1 phase file after
  `code-dev plan --mode=tactical`.
- `03-decisions/` directory exists with ≥1 ADR after `--mode=decision`
  (only required for projects that explicitly opt-in).
- `tools/docgen_verify.py` exits 0 on a freshly-generated v3 project.
- `cat VERSION` prints `3.6.1`.
- `head -10 CHANGELOG.md` shows the v3 block (errata + planning upgrade).
- All 18 PRs present in git log between origin/main pre-axon-user and HEAD.

## 10. Out-of-scope (deferred, named)

- **Auto-migrate axon-master from flat to hierarchical** — its `03-plan.md`
  stays flat for the 3.6.x line; migration happens at 3.7.0 (next minor).
- **Cross-roadmap edges** — `roadmap-A` depends on `roadmap-B`. Not needed
  for v3.6.1; would be added at the same time as multi-project plans.
- **Decision-mode trade-off rendering** — U-13 just creates the ADR file;
  computing "which alternative wins" lives in `code-dev review`'s future
  decision-aware mode.
- **Visual DAG renderer** — `tools/plan_dag.py` already emits Mermaid; we
  do not ship a graphical viewer.

## 11. Why each new PR matters (executive context)

- **U-10** is the first time AXON has a *strategic* artifact. Today nothing
  describes "what 3.6 is *for*" except CHANGELOG; the roadmap fills that gap.
- **U-11** is the load-bearing change: a phase deserves its own document
  because phases are how humans *think* about a plan. Reading a 5-line
  table row is not the same as reading a 100-line phase doc with rationale.
- **U-12** prevents PR specs from drifting away from their phase. The
  parent-link is enforced; PR titles inherit phase scope; PR ordering is
  bounded by phase boundaries.
- **U-13** gives decisions a permanent home. Today, "we chose tactic A
  over tactic B" lives in chat scrollback. ADRs make it durable.
- **U-14** is the linter that holds it all together. Without it, the
  hierarchy decays back into flat plans.
- **U-15** + **U-16** are docs — without them, agents (and the next
  contributor) will not know the hierarchy exists.

## 12. Iteration log

- v1 (compact table, ~90 lines) — superseded
- v2 (full code-dev-plan deliverable set, ~200 lines, 10 PRs) — retained
- **v3** (this file, planning-workflow upgrade, +7 PRs) — current

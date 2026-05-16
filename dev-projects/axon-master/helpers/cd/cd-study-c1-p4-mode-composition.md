# CD·STUDY·C1·P4 — mode composition & workflow integration

> Modes are LEGO bricks. The value comes from how they compose.

## Composition primitives

1. **Sequential.** `overview` → `subsystem(auth)` → `security` → `tests`.
2. **Parallel.** `dependencies` || `dead-code` || `history` (all independent).
3. **Conditional.** If `overview` flags a perf concern, run `performance`.
4. **Iterative.** `dataflow` query iterated with refinement.

## Canonical sequences (named compositions)

### CS1 — "New-repo onboarding"
```
overview → history → dependencies → api-surface → tests
```
Result: full ramp-up package for unfamiliar code.

### CS2 — "Pre-release audit"
```
security → dependencies → tests → dead-code → observability
```
Result: ship-readiness gate.

### CS3 — "Refactor prep"
```
subsystem → naming → dead-code → tests → dataflow
```
Result: confidence package before a big refactor.

### CS4 — "Perf regression hunt"
```
history --since 14d → performance --target=<hot path> → dataflow → tests
```
Result: diagnose what changed.

### CS5 — "Brownfield acquisition"
```
overview → history → dependencies → security → architecture → data-model
```
Result: due-diligence package.

### CS6 — "Library API change review"
```
api-surface --diff --since=v1.0 → tests → dependencies (downstream)
```
Result: semver gate.

### CS7 — "Bug triage"
```
dataflow --from <input> --to <crash> → error-handling → tests
```
Result: localized root cause hypotheses.

### CS8 — "Quarterly health check"
```
overview --diff --since=90d → history → dependencies → tests --diff
```
Result: trends snapshot.

## Integration with `code-dev plan`

After a composition runs, the artifacts feed `plan`:

```
study/overview.md            ─┐
study/security.md             │
study/tests.md                │   →   code-dev flow plan --from study/
study/dead-code.md            │
study/history.md             ─┘
```

`plan` emits `02-prs.md` listing proposed PRs, ranked by:
- severity (security high?)
- effort (dead-code small wins?)
- alignment with stated goals (in `_meta.goals`)

## Integration with `code-dev next`

`code-dev state next` reads `study/_index.md` and, if any mode is *stale* (older than threshold OR codebase changed materially), suggests:

```
SUGGESTED NEXT:
  code-dev knowledge study --mode=overview --diff --since-last
  code-dev knowledge study --mode=tests       # not run yet
```

## Integration with `code-dev pr ready`

For sensitive PRs (touching auth, data layer, deps):
```
pr ready N:
  ✓ scope check
  ✓ self-review
  ✓ tests suggested
  ✗ security study stale (last run 60d ago, touched files: src/auth/*)
  → recommendation: run `code-dev knowledge study --mode=security --target=src/auth`
```

`pr ready` doesn't BLOCK on study staleness by default; it WARNS. Optional `--strict` flag promotes to block.

## Composition language (proposed)

A composition is a markdown file under `workspace/study-recipes/`:

```
# RECIPE: new-repo-onboarding
# desc: full ramp-up package for an unfamiliar codebase
# applies-to: project-init

STEPS:
  1. study --mode=overview
  2. study --mode=history
  3. study --mode=dependencies
  4. study --mode=api-surface
  5. study --mode=tests

ON_FAIL:
  - log entry + halt (HUMAN intervention)
```

`code-dev knowledge study --recipe=new-repo-onboarding` runs the recipe.

## "Suggest next study" logic

Inputs:
- `study/_index.md` (what's been run, when)
- `_meta.codebase` mtime
- `_meta.last-pr` topic
- `_meta.goals`
- `safety/rules` (don't suggest deprecated modes)

Heuristic (markdown-program):
1. If no `overview` exists → suggest `overview` first.
2. If `overview` exists but no `tests` AND PR-N touches tests → suggest `tests`.
3. If PR touches `src/auth` AND last `security` study > 30d → suggest `security`.
4. If `_meta.goals.includes('perf')` AND no `performance` study → suggest `performance`.
5. If user about to release (`flow finalize`) AND no `dependencies` study in last 14d → suggest `dependencies`.

Output: ranked list of mode suggestions with one-line rationale.

## Cross-mode consistency

A single fact (e.g. "auth lives in src/auth/") should appear in ONE place. Modes that need it cite via:

```
> [overview] subsystem-map :: auth → src/auth/  (study/overview.md#auth)
```

This keeps modes DRY without sharing mutable state.

## File-system effect

After a full `new-repo-onboarding` recipe:

```
my-axon/dev-projects/<slug>/study/
├── _index.md              # 1 KB
├── overview.md            # 3-5 KB
├── history.md             # 2-3 KB
├── dependencies.md        # 1-3 KB
├── api-surface.md         # 3-5 KB
├── tests.md               # 2-4 KB
└── subsystems/            # populated on demand
```

Total: 15-25 KB. Comparable to current `01-study.md` for medium codebases, but **modular, refreshable, and grep-able**.

→ workflows that use studies: `cd-study-c2-p1-workflows.md`.

# CD·STUDY·C3·P3 — implementation roadmap

> 6 waves, each independently shippable. Closes the top-10 study gaps + plan-mode gaps from Layer 2.

## Wave S0 — Plumbing (foundation)

| Item | Deliverable |
|------|-------------|
| S0.1 | Create `study/` folder convention in `_meta` schema (v4.1 minor bump) |
| S0.2 | Migrator: rewrite `01-study.md` → `study/overview.md` + redirect file |
| S0.3 | `study/_index.md` auto-maintainer (read-modify-write helper) |
| S0.4 | Journal event vocabulary: `study.<mode>`, `plan.<mode>` |

**Acceptance:** axon-master project migrated automatically; old `01-study.md` becomes a one-line pointer; no breaking changes for callers reading 01-study.md directly (kept as a composed view).

## Wave S1 — Core study modes (top-10 gaps closed)

| Item | Deliverable |
|------|-------------|
| S1.1 | `study --mode=overview` (refactor of today's `study`) |
| S1.2 | `study --mode=subsystem --target=<path>` |
| S1.3 | `study --target=<glob>` (G-S2, G-S19) |
| S1.4 | `study --output engineering|executive|machine` (G-S20) |
| S1.5 | Multi-file output to `study/<mode>.md` (G-S7) |
| S1.6 | `_index.md` auto-update (G-S8) |
| S1.7 | `--budget tokens=N` enforcement (G-S6) |
| S1.8 | `--input <path>` plumbing (G-S4) |
| S1.9 | Staleness flags in `_index.md` (G-S11) |
| S1.10| `flow plan --budget N` (G-S14) |
| S1.11| `flow plan --rule "..."` (G-S13) |
| S1.12| `state next` reads `_index.md` and suggests next mode (G-S9) |

**Acceptance:** all 10 P0 gaps closed; existing workflows continue.

## Wave S2 — Additional study modes

| Item | Deliverable |
|------|-------------|
| S2.1 | `study --mode=security` |
| S2.2 | `study --mode=dependencies` |
| S2.3 | `study --mode=tests` (with optional --input coverage.json) |
| S2.4 | `study --mode=api-surface` |
| S2.5 | `study --mode=performance` |
| S2.6 | `study --mode=history` (with --input git-log) |

**Acceptance:** each mode shipped + tested against axon-master.

## Wave S3 — Plan modes

| Item | Deliverable |
|------|-------------|
| S3.1 | `flow plan --mode=execution` (refactor of current) |
| S3.2 | `flow plan --mode=risk-first` |
| S3.3 | `flow plan --mode=budgeted` |
| S3.4 | `flow plan --mode=constrained` |
| S3.5 | `flow plan --mode=cost` |
| S3.6 | `flow plan --mode=alignment` (reads `_meta.goals`) |
| S3.7 | `flow plan --mode=exploratory` |
| S3.8 | `flow plan --mode=dry` |
| S3.9 | `flow plan --replay` |
| S3.10| `flow plan --multi-dev K` |
| S3.11| `flow plan --epic` (replaces `plan-master`; alias-stub for the old name) |

**Acceptance:** 10 plan modes shipped; existing `plan` continues to work as `--mode=execution`.

## Wave S4 — Recipes

| Item | Deliverable |
|------|-------------|
| S4.1 | `workspace/study-recipes/` directory with 7 recipes |
| S4.2 | `study --recipe=<name>` runner |
| S4.3 | `study --suggest-next` heuristic (G-S9 deeper) |
| S4.4 | `study --diff --since-last` (G-S3) |
| S4.5 | `study --checkpoint` / `--resume` (G-S10) |

**Acceptance:** all 7 recipes runnable; resume after crash works.

## Wave S5 — Niche modes + integrations

| Item | Deliverable |
|------|-------------|
| S5.1 | `study --mode=dead-code` |
| S5.2 | `study --mode=naming` |
| S5.3 | `study --mode=observability` |
| S5.4 | `study --mode=error-handling` |
| S5.5 | `study --mode=data-model` |
| S5.6 | `study --mode=dataflow --from --to` (large) |
| S5.7 | `pr ready` reads study staleness (warn-mode) |
| S5.8 | `pr ready --strict` blocks on staleness |
| S5.9 | `safety preflight` reads `study/security.md` |
| S5.10| `meta board` adds "studies" column |

**Acceptance:** integrations tested across one full PR cycle (WF-S3 end-to-end).

## Wave S6 — Polish

| Item | Deliverable |
|------|-------------|
| S6.1 | `meta cheatsheet study` + `meta cheatsheet plan` |
| S6.2 | `study --diff` semantic (not just text) where feasible |
| S6.3 | Token-usage report per `_index.md` entry |
| S6.4 | Removal of `01-study.md` redirect after 1 release |
| S6.5 | Documentation: `workspace/AXON-DOCS-STUDY.md` |

## Cross-wave acceptance gates

- Every wave passes `axon-audit`.
- Every wave passes the compile-write regression gate (Round-2 T-A3).
- Every wave logs `journal event` for actions.
- Every wave updates `_index.md` correctly.

## Risk register (study-specific)

| Risk | Severity | Mitigation |
|------|---------:|-----------|
| Token overruns on large repos | HIGH | budgets + checkpoint + partial output |
| Stale `_index.md` after manual edits | MED | rebuild command `study reindex` |
| Conflicting plan modes user-specified | LOW | clear precedence: budget > mode |
| Recipe drift (one mode changes shape) | MED | recipe runners check mode-version |
| 01-study.md callers break | MED | redirect file + 1-release deprecation |
| `_meta` schema bump breaks v1 projects | HIGH | migrator MUST ship in S0 |
| Per-mode LLM stochasticity | LOW | freeze temperature; idempotence target 80% |
| dataflow mode is slow / expensive | HIGH | gate behind explicit `--mode=dataflow` only; budget aggressive |

## Effort labels

S0: small
S1: medium (most-impactful)
S2..S5: medium each
S6: small

## Definition of done (full programme)

- All 14 study modes shipped.
- All 10 plan modes shipped.
- 7 recipes shipped.
- `_index.md` and staleness fully integrated.
- Documentation written.
- Old `01-study.md` redirect removed (post 1 release).

→ Layer 4 synthesis & target list: `cd-study-c4-p1-synthesis.md`.

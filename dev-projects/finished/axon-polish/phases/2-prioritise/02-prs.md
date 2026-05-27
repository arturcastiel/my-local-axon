# PR list — 2-prioritise

> Preliminary PR list from `02-plan.md` cluster expansion. Full PR specs land in `phases/3-design/03-prs/*.md` (next phase).
> One row per PR (not per cluster). 12 in-scope clusters → ~30 PRs total (estimated).

## Top-5 cluster PRs (Phase 3 entry candidates)

| PR | Cluster | Title | Size | Risk | Depends on |
|---|---|---|---|---|---|
| PR-1.1 | C-01 | `tools/shell.py` sandbox with allowlist + JSON output | M | high | — |
| PR-1.2 | C-01 | R9 hardening: realpath in `_is_axon_path` + enforce.py + 4 bypass tests | S | low | — |
| PR-1.3 | C-01 | REGISTRY.json shell entry: OPTIONAL/host → ACTIVE/tool + health probe | S | low | PR-1.1 |
| PR-12.1 | C-12 | enforce.py check-source: remove `user:` short-circuit | S | low | — |
| PR-12.2 | C-12 | enforce.py check-arithmetic: implement OR mark advisory | S | low | — |
| PR-12.3 | C-12 | Tests for enforce.py check-source + check-arithmetic | S | low | PR-12.1, PR-12.2 |
| PR-5.1 | C-05 | workflow-run.md: loop step counter + rejection-criteria check | S | medium | — |
| PR-5.2 | C-05 | workflow-run.md: STORE active-phase per step + CHECKPOINT | S | medium | PR-5.1 |
| PR-5.3 | C-05 | Goal-state mutation hook for adaptive workflows | M | medium | PR-5.1 |
| PR-2.1 | C-02 | `tools/fail_render.py` + tests | S | low | — |
| PR-2.2 | C-02 | AXON-LANG shorthand: FAIL(prog, problem, cause, fix) | S | low | PR-2.1 |
| PR-2.3 | C-02 | Migrate 5 most-FAIL-heavy programs (canonical examples) | S | low | PR-2.1, PR-2.2 |
| PR-2.4 | C-02 | Advisory lint rule for bare-string FAIL | S | low | PR-2.2 |
| PR-7.1 | C-07 | context.py: read L:host-model for limit lookup | S | low | — |
| PR-7.2 | C-07 | Session-scoped accumulator reset on boot | S | low | PR-7.1 |
| PR-7.3 | C-07 | Tokenizer estimate alignment (context.py + _axon_lib.py) | S | low | PR-7.1 |

## Remaining 10 clusters (Phase 3-design later)

| Cluster | Title | Est PRs | First-PR size | ADR status |
|---|---|---|---|---|
| C-03 | Deprecation policy scaffold | 3 | M | ADR-003 done |
| C-04 | Mainline composition (PR-111 fix) | 4 | M | needs ADR-004 |
| C-06 | Resume/compaction/G-02 | 6 | M | needs ADR-006 |
| C-08 | Core Rule enforcers (5 missing) | 5 | S | per-rule ADRs |
| C-09 | Duplicated files cleanup | 4 | S | none needed |
| C-14 | Doc-drift / live-count pipeline | 3 | M | D-XC-001 |
| C-15 | Worst error messages | 2 | S | depends on C-02 |

## Routed PRs (out of scope)

| Originally in | Routes to | Owner-project |
|---|---|---|
| C-10 dispatcher wiring | axon-wiring-gaps | wiring-gaps |
| C-11 catalog grooming | axon-cleanup | cleanup |
| C-13 synapse ranker | axon-ranker-v2 | ranker-v2 |

## Phase 3 entry checklist
- [x] Top-5 clusters expanded with PR rows
- [x] PR sizes assigned
- [x] Dependencies graphed
- [x] Routing decisions made (3 clusters out of scope)
- [ ] ADR-004 (mainline composition) — needed before C-04 enters Phase 3
- [ ] ADR-005 (adaptive workflow goal-mutation) — needed before C-05 PR-5.3
- [ ] ADR-006 (resume/compaction contract) — needed before C-06

Total estimated Phase 3 work (in-scope clusters): ~30 PRs, ~3-5 person-weeks at S/M-dominant sizing.

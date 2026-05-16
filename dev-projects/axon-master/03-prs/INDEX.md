# 03-prs/ — per-PR detail files for axon-master plan v5

> Each `pr-N.md` carries the full context a coding agent needs to execute one PR
> without re-reading the 15k-line `helpers/` tree. `03-plan.md` is the wave/gate
> index; this directory is the per-PR substrate.

## File schema (every `pr-*.md` follows)

```
# pr-N — <slug>

**Wave**: W<n> · **Goals**: <G.*/T-*/D-*/NS-*> · **Score**: <I/E> · **Depends-on**: <pr-…>

## Why (problem statement)
2–5 sentences. Paraphrased from study findings.

## Evidence (from studies)
- helper: cd-…-p…-…  → <quoted fact / number>
- …

## Design notes
Concrete approach. Drawn from the helpers (R2-R6) + web-findings.
File layout sketch. Edge cases.

## Pitfalls (from failure-mode catalog)
- F-<class><n> <name> → mitigation in this PR.

## Interface sketch
```text
$ code-dev <verb> …
…
```

## Spec (canonical)
- **Files**:
  - new: …
  - modified: …
- **Acceptance**: numbered list, observable behavior.
- **Rollback**: …
- **Owner**: AGENT writes / HUMAN runs <which commands>.
- **Parallelism**: ⊥ <other PR> · blocks <other PR>.

## Cross-refs
- Master plan: [`../03-plan.md` § PR-N](../03-plan.md)
- Studies: helpers/cd-…
```

## Wave 0 — consistency gate (1 PR, must land first)

| PR | Slug | Score | Goals |
|----|------|------:|-------|
| [pr-0](pr-0.md)   | Consistency gate (DAG check + PR schema check + workflow audit) | — | INVARIANTS in `_meta.md` |

> PR-0 ships `_dag-check.py`, `_schema-check.py`, `_check-all.sh` and a generated `_workflow-audit.md`. Every later PR's Acceptance implicitly requires `bash 03-prs/_check-all.sh` to exit 0.

## Wave 1 — foundation (7 PRs + 1 version bump)

| PR | Slug | Score | Goals |
|----|------|------:|-------|
| [pr-1](pr-1.md)   | T1 structural tests + cross-ref lint + boot smoke + tour lint | 4.0 | G.test.01, G.test.09, G.wf.02 |
| [pr-2](pr-2.md)   | Compile audit + regression gate + static-prefix lint          | 5.0 | G.tok.01-04 (T-A1, T-A3) |
| [pr-3](pr-3.md)   | Schema migrator v1→v4.1 + atomic `_meta.md`                   | 3.5 | G.inf.01-04, G.study.04 |
| [pr-4](pr-4.md)   | Governance schema + precedence doc + plan-reads-rules stub    | 3.0 | G.gov.01-02, G.gov.04 |
| [pr-5](pr-5.md)   | Secret redaction + pre-push scan                              | 3.0 | G.safe.03, G.safe.08 (F-H1, F-A2) |
| [pr-6](pr-6.md)   | One-page cheatsheet                                            | 2.5 | G.doc.10 (F-F1) |
| [pr-7](pr-7.md)   | Failure-mode catalog + postmortem template                    | 3.0 | G.safe.01-02, G.safe.09 |
| pr-v1             | Version bump 0.7.0                                            | —   | — |

## Wave 2 — modes + sessions + governance + ergonomics (13 PRs + 1 bump)

| PR | Slug | Score | Goals |
|----|------|------:|-------|
| [pr-8](pr-8.md)     | Study modes core (+ --target/--output/--input)           | 3.5 | G.study.01/07, T-S1.2-4/8 |
| [pr-9](pr-9.md)     | `_session.md` + auto-checkpoint + atomic state-files     | 3.0 | G.sess.01/03, G.inf.04 (F-A1, F-B2/3, F-C4) |
| [pr-9.5](pr-9.5.md) | `code-dev pr list` aggregator                            | 4.0 | G-I1 / D-B1 |
| [pr-9.6](pr-9.6.md) | `preflight --mode=summary` + `next` reads `_meta.next-action` | 3.0 | T-C1, T-C2 |
| [pr-9.7](pr-9.7.md) | `meta context use <slug>`                                | 3.0 | G-I10 / G-M1 (F-G3) |
| [pr-10](pr-10.md)   | Governance `--strict` (full)                             | 3.0 | G.gov.04, G.gov.05 (F-E2/4) |
| [pr-11](pr-11.md)   | Plan reads rules (full) + governance trace + `--rule`    | 3.0 | G.plan.04-05, T-S1.11 (F-E1) |
| [pr-12](pr-12.md)   | Rename-safety harness                                    | 3.0 | G.umb.04, G.test.07 (F-D2) |
| [pr-13](pr-13.md)   | Usage logging                                            | 4.0 | G.obs.01 / D-A2 |
| [pr-14](pr-14.md)   | Router stubs (full 10-umbrella set)                      | 4.0 | G.umb.01 (R3) |
| [pr-15](pr-15.md)   | Compaction recovery + sess.04 harness                    | 3.5 | G.sess.04 (F-A1, F-C4) |
| [pr-16](pr-16.md)   | Plan modes (4) + `--budget N`                            | 3.0 | G.plan.01-02, T-S1.10 |
| [pr-16.5](pr-16.5.md) | Plan DAG emitter (`tools/plan_dag.py`) + Mermaid + JSON | 3.5 | G.plan.06 (acyclicity machine-check) |
| [pr-17](pr-17.md)   | `study/_index.md` + staleness flags + journal vocabulary | 3.5 | G.study.02-03, T-S0.4 (F-E4) |
| pr-v2               | Version bump 0.8.0                                        | —   | — |

## Wave 3 — observability + perf + integration + docs (15 PRs + 1 bump)

| PR | Slug | Score | Goals |
|----|------|------:|-------|
| [pr-15.5](pr-15.5.md) | Events-bus wiring (`_events.log` ↔ kernel)        | 2.5 | D-A1 |
| [pr-15.6](pr-15.6.md) | `igap` feedback from code-dev low-confidence       | 2.0 | D-A3 |
| [pr-18](pr-18.md)     | Dispatch corpus (seed 30)                          | 3.0 | G.test.02 (F-D1) |
| [pr-19](pr-19.md)     | Dispatch quality metric                            | 3.0 | G.obs.06 (F-D1) |
| [pr-20](pr-20.md)     | Per-program budget blocks                          | 3.0 | G.tok.05 |
| [pr-20.5](pr-20.5.md) | Caches bundle (T-B1/B2/B3/B5)                      | 2.5 | T-B1-5 |
| [pr-20.6](pr-20.6.md) | `meta board` ASCII Kanban                          | 2.5 | G-I8 |
| [pr-20.7](pr-20.7.md) | Study-evals workstream                             | 2.0 | NS-1 |
| [pr-20.8](pr-20.8.md) | Split `code-dev-pr-review` into P1-P9              | 1.25 | T-A2 |
| [pr-21](pr-21.md)     | Token-ceiling + usage aggregator                   | 2.5 | G.tok.08, G.obs.02 |
| [pr-22](pr-22.md)     | `rules audit`                                       | 2.5 | G.gov.03 (F-E3) |
| [pr-23](pr-23.md)     | AXON-DOCS for workflows/study/plan + canonical flows doc | 2.5 | G.doc.01-03, G.wf.01 |
| [pr-24](pr-24.md)     | AXON-DOCS-SCHEMA fill + GOVERNANCE expand           | 2.5 | G.doc.04-05 |
| [pr-25](pr-25.md)     | Idempotence harness                                | 3.0 | G.test.04, NS-2 |
| [pr-25.5](pr-25.5.md) | `state next` ↔ `_index.md` + pending PRs           | 3.0 | T-S1.12 |
| pr-v3                 | Version bump 0.9.0                                  | —   | — |

## Wave 4 — renames + behavioral + PR-ergonomics + docs (13 PRs + 1 bump)

| PR | Slug | Score | Goals |
|----|------|------:|-------|
| [pr-26](pr-26.md)     | Rename wave A (5 low-risk)                          | 2.5 | G.umb.05 partial |
| [pr-27](pr-27.md)     | Rename wave B (10 medium-risk)                       | 2.0 | G.umb.05 partial |
| [pr-28](pr-28.md)     | Rename wave C (10-15 high-risk in core flow)         | 1.5 | G.umb.05 partial |
| [pr-28.5](pr-28.5.md) | PR-ergonomics suite (pr sync/drift/export/suggest-reviewer + review-coverage) | 3.0 | G-I3/5/9/11, G.wf.09-11 |
| [pr-29](pr-29.md)     | Behavioral T3 for 5 critical programs                | 3.5 | G.test.03 |
| [pr-30](pr-30.md)     | Per-mode budgets (full)                              | 2.5 | G.study.05 + plan |
| [pr-31](pr-31.md)     | Context-switch ergonomics (`chats list/show/switch`) | 2.5 | G.sess.05, G.wf.07 partial |
| [pr-31.5](pr-31.5.md) | Recursive loop detector + tour cross-ref lint        | 3.0 | G.safe.07, G.wf.02 (F-D3) |
| [pr-32](pr-32.md)     | Golden study outputs                                  | 2.5 | G.test.08 |
| [pr-32.5](pr-32.5.md) | Nightly `shadow refresh` cron                        | 3.0 | T-F1 |
| [pr-33](pr-33.md)     | Docs completion wave 1                                | 2.5 | G.doc.06-09 |
| [pr-34](pr-34.md)     | Docgen verify                                         | 2.5 | G.doc.12 |
| [pr-34.5](pr-34.5.md) | Cheatsheet auto-section via docgen                   | 2.5 | G.umb.06 |
| pr-v4                 | Version bump 1.0.0                                    | —   | — |

## How to use these files

1. Agent picks up a PR via `code-dev resume` or human directive ("start PR-N").
2. Agent reads `03-prs/pr-N.md` (this directory) for full context.
3. Agent implements per the **Spec** section.
4. Updates `_meta.md` PR block and `_actions.log`.
5. HUMAN reviews, runs tests, merges.

## Source map (which study round backs each PR)

| Round | Helper prefix | PRs primarily backed |
|-------|---------------|----------------------|
| R1    | `c1-..c3-`    | PR-2 (token findings), PR-13 (usage) |
| R2 (code-dev focus)        | `cd-c1..c4-`  | PR-1, PR-2, PR-9.5, PR-13, PR-15.5, PR-15.6, PR-20.5-20.8 |
| R3 (tools/umbrella)        | `cd-tools-p*` | PR-12, PR-14, PR-26-28, PR-34.5 |
| R4 (workflow + naming)     | `cd-wf-c*-p*` | PR-6, PR-9.6, PR-9.7, PR-20.6, PR-23, PR-28.5, PR-31, PR-32.5 |
| R5 (study + plan modes)    | `cd-study-c*-p*` | PR-8, PR-11, PR-16, PR-17, PR-25.5, PR-30 |
| R6 (gap-closure)           | `cd-gap-c*-p*` | PR-3, PR-4, PR-5, PR-7, PR-10, PR-15, PR-18, PR-19, PR-20, PR-21, PR-22, PR-24, PR-25, PR-29, PR-31.5, PR-32, PR-33, PR-34 |
| I1-I5 (plan iteration)     | `cd-plan-i*`  | sequencing/risks; consulted by every PR |

# CD·GAP·C4·P1 — consolidated goal tree

> Every goal extracted from R2-R6, organized as a tree. Single-ID space (G.* prefixed by area). This is the spine the eventual plan will operate on.

> Cross-reference: original area-specific goal tables live in `cd-gap-c1-p3-goals-extracted.md` (R2-R5) and the L2/L3 helpers above (R6 adds).

## Top-level structure

```
ROOT (axon-master: harden the OS for code-dev as flagship workflow)
│
├── A. INFRASTRUCTURE & SCHEMA  ── G.inf.*  (low-level invariants)
├── B. COMPILER & TOKENS         ── G.tok.*
├── C. UMBRELLA / NAMING         ── G.umb.*
├── D. WORKFLOWS                 ── G.wf.*
├── E. STUDY MODE                ── G.study.*
├── F. PLAN MODE                 ── G.plan.*
├── G. GOVERNANCE                ── G.gov.*
├── H. SESSION MODEL             ── G.sess.*
├── I. TESTING                   ── G.test.*
├── J. DOCUMENTATION             ── G.doc.*
├── K. OBSERVABILITY / COST       ── G.obs.*
├── L. FAILURE MODES / SAFETY    ── G.safe.*
└── M. TEAM / MULTI-ACTOR (DEFERRED)  ── G.team.*
```

## A. INFRASTRUCTURE & SCHEMA — G.inf.*

| ID         | Goal                                                            | Source        | Priority |
|------------|-----------------------------------------------------------------|---------------|----------|
| G.inf.01   | `_meta.md` schema v4.1 published & documented                  | R5, U-2       | P0       |
| G.inf.02   | Migrator v1 → v4 → v4.1, idempotent, with backup/restore       | G-CD-A1, U-2  | P0       |
| G.inf.03   | `resume` auto-detects + offers migration                       | U-2           | P0       |
| G.inf.04   | Atomic write helper for `_meta.md`, `_actions.log`, `journal/` | F-B2, F-B3    | P1       |
| G.inf.05   | `_session.md` schema v1 (session as first-class object)        | U-6           | P1       |
| G.inf.06   | v5 schema spec (stacks, sync, spec-history)                    | R4 G-S*       | P2       |

## B. COMPILER & TOKENS — G.tok.*

| ID         | Goal                                                            | Source     | Priority |
|------------|-----------------------------------------------------------------|------------|----------|
| G.tok.01   | Audit every compiled program; numbers table                    | R2 T-A1, U-1 | P0     |
| G.tok.02   | `compile-write.py` regression gate (95% bytes & tokens)        | R2 T-A3, U-1 | P0     |
| G.tok.03   | Static-prefix discipline lint                                  | U-8        | P0       |
| G.tok.04   | Quarantine RED-class compiled programs                         | U-1        | P0       |
| G.tok.05   | Per-program `budget:` frontmatter block                        | U-8        | P1       |
| G.tok.06   | `tools/usage.py` per-turn logging                              | U-8        | P1       |
| G.tok.07   | Cache-hit-rate metric                                          | U-8        | P2       |
| G.tok.08   | Token-ceiling field in `_meta.md`                              | U-8        | P1       |

## C. UMBRELLA / NAMING — G.umb.*

| ID         | Goal                                                            | Source        | Priority |
|------------|-----------------------------------------------------------------|---------------|----------|
| G.umb.01   | Router stubs for top umbrellas (meta, pr, study, plan, lifecycle) | R3 W1     | P1       |
| G.umb.02   | Deprecation-stub pattern for renamed verbs                     | R3 W2         | P1       |
| G.umb.03   | Dispatch `# desc:` quality pass                                | R3            | P1       |
| G.umb.04   | TW8 rename-safety harness before W4                            | U-3 / R3 W4   | P0       |
| G.umb.05   | File renames executed in waves                                 | R3 W4         | P2       |
| G.umb.06   | Cheatsheet auto-generated from `# desc:`                       | R3 + U-7      | P1       |

## D. WORKFLOWS — G.wf.*

| ID         | Goal                                                            | Source     | Priority |
|------------|-----------------------------------------------------------------|------------|----------|
| G.wf.01    | Canonical-flows doc (entry → exit per scenario)                | R4         | P1       |
| G.wf.02    | `code-dev tour` keeps current (cross-ref lint)                 | R4         | P2       |
| G.wf.03    | CI integration: `pr sync` reads checks, `pr ready` consults    | R4         | P2       |
| G.wf.04    | PR-stack support (`stack-id`)                                  | R4 G-S5    | P2       |
| G.wf.05    | "First 30 minutes" tutorial                                    | R4 + U-7   | P1       |
| G.wf.06    | Workflow cookbook (top 10 scenarios)                           | R4         | P2       |
| G.wf.07    | `code-dev next` weights by phase + stack position               | R4         | P2       |

## E. STUDY MODE — G.study.*

| ID          | Goal                                                            | Source   | Priority |
|-------------|-----------------------------------------------------------------|----------|----------|
| G.study.01  | Modes taxonomy: quick / standard / deep                         | R5       | P0       |
| G.study.02  | `study/_index.md` + per-area files                             | R5 S0.1  | P0       |
| G.study.03  | Staleness flags (timestamps + threshold)                       | R5       | P0       |
| G.study.04  | Migrator: existing `01-study.md` → `study/` folder             | R5 + U-2 | P0       |
| G.study.05  | Per-mode budgets (1k/5k/15k)                                   | R5 + U-8 | P1       |
| G.study.06  | Idempotence test (≥ 80% across two runs)                        | R5 NS-2  | P1       |
| G.study.07  | Areas: lifecycle, deps, security, perf, ux, ops, schema, docs   | R5       | P1       |

## F. PLAN MODE — G.plan.*

| ID         | Goal                                                            | Source       | Priority |
|------------|-----------------------------------------------------------------|--------------|----------|
| G.plan.01  | Modes taxonomy: strategy / tactical / operational / decision    | R5           | P0       |
| G.plan.02  | Plan consults `study/_index.md`; require relevant studies      | R5           | P0       |
| G.plan.03  | `plan --rule "<text>"` injects ad-hoc constraint                | R5           | P1       |
| G.plan.04  | Plan reads `safety/rules.md` + `dont-do.md`                     | R5 + U-5     | P0       |
| G.plan.05  | Governance trace appended to every plan                         | U-5          | P0       |
| G.plan.06  | Plan output schema (sections + machine-readable)                | R5           | P1       |
| G.plan.07  | Plan-vs-plan diff/compare                                       | R5           | P2       |
| G.plan.08  | Plan-to-PR materialization helper                               | R5           | P1       |

## G. GOVERNANCE — G.gov.*

| ID         | Goal                                                            | Source | Priority |
|------------|-----------------------------------------------------------------|--------|----------|
| G.gov.01   | `safety/rules.md` schema (rules-v1 YAML)                        | U-5    | P0       |
| G.gov.02   | Precedence model documented                                     | U-5    | P0       |
| G.gov.03   | `code-dev rules audit` (contradictions + dead rules)            | U-5    | P1       |
| G.gov.04   | Strict-mode escalator (`--strict`)                              | U-5    | P0       |
| G.gov.05   | `pr ready --strict` consults stale + rules + tests              | U-5    | P0       |

## H. SESSION MODEL — G.sess.*

| ID         | Goal                                                            | Source | Priority |
|------------|-----------------------------------------------------------------|--------|----------|
| G.sess.01  | `_session.md` object created per chat                           | U-6    | P0       |
| G.sess.02  | handoff vs freeze vs tag distinction documented                 | U-6    | P0       |
| G.sess.03  | Auto-checkpoint every N turns                                   | U-6    | P0       |
| G.sess.04  | Compaction-recovery harness                                     | U-6, F-A1 | P0    |
| G.sess.05  | `code-dev chats list/show/switch`                               | U-6    | P2       |
| G.sess.06  | Resume restores session continuation note                       | U-6    | P1       |

## I. TESTING — G.test.*

| ID         | Goal                                                            | Source | Priority |
|------------|-----------------------------------------------------------------|--------|----------|
| G.test.01  | T1 full structural test coverage                                | U-3    | P0       |
| G.test.02  | T2 dispatch golden corpus (50+ prompts)                         | U-3    | P0       |
| G.test.03  | T3 behavioral tests for 5 critical programs                     | U-3    | P1       |
| G.test.04  | T5 idempotence harness                                          | U-3 + R5 | P1     |
| G.test.05  | T6 token-budget tests                                           | U-3 + U-8 | P0    |
| G.test.06  | T7 router/stub contract tests                                   | U-3    | P0       |
| G.test.07  | T8 rename-safety snapshot diff                                  | U-3    | P0       |
| G.test.08  | T4 study-mode golden outputs                                    | U-3    | P2       |

## J. DOCUMENTATION — G.doc.*

| ID         | Goal                                                            | Source | Priority |
|------------|-----------------------------------------------------------------|--------|----------|
| G.doc.01   | AXON-DOCS-WORKFLOWS.md                                          | R4 + U-7 | P0     |
| G.doc.02   | AXON-DOCS-STUDY.md                                              | R5 + U-7 | P0     |
| G.doc.03   | AXON-DOCS-PLAN.md                                               | R5 + U-7 | P0     |
| G.doc.04   | AXON-DOCS-SCHEMA.md                                             | U-2 + U-7 | P0    |
| G.doc.05   | AXON-DOCS-GOVERNANCE.md                                         | U-5 + U-7 | P1    |
| G.doc.06   | AXON-DOCS-SESSIONS.md                                           | U-6 + U-7 | P1    |
| G.doc.07   | AXON-DOCS-COMPILER.md                                           | U-1 + U-8 | P1    |
| G.doc.08   | AXON-DOCS-TESTING.md                                            | U-3 + U-7 | P1    |
| G.doc.09   | AXON-DOCS-FAILURE-MODES.md                                      | U-4 + U-7 | P1    |
| G.doc.10   | AXON-DOCS-CHEATSHEET.md (one page)                              | U-7    | P0       |
| G.doc.11   | first-30-minutes tutorial                                       | U-7    | P1       |
| G.doc.12   | `docgen verify` link/cross-ref lint                             | U-7    | P2       |

## K. OBSERVABILITY / COST — G.obs.*

| ID         | Goal                                                            | Source | Priority |
|------------|-----------------------------------------------------------------|--------|----------|
| G.obs.01   | Per-turn usage logging                                          | U-8    | P0       |
| G.obs.02   | `code-dev meta usage` aggregator                                | U-8    | P1       |
| G.obs.03   | Per-program cost dashboard                                      | U-8    | P2       |
| G.obs.04   | Session-level burn warnings                                     | U-8 + U-6 | P1    |
| G.obs.05   | Cache-hit-rate measurement                                      | U-8    | P2       |
| G.obs.06   | Dispatch-quality measurement (precision @1, @3)                 | U-12   | P1       |

## L. FAILURE MODES / SAFETY — G.safe.*

| ID         | Goal                                                            | Source | Priority |
|------------|-----------------------------------------------------------------|--------|----------|
| G.safe.01  | Failure-mode catalog → `workspace/log/failure-modes.md`         | U-4    | P0       |
| G.safe.02  | Postmortem template                                             | U-4    | P1       |
| G.safe.03  | Secret-redaction in journal                                     | F-H1   | P0       |
| G.safe.04  | Push-gate self-check (post-incident)                            | F-A2   | P0 ✓ (memory) |
| G.safe.05  | Persona-bleed re-anchor doc                                     | F-A1   | P0 ✓ (memory) |
| G.safe.06  | Hallucinated-tool-output rule                                   | F-A3   | P0 ✓ (kernel) |
| G.safe.07  | Recursive program loop detector                                  | F-D3   | P2       |
| G.safe.08  | Backup pre-push secret scan                                      | F-H1   | P1       |

## M. TEAM / MULTI-ACTOR — G.team.* (DEFERRED, kept for v5)

| ID         | Goal                                                            | Source | Priority |
|------------|-----------------------------------------------------------------|--------|----------|
| G.team.01  | Multi-actor mode                                                | R4     | P3       |
| G.team.02  | Shared-rules at workspace level                                 | U-5    | P3       |
| G.team.03  | Cross-project ergonomics                                        | R4     | P3       |
| G.team.04  | Library-dev parallel workflow                                   | R4     | P3       |

## Totals
- A: 6, B: 8, C: 6, D: 7, E: 7, F: 8, G: 5, H: 6, I: 8, J: 12, K: 6, L: 8, M: 4
- **TOTAL: 91 goals**, of which ~50 are P0 (must-have for first plan wave).

## P0 quick list (eyes-on)
G.inf.01–04, G.tok.01–04, G.umb.04, G.study.01–04, G.plan.01–02, G.plan.04–05, G.gov.01–02, G.gov.04–05, G.sess.01–04, G.test.01–02, G.test.05–07, G.doc.01–04, G.doc.10, G.obs.01, G.safe.01, G.safe.03

→ priority matrix: `cd-gap-c4-p2-priority-matrix.md`.

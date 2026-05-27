# CD·GAP·C4·P2 — priority / impact / effort / dependency matrix

> Helps the plan pick wave-1 candidates. Effort & impact are agent estimates; the plan will refine.

## Legend

- **Impact**: 1 (cosmetic) … 5 (unblocks multiple gates / averts incidents)
- **Effort**: 1 (< 1 hour) … 5 (multi-PR wave)
- **Dep**: P0/P1/P2 priority + IDs this depends on

## Wave-1 candidates (high impact, low-medium effort, few deps)

| Goal       | Impact | Effort | Deps                 | Notes                                              |
|------------|:------:|:------:|----------------------|----------------------------------------------------|
| G.inf.01   | 5      | 1      | —                    | document existing fields — pure doc                |
| G.inf.02   | 5      | 3      | G.inf.01             | THE migrator; unblocks resume on old projects      |
| G.inf.03   | 4      | 1      | G.inf.02             | one branch in resume program                       |
| G.tok.01   | 4      | 2      | tokenizer.py         | numbers-only audit; HUMAN runs tokenizer           |
| G.tok.02   | 5      | 2      | G.tok.01             | one gate in compile-write.py                       |
| G.tok.04   | 4      | 1      | G.tok.01             | flag in compiled manifest                          |
| G.gov.01   | 4      | 1      | —                    | YAML schema only                                   |
| G.gov.02   | 4      | 1      | G.gov.01             | doc                                                |
| G.gov.04   | 4      | 2      | G.gov.01–02          | `--strict` plumbing in plan + pr-ready             |
| G.umb.04   | 5      | 2      | G.test.01            | rename-safety harness — blocks R3 W4               |
| G.test.01  | 3      | 2      | —                    | finish structural coverage                         |
| G.test.07  | 4      | 1      | G.test.01            | snapshot diff                                      |
| G.safe.03  | 4      | 1      | —                    | regex redact in journal                            |
| G.doc.10   | 5      | 1      | —                    | one-page cheatsheet (high leverage / low effort)   |
| G.sess.04  | 4      | 2      | —                    | compaction recovery harness                        |

## Wave-2 candidates

| Goal       | Impact | Effort | Deps                | Notes                                            |
|------------|:------:|:------:|---------------------|--------------------------------------------------|
| G.study.01 | 5      | 3      | —                   | modes taxonomy + dispatch                         |
| G.study.02 | 4      | 2      | G.inf.02            | `study/` folder + `_index.md`                    |
| G.study.03 | 3      | 1      | G.study.02          | timestamp + threshold                            |
| G.study.04 | 3      | 1      | G.inf.02            | move-and-redirect (in migrator)                   |
| G.plan.01  | 5      | 3      | G.study.01          | plan modes                                       |
| G.plan.02  | 5      | 2      | G.study.02          | plan reads `_index.md`                            |
| G.plan.04  | 5      | 1      | G.gov.01            | plan reads rules                                  |
| G.plan.05  | 4      | 1      | G.plan.04           | append governance trace                          |
| G.sess.01  | 4      | 2      | —                   | `_session.md` schema                              |
| G.sess.02  | 3      | 1      | —                   | doc                                              |
| G.sess.03  | 4      | 2      | G.sess.01           | auto-checkpoint                                  |
| G.tok.05   | 3      | 2      | G.tok.02            | budget block per program                         |
| G.tok.08   | 3      | 1      | —                   | `token-ceiling` field                            |
| G.umb.01   | 4      | 3      | G.umb.04, G.test.07 | router stubs                                     |
| G.umb.03   | 3      | 2      | —                   | dispatch desc pass                               |

## Wave-3 candidates

G.umb.02, G.umb.06, G.test.02, G.test.05, G.test.06, G.doc.01–04, G.obs.01, G.obs.02, G.safe.01, G.safe.02, G.wf.01, G.wf.05.

## Wave-4+ (later)

G.umb.05 (file renames), G.test.03/04/08, G.doc.05–09/11/12, G.obs.03–06, G.plan.03/06–08, G.wf.02–04/06–07, G.sess.05–06, G.tok.06/07, G.inf.04–06, G.safe.07–08.

## Deferred (post-v5 / not in scope)
All G.team.* — multi-actor, library-dev parallel.

## Critical path

```
G.inf.01 → G.inf.02 → G.inf.03 ───────────┐
                                          │
G.tok.01 → G.tok.02 → G.tok.04 ──────────┤
                          ↓               │
                       G.tok.05           │
                                          ▼
G.gov.01 → G.gov.02 → G.gov.04 ─── G.plan.04 → G.plan.05
                                          ▲
G.study.01 ─→ G.study.02 ─→ G.plan.02 ────┤
                  ↓                       │
              G.study.04 (needs G.inf.02) │
                                          │
G.test.01 → G.test.07 → G.umb.04 → G.umb.01 → G.umb.02 → G.umb.05
```

Note: G.inf.02 (migrator) gates G.study.04. Therefore migrator must ship first.

## Effort-impact scatter (top-left = quick wins)

```
high impact ↑
            │   G.doc.10                 G.inf.02   G.umb.04   G.plan.01
            │   G.gov.01                 G.tok.02   G.study.01 G.umb.01
            │   G.tok.04                 G.gov.04   G.plan.02
            │   G.inf.01                 G.tok.01   G.plan.04
            │   G.safe.03                G.test.07  G.sess.04
            │
            │   G.umb.03                 G.tok.05   G.study.02
            │   G.test.01                G.sess.01  G.plan.05
            │
            │   …                        …          …
            │
low impact  ↓   low effort →→→→→→→→→→→→→→→→→→→→→→→→ high effort
```

→ readiness checklist: `cd-gap-c4-p3-readiness-checklist.md`.

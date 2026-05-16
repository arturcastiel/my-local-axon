# CD·PLAN·I1·A — audit (iteration 1)

> Audit of the I1·S refinements. Cross-check against constraints, failure modes, and prior-round findings.

## Constraint cross-check

| Constraint                                              | Status |
|---------------------------------------------------------|--------|
| Kernel rule 7 — never write `axon/` without dev-mode    | OK — all plan items target `workspace/`, `tools/`, `my-axon/`, `tests/` |
| Kernel rule 9 — humans run builds/tests                  | OK — agent writes code; HUMAN executes pytest/compile |
| User memory — no push without explicit consent          | OK — plan does not auto-push |
| AGENT contract — boot first                             | OK — assumed |
| `safety/rules.md`                                       | empty currently; emit empty governance-trace |
| `dont-do.md`                                            | empty currently |

## Failure-mode cross-check (top-10 mitigation list)

| #  | Failure mode               | Addressed by             | Status      |
|---:|----------------------------|--------------------------|-------------|
| 1  | F-A2 premature push        | already in memory        | covered     |
| 2  | F-A1 persona drift         | already in memory + kernel | covered    |
| 3  | F-B1 schema mismatch       | G.inf.02 (migrator)      | wave-1      |
| 4  | F-C1 negative compression  | G.tok.02 (gate)          | wave-1      |
| 5  | F-A3 hallucinated output   | kernel rule              | covered     |
| 6  | F-E4 stale study           | G.study.03 + G.gov.05    | wave-2      |
| 7  | F-D1 mis-dispatch          | G.obs.06 + G.test.02     | wave-2/3    |
| 8  | F-H1 secret push           | G.safe.03                | wave-1      |
| 9  | F-E3 rule contradiction    | G.gov.03                 | wave-3      |
| 10 | F-C4 compaction loss       | G.sess.03 + G.sess.04    | wave-2      |

→ all top-10 addressed within first 3 waves.

## Critical-path check
- G.inf.02 (migrator) is single most-blocking item — confirms must be in wave-1.
- G.tok.02 (gate) is independent — can run in parallel.
- G.umb.04 (rename-safety) blocks G.umb.01 (routers) which blocks G.umb.05 (file renames). Routers can ship in wave-2; renames in wave-4+.

## Dependency DAG (P0 subset)

```
G.inf.01 (doc)
   └→ G.inf.02 (migrator)
        ├→ G.inf.03 (resume integration)
        ├→ G.study.04 (folded in)
        └→ G.study.02 (_index.md skeleton; needs migrator path)

G.tok.01 (audit numbers)  ──→ G.tok.02 (gate)
                                     ├→ G.tok.04 (quarantine)
                                     └→ G.tok.05 (budget block)

G.gov.01 (rules schema)
   └→ G.gov.02 (precedence doc)
        └→ G.gov.04 (--strict)
             └→ G.gov.05 (pr ready --strict)

G.gov.01 ───→ G.plan.04 (plan reads rules) ─→ G.plan.05 (trace)

G.study.01 (modes) ─→ G.plan.01 (plan modes) ─→ G.plan.02 (consults _index.md)

G.test.01 (structural) ─→ G.umb.04 (rename harness) ─→ G.umb.01 (routers) ─→ G.umb.05 (renames)

G.sess.01 (_session.md) ─→ G.sess.03 (checkpoint) ─→ G.sess.04 (compaction recovery)

G.obs.01 (usage logging) ──(independent)──→ G.obs.02 (aggregator)

G.safe.03 (redact) ──(independent)──
G.doc.10 (cheatsheet) ──(independent)──
```

## Wave assignment (post-DAG)
- **W1** roots-of-trees-and-quick-wins: G.inf.01, G.inf.02, G.tok.01, G.tok.02, G.gov.01, G.gov.02, G.safe.03, G.doc.10, G.test.01.
- **W2** unlock-things-W1-enabled: G.inf.03, G.tok.04, G.gov.04, G.plan.04, G.study.01, G.sess.01, G.umb.04, G.obs.01.
- **W3** consume-W2: G.gov.05, G.plan.05, G.plan.01, G.plan.02, G.study.02, G.study.03, G.sess.03, G.sess.04, G.umb.01, G.test.07.
- **W4+**: everything else, including renames, broader docs, deeper tests.

## PR-count estimate
- W1: 9 goals → ~7 PRs (some bundle).
- W2: 8 goals → ~7 PRs.
- W3: 10 goals → ~8 PRs.
- W4+: ~30+ goals → ~15-20 PRs.

Total plan footprint: ~35-45 PRs. First-three-waves: ~22 PRs. Sane.

## Holes found in I1·S (audit corrections)
1. **No mention of order between G.tok.01 audit and the compaction event** — measurement of token cost must happen BEFORE the compile-gate ships, otherwise threshold is uncalibrated. Confirmed: G.tok.01 → G.tok.02 (kept).
2. **G.sess.04 (compaction recovery harness) needs a synthetic test fixture** — add to test deliverables (covered by G.test.01).
3. **G.inf.02 migrator's `--restore` was specified but not the safety net for partial-state** — needs a follow-up: backup retention policy. Add to W1 PR for migrator.

## Audit verdict
- **Pass with 3 corrections** above incorporated.
- DAG is acyclic.
- Top-10 failure modes are covered by W1-W3.
- Wave sizes are sane.

→ plan draft v1: `cd-plan-i1-p-draft.md`.

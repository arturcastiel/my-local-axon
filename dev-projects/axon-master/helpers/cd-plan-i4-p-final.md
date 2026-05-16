# CD·PLAN·I4·P — plan v4 (FINAL)

> v3 + acceptance details + W3 full + W4 detailed + W5 sketched + version/changelog discipline. This is the source from which `03-plan.md` is materialized.

The contents are the union of:
- `cd-plan-i3-p-v3.md` — W1 and W2 fully detailed
- `cd-plan-i4-s-acceptance.md` — W3, W4 detailed; W5 sketched
- This file — final sequencing + version/changelog overlay + summary tables

## Wave summary table

| Wave | PRs       | Goals delivered                 | Gate to next                                   |
|------|-----------|---------------------------------|------------------------------------------------|
| W1   | PR-1..7   | Schema, compile gate, governance schema, T1, safety, cheatsheet, catalog | 4 MUST PRs merged + migration done + T1 green |
| W2   | PR-8..17  | Study/plan modes, sessions, strict, routers, recovery, staleness, usage | E2E plan with trace; compaction-recovery green; rename snapshot live |
| W3   | PR-18..25 | Dispatch corpus + metric, budgets, ceiling, usage agg, rules audit, docs WSP+SG, idempotence | Dispatch baseline recorded; budgets in every program; top docs live |
| W4   | PR-26..34 | Renames waves A/B/C, behavioral tests, per-mode budgets, ergonomics, golden outputs, docs SCTF, docgen verify | All renames done; behavioral coverage on critical 5; docs near-complete |
| W5+  | PR-35..   | CI, cron, plan diff, plan→PR, tutorial, cookbook | (out-of-scope for this plan; queued)            |

## End-of-wave deliverables

| Wave | Version bump | Changelog | Test result expected |
|------|-------------:|-----------|---------------------|
| W1   | 0.6.x → 0.7.0 | "schema v4.1, compile gate, governance schema, safety baseline" | pytest green; gate active |
| W2   | 0.7.0 → 0.8.0 | "study + plan modes, sessions, strict, routers" | E2E plan + recovery test green |
| W3   | 0.8.0 → 0.9.0 | "dispatch eval, budgets, top docs" | dispatch P@1 ≥ 0.8; budgets enforced |
| W4   | 0.9.0 → 1.0.0 | "renames complete, behavioral tests, docs complete" | full umbrella; behavioral T3 green |

## PR signature template (used by every PR)

```markdown
# PR-N — <title>

## Goals
G.X.YY, G.X.YY, ...

## User-visible change (1 line)
<for CHANGELOG.md>

## Files
**New**: <list>
**Modified**: <list>

## Acceptance
1. ...
2. ...
3. ...

## Rollback
<one short paragraph>

## Owner
- AGENT: writes the code/docs.
- HUMAN: runs tests; merges; pushes (with consent).

## Parallelism
- ⊥ PR-M, PR-K (safe to run concurrently)
- depends-on: PR-J (must merge first)

## lint_paths.py
clean / NA
```

## Execution loop (per PR)

1. AGENT reads PR spec from `03-plan.md`.
2. AGENT writes code + tests + docs.
3. AGENT runs `tools/lint_paths.py` mentally (cannot exec; flags issues for HUMAN).
4. AGENT updates `02-prs.md` block: `pr-N: state=ready-for-review`.
5. HUMAN reviews; HUMAN runs pytest.
6. HUMAN merges; updates `_actions.log`.
7. AGENT updates `_meta.md.pr-N: state=done` + appends CHANGELOG line.
8. Next PR.

## Resume semantics (mid-plan)

If session compacts mid-execution:
1. AGENT on boot reads `_session.md` + `_meta.md`.
2. Identifies last `pr-N: state=in-progress`.
3. Reads PR-N spec from `03-plan.md`.
4. Resumes at the next unchecked acceptance item.

## Replan trigger

If during execution any of these fire, HALT and replan:
- A W1 MUST-PR fails review and cannot be fixed in same session.
- A failure mode not in current catalog appears.
- A user-rule added mid-plan changes scope.
- Token cost forecast exceeds session budget × 1.5.

Replan = create `cd-plan-i5-*` set; produce updated `03-plan.md`.

## DONE definition (end of W4)
- 0.9.x → 1.0.0.
- All P0 goals closed.
- All top-10 failure-mode mitigations live.
- Top-10 docs live.
- Rename umbrella complete.
- Dispatch P@1 ≥ 0.8 measured.
- Compile gate active and respected.
- Schema v4.1 universal.
- Sessions + compaction-recovery hardened.

## Post-1.0 (not in plan, queued for future plan rounds)
v5 schema spec · stacks · sync · CI integration · multi-actor mode · cron/scheduler · library-dev · plan diff / replay · tutorial corpus.

— end of plan v4 / FINAL —

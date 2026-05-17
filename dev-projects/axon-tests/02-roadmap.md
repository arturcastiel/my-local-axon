# Strategic roadmap — AXON Test Battery

> Project:  axon-tests
> Date:     2026-05-16
> Mode:     strategic (tier-1 roadmap)
> Hosts:    02-plan.md (tactical, 21 PRs)

## Vision (one paragraph)

AXON ships with rich infrastructure — 315 pytest cases, 9 rule
predicates, 170 programs, 81 tools, 15 named workflows. **Today
< 3 % of that infrastructure is enforced as a gate.** The roadmap
flips the default: every modification to `axon/` or `tools/` must
pass an end-to-end test battery that proves the kernel rules,
safety-critical workflows, identity gate, and rules engine still
behave as documented. Tests and reference documentation ship
together — every doc page lists the tests that guard it; every test
points back to the doc anchor it pins.

## Releases (rolled up from 02-plan.md)

| Release | Theme                       | PRs        | Outcome |
|---------|-----------------------------|------------|---------|
| R1      | Foundations                 | PR-001..006 | CI runs full suite; coverage gate live; pre-push installed; doc + workflow harnesses ready |
| R2      | Safety-critical             | PR-007..011 | Identity, boot, dev-mode, workspace-backup, full rules engine — all covered |
| R3      | Breadth                     | PR-012..017 | Verifier, workflows, compiler/dispatch, tier-A programs, tool gaps |
| R4      | Closure                     | PR-018..021 | Mandatory enforcement, CONTRIBUTING, README badges, final docs sweep |

## Success metrics

| Metric                                | Today | R4 target |
|---------------------------------------|-------|-----------|
| pytest cases enforced in CI           | ~10   | all (315 + ~200 new) |
| `tools/rules/` line+branch coverage   | unmeasured | 100 % |
| `tools/` line coverage                | unmeasured | ≥ 80 % |
| Rules with dedicated test file        | 1 / 9 | 9 / 9 |
| Workflows with e2e test               | 0 / 15 | 15 / 15 |
| AXON-DOCS pages with Guarded-by block | 0 / 11 | 11 / 11 |
| Autonomous git ops guarded by test    | 0 / 1 | 1 / 1 |
| Identity gate covered                 | no | yes |
| Pre-push hook installed               | no | yes |

## Non-goals (explicit)

- No new AXON behaviour or programs.
- No replacement of pytest or the existing harness.
- No tier-B / tier-C program behavioural coverage (deferred to a
  follow-up project; only ~10 tier-A programs covered here).
- No CI for non-Python artifacts (the doc gate is enforced by
  Python tooling, not a new toolchain).

## Plan index

- `02-plan.md`            — tactical plan (21 PRs across R1..R4)
- `02-prs.md`             — numbered PR list with deps + complexity
- `02-roadmap.md`         — this file
- `phases/1-study/`       — 01-study.md + helpers/ (rules-crosswalk,
                            workflows-catalog)
- `03-prs/PR-NNN.md`      — per-PR specifications (Phase 3 output)

## Cross-refs

- AXON-DOCS-TESTING.md  — current minimal doc; rewritten by PR-021.
- AXON-DOCS-GOVERNANCE.md — gains rule-predicate table (PR-006/011).
- AXON-DOCS-WORKFLOWS.md  — gains W-08..W-15 + Guarded-by per row.
- KERNEL-SLIM.md §§ CORE RULES, BOOT STEPS, COMPLIANCE — pinned by
  PR-008, PR-009, PR-011.

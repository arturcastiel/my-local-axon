# Plan — AXON Test Battery (axon-tests)

> Phase 2 — Tactical plan grounded in the codebase
> Project: axon-tests · Date: 2026-05-16
> Inputs: phases/1-study/01-study.md + helpers/rules-crosswalk.md +
>         helpers/workflows-catalog.md
> Mode: tactical · Confidence (AXON): 8/10
> User §4 answers: defaults accepted (pytest + AXON conventions, cov
> 100% rules / 80% tools, gate in CI **and** pre-push, A/B/C tiering,
> doc co-output advisory → blocking, workflow tests hybrid A+B).

---

## 1. Goal restated

Deliver an exhaustive, mandatory test battery for AXON + the matching
reference documentation, such that any future modification to `axon/`
or `tools/` is gated on:

1. All existing tests pass.
2. New behaviour ships with new tests.
3. New behaviour ships with a doc page whose `Guarded by:` block lists
   those tests.

No AXON behaviour changes. Pure verification + documentation density.

## 2. Architecture grounding (where the test surface actually lives)

| Layer | Source of truth | Today's coverage |
|---|---|---|
| Kernel rules (text)   | `axon/KERNEL-SLIM.md` § CORE RULES               | docs only |
| Rule predicates       | `tools/rules/r*.py` (9 modules)                  | 1 / 9 has dedicated tests |
| Verifier              | `tools/verify.py`                                | 5 black-box cases |
| Tools                 | `tools/*.py` (81 files)                          | partial, no line coverage |
| Path resolver         | `tools/_axon_paths.py`                           | covered (in CI) |
| Programs (text)       | `workspace/programs/*.md` (170, 74 compiled)     | structural lint only |
| Compiler              | `tools/compile.py` + `tools/compile_optimizer.py` | 11 regression cases |
| Dispatch              | `tools/dispatch.py`                              | 3 cases |
| Boot                  | `tools/boot.py` + KERNEL § BOOT STEPS            | integration-only |
| Identity gate         | `axon/programs/identity.md`                       | **0** |
| Workspace-backup      | `workspace/programs/workspace-backup.md`         | **0** |
| Workflows (chains)    | `workspace/AXON-DOCS-WORKFLOWS.md` (W-01..W-07)  | **0** e2e |
| Pre-push secret scan  | `tools/scan_pre_push.py`                          | tool tested; **not wired** |
| CI                    | `.github/workflows/ci.yml`                       | runs ~10 / 315 cases |

## 3. Implementation approach

**One pattern, applied per area:** test PR → doc PR → enforce PR.

- **Test PR** adds `tests/test_<area>/` (or class) with positive +
  negative + edge cases; cross-links its assertions to a doc anchor.
- **Doc PR** updates `workspace/AXON-DOCS-<AREA>.md` with the spec the
  tests pin, ending in a `Guarded by:` block listing test ids.
- **Enforce PR** wires CI / pre-push / audit to make the gate
  mandatory.

The Phase-3 PR list (§ 4 below) follows this rhythm, ordered so that
**foundations land first** (CI gate, coverage tooling, doc template,
audit hook), then **safety-critical areas** (identity, boot,
workspace-backup, rules), then **breadth** (workflows, programs,
compiler, dispatch), then **closure** (mandatory enforcement, repo
docs, README updates).

## 4. Wave structure (PRs grouped into 4 waves)

| Wave | Theme                       | PRs        | Why this order |
|------|-----------------------------|------------|----------------|
| W-A  | Foundations                 | PR-001..006 | Make the gate exist before pouring tests through it |
| W-B  | Safety-critical surfaces    | PR-007..011 | Identity, boot, dev-mode, workspace-backup, rules engine |
| W-C  | Breadth                     | PR-012..017 | Workflows, programs, compiler/dispatch, tools |
| W-D  | Closure                     | PR-018..021 | Make everything mandatory + final docs + README |

## 5. PR list

See `02-prs.md` for the full ordered list with scopes, deps, and
complexity estimates.

## 6. Dependency invariant

No PR depends on a higher-numbered PR.
Key chains:

- PR-001 (CI wired) → PR-002 (coverage gate) → all later test PRs
- PR-003 (pre-push installer) is independent but lands before W-B
- PR-004 (doc template + linter) is depended on by every "Doc PR"
- PR-005 (workflow harness tool) → PR-013, PR-014
- PR-006 (rules-test scaffold + meta-test) → PR-011 and PR-012

## 7. Out of scope

- New AXON behaviour or new programs.
- New tools beyond `tools/workflow_test.py` (PR-005) and minor audit
  extensions (PR-018).
- Test-runner replacement; we keep pytest.

## 8. Open risks

1. **Auto-running tests on `axon/` writes** — the kernel forbids the
   agent from running tests. The gate has to be CI/hook-driven, not
   agent-driven. We document this clearly in PR-021.
2. **Mock-model harness drift** — `tests/_mock_model.py` may not cover
   all program shapes; PR-013 includes a harness audit.
3. **Coverage of the `code-dev-*` family is enormous** — tier-B (every
   `code-dev-*` program) is large; PR-016 may need to split.
4. **AXON-DOCS-* page count will grow** — Phase 4 (separate phase)
   adds the per-rule, per-workflow, per-tool reference pages; this
   plan only ships their skeletons via the doc PRs.

## 9. Phase exits

Phase 2 exits when:
- `02-plan.md` + `02-prs.md` reviewed and confirmed by user.
- PR numbering frozen.
- `_meta.md` phase advances to **2-plan-complete**.

Next: `code-dev pr 1` to write PR-001's full specification.

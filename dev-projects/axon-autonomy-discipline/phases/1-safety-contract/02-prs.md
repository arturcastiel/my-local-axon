# PR List — AXON Autonomy Discipline (phase 1-safety-contract)
Updated: 2026-06-03  ·  Total PRs: 7  ·  AXON: 9/10 · User: 9/10

## PR-001 — Gate rule: code-change ⇒ on-workflow (the teeth)
- **Status:** ✅ merged (!111, squash b28b31d) — gate passed:true, zero warnings; reproduction test locks the freelance
- **Complexity:** M
- **Scope:** `tools/rules/r_code_change_requires_pr_phase.py` (new) · `tests/test_r_code_change_requires_pr_phase.py` · `tools/crucible.json` (WARN control) · wire into `crucible.run_changeset`
- **Depends on:** none
- **Why:** criterion-zero — the gate refuses an off-workflow code change. Predicate: silent-no-project · code-classifier · meta/non-code exempt · weakest-sound coverage · WARN→BLOCK. Reproduction test locks the 2026-06-03 freelance. (01-study C, E1.)
- **Spec:** 03-prs/PR-001.md ✓

## PR-002 — Reanchor re-asserts workflow position
- **Status:** ✅ merged (!112, squash e1784b7) — gate passed:true, zero warnings; neuron-audit PASS; reuses PR-001's predicate
- **Complexity:** M
- **Scope:** `tools/autonomy_reanchor.py` (extend frame-check with the on-workflow check) · `workspace/programs/autonomy-reanchor.md` (halt off-workflow) · tests
- **Depends on:** PR-001
- **Why:** proactive boundary enforcement — re-assert identity + workflow position, halt off-workflow before the gate (the reanchor that would have caught the freelance). The cleaned draft is the skeleton. (01-study C3, B3.)
- **Spec:** 03-prs/PR-002.md (not written yet)

## PR-003 — Autonomy contract (ask for powers)
- **Status:** ✅ merged (!113, squash 46b9770) — thin-waist (tool + program); 3 effects asserted as observed state; gate passed:true, zero warnings
- **Complexity:** M
- **Scope:** `workspace/programs/autonomy-contract.md` (new; `TOOL(decide)` interview → `_policy.md` + `autonomous-mode on` + `accountability open`) · `tools/crucible.json` WARN control `autonomy-contract`
- **Depends on:** none
- **Why:** unify the decoupled AEGIS policy + autonomous-mode grant via one interactive contract; the overnight entry gate (least-privilege within the existing floor). (01-study B2.)
- **Spec:** 03-prs/PR-003.md (not written yet)

## PR-004 — Circuit breakers
- **Status:** ✅ merged (!114, squash a5be82d) — breaker state machine + R_AUTONOMY_BREAKER rule; trip logic asserted as observed state; gate passed:true, zero warnings. (Signal wired by PR-005.)
- **Complexity:** M
- **Scope:** `tools/rules/r_autonomy_breaker.py` (+ small breaker state) · `tools/crucible.json` control · tests
- **Depends on:** PR-003
- **Why:** halt-and-surface, never push through — twice-red gate / N consecutive failures / out-of-scope touch / budget exhausted (lessons L1, L7).
- **Spec:** 03-prs/PR-004.md (not written yet)

## PR-005 — Operate-through-AXON: command counter + cadence fire + discipline workflow
- **Status:** ✅ merged (!115, 1ae998a) — refined to the cadence STATE (keyed off W:turn-count; no core-touch) + reanchor records its fire. Orchestrator auto-fire + autonomy-discipline.yml DEFERRED (the PR-006 backstop enforces without them). gate passed:true.
- **Complexity:** L
- **Scope:** `tools/dispatch.py` (increment `W:autonomous-command-count`) · orchestrator cadence fire (every 5, autonomous mode) · `workspace/workflows/autonomy-discipline.yml` (FIXED: contract → reanchor → select → breaker) · workflow-validate + workflow-simulate + tests
- **Depends on:** PR-002, PR-003, PR-004
- **Why:** the one-line definition made operational — operate AXON's programs + reanchor on cadence; the discipline runs on AXON's own engine. (01-study D, E2-FIRE.)
- **Spec:** 03-prs/PR-005.md (not written yet)

## PR-006 — Cadence backstop (enforced, not trusted)
- **Status:** ✅ merged (!116, eaf5928) — R_AUTONOMY_CADENCE detects a lapsed reanchor at the gate; WARN→BLOCK via flag; gate passed:true, zero warnings.
- **Complexity:** M
- **Scope:** `tools/autonomy_cadence.py` (new; records last-reanchor count) · `tools/rules/r_autonomy_cadence.py` + `tools/crucible.json` control · tests
- **Depends on:** PR-005
- **Why:** make a reanchor lapse > 5 commands DETECTABLE at the gate — detection = enforcement; converts the cadence from trusted to enforced. (01-study E2-VERIFY.)
- **Spec:** 03-prs/PR-006.md (not written yet)

## PR-007 — Flip gate rules WARN→BLOCK
- **Status:** ✅ merged (!117, d6ba21f) — all 3 rules BLOCK-by-default (opt-out via `false`); committable repo-wide flip (longterm is gitignored); current state trips none; gate passed:true at BLOCK. **PHASE 7/7 COMPLETE.**
- **Complexity:** S
- **Scope:** set `L:code-change-requires-pr-phase-required=true` + `L:autonomy-cadence-required=true` (after the backlog is clean) · update `tools/crucible.json` severities → BLOCK + notes
- **Depends on:** PR-001, PR-006
- **Why:** the ratchet — make criterion-zero + the cadence ENFORCED (BLOCK), so off-workflow code + a lapsed reanchor cannot merge.
- **Spec:** 03-prs/PR-007.md (not written yet)

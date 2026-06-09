# Branch → PR registry — AXON Autonomy Discipline

| Branch | PR | Phase | Status | Notes |
|--------|----|----|--------|-------|
| fix/gate-rule-on-workflow | !111 | 1-safety-contract | ✅ merged | PR-001 — R_CODE_CHANGE_REQUIRES_PR_PHASE (criterion-zero / the teeth) |
| feat/autonomy-reanchor | !112 | 1-safety-contract | ✅ merged | PR-002 reanchor — identity + workflow-position, fail-closed (e1784b7) |
| fix/autonomy-contract | !113 | 1-safety-contract | ✅ merged | PR-003 autonomy contract — powers interview → policy + grant + ledger (46b9770) |
| fix/autonomy-breaker | !114 | 1-safety-contract | ✅ merged | PR-004 circuit breakers — halt-and-surface on grinding red (a5be82d) |
| fix/autonomy-cadence | !115 | 1-safety-contract | ✅ merged | PR-005 cadence state (keyed off turn-count) + reanchor records its fire (1ae998a) |
| fix/autonomy-cadence-backstop | !116 | 1-safety-contract | ✅ merged | PR-006 cadence backstop — R_AUTONOMY_CADENCE flags a lapsed reanchor (eaf5928) |
| fix/autonomy-flip-block | !117 | 1-safety-contract | ✅ merged | PR-007 flip WARN→BLOCK — discipline now MANDATORY (d6ba21f) |
| fix/autonomy-hollow-rules-warn | !118 | 2-followups | ✅ merged | PR-F1 selective revert — breaker+cadence → WARN (hollow, audit F1/F2/F3); gate rule stays BLOCK (ef89593) |
| fix/autonomy-breaker-recorder | !119 | 2-followups | ✅ merged | PR-F2 breaker recorder wired into run_changeset (guarded by unattended run marker) + anchored change-id + run reset (F1/F12/F13) (ef1f628) |
| fix/autonomy-cadence-runs | !120 | 2-followups | ✅ merged | PR-F3 cadence — run_active gate (F3) + fail-closed on absent counter (F2) + record-after-HALT (F7); recovered a branch-first slip (7fa3b66) |
| fix/gate-rule-soundness | !121 | 2-followups | ✅ merged | PR-F4 gate rule — W:myaxon-path resolver (F4) + status-aware coverage (F5) + _meta/_phases union (F6); F10/F11 deferred/by-design (1072515) |
| fix/contract-policy-budget | !122 | 2-followups | ✅ merged | PR-F5 contract — _policy.md backup+preserve (F8) + structured advisory budget (F9) (d479915) |
| fix/reflip-block-end-to-end | !123 | 2-followups | ✅ merged | PR-F6 re-flip breaker+cadence → BLOCK with end-to-end proof + anchored_change_id single-source fix (5434e22) |
| fix/breaker-green-resets | !124 | 3-reaudit-fixes | ✅ merged | PR-G1 re-audit HIGH — green clears same-change reds (R1) + CLI unattended reset (R4) + my-axon fallback align (R8) (616f5d7) |
| fix/gate-rule-soundness-2 | !125 | 3-reaudit-fixes | ✅ merged | PR-G2 gate rule R2 (first-token status) + R3 (prefer _meta coverage) + R6 (pointer parse) (1da6d1a) |
| fix/contract-preserve-bounds | !126 | 3-reaudit-fixes | ✅ merged | PR-G3 contract _policy.md notes slurp bounded + dedup (R5) (15cd720) |

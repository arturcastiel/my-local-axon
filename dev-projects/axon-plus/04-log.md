# Implementation Log — Axon Plus
## Entries
_No entries yet. Run: code-dev log_

### PR-001 — token bench + baseline · commit d5a8ce8 · 2026-06-11
- token-bench tool + BASELINE: boot-menu 32,593 · pr-cycle 8,060 · study 6,789 · chat 1,041.
- 3 gate catches fixed in-PR: orphan-tool (menu wiring), doc counts 162→163, and a REAL
  flaky-infra bug — web-search health probe ran live queries per sweep, network flake under
  gate concurrency = the session's recurring "pytest red only in crucible". Now offline,
  regression-pinned, deterministic under 3-way load.
- Owner design input during gate: semantic compression (denser op vocabulary) = compile
  TARGET design input for PR-007; 5 further levers recorded for W1 re-plan checkpoint
  (sectional reads · cache ordering · delta rendering · warm-start · registry-first).
- MERGED: squash to main, pushed 1e58fa0..d5a8ce8. Branch deleted. W0: 1/5.

### PR-002 — execution receipts · commit 81ab00e · 2026-06-11
- Dispatcher-side receipt ledger (1 edit, all 163 tools) + R_TOOL_RECEIPTS opt-in BLOCK
  rule: claimed-but-unreceipted TOOL() executions = mimicry = blocked. Goal G layer-1 live.
- Gate catches: concurrency-unsafe receipt test (line counting — same class as web-search
  probe flake), rule-test directory convention (tests/test_rules/). Crucible green 4th run.
- MERGED: squash to main, pushed d5a8ce8..81ab00e. W0: 2/5.

### PR-003 — mechanical menu-render check · commit 4fca0ab · 2026-06-11
- R_MENU_RENDERED: partial render blocks naming missing sections; skipped render blocks
  via active_program. Rule 12 mechanical. First-pass green (pr-2 conventions applied).
- MERGED: squash to main, pushed 81ab00e..4fca0ab. W0: 3/5.

### PR-004 — doc census · delivered 2026-06-11 (analysis artifact, no repo diff)
- 497 docs: 6 adjoint-class · 131 unreferenced · 0 age-stale (rot is structural).
  Artifact: census/doc-census-2026-06-11.{json,md}. Feeds PR-026/PR-027. W0: 4/5.

### PR-005 — census discrepancies · delivered 2026-06-11 (investigation, no repo diff)
- residue-lint: healthy, 27 sites real — census probe had parsed a wrong key (false positive).
- prompt-log: tool healthy; REAL finding = dead wiring (kernel declares per-turn logging,
  nothing mechanical fires it; corpus was empty forever). Routed to W5/G hooks work.
- F design consequence: adversarial verification of findings before queueing (study updated).

## WAVE 0 COMPLETE — 2026-06-11
PR-001 token bench+baseline (d5a8ce8) · PR-002 execution receipts (81ab00e) ·
PR-003 menu-render check (4fca0ab) · PR-004 doc census (delivered) · PR-005 investigation
(delivered). Floors live: anti-mimicry receipts + Rule-12 mechanical. Evidence live:
32.6k boot-menu baseline · 497-doc census · F verification discipline.

### PR-006 — menu state aggregation · commit 10bd0aa (LOCAL) · 2026-06-12
- menu-snapshot: 7 envelopes → 1 call (~300 tok); equivalence test-pinned; −1,777/session
  (7% of corrected baseline 26,480 → 24,703). Baseline health-sweep error corrected.
  Anatomy mapped: kernel 12.9k (owner) · menu.md 5.8k (compile) · boot env 3k (brief).
- Gate catches: ruff F401 (unused import) · trailer lint blocked an internal PR-N ref
  (second occurrence — lint-before-commit now hard-stops the script).
- ⚠ PUSH BLOCKED: ci.tno.nl GitLab READ-ONLY (expired license — admin action). Local
  main is source of truth, ahead 1. my-axon backup (github.com) unaffected. Autonomous
  run continues locally; pushes queue until license fixed.

### PR-007 — compile pipeline pilot · commit db0c2c8 (LOCAL) · 2026-06-12
- compile-write tool built (the missing Phase-4 writer); 6 programs compiled: review 43% ·
  impact 35% · plan 24% · study 22% · mode-detect 19% · menu 10% (~3.9k/cycle banked).
- Equivalence BY CONSTRUCTION (functional-line survival, CI) + mechanical staleness test.
- Checkpoint findings: strip 19-43% prose-heavy / 10% op-dense; next tier = sectional
  reads (8k routers) + denser op vocabulary (owner input) + kernel diet (owner-only).
- backup/v02 + bundle v02 → GitHub. W1: 2/4 done (006, 007). Next: PR-008 brief envelopes.

### PR-008 — brief boot envelope · commit d71cba4 (LOCAL) · 2026-06-12
- boot default BRIEF (count/ids), --full escape; consumer audit clean; brief contract
  test-pinned. boot envelope 2,960→593; boot-menu 24,703→22,341 (−16% wave-to-date).
- backup/v03 + bundle v03 → GitHub. W1: 3/4. Next: PR-009 program shadows, then the
  RE-PLAN CHECKPOINT closes the wave.

### PR-009 — sectional reads via compiled TOCs · commit 14e9d47 (LOCAL) · 2026-06-12
- TOC in every .cmp.md (range accuracy = CI); code-dev router: 7,568 → 1,090/routed read
  (−86%). 7 programs compiled. Re-scope per checkpoint-w1 (shadows redundant vs .cmp).

## WAVE 1 COMPLETE — 2026-06-12
boot-menu 26,480 → 22,341 (−16%, mechanical floor reached) · boot envelope −80% ·
menu probes → 1 snapshot · compile pipeline real (7/191, 10–43%/read) · routed reads −86%.
Checkpoint-w1: A-targets proposal + below-floor paths (menu-as-template, hash-attested
warm boot = autonomous candidates; kernel-in-system-prompt, kernel diet = owner-gated).
backup/v01..v04 + bundles on GitHub. Push queue: 4 (GitLab outage).

### PR-010 — convergence contracts · commit b1cc896 (LOCAL) · 2026-06-12
- loop-contract engine: define/iterate/replan/rebudget(human-wall)/report; mechanical
  CONVERGED/EXHAUSTED/REPLAN-advice; receipts per transition; goal-store integration.
- Historic gate note: the compile staleness CI fired its FIRST real enforcement on this
  PR's own menu edit — recompile forced mechanically. 8 lifecycle tests.
- backup/v05 + bundle v05. W2: 1/4. Next: PR-011 loop designer.

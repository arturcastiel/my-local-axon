# Plan — axon-bugfree10 (deep plan · HR council)

> Phase 2. Method: lead-planner proposal → 8-lens HR advisory council (security/kernel-integrity, architecture, test-strategy, release-sequencing, effort, regression, dependency-DAG, Challenger) → deliberated synthesis.
> Council verdict: {'endorse': 0, 'revise': 8, 'reject': 0} over a 26-PR proposal → **31 final PRs**. Date: 2026-07-27.

## Strategy

Strategy: land the trust boundary before anything that could exploit or mask a hole. Wave 1 fixes the security/gate fail-opens and stands up the verification substrate. PR-01 (shell.py R9 write-gate) is first and load-bearing — until the kernel-write anchor is correct, no downstream autofix can be trusted not to scribble the floor; it is expanded with traversal, symlink, and tmp-topology tests plus a mandatory caller-audit of enforce_pretooluse.py and r9_axon_write.py (both pass the same suspect anchor, though neither is a ledgered bug). PR-06 moves to second because test_runner's returncode-blind verdict is the release's pass/fail oracle: every 'passes-after' claim is only trustworthy once it is returncode-aware. The remaining Wave 1 PRs close the doctrine, lint, trace, and program-dry-run gates, extract the config autonomy fail-open (B047) from the old grab-bag into its own promoted PR-28, and surface the live kernel gate holes (PR-22, owner-escalation). PR-02 lands the shared comment-strip helper before PR-05 reuses it.

Phasing rationale: Wave 2 is tool correctness (receipts, workflow, health, state stores, data-integrity, CLI, dispatch, harness) — split where the council converged (B051/axon.py out of the loop_receipt PR into PR-29; PR-14 split so the runtime hook and project_refresh do not share a revert unit with the pure-CLI trio). Wave 3 is program correctness, with the oversized PR-18 split into dispatch (18a) and guard/seed (18b) halves and PR-19 re-labeled L to reflect five separate program traces; program-layer PRs depend on PR-01 (write gate) and PR-06 (verdict). Because tools/simulate.py has no IF/ELSE/DONE branch-scope evaluator, all program-layer oracles are honestly reframed as static-structural assertions rather than a mythical runtime trace harness. Wave 4 is the human-only kernel-floor advisory track: no axon/* source is edited, but every advisory bug now carries a LANDED failing-before test in tests/ (outside the floor, per the test_kernel_floor_pr021 precedent) so these AI-verified bugs become durable checks; the KERNEL-SLIM pre-parse interrupt gate (B052/B053) is split out as PR-27a and placed first in the advisory wave because a broken pre-execution control outranks tool-logic advisories. The R_TOOL_RECEIPTS canonical-name trio (B081/B051/B029) is sequenced so PR-03 lands first and PR-29/PR-10 depend on it, keeping the claim/record boundary consistent.

## Council summary (per lens)

["security-kernel-integrity (revise): PR-01 must prove EVERY named R9 vector (absolute, ../axon traversal, symlink) is closed and co-audit the enforce_pretooluse.py / r9_axon_write.py callers that share the same wrong anchor.","architecture-coupling (revise): file-cohesion discipline is excellent, but extract the security fixes (B047, B051/axon.py) out of thematic grab-bags and converge the tools-side scanners on one comment-strip helper.","test-strategy (revise): test_runner's returncode-blind verdict (B033) is the release oracle and must land second; the program-layer 'trace harness' does not exist, so reframe those oracles as static-structural; advisory bugs should carry LANDED failing-before tests, not un-landed proposals.","release-sequencing-risk (revise): no hard merge conflicts (disjoint files) but move PR-06 to slot 2 as verification infrastructure and split the medium-risk 6-bug PR-18 to halve its blast radius.","effort-estimation (revise): PR-18 is really an L (six program traces) and PR-20 mixes a security fail-open with cosmetics — split both; budget PR-01 as a heavy high-risk M.","regression-blast-radius (revise): 'disjoint files => no dependencies' is false for shared classifier contracts — PR-01 shares _is_axon_path with the PreToolUse hook and the r9 rule; broad-regression gates are needed for B020/B030/B044/B046.","dependency-dag (revise): empty depends_on is largely defensible (no shared files, no cycles), but encode the soft edges — PR-05→PR-02 (strip helper), the B081/B051/B029 receipts trio, and PR-06 as the verification substrate.","challenger (revise): worst offense is burying the B047 autonomy fail-open at position 20 among cosmetic bugs — promote it to Wave 1; split the crown-jewel B001 and the over-batched program PRs; coverage checks out 91/91 but the notes miscount the PRs."]

## Coverage & integrity (validated)

- 91/91 confirmed bugs assigned to exactly one PR · no duplicates · no orphans
- depends_on targets all exist · DAG acyclic · sequence is topologically valid
- 7 PRs are KERNEL-ADVISORY (axon/* — human-only floor, findings-only, owner escalation)

## PR sequence (execution order)

| # | PR | risk/effort | bugs | deps | wave | title |
|---|----|----|----|----|----|-------|
| 1 | **PR-01** | high/M | 3 | — | W1 | shell.py R9 write-gate: fix kernel anchor, redirect regex, and cd-cwd  |
| 2 | **PR-06** | medium/M | 2 | — | W1 | Green-gate integrity: test_runner returncode-aware verdict + quality_l |
| 3 | **PR-04** | medium/M | 3 | — | W1 | Doctrine gates: fail-closed integrity, delimited receipt match, relati |
| 4 | **PR-28** | medium/S | 1 | — | W1 | config.md autonomy fail-open: attended capability-grant branch never f |
| 5 | **PR-02** | medium/M | 3 | — | W1 | Rule linters: strip comments/quotes before EXEC/STORE/phase-ledger sca |
| 6 | **PR-05** | medium/M | 4 | PR-02 | W3 | Lint/dep/conformance gates: close substring & regex fail-opens (reuse  |
| 7 | **PR-03** | medium/M | 4 | — | W1 | Rule linters: regex/parse correctness (arithmetic, dont-do, mode-lock, |
| 8 | **PR-07** | medium/M | 3 | — | W1 | Trace gates: dag conditional edges, drift TTL stability, pr_drift anch |
| 9 | **PR-17** | medium/M | 4 | PR-01, PR-06 | W3 | Program dry-run & control-flow safety: combine/merge/workflow-run |
| 10 | **PR-22** | low/S | 3 | — | W4 | ADVISORY (kernel floor): gate fail-opens in dry_run_lint & write_barri ⚠KF |
| 11 | **PR-08** | medium/M | 2 | PR-06 | W3 | Receipt & ledger integrity: canonical checksum + GC re-chain |
| 12 | **PR-29** | low/S | 1 | PR-03 | W3 | axon.py: record canonical registry tool name in receipts |
| 13 | **PR-09** | low/S | 2 | — | W2 | workflow_run.py: exclude draft workflows, honor boolean-true if: |
| 14 | **PR-10** | low/S | 3 | PR-03 | W3 | Tool health/conformance/registry resolution fixes |
| 15 | **PR-11** | low/S | 2 | — | W2 | State stores: kv_store null value + memory L: rollback history |
| 16 | **PR-13** | medium/M | 3 | PR-06 | W3 | Data-integrity: table-row corruption, rollback eviction ordering, obsi |
| 17 | **PR-14a** | low/S | 4 | — | W2 | CLI arg/boundary hardening: benchmark, tokenizer, context |
| 18 | **PR-14b** | low/S | 2 | — | W2 | Hook/refresh boundary: reanchor_store prompt token + project_refresh r |
| 19 | **PR-15** | medium/S | 2 | PR-06 | W3 | Invocation fidelity: run.py subcommand/args + dispatch threshold persi |
| 20 | **PR-16** | low/S | 2 | — | W2 | Harness plumbing: verify_stop import path + cold_stranger repo_sha |
| 21 | **PR-18a** | medium/M | 3 | PR-01, PR-06 | W3 | code-dev dispatch/CASE routing: state actions branch, phase token, saf |
| 22 | **PR-18b** | medium/M | 3 | PR-01, PR-06 | W3 | code-dev guard/seed logic: study escalation, phase-start CONTAINS anch |
| 23 | **PR-19** | medium/L | 5 | PR-01, PR-06 | W3 | code-dev arg/tool/result marshaling fixes |
| 24 | **PR-20** | medium/M | 5 | PR-06 | W3 | Program logic & interpolation: discover/quality-loop/versions/audit/co |
| 25 | **PR-21** | low/S | 2 | PR-01 | W3 | Program state/persistence: plan-done stale pointers + chat-input persi |
| 26 | **PR-27a** | low/S | 2 | — | W4 | ADVISORY (kernel floor): KERNEL-SLIM active-program interrupt gate int ⚠KF |
| 27 | **PR-23** | low/S | 4 | — | W4 | ADVISORY (kernel floor): predicate/validator/registry error handling ⚠KF |
| 28 | **PR-24** | low/S | 2 | — | W4 | ADVISORY (kernel floor): self_care substring false-positives ⚠KF |
| 29 | **PR-25** | low/M | 5 | — | W4 | ADVISORY (kernel floor): kernel tool logic/format (lib ts, clock, live ⚠KF |
| 30 | **PR-26** | low/S | 4 | — | W4 | ADVISORY (kernel floor): compiler template defects (chat-session, feed ⚠KF |
| 31 | **PR-27b** | low/S | 3 | — | W4 | ADVISORY (kernel floor): kernel program specs (dev-new, plan-list, reg ⚠KF |

## Preserved dissent

- PR-01 grouping: challenger wanted B001 split into its own minimal-diff PR ahead of B031/B032; security/architecture/release lenses (majority) kept the three shell.py bugs together as one gate/one revert unit. Recorded on PR-01.
- R9 caller coverage gap: security and regression lenses identified a probable sibling B001-class fail-open in tools/rules/r9_axon_write.py and in tools/hooks/enforce_pretooluse.py, neither of which is a ledgered bug. It cannot be assigned a bug_id, so it is captured as a mandatory pre-merge caller-audit inside PR-01 rather than a separate PR — the one place the disjoint-file coverage guarantee is genuinely incomplete.
- PR-07/B020 (drift): regression lens wanted it split into its own drift.py PR given its ripple into the fail-closed drift gate and autonomy halt; kept bundled but mitigated by mandating the full drift test corpus as a merge gate.
- Program-layer verification: test-strategy lens holds that static-structural assertions are strictly weaker than the runtime-trace evidence the original plan implied; accepted as the honest ceiling unless the team first builds branch-scope evaluation into simulate.py (not scheduled this release).
- Low-severity CLI bugs (B086/B087/B091 etc.): challenger wanted them deferred out of the release entirely; overruled because the plan must place all 91 confirmed bugs, but they are sunk to Wave 2 and never gate the security wave.
- Advisory kernel gate holes B009/B010/B013 ship UNFIXED (human-only floor). Security and release lenses stress these must be escalated to the owner for a same-cycle manual patch (dev-mode + full-test), because while open, PR-01/B001 is the only automated kernel-write guardrail during Waves 2-3.

## Dependency DAG
```
nodes: PR-01, PR-06, PR-04, PR-28, PR-02, PR-05, PR-03, PR-07, PR-17, PR-22, PR-08, PR-29, PR-09, PR-10, PR-11, PR-13, PR-14a, PR-14b, PR-15, PR-16, PR-18a, PR-18b, PR-19, PR-20, PR-21, PR-27a, PR-23, PR-24, PR-25, PR-26, PR-27b
  PR-05 → PR-02   PR-05/B072 consumes the comment/quote-stripping helper introduced in P
  PR-29 → PR-03   R_TOOL_RECEIPTS canonical-name boundary: B051 (record the canonical na
  PR-10 → PR-03   Same canonical-name boundary: B029 (resolve script by registry 'script
  PR-17 → PR-01   Program-layer autofixes mutate workspace/programs; the R9 kernel-write
  PR-17 → PR-06   Program control-flow evidence relies on a returncode-aware verdict; PR
  PR-18a → PR-01   code-dev dispatch autofixes mutate program files; kernel-write gate mu
  PR-18a → PR-06   Trace evidence trustworthy only after the returncode-aware verdict lan
  PR-18b → PR-01   code-dev guard/seed autofixes mutate program files; kernel-write gate 
  PR-18b → PR-06   Trace evidence trustworthy only after the returncode-aware verdict lan
  PR-19 → PR-01   code-dev marshaling autofixes mutate program files; kernel-write gate 
  PR-19 → PR-06   Five-program trace evidence trustworthy only after the returncode-awar
  PR-20 → PR-06   Program interpolation trace evidence relies on the returncode-aware ve
  PR-21 → PR-01   Program state/persistence autofixes mutate program files; kernel-write
  PR-08 → PR-06   Receipt/ledger tool tests are verified through the runner; returncode-
  PR-13 → PR-06   Data-integrity fixture tests verified through the runner; depends on t
  PR-15 → PR-06   Dispatch-contract change verified via the program-trace corpus through
```

Next: `code-dev pr <N>` to write per-PR specs (Phase 3), starting with Wave 1 (PR-01, PR-06, PR-04, PR-28, PR-02).

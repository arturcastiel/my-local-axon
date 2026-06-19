# Wave G — residual hardening log (redo-until-closed)

## G4 — one cwd-independent axon/ path classifier (#11) — DONE (uncommitted)
- Root cause: tools/_axon_io.py _is_axon_path used path.resolve() (cwd-relative) for relative axon/ targets.
- Fix: added canonical _axon_paths.is_axon_path(target, anchor=None) (relative->AXON_ROOT, realpath, symlink-safe);
  routed _axon_io + shell + r9_axon_write through it (4 impls -> 1 shared + enforce CLI gate keeps its axon_dir contract).
- VERIFIED (live, read-only): _axon_io._is_axon_path('axon/KERNEL-SLIM.md') from cwd=/tmp now True (was False=BUG);
  symlink/traversal/absolute vectors preserved; gate_check 6 known shapes still BLOCK; legit paths ALLOW; no false-pos.
- Test: tests/test_axon_path_unified.py (cwd-independence regression + workspace-anchor converse + symlink + delegation).
- Files: tools/_axon_paths.py (+is_axon_path), tools/_axon_io.py, tools/shell.py, tools/rules/r9_axon_write.py.

## G1a — Bash gate interpreter/redirect/nested-shell vectors (#1, decidable part) — DONE (uncommitted)
- shell.gate_check now recurses interpreter -c/-e/heredoc payloads + nested `sh -c`, widened redirect
  regex to fd-prefixed (1>/3>/&>>/>|), and FAILS CLOSED on parser exception. Catches the literal vector;
  computed-path residual -> G1c (ADR-004). Files: tools/shell.py. Test: tests/test_enforce_bash_gate.py (+vectors).

## G2 — run-id rotates per boot (#6) — DONE (uncommitted)
- Added session.rotate_run_id() (overwrite-once from CLAUDE_CODE_SESSION_ID); wired into boot.py
  auto_recover_sessions BEFORE recover() reads it. current_run_id() semantics untouched (within-boot stable).
- Files: tools/session.py, tools/boot.py. Test: tests/test_session_runid_rotation.py (real two-boot topology).

## REGRESSION CAUGHT BY TESTS (owner: "DONT SKIP tests") — fixed
- G4 delegation initially ignored the monkeypatched _axon_io.AXON_DIR -> 6 test_axon_io_r9 failures
  (axon writes not blocked in the hermetic fixture). Fix: anchor _axon_io._is_axon_path on AXON_DIR.parent
  (honors the injection AND keeps cwd-independence). Live function-call verification had MISSED this; the
  suite caught it. Lesson logged.

## TEST BAR (targeted, run 2026-06-19): 129 passed, 0 failed
  test_axon_path_unified · test_enforce_bash_gate · test_session_runid_rotation · test_shell_sandbox
  · test_rules/test_r9_axon_write · test_axon_io_r9 · test_axon_io_lint · test_enforce_root_anchor
  · test_session_recovery_token   →  ALL GREEN (full crucible+suite gate still required before merge/push)

## G5 — test-ledger truth — DONE (uncommitted)
- Fixed PR-05 spec stale test path (test_terminal_outputs.py -> test_rules/test_r_terminal_outputs.py).
- Verified all 19 PR-spec cited test paths resolve on disk: 0 missing (PR-02 cites "integration", no file — noted).
- A permanent per-project "every cited test exists" meta-check belongs in code-dev-audit (project-scoped),
  NOT the OS unit suite (would fail on a fresh clone with no my-axon/). One-time reconcile done here.

## G6 — commit hygiene — DONE (uncommitted)
- .gitignore += axon/state/ (3.6MB kernel-path ledger), /memory/ (root-anchored), workspace/memory/episodic/,
  .claude/workflows/. _policy.md left TRACKED (deliberate AEGIS policy file, not cruft).
  NOTE: 2 episodic files already tracked -> need `git rm --cached` at commit step (deferred).
- tools/lint_commit_trailer.py _BRANDS += Opus|Sonnet|Haiku|Fable (bare model names were uncaught;
  commit a3630db slipped "Haiku 4.5/Sonnet 4.6/Opus 4.8" through). Test: 21 passed; new matching verified.
- DEFERRED to G1c: axon/state/ R9 write-allowlist (8 tools write it; gitignore alone doesn't unblock the
  R9 gate with dev-mode OFF — folded into the FS-barrier work where the allowlist lives).

## STATUS: Wave G 5/7 done + green (G4, G1a, G2, G5, G6). Remaining: G3 (carriage/keystone), G1c (FS barrier).

## G3 — keystone reverse-coverage (#5) — DONE conservatively (uncommitted)
- Added tools/keystone.py reverse_coverage() + `reverse-coverage` subcommand: classifies every BLOCK rule
  as fail_closed (12: crucible BLOCK + 3 merge-carried verify) / hook_enforced (1: r9 via PreToolUse) /
  response_gate_advisory (12: gate un-sendable output, cannot be fail-closed by design — finding #7) /
  accepted_static_gap (8: lint/audit-only BLOCK rules) / unexpected_gaps (0). Exit 1 only on UNEXPECTED gaps.
- Test: tests/test_keystone_reverse_coverage.py — pins the accepted set + proves a NEW unguarded BLOCK rule
  is caught (synthetic-rule injection). Locks the gap so it cannot grow silently.
- CONSERVATIVE SCOPE (owner: "more conservative"): did NOT unilaterally (a) flip the 8 static rules'
  lint/audit controls to crucible-BLOCK, nor (b) change verify.py cmd_merge clone-gate to fail-closed —
  both broadly affect CI (would red clean merges). Tracked as OWNER DECISIONS below.

## OWNER DECISIONS surfaced by G3 (not actioned — need sign-off):
- D1: promote the 8 static BLOCK rules (r_cognition_language, r_fail_format, r_identity_lock,
  r_inference_mode_lock, r_neuron_role, r_override_attempt, r_phase_tracked, r_reservoir_output) to a
  crucible BLOCK control, OR reclassify them. Currently lint/audit WARN-only.
- D2: clone fail-closed for cmd_merge — must distinguish "no active project" (legit-empty, allow) from
  "state suppressed" (block) or every clean CI merge false-blocks.

## TEST BAR (broad sweep, 2026-06-19): 185 passed, 0 failed
  axon_path_unified · enforce_bash_gate · session_runid_rotation · keystone_reverse_coverage · keystone
  · shell_sandbox · r9_axon_write · axon_io_r9 · axon_io_lint · enforce_root_anchor · session_recovery_token
  · lint_commit_trailer · crucible_verify_carriage · compile_write_traversal · r_terminal_outputs → ALL GREEN

## STATUS: Wave G 6/7 done + green (G4 G1a G2 G3 G5 G6). Remaining: G1c (kernel FS write-barrier) — owner-gated.

## G1c — kernel FS write-barrier (#1 computed-path residual) — DEFERRED (owner decision 2026-06-19)
- Owner: defer as a separate, carefully-reviewed iteration. Wave G closes at 6/7.
- Rationale: G1a blocks every LITERAL interpreter/redirect/nested-shell vector (green); the residual is
  a runtime-COMPUTED path (e.g. python3 -c "p='ax'+'on/...'; open(p,'w')") with dev-mode OFF — real but
  requires deliberate evasion. The OS chmod barrier is the highest-blast-radius change in the repo and
  earns its own reviewed change. Tracked in ADR-004 as the accepted residual + the G1c follow-up.

## WAVE G FINAL: 6/7 shipped + green (G4 G1a G2 G3 G5 G6). G1c deferred. 185 tests passing.
## Next: full crucible gate -> commit on a branch (AXON trailer) -> confirm before push.

## WAVE G LANDED (branch) — 2026-06-19
- commit 6ce9bd8 on fix/wave-g-residual-hardening (13 files, +521/-41). Pre-commit hooks green
  (hardcoded-paths, AXON-trailer). Full crucible gate: passed (33 controls, 0 blocking; 2 pre-existing WARNs).
- PUSHED to origin (ci.tno.nl artur.castiel-tno/axon). MR not yet opened (owner can create at GitLab URL).
- NOT merged to main. G1c deferred (ADR-004). G3 owner-decisions D1/D2 still open.
- Test bar at landing: 185 targeted tests green.

## PHASE-2 COUNCIL FLEET — COMPLETE (resume, 2026-06-19)
- 8 full-form councils (4 seats each) + synthesis handoff. First run hit the session usage limit;
  resumed after reset → all reports written. 41 agents, ~2.1M tokens, 689 tool-uses.
- Saved to reports/: menu, architecture, state-machine-compliance, naming, job-audit, state-machine-dag,
  non-compliance-gaps, drift-root-cause, + 00-AXON-report-state-handoff.md (capstone, sent to owner).
- HEADLINE: AXON is a strong, self-honest architecture shipped DISARMED (0 L:*-required flags) with blind
  instruments. NEW concrete bug found: Core Rule 13 test-gate fails OPEN in CI (crucible.py:131 missing
  2>/dev/null vs :155) — same "gates fail open" family as the arch-audit. Drift verdict: ~60% arch /
  30% config / 10% model, but model share unfalsifiable until the drift detector is instrumented (Tier-0).
- Handoff backlog = candidate scope for a follow-on project (flip flags, fix CR-13 resolver, instrument drift).

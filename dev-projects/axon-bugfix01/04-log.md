# Implementation Log — AXON Bugfix 01

## SESSION START — 2026-07-01T09:37:24.758325Z
project:        axon-bugfix01
phase:          study
workflow-step:  build
branch:         main

## Entries

## 2026-07-03T12:35:48+00:00 · PR-001 implemented (branch pr-001-destructive-git-gate, commit 440c529)
- shell.py: destructive-git classifier (_git_parse/_classify_destructive_git), grant consultation
  via autonomous_mode.authorized() (first production caller), fail-closed repo-slug resolution;
  kernel floor for unattended runs (_kernel_floor_paths/_unattended_run_active, code kernel-floor).
- enforce_pretooluse.py: forwards destructive-git + kernel-floor codes on Bash; kernel_floor_block()
  arm for Write/Edit; codes limited to _BASH_ENFORCED_CODES (hard-forbidden deliberately NOT broadened).
- tests/test_shell_destructive_git.py: 41 tests (classifier matrix, grant wiring, scope mismatch,
  unresolvable repo, kernel floor attended vs unattended).
- Deviations from spec: none functional. F21 lesson — no per-file sys.path bootstraps in tools/
  (test_no_sys_path_bootstrap enforces); plain lazy import works in both script + hook contexts.
- Fallout fixed: canonical DOC-INDEX export was stale → regenerated (doc_index.py export --canonical).
- Full suite: 4947 passed / 0 failed / 16 skipped (was 3 failed pre-fix, all mine).
- Baseline note: pre-edit clean-main baseline was not captured (two concurrent gate runs raced;
  orphan killed); branch green + green-only merge gate covers the merge decision.

- MERGED: squash to main as 1b63f84, pushed to origin. Crucible gate green (33 controls). Grant checks: commit/merge-squash/push all authorized (audited).
- Live proof: git commit --amend on the branch was BLOCKED by the new gate itself (destructive-git, amend) — used a follow-up commit instead.

## PR-002 implemented + MERGED (476e5d1)
- test_runner.py: _actor (env/flag), _cached_gate_green (crucible-last.json, <24h, fail-closed),
  _aegis_refusal (aegis_policy.resolve over _policy.md x live grant), exit 3 refusal envelope,
  --actor flag. Human runs never gated.
- tests/test_test_runner_policy.py: 12 tests. Full suite 4958/0/16. Crucible gate green (33 controls).
- Live check: agent-invoked run correctly ALLOWED under active grant + fresh green verdict.

## PR-003 implemented + MERGED (74bede2)
- synapse_suggest.py: programs-corpus default fallback (_load_candidates_from_programs, merged
  with dispatch-index descriptions), --corpus flag, degraded-fallback labeling, docstring honesty,
  absolute confidence (raw / additive mass) replacing raw/max_raw.
- Scope addition (same defect class, logged as deviation): anticipate.py also ranked the TOOLS
  corpus + its SUGGEST_MARGIN was calibrated to the old always-1.0 scale — corpus switched to
  programs, margin 0.20 -> 0.05 (absolute scale), test guard refined (literal '+' in program
  descriptions is legit; the guard now matches the signal-weight pattern only).
- 4 orchestrator replay fixtures recalibrated: honest-weak inputs now expect decision 'ask' at
  inference-mode 5 (they only expected 'fire' because top-1 was pinned at 1.0).
- Live repro fixed: 'run the code review workflow' -> code-dev-review-correctness @ 0.118 (was lint-code @ 1.0).
- Tests: 19 new in test_synapse_suggest_corpus.py. Full suite 4967/0/16. Crucible green (33 controls).

## PR-004 implemented + MERGED (c56bd89) — WAVE A COMPLETE
- orchestrator.md: fire branch rewritten (direct EXEC of the ranked program file; dispatch-match
  fallback on the tool's REAL contract; loud fire->ask downgrade + fire-failed telemetry);
  FL-05 zero-candidate fallback flag drift fixed; both rank call sites pin --corpus programs.
- program_tool_conformance.py: orchestrator.md added to SCOPE_GLOBS (regression trap) — the
  newly-scoped lint immediately caught the second flag-drift call site (validation of the trap).
- emit_listener_lint.py: fire-failed whitelisted (telemetry, triage note per whitelist policy).
- tests: test_orchestrator_fire_conformance.py (6 tests: scope pin, real-contract pin, EXEC-path
  pin, no-silent-noop pin, corpus pin); partition test extended.
- EXEC-ref lesson: structural validator requires template form EXEC({var}), not EXEC(var).
- Full suite 4973/0/16. Crucible green (33 controls).

## PR-005 implemented + MERGED (ecf4861) — Wave B begun
- predicate.py: 8 new fail-closed builtins + BUILTIN_ALIASES (16 entries incl. all_prs_implemented
  -> prs.all-implemented, found by the new trap test — a 5th unregistered predicate the audit missed);
  alias resolution at Call-eval; uniform CLI envelope (error/message always present, null on success).
- 4 canonical YAMLs renamed to registered vocabulary (mechanical).
- workflow-run.md: gate ERRORS now halt loudly with the failing expressions (FAIL block);
  all-gates-false remains a legal terminal.
- output_manifest.json: predicate.eval grown to [result, error, message] (accessor contract).
- Chain lesson: conformance-lint accessor checks + manifest tripwires forced the uniform envelope —
  three mechanical guards composed correctly (trap caught vocab, lint caught accessor, tripwire pinned emission).
- Tests: 35 new. Full suite 5018/0/16. Crucible green (33 controls).

## PR-006 implemented + MERGED — C1 fully closed (both halves)
- workflow_run.py: build_gate_ctx (pure, fail-soft) + `ctx` CLI subcommand; canonical state
  sources documented in-code; domains mirrored under ctx.state (ref-scope reality); hyphenated
  state keys auto-aliased to underscores (hyphen-lexes-as-subtraction reality).
- workflow-run.md: in-loop ctx AND post-loop acceptance final-ctx (same defect, found via a
  test anchor) now use the builder; history merged interpreted-side.
- YAML refs: audit.open-findings -> audit.open_findings (12 sites, 4 files).
- Tests: 8 in test_workflow_gate_ctx.py incl. the C1 end-to-end close-out (canonical step-4
  gates evaluate correctly against real state, objection round-trip included).
- Full suite 5025/0/16. Crucible green.

## PR-007 + PR-008 implemented + MERGED jointly — H5 + C4 closed
- validate runs check-stale + check-templating (target-scoped, severity-mapped).
- check_stale: tool-not-program finding kind; narrow runtime-backed role:orchestrator exemption.
- workflow-run.md: role:orchestrator = rank-then-fire node type (programs corpus, loud fallback).
- adaptive-free-text.yml: s2 hardcode removed, s1 self-loop, s3 -> session-summary (was dead code-dev-finalize).
- SEQUENCING LESSON: a lint PR is not independently mergeable under green-only if the repo still
  contains the bug it detects — the gate control forced the joint landing (logged as deviation).
- Full suite 5030/0/16. Crucible green incl. workflow-check-stale control. Repo lints: 0 findings.

## PR-009 implemented + MERGED — C8 closed
- library-dev.canonical.yml v2: 6 synapses, all library-dev-* (new->ingest->explain->intersect->
  report->status); iterative back-edge s4->s2 gated on W.library_needs_more (writer wired in
  library-dev-intersect.md from the coverage map — real state, not an invented predicate).
- _index.md corrected. Domain-purity pin in test_library_dev_workflow.py (C8 trap).
- Reference-invariant lesson: canonical workflows must declare >=1 runtime-bounded cycle
  (test_workflow_suite pin) — satisfied honestly rather than waived.
- Obsolete pin scope fixed (test_workflow_stale_neurons listed the file only as the copy-paste).
- Full suite 5033/0/16. Crucible green.

## PR-010 implemented + MERGED — WAVE B COMPLETE (H4 closed via ADR-001)
- ADR-001: hybrid descoped; adaptive = 4 real mechanisms; synthesized-node continuation REJECTED
  (rigid-traversal discipline). Authoring surfaces fixed/adaptive only; runtime WARN-downgrade.
- menu + compiled menu regenerated (lossless staleness gate exercised and satisfied).
- Full suite 5037/0/16. Crucible green.
- WAVE B: PR-005..010 all merged. C1, C4, C8, H4, H5 closed.

## PR-011 implemented + MERGED — C6/C7/M7/M8/H19 closed (the L-sized router root-cause fix)
- Generic two-token resolution collapsed the expected L into ~M effort (no split needed).
- Explicit tokenizer bridges in both routers; 9 umbrella/chats single-token entries.
- Compiled code-dev.cmp.md regenerated: functional lines inserted + TOC rebuilt to fixpoint
  (lossless mandate exercised twice this wave — the mechanical gates work).
- Full suite 5067/0/16. Crucible green.

## PR-015 + PR-016 implemented + MERGED (pulled forward from Wave D on owner order)
- Owner order executed: kernel modifications (KERNEL-SLIM scheduler section, SCHEDULER.md
  rewrite, both QUEUE.md copies) — authorization logged; kernel v1.1.8 -> v1.1.9; F50
  content-hash lock fired on the edit exactly as designed and was updated per its protocol.
- queue_tool.py: in_progress/requeue (non-lossy pop), dep-eligibility at pop, clear scopes.
- ADR-002 accepted (preemption descope). Tests: 8 queue + 4 doc-honesty + relocked F50.
- Full suite 5079/0/16. Crucible green. C10 FULLY CLOSED (both halves).

## CORRECTION + final truth for PR-015/PR-016
- The prior 'MERGED' entry was premature: the checkout to main had ABORTED (regenerated
  AXON-DOCS.md blocked it) and the push was a no-op — the commits lived only on the branch.
- During recovery, a real miss surfaced: the ctx-fix's underscore renames to the 3 code-dev
  YAMLs were never staged (main carried the subtraction-lexing refs), and rejection-criteria
  had the same class unfixed (audit.critical-issues — critical findings could never trip
  rejection). Completed + pinned (gate-expression hyphen-ref scan test).
- TRUE merge: e401b50 on main, pushed to origin. LESSON: verify `git log main` shows the
  merge commit BEFORE writing 'merged' anywhere — checkout aborts fail the whole chain.

## PR-012 implemented + MERGED a4a3c50 (verified on main) — C5 closed
- check-structure → code-dev-safety-audit-structure (source + compiled); orphan key gone.
- Stale reduce-surface pin had encoded the buggy route as expected — corrected with note.
- Recurring-class note: post-gate AXON-DOCS regeneration blocks checkout — protocol now
  commits regenerated docs on the branch BEFORE checkout, and verifies the merge hash on main.

## PR-013 implemented + MERGED 788f512 (verified) — WAVE C COMPLETE; H8/H9/H10/H11/H12 closed
- Stub deletion ripple handled: freshness refresh auto-healed 6 registries/counts; dangling
  synapse edges + tour cross-refs fixed by hand; COMMANDS.md count auto-updated 172->170.
- 15/30 PRs merged — halfway by count. Waves A, B, C complete + D 2/5.

## PR-017 implemented + MERGED (verified) — C11 closed
- done --force precedes staling (order pinned); audit sandbox repro replayed both ways in tests.
- 16/30. Wave D 3/5 (PR-014, PR-018 remain).

## PR-018 implemented + MERGED (verified) — C12 + M14 closed (ADR-003)
- 17/30. Wave D 4/5 — PR-014 (L: unification) closes the wave.

## PR-014 implemented + MERGED (verified) — C9 closed (ADR-004) — WAVE D COMPLETE
- 18/30. All CRITICAL-class findings in waves A-D now closed. Next: Wave E (hr-team).

## PR-019 implemented + MERGED (verified) — C2 + M1 closed
- 19/30. Wave E 1/3 — PR-020 (filters/weights), PR-021 (deliberation flow) remain.

## PR-020 implemented + MERGED (verified) — C3 + H2 closed
- 20/30. Wave E 2/3 — PR-021 (deliberation flow + LOW sweep) closes the wave.

## PR-021 implemented + MERGED (verified) — WAVE E COMPLETE (H3, M2, M3 + 5 hr-team LOWs closed)
- Contract lesson: a LOW's 'vestigial check' had a pinned 7-refusal contract behind it — the fix
  was the undefined TERM, not deletion (the convener-router pin caught the over-removal).
- 21/30. ALL hr-team findings closed. Next: Wave F (C13 simulate, H15/H16, H17/H18/M15).

## PR-022 implemented + MERGED (verified) — C13 closed
- 22/30. Wave F 1/3 — PR-023 (quickstart+run-tests), PR-024 (library-dev trio) remain.

## PR-023 implemented + MERGED (verified) — H15 + H16 closed
- 23/30. Wave F 2/3 — PR-024 (library-dev trio) closes the wave.

## PR-024 implemented + MERGED (verified) — WAVE F COMPLETE (H17, H18, M15 closed)
- 24/30. Next: Wave G (PR-025 cron, PR-026 dispatch-index, PR-027 misc), then Wave H.

## PR-025 implemented + MERGED (verified) — H6/H7/H13/H14 closed
- Second pin-captured-the-bug case this project (cron conformance expected the bare name).
- 25/30. Wave G 1/3.

## PR-026 implemented + MERGED (verified) — H20 closed (+7 rotted status headers repaired)
- Chain lesson REPEATED: tail-truncation hid a trailer-hook rejection (internal PR-N ref in the
  message body) — two failed commit attempts before surfacing the hook output. Protocol: never
  truncate commit output; grep -v the INFO noise instead.
- 26/30. Wave G 2/3 — PR-027 (misc sweep) closes the wave.

## PR-027 implemented + MERGED (verified) — WAVE G COMPLETE (H22-H26, M5 closed)
- 27/30. Wave H remains: PR-028 (liveness lint), PR-029 (EXEC-args lint + H1), PR-030 (doc honesty).

## PR-028 implemented + MERGED (verified) — pattern-7 guard live (34th crucible control)
- First run found 4 previously-unknown dead tools (quarantined). 28/30.

## PR-029 implemented + MERGED (verified) — H1 closed; 35th crucible control (BLOCK)
- 29/30. PR-030 (doc honesty + pre-authorized kernel line) closes the backlog.

## PROJECT COMPLETE — 2026-07-07
- PR-030 merged b525071 (kernel v1.1.10, owner-ordered lines executed). 30/30 PRs.
- Phase 5 audit written (05-audit.md); manifest: study/plan/pr/log/audit ALL DONE.
- Suite 4944 → 5172 (+228). Crucible 33 → 35 controls. 2 S-CRIT + 13 CRIT + 26 HIGH closed.
- Open items live in the OWNER QUEUE section of 05-audit.md.

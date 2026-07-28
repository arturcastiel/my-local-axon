# PR list — axon-bugfree10

31 PRs · 91 confirmed bugs · execution order below. ⚠KF = kernel-advisory (axon/*, human-only floor).

## PR-01 — shell.py R9 write-gate: fix kernel anchor, redirect regex, and cd-cwd rebasing
- **risk/effort:** high / M  ·  **subsystem:** kernel-gate-runtime-security
- **bugs (3):** B001, B031, B032
- **depends_on:** —
- **rationale:** The single most security-critical file, all three fail-open holes in the R9 axon-write classifier. B001: _is_axon_path passes `workspace` (=<repo>/workspace) as the anchor so is_axon_path checks the non-existent <repo>/workspace/axon, letting absolute and ../axon kernel writes go unrecognized; B031 misses `word>file` redirects with no leading space; B032 never rebases path resolution after a stripped `cd`. Same file, same gate, must co-land and land first. DESIGN CONSTRAINT: the fix must mirror _axon_io.py's AXON_DIR.parent (real kernel-root) anchoring — the one consolidated consumer that got it right — not invent a third anchor derivation, so the three _axon_paths.is_axon_path consumers (shell.py, r9_axon_write.py, _axon_io.py) do not drift.
- **test strategy:** tests/tools/test_shell_gate.py — BLOCK each of: `echo x > /abs/repo/axon/KERNEL-SLIM.md` (absolute), `echo x > /abs/repo/workspace/../axon/KERNEL-SLIM.md` (traversal, named in B001 summary), a symlink-into-axon write (F-D8-001 vec 1), `echo x>axon/foo.md` (no-space redirect, B031), `cd axon && rm KERNEL-SLIM.md` (cd-rebase, B032). ALLOW: a legitimate workspace write (no over-block) AND a write correctly classified under a tmp/test/federation topology where `workspace` is deliberately a distinct root (re-anchoring must not break those). CALLER AUDIT (mandatory pre-merge, not a code change here unless a defect is found): confirm tools/hooks/enforce_pretooluse.py (which calls shell._is_axon_path(tgt, shell._default_workspace()) on the highest-traffic PreToolUse path) and tools/rules/r9_axon_write.py (anchors on ctx['workspace_root']) resolve to the SAME real kernel root after this fix; if either still supplies <repo>/workspace or cwd, it carries the identical B001 defect and must be co-changed in this PR.
- **dissent:** Challenger lens wanted B001 split into its own minimal-diff PR ahead of B031/B032 to isolate the crown-jewel anchor fix. Overruled: security, architecture and release-sequencing lenses all hold that three bugs in one file behind one gate must co-land for a clean revert unit and a single reviewed trust boundary.

## PR-06 — Green-gate integrity: test_runner returncode-aware verdict + quality_loop HMAC ramp
- **risk/effort:** medium / M  ·  **subsystem:** tools-quality-gates
- **bugs (2):** B033, B025
- **depends_on:** —
- **rationale:** Moved to slot 2 as the release's VERIFICATION SUBSTRATE. B033: test_runner computes PASS from failed==0 while ignoring pytest collection/import errors and returncode, so any downstream PR whose new test errors at collection reads green — every 'passes-after' claim in this release is only trustworthy once this is returncode-aware. B025: ramp_record discards the integrity_ok flag then re-signs, laundering tampered clean-cycle state past the HMAC ramp gate. Both let a broken/forged state read green and gate autonomy.
- **test strategy:** B033: invoke test_runner directly against a fixture suite that ERRORS on collection (not merely fails) and assert on the returned dict that verdict != PASS — assert on the tool's output object, NOT through the green-gate it is fixing (avoid the self-referential runner). B025: hand-edit a ramp state file, call ramp_record, assert it is REJECTED rather than re-signed clean. Both fail pre-fix.
- **dissent:** Original proposal sequenced this 8th (grouped as a mid-plan quality gate). All four sequencing/test lenses (test-strategy, release-sequencing, dependency-dag, challenger) converged that it must be second, immediately after PR-01, because it certifies the pass/fail oracle for the whole release.

## PR-04 — Doctrine gates: fail-closed integrity, delimited receipt match, relative-path crash
- **risk/effort:** medium / M  ·  **subsystem:** doctrine
- **bugs (3):** B017, B018, B019
- **depends_on:** —
- **rationale:** doctrine_arming + doctrine_preflight trust boundary. B019 is a fail-OPEN integrity gate (reports 'blessed' for untracked routines) — must be fail-closed; B017 matches receipts by undelimited `run {id}` substring so a prefix-sibling (r1 vs r10) borrows receipts; B018 crashes (uncaught ValueError) on a relative routine path under ROOT.
- **test strategy:** tests/tools/test_doctrine.py: B019 assert preflight on an untracked routine returns ok:false (not 'blessed'); B017 assert run `r1` cannot satisfy receipts committed by `r10`; B018 run preflight with a relative path from inside ROOT and assert a clean error envelope instead of a traceback. Each fails pre-fix.

## PR-28 — config.md autonomy fail-open: attended capability-grant branch never fires
- **risk/effort:** medium / S  ·  **subsystem:** programs-security-gate
- **bugs (1):** B047
- **depends_on:** —
- **rationale:** EXTRACTED from PR-20 and promoted to Wave 1. B047 is a capability-grant fail-open: the config wizard matches the autonomy selection with ≡ against short labels while W:_decision holds the full string, so the attended branch never fires and capabilities are granted unattended. The original proposal's own rationale flagged it 'leads as a gate-bypass' yet buried it 20th among cosmetic interpolation bugs — a contradiction four lenses (security, architecture, effort, challenger) called out. A capability fail-open belongs with the other gate fixes.
- **test strategy:** Select the attended autonomy option and assert capabilities are NOT auto-granted (the attended branch fires and prompts). Add a control where the unattended option IS selected and grant proceeds. Fails pre-fix.

## PR-02 — Rule linters: strip comments/quotes before EXEC/STORE/phase-ledger scans (shared helper)
- **risk/effort:** medium / M  ·  **subsystem:** rules-linters
- **bugs (3):** B026, B027, B028
- **depends_on:** —
- **rationale:** Shared root cause across r_identity_lock and r_phase_tracked: regexes run against raw program text with no comment/doc-section/quote stripping. B026 false-positives on an EXEC in a comment; B027 fail-opens when the only active-program STORE is inside a comment/example; B028 fail-opens when the only phase-ledger call is a comment mention. This PR introduces ONE reusable comment/quote-stripping helper in the tools layer that PR-05 (B072) also consumes, so the codebase converges on a single source of truth for that predicate rather than several divergent strip implementations.
- **test strategy:** tests/rules/test_comment_stripping.py: feed a program with EXEC/STORE(W:active-program)/phase-ledger tokens present ONLY in `#` comments or ## HELP examples — assert no violation for the false-positive case (B026) and a violation IS raised for the fail-open cases (B027/B028). Add a real-token control that must still flag correctly. Assert the helper is importable/shared (contract test) so PR-05 can reuse it.

## PR-05 — Lint/dep/conformance gates: close substring & regex fail-opens (reuse strip helper)
- **risk/effort:** medium / M  ·  **subsystem:** tools-lint-gates
- **bugs (4):** B067, B068, B070, B072
- **depends_on:** PR-02
- **rationale:** Four fail-open (or dead) static gates sharing the 'naive matching lets bad input through' pattern: B067 axon_io_lint _OPEN_RE only captures the first quoted string so raw writes with a literal path evade R9 (defense-in-depth sibling of PR-01/PR-22); B070 deps.py skips markdown table rows dropping real EXEC deps; B072 harness_conformance uses substring match so a capability key in a comment satisfies it — this fix CONSUMES PR-02's comment/quote-stripping helper rather than re-implementing it; B068 coherence_lint C3 branch is dead (never-falsy return).
- **test strategy:** B067 assert open('/path','w') detected; B070 assert a table-routed EXEC dep is reported missing when its target is absent; B072 assert a commented-only STORE(L:cap) does NOT satisfy the gate (via the shared helper); B068 — DROP the 'or removed' disjunction: craft an input that reaches the unclassified C3 return and assert it is emitted (a real pre-fix red), then fix the never-falsy return. Each fails pre-fix.
- **dissent:** Test-strategy lens objected to B068's original 'assert reachable OR removed with rationale' escape-hatch oracle (a dead-code bug ships with no failing test). Resolved by mandating a falsifiable reachability assertion. Architecture/dependency lenses' soft edge PR-05→PR-02 is now encoded as a hard depends_on so the shared helper lands first.

## PR-03 — Rule linters: regex/parse correctness (arithmetic, dont-do, mode-lock, receipts)
- **risk/effort:** medium / M  ·  **subsystem:** rules-linters
- **bugs (4):** B078, B079, B080, B081
- **depends_on:** —
- **rationale:** Four independent regex/parser defects in tools/rules/*, same fix pattern (tighten the matcher): B078 ARITH_RE fails open on %/currency; B079 parse_dont_do doesn't reset `cur` on a struck bullet so it clobbers the prior prohibition; B080 _STORE_RE \b over-matches L:inference-mode-locked; B081 _CLAIM_RE captures non-tool subcommands like `help` causing a false BLOCK. B081 co-governs the R_TOOL_RECEIPTS canonical-name boundary with B051 (PR-29) and B029 (PR-10) — reviewed as a consistency set.
- **test strategy:** B078 assert BLOCK on `12% of 3.4` and `$5 + $6`; B079 assert a ~~struck~~ bullet does not overwrite the preceding active token; B080 assert STORE(L:inference-mode-locked,...) does NOT satisfy the inference-mode declaration; B081 assert `axon.py help` is not treated as a receiptable tool claim AND that a canonical-name claim recorded by B051's fix IS still captured by the tightened _CLAIM_RE. Each fails pre-fix.

## PR-07 — Trace gates: dag conditional edges, drift TTL stability, pr_drift anchor casing
- **risk/effort:** medium / M  ·  **subsystem:** tools-trace-gates
- **bugs (3):** B016, B020, B024
- **depends_on:** —
- **rationale:** Three trace/consistency gate logic bugs: B016 dag_consistency never validates next-conditional edges so dangling conditionals pass the fail-closed gate; B020 drift flips a no-program trace from stable to diverged after one tool, re-introducing the auto-improve halt (historically fragile — prior 'drift deadlock'); B024 pr_drift lowercases the token before the CamelCase anchor regex, permanently defeating that branch.
- **test strategy:** B016 add a dangling next-conditional edge, assert the gate now BLOCKS; B020 record one tool on a no-program trace and assert status stays stable until TTL; B024 assert a CamelCase-only acceptance token classifies as anchored. Each fails pre-fix. MERGE GATE (regression lens): B020 alters drift.py's classify contract consumed by the fail-closed r_drift_gate + auto_improve halt; run the FULL existing drift corpus (test_drift_fail_closed, test_drift_falsification, test_programs_drift, test_drift_kernel_interface) as a merge gate, not just the one new assertion.
- **dissent:** Regression-blast-radius lens wanted B020 split into its own drift.py PR because it ripples into an autonomy gate. Kept bundled (same trace-gate surface, disjoint files) but its higher blast radius is mitigated by mandating the full drift corpus as a merge gate rather than the single new assertion.

## PR-17 — Program dry-run & control-flow safety: combine/merge/workflow-run
- **risk/effort:** medium / M  ·  **subsystem:** programs-control-flow
- **bugs (4):** B002, B003, B004, B036
- **depends_on:** PR-01, PR-06
- **rationale:** Highest-priority program-layer bugs: dry-run guards and terminators that mis-scope side effects. B002 undo-completion code is stranded after a DONE inside the dry-run guard (dead) and falls through into full combine; B036 (same file, code-dev-combine.md — co-lands with B002) places the C8 dry-run guard AFTER the mutating RESTORE-DIR so --undo overwrites phases/ even when armed; B003 merge nests all real side effects inside the dry-run branch and mis-binds the ELSE; B004 workflow-run's PROMOTE DONE is dedented to column 0 (unconditional).
- **test strategy:** HONEST SCOPE (test-strategy lens): tools/simulate.py does NOT model IF/ELSE/DONE/guard nesting, so these are verified as STATIC structural/indentation assertions over the .md (the established test_workflow_termination / test_kernel_floor_pr021 pattern) — they prove the text shape changed, not runtime branch behavior. B002 assert the undo-completion block sits before DONE and is reachable; B036 assert the C8 guard textually precedes RESTORE-DIR; B003 assert side-effect ops are outside the dry-run branch; B004 assert DONE(workflow-run) is indented under the promote-run guard. Each fails pre-fix.
- **dissent:** Test-strategy lens flagged that the original 'compile+trace / axon dry-run harness' oracle does not exist (simulate.py has no branch-scope evaluation). Reframed to static-structural assertions with the weakness acknowledged, rather than blocking the wave on a mythical harness. Depends_on PR-01 (kernel-write gate sound before program mutations) and PR-06 (returncode-aware verdict) encode the two release-gating prerequisites.

## PR-22 — ADVISORY (kernel floor): gate fail-opens in dry_run_lint & write_barrier — OWNER ESCALATION
- **risk/effort:** low / S  ·  **subsystem:** kernel-advisory-gates · ⚠ KERNEL-ADVISORY (findings-only, owner escalation)
- **bugs (3):** B009, B010, B013
- **depends_on:** —
- **rationale:** Findings-only advisory — axon/* is a HUMAN-ONLY kernel floor, no autofix. Surfaced in Wave 1 because these are LIVE gate holes that ship UNFIXED this release: B009 dry_run_lint _MUTATING_OP is line-start-anchored so an inline `→ WRITE(...)` mutator evades the merge gate; B010 _GUARD.search matches the dry-run token inside a `#` comment so a removed real guard still passes; B013 write_barrier lets os.open() writes/truncations through on the UNATTENDED autonomous path because the 'open' audit event carries mode=None and _hook treats it as a read. Per the owner-gates-kernel-edits memory these must be ESCALATED to the owner for a same-cycle manual patch (dev-mode + full-test), not merely surfaced — while they remain open, PR-01/B001 is the only automated kernel-write guardrail during Waves 2-3.
- **test strategy:** Advisory — LANDED failing-before tests in tests/ (exercising a kernel tool from outside axon/* is NOT a floor edit; precedent: test_kernel_floor_pr021): a program with an inline `→ WRITE` mutator and a comment-only guard must be BLOCKED by dry_run_lint; an os.open(path,O_WRONLY|O_TRUNC) into a protected subtree must be BLOCKED by write_barrier. Tests flip green when the human applies the fix. No axon/* source edit lands here.
- **dissent:** Original proposal specified 'no code change, proposed human-run test.' Test-strategy lens (and precedent) established that regression tests live in tests/ outside the floor, so these advisory bugs should carry LANDED failing-before tests rather than un-landed proposals. Adopted.

## PR-08 — Receipt & ledger integrity: canonical checksum + GC re-chain
- **risk/effort:** medium / M  ·  **subsystem:** tools-receipts
- **bugs (2):** B023, B075
- **depends_on:** PR-06
- **rationale:** Both in tools/loop_receipt.py — a single cohesive surface (B051/axon.py extracted to PR-29 per architecture lens). B023 _canonical_checksum re-serializes str values so verify never matches file/jsonl targets; B075 cmd_gc rewrites the ledger without re-chaining prev-sha so verify_chain reports a false tamper break.
- **test strategy:** B023 write then verify a file-target receipt (fixture: a jsonl+file-target receipt pair), assert it matches; B075 gc a middle entry of a multi-entry chained ledger then verify_chain, assert no false tamper. Each fails pre-fix.

## PR-29 — axon.py: record canonical registry tool name in receipts
- **risk/effort:** low / S  ·  **subsystem:** tools-receipts
- **bugs (1):** B051
- **depends_on:** PR-03
- **rationale:** EXTRACTED from PR-08 per architecture lens: axon.py is the top-level dispatcher (high blast radius), a distinct surface from tools/loop_receipt.py, and should not share a revert unit with a leaf receipts tool. B051 records the typed alias instead of the canonical registry name so R_TOOL_RECEIPTS mismatches canonical-name claims. Depends on PR-03 (B081) so the record side (canonical name) and the tightened _CLAIM_RE claim-capture side are made consistent together.
- **test strategy:** Invoke a tool via an alias and assert the receipt records its canonical registry name, and that a claim referencing the canonical name matches under the PR-03 _CLAIM_RE. Fails pre-fix.

## PR-09 — workflow_run.py: exclude draft workflows, honor boolean-true if:
- **risk/effort:** low / S  ·  **subsystem:** tools-workflow
- **bugs (2):** B082, B083
- **depends_on:** —
- **rationale:** Two resolve/loading bugs in one file: B082 enumerates promoted .draft.yml files (documented never-auto-activated) so a draft shadows the active workflow of the same name; B083 resolve_next silently drops a rule whose if: is unquoted YAML boolean true, inverting its semantics.
- **test strategy:** B082 install an active workflow and a same-name .draft.yml, assert resolution picks the active one; B083 author a rule with `if: true` and assert the rule fires. Both fail pre-fix.

## PR-10 — Tool health/conformance/registry resolution fixes
- **risk/effort:** low / S  ·  **subsystem:** tools-health-conformance
- **bugs (3):** B021, B029, B089
- **depends_on:** PR-03
- **rationale:** Registry/subcommand resolution and health probing: B021 probe_smoke returns ACTIVE even when --help exits non-zero/times out; B029 r_tool_call_exists resolves the script by name not the REGISTRY 'script' field so aliased tools skip subcommand checks; B089 program_tool_conformance mistakes an option's {json,text} choices for the subcommand set, false-blocking subparser-less tools. B029 co-governs the R_TOOL_RECEIPTS canonical-name boundary with B081 (PR-03) and B051 (PR-29); depends_on PR-03 to keep that boundary consistent.
- **test strategy:** B021 point probe_smoke at a tool whose --help exits 1, assert status != ACTIVE; B029 give a tool whose registry name != script filename and assert its subcommands are checked; B089 lint a subparser-less tool with only `--format {json,text}` and assert no unknown-subcommand violation. Each fails pre-fix.

## PR-11 — State stores: kv_store null value + memory L: rollback history
- **risk/effort:** low / S  ·  **subsystem:** tools-state-store
- **bugs (2):** B074, B076
- **depends_on:** —
- **rationale:** Two state-store correctness bugs: B074 kv_store get reports a legitimately-stored JSON null as not-found (contradicts exists); B076 memory L: rollback can only ever reach the single most-recent prior value, so repeated rollback oscillates instead of walking history. NOTE (challenger coupling): the advisory B012 (PR-24, self_care health score via a kv L: key kv_store refuses) assumes kv_store key-acceptance semantics; B074's fix and B012's finding must agree on how L: keys/null are handled.
- **test strategy:** B074 store null, assert get returns it as present (matching exists=true); B076 store three successive values then rollback twice and assert it walks back two steps rather than oscillating. Both fail pre-fix.

## PR-13 — Data-integrity: table-row corruption, rollback eviction ordering, obsidian counts
- **risk/effort:** medium / M  ·  **subsystem:** tools-data-integrity
- **bugs (3):** B073, B015, B077
- **depends_on:** PR-06
- **rationale:** Three ordering/output bugs that corrupt or misreport persisted data (independent files; reviewed per-hunk): B073 index.append_table_row concatenates the new row onto the following ## SECTION line and injects a blank line; B015 restore() takes the FIFO-capped self-snapshot (evicting the oldest) BEFORE reading the chosen snapshot bytes, deleting `chosen` then crashing; B077 obsidian export_fresh's unchanged fast-path reports raw-graph counts instead of the file-note/cross-file-edge counts build_vault produces.
- **test strategy:** B073 append a row to a table immediately followed by a header, assert the header survives and the table is well-formed; B015 (fixture: a .rollback dir pre-filled to the FIFO cap with oldest==chosen) restore the oldest snapshot at cap, assert it succeeds with no self-eviction of `chosen`; B077 (fixture: an obsidian vault exported twice) run export_fresh twice and assert identical counts on the unchanged path. Each fails pre-fix.

## PR-14a — CLI arg/boundary hardening: benchmark, tokenizer, context
- **risk/effort:** low / S  ·  **subsystem:** tools-cli-args
- **bugs (4):** B086, B087, B091, B069
- **depends_on:** —
- **rationale:** Pure-CLI half of the original PR-14 (hook + project_refresh split to PR-14b per architecture lens for revert independence). Shared falsy/None/parse pattern: B086 benchmark required-args guard treats a legit 0 as missing; B087 benchmark load_log drops data rows containing 'Date'/'---' substrings; B091 tokenizer treats empty --text as absent and crashes on files=None; B069 context resolve_limit discards an explicit --limit equal to DEFAULT (medium — the one non-cosmetic bug here).
- **test strategy:** B086 pass src_tokens=0 and assert accepted; B087 log a row whose workflow contains 'Date', assert it survives list/stats; B091 --text '' assert clean empty result (no files crash); B069 --limit 128000 assert it wins over host window. Each fails pre-fix.
- **dissent:** Challenger lens argued the low-severity CLI bugs (B086/B087/B091) should be deferred out of a gate-fix release entirely. Overruled: the plan must place all 91 confirmed bugs; they are sunk to Wave 2 with near-trivial isolated tests so they never gate the security wave.

## PR-14b — Hook/refresh boundary: reanchor_store prompt token + project_refresh reconcile report
- **risk/effort:** low / S  ·  **subsystem:** tools-cli-args
- **bugs (2):** B088, B090
- **depends_on:** —
- **rationale:** Split from PR-14 so the reanchor_store HOOK (runtime-active) and project_refresh do not share a revert unit with the pure-CLI trio: B088 reanchor_store no-ops when the prompt is an option-like token; B090 project_refresh cmd_reconcile rebinds res and discards the fix report.
- **test strategy:** B088 prompt '-h' assert the three actions run; B090 assert fix_applied appears in reconcile output. Each fails pre-fix.

## PR-15 — Invocation fidelity: run.py subcommand/args + dispatch threshold persistence
- **risk/effort:** medium / S  ·  **subsystem:** tools-dispatch
- **bugs (2):** B030, B071
- **depends_on:** PR-06
- **rationale:** Two invocation/side-effect bugs: B030 run.py's TOOL branch calls run_script(script) with NO arguments, dropping the captured subcommand/flags and the STORE(...result) target; B071 dispatch auto-tune reports threshold_adjusted even when the re.sub no-ops or the pref file is missing, so the change is never persisted. B030 changes the core AXON-LANG TOOL-line dispatch contract — wide blast radius.
- **test strategy:** B030 issue a TOOL line with a subcommand+flag and a `→ STORE(...)` target, assert the subcommand runs and the result is stored; B071 run auto-tune when the dispatch-confidence line is absent and assert it PERSISTS a new line (single falsifiable post-condition, not the original 'persists OR reports not-adjusted' ambiguous oracle). MERGE GATE (regression lens): run the full program-trace corpus for programs that emit TOOL lines, since B030 alters run_script for every TOOL line, not just the crafted one.
- **dissent:** Test-strategy lens flagged B071's original 'persists a new line OR reports not-adjusted' as a non-deterministic oracle; pinned to the persist post-condition. Regression lens required the broad program-trace corpus as a merge gate for B030's dispatch-contract change.

## PR-16 — Harness plumbing: verify_stop import path + cold_stranger repo_sha
- **risk/effort:** low / S  ·  **subsystem:** harness-benchmark
- **bugs (2):** B022, B066
- **depends_on:** —
- **rationale:** Two harness/provenance plumbing bugs: B022 verify_stop._doctrine_host_mirror imports _axon_paths without adding tools/ to sys.path, so it silently no-ops on the sentinel-governed path and never writes the tamper-evidence mirror; B066 cold_stranger computes repo_sha against a git-archive checkout with no .git so provenance is always 'unknown'.
- **test strategy:** B022 (fixture: a sentinel-governed path with tools/ import context) exercise the sentinel path and assert the host-side mirror file is written; B066 (fixture: a .git-less git-archive checkout) assert repo_sha resolves to a real sha OR a SINGLE documented explicit fallback value (pick one falsifiable post-condition, not an open disjunction). Both fail pre-fix.
- **dissent:** Test-strategy lens flagged B066's 'real sha OR documented fallback' as an ambiguous oracle; the fix must commit to one expected post-condition.

## PR-18a — code-dev dispatch/CASE routing: state actions branch, phase token, safety-freeze state
- **risk/effort:** medium / M  ·  **subsystem:** programs-code-dev
- **bugs (3):** B044, B046, B042
- **depends_on:** PR-01, PR-06
- **rationale:** Dispatch/state half of the split PR-18 (effort/release/challenger lenses converged that 6 medium-risk program traces in one PR is an L, too big for one sitting). B044 missing `actions` CASE branch falls to wildcard-fail; B046 phase dispatch reads unwritten W:code-dev-phase-cmd instead of the parsed token so `phase list` runs phase-new; B042 safety-freeze hardcodes state=frozen so `thaw` re-freezes.
- **test strategy:** STATIC-STRUCTURAL (no branch-scope evaluator in simulate.py): B044 assert an `actions` CASE branch exists in the dispatch; B046 assert the phase dispatch reads the parsed token not W:code-dev-phase-cmd; B042 assert `thaw` sets state to unfrozen (not the hardcoded 'frozen'). Each fails pre-fix. MERGE GATE: for B044/B046 (dispatch routing every code-dev subcommand traverses) assert untouched subcommands still route correctly (structural completeness of the CASE table).

## PR-18b — code-dev guard/seed logic: study escalation, phase-start CONTAINS anchor, plan undefined-var
- **risk/effort:** medium / M  ·  **subsystem:** programs-code-dev
- **bugs (3):** B045, B039, B040
- **depends_on:** PR-01, PR-06
- **rationale:** Guard/seed half of the split PR-18. B045 study's escalation/handoff run unconditionally with a dangling ELSE IF; B039 phase-start CONTAINS uses a regex-anchored '^- ' literal that never matches, re-seeding _dont-do.md; B040 plan STOREs/derefs undefined search-results/arch-findings.
- **test strategy:** STATIC-STRUCTURAL: B045 assert escalation/handoff sits under the outputs-missing guard (no dangling ELSE IF); B039 assert the CONTAINS predicate matches an existing '- ' bullet so an existing _dont-do.md is NOT re-seeded; B040 assert no undefined-var deref (search-results/arch-findings are STOREd before use). Each fails pre-fix.

## PR-19 — code-dev arg/tool/result marshaling fixes
- **risk/effort:** medium / L  ·  **subsystem:** programs-code-dev
- **bugs (5):** B035, B037, B038, B041, B043
- **depends_on:** PR-01, PR-06
- **rationale:** Marshaling errors that silently drop data or crash in code-dev programs (re-labeled L — five distinct program files each needing its own trace, per effort lens): B038 passes '7d' to igap's integer --days (crash); B041 shadow append with unsupported --date flag crashes and loses findings; B043 binds the whole shell envelope without unwrapping .stdout so branch-drift always false-positives; B037 builds the append shadow-path from the relative path while init used the absolute convention, so appends no-op; B035 reads 02-prs.md as a table filtering col5=merged though it is a bullet list.
- **test strategy:** STATIC-STRUCTURAL per program: B038 assert default igap passes an int days value; B041 assert the per-edit shadow append omits the unsupported --date flag; B043 assert {git-branch} dereferences .stdout of the envelope; B037 assert the four appends target the absolute shadow-path init created; B035 assert changelog counts merged PRs from the bullet '- **Status:**' form. Each fails/mis-behaves pre-fix.
- **dissent:** Effort lens re-labeled M→L (five separate program traces). Kept as one PR (cohesive code-dev marshaling surface, disjoint files) but budgeted as a heavy L review; noted as a review-adjacency cluster with PR-18a/b and PR-20.

## PR-20 — Program logic & interpolation: discover/quality-loop/versions/audit/compare
- **risk/effort:** medium / M  ·  **subsystem:** programs-misc
- **bugs (5):** B048, B049, B050, B084, B085
- **depends_on:** PR-06
- **rationale:** B047 (autonomy fail-open) EXTRACTED to PR-28 and promoted to Wave 1, so this PR no longer mixes a trust-boundary fix with cosmetics. Remaining: B048 discover re-inits `issues` discarding the appended dependency issue and references it before init; B049 quality-loop passes undefined findings-json to report; B050 versions reads unwritten W:_versions-target with no W:_arg1 fallback; B084 audit-to-study uses {project.path} on a slug string; B085 axon-compare interpolates never-assigned {coverage-pct}.
- **test strategy:** STATIC-STRUCTURAL: B048 assert a surfaced dependency issue reaches output (issues not re-init'd); B049 assert the cycle report references a defined findings-json; B050 assert a CLI target arg is honored via a W:_arg1 fallback; B084 assert notes-dir resolves from the slug (no {project.path} on a slug); B085 assert coverage-pct is assigned before interpolation (or the GAP block corrected). Each fails pre-fix.
- **dissent:** Challenger lens wanted the cosmetic interpolation bugs B084/B085 deferred out of this release. Overruled (all 91 must be placed) but they are demoted to Wave 3 and no longer share a PR with the extracted security fix B047.

## PR-21 — Program state/persistence: plan-done stale pointers + chat-input persist
- **risk/effort:** low / S  ·  **subsystem:** programs-state
- **bugs (2):** B014, B034
- **depends_on:** PR-01
- **rationale:** Two persistence/state-lifecycle bugs: B014 plan-done task=='all' clears W:active-plan but leaves stale W:plan-done-name/-task that shadow the active-plan fallback next invocation; B034 chat-input's PERSIST append omits the `text` field so the assistant reply is never written to the chat file.
- **test strategy:** STATIC-STRUCTURAL: B014 assert plan-done all CLEARs the stale plan-done-name/-task pointers (no shadowing of active-plan on the next invocation); B034 assert the PERSIST append includes the `text` field. Both fail pre-fix.

## PR-27a — ADVISORY (kernel floor): KERNEL-SLIM active-program interrupt gate integrity
- **risk/effort:** low / S  ·  **subsystem:** kernel-advisory-programs · ⚠ KERNEL-ADVISORY (findings-only, owner escalation)
- **bugs (2):** B052, B053
- **depends_on:** —
- **rationale:** SPLIT from PR-27 and moved to the FRONT of the advisory wave (security lens): B052/B053 are a PRE-EXECUTION security control in KERNEL-SLIM.md that fires on EVERY user input before command parsing. B052 interrupt ABORT clears W:_interrupt-pending-input then EXECs that now-empty key (drops the user action); B053 binds `answer` from the triggering input not the K/I/A reply and re-fires on every input, so no K/I/A branch executes and the reply overwrites pending-input. A broken pre-parse gate must outrank tool-logic/format advisories.
- **test strategy:** Advisory — LANDED static-assertion tests over KERNEL-SLIM.md (kernel .md; tests in tests/ do not edit the floor): assert the ABORT branch preserves and runs the new action; assert `answer` binds from the K/I/A reply and each K/I/A branch routes to its handler; assert the gate does not re-fire on every input. Flip green when the human applies the fix. No axon/* source edit lands here.

## PR-23 — ADVISORY (kernel floor): predicate/validator/registry error handling
- **risk/effort:** low / S  ·  **subsystem:** kernel-advisory-tools · ⚠ KERNEL-ADVISORY (findings-only, owner escalation)
- **bugs (4):** B011, B060, B065, B061
- **depends_on:** —
- **rationale:** Findings-only advisory (kernel floor). Uncaught-exception / error-propagation defects in kernel .py tools: B011 predicate `matches` with an invalid regex raises re.error and crashes the CLI/gate caller; B060 predicate `in` with a non-string LHS raises uncaught TypeError; B065 validator selects the data source by truthiness so `--data ''` falls through to open(None); B061 programs_registry main() never propagates args.func's return so `return 1` error paths exit 0.
- **test strategy:** Advisory — LANDED behavioral failing-before tests in tests/ (kernel .py tools are testable from outside the floor): invalid regex RHS returns the error envelope not a traceback; non-string `in` returns an error envelope; validator with --data '' errors cleanly; programs_registry error path exits non-zero. Flip green on human fix. No floor edit.
- **dissent:** Test-strategy lens: original 'proposed human-run test / no code lands' under-covers 14 behaviorally-testable kernel .py bugs. Adopted LANDED failing-before tests in tests/ (not a floor edit) so these AI-verified bugs carry durable regression checks.

## PR-24 — ADVISORY (kernel floor): self_care substring false-positives
- **risk/effort:** low / S  ·  **subsystem:** kernel-advisory-tools · ⚠ KERNEL-ADVISORY (findings-only, owner escalation)
- **bugs (2):** B012, B064
- **depends_on:** —
- **rationale:** Findings-only advisory (kernel floor). B012 reads the health score via kv-store with an L: key that kv_store refuses and no longer holds the value, so score is always None (health perpetually unknown) — coupled to PR-11/B074 kv_store key-acceptance semantics, which must agree; B064 complete-claim check uses `"complete" in (status+' '+phase)` matching inside 'incomplete', a false complete-claim-unbacked finding.
- **test strategy:** Advisory — LANDED behavioral tests in tests/: self_care reports a real numeric health score when one exists; a status of 'incomplete' does NOT trigger a complete-claim-unbacked finding. Flip green on human fix. No floor edit.

## PR-25 — ADVISORY (kernel floor): kernel tool logic/format (lib ts, clock, liveness, redact, rules_loader)
- **risk/effort:** low / M  ·  **subsystem:** kernel-advisory-tools · ⚠ KERNEL-ADVISORY (findings-only, owner escalation)
- **bugs (5):** B057, B058, B059, B062, B063
- **depends_on:** —
- **rationale:** Findings-only advisory (kernel floor). Five logic/format defects in kernel .py tools: B057 _axon_lib usage_record writes ts as isoformat()+'Z' ('...+00:00Z') which usage.py cannot fromisoformat-parse, silently dropping entries; B058 clock's `unix` uses naive-UTC .timestamp() (off by the host UTC offset); B059 liveness_lint's caller regex \bauthorized\s*\( matches English prose so a dead governance seam reads as wired; B062 redact reports hit offsets against the progressively-redacted string not the original; B063 rules_loader dead-rule detection uses substring containment so R-1 is masked by R-10.
- **test strategy:** Advisory — LANDED behavioral tests in tests/: usage_record entries are readable by usage.py windowed queries; clock.unix equals the true epoch on a non-UTC TZ; liveness_lint does not report a dead seam wired from prose; redact offsets index the original text; rules_loader flags R-1 dead even when R-10 is referenced. Flip green on human fix. No floor edit.

## PR-26 — ADVISORY (kernel floor): compiler template defects (chat-session, feedback-loop, qc-workflow)
- **risk/effort:** low / S  ·  **subsystem:** kernel-advisory-compiler · ⚠ KERNEL-ADVISORY (findings-only, owner escalation)
- **bugs (4):** B005, B006, B054, B055
- **depends_on:** —
- **rationale:** Findings-only advisory (kernel floor). Compiler .tpl.md template bugs: B005 chat-session Save Output invokes translate with key `input:` instead of required `source:` so translate hard-fails; B006 feedback-loop actor-failure branch falls through to EVAL (dead eval-result write, EVAL runs on empty/FAIL); B054 qc-workflow Slack alert interpolates never-stored {W:batch-key}; B055 qc-workflow RAND(W:batch, W:sample-size) misuses RAND (no sample-N-without-replacement form).
- **test strategy:** Advisory — LANDED static-assertion tests over the .tpl.md templates: chat-session Save Output passes source:; feedback-loop actor failure SKIPS the iteration (no fallthrough to EVAL); qc-workflow interpolates a stored batch key and uses a valid sampling op. Flip green on human fix. No floor edit.

## PR-27b — ADVISORY (kernel floor): kernel program specs (dev-new, plan-list, register-preference)
- **risk/effort:** low / S  ·  **subsystem:** kernel-advisory-programs · ⚠ KERNEL-ADVISORY (findings-only, owner escalation)
- **bugs (3):** B007, B008, B056
- **depends_on:** —
- **rationale:** Findings-only advisory (kernel floor) — remainder of PR-27 after the security-critical interrupt gate (B052/B053) split to PR-27a. B007 dev-new scaffold hardcodes DONE(dev-new) instead of DONE({W:dev-new-name}); B008 plan-list uses FIND where a filter is needed so it captures only the first plan (under-reports); B056 register-preference OUTPUT interpolates pref-topic/key/value after they were CLEARed (blank confirmation).
- **test strategy:** Advisory — LANDED static-assertion tests over the kernel .md programs: dev-new output program terminates with its own name; plan-list lists ALL active/completed plans; register-preference confirmation shows populated fields. Flip green on human fix. No floor edit.


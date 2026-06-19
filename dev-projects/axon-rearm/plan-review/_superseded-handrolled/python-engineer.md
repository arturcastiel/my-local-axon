# Plan Review — Senior Python Engineer

**Reviewer:** Senior Python Engineer (named specialist)
**Scope:** implementability + code quality of the first-sprint PRs of `axon-rearm`
**Mode:** READ-ONLY. Read the plan (`HANDOFF.md`, `01-study.md`, `02-plan.md`, `02-prs.md`) + source handoff + live tree at `/home/arturcastiel/projects/new-axon/axon`. Ran read-only git/grep. No code modified, no tests run.
**Date:** 2026-06-19

---

## 1. Verdict

**SOUND-WITH-RISKS** — confidence **high** (0.85).

The plan is implementable and the diagnoses are accurate against the live tree. Every load-bearing fact I spot-checked is real: zero `*-required` flags on disk; the `crucible.py:131` vs `:155` resolver asymmetry; the dual `drift` encoding; the ungated `dev-mode`; five divergent axon-path classifiers. The PRs are correctly *ordered* (Tier 0 first is right) and the test-claims are mostly well-targeted. The risks are not in the strategy — they are in **under-specification of the wiring**, which on this codebase is exactly where the bugs live (the handoff's own theme T3, "the seam is where AXON breaks"). Several first-sprint PRs are specced as one-liners over machinery that has 2–5 redundant code paths; an executor who implements the named path and stops will ship a partial fix that the test-claim, as written, may not catch.

The single most important correction: **PR-T1-1's premise is partly stale** — the fail-closed guard already half-landed in this checkout — so the PR must be re-scoped from "fix the bug" to "consolidate the now-redundant resolvers + add the no-mock test," or it will look done while a real residual remains. Details below.

---

## 2. What the plan gets right

- **Tier-0-first is correct and the dependency `PR-T0-2a → PR-T0-2` is real.** `tools/rules/r_terminal_outputs.py` resolves declared outputs through the `# emits:` SSOT (`_declared_emits`, lines 48-57) and **fails OPEN when no emits header exists** (docstring lines 8-16). Confirmed only 5 programs declare `# emits:` today. Flipping `terminal-outputs-required` before seeding emits would bite nothing — exactly as A2a/PR-T0-2a argues. The ordering is load-bearing, not ceremony.

- **The CR-13 resolver diagnosis is accurate.** `changed_files()` (`crucible.py:131`) runs `git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1` — the fallback clause has no `2>/dev/null`, so on a single-commit / no-origin repo `base` resolves to `""` (empty). `_changeset_base()` (`:155`) has `2>/dev/null` on *both* clauses and returns `None` via `or None`. The two provably disagree. The plan cites the right lines and the right mechanism.

- **The "test mocks the defect away" claim is literally true.** `tests/test_crucible_failopen.py:21-22` monkeypatches **both** `_changeset_base` and `changed_files` to fixed return values — so the test can never exercise the real git-shell divergence. PR-T1-1's "NO monkeypatching" test-claim and PR-T1-3's "re-point `test_crucible_failopen.py`" are correctly aimed.

- **PR-T1-4's four loopholes are all real and precisely located** in `tools/rules/r_new_needs_test.py`: A-only gating (`status != "A"`, line 150); `_classify` covers only `workspace/programs/` + `tools/` (lines 48-62), missing addon neurons; `tests:` field is text-presence only with no `os.path.exists` (`_declared_tests`, lines 87-98); `_credible_reference` (lines 101-112) is a regex-OR that a plausible filename satisfies. The PR is a faithful map of the rule's gaps.

- **PR-T3-2's drift-gate seam is exactly where the plan says.** `tools/rules/r_drift_gate.py:62` is `if drift_state == "unknown": return None` and `tools/drift.py:_evaluate_gate` already computes the fail-closed `unknown` verdict (`_unknown_gate`, lines 226-235; gate at 247-300). The consumer discards what the producer correctly computes — a clean fix surface.

- **The security-floor diagnosis is correct.** `dev-mode` is read from ordinary L: memory (`enforce.py:cmd_check_write` lines 74-78 via `read_longterm`), the file lives ungated in `workspace/memory/longterm/dev-mode.md`, and the R9 write-gate keys entirely off `is_inside_axon` (`enforce.py:34`) — so `tools/` and `.claude/settings.json` are genuinely outside any gate. PR-T2-1 / PR-T2-2 target the right capability.

- **Method discipline is right for this repo.** "Reproduce-then-block, no fingerprint-only closure, STRONG per-rule tests" is the correct posture for a codebase whose bugs are overwhelmingly in redundant/divergent code paths. A single integration test would mask exactly the failures that matter here.

---

## 3. Weaknesses / risks / gaps (ranked by severity)

### S1 — CRITICAL · PR-T1-1 premise is stale; risk of a "looks-done" partial fix
`run_changeset` (`crucible.py:182-231`) **already calls the fixed resolver**: the fail-closed guard at line 189 is `if not changed and base is None and _changeset_base(base, cwd) is None: return {ok: False, R_CHANGESET_BASE}`. So on a single-commit repo with an empty diff, the gate **already fails closed today** — the `:155` resolver is wired into the live guard. The remaining defect is narrower than "the gate fails open":
- `changed_files()` (`:131`) still leaks stderr and computes against `base=""` when its fallback fails, producing a **different** changeset than `_changeset_base` would imply, and
- the two resolvers are still duplicated, so they *can* drift again.

**Implication:** PR-T1-1 as specced ("collapse to ONE resolver … the duplication IS the root cause") describes a fix that is **half-landed**. If the executor collapses the two functions and the existing (mock-based) test stays green, the PR will read DONE while the real end-to-end behavior is unverified. The test-claim — "single-commit repo, new untested `tools/X.py`, base=None → ok is False, NO monkeypatching" — must assert against `run_changeset`'s **full path including a non-empty changeset** (a new untested file present), not just the empty-diff guard that already passes. **Fix:** re-scope PR-T1-1 to "consolidate the redundant resolvers + prove end-to-end with a real new-untested-tool fixture," and make PR-T1-3 the gating test that distinguishes "empty diff fail-closed" (already works) from "non-empty diff with an untested neuron blocks" (the actual CR-13 promise).

### S2 — HIGH · PR-T0-1 is under-specified: `drift record` hard-fails without `drift init`
`drift.py:cmd_record` (lines 165-181) returns `{"error": "No trace initialized"}` and **exit 1** if no trace exists (lines 167-169). A PostToolUse hook that calls `drift record --tool X` will therefore no-op (or error) for the entire session unless something has first run `drift init --program <path>`. **There is no `drift init` caller anywhere today** and **no PostToolUse hook registered** (confirmed: `.claude/settings.json` has only `UserPromptSubmit`, `PreToolUse`, `Stop`; the `.proposed` file is already consumed). PR-T0-1's change-line ("wire `drift record` from a real PostToolUse interceptor") silently assumes an init step that does not exist. **Fix:** PR-T0-1 must specify *both* (a) a trace-init trigger — likely a UserPromptSubmit/program-start hook that runs `drift init --program <active-program>` (or `--no-program` for a stable baseline) — and (b) the PostToolUse `record` interceptor. The test-claim ("trace file gains the actual call; drift.py computes a non-empty verdict") cannot pass without the init half. Without this, PR-T0-1 ships a wire that records nothing — recreating the exact "decorative meter" the project exists to fix.

### S3 — HIGH · PR-T0-1 ↔ PR-T2-2 ordering coupling (self-locking gate)
PR-T0-1 must add a `PostToolUse` block to `.claude/settings.json`. PR-T2-2 explicitly brings `.claude/settings.json` under R9-style protection (dev-mode-gated). If PR-T2-2 lands first, PR-T0-1's own edit to `settings.json` is **blocked by the gate it is trying to coexist with** — and worse, any *future* hook wiring requires a dev-mode toggle. The plan's critical-path section lists neither dependency. **Fix:** (1) sequence all `.claude/settings.json` hook edits (PR-T0-1, and any later) **before** PR-T2-2, or land them together; (2) PR-T2-2 must define the legitimate "edit settings.json under dev-mode" path and add a test that a governed settings edit *succeeds* with dev-mode ON — not just that it's blocked OFF.

### S4 — HIGH · PR-T2-2 names one classifier but the gate has five code paths
The plan says "extend `is_axon_path` → `is_protected_path`." There are **five** divergent path classifiers: `tools/_axon_paths.py:is_axon_path` (the one named), `tools/enforce.py:is_inside_axon` (line 34 — **this is the one the PreToolUse Write/Edit gate actually calls**, via `cmd_check_write`), `tools/shell.py:_is_axon_path` (line 139 — the **Bash** gate path, via `enforce_pretooluse.bash_axon_write_block`), `tools/rules/r9_axon_write.py:_is_axon_path` (line 52), and `tools/_axon_io.py:_is_axon_path` (line 49). The `_axon_paths.py` docstring claims it "replaces 3 divergent in-process impls" — it has not; they still exist. Protecting `tools/` + `.claude/settings.json` requires touching **every gate the PreToolUse hook routes through** (at minimum `enforce.is_inside_axon` for Write/Edit and `shell.gate_check` for Bash), or a Bash `echo x > tools/rules/r9_axon_write.py` walks straight past a Write-only fix. **Fix:** PR-T2-2 must enumerate all gate entrypoints and add a **Bash-path** test (`echo … > tools/rules/*.py` BLOCKED), not only a Write/Edit test. The plan's own test-claim mentions "Write/Bash into tools/…" — good — but the change-line names only one classifier, which an executor will take literally.

### S5 — MEDIUM · PR-T0-2 hides a heterogeneous flag-delivery matrix; per-rule tests are mandatory, not optional
The six flags reach their rules by **two different mechanisms**, and the per-rule test-claim is the only thing that catches a broken one:
| Flag | read by `verify.py:load_state`? | rule has disk-fallback? |
|---|---|---|
| `state-surfaced` | YES (`verify.py:105`) | NO |
| `terminal-outputs` | YES (`:107`) | NO |
| `reasoning-trace` | YES (`:114`) | YES |
| `phase-tracking` | NO | YES (`r_phase_tracked._is_required`) |
| `workflow-node-order` | NO | YES (`r_workflow_node_order._required`, reads `repo_root/workspace/...`) |
| `no-orphan-tools` | NO | YES (`r_no_orphan_tools._required`) |
The disk-fallback rules only see the flag when invoked with the right anchor: the crucible changeset path passes `repo_root` (`crucible.py:197`) which the fallbacks join correctly — so they *do* bite — but `r_state_surfaced` / `r_terminal_outputs` have **no fallback** and bite **only** if `verify.py:load_state` carries the flag into `state`. This works today for those two (load_state reads them), but the asymmetry means any new flag, or any rule whose load path is wrong, fails silently. **Fix:** PR-T0-2's test-claim already says "per-rule BLOCK-on-violation + PASS-on-clean" — keep that **strictly**; reject any closure that uses a single end-to-end test. Add one assertion that each flag, when flipped on disk *and nothing else*, flips the rule's verdict (proves the delivery path, not just the predicate).

### S6 — MEDIUM · PR-T3-2 reverses a documented intentional decision without addressing the prior intent
`r_drift_gate.py:57-61` is an explicit comment block ("PR-AUTO-213: distinguish positive divergence from evidence absence … At the response gate this is silent — the menu badge surfaces it"). The `unknown → return None` is **documented as intended**, not an accident. OD-2 rules it a "bug" (fine, owner's call), but PR-T3-2's change-line doesn't acknowledge that flipping it to fail-closed BLOCK will make **every session with a stale/missing trace block output** — and given S2, traces are stale/missing *by default* until PR-T0-1 lands and stays healthy. **Fix:** PR-T3-2 must (a) hard-depend on PR-T0-1 being not just merged but *producing fresh traces* (the plan lists the dep — good), (b) decide the `dev_mode` interaction for `unknown` (currently dev-mode demotes `diverged` to WARN at lines 64-73 but `unknown` returns before that — should `unknown` under dev-mode also demote, or block?), and (c) delete/rewrite the PR-AUTO-213 comment so the code doesn't read two ways. A 2-hour TTL (`DRIFT_TRACE_TTL_S`, `drift.py:223`) means any idle session re-blocks — confirm that's intended.

### S7 — LOW/MEDIUM · PR-T0-3 has no atomic increment primitive
`tools/memory.py` exposes only get/set/append/clear/rollback/history — **no increment** (and `set` for `W:` is a blind `atomic_write`, line 61). Incrementing `W:turn-count` from `reanchor_store.py` requires a read-modify-write (`memory get` → parse int → `memory set`). In the UserPromptSubmit hook this is single-threaded per turn so a race is unlikely, but: (a) the parse must tolerate a missing/garbage current value (first turn, corruption), and (b) `reanchor_store.py:main` exits 0 unconditionally (advisory) — a failed increment is **silent**, which re-introduces a soft-failure mode in the very counter meant to be mechanical. **Fix:** either add a small `memory.py increment` subcommand (atomic, defaults missing→0) and call that, or inline a defensive read-modify-write with an explicit default; the test-claim ("two simulated turns → turn-count advances without a model STORE") must drive the **actual hook** with realistic payloads, not call a helper.

### S8 — LOW · `sys.path.insert(0, cwd)` in `run_changeset` is a latent import-shadowing trap
`crucible.py:184` does `sys.path.insert(0, cwd)` to make `from tools.rules import …` resolve to the checkout rather than the editable install. Any PR that adds a new rule import to this block (PR-T0-2 wiring, PR-T3-4 adding `crucible` to `R_PHASE_TRACKED`) inherits this. There is a `test_no_sys_path_bootstrap.py` in the suite — confirm new rule-loading code does not trip it, and prefer the existing pattern over a fresh `sys.path` mutation. Low severity (it's contained), but it's the kind of thing a Tier-3 PR will stumble on.

---

## 4. Specific changes I would make before execution

1. **Re-scope PR-T1-1** from "fix the fail-open" to "consolidate the two resolvers (`changed_files` + `_changeset_base`) into one + verify end-to-end." Note in the PR that the empty-diff fail-closed guard (`crucible.py:189`) already works; the residual is the `changed_files` stderr-leak/`base=""` path and the duplication itself. Move the *behavioral* assertion into PR-T1-3 and make it test a **non-empty changeset with a new untested tool**, with no monkeypatching of either resolver.

2. **Split PR-T0-1 into init + record, or make the init step explicit.** Add a sub-bullet: "wire `drift init` (program-start or UserPromptSubmit) so a trace exists before `record` fires." Without it the PostToolUse `record` no-ops all session. Add the test that `drift check` returns a **non-empty `actual`** after a simulated init→record→record sequence through the real hooks.

3. **Add the PR-T0-1 ↔ PR-T2-2 dependency to the critical path** and sequence settings.json hook edits before the settings.json lock. PR-T2-2 must include a "governed edit succeeds under dev-mode ON" test, not only a "blocked OFF" test.

4. **Make PR-T2-2 enumerate every gate path.** Change the change-line to "extend the protected-path classifier across all write-gate entrypoints (`enforce.is_inside_axon` for Write/Edit, `shell.gate_check`/`shell._is_axon_path` for Bash)" — not "extend `is_axon_path`." Require both a Write/Edit test and a Bash-redirect test against `tools/rules/*.py` and `.claude/settings.json`. Consider a meta-test (overlaps PR-T3-1) asserting the protected-path classifiers agree, since there are five of them.

5. **Keep PR-T0-2's per-rule test-claim non-negotiable** and add "flip-flag-on-disk-only flips the verdict" to prove the heterogeneous delivery path (two of six rules have no disk fallback; the others read different anchors). Do not accept a single integration test.

6. **PR-T3-2:** add (a) an explicit hard-dependency that PR-T0-1 is producing *fresh* traces in normal operation before `unknown→BLOCK` flips (else default sessions block on a stale/absent trace given the 2h TTL), (b) a decision on the `dev_mode` × `unknown` interaction, and (c) deletion of the now-contradictory PR-AUTO-213 comment.

7. **PR-T0-3:** add a `memory.py increment` primitive (atomic, missing→0) or specify a defensive inline read-modify-write, and make the increment failure non-silent enough to be testable (the hook can stay advisory-exit-0, but the test must assert the value actually advanced through the real hook entrypoint).

8. **Add an explicit anti-regression meta-test to PR-T1-3** (the plan hints at it): "no R13 test monkeypatches both resolvers." This is cheap and permanently prevents the `test_crucible_failopen.py` failure class from recurring.

---

## 5. Per-PR implementation-risk ratings (first sprint)

| PR | Implementable as specced? | Risk | Why |
|---|---|---|---|
| **PR-T0-1** (instrument drift) | Partially — missing init step | **HIGH** | `drift record` hard-fails without `drift init`; no PostToolUse hook exists; couples to settings.json lock (S2, S3). Biggest hidden gap in the sprint. |
| **PR-T0-2a** (seed `# emits:`/`outputs:`) | Yes | **LOW** | Mechanical data-seeding; `r_terminal_outputs` resolution path confirmed (fails open without emits — safe). |
| **PR-T0-2** (arm flags) | Yes, with strict tests | **MEDIUM** | Heterogeneous flag delivery (two mechanisms, five rules); per-rule tests are load-bearing (S5). |
| **PR-T0-3** (mechanical counters) | Yes, with a primitive | **MEDIUM** | No atomic increment in `memory.py`; silent-failure mode in the advisory hook (S7). |
| **PR-T1-1** (one resolver) | Premise stale — re-scope | **MEDIUM-HIGH** | Fail-closed guard already half-landed; "looks-done" partial-fix risk; test must hit the non-empty-changeset path (S1). |
| **PR-T1-2** (CI fetch-depth) | Yes | **LOW** | YAML/CI config; the actual enable-condition for a real merge-base. Low code risk. |
| **PR-T2-1** (gate dev-mode) | Yes, design-dependent | **HIGH** | "Out-of-band human token" is unspecified mechanism; highest-blast-radius security change; needs the reproduce-then-block test the method demands. |
| **PR-T2-2** (protect tools/ + settings) | Yes, if all gates touched | **HIGH** | Five classifiers; must cover Write/Edit **and** Bash paths; self-locking-gate ordering vs PR-T0-1 (S3, S4). |

---

## 6. Bottom line

The plan is **SOUND-WITH-RISKS**. The diagnoses are accurate and the ordering is correct — this is a remediation backlog, not a rewrite, and the author understands the codebase. The risks are concentrated in **under-specified wiring on machinery with redundant code paths**, which is precisely the failure mode the handoff itself identified (T3, T5). Four first-sprint PRs (T0-1, T1-1, T2-1, T2-2) need tightening before execution: T0-1 is missing its init half, T1-1's premise is stale, and the two Tier-2 PRs name one code path where five exist and carry an unstated self-locking-gate ordering. Fix the eight items in §4 — especially the PR-T1-1 re-scope and the PR-T0-1 init step — and the sprint is safe to execute under the stated "test-more, redo-until-closed" discipline.

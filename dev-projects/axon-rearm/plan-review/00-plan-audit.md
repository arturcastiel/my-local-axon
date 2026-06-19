# 00 — AXON-REARM PLAN AUDIT (authoritative)

**Synthesizer:** AUDIT DELIBERATOR (Tie-Breaker synthesis persona, process/deliberation-roles, senior)
**Inputs:** four sealed audit-seat opinions (feasibility/auditor, risk/challenger, completeness/completer-finisher, consensus/tie-breaker) over ten catalog-persona specialist reports under `plan-review/`.
**Live tree:** `/home/arturcastiel/projects/new-axon/axon` — HEAD `6ce9bd8`, branch `fix/wave-g-residual-hardening`, remote `git@ci.tno.nl:...` (GitLab), date 2026-06-19.
**Method:** vote aggregation → consensus must-fix slate (≥3 independent lenses = near-fact) → conflict docket (owner-only arbitration) → revised first sprint. Load-bearing claims re-verified read-only against the live tree by this seat (see §6 Evidence Register). Read-only; advisory.

---

## 1. OVERALL VERDICT

### **PROCEED-WITH-CHANGES — confidence HIGH (0.84)**

The plan's **diagnosis is sound, re-verifiable, and earns the right to proceed**; the plan's **first-sprint execution spec is not yet executable as written** and must be amended before any PR is opened. This is not REWORK (no redesign is required; the engines are correct, the thesis holds, the decision→PR traceability is complete) and it is not unqualified PROCEED (at least four CRITICAL nonconformities would, run as ordered, reproduce the exact false-green the project exists to destroy, and one would revert a correct regression test).

**Why PROCEED-WITH-CHANGES and not REWORK.** All four audit seats and all ten specialist seats converge on a single direction: the diagnosis ("disarmed + uninstrumented, config-not-redesign, fix-seams-not-engines") is verified against source, not asserted. No seat found a reason to redesign. The Tier-0-first ordering instinct is endorsed 10/10. The remediation *style* (fix consumers and joins, do not rewrite proven engines) is correct for this codebase. The defects are concentrated in **sequencing, test-rigor, and a small set of net-new scope gaps** — every fix is a pre-execution plan edit.

**Why PROCEED-WITH-CHANGES and not PROCEED.** Three of the four audit seats reached a *harder-than-the-specialists* grade (auditor: NOT-EXECUTABLE-AS-WRITTEN; challenger: NOT-SOUND-AS-ORDERED 0.70; completer: NOT-DELIVERABLE-AS-WRITTEN). The challenger's consensus-cascade warning is well-taken and I bank it: ten specialist lenses each returned SOUND-WITH-RISKS and each downgraded only one notch ("all fixable pre-execution"), but the *aggregate of ten independent CRITICAL findings* is a first sprint that, run as ordered, bricks or blinds itself in at least four independent ways. The deliberator does not average that alarm away — it converts it into binding pre-execution gates (§2).

**The single most important correction this audit makes** (and the place the four seats split): the highest-priority owner action is the **30-second K1 disambiguation** of `tests/test_crucible_failopen.py`. This seat performed that read. **It is resolved below (§4 K1-RESOLVED) and it re-weights ~3 specialist reports.** PROCEED-WITH-CHANGES is conditioned on the Tier-1 PRs being rewritten against the live tree before execution.

---

## 2. RANKED MUST-FIX CHANGES BEFORE EXECUTION

Each item cites the PR(s) it amends, the source seat(s), and the live-tree evidence. Ranked by **leverage × irreversibility-of-getting-it-wrong**. M-items 1–9 are blocking; the first sprint must not open until M1–M6 are closed and M7–M9 are owner-ruled.

### M1 — [CRITICAL · do first, costs 30s] STOP re-pointing a correct regression test; rewrite PR-T1-1/T1-3/T1-4 against the live tree
**PRs:** T1-1, T1-3, T1-4. **Seats:** auditor F1, challenger §1, completer D1, tie-breaker K1/C7; primary owner **kernel-engineer R1**.
**Verified live (this seat read the full file):** `tests/test_crucible_failopen.py` contains exactly two functions. `test_run_changeset_fails_closed_on_unresolvable_base` (line 18) monkeypatches `_changeset_base→None` and `changed_files→[]` **to construct the empty-diff-unresolvable-base scenario, then asserts `res["ok"] is False`** — i.e. it asserts the FIX. On the live tree `_changeset_base()` already exists (`crucible.py:148`) and `run_changeset` already fails CLOSED (`crucible.py:189-194`, returns `R_CHANGESET_BASE` BLOCK). **The catastrophic empty-diff vacuous-pass the plan exists to fix is ALREADY CLOSED.** PR-T1-3's instruction to "re-point `test_crucible_failopen.py` which currently enshrines the bypass" would **revert a correct regression test.**
**Action:** DELETE the T1-3 "re-point" instruction. Re-scope T1-1 to the residual real defect: collapse `changed_files()`' inline base resolution (`:128-134`) to call the single `_changeset_base`; verify the `2>/dev/null` parity; distinguish "no diff" from "git failed" on the non-empty-diff path. ADD a new no-mock end-to-end test alongside the existing one; do not touch the existing one. **Until rewritten, T1-1/T1-3/T1-4 cannot close under reproduce-then-block — their named pre-fix RED state does not exist on HEAD.**

### M2 — [CRITICAL] Do not flip a `-required` flag for a rule the engine never loads; split PR-T0-2
**PRs:** T0-2 (split into Phase A / Phase B); pull T3-1 into Wave 0. **Seats:** auditor F2, challenger §2, completer D3, tie-breaker C2; primary owner **challenger R1**.
**Verified live:** `registry._collect_rules()` returns **22 rules**. The registry imports `r_reasoning_trace, r_drift_gate, r_state_surfaced, r_terminal_outputs, r_coherence` — but **does NOT import `r_phase_tracked`, `r_workflow_node_order`, or `r_no_orphan_tools`.** Of the six flags PR-T0-2 flips, three are REGISTERED (`r_state_surfaced`, `r_reasoning_trace`, `r_terminal_outputs`) and **three are UNREGISTERED no-ops** at the response gate. Flipping a `-required` flag for an unregistered rule sets a state key nothing reads — `verify.py status` reads "armed," the meter reads quiet, the council concludes "armed and instrumented," and **the precise honesty≠enforcement disease is rebuilt inside the cure's first sprint.** (Note: challenger's harsher refinement — `r_workflow_node_order`/`r_no_orphan_tools` are imported *directly* by `run_changeset` at the changeset plane, so they bite at the merge gate but never the response gate — is a real plane-split that PR-T0-2's single-plane test cannot detect.)
**Action:** SPLIT PR-T0-2. Phase A flips ONLY flags whose rule is in `_collect_rules()` AND has a per-rule RED-before/GREEN-after test at the plane the flag claims to arm. Phase B flags stay OFF until their rules are registered. This requires **re-ordering PR-T3-1 (prose↔wiring audit) from Wave 3 into Wave 0** — the plan's dependency graph has this backwards: you cannot arm what you have not verified is wired.

### M3 — [CRITICAL] Protect-before-arm: the armed flags live in an UNPROTECTED, gitignored directory
**PRs:** extend T2-2 scope (or add `PR-T2-flags`); co-land with T0-2. **Seats:** auditor F7, challenger §3, completer M2, tie-breaker C1 (5-seat consensus: app-security R3/C-4, red-teamer R4, harness RISK-1, agent-architect R2/R3, release R4).
**Verified live:** the `-required` flags and `dev-mode.md` live in `workspace/memory/longterm/`, which is `is_axon_path → False` (unprotected) and gitignored. PR-T2-2 as scoped protects only `tools/` + `.claude/settings.json` — **NOT the flag dir.** Post-plan the flags are armed-but-unprotected: one `memory.py set --key <x>-required --value false` (or a drifted/malicious tool call) silently re-disarms everything Tier 0/1 turned on — no rule fires, no dev-mode needed. This recreates "the guard is less protected than what it guards" AT THE FLAG LAYER and **corrupts the plan's own falsifiable drift prediction** (drift can be flipped back invisibly). App-security states it bluntly: "arming a flag the agent can disarm next turn is theatre."
**Action:** fold `workspace/memory/longterm/*-required.md` AND `dev-mode.md` into `is_protected_path` in the SAME PR that arms (co-land), or protect-before-arm.

### M4 — [CRITICAL] dev-mode ships ALREADY OPEN; pin the path anchor; close the loop-receipt bypass
**PRs:** T2-1 (revert dev-mode default; redefine token channel); add `PR-T2-anchor`; add `PR-T2-loopreceipt`. **Seats:** auditor F7, challenger §3, completer M1/M3, tie-breaker C1; primary owners **prompt-injection-red-teamer R1/R2/R4, application-security-engineer R1/C-1/C-2**.
**Verified live (this seat reproduced all three):**
- `dev-mode.md` currently reads `value: true` — **the master lock ships unlocked.** PR-T2-1's test ("a write of dev-mode=true is DENIED") is irrelevant against a lock that is already open. The plan arms enforcement on top of an open master key and never closes it.
- `AXON_ROOT=/tmp` → `is_axon_path(<abs path to KERNEL-SLIM.md>)` returns **False**. The R9 classifier (the SSOT every gate funnels through) believes the real kernel is outside `axon/`, so a write to it is ALLOWED. The agent exports one variable; no Tier-2 PR touches the anchor. **This is a one-line total write-gate bypass from Bash.**
- `tools/_axon_io.py:33`: `_R9_WHITELIST = frozenset({"loop-receipt"})`; `atomic_write(_actor="loop-receipt")` skips R9 regardless of dev-mode (confirmed at lines 122/179). A standing insider bypass PR-T2-1 leaves untouched while adding a new check.
**Action:** revert dev-mode to default-OFF and add a test that asserts it defaults OFF and reverts OFF (not just "true is denied"); pin `_resolve_axon_root` to the tracked `.axon-governed` sentinel realpath and REJECT a disagreeing `$AXON_ROOT`; constrain `_R9_WHITELIST` to a path, not an actor; define the dev-mode authorization channel as NOT-a-file-in-the-same-drawer. **A Tier-2 that passes its own tests while leaving these three insider vectors open is worse than no Tier-2 — it manufactures the false assurance the project exists to kill.**

### M5 — [CRITICAL] Resolve the CI host; the gate fix targets the wrong pipeline; co-merge T1-1+T1-2
**PRs:** T1-2 (rewrite for the gating host); annotate T1-1↔T1-2 as atomic co-merge; add a CI-host study sub-step. **Seats:** auditor F4, challenger §5, completer M5, tie-breaker (release lens); primary owner **release-engineer R1/R2/R5** (sole CI-host lens; uncontested).
**Verified live:** the only CI config is `.github/workflows/ci.yml` (GitHub Actions); the remote is GitLab (`git@ci.tno.nl:...`); **there is no `.gitlab-ci.yml` anywhere.** PR-T1-2's `fetch-depth: 0` is a GitHub `actions/checkout` key. If GitLab MR pipelines gate merges, either the crucible fix lands in a non-gating pipeline OR the gate does not run on the merge path at all — **CR-13 would be unenforced exactly where code merges.** Separately, T1-1's corrected resolver WITHOUT T1-2 fails CLOSED on every shallow detached-HEAD MR — a blocked-merge storm; the DAG `depends` edge does not encode "co-merge." Also pre-existing: `lint-commit-trailer --range origin/main..HEAD` already fails-closed the whole gate on shallow checkouts (release R5).
**Action:** add a study sub-step BEFORE T1-2 to determine the authoritative gating pipeline; if GitLab gates, author the `.gitlab-ci.yml` crucible job and translate `fetch-depth`→`GIT_DEPTH` + explicit `git fetch origin main:refs/remotes/origin/main`. Annotate the DAG edge T1-1↔T1-2 as ATOMIC CO-MERGE. Test on the runner that actually gates, on a DETACHED-HEAD fixture.

### M6 — [CRITICAL] Pin the drift module + preconditions + calibration, or PR-T0-1 records nothing
**PRs:** T0-1 (pin module, add init/hook/Bash-resolver, add calibration test). **Seats:** auditor F3 (5-seat convergence), challenger §4, completer D4/M9, tie-breaker K3; owners **kernel-engineer R3/R10, harness-designer R3/R4, llm-behaviour-analyst G1/G7, eval-engineer R4, prompt-injection R3**.
**Verified live / from seats:** (a) `.claude/settings.json` has NO PostToolUse hook — T0-1 must ADD a new hook *event*, not a handler; (b) AXON tools run as `Bash(python tools/x.py)`, so a PostToolUse matcher sees `Bash`, not the canonical tool — without a command-string parser the meter reads constant divergence and discredits itself; (c) `drift record` no-ops ("No trace initialized") when no program is active — the normal interactive state — so the meter stays empty even after T0-1 ships; (d) THREE drift encodings exist (`tools/drift.py`, `workspace/tools/drift.py`, `axon_drift_log.py`) and T0-1 does not pin WHICH. The kernel issues `drift record --type persona-bleed` at four KERNEL-SLIM sites, but `tools/drift.py record` requires `--tool` and has no `--type` → argparse exit 2 → nothing logged.
**Action:** pin `tools/drift.py` as THE module; add the drift-init/ensure-trace step; specify the new PostToolUse event AND a Bash-command→canonical-tool resolver; add a golden-trace CALIBRATION test (match→0.0, one-divergence→band, reorder→diverged) — not just "trace gains a call." **Until calibrated, T0-1 cannot close under the STRONG-test bar, and everything that reads its trace (T3-2, T6-exp) inherits an uncalibrated meter.** See conflict K3: the owner must also decide whether "residual MODEL drift" binds to this procedural meter at all.

### M7 — [HIGH] Regenerate DAG.json so it can enforce its own plan; sequence against self-lockout
**PRs:** 03-prs/DAG.json; sequence T2-2 after T0-1/T0-3/T3-3 and the Wave 1/3 rule edits. **Seats:** auditor F5/F6 (7-seat convergence), challenger §5, completer C3/C4, tie-breaker C4; primary owner **agent-architect R1/R3/R4**.
**Verified live:** DAG.json = **29 nodes, 10 edges, 15 isolated nodes, `critical-path: []`, `validated: null`.** The prose asserts dependencies the DAG drops (T1-2→T1-3; the settings.json freeze cluster T0-1/T0-3/T3-3→T2-2). **A re-arm program whose own delivery DAG is unplugged is the exact honesty≠enforcement pathology it exists to fix, reproduced in its governance artifact.** Self-lockout is live: settings.json + tools/ are currently ungated; T2-2 brings them under the write-gate; but T0-1/T0-3 must ADD hooks to settings.json and T3-3/Wave-1/Wave-3 edits touch tools/. Land T2-2 first → the project locks itself out of its own remaining edits behind an out-of-band token T2-1 just made deliberately hard, and the plan never defines the dev-mode self-edit workflow its executor will use.
**Action:** add hard edges (T1-2→T1-3; T0-1→T2-2, T0-3→T2-2, T3-3→T2-2 so protect-settings lands AFTER files it freezes); add `touches` soft-edges for shared-file clusters; populate `critical-path` and `validated`; add per-node machine-checkable `dod`/`proves` fields (the empty required fields are a schema nonconformity). Define and rehearse the governed dev-mode self-edit path BEFORE T2-2 freezes the engine. Add per-wave ROLLBACK gates (see M8).

### M8 — [HIGH] Add a tested off-switch to every gate-tightening PR (no disarm command exists today)
**PRs:** T1-1, T2-1, T2-2, T2-clone, T3-2, T3-4 each gain a named WARN-downgrade. **Seats:** completer M6, auditor F6/F7, tie-breaker C4; owners **release-engineer R6, agent-architect R2, harness-designer RISK-1**.
**Verified from seats:** the backlog specifies tests-to-green but **no documented, owner-controlled, time-boxed downgrade path** for a control that over-blocks in production. HANDOFF's only posture is "gates cannot be broken (no `--force`)" — which forbids bypass but leaves NO legitimate off-ramp. A re-arm program with no disarm command is incomplete by definition-of-done. Wave 0 needs a tested one-command flag-disarm; Wave 2 needs a rehearsed break-glass.
**Action:** for each newly-BLOCKing PR, add a named, tested, audited WARN-downgrade and record it in the DAG node DoD.

### M9 — [HIGH] PR-T3-2 (`unknown→BLOCK`) reverses a documented, tested choice and bricks interactive sessions
**PRs:** T3-2 (gate on a "wire-is-live" precondition; record bug-vs-policy decision). **Seats:** challenger §5, completer D8, tie-breaker C5/K4 (5-seat convergence: harness RISK-3, llm-analyst G5, kernel R4, compiler, agent-architect R7); see conflict **K4** for the residual split.
**Verified from seats:** `r_drift_gate.py:57-63` carries an explicit `PR-AUTO-213` rationale and a passing test enshrining `unknown→None` (positive-divergence BLOCKs; evidence-absence surfaces via menu-badge). OD-2 resolved this "BUG"; the code says "policy." "No active program / stale trace" is the NORMAL interactive state, so fail-closing `unknown` BEFORE T0-1 reliably feeds the wire **halts output on essentially every interactive turn** — punishing the model for the meter being empty, the exact condition Tier-0 fixes by wiring.
**Action:** gate T3-2 on a wire-is-live precondition (not merely "meter exists"); record the decision explicitly against the PR-AUTO-213 comment rather than editing past a live rationale silently. The fail-closed *scope* (everywhere vs autonomous/merge-only) is conflict K4 below — owner-only.

### Medium nonconformities (close before the owning wave, not the whole sprint)
- **M10 [MED] Reconcile the PR count.** HANDOFF + 02-prs.md say "26-PR backlog"; 02-plan.md says "28 PRs"; DAG.json has **29 nodes** (verified); legacy-program count is 31 on disk vs the study's 29. The plan miscounts itself — an instance of Theme T7. Decide whether `PR-T4-hrteam` is in scope and pin one denominator. (challenger R7, harness GAP-7, completer E1/E2.)
- **M11 [MED] Test CLAIMS are not SPECS.** Several first-sprint claims can pass while the defect survives (T0-2 has no flags-OFF arm/per-plane slice; T1-1 tests one of three base states; T1-5's "shrink-only ratchet mirrors liveness-allow.txt" is FALSE — `liveness.py` has no shrink-only guard, the ratchet is net-new to BUILD; T2-3's `chattr`/`0o444` silently no-ops on WSL2/tmpfs — assert EPERM, not exit 0). Promote T1-3's anti-mock meta-assert into a **sprint-wide lint** flagging any gate test that monkeypatches the function-under-test on both defect and resolver paths. Require a literal RED-before/GREEN-after transcript for every gate/security PR. (eval-engineer R1/R2/R3/R8, kernel R9, harness GAP-6, app-security R5/C-6.)
- **M12 [MED] Retype and front-load the spikes/experiments.** T4-shadow (ADR), T6-exp (protocol+verdict), T2-3 (build-or-strike) have no binary test-checkable DONE — incompatible with "STRONG automated test proves its claim." Retype as `kind:spike`/`kind:experiment`; do not count them in the ship denominator; pull a minimal heavy-OFF-vs-ON measurement into Wave 0. (agent-architect R5, harness GAP-7, challenger §3, eval R9.) See conflicts K2/K5.
- **M13 [MED] Fix the EXEC parser before T5-4 emits an "armed" graph.** `synapse_infer.py:48 RE_EXEC` excludes `/` and `.`, so path-form `EXEC(workspace/programs/X.md)` collapses to literal `workspace` → phantom hub, false orphans, "~38% isolated" wrong in both directions. Land the ~3-line regex fix + fixture as T5-4's first sub-step; add per-relation cycle policy (cycles fatal on `depends`, legitimate on `transition`). Uncontested single-lens CRITICAL — a confidently-wrong artifact masquerading as success. (compiler-engineer R1/R2/R5; tie-breaker K5.)
- **M14 [MED] T3-4 (R_PHASE_TRACKED→biting) goes 0→~100 BLOCKs with no grandfather.** The plan's own text notes 100/105 ownership programs violate the ledger contract today. Add a grandfather node (mirroring OD-5) and prove the N/A classifier; add a paired STORE…CLEAR bracket check. (kernel R7, compiler R3.)

---

## 3. CROSS-SPECIALIST CONSENSUS (decision-grade — bank without re-litigation)

**Unanimous verdict-distribution.** All 10 specialist seats returned SOUND-WITH-RISKS (confidence 0.72–0.85, mean ~0.81); zero NOT-SOUND, zero unqualified SOUND. The body **converged, it did not deadlock** — no casting vote is required on direction. The disagreement is entirely about sequencing, test rigor, and the scope gaps in §2.

**What every seat agrees the plan gets RIGHT (bank it, stop re-examining):**
1. **The diagnosis is verified at source, not asserted.** Independently confirmed by multiple seats and re-confirmed by this audit: the `crucible.py:131`/`:155` resolver asymmetry, zero `*-required` flags on disk, the absent PostToolUse hook, the empty drift wire, `r_drift_gate.py` discarding `unknown`, dev-mode=true, the GitLab remote, 22 registered rules. **No seat found a reason to redesign.**
2. **Tier-0-first is the correct epistemic ordering (10/10)** — you cannot run a PLAN-ACT-OBSERVE loop with a dead OBSERVE channel; the demonstrated cause (unwired meter) rightly outweighs the unfalsifiable one (model statelessness).
3. **The remediation STYLE is correct** — fix consumers and joins (R9 write-gate, `phase_model.done`, `workflow_run.advance`, registry hygiene), do not rewrite the proven engines.
4. **The decision→PR traceability (OD-1..OD-8 → PRs) is COMPLETE and resolves** — no orphaned decision, no PR inventing un-decided scope. The one clean traceability pass.
5. **The "reproduce-then-block, no fingerprint-only, no monkeypatching" METHOD is the right bar (10/10)** — it is precisely the discipline that would have caught the original fail-open. The gap is that the PR test CLAIMS do not yet meet the method (M11), not that the method is wrong.

**Convergence map (corroboration count = near-fact weight):** protect-before-arm/unprotected flags (7 seats incl. all four audit seats), settings.json self-lockout (7 seats), drift-meter under-specified (5 seats), `unknown→BLOCK` policy-reversal-brick (5 seats), front-load T6-exp (5 seats), unregistered-rule false-green (4 seats), stale crucible spec (4 seats incl. the K1 split), test-claims≠specs (4 seats), DAG decorative (4 seats). Where independent lenses converge, the deliberator treats the finding as fact and bakes it in.

---

## 4. UNRESOLVED CONFLICTS FOR THE OWNER (council cannot arbitrate; intent required)

### K1 — RESOLVED by this audit (was the sharpest conflict; now a directive)
**Was:** kernel-engineer R1 (the test asserts the FIX; re-pointing reverts it) vs release-engineer/eval-engineer/challenger (the test monkeypatches both resolvers → enshrines the bypass).
**This seat read the full file. RESOLUTION: kernel-engineer is correct.** `test_crucible_failopen.py` has exactly two functions. `test_run_changeset_fails_closed_on_unresolvable_base` *does* monkeypatch both resolvers (lines 21-22) — but only to **construct** the empty-diff-unresolvable-base scenario, then it **asserts `res["ok"] is False`** (the fail-closed FIX). The other seats correctly saw the monkeypatch but misread its *purpose*: it sets up the fail-closed assertion, it does not mask the defect. **Directive: the plan's "re-point the test that enshrines the bypass" instruction is FALSE and DESTRUCTIVE. Do not execute it. Add a new no-mock end-to-end test; leave the existing two intact.** This re-weights ~3 reports — the T1 wave is closer to done than the plan claims (see M1). Residual-risk owner: whoever executes T1-3 — now discharged by this read.

### K2 — GOVERNANCE: does OD-8 have veto power over the arming waves, or only advisory power?
**Split:** challenger (§3/§5.4) demands a *pre-committed HALT criterion* — "if post-Wave-0 instrumented drift does not fall below {threshold}, STOP the arming waves and re-open OD-8" — vs agent-architect/llm-analyst, who want T6-exp run early but as a *measurement that informs*, not a *gate that aborts*; vs the plan-as-written (OD-1 "ARM IT" treats arming as settled). **This is a decision-RIGHTS question only the owner can answer.** Either is defensible; leaving it implicit ("may re-scope the whole backlog" with no mechanism) is the one option the challenger correctly calls mandatory-dissent-as-theatre. **Owner must choose: (a) write the failure threshold and self-abort now, or (b) consciously accept that Tiers 1-5 ship regardless and document T6-exp as post-hoc.** Coupled to K3 — you cannot threshold a meter pointed at the wrong signal.

### K3 — INSTRUMENT: does PR-T0-1 measure the right quantity at all?
**Split (single-lens, preserved not averaged):** llm-behaviour-analyst (G1/G2, the ONLY behavioural lens) — `tools/drift.py` scores tool-call-order edit-distance (*procedural conformance*); the model-cognition signal (persona-bleed, frame-slip) lives in `axon_drift_log.py`, which the kernel mis-calls. So §4's "measure the residual MODEL drift" binds to a meter that **subsides regardless of model behaviour** (tool-order is exactly what file-backed state already fixes), confirming the verdict for the wrong reason. Every other seat treated T0-1 as instrumenting *the* meter — a blind spot, not a contradiction. **Owner must decide whether "residual model drift" binds to (a) tool-order conformance (cheap, already-instrumented, circular) or (b) cognition/persona drift (the quantity the whole epistemic argument needs, currently uninstrumented).** If (b): split the meter, wire `axon_drift_log` into a read verdict, and eval-engineer's calibration test (M6) is mandatory. **Chain: K3 unresolved → K2's HALT threshold undefinable → OD-8 cannot actually re-scope.** Resolve K3 first.

### K4 — POLICY: should `unknown` fail-closed at the INTERACTIVE response gate?
**Split:** compiler-engineer endorses fail-closed everywhere as formally sound ("absence of evidence about the guard must not satisfy the guard") vs llm-analyst (C5)/kernel-engineer (R4) — keep `unknown` ADVISORY at the *interactive* gate, reserve fail-closed for *pre-merge/autonomous* contexts. The owner already resolved OD-2 "BUG/fail-closed" but, per three seats, without reconciling the deliberate PR-AUTO-213 consumer comment. **Owner must decide SCOPE:** fail-closed everywhere (formally clean, risks interactive bricking) vs fail-closed only in autonomous/merge contexts (preserves the documented split). What changes the call: whether interactive sessions reliably init a non-`unknown` trace — untested in the plan. (M9 holds the precondition regardless of which scope is chosen.)

### K5 — SCOPE (consensus-of-one, high-stakes): is PR-T5-4's typed graph buildable as specced?
Not a true conflict (no opposing seat) but flagged because executing T5-4 as-written produces a confidently-wrong artifact. The EXEC parser miscompile (M13) silently invalidates the headline completeness/orphan figures. **Owner action: land the regex fix + fixture INSIDE T5-4 as its first sub-step.** Residual-risk owner: whoever cites the orphan counts.

---

## 5. REVISED FIRST SPRINT (warranted — the plan's first-sprint order is unsafe as written)

The plan's first sprint bundles T0-1/T0-2/T0-3 + T1-1/T1-2/T1-3 + T2-1/T2-2. As ordered it: arms three no-op flags (M2), arms before it protects (M3), ships an already-open master lock (M4), may record nothing (M6), targets the wrong CI host (M5), can lock itself out of the engine (M7), and would revert a correct test (M1). Revised sequence below — **gate-by-gate, protect-before-arm, verify-the-wire-before-arming-the-flag, with K1 already discharged.**

**Wave 0a — RE-BASELINE & VERIFY THE WIRE (no arming yet)**
1. **Re-verify every PR's premise against executing HEAD** — RED-before transcript per gate PR on the live tree. (Closes the stale-snapshot root cause; M1.)
2. **PR-T3-1 (prose↔wiring audit), pulled forward** — produce the full per-flag × per-plane × format truth table; identify the 3 unregistered rules. Use static AST/glob introspection, NOT live-import (kernel R8). (Prerequisite for any flag flip; M2.)
3. **PR-T3-3 (drift-encoding unification), pulled forward** — pin `tools/drift.py` as THE module; reconcile the four `--type` call sites. (Prerequisite for T0-1; M6.)
4. **PR-T0-1 (drift meter), with all preconditions** — new PostToolUse event + Bash→canonical-tool resolver + drift-init/ensure-trace + golden-trace CALIBRATION test. (M6.) **Owner rules K3 here** (which quantity the meter binds to) before this closes.

**Wave 0b — PROTECT (before any arming)**
5. **PR-T2-anchor (new)** — pin `_resolve_axon_root` to the `.axon-governed` sentinel realpath; reject a disagreeing `$AXON_ROOT`. (M4.)
6. **PR-T2-1 (dev-mode), corrected** — revert dev-mode to default-OFF; test asserts defaults-OFF/reverts-OFF; define the OOB authorization channel as not-a-file-in-the-same-drawer. (M4.)
7. **PR-T2-loopreceipt (new)** — constrain `_R9_WHITELIST` to a path, not the `loop-receipt` actor. (M4.)
8. **PR-T2-flags / extend T2-2 scope** — fold `workspace/memory/longterm/*-required.md` + `dev-mode.md` into `is_protected_path`. (M3.)

**Wave 0c — ARM (only now, only what is wired & protected)**
9. **PR-T0-2 Phase A** — flip ONLY the registered flags (`r_state_surfaced`, `r_reasoning_trace`, `r_terminal_outputs`) with per-flag 2×2 {on/off}×{violating/clean} RED-before/GREEN-after tests at the claimed plane. Phase B (the 3 unregistered) stays OFF, gated on registration. (M2.) Each armed gate ships with its tested WARN-downgrade off-switch (M8).
10. **PR-T0-3** — emits-SSOT (must precede any terminal-outputs arming; the dependency the plan correctly captured).

**Wave 1 — CRUCIBLE GATE (CI-host-resolved, co-merged)**
11. **CI-host study sub-step** — determine the authoritative gating pipeline. (M5.)
12. **PR-T1-1 (rewritten per M1) + PR-T1-2 (host-correct), ATOMIC CO-MERGE** — T1-1 collapses the inline base resolution to `_changeset_base`; **DELETE the T1-3 re-point; ADD a new no-mock end-to-end test.** T1-2 authored for the gating host (`.gitlab-ci.yml` job + `GIT_DEPTH` + explicit refspec fetch if GitLab gates). Tested on a detached-HEAD fixture. (M1, M5.)

**Wave 0d — EXPERIMENT BASELINE (capture the cheap OFF arm NOW)**
13. **PR-T6-exp-baseline (minimal, pulled forward)** — capture the heavy-OFF-vs-ON measurement at today's already-disarmed state, depending only on T0-1+T0-3. **Owner rules K2 here** (HALT-gate vs advisory) and writes the pre-committed threshold (definable only after K3). (M12; the one experiment that can re-scope 27 PRs must not run last.)

**Defer to later waves (NOT in the first sprint):** PR-T2-2's full `tools/`+`settings.json` freeze (must land AFTER T0-1/T0-3/T3-3 and the Wave-1/3 rule edits — M7 self-lockout); PR-T3-2 (`unknown→BLOCK`, gated on wire-is-live + owner ruling K4 — M9); PR-T3-4 (needs grandfather — M14); PR-T5-4 (needs EXEC-parser fix — M13). Regenerate DAG.json with the hard edges, `critical-path`, `validated`, and machine-checkable per-node DoD before the sprint opens (M7); reconcile the 26/28/29 count (M10). Open an EXCEPTION REGISTER recording an owner + date for every M-item — today these are hidden risk, not owned risk.

---

## 6. EVIDENCE REGISTER (re-verified by this seat, read-only, HEAD 6ce9bd8)
- `tests/test_crucible_failopen.py`: 2 functions; `test_run_changeset_fails_closed_on_unresolvable_base` asserts `res["ok"] is False` → **K1 resolved: test asserts the FIX.**
- `crucible.py`: `_changeset_base()` at `:148`; `run_changeset` fails CLOSED at `:189-194` (`R_CHANGESET_BASE`). Empty-diff vacuous-pass already closed.
- `rules/registry._collect_rules()` → **22 rules**; registry imports `r_reasoning_trace/r_drift_gate/r_state_surfaced/r_terminal_outputs/r_coherence`; does NOT import `r_phase_tracked/r_workflow_node_order/r_no_orphan_tools` → **3 of 6 T0-2 flags are no-ops at the response gate.**
- `workspace/memory/longterm/dev-mode.md`: `value: true` → **master lock ships open.**
- `AXON_ROOT=/tmp` → `is_axon_path(KERNEL-SLIM.md)` = **False** → one-env-var write-gate bypass.
- `tools/_axon_io.py:33`: `_R9_WHITELIST = frozenset({"loop-receipt"})`; bypass at `:122/:179`.
- CI: only `.github/workflows/ci.yml` (GitHub Actions); remote GitLab `ci.tno.nl`; **no `.gitlab-ci.yml`.**
- `03-prs/DAG.json`: **29 nodes, 10 edges, 15 isolated, `critical-path: []`, `validated: null`.**

*— AUDIT DELIBERATOR (Tie-Breaker synthesis). Consensus separated from conflict; minority records (K3, K5 single-lens) preserved not averaged; K1 disambiguated by direct read and discharged. Verdict PROCEED-WITH-CHANGES, confidence 0.84. Advisory; read-only; no code or state modified.*

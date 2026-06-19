# PR backlog — AXON Re-Arm
Derived from the handoff §3 (6-tier backlog) + the 8 resolved owner decisions (01-study §Decisions).
Ordering = leverage (impact ÷ change-size), dependency-respected. Each PR is redo-until-closed: not DONE
until a STRONG automated test proves its claim (security/gate PRs must reproduce-then-block the failure).
FIRST SPRINT (council recommendation): PR-T0-1, T0-2, T0-2a, T0-3, T1-1, T1-2, T2-1, T2-2.

<!-- KERNEL-SLIM edits flagged per-PR; each needs dev-mode + per-change owner confirm. -->

## Tier 0 — Turn the lights on + plug in the meters (do FIRST; without these the rest is unmeasurable)

### PR-T0-1 — Instrument the drift detector (A1)  [CRIT] · depends —
- change: wire `drift record` from a real PostToolUse interceptor so working/drift-trace.json carries real
  `actual` tool sequences. Until this, every model-side drift claim is unfalsifiable; drift.py is decorative.
- test: PostToolUse hook fires → trace file gains the actual call; drift.py computes a non-empty verdict.

### PR-T0-2 — Arm the enforcement flags (A2 · OD-1)  [CRIT] · depends PR-T0-2a
- change: flip the `-required` flags in a governed profile (state-surfaced, reasoning-trace, phase-tracking,
  terminal-outputs, workflow-node-order, no-orphan-tools). Step 4 of scripts/enable-enforcement.sh, never run.
- test: with flags on, each rule returns BLOCK on a violating fixture and PASS on a clean one (per-rule).

### PR-T0-2a — Seed `# emits:` / `outputs:` SSOT (A2a)  [HIGH] · depends —
- change: only 5 programs declare `# emits:`; 13/16 real _phases.json lack `outputs:`. Seed them so the
  terminal-outputs gate has something to enforce BEFORE T0-2 flips its flag.
- test: every ladder/ownership program resolves a non-empty declared-outputs set; drift-lock (⊇) holds.

### PR-T0-3 — Mechanical counters (A3)  [HIGH] · depends —
- change: increment W:turn-count in reanchor_store.py (UserPromptSubmit); feed real harness token counts into
  `context record` from a hook. Re-arms every `mod N` cadence gate + context-pressure at once (kills T4 loop).
- test: two simulated turns → turn-count advances without a model STORE; context-pressure reads real tokens.

## Tier 1 — Restore the flagship gate's bite (Core Rule 13 fails OPEN today)

### PR-T1-1 — One shared changeset base resolver (B1)  [CRIT] · depends —
- change: collapse crucible.py changed_files() (:131) + _changeset_base() (:155) to ONE resolver using
  `git rev-parse --verify HEAD~1` (silent). The duplication IS the root cause — one resolver can't disagree with itself.
- test: end-to-end, single-commit repo, new untested tools/X.py, base=None → ok is False. NO monkeypatching.

### PR-T1-2 — CI fetch-depth + merge-base (B2)  [CRIT] · depends PR-T1-1
- change: set fetch-depth: 0 and fetch origin/main in crucible/test CI jobs so a real merge-base exists.
- test: CI-shaped checkout computes a non-trivial changeset; the gate is not forced-closed-on-every-PR.

### PR-T1-3 — Real CR-13 end-to-end test (B3)  [HIGH] · depends PR-T1-1
- change: the test that would have caught B1 — throwaway repo + untested neuron + run_changeset(base=None),
  assert ok False, no mocks. Re-point test_crucible_failopen.py which currently enshrines the bypass.
- test: (this PR is the test) + a meta-assert that no R13 test monkeypatches both resolvers.

### PR-T1-4 — Close R13 coverage loopholes (B4)  [HIGH] · depends PR-T1-1
- change: resolve `tests:` paths with os.path.exists; tighten _credible_reference to require a test_* token
  co-located with the stem; gate status in {A,R,C} not A-only; extend _classify to addon neurons. Re-point the
  3 tests that enshrine the bypasses.
- test: add-only / rename-launder / typo-a-filename bypass fixtures all BLOCK.

### PR-T1-5 — Frozen shrink-only test-grandfather (OD-5)  [HIGH] · depends PR-T1-1
- change: adopt test-grandfather.txt (mirrors liveness-allow.txt) — append-forbidden, can only shrink. New
  neurons always need tests; the exempt set monotonically decreases toward zero.
- test: adding an entry fails the gate; removing one passes; a new neuron not in the list still requires a test.

## Tier 2 — Protect the guard + the god-flag (security floor — highest blast radius, own review)

### PR-T2-1 — Gate the dev-mode toggle (C1)  [CRIT] · depends —
- change: deny any Write/Edit/Bash setting dev-mode=true without a human-controlled out-of-band token. The
  capability that authorizes kernel writes must not be writable without authorization.
- test: a programmatic dev-mode=true write is DENIED; the out-of-band path is ALLOWED.

### PR-T2-2 — Protect the enforcement core (C2)  [CRIT] · depends —
- change: extend is_axon_path → is_protected_path (or declare "Layer 0 — enforcement core") covering tools/
  + .claude/settings.json, gated like axon/. A plain Write to r9_axon_write.py must not neutralize R9.
- test: Write/Bash into tools/rules/*.py and .claude/settings.json BLOCKED with dev-mode OFF; allowed ON.

### PR-T2-clone — Clone/CI fail-closed (OD-6 · Wave G G3-D2)  [HIGH] · depends —
- change: merge/`-required` checks fail CLOSED or loud-N/A when working-state is absent; MUST distinguish
  "no active project" (legit-empty → allow) from "state suppressed" (→ block). Heavily tested (owner: test more).
- test: fresh-clone fixture (no working/) with the sentinel present → fail-closed; no-active-project → loud N/A, not silent pass.

### PR-T2-3 — Build G1c or delete the claim (C3)  [HIGH] · depends —
- change: implement the deferred OS write-barrier (chattr +i / 0o444 / read-only) gated by dev-mode with the
  axon/state/ allowlist, OR strike "closed by G1c" from shell.py. A comment-only control is worse than an honest gap.
- test: interpreter computed-path write to axon/ DENIED by the OS with dev-mode OFF; axon/state/ writes still work.

## Tier 3 — Close the prose↔wiring rule gap + the drift seam

### PR-T3-1 — Prose-vs-wiring meta-rule (D1)  [HIGH] · depends —
- change: a rule/test asserting every tools/rules/r_*.py is registered AND every BLOCK rule named in KERNEL-SLIM
  resolves to a wired, reachable predicate. Fix or delete the 14-of-37 unregistered rule files.
- test: an unregistered r_*.py or a kernel-named-but-unwired rule fails the meta-gate.

### PR-T3-2 — Drift-gate unknown → fail-closed (D2 · OD-2)  [HIGH] · depends PR-T0-1
- change: r_drift_gate.py:62 treats `unknown` as the fail-closed BLOCK drift.py already returns (a
  stable-by-emptiness detector manufactures false assurance).
- test: an unknown/stale trace → BLOCK; a real stable trace → PASS.

### PR-T3-3 — Unify the dual drift encoding (D3)  [HIGH] · depends —
- change: fix KERNEL-SLIM:188,341 to call the drift tool whose argparse matches (--phrase/--kind), add a
  conformance test asserting every TOOL(drift,…) in the kernel parses against the resolved tool. KERNEL edit — flag.
- test: every kernel TOOL(drift,…) literal parses (exit 0) against the resolved tool's parser.

### PR-T3-4 — R_PHASE_TRACKED to a biting runner (D4)  [HIGH] · depends —
- change: add `crucible` runner to R_PHASE_TRACKED after confirming its N/A path (no STORE(W:active-program)).
  100/105 ownership programs violate the ledger contract today; lint/audit-only never surfaces at a biting gate.
- test: a program that takes the lock but never records a transition → BLOCK at the crucible gate.

## Tier 4 — Execute the deletions + fix the broken front doors

### PR-T4-shadow — Investigate the 29 legacy programs (OD-4)  [study sub-step] · depends —
- change: audit the 29 axon/programs/ nodes (live callers? dead? duplicated in workspace?) + the dead DAG.json
  layer; record a migrate-vs-retire ADR. THEN the chosen action becomes its own PR.
- test: (investigation) — output is an ADR + a reachability report; no silent merge/ignore.

### PR-T4-1 — Fix the dead resume program (E1)  [HIGH] · depends —
- change: rewrite resume.md:27-28 to read W:active-phase + session.py recovery + the REAL event names
  (checkpoint/restore); add a contract test that filtered event names ⊆ emitted names.
- test: an interrupted session is actually detected by `resume` (today it ~always says "no interrupted sessions").

### PR-T4-2 — QUARANTINE prune + orphan gates (E2)  [MED] · depends —
- change: run _reservoir-manifest.md prune; wire-or-drop the 3 orphan gate-tools (axon_io_lint,
  emit_listener_lint, domain_validate). Removal procedure already written; only the trigger is missing.
- test: post-prune registry/disk sync stays 0-drift; each former orphan gate is either invoked by a runner or gone.

### PR-T4-3 — Test-or-delete below-radar drift tools (E3)  [HIGH] · depends —
- change: _axon_rollback.py (recovery primitive, unregistered + 0 tests = highest single risk) and queue_tool.py
  (used in 5 files, unregistered) — test + register, or delete.
- test: rollback primitive has a real round-trip test; queue_tool registered + covered, or removed with callers migrated.

### PR-T4-4 — Registry status enum + alias_of (E4 · OD-7 enabler)  [HIGH] · depends —
- change: add STUB/ALIAS/DEPRECATED status enum + alias_of/supersedes to REGISTRY.json; delete the 2 -ALIAS
  files. This is the NAMING enabler — once status/alias fields exist, every rename ships as a back-compat alias.
- test: an -ALIAS-in-filename is rejected by a registry lint; alias resolution works via the field.

### PR-T4-5 — Fix workflow-run --name (E5 · OD-7)  [HIGH] · depends PR-T4-4
- change: index canonical workflows by `name:` across domains/*/workflows/ + workflows/; namespace the workflow
  name away from the program name (paired migration). `workflow-run --name code-dev` is dead today.
- test: workflow-run --name <wf> resolves + runs; a program/workflow name collision is caught.

## Tier 5 — Honesty, counts, self-model + naming + the graph

### PR-T5-1 — Reconcile self-models (F1)  [MED] · depends —
- change: KERNEL-SLIM:2 v1.1.7 → 3.8.0; correct host-cap-enforce="self" (now false); re-title HOOKS-README
  ("PROPOSAL"); self-heal host-model on boot; add discipline docs to the freshness reconciler. KERNEL edit — flag.
- test: a self-model-drift check (version/host-cap/host-model vs reality) fails when they diverge.

### PR-T5-2 — Menu link + count integrity (F2)  [MED] · depends —
- change: audit/CI rule — every command literal in menu.md + quickstart.md resolves to a program/tool/help target;
  fix total-progs to consume snap.programs_total; surface health-score + dispatch-index staleness.
- test: a dead menu link or a stale-green dashboard fixture fails the menu-integrity check.

### PR-T5-3 — Naming conventions + authoring-guide section (F3 · OD-7)  [MED] · depends PR-T4-4
- change: adopt verb-first names; reserve bare-verb shadows by scope; `-` workflow separator; flat code-dev-*
  namespace. Write the authoring-guide NAMING section + a corpus-compliance reporter.
- test: a name violating the convention is flagged; the reporter scorecards every lint/audit rule across the corpus.

### PR-T5-4 — Generate the typed program graph (F4 · OD-3)  [MED] · depends —
- change: run the parser + a body-EXEC extractor; persist a TYPED multi-relation graph (transition vs suggests);
  add reachability/orphan/cycle checks to dag_consistency.py; fix the 2 self-loop bugs (quickstart, workspace-backup).
  Per OD-3: gate completeness on the EXEC `transition` layer.
- test: the cycle/orphan checks fire on the known defects; the ~38%-isolated count is surfaced (not hidden by "0 errors").

## Tier 6 — The experiment (after Tier 0 gives it a meter)

### PR-T6-exp — Thin-kernel heavy-ceremony OFF-vs-ON (OD-8)  [experiment] · depends PR-T0-1, PR-T0-3
- change: a controlled comparison of drift outcomes with the heavy per-turn apparatus on vs off, measured by the
  now-instrumented drift detector. The one place "more enforcement" might be wrong — may re-scope the whole backlog.
- test: (experiment) — a reproducible protocol + a written verdict with the drift deltas; preserved as an ADR.

### PR-T4-hrteam — Wire the hr-team execution seam so AXON can ALWAYS convene a real council  [HIGH] · depends —
- finding: tools/hr_team.py run_seats() BACKEND="fanout" is NOT wired to real cognition — it raises
  NotImplementedError (or stubs fake verdicts with AXON_HR_TEAM_ALLOW_STUB=1). The SELECTOR/CONVENER/
  DELIBERATOR are built; the per-seat execution seam is dormant → `hr-team --task` cannot fire a real
  council. Textbook "wired but not firing" (handoff theme T1/T2). (owner: AXON must ALWAYS trigger hr-team.)
- change: (a) add a roster-emitter mode to hr_team.py that runs SELECTOR+CONVENER and emits the per-seat
  CATALOG-PERSONA-loaded prompts as JSON (no run_seats); (b) save a reusable named `hr-team-council`
  workflow that consumes the roster, fans out real persona-seeded sub-agents, and feeds the DELIBERATOR;
  (c) update workspace/programs/hr-team*.md so "convene the council" routes through the bridge.
- test: roster-emitter returns N catalog-sourced seats incl. the mandatory process/challenger with their
  persona content; a stubbed fan-out round produces a §4.3 advisory verdict (advisory_only:true,
  verdict_distribution present). NO fabricated cognition in the tool path.
- note: this is the durable fix for "AXON must always trigger hr-team"; the running plan-review workflow
  (catalog-linked fan-out) is the working bridge until this lands.

---
# AUDIT AMENDMENTS (binding · pre-execution) — from plan-review/00-plan-audit.md (PROCEED-WITH-CHANGES 0.84)
The 10 catalog-persona specialists + 4-seat audit council verified the plan at source and found the
first sprint NOT executable as written. These amendments are binding before any PR opens. Each cites its M-item.

## Amended existing PRs
- **M1** → PR-T1-1/T1-3/T1-4 RE-BASELINE vs HEAD. The CR-13 empty-diff fail-open is ALREADY closed
  (crucible.py:148 _changeset_base, :189-194 fail-closed). DELETE T1-3's "re-point test_crucible_failopen.py"
  instruction (it would REVERT a correct passing test). Re-scope T1-1 to the residual: collapse
  changed_files() inline base (:128-134) to call _changeset_base; verify 2>/dev/null parity; ADD a new
  no-mock e2e test ALONGSIDE the existing one (do not touch it).
- **M2** → PR-T0-2 SPLIT. Phase A flips ONLY flags whose rule registry._collect_rules() loads (22 rules):
  r_state_surfaced, r_reasoning_trace, r_terminal_outputs. Phase B (r_phase_tracked, r_workflow_node_order,
  r_no_orphan_tools) stays OFF until registered — flipping them today is FALSE-GREEN. Each Phase-A flag needs
  a per-rule RED-before/GREEN-after test at the plane it arms (response vs changeset — they differ).
- **M6** → PR-T0-1 pin tools/drift.py as THE module (3 encodings exist); add drift-init/ensure-trace; add the
  NEW PostToolUse hook event + a Bash→canonical-tool resolver (tools run as Bash(python x.py)); add a
  golden-trace CALIBRATION test (match→0, one-divergence→band, reorder→diverged), not just "trace gains a call".
  T3-2 and T6-exp inherit an uncalibrated meter until this lands.
- **M9** → PR-T3-2 gate on a WIRE-IS-LIVE precondition (not "meter exists"); "no active program / stale trace"
  is the NORMAL interactive state → unknown→BLOCK bricks ~every turn. Record the bug-vs-policy decision against
  the live PR-AUTO-213 rationale in r_drift_gate.py (do not edit past it silently). Scope = conflict K4 (owner).
- **M7** → 03-prs/DAG.json regenerate with hard edges (T1-1↔T1-2 ATOMIC, T0-1→T2-2, T0-3→T2-2, T3-3→T2-2 so
  protect-settings lands AFTER the files it freezes), populated critical-path, per-node dod/proves. Anti-self-lockout.
- **M8** → T1-1, T2-1, T2-2, T2-clone, T3-2, T3-4 each gain a NAMED, tested, audited WARN-downgrade (off-switch).
  A re-arm program with no disarm command is incomplete. Wave 0 = one-command flag-disarm; Wave 2 = break-glass.

## New PRs (audit-surfaced)
### PR-T2-anchor — Pin the R9 anchor to the .axon-governed sentinel (M4)  [CRIT] · DONE 781463a (Wave G follow-up)
- $AXON_ROOT only honoured with the tracked sentinel; sentinel-less env rejected. Closed the live one-line bypass.
### PR-T2-devmode-default — dev-mode ships default-OFF (M4)  [CRIT] · depends —
- dev-mode.md currently reads value:true (master lock OPEN). Revert to default-OFF; test asserts it defaults OFF
  AND reverts OFF (not just "true is denied"). T2-1 arms enforcement on an open master key today.
### PR-T2-loopreceipt — Constrain the R9 actor-whitelist to a PATH not an actor (M4)  [CRIT] · depends —
- _axon_io._R9_WHITELIST={"loop-receipt"} skips R9 for any caller passing _actor="loop-receipt" (lines 122/179).
  Standing insider bypass. Constrain to a specific path, not an actor name.
### PR-T1-cihost — Resolve the gating CI pipeline (M5)  [CRIT] · depends —
- Only .github/workflows/ci.yml exists; remote is GitLab; NO .gitlab-ci.yml. fetch-depth:0 is a GitHub key.
  Study sub-step: determine the authoritative gating pipeline; if GitLab, author the crucible job (GIT_DEPTH +
  explicit fetch origin main). T1-1↔T1-2 co-merge or T1-1 alone bricks every shallow detached-HEAD MR.
### PR-T2-flags — Protect the flag dir (M3)  [CRIT] · depends —
- Fold workspace/memory/longterm/*-required.md + dev-mode.md into is_protected_path, co-land with T0-2 arming.
  Armed-but-unprotected flags = an agent disarms them next turn with no rule firing.

## REVISED FIRST SPRINT (audit-recommended; supersedes the original 8)
1. M1 RE-BASELINE (T1-1 vs HEAD) · 2. VERIFY-THE-WIRE — pull PR-T3-1 (prose↔wiring) + PR-T3-3 (drift parser) +
   PR-T0-1 (meter, pinned+calibrated) into Wave 0 · 3. PROTECT — PR-T2-anchor [DONE] + T2-devmode-default +
   T2-loopreceipt + T2-flags · 4. ARM only registered flags (PR-T0-2 Phase A) · 5. CO-MERGE T1-1+T1-cihost
   host-correct · 6. capture the cheap OFF baseline early (minimal PR-T6-exp before flags harden).
PRINCIPLE (audit): PROTECT-before-ARM, VERIFY-the-wire-before-ARM, RE-BASELINE-before-fix.

## OWNER-ONLY CONFLICTS (arbitrate before the affected PRs) — K2..K5
- K2: who/what holds HALT-rights (the off-switch authority). K3: does "residual MODEL drift" even BIND to the
  procedural tool-sequence meter (M6) — or is it the wrong instrument for the model question. K4: unknown→BLOCK
  SCOPE — everywhere vs autonomous/merge-only. K5: the EXEC-parser miscompile (synapse_infer.py:48 mis-parses
  EXEC(workspace/programs/X.md) → phantom 'workspace') — fix inside PR-T5-4 before the typed graph is trusted.

## OWNER ARBITRATIONS — RESOLVED 2026-06-19
- **K2 = GATE (pre-committed HALT).** OD-8 (thin-kernel experiment) can HALT the arming waves. PR-T6-exp-baseline
  must define a failure threshold + self-abort: if post-Wave-0 instrumented drift does not improve below the
  threshold, STOP the arming waves and re-open OD-8. The THRESHOLD VALUE is set after K3 (which meter) — the
  governance is decided (gate), the number waits on K3. No "re-scope with no mechanism" (avoids dissent-as-theatre).
- **K5 = FIX-FIRST + per-relation cycle policy.** PR-T5-4's FIRST sub-step lands the synapse_infer.py:48 RE_EXEC
  regex fix (currently excludes `/` and `.` → path-form EXEC collapses to phantom `workspace`) + a fixture, before
  any typed graph is trusted. Cycle policy: FATAL on the `depends` relation, LEGITIMATE on the `transition` relation
  (programs loop by design, e.g. menu↔modes). Orphan/isolation counts are not authoritative until this lands.
- **STILL OPEN (owner): K3** (does residual model-drift bind to the procedural tool-order meter, or to
  cognition/persona drift in axon_drift_log.py) — blocks K2's threshold value + PR-T0-1's meter binding.
  **K4** (unknown→BLOCK scope: everywhere vs autonomous/merge-only) — blocks PR-T3-2.

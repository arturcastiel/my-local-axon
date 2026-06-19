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

# PR-W5b — rebuild the multiple-code-dev meta-workflow so it actually runs

> **✅ MERGED — !147 (`9418569`), gate GREEN first try (passed:true, 0 blocking, 0 warn).** Verified on main:
> W:mcd-decision routing, the per-lap visit-wiring, 4 new programs registered. Branch deleted. The meta-workflow
> rebuild is DONE — every audited blocker fixed. (Remaining campaign work: W5c — e2e multi-lap drive + M2.)
>
> **Build record — committed `d6fe162` on `feat/multiple-code-dev-rebuild`, gate-first.** 11 files
> / +609/−15. ALL audited blockers fixed: C1 (W:mcd-decision edges) · C4 (abort→finalize edge + no FAIL) ·
> C5/H1 (goal-audit reads criteria from W:active-workflow + verdict-write) · H2 (flat seed schema, writer↔reader) ·
> H3 (goal-set resets loop keys) · H5 (goal-audit requires criteria in autonomous loop) · C2/C3 (workflow-run
> per-lap visit wiring, backward-compatible) · 2 goal-audit tool BLOCKs fixed · 4 new programs given OUTPUT/
> banner/DONE + registered. Verified pre-gate: 6 programs valid + 0 kernel BLOCKs; check-stale=0; check-templating=0;
> drift exit 0; rebuild test 9 passed (routing proven via the predicate engine); seed-channel test 5 passed; broad
> regression 2262 passed. Awaiting passed:true → merge. (M2 explicit-terminal + full e2e multi-lap drive → W5c.)

- **Status:** built, gating
- **Phase:** 2-harmonize · **Complexity:** L (the heart of the rebuild; touches the critical `workflow-run.md`)
- Brought NEW from `review/mcd-141` (staged): `goal-set.md`, `goal-audit.md`, `iterate-or-stop.md`,
  `audit-to-study.md`, `multiple-code-dev.yml`, `tests/test_code_dev_study_seed_channel.py`. (Skipped: the
  existing `code-dev-study.md` — handle its +21 seed-read block additively; the foreign `.cmp.md`; the stale HANDOFF.)
  `code-dev-finalize` (s6) + `code-dev` (s2 sub-workflow) already exist on main.

## DONE so far (uncommitted on the branch)
- **C1 — route the gate decision.** `multiple-code-dev.yml` s4 edges rewritten to `if: W.mcd-decision ==
  "green"|"iterate"|"abort"` (was the dead `if: decision.green`). `iterate-or-stop.md` now `STORE(W:mcd-decision,
  decision)` (renamed from the private `_iterate-or-stop-decision`). VERIFIED: the runner resolves `W.*` from live
  memory through its state-only `--ctx` (workflow-run.md:228), so the edge resolves at runtime — no runner-ctx change.
- **C4 — abort → clean terminal.** Added the explicit `abort → s6` edge (finalize closes the task either way);
  removed the `FAIL(...)` on abort in `iterate-or-stop.md` (it now emits + DONEs). No new program needed.

## REMAINING (the build, gate-first)
1. **Structural fixes (integration checklist).** All 4 brought programs FAIL `tools/test.py` — missing
   `## OUTPUT` + `▶` banner (the foreign instance never ran our validator). Add them (model on a passing neuron;
   they already have `DONE(name)`). [memory `axon-foreign-program-integration`]
2. **C5/H1 — goal-criteria channel.** `goal-set` propagate the workflow's `default-goal.acceptance-/rejection-criterion`
   into `W:current-goal` (today only id/statement/set-at); `goal-audit` WRITE `verdict.pass` /
   `verdict.unresolved-bug-after-pr` / `verdict.fatal` into `W:last-audit-verdict` (today never set → iterate-or-stop's
   pass/fatal branches inert).
3. **H2 — seed field align.** Same key `W:code-dev-study-seed`; writer (`audit-to-study`) emits `iteration` +
   `evidence.failing-tests`; reader (`code-dev-study`, the +21 block) wants `seed.iter` + top-level `failing-tests` +
   `seed.verdict`. Pick one flat schema; fix the writer + add `verdict`. Reconcile code-dev-study against main's version.
4. **H3 — run-start reset.** Clear `multiple-code-dev-iter` / `last-audit-verdict` / `mcd-decision` /
   `code-dev-study-seed` / `current-goal` at s1 (in goal-set, or an s1 reset step) so a 2nd in-session run starts clean.
5. **H5 — autonomous (DECIDED: require criteria).** goal-audit must NOT block on `QUERY(user)` in an autonomous
   loop. Default: require explicit acceptance/rejection criteria (FAIL-fast at goal-set if absent) rather than self-judge.
6. **Visit-wiring (the per-lap teeth, uses W5a).** `workflow-run.md`: compute the per-lap visit (count of the looping
   node's prior visits in `trace`) and thread it into BOTH the child run-id (`::v{n}`, line 141) and the
   `advance --parent-visit` call (line 241). CAREFUL — this is the runner every workflow uses; keep it a no-op for
   non-looping nodes (visit stays None). Resolve the dispatch-vs-guard off-by-one (see W5a `_sub_traj_run_id`).
7. **Register** the 4 new programs (`programs_registry.py generate`; no foreign mirrors).
8. **Tests.** Bring/fix `test_code_dev_study_seed_channel.py` (H2); add the e2e loop test (≥2 laps under one
   parent-run-id on the REAL runner path — the proof the mirage never had) → that overlaps W5c.

## Then
- gate-first (expect iterations like W2 had); on passed:true → merge → W5c (e2e loop/abort/depth tests + M2 lint).

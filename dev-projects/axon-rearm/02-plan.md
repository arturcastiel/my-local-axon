# Master Plan — AXON Re-Arm

> Executes the report-state handoff backlog. 28 PRs (02-prs.md), DAG'd (03-prs/DAG.json). Ordering =
> leverage (impact ÷ change-size), dependency-respected. Tier 0 is non-negotiable first: without the
> meter (A1) and the flags (A2), the system cannot tell whether any later fix worked.

## Objective
Move AXON from **"disarmed and blind"** to **"armed and instrumented"** — closing the gap between
AXON-as-specified and AXON-as-running, which the 8 councils showed is dominated by configuration +
unfinished wiring, not design error or model limitation.

## Waves (= tiers)
- **Wave 0 — Arm + instrument** (PR-T0-1/2/2a/3) · CRIT. Plug in the drift meter, flip the `-required` flags
  (seed `# emits:` first), mechanize the counters. Unblocks measurement of everything else.
- **Wave 1 — CR-13 bite** (PR-T1-1..5) · CRIT/HIGH. Fix the fail-open resolver, CI fetch-depth, a real
  no-mock test, close the coverage loopholes, frozen shrink-only grandfather (OD-5).
- **Wave 2 — Security floor** (PR-T2-1/2/clone/3) · CRIT/HIGH. Gate the dev-mode toggle, protect tools/ +
  settings, close clone fail-open (OD-6), build-or-delete G1c. **Own review — highest blast radius.**
- **Wave 3 — Prose↔wiring + drift seam** (PR-T3-1..4) · HIGH. Meta-rule for rule registration, drift-gate
  unknown→fail-closed (OD-2), unify dual drift encoding, R_PHASE_TRACKED to a biting runner.
- **Wave 4 — Deletions + front doors** (PR-T4-shadow/1..5) · HIGH/MED. Investigate the 29 legacy (OD-4),
  fix the dead resume, prune QUARANTINE, test-or-delete rollback/queue, registry status enum (OD-7 enabler),
  fix workflow-run --name.
- **Wave 5 — Self-model + naming + graph** (PR-T5-1..4) · MED. Reconcile versions/host-model, menu integrity,
  NAMING section + conventions (OD-7), generate the typed graph gated on EXEC transitions (OD-3).
- **Wave 6 — The experiment** (PR-T6-exp). Thin-kernel heavy-ceremony OFF-vs-ON (OD-8), after Wave 0's meter exists.

## Critical path (longest dependency chain)
`PR-T0-2a → PR-T0-2` (arm flags needs the emits SSOT) · `PR-T1-1 → {T1-2, T1-3, T1-4, T1-5}` (everything CR-13
hangs off the one shared resolver) · `PR-T0-1 → PR-T3-2 / PR-T6-exp` (drift-gate + experiment need the live meter) ·
`PR-T4-4 → {PR-T4-5, PR-T5-3}` (registry status enum unblocks the naming work).

## First sprint (council-recommended — do these eight first)
`PR-T0-1` · `PR-T0-2a` · `PR-T0-2` · `PR-T0-3` · `PR-T1-1` · `PR-T1-2` · `PR-T2-1` · `PR-T2-2`
→ "disarmed and blind" → "armed and instrumented". After it, compliance + drift are measurable for the first time.

## Method (owner: conservative · test-more · redo-until-closed)
Every PR ships a STRONG automated test proving its claim. Security/gate PRs (Wave 1/2/3) must
**reproduce-then-block** the failure — no fingerprint-only closure. crucible-green before test-execution.
KERNEL-SLIM edits (OD-1 prose, OD-2 lines 188/341, F1 version) are per-change owner-confirmed; the kernel
floor stays human.

## Open experiment (not a fix — a measurement)
`PR-T6-exp` (OD-8): the thin-kernel null hypothesis. If the heavy apparatus manufactures the slips it flags,
this re-scopes the whole "add enforcement" thrust. Cheap to test once Wave 0 gives it a meter.

## Decisions → PRs (traceability)
OD-1→T0-2 · OD-2→T3-2 · OD-3→T5-4 · OD-4→T4-shadow · OD-5→T1-5 · OD-6→T2-clone · OD-7→T4-4+T5-3 · OD-8→T6-exp.

---
## POST-AUDIT REVISION (binding) — plan-review/00-plan-audit.md, PROCEED-WITH-CHANGES 0.84
The catalog-persona audit found the original first sprint NOT executable as written. SUPERSEDING first sprint:
**re-baseline (M1) → verify-the-wire (T3-1/T3-3/T0-1 into Wave 0) → protect (T2-anchor[DONE]/T2-devmode-default/
T2-loopreceipt/T2-flags) → arm ONLY registered flags (T0-2 Phase A) → co-merge T1-1+T1-cihost host-correct →
capture the OFF baseline early.** Principle: PROTECT-before-ARM · VERIFY-the-wire-before-ARM · RE-BASELINE-before-fix.
See 02-prs.md "AUDIT AMENDMENTS" for the M1-M9 per-PR changes + the 5 new PRs. PR-T2-anchor (M4 AXON_ROOT
bypass) already LANDED (781463a). Owner conflicts K2-K5 await arbitration. M7 (full DAG hardening: atomic +
protect-after edges, critical-path, per-node dod) is itself a tracked amendment.

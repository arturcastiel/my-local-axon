# Plan Review — Agent Architect seat

> Council seat: **Agent Architect** (ai-ml / agent-systems, master). Charge: agent-OS architecture +
> delivery-sequencing lens — DAG/critical-path correctness (`03-prs/DAG.json`), the 8-PR first sprint cut,
> effort/risk balance, mis-/under-/over-scoped PRs, missing dependencies, and program gaps (rollback gates,
> definition-of-done, owner checkpoints). **Advisory only. Read-only.** Verified against the live tree at
> `/home/arturcastiel/projects/new-axon/axon` (branch `fix/wave-g-residual-hardening`, HEAD `6ce9bd8`).

Role-lock: I speak only as the Agent Architect. I evaluate AXON — *an OS for AI agents* — as an agent
system: its per-turn gates, hooks, memory scopes, and tool authority ARE the orchestration substrate, and
this 28-PR backlog is the plan that re-arms it. I judge topology, state/authority boundaries, failure
propagation, and the execution DAG that drives them.

---

## 1. Verdict

**SOUND-WITH-RISKS** — confidence **High** (0.82).

The plan rests on a correct architectural thesis (the system is *disarmed and uninstrumented, not
misdesigned*), the Tier-0-first sequencing is exactly right, and the load-bearing code claims I spot-checked
are true on the live tree. But the **delivery DAG that is supposed to enforce that sequencing is too thin to
do its job** — it encodes 10 of the dependencies the prose actually asserts, leaves 14 of 28 PRs as isolated
nodes, and ships with `critical-path: []` and `validated: null`. As an agent-OS-rearm program it is missing
three governance primitives my discipline treats as non-negotiable for an autonomous-actor change: a
**rollback/abort gate per wave**, an explicit **definition-of-done state per PR** (the DAG has only
`pending`), and **owner-checkpoint nodes** between the meter-existing and the meter-trusted states. None of
these is fatal; all are fixable before execution. Hence SOUND-WITH-RISKS, not SOUND.

I did **not** find a reason to call it NOT-SOUND: the critical-path narrative in `02-plan.md` is correct even
where `DAG.json` under-encodes it, and the highest-blast-radius work (Tier 2 security floor) is correctly
flagged for its own review.

---

## 2. What the plan gets right (architecture + sequencing)

- **The thesis is architecturally honest and the sequencing follows from it.** `01-study.md:7-9` and
  `00-...handoff.md:39` frame the gap as configuration + unfinished wiring. Tier 0 (`02-prs.md:9`) instruments
  the meter *before* anything is measured against it. In agent-system terms: **you cannot run a
  PLAN-ACT-OBSERVE loop with a dead OBSERVE channel.** PR-T0-1 (instrument drift) genuinely is the
  prerequisite for PR-T3-2, PR-T6-exp, and the entire drift verdict — and the DAG correctly wires
  `PR-T0-1 → PR-T3-2` and `PR-T0-1 → PR-T6-exp` (`DAG.json` edges). This is the single most important
  ordering decision and it is right.
- **The two genuinely hard dependencies are captured.** `PR-T0-2a → PR-T0-2` (seed the `# emits:` SSOT before
  flipping `terminal-outputs-required`) and `PR-T1-1 → {T1-2,T1-3,T1-4,T1-5}` (one shared resolver before
  anything that hangs off it) are both present and both correct. I verified the T0-2a premise on disk:
  `grep -rl "# emits:"` over `workspace/` returns **5** programs — matching the plan's "only 5 programs
  declare `# emits:`" claim (`02-prs.md:23`). Flipping the flag first would, as the plan says, "bite nothing."
- **The flagship bug is real and the fix is correctly scoped as a *de-duplication*, not a patch.** I read
  `tools/crucible.py`: `changed_files()` (now ~line 130) runs
  `git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1` — the second clause has **no
  `2>/dev/null`** — while `_changeset_base()` (~line 148) has `2>/dev/null` on **both** clauses. The two
  resolvers provably disagree on a shallow checkout. PR-T1-1's framing ("one resolver can't disagree with
  itself," `02-prs.md:35`) is the correct architectural move: collapse to one source of truth rather than
  patch two.
- **The instrument seam is correctly diagnosed.** I read `tools/rules/r_drift_gate.py`: the `unknown → return
  None` path is live (labeled `PR-AUTO-213`), confirming PR-T3-2 / OD-2. The plan correctly treats this as a
  consumer bug (fail-open), not an engine rewrite — consistent with theme T3 ("fix consumers and joins, don't
  rewrite engines," `01-study.md:22`).
- **The highest-authority work is fenced.** Tier 2 (dev-mode toggle, protecting `tools/` + `settings.json`)
  is flagged "own review — highest blast radius" in `02-plan.md:18` and `_meta.md:31`. From a
  tool-authority-matrix lens this is exactly the PR set that most needs a human gate, and the plan names it.
- **Decision→PR traceability is complete.** `02-plan.md:48` maps all 8 owner decisions to PRs; I cross-checked
  each against `02-prs.md` and they resolve. No orphaned decision, no PR inventing un-decided scope.
- **DoD method is stated at program level.** "redo-until-closed; STRONG automated test; security/gate PRs
  reproduce-then-block" (`02-prs.md:3-4`, `_meta.md:26-27`). The *policy* is sound; my objection in §3 is that
  it is not encoded as machine-checkable state.

---

## 3. Ranked risks / gaps (with the PRs they touch)

### R1 — The DAG under-encodes the plan's own dependency graph (HIGH). Touches the whole backlog; acutely `03-prs/DAG.json`.
`DAG.json` carries **10 edges** for **28 nodes**, max chain length **2**, and **14 isolated nodes**
(`PR-T2-1, T2-2, T2-3, T2-clone, T3-1, T3-3, T3-4, T4-1, T4-2, T4-3, T4-shadow, T5-1, T5-2, T5-4`). The prose
asserts dependencies the DAG drops:
- **PR-T1-2 (CI fetch-depth) is the actual enable-condition for the corrected resolver in CI** — the handoff
  says so explicitly (`00-...handoff.md:116`, "A corrected resolver still needs history"). It is correctly an
  edge in the DAG (`T1-1 → T1-2`), but PR-T1-3's *no-mock end-to-end test* also presumes a real merge-base,
  i.e. it really depends on **both** T1-1 *and* T1-2, not T1-1 alone. The DAG has `T1-1 → T1-3` only. A
  reviewer running T1-3 before T1-2 will get a test that can only ever fail-closed-on-every-commit, which is
  not the behavior under test.
- **Tier-0 hook collisions are invisible.** I read `.claude/settings.json`: there is **no `PostToolUse` hook
  today**. PR-T0-1 (drift via PostToolUse) and PR-T0-3 (mechanical counters fed "from a hook") both mutate the
  *same* `settings.json` hook surface, and PR-T2-2 proposes bringing `settings.json` under write-protection.
  These three touch one shared, security-sensitive file with zero edges between them. That is a merge-order
  and a self-lockout hazard (see R3), and the DAG says nothing.
- **Isolation ≠ independence.** Several "isolated" nodes share a primitive: `is_axon_path`/`is_protected_path`
  lives in `tools/_axon_paths.py` and is consumed by `r9_axon_write.py`, `_axon_io.py`, and `shell.py`
  (verified). PR-T2-2 (extend `is_axon_path → is_protected_path`), PR-T2-clone (fail-closed on absent state),
  and PR-T2-3 (G1c OS write-barrier) all operate on that one classifier and on `dev-mode` gating. They should
  carry ordering or at least a "same-file / same-primitive" soft-edge so two PRs don't refactor the classifier
  in conflict.

**Fix:** before execution, regenerate `DAG.json` with every dependency the prose asserts, add `kind:"touches"`
soft-edges for shared-file PRs (Tier 0 hook surface; Tier 2 path classifier), and populate `critical-path`
and `validated`. Right now the DAG is decorative relative to `02-plan.md` — which is the exact failure mode
(`T2: honesty ≠ enforcement`) this whole project exists to correct. A re-arm program whose own delivery DAG
is unplugged is ironic and risky.

### R2 — No rollback / abort gate per wave (HIGH). Touches Wave 0 (`PR-T0-2`), Wave 2 (`PR-T2-1/2/clone/3`).
"Every autonomous tool needs an owner, scope, and rollback story." Two PRs change the *running posture* of an
agent OS and have no documented revert path:
- **PR-T0-2 arms six `-required` flags at once** (`state-surfaced, reasoning-trace, phase-tracking,
  terminal-outputs, workflow-node-order, no-orphan-tools`, `02-prs.md:17`). The DoD ("each rule BLOCKs a
  violating fixture, PASSes a clean one") proves each rule *works* — it does **not** prove the six together
  don't brick live sessions on false positives. This is precisely Seat-4's dissent preserved in the study
  (`01-study.md:54-56`, OD-8). Arming six BLOCK rules in one PR with one combined revert is over-scoped for a
  posture change; it should be a staged rollout (flag-by-flag or a two-stage WARN→BLOCK) with a named
  one-command disable. The kill-switch already exists conceptually (`scripts/enable-enforcement.sh` step 4 is
  the on-switch) — the plan must name its off-switch as the rollback gate and test it.
- **PR-T2-1 (gate dev-mode), PR-T2-2 (protect `tools/` + `settings.json`), PR-T2-3 (OS write-barrier)** modify
  the capability that authorizes kernel writes. If T2-2 protects `settings.json` and a later Tier-0/Tier-3 PR
  needs to edit `settings.json` (T0-1/T0-3 add hooks; T3-3 edits KERNEL lines), the program can lock *itself*
  out of its own remaining edits. There is no "break-glass" node.

**Fix:** add a per-wave rollback gate to `02-plan.md`: Wave 0 = "one-command flag-disable, tested";
Wave 2 = "documented break-glass + dev-mode out-of-band token rehearsed before T2-2 lands." Sequence T2-2
(protecting `settings.json`) **after** all PRs that still need to edit `settings.json` (T0-1, T0-3, T3-3),
or give T2-2 an explicit governed-write path for them. This is a missing dependency *and* a missing gate.

### R3 — Self-lockout / ordering hazard inside the security floor (HIGH). Touches `PR-T2-2` vs `PR-T0-1`, `PR-T0-3`, `PR-T3-3`.
Sharpened from R1/R2 because it is the single most likely way this program stalls mid-flight. PR-T2-2 brings
`.claude/settings.json` under the R9-style write-gate (verified: `settings.json` is currently ungated,
outside `axon/`). But PR-T0-1 and PR-T0-3 *add hook entries to that same file*, and PR-T3-3 edits
`KERNEL-SLIM.md:188,341` (also a protected surface under the kernel-floor rule). The DAG places T2-2 as an
isolated node with no edge to any of them. **Concrete failure:** if a maintainer runs T2-2 before T0-3, the
mechanical-counter hook wiring now requires the dev-mode/out-of-band path that T2-1 just made deliberately
hard — and if T2-1 isn't landed yet, the governed path may not exist at all. Order matters and is unstated.

**Fix:** add edges `PR-T0-1 → PR-T2-2`, `PR-T0-3 → PR-T2-2`, and a note that any post-T2-2 edit to
`settings.json`/kernel goes through the governed dev-mode path. Treat `settings.json` as a shared resource
with an explicit "freeze after" point in the program.

### R4 — Definition-of-Done is prose, not machine-checked state (MEDIUM). Touches every PR node in `DAG.json`.
The DoD policy (`02-prs.md:3`) is excellent, but `DAG.json` nodes carry only `status:"pending"` — there is no
`test-claim`, no `dod`, no `gate` field. For a *conservative, redo-until-closed* program, the DAG should be
the ledger that proves a PR met its bar (e.g. `status ∈ {pending, in-progress, test-green, blocked, done}` +
a `proves` pointer to the reproduce-then-block fixture). Without it, "DONE" is a human assertion — the exact
`T4: model-/human-executed bookkeeping` weakness (`01-study.md:22`) the backlog is trying to mechanize.
Eat your own dog food: encode DoD in the DAG so the program's own progress is instrumented.

### R5 — Two "PRs" are not PRs; mixing investigation/experiment nodes into the delivery DAG distorts the critical path (MEDIUM). Touches `PR-T4-shadow`, `PR-T6-exp`.
`PR-T4-shadow` is explicitly a *study sub-step* ("output is an ADR," `02-prs.md:104`) and `PR-T6-exp` is an
*experiment* whose verdict "may re-scope the whole backlog" (`02-prs.md:160`). These are decision/measurement
nodes, not code deliverables. Counting them in the "28-PR" total and the wave plan conflates *spikes* with
*ships*. More importantly, **PR-T6-exp is a gate that can invalidate Tiers 1–5**, yet it sits at the very end
with no feedback edge back to the enforcement-adding PRs it might overturn (OD-8, `01-study.md:54`). An
architect does not put the experiment that could falsify the program *after* the program has shipped.

**Fix:** retype these nodes (`kind:"spike"` / `kind:"experiment"`) and — for T6-exp — either (a) pull a
*minimal* heavy-OFF-vs-ON measurement forward to right after Wave 0 (it only depends on T0-1 + T0-3, both
already in the first two waves), so its verdict can still re-scope Tiers 3–5, or (b) explicitly accept that
Tiers 1–5 ship regardless and document T6-exp as a *post-hoc* check. Leaving it implicitly able to
"re-scope the whole backlog" from the last slot is an unmanaged feedback loop.

### R6 — The 8-PR first sprint over-commits the security floor relative to its own "own review" caveat (LOW-MEDIUM). Touches `PR-T2-1`, `PR-T2-2`.
The first-sprint cut (`02-prs.md:5`, `02-plan.md:34`) is `T0-1, T0-2a, T0-2, T0-3, T1-1, T1-2, T2-1, T2-2`.
Pulling **two CRIT security-floor PRs** (T2-1, T2-2) into the same sprint as the arm-and-instrument work is
defensible by leverage, but it contradicts the plan's own "Tier 2 = highest blast radius, own review"
posture (`_meta.md:31`). From a sequencing standpoint the first sprint's *purpose* is "armed and
instrumented" — T2-1/T2-2 are *protect-the-guard*, a different goal. They are correctly urgent (the guard is
less protected than what it guards) but bundling them dilutes the sprint's definition-of-done and front-loads
the work most likely to need a careful human review cycle.

**Fix (optional):** keep the first sprint to the arm+instrument+CR-13 spine
(`T0-1, T0-2a, T0-2, T0-3, T1-1, T1-2` = 6) and run T2-1/T2-2 as a tight, separately-reviewed second sprint
with the Tier-2 rollback gate from R2. If the owner keeps all 8, add the explicit own-review checkpoint
between the Tier-0/1 PRs and the Tier-2 PRs so they aren't reviewed as one block.

### R7 — Owner-checkpoint nodes between "meter exists" and "meter trusted" are missing (LOW). Touches `PR-T0-1`, `PR-T3-2`, `PR-T6-exp`.
The drift verdict's whole falsifiable-prediction logic (`01-study.md:25-28`) hinges on a moment where the
owner *reads the now-real meter and decides whether drift subsided*. That is a human-in-the-loop checkpoint,
not a PR — but it gates T3-2 (fail-closed on `unknown` is only safe once the meter reliably distinguishes
`stable` from `empty`) and T6-exp. The plan has no node for "owner reviews first real drift traces." Add one
between Wave 0 and Wave 3.

---

## 4. Specific changes to make before execution (ordered, actionable)

1. **Regenerate `03-prs/DAG.json` to match the prose** (fixes R1, R4). Add the missing hard edges
   (`T1-2 → T1-3` so the no-mock test has a merge-base; `T0-1 → T2-2`, `T0-3 → T2-2`, `T3-3 → T2-2` so the
   protect-`settings.json`/kernel PR lands last among files it freezes). Add `kind:"touches"` soft-edges for
   shared-file clusters: the Tier-0 hook surface (`settings.json`: T0-1, T0-3) and the Tier-2 path classifier
   (`_axon_paths.py`/`dev-mode`: T2-1, T2-2, T2-3, T2-clone). Populate `critical-path` and `validated` (both
   null today). Add per-node `dod`/`proves` fields so DONE is machine-checkable.
2. **Add a per-wave rollback gate to `02-plan.md`** (fixes R2). Wave 0: name and *test* the one-command flag
   disable for PR-T0-2 (the off-switch for the six armed flags). Wave 2: rehearse the dev-mode out-of-band
   break-glass *before* PR-T2-2 freezes `settings.json`.
3. **Stage PR-T0-2** (fixes R2). Do not arm six `-required` flags in one BLOCK step. Either flag-by-flag, or a
   two-stage WARN-then-BLOCK, each with its own clean+violating fixture, so a false-positive storm is
   reversible per-flag rather than all-or-nothing.
4. **Resolve the `settings.json` freeze ordering explicitly** (fixes R3). Land PR-T2-2 *after* T0-1, T0-3, and
   T3-3, or give T2-2 a documented governed-write path those later PRs use. Make this a real edge, not a note.
5. **Retype the non-code nodes and pull the experiment forward** (fixes R5). Mark `PR-T4-shadow` as a spike
   and `PR-T6-exp` as an experiment; run a minimal heavy-OFF-vs-ON drift comparison immediately after Wave 0
   (it only needs T0-1 + T0-3) so OD-8's verdict can still re-scope Tiers 3–5 instead of arriving after them.
6. **Cut the first sprint to the arm+instrument+CR-13 spine OR insert an explicit own-review checkpoint**
   (fixes R6). Recommended: first sprint = `T0-1, T0-2a, T0-2, T0-3, T1-1, T1-2`; T2-1/T2-2 as a separate
   reviewed sprint. If the owner keeps all 8, add a mandatory Tier-2 review gate between the Tier-0/1 and
   Tier-2 PRs.
7. **Add two human-in-the-loop checkpoint nodes** (fixes R7): "owner reviews first real drift traces" between
   Wave 0 and Wave 3 (gates T3-2's fail-closed flip), and "owner reads T6-exp verdict / re-scope decision."

---

## 5. Architect's bottom line

The plan's *intellectual* architecture is sound: right diagnosis, right Tier-0-first instinct, right
"fix the seams not the engines" remediation style, verified code claims, complete decision traceability. What
is under-built is the *delivery* architecture — the DAG that is supposed to make the sequencing enforceable
is thin (10 edges, 14 isolated nodes, empty critical-path), and three governance primitives I require for any
change to an autonomous actor's running posture are absent: **per-wave rollback gates, machine-checkable DoD
state, and owner checkpoints**, plus an unmanaged feedback loop where the experiment that can falsify the
whole program (PR-T6-exp) sits last. All seven fixes in §4 are cheap and pre-execution. Make them and this
moves to SOUND. Ship it as-is and the first stall will be a self-lockout on `settings.json` or a
false-positive storm from arming six flags at once — both predictable, both preventable.

*— Agent Architect seat. Smallest topology that satisfies the requirement; least authority per tool;
recoverable state over impressive demos. Role-lock held throughout.*

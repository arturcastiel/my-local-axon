# Plan Review — Technical Program Manager

**Reviewer role:** Technical Program Manager (delivery / DAG / sequencing / risk)
**Scope reviewed:** `HANDOFF.md`, `01-study.md`, `02-plan.md`, `02-prs.md`, `03-prs/DAG.json`, source handoff `research/00-AXON-report-state-handoff.md`. Read-only verification against the live tree at `/home/arturcastiel/projects/new-axon/axon`.
**Stance:** Advisory only. No code or state modified.

---

## 1. Verdict

**SOUND-WITH-RISKS — confidence: high (≈0.85).**

The backlog is well-conceived as *engineering*: the leverage ordering (impact ÷ change-size) is correct, Tier 0 is rightly non-negotiable-first, the critical-path intuition is right, and the dependency edges that exist in `DAG.json` are all individually correct in direction. The plan is *not yet sound as a program*: it is a 28-node backlog with only **10 declared edges**, no `critical-path` populated (`DAG.json:9` is `[]`), no per-PR effort/size estimate, no rollback gate, no definition-of-done beyond "a strong test is green," and no owner-decision checkpoint structure even though five of the eight Tier-0/first-sprint PRs touch the security floor or the kernel. The single biggest delivery risk (below) is that **the first sprint arms enforcement (PR-T0-2) before the enforcement core is protected (PR-T2-2) and before the meter that tells you arming worked is trusted (PR-T0-1)** — three PRs the plan treats as parallel-independent that have a real causal ordering. That is a sequencing defect inside the most important sprint, not a wording nit.

I would not block execution, but I would require the four changes in §4 before the first PR merges.

---

## 2. What the plan gets right

1. **Tier-0-first is correct and defensible, and it is the right *kind* of first move.** `02-plan.md:3-5` and `01-study.md:51` make the meter-before-fixes argument; I verified the premise on the tree: there are **zero `*-required` flags** in `workspace/memory/longterm/` (the dir holds host-cap/cognition/host-model state + `dev-mode.md` only), **no `PostToolUse` hook** in `.claude/settings.json` (only `PreToolUse`, `Stop`, `UserPromptSubmit`), and **no `drift-trace.json` on disk**. The diagnosis is real, so sequencing the instrument first is sound.

2. **The CR-13 critical path is identified correctly.** PR-T1-1 (one shared resolver, B1) is the true root and `DAG.json` correctly fans T1-2/T1-3/T1-4/T1-5 off it. I confirmed the defect on the tree: `crucible.py:131` (`changed_files`) runs `git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1` and on failure falls through to a non-empty `base="HEAD~1"` string and *diffs anyway*, while `_changeset_base()` at `:148-157` has `2>/dev/null` on **both** clauses and returns `None` (fail-closed) on empty. The two resolvers provably disagree; collapsing them is the correct single fix and correctly gates the four downstream PRs.

3. **Decision→PR traceability is complete and auditable.** `02-plan.md:48` and `02-prs.md` map all eight owner decisions (OD-1..OD-8) to specific PRs. As a TPM I can trace every resolved decision to a deliverable — that is rare and good.

4. **The redo-until-closed / reproduce-then-block bar is a real definition-of-done for the *gate/security* PRs** (`02-prs.md:3-4`, `02-plan.md:37-39`). For Tier-1/2/3 PRs this is strong: "reproduce the failure, then block it" is an acceptance test a reviewer can check.

5. **The riskiest tier is flagged and quarantined for its own review** (`02-plan.md:17`, `_meta.md:31`): Tier 2 = security floor, "own review — highest blast radius." Correct instinct.

6. **The open experiment is honestly carried as a measurement, not a fix** (PR-T6-exp), and its dependency on the meter (T0-1, T0-3) is correctly encoded in `DAG.json:278-286`. A weaker plan would have dropped the dissent.

---

## 3. Weaknesses / risks / gaps — ranked by severity

### S1 — CRITICAL (delivery): The first sprint arms enforcement before the core is protected and before the meter is trusted. Missing dependency edges. *(PR-T0-2, PR-T0-1, PR-T2-1, PR-T2-2)*
The first sprint (`02-plan.md:34`, `02-prs.md:5`) is `T0-1, T0-2a, T0-2, T0-3, T1-1, T1-2, T2-1, T2-2`. `DAG.json` declares **T0-2 depends only on T0-2a** — it is otherwise treated as independent of T0-1, T2-1, T2-2. That is a program-sequencing error:
- **Arm-before-protect.** PR-T0-2 flips six `-required` flags, converting ~6 rules to live BLOCK. But the enforcement engine itself (`tools/`, `.claude/settings.json`) and the `dev-mode` god-flag are *not yet protected* — that is PR-T2-1/T2-2, scheduled in the *same* sprint with no ordering edge. Arming enforcement whose own kill-switch is still world-writable is the textbook "lock and key in the same drawer" the handoff calls out (`research/00...:124`). T2-1 and T2-2 should land **before** T0-2, or at minimum be hard-sequenced ahead of it within the sprint.
- **Arm-before-you-can-see.** The whole thesis (`02-plan.md:3-5`) is "without the meter you can't tell if a fix worked." Yet T0-2 (the highest-blast-radius behavioral change in the sprint — it can start BLOCKing real sessions) has no declared dependency on T0-1 (the meter) or T0-3 (mechanical counters that several armed rules read). If you arm `reasoning-trace`/`phase-tracking` while turn-count is still model-executed (T0-3 not landed), you can BLOCK on counters that freeze exactly when drift is worst (theme T4, `research/00...:79`).
- **Fix:** add edges `T0-1 → T0-2`, `T2-1 → T0-2`, `T2-2 → T0-2`, and `T0-3 → T0-2` (or explicitly justify each as independent in the PR spec). At minimum, re-order the first sprint so the *protect + instrument* PRs precede the *arm* PR. As written, the single most dangerous PR is scheduled first-among-equals with the weakest dependency guard.

### S2 — HIGH (delivery): No rollback gate / blast-radius control for the behavioral-change PRs. *(PR-T0-2, PR-T2-1, PR-T2-2, PR-T2-3, PR-T3-2, PR-T3-4)*
"Redo-until-closed" is a *forward* gate (don't merge until the test is green). There is **no reverse gate**: nothing in the plan says what happens when an armed flag (T0-2) or a fail-closed flip (T3-2 `unknown→BLOCK`, T3-4 phase-tracked-bites, T2-clone clone-fail-closed) produces false-positive BLOCKs that brick live sessions. The handoff itself preserves Seat-4's warning that fail-closed-by-default "can brick sessions on false positives" (`research/00...:186`), and `r_drift_gate.py:57-61` shows the `unknown→None` was a *deliberate* prior choice (PR-AUTO-213) precisely to avoid that — so T3-2 is reversing a guard someone added on purpose. A program needs:
- a documented rollback path per behavioral PR (flag flip-back is trivial for T0-2; T2/T3 code reverts need a named procedure),
- a "soak / canary" step: arm a flag in WARN-only for N sessions before BLOCK,
- a kill-switch owner.
None of this is in the plan. For an "OS for agents" that will be running while you re-arm it, this is the gap most likely to cause an outage.

### S3 — HIGH (delivery): PR-T0-1 is under-scoped — it is net-new hook plumbing, not "wire the decorative tool." *(PR-T0-1)*
The PR spec (`02-prs.md:11-14`) reads as a small wiring fix ("wire `drift record` from a real PostToolUse interceptor"). On the tree there is **no `PostToolUse` hook registered at all** — `.claude/settings.json` has only `PreToolUse/Stop/UserPromptSubmit`. So T0-1 must (a) author a new hook wrapper, (b) register a new hook *type* in `settings.json` — which is exactly the file T2-2 is about to lock down — (c) handle hook-payload field-name verification (the `HOOKS-README` caveat the enforce script flags), and (d) prove the trace is non-empty end-to-end. That is the largest, riskiest Tier-0 item, it is on the critical path for T3-2 and T6-exp, and it is tagged the same `[CRIT]` weight with no size estimate distinguishing it from the one-line flag flips. **Under-scoped + un-estimated + on the critical path = the schedule risk hides here.** It also creates a latent edge: T0-1 edits `settings.json`, T2-2 protects `settings.json` → these two must be ordered (T0-1 before T2-2, or T0-1 done through the dev-mode path T2-1 establishes).

### S4 — MEDIUM (DAG hygiene): `critical-path` is empty and `validated` is null — the DAG is unvalidated. *(03-prs/DAG.json)*
`DAG.json:9` `"critical-path": []` and `:8` `"validated": null`. The plan *prose* asserts a critical path (`02-plan.md:28-31`) but the machine artifact does not encode it, so no tool can check it and no one can see slack/float. For a 28-PR / 7-wave program this is the core PM instrument and it is blank. Also: with only 10 edges across 28 nodes, **18 PRs are modeled as fully independent** — almost certainly false (S1, S3, and S6 each name a missing edge). The DAG under-constrains reality, which makes the "everything else is parallelizable" read dangerously optimistic.

### S5 — MEDIUM (scoping): The 26-vs-28 PR count is inconsistent across artifacts. *(HANDOFF.md vs 02-plan.md vs DAG.json)*
`HANDOFF.md:16,26` says "26-PR backlog"; `02-plan.md:3` and `02-prs.md` say 28; `DAG.json` has 28 nodes. The drift is the later-added T0-2a, T2-clone, T2-3, T4-shadow not back-propagated to the handoff. Minor, but it is a self-consistency smell in a program whose entire thesis is "the OS misreports its own counts" (theme T7) — the plan should not replicate the bug it is fixing. Reconcile to one number.

### S6 — MEDIUM (sequencing): PR-T1-2 (CI fetch-depth) is dependency-ordered after T1-1 but is arguably the *true* enable-condition and should ship coupled. *(PR-T1-1, PR-T1-2)*
`DAG.json:243` edges `T1-1 → T1-2` is correct in direction, but operationally the corrected resolver (T1-1) **does nothing in CI without** `fetch-depth: 0` (T1-2) — a single-commit shallow checkout still gives a degenerate merge-base. Shipping T1-1 alone leaves the flagship gate still effectively inert in CI until T1-2 lands. These two should be one mergeable unit or explicitly co-required in the sprint exit criteria, otherwise you can mark "CR-13 fixed" (T1-1 green) while CR-13 is still open in CI. This is precisely the "honesty ≠ enforcement" trap (theme T2) at the program level.

### S7 — LOW (scoping): PR-T4-shadow is a study task wearing a PR id, with an undefined fan-out. *(PR-T4-shadow)*
`02-prs.md:104-107` is an *investigation* whose output is "an ADR + the chosen action becomes its own PR." That unnamed downstream PR is not in the DAG, has no id, no estimate, and no wave. As a TPM I can't schedule "TBD work discovered later." Either time-box it as a spike with a hard decision date, or pre-create the placeholder node so the backlog is honest about its own size.

### S8 — LOW (definition-of-done): "Strong automated test" is a strong DoD for gates but undefined for the non-gate PRs. *(PR-T4-2, PR-T5-1, PR-T5-2, PR-T4-shadow, PR-T6-exp)*
For QUARANTINE prune (T4-2), self-model reconciliation (T5-1), menu integrity (T5-2), the experiment (T6-exp), and the investigation (T4-shadow), "reproduce-then-block" doesn't apply and the DoD is fuzzy. Each needs its own acceptance criterion (e.g., T5-1: "version self-model check fails CI when KERNEL-SLIM ≠ VERSION"). Without it these tail PRs will sprawl.

---

## 4. Specific changes I would make before execution

1. **Re-sequence the first sprint and add the missing edges (fixes S1, S3).** New intra-sprint order: **T1-1 → T1-2** (CR-13, independent track, can run in parallel) and **{T2-1, T2-2} → T0-1 → {T0-2a → T0-2, T0-3}**. Add DAG edges `T2-1 → T0-2`, `T2-2 → T0-2`, `T0-1 → T0-2`, `T0-3 → T0-2`, `T0-1 → T2-2` (T0-1 touches settings.json which T2-2 locks). Rationale: protect the core and stand up the meter *before* you arm. If the owner deliberately wants to arm-first, that must be an explicit, recorded decision, not a silent gap in the DAG.

2. **Add a rollback gate + WARN-soak to the definition-of-done for every behavioral-change PR (fixes S2).** For T0-2, T2-1, T2-2, T2-3, T2-clone, T3-2, T3-4: require (a) a named revert procedure, (b) an initial WARN-only window before BLOCK where the rule can fire, (c) a designated kill-switch owner. Make "rolled back cleanly in a test" part of closure for the fail-closed flips (T3-2, T2-clone) — the plan already says reproduce-then-block; add reproduce-then-block-then-revert-clean.

3. **Re-scope and re-estimate PR-T0-1 explicitly as net-new hook plumbing, and split if needed (fixes S3).** Make the spec state: author + register a new `PostToolUse` hook, verify payload field names per HOOKS-README, prove non-empty trace end-to-end. Consider splitting into T0-1a (register the hook) and T0-1b (wire drift record + prove trace). Add a size/effort tag to every PR so the critical path has weights.

4. **Populate the DAG instrument (fixes S4, S5, S7).** Set `DAG.json:critical-path` to the computed longest weighted chain, set `validated`, add the edges from change 1, reconcile the PR count to 28 across `HANDOFF.md`/`02-plan.md`/`02-prs.md`, and either give PR-T4-shadow a hard decision date + a placeholder successor node or down-rank it out of the critical wave. Then re-derive the critical path; my hypothesis is it runs **T2-1/T2-2 → T0-1 → T0-2 (arm) → T3-2 → T6-exp**, i.e. longer than the prose's CR-13 chain once the arm-before-protect and meter dependencies are honest.

5. **Couple T1-1 and T1-2 as a single exit criterion (fixes S6).** "CR-13 fixed" is not DONE until the gate bites in a CI-shaped checkout — make T1-2 a required co-merge, not a follow-on, or add it to the sprint's exit gate so no one can claim the flagship is armed while it is still open in CI.

6. **Add owner-decision checkpoints to the schedule, not just to the study (program gap).** OD-1..OD-8 are *resolved* but several PRs reverse deliberate prior choices (T3-2 reverses PR-AUTO-213's `unknown→None`; T0-2 reverses ship-dark). Add an explicit per-change owner-confirm checkpoint at the *PR-merge* boundary for: every KERNEL-SLIM edit (T3-3, T5-1, and the OD-1/OD-2 prose lines the plan already flags), the arm flip (T0-2), and the security-floor PRs (T2-*). The plan mentions per-change confirm for kernel edits (`02-plan.md:40-41`) but does not place these as gates in the delivery flow.

---

## 5. Bottom line for the owner

The engineering plan is right; the **program** is thin. The biggest single delivery risk is **arm-before-protect-and-instrument inside the first sprint** (S1): PR-T0-2 flips live BLOCKs while the enforcement core (T2-2), the kill-switch (T2-1), and the meter (T0-1) are still pending and un-linked in the DAG. Close that with explicit edges and a re-sequence, add a rollback/WARN-soak gate for the behavioral PRs, re-scope T0-1 as net-new hook work, and populate the DAG's critical-path/validated fields. Do those four things and this moves from SOUND-WITH-RISKS to SOUND.

*Report file: `/home/arturcastiel/projects/new-axon/axon/my-axon/dev-projects/axon-rearm/plan-review/tech-program-manager.md`*

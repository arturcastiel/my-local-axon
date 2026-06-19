# Plan Review — Challenger Seat (mandatory dissent)

**Seat:** Challenger (`catalog/professions/process/challenger.md`) — structured dissent, assumption
testing, minority-influence preservation, pre-mortem.
**Mode:** STEELMAN-OPPOSITION + ASSUMPTION-LEDGER + PRE-MORTEM. Advisory only. Read-only; no code,
tests, or state modified. Load-bearing claims re-verified against the live tree at
`/home/arturcastiel/projects/new-axon/axon` (HEAD `6ce9bd8`).
**Role-lock:** I argue the case *against* the plan. Where the plan is right I say so, but my charge is
to find the failure mode the council is converging past. I challenge the plan, not the planners.

---

## 1. Verdict

**SOUND-WITH-RISKS — confidence 0.72 that the plan as written will *partially* make AXON worse before it
makes it better, and 0.55 that its central sequencing claim ("Tier 0 first, then everything is measurable")
is materially mis-ordered.**

I cannot honestly return NOT-SOUND: I re-verified the plan's core factual spine and it holds (the
`crucible.py` resolver disagreement is real, zero `*-required` flags exist on disk, the drift gate discards
`unknown`, the failopen test monkeypatches the defect away, the dual `drift` tool divergence is real). The
diagnosis is good. But the *direction of action it prescribes* rests on a single assumption I believe is
unproven, and the very first sprint contains a latent no-op that will produce **false green** — the one
outcome an instrumentation-first plan must never produce. That is enough to withhold SOUND.

A SOUND verdict would require: (a) moving the prose↔wiring audit (PR-T3-1) and the thin-kernel experiment
(PR-T6-exp) *before* the arming wave, and (b) a written, pre-committed failure criterion for the whole
"add enforcement" thrust. Neither is in the plan today.

---

## 2. What the plan gets right (steelmanned in its favor, so my dissent is not cheap)

These are strengths I verified, not courtesies:

- **The factual base is real, not asserted.** I re-ran the checks. `tools/crucible.py` `changed_files()`
  (the `:131` clause) uses `git merge-base ... 2>/dev/null || git rev-parse HEAD~1` — the fallback has **no**
  `2>/dev/null`, while `_changeset_base()` (the `:155` clause) has `2>/dev/null` on *both* sides. The two
  resolvers provably disagree on a shallow/single-commit checkout. PR-T1-1's "one resolver can't disagree
  with itself" is the correct fix.
- **The failopen test genuinely enshrines the bug.** `tests/test_crucible_failopen.py:21-22`
  monkeypatches *both* `_changeset_base` and `changed_files` to constants — the test passes no matter what
  the real resolver does. PR-T1-3's no-mock end-to-end test is not redundant; it is the only test that would
  bite. This is the strongest single PR in the backlog.
- **Tier-0-before-Tier-1 dependency logic is locally correct.** PR-T3-2 (drift-gate fail-closed) and
  PR-T6-exp both genuinely depend on PR-T0-1 (the live meter). `r_drift_gate.py:62` does discard `unknown`
  (verified). You cannot measure a fix you cannot read.
- **OD-2 is handled with appropriate nuance.** The plan calls `unknown → return None` a bug, but the live
  code annotates it as a deliberate "PR-AUTO-213" design choice (menu-badge surfacing, not silent). The
  study's OD-2 framing ("bug or policy") preserves that — it does not steamroll the existing intent. Good.
- **The method discipline is right.** "Reproduce-then-block, no fingerprint-only closure" for security/gate
  PRs is exactly the standard that would have caught the original failopen. With 359 test files on disk, the
  regression safety net is real, which materially lowers the "arming bricks every session" risk.

I want this on the record: the *diagnosis* is high quality. My dissent is about the *prescription* and the
*order*, not the findings.

---

## 3. The single most dangerous assumption

> **"Adding enforcement to a correct-but-disarmed architecture moves it toward its specified behavior —
> therefore the right action is to arm, and the only question is sequencing."**

Every wave except Tier 6 treats this as settled (OD-1 "ARM IT", OD-8 demoted to a single late experiment).
The plan's own preserved dissent (01-study §Open experiment; handoff §4 "Preserved dissent") states the null
hypothesis and then **structurally buries it**: PR-T6-exp is the *last* PR, depends on Wave 0, and is the
only check on a thesis that, if true, *re-scopes 27 of the 28 PRs*. That is mandatory-dissent-as-theatre —
the exact failure mode my seat exists to prevent ("Mandatory dissent must be structured or it becomes
theatre").

**Why the null hypothesis is not a curiosity — the steelman (OD-8):**

The live kernel is 757 lines (`wc -l axon/KERNEL-SLIM.md` = 757). Its output band carries **89**
per-turn `ASSERT/TOOL/STORE/RETRIEVE` operations (verified count) and references **31** rules. The kernel
*itself* concedes (`axon/KERNEL-SLIM.md:89-95`, verified) that compaction degrades the cognition frame —
and the safeguards against that drift are routed *through the same model-executed bookkeeping that
compaction erodes* (this is the plan's own Theme T4). So the causal chain the apparatus flags as "model
drift" is plausibly **manufactured by the apparatus's own attention cost**: every ceremony token is
attention not spent on the task, and more gates means more ceremony.

If that is true — and *no data exists either way*, which the handoff admits — then PR-T0-2 (arm 6 flags),
PR-T0-3 (mechanical counters that add more per-turn ops), PR-T3-4 (add `crucible` to a biting phase-tracked
runner), and the entire Wave 3–5 enforcement expansion are pushing **in the wrong direction**: they increase
the per-turn ceremony load on the faculty that is already the load-bearing weakness. The plan would then be
*measuring drift with one hand while increasing it with the other*, and PR-T0-1's "now-instrumented detector"
would credit the architecture for catching slips the architecture caused.

**The disconfirming test the plan defers but should front-load:** the OFF-vs-ON comparison (PR-T6-exp)
is described as "cheap to test." If it is cheap, there is no defensible reason to run it *after* committing
27 PRs of enforcement expansion. Run a minimal version *in Wave 0*, immediately after PR-T0-1 gives it a
meter, and **gate the arming waves on its result.** Sequencing the one experiment that could falsify the
thrust to the very end is the plan choosing not to look until it is too late to act.

---

## 4. Ranked risks / gaps (each tied to an assumption, a missing test, or a decision consequence)

### R1 — CRITICAL — Arming flags for rules that are not wired produces FALSE GREEN. `PR-T0-2`, `PR-T3-1`
The single most damaging finding of this review, and it is *inside the first sprint*.
PR-T0-2 proposes flipping six `-required` flags: `state-surfaced, reasoning-trace, phase-tracking,
terminal-outputs, workflow-node-order, no-orphan-tools`. I checked each against the active rule registry
(`tools/rules/registry.py` `_collect_rules()`):

- WIRED: `r_state_surfaced`, `r_reasoning_trace`, `r_terminal_outputs`
- **NOT in the collected rule set:** `r_phase_tracked`, `r_workflow_node_order`, `r_no_orphan_tools`

Three of the six flags PR-T0-2 flips control rules that **the engine never loads** (14 of 33 `r_*.py` files
are unregistered, including `r_cognition_language` — the kernel's self-described "loudest rule," CR-11).
Flipping a flag for an unregistered rule sets a state key that *nothing reads*. The runtime posture appears
"armed" (`verify.py status` shows flags on), the drift meter (PR-T0-1) reads a quiet trace, and the council
concludes "armed and instrumented" — when in fact half the named enforcement surface is a no-op. **This is
the precise false-assurance failure the plan was written to eliminate, reintroduced in its first sprint.**

→ **Fix:** PR-T3-1 (prose↔wiring meta-rule, the audit that catches exactly this) MUST run *before* PR-T0-2,
not in Wave 3. You cannot arm what you have not verified is wired. The plan's own dependency graph has this
backwards. At minimum, PR-T0-2 must be split: flip only flags whose rule is registered AND has a green
per-rule BLOCK test, and *block* the rest behind PR-T3-1.

### R2 — HIGH — The dual-drift divergence poisons the meter PR-T0-1 depends on. `PR-T0-1`, `PR-T3-3`
The instrument the whole plan is sequenced around may be wired to the wrong tool. Verified: the kernel calls
`TOOL(drift, record --type persona-bleed --detail ...)` at `KERNEL-SLIM.md:188` and `:341`. But the *active*
`tools/drift.py` (mtime Jun-19, the live one) `record` subcommand requires `--tool` (line 330) and has no
`--type/--detail`. The `--type/--detail` interface lives only in the *stale* `workspace/tools/drift.py`
(mtime May-26, line 208). So the kernel's drift-record calls hit the wrong parser → exit 2 → **nothing
logged.** PR-T0-1 wires a PostToolUse interceptor, but if it records through the same divergent surface, the
"now-instrumented" detector PR-T3-2, PR-T6-exp, and the §4 drift verdict all depend on is recording into a
parser mismatch. **PR-T3-3 (unify the encoding) is a hard prerequisite of PR-T0-1, yet sits in Wave 3.**
The critical path in 02-plan.md (`PR-T0-1 → PR-T3-2 / PR-T6-exp`) omits this back-edge.

### R3 — HIGH — No pre-committed failure criterion for the thrust; the falsifiable prediction has no gate.
`PR-T6-exp`, whole plan
01-study §Drift root-cause states a falsifiable prediction ("instrument + arm + counters; if drift subsides,
it was process wearing a model costume"). A prediction without a **decision gate** is not falsifiable in
practice — there is no PR that says "if drift does NOT subside after Wave 0, HALT the arming waves and
re-open OD-8." My seat's standard: "This plan lacks a credible failure criterion." Define, *before
execution*, the threshold (e.g., post-Wave-0 drift-divergence rate vs a baseline) at which the plan
self-aborts. Otherwise the 28-PR backlog has no off-ramp and OD-8 cannot actually re-scope anything.

### R4 — HIGH — Tier 2 security-floor PRs alter the kernel's write capability and are mis-grouped with
gradual fixes. `PR-T2-1`, `PR-T2-2`, `PR-T2-3`
PR-T2-1 (gate the dev-mode god-flag) and PR-T2-2 (protect `tools/` + `.claude/settings.json`) change *what
can write to the enforcement core* — the highest blast radius in the repo, correctly flagged "own review."
But there is a bootstrapping hazard the plan does not address: the enforcement-core PRs (Wave 1–5) *edit
files under `tools/`*. If PR-T2-2 lands first and protects `tools/` behind a dev-mode gate, every subsequent
PR must toggle dev-mode to modify a rule — and PR-T2-1 has just made dev-mode require an out-of-band token.
The plan never sequences its own ability to keep editing the engine after it locks the engine. **Pre-mortem:
the plan locks itself out of `tools/` mid-execution.** Sequence T2-1/T2-2 *after* the Wave 1/3 rule edits,
or define the dev-mode workflow the executor itself will use.

### R5 — MEDIUM — PR-T0-2a "seed emits first" may be load-bearing for correctness, not just coverage.
`PR-T0-2a → PR-T0-2`
Flipping `terminal-outputs-required` (PR-T0-2) before every program declares `# emits:` means programs with
no declared outputs hit the gate. The plan treats T0-2a as a coverage enabler ("something to bite"), but if
any *live, in-use* program lacks `outputs:` (13/16 `_phases.json` lack it, per study), arming the flag could
BLOCK working programs mid-session. The plan asserts "drift-lock (⊇) holds" as the T0-2a test but does not
require a *census of currently-running programs* before the flip. Add: enumerate active programs, confirm
each resolves a non-empty declared-outputs set, *then* flip — fail-closed on any gap, not on the aggregate.

### R6 — MEDIUM — "60/30/10 architecture/process/model" is an unmeasured prior presented as a finding.
whole plan, `PR-T6-exp`
The handoff is admirably honest that the model share is "unmeasured and over-attributed because the meter
records nothing" — yet the same paragraph commits to ~10% irreducible model and builds the entire ordering
on "drift is process, not model." That is a prior, not a measurement, and the plan spends 27 PRs of effort
on the strength of it before PR-T6-exp tests it. The epistemics cut both ways: if "unmeasured causes inflate
toward the convenient explanation," then "it's process, just finish the wiring" is *also* a convenient
explanation for an owner who would rather configure than redesign. Hold the 60/30/10 as a hypothesis to be
measured in Wave 0, not a result that justifies Waves 1–6.

### R7 — LOW/MEDIUM — Scope creep: 26 PRs (02-prs.md header) → 28 PRs (02-plan.md). whole plan
The HANDOFF and 02-prs.md say "26-PR backlog"; 02-plan.md says 28. Minor, but in a plan whose whole virtue is
"count the surface honestly" (Theme T7: "counts and self-models are quietly wrong"), an unreconciled PR count
in the plan's own front matter is a small instance of the disease it diagnoses. Reconcile before execution.

---

## 5. Specific changes to the plan before execution (decision gates, not vetoes)

1. **Re-order: PR-T3-1 (prose↔wiring audit) and PR-T3-3 (unify drift encoding) move into Wave 0, before
   PR-T0-2 and as a prerequisite of PR-T0-1.** Rationale: R1 + R2. You cannot honestly claim "armed and
   instrumented" while arming no-op flags and recording through a mismatched parser. This is the single
   highest-priority change.

2. **Split PR-T0-2.** Phase A: flip only flags whose rule is in `registry.py` `_collect_rules()` AND has a
   passing per-rule reproduce-then-block test. Phase B: the remaining flags stay OFF until their rules are
   registered (gated on PR-T3-1). No flag is flipped for an unregistered rule. (R1)

3. **Promote a minimal PR-T6-exp into Wave 0.** Immediately after PR-T0-1, run a small OFF-vs-ON ceremony
   comparison and **record a baseline drift rate.** Make the Wave 1+ enforcement-expansion PRs *conditional*
   on the experiment not showing ceremony-induced drift. (§3, R3, R6)

4. **Add an explicit HALT gate (a written failure criterion) to the plan front matter:** "If, after Wave 0,
   instrumented drift-divergence does not fall below {threshold} relative to the Wave-0 baseline, STOP the
   arming waves and re-open OD-8 before any Wave 3–5 enforcement expansion." Without this, OD-8 cannot
   actually re-scope anything and the falsifiable prediction is unfalsifiable in practice. (R3)

5. **Re-sequence Tier 2 relative to the engine edits, or document the dev-mode self-edit workflow.** Ensure
   the plan does not lock `tools/` (PR-T2-2) and the dev-mode key (PR-T2-1) before the Wave 1/3 PRs that must
   still edit rules. (R4)

6. **Add an active-program census to PR-T0-2a's test claim** — every *currently-running* program must
   resolve non-empty declared outputs before `terminal-outputs-required` flips, fail-closed on any gap. (R5)

7. **Demote the 60/30/10 attribution to a labeled hypothesis everywhere it appears** (01-study, plan
   objective), pending the Wave 0 measurement. (R6)

8. **Reconcile the 26-vs-28 PR count** across HANDOFF / 02-prs.md / 02-plan.md. (R7)

---

## 6. Minority report (preserve, do not average away)

Even if the owner rejects every re-ordering above, **one item is non-negotiable from a decision-quality
standpoint:** the plan must not flip a `-required` flag for a rule the engine does not load (R1), and must
not declare the system "instrumented" while the kernel's drift-record calls hit the wrong parser (R2). Those
two are not matters of sequencing taste — they are the difference between *armed* and *appears armed*, which
is the exact illusion this entire project exists to destroy. If the council ships Wave 0 without fixing R1
and R2 first, it will have rebuilt the disease (false-green self-report) inside the cure, and the drift meter
it then trusts will be measuring a system that is lying to it about its own enforcement surface.

The plan's diagnosis earned my respect. Its first sprint, as currently ordered, has not yet earned the word
"armed."

---

*Challenger seat, AXON Re-Arm plan review. Structured dissent tied to verified assumptions and missing
decision tests; no personal or motive-based objection. Closure is not blocked — the plan is executable with
the eight changes above as decision gates. Advisory only.*

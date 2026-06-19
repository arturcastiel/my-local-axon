# Plan Review — Applied LLM / Agent-Reliability Researcher

**Reviewer role:** Applied LLM / Agent-Reliability Researcher (named specialist)
**Scope:** `axon-rearm` plan — `HANDOFF.md`, `01-study.md`, `02-plan.md`, `02-prs.md`, source handoff `research/00-AXON-report-state-handoff.md`
**Mode:** READ-ONLY. Advisory only. No code, tests, or state modified. Live-tree facts re-verified on the checkout at `/home/arturcastiel/projects/new-axon/axon` (branch `fix/wave-g-residual-hardening`).
**Date:** 2026-06-19

---

## 1. Verdict

**SOUND-WITH-RISKS — confidence HIGH (≈0.8).**

The plan's central epistemic move — *instrument the drift meter first (PR-T0-1), then measure, and do NOT pre-harden against model statelessness* — is **correct and well-reasoned from an agent-reliability standpoint.** It refuses the unfalsifiable-by-default explanation ("the model can't hold state") in favor of the demonstrated one ("nobody plugged in the meter"), and it sequences the work so the open question (OD-8 / PR-T6-exp) becomes answerable. That is exactly the right posture.

But the plan is sound *as a thesis* and risky *as currently sequenced*. Three things stand between "epistemically sound" and "executes safely":
1. **A concrete arming trap** I verified on the live tree: PR-T0-1 + the existing boot auto-init + PR-T3-2 compose into a gate that BLOCKs essentially every interactive turn. The plan does not flag this.
2. **The thin-kernel experiment (PR-T6-exp / OD-8) is not yet falsifiable** — it has no operationalized metric, no unit of analysis, no confound controls, and no defined "drift outcome." As written it cannot settle the dissent it exists to settle.
3. **The ~10% irreducible-model-drift figure is an unmeasured prior dressed as an estimate**, and the plan partly forgets its own caveat downstream.

None of these is fatal. All are fixable before execution. Hence SOUND-WITH-RISKS, not NOT-SOUND.

---

## 2. What the plan gets right (from my lens)

- **The first-principles ordering is correct.** `01-study.md:25-28` and the handoff §4 (`research/00-AXON-report-state-handoff.md:160-176`) refuse to attribute drift to the model until the instrument exists. This is the single most important call in the whole document and it is right. "Unmeasured causes inflate toward the convenient explanation" (`research/…:172`) is the correct prior for any agent-reliability investigation. Tier 0 before everything is non-negotiable and the plan treats it as such (`02-plan.md:3-5`, `02-prs.md:9`).

- **It correctly identifies model-executed bookkeeping (Theme T4) as the load-bearing reliability weakness.** `research/…:78-79` is the sharpest observation in the corpus: AXON routed *around* statelessness by putting state in files, then routed its *safeguards* back through markdown ops the model must choose to run — so "the counters freeze exactly when drift is worst." PR-T0-3 (mechanical counters in `reanchor_store.py` / a token hook) attacks this at the root. Moving `W:turn-count` off model discipline and onto a `UserPromptSubmit` hook is the correct fix and it re-arms every `mod N` cadence gate at once (`02-prs.md:26-30`). This is the highest-leverage reliability change in the backlog and it is correctly placed in Tier 0.

- **The compaction model is broadly accurate.** The claim that the system prompt decays from "active rules" to "inert text" under compaction (`research/…:170`), and that the up-to-5-turn cognition-frame window is the genuine irreducible residue, matches how long-horizon context degradation actually manifests: instruction-following salience decays with distance/compaction, and self-referential "always do X every turn" directives are precisely the kind most eroded. The kernel itself concedes this (`axon/KERNEL-SLIM.md:171` "compaction can clear L:cognition-frame between turns"). The plan's mental model here is sound.

- **"Prompt-as-program" is treated with appropriate skepticism.** The kernel's own honesty note (`axon/KERNEL-SLIM.md:89-95`) — rules are advisory until hooks + flags are active — is correctly read by the plan as *the tell*, not a credential (Theme T2, `research/…:66-67`). The plan does not mistake a 757-line markdown kernel that *says* "cannot be bypassed" for an enforcement mechanism. That is the correct stance: prose in the context window is a soft prior over model behavior, not a guarantee, and the plan's entire Tier 1/Tier 2 thrust is about converting prose into hooks.

- **The dissent is preserved, not flattened.** `01-study.md:54-56` and `research/…:178` keep Seat-4's null hypothesis alive as PR-T6-exp instead of burying it. From a reliability-research standpoint this is exactly right — the heavy-ceremony-causes-the-slips hypothesis is real, plausible, and the plan resists the temptation to assume its own conclusion.

- **OD-2 / PR-T3-2 (drift-gate `unknown` → fail-closed) is correctly diagnosed.** I confirmed `tools/drift.py` already computes a fail-closed `unknown` verdict (`_unknown_gate`, drift.py:226-235, 247-300) but `tools/rules/r_drift_gate.py:62` silently `return None` on it. The consumer discards the producer's verdict. The plan's framing — "fix the consumer/seam, not the engine" (Theme T3) — is accurate.

---

## 3. Weaknesses, risks, and gaps (ranked by severity)

### S1 — CRITICAL · The arming trap: PR-T0-1 + boot auto-init + PR-T3-2 compose into a gate that BLOCKs every tool-using turn. (touches PR-T0-1, PR-T3-2, and the boot path)

This is the most important finding in this review and the plan is silent on it. I verified it end-to-end on the live tree:

1. `axon/BOOT.md:182-188` already auto-inits the drift trace at boot with `drift init --no-program`, producing a trace with **`expected=[]`** (drift.py:142-158). This is intentional today — with no `actual` calls and `expected=[]`, `compute_score` returns `0.0` → stable.
2. **PR-T0-1** wires a `PostToolUse` interceptor that appends real tool calls to `actual` (`02-prs.md:11-14`). No such hook exists today — I confirmed zero `PostToolUse` references in the repo and none in `.claude/settings.json`.
3. The moment the first real tool call lands, the trace is `expected=[] , actual=[<tool>]`. In `compute_score` (drift.py:114-125): `n = min(len(actual), len(expected)) = min(1,0) = 0` → the function returns **`1.0`**. `classify(1.0)` → **`diverged`**. `gate_decision(1.0)` → **`{decision: "halt", modifier: -50}`** (drift.py:240-241). I executed the scoring logic to confirm: `expected=[] actual=[clock,calc] -> 1.0`.
4. **PR-T3-2** then changes `r_drift_gate.py` so non-stable states BLOCK. Today `unknown` returns `None` (silent); the PR's job is to make the gate *bite*. A `diverged` state already returns BLOCK at `r_drift_gate.py:74-82`.

**Net effect:** once PR-T0-1 lands and a session is in the default no-program (interactive) trace, *every turn that calls any tool* scores 1.0 → diverged → and once PR-T3-2 / armed gates are on, the output gate BLOCKs. I confirmed there is **no special-case guard** in the gate path for the empty-`expected` / `<no-program>` trace — `_evaluate_gate` (drift.py:247-300) passes `expected=[]` straight into `compute_score`.

This is the canonical failure mode the whole field warns about: **arming a gate whose evidence model is wrong bricks the session.** It is also precisely the "ceremony that degrades the model rather than helping it" risk I was charged to assess — here it does not just degrade, it halts. The drift detector as built measures "deviation from a declared program," which is *meaningless for free-form interactive chat* (there is no declared program, so any tool use is infinite deviation).

**Fix (must precede or accompany PR-T0-1):** the drift detector needs an explicit `expected=[]` semantics decision. Either (a) `compute_score` returns `0.0` (or `gate_decision` returns `stable`) when `expected == []` — i.e. "no program declared → drift is undefined → quiet, not halt"; or (b) the `PostToolUse` interceptor only records against an *active program* trace (`drift init --program …`), and never against the `--no-program` boot trace. Option (a) is the smaller, safer change and should be added as an explicit acceptance criterion on **PR-T0-1** and re-asserted in **PR-T3-2**'s test matrix ("no-program trace + N tool calls → gate stays quiet"). Without this, the first sprint's "arm + instrument" delivers a self-DoS.

### S2 — HIGH · The thin-kernel experiment (PR-T6-exp / OD-8) is not yet falsifiable. (touches PR-T6-exp)

OD-8 is the most valuable experiment in the plan and the one I was specifically asked to scrutinize. As written (`02-prs.md:159-162`, `01-study.md:45-46`, `research/…:178`) it is a *direction*, not a *design*. It will not produce a defensible answer because:

- **No operational definition of "drift outcome."** The plan says "measured by the now-instrumented drift detector" — but that detector measures tool-sequence edit-distance against a declared program (drift.py:90-125). That metric (i) does not exist for the interactive surface where the cognition-frame slips actually happen, and (ii) measures program-conformance, **not** the cognition-frame/persona-bleed slips that OD-8 is about. The experiment's hypothesis is about *cognition slips the heavy kernel may manufacture* (`research/…:178`); the instrument it names measures *tool-order deviation*. **Metric ≠ hypothesis.** This is a construct-validity hole large enough to invalidate the result either way.

- **The confound that dominates this experiment is uncontrolled: task-content variance.** Drift in an agentic session is driven far more by *what task is being run* and *how long the session is* than by kernel ceremony. An OFF-vs-ON comparison over different conversations measures task difficulty, not ceremony. Without a fixed task battery run under both conditions, the deltas are noise.

- **Order/learning and prompt-caching confounds.** Running OFF then ON (or vice versa) on the same tasks introduces order effects; running them in separate sessions introduces between-session token/compaction-state variance. Prompt-caching behavior also differs between a 757-line kernel and a thin one in ways that change latency and possibly sampling, which can correlate with drift.

- **No unit of analysis or stopping rule.** Per-turn? Per-session? Per-task? How many replicates? Stochastic decoding means a single OFF/ON pair is uninformative — you need N replicates per condition per task and a pre-registered effect-size threshold, or the "verdict" is a coin flip narrated as science.

- **The kernel cannot cleanly be turned "off."** "Heavy-ceremony OFF" is underspecified. Is it: flags off (the current disarmed state)? The kernel prose removed from context? Only the per-turn output-block ceremony removed? Each is a different independent variable. The plan must name the exact manipulation, because "off" today already *is* the disarmed baseline — so "ON" must be carefully defined as the *armed* Tier-0 state, which means **PR-T6-exp is measuring the very thing Tier 0 just turned on**, and its result could retroactively invalidate the arming thrust (the plan acknowledges this re-scoping risk at `02-plan.md:44-45` but gives the experiment no power to actually trigger it).

**This is salvageable and worth doing** — see §4 for the protocol it needs. But as currently scoped it is an experiment-shaped placeholder, and shipping it as-is risks producing a confident-but-meaningless verdict that gets baked into an ADR (`02-prs.md:162`).

### S3 — HIGH · The "~10% irreducible model" figure is an unmeasured prior presented as an estimate, and the plan drifts from its own caveat. (touches the drift verdict; informs PR-T6-exp, PR-T0-1, PR-T0-3)

`01-study.md:26-28` and `research/…:164` give "~60% architecture/process · ~30% config · ~10% irreducible model." The handoff is admirably explicit that "the model share is unmeasured and over-attributed because the meter records nothing" (`01-study.md:27`). Good. But:

- **A number with one significant figure on an unmeasured quantity invites false precision.** Downstream readers will quote "~10%" as if it were measured. It is a prior. I would either (a) drop the number entirely and say "model share is currently *unmeasurable*; the prior is *small but unknown*," or (b) explicitly tag it as `prior, not measurement` everywhere it appears. The plan does this once and then lets the number travel naked.

- **The falsifiable prediction is sound but under-instrumented for the model question.** `01-study.md:28` and `research/…:174`: "if drift subsides after Tier 0, it was process wearing a model costume." Correct logic. But the *residual* (the genuinely model-side part) can only be isolated if you can measure cognition-frame slips on the interactive surface — which, per S1/S2, the current detector cannot do (it measures program conformance). **So even after Tier 0, the plan as written cannot cleanly size the model share.** It can show "drift symptoms subsided," but symptom ≠ the cognition-frame mechanism. The plan needs an interactive-surface cognition-slip counter (persona-bleed events per turn, frame-restore events per turn — both of which the kernel already emits at `axon/KERNEL-SLIM.md:188,341`) wired into the meter, not just tool-order edit-distance. This is a small addition to PR-T0-1's scope and it is what actually answers the owner's question.

### S4 — MEDIUM · Arming the per-turn gates (PR-T0-2 / PR-T0-3) adds real per-turn token + compute load; the plan never budgets it. (touches PR-T0-2, PR-T0-2a, PR-T0-3)

I was asked whether arming per-turn gates helps or adds self-degrading ceremony. The honest answer: **mostly helps, but the plan under-accounts the cost, and the cost is paid in the exact currency (attention/context) that drift is about.**

- The per-turn ceremony is already substantial. The "Response gate" alone (`axon/KERNEL-SLIM.md:80-95`) mandates, every turn: a `STORE(W:reasoning-trace)`, an instruction-source ASSERT, a `TOOL(verify, output)` call, an output-mode ASSERT — plus the cognition-language gate (two ASSERTs *before any reasoning step*, `:157-163`), the coherence guardian scan (`:174-193`), turn+prompt logging (`:107-131`), and the output-layer block with a `drift check` + `anticipate` call + turn-count write (`:133-149`). The `reanchor_store.py` hook already fires **3 subprocesses per turn** (memory set, prompt_log, anticipate); PR-T0-3 adds a 4th (turn-count) and a token-record hook.
- **The good news:** PR-T0-3 moves bookkeeping *off* the model and *onto* hooks. This is strictly reliability-positive — it removes load-bearing markdown ops from the model's per-turn burden (the T4 fix). Mechanical counters do not consume model attention. This is the right direction and *reduces* ceremony-on-the-model even as it adds ceremony-on-the-host.
- **The risk:** arming `R_REASONING_TRACE` / `R_STATE_SURFACED` / cognition-language as **BLOCK** (PR-T0-2) means the model must emit a syntactically-valid AXON-LANG reasoning trace *every turn* or be halted. Under compaction — exactly when the frame erodes — this is most likely to fail, producing a BLOCK cascade at the worst moment. The kernel's own mid-loop check is set to `mod 5` precisely "to avoid overhead" (`axon/KERNEL-SLIM.md:172`); arming the per-turn variant to BLOCK removes that mercy. **Recommendation:** arm these gates at **WARN/confidence-penalty first** (which the drift gate already supports via the `-30` modifier, drift.py:243), gather the instrumented data PR-T0-1 now provides, and only promote to BLOCK after the false-positive rate is *measured* to be acceptable. The plan currently flips straight to BLOCK (`02-prs.md:18-20`) with no WARN-soak period — which is inconsistent with its own "measure first" thesis.

### S5 — MEDIUM · The reasoning-trace is written by the audited entity about itself — a known-weak reliability signal. (touches PR-T0-2, and any gate consuming `W:reasoning-trace`)

`research/…:79` flags it: "the reasoning-trace is written by the audited entity about itself." From a reliability standpoint this is a genuine limitation: a model producing a post-hoc AXON-LANG trace of "the ops it used" is producing a *narrative*, not a faithful execution log — LLM self-reports of their own process are unreliable and confabulation-prone. Gating on the *presence and syntax* of a trace (which is what `R_REASONING_TRACE` checks, `axon/KERNEL-SLIM.md:84`) is defensible as a discipline nudge; **reading the trace as ground truth about what happened is not.** The plan should be explicit that `W:reasoning-trace` is a *compliance ritual*, not a *measurement* — and that the real execution signal is the `PostToolUse` tool log from PR-T0-1 (which *is* faithful). The drift verdict and PR-T6-exp should lean on the tool log and the mechanical event counts, never on the self-authored trace.

### S6 — LOW · Dual cognition-frame keys double the loss surface; no PR consolidates them. (gap — no PR owns it)

`research/…:84`: two cognition-frame keys (`L:cognition-frame` + `W:reasoning-mode`) "double loss probability for no redundancy." I confirmed both are asserted every turn (`axon/KERNEL-SLIM.md:158-159`) and independently restored (`:341`, `:596-597`). From a reliability standpoint, two keys that must agree and are checked independently is a strictly worse design than one — it doubles the probability that *some* check fires a false frame-loss. No PR in the backlog collapses these. Minor, but it is a free reliability win that the plan misses; consider folding into PR-T3-1 (the prose-vs-wiring meta-rule) or PR-T5-1 (self-model reconciliation).

---

## 4. Specific changes I would make before execution

1. **(Blocks PR-T0-1 / PR-T3-2 — do this first) Fix the empty-`expected` gate semantics.** Add to PR-T0-1's acceptance test: *a `--no-program` trace plus N recorded tool calls keeps the gate `stable`/quiet, never `diverged`.* Implement either `compute_score` returns `0.0` when `expected == []`, or the `PostToolUse` interceptor records only against an active `--program` trace. Re-assert this in PR-T3-2's matrix. **Without this, the first sprint bricks interactive sessions.** This is S1 and it is the gating change.

2. **(Re-scope PR-T6-exp into a real protocol before running it.)** Give OD-8 a falsifiable design:
   - **Hypothesis (pre-registered):** "Heavy per-turn ceremony increases cognition-frame slip rate." H0 = no difference.
   - **Independent variable, named exactly:** kernel ceremony level — e.g. ARMED-FULL (Tier-0 armed) vs ARMED-MINIMAL (per-turn output-block ceremony stripped, identity/write-gate retained). Not "the disarmed baseline," since that is a different confounded variable.
   - **Dependent variable that matches the hypothesis:** cognition-frame slip rate = (persona-bleed events + frame-restore events) **per turn**, sourced from the events the kernel *already* emits (`axon/KERNEL-SLIM.md:188,341`) — *not* tool-sequence edit-distance. Plus a task-success rate as a guardrail (ceremony that reduces drift but tanks task completion is not a win).
   - **Fixed task battery:** the same ≥10 scripted multi-turn tasks under both conditions, long enough to trigger ≥1 compaction.
   - **Replicates + stopping rule:** ≥N runs per (task × condition) with a pre-set minimum detectable effect; report effect size + a dispersion measure, not a single anecdote.
   - **Confound controls:** counterbalance condition order; hold the task battery, the host model id, and the window size fixed; note prompt-cache state. Run paired by task.
   - **Verdict rule, pre-committed:** define in advance what delta re-scopes the backlog vs confirms the arming thrust.
   - Without this, do **not** let PR-T6-exp's output become an ADR — an underpowered verdict baked into an ADR is worse than no experiment.

3. **(PR-T0-1 scope add) Instrument cognition-frame slips on the interactive surface, not just tool order.** Wire the persona-bleed / frame-restore events (`axon/KERNEL-SLIM.md:188,341`) into the meter as a per-turn count. This is the signal that actually sizes the "model share" of drift (S3) and the metric PR-T6-exp needs (S2). The current edit-distance detector cannot answer the owner's root-cause question on the surface where it matters.

4. **(PR-T0-2 sequencing) Arm per-turn gates at WARN/penalty first, BLOCK after measurement.** Use the data PR-T0-1 now provides to measure the false-positive rate of `R_REASONING_TRACE` / `R_STATE_SURFACED` / cognition-language under real (and compacted) sessions *before* promoting them from WARN to BLOCK. This is consistent with the plan's own "measure first" thesis; flipping straight to BLOCK (`02-prs.md:18-20`) is not. (S4)

5. **(Drift verdict hygiene) Stop quoting "~10%" naked.** Replace with "model share currently *unmeasurable*; prior is *small but unknown*," or tag every occurrence `prior, not measurement`. Add to the §4 prediction the explicit caveat that "drift symptoms subsided" is necessary but not sufficient to bound the model share — only the per-turn cognition-slip counter (change 3) can do that. (S3)

6. **(Reliability framing) Declare `W:reasoning-trace` a ritual, not a measurement.** Document that gates may check its *presence/syntax* but no consumer may read it as ground truth; the faithful execution signal is the `PostToolUse` tool log. (S5)

7. **(Nice-to-have) Collapse the dual cognition-frame keys** (`L:cognition-frame` + `W:reasoning-mode`) into one, folded into PR-T3-1 or PR-T5-1. Two keys that must agree double the false-frame-loss surface. (S6)

---

## 5. Bottom line for the owner

The plan's *epistemics are right*: instrument before attributing, refuse the unfalsifiable model excuse, mechanize the counters, preserve the dissent. Keep all of that. The two things that will hurt you in execution are (a) a concrete, verified arming trap where PR-T0-1 + the boot auto-init + PR-T3-2 turn the drift gate into a per-turn session-halter (fix the empty-`expected` semantics *first*), and (b) a thin-kernel experiment that, as written, cannot answer the question it exists to answer — it needs a real metric (cognition slips, not tool-order edit distance), a fixed task battery, replicates, and a pre-registered verdict rule before you let its output become an ADR. Arm the per-turn gates at WARN first and promote to BLOCK only on measured false-positive rates — that is your own "measure first" principle applied to the gates themselves.

*Advisory only. Live-tree facts (zero `*-required` flags; boot `drift init --no-program` at `axon/BOOT.md:186-188`; `compute_score([], [t]) → 1.0` at `tools/drift.py:114-125`; no `PostToolUse` hook in `.claude/settings.json`; `r_drift_gate.py:62` silent on `unknown`; 757-line `axon/KERNEL-SLIM.md`; `reanchor_store.py` already firing 3 subprocesses/turn) were re-verified on the checkout on 2026-06-19.*

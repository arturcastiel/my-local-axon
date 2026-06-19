# Plan Review — LLM Behaviour Analyst seat

> Council: AXON Re-Arm plan review. Seat: **LLM Behaviour Analyst** (ai-ml / prompt-engineering, senior).
> Persona source: `workspace/hr-team/catalog/professions/ai-ml/llm-behaviour-analyst.md`.
> Scope of charge: the **LLM lens** on Tier-0 — is "instrument-then-measure, don't pre-harden against model
> statelessness" epistemically sound? Are the compaction / context-loss / prompt-as-program assumptions and the
> **~10% irreducible-model drift share** right? Does arming per-turn gates *help*, or add ceremony that itself
> degrades the model? **Advisory only — read-only review; no code, plans, or state were modified.**
> Role-lock active: I contribute only the behavioural-analyst viewpoint and separate **observed** from **inferred**.

---

## 1. VERDICT

**SOUND-WITH-RISKS** · confidence **0.78** (high on the headline epistemics, medium on the calibration details).

The Tier-0 thesis — *do not spend effort hardening against model statelessness until the meter exists; finish
the wiring, flip the flags, mechanize the counters, then measure the residual* (`research/00-...md` §4, §6;
`01-study.md` §Drift root-cause) — is, from a behavioural-evidence standpoint, **the correct ordering and the
correct epistemic posture.** "Nobody plugged in the meter" is a *demonstrated* cause; "the model can't hold
state" is, today, an *unfalsifiable* one, and sound epistemics weight the demonstrated cause higher until the
meter exists. That instinct is exactly what my discipline would prescribe: **one surprising transcript is a
hypothesis, not evidence; probe before you name a behaviour.**

The reason it is **not** an unqualified SOUND is that the plan's own *instrument* — the thing Tier-0 plugs in
to make the model-share measurable — **cannot measure model cognition at all** as currently specified, and the
plan does not notice this. `PR-T0-1` instruments `tools/drift.py`, which scores **tool-call-sequence edit
distance vs a statically-extracted expected sequence** (`drift.py:69-125`). That is a *procedural-conformance*
meter, not a *model-behaviour* meter. The actual model-cognition signal — persona-bleed, cognition-frame slip,
assistant-mode reversion — lives in a **different tool** (`axon_drift_log.py`, `--phrase/--source/--kind`) that
the kernel **mis-calls** (`KERNEL-SLIM.md:188,341` invoke `TOOL(drift, record --type persona-bleed ...)`, but
`drift.py record` only accepts `--tool` → argparse exit 2 → nothing logged). So the plan's "measure the residual
model drift" promise is, on the current artifact, **measuring the wrong quantity with the right name.** The
verdict is SOUND because the *ordering* and *posture* are right; WITH-RISKS because the **falsification
instrument the whole epistemic argument rests on is mis-specified**, and that defect is invisible in the plan.

Two-line summary of the lens: *the "instrument first" instinct is textbook-correct and I endorse it; but the
plan instruments a conformance meter and calls its output "model drift," so the falsifiable prediction in §4 of
the report cannot actually be run until the two drift concepts are split. Arming the per-turn gates is net-helpful
for state, but several gates are themselves attention-tax with no measured payoff, and `PR-T6-exp` must run
BEFORE, not after, the flags harden — otherwise the experiment can no longer observe the OFF arm.*

---

## 2. WHAT THE PLAN GETS RIGHT (behavioural-evidence view)

**R1 — "Instrument before attributing to the model" is the single best call in the corpus.**
`research/00-...md` §4.3 states the decisive point precisely: *the model share cannot currently be measured, and
unmeasured causes inflate toward the convenient explanation.* This is the analyst's core discipline written in
plain prose. Attributing drift to "model statelessness" before the meter reads real data would be exactly the
*memorable-anecdote-over-reproducible-probe* failure my seat exists to prevent. Sequencing `PR-T0-1` (A1) at the
top of the DAG, and gating `PR-T6-exp` and `PR-T3-2` on it (`02-plan.md` critical path), is the right dependency
shape. **Endorsed without reservation.**

**R2 — The falsifiable prediction is stated, and it is genuinely falsifiable.**
`research/00-...md` §4.4 / `01-study.md`: *instrument + arm + mechanize counters; if drift subsides it was process
wearing a model costume; if it persists after the meter reads real data, the residual is model-side.* This is a
real pre-registered prediction with a directional outcome — rare and commendable. My only amendment (risk G1) is
that "drift subsides" must be defined over the **right meter**, which today it is not.

**R3 — Identifying model-executed bookkeeping (T4) as the load-bearing weakness is behaviourally correct.**
`research/00-...md` §2 T4 and `01-study.md` T4 nail the real mechanism: AXON routed its safeguards back through
markdown ops the model must *choose* to run (`KERNEL-SLIM.md:137` turn-count via `STORE`; `:333-338` phase
tracking via `STORE`; line 188/341 drift via `TOOL`), and **the faculty compaction degrades is the same faculty
the safeguards depend on.** This is the correct and non-obvious observation: the counters freeze exactly when
drift is worst. `PR-T0-3` (mechanize `W:turn-count` in `reanchor_store.py`, feed real token counts to `context
record`) converts a model-choice dependency into a host-hook guarantee. From the behavioural side this is the
**highest-value single change** in Tier-0, because it removes a confound — once the counter is mechanical, a
frozen counter can no longer be misread as "model held state fine."

**R4 — The compaction model in the kernel is explicit, localized, and therefore testable.**
The kernel does not hand-wave statelessness; it encodes specific, checkable assumptions: `KERNEL-SLIM.md:164-172`
(G-02: "compaction can clear `L:cognition-frame` between turns within a loop"; re-assert every 5 turns),
`:315` (re-read CORE RULES when context is long), `:340` (cognition-frame drift check every 5 turns), `:594-601`
(G-01 boot frame-set with restore-on-absence). Because these are *named, line-located, cadence-specified*
assumptions rather than vibes, they are exactly the kind of claim my seat can build a probe battery around
(see §4, change C3). The plan inherits a falsifiable substrate — that is an asset.

**R5 — The dual-encoding theme (T5) is real and the plan flags the right file.**
`PR-T3-3` (D3) correctly identifies that `KERNEL-SLIM.md:188,341` call a `drift` CLI that does not parse, and
proposes a conformance test that *every* `TOOL(drift,…)` literal parses against the resolved tool. I confirmed
this defect directly: `grep` shows lines 188/341 pass `--type persona-bleed --detail …` while `drift.py:329-330`
declares `record` with only `--tool` (required). The plan's instinct to add a kernel↔tool argparse-conformance
test is **exactly the right mechanical guard** and I strongly endorse it (with one expansion — risk G2).

**R6 — `PR-T6-exp` (OD-8 thin-kernel null hypothesis) is preserved, not flattened.**
`research/00-...md` §4 "Preserved dissent" and `01-study.md` §Open experiment keep alive the strongest
behavioural objection in the whole audit: *the 757-line kernel with ≥14 per-turn gates may itself manufacture the
cognition-frame slips it flags.* Refusing to resolve this by fiat and routing it to a controlled OFF-vs-ON
comparison is precisely the right move — it treats "more enforcement helps" as a hypothesis, not an axiom. This
is the council behaving like an analyst. (My disagreement is only on its *sequencing* — risk G3, the top-ranked
gap.)

---

## 3. RANKED RISKS / GAPS (with the PR ids they touch)

Ranked by behavioural blast-radius — how badly each one corrupts the council's ability to reason about model
behaviour *empirically*. Confidence and confounders flagged per my guardrails.

### G1 — [CRITICAL] The Tier-0 meter measures procedural conformance, not model cognition; the §4 prediction cannot be run on it as-is. — touches `PR-T0-1`, `PR-T3-2`, `PR-T6-exp`
**Observed (high confidence):** `drift.py` computes normalized edit-distance over *tool-call order* (expected =
static scan of `TOOL()`/`tools/x.py` literals in the program; actual = appended tool names). `PR-T0-1` wires
`drift record` from a PostToolUse interceptor → it will populate `actual[]` with **tool names**. The model-cognition
signals (persona-bleed, cognition-frame slip) are recorded by a *separate* tool, `axon_drift_log.py`, keyed on
`--phrase/--kind`, which the kernel never calls by its real CLI.
**Inferred (medium-high confidence):** The report's central claim — "instrument A1, then *measure the residual
model drift*" (`research/00-...md` §4, §6) — silently conflates these two meters under the shared word "drift."
After `PR-T0-1`, the council will have a good **"did the agent run the program's tools in the expected order"**
meter and **still zero** mechanical **"did the model slip out of frame"** meter. The falsifiable prediction ("if
drift subsides it was process") will be evaluated against tool-order conformance, which is *exactly the dimension
file-backed state already fixes* — so it is rigged to "subside" regardless of model behaviour, **confirming the
verdict for the wrong reason.**
**Confounder:** a clean tool-order trace says nothing about whether the model held identity/frame; the two can
diverge completely (correct tools, assistant-mode prose). Averaging them under one badge hides the tail that
matters for orchestration.
**Smallest fix:** split the meter (see §4 change C1). Until then, `PR-T6-exp`'s outcome metric is undefined.

### G2 — [HIGH] `PR-T3-3` fixes the wrong half of the dual-drift wiring; the real model-cognition sink stays disconnected. — touches `PR-T3-3`, `PR-T0-1`
**Observed (high confidence):** `PR-T3-3` proposes pointing `KERNEL-SLIM.md:188,341` "to call the drift tool whose
argparse matches (`--phrase/--kind`)" — i.e. `axon_drift_log.py`. That is correct for *logging* a persona-bleed
phrase. But the same lines are the *only* per-turn capture point for cognition-frame events, and `axon_drift_log`
is a one-way JSONL **sink the gate never reads** (its own docstring: "never reads its own output to make
decisions"). So even after `PR-T3-3`, persona-bleed events land in `log/drift/*.jsonl` and **never reach
`drift.py`'s trace or `r_drift_gate.py`'s decision.** The model-behaviour signal is logged-but-inert — the same
T2 ("honesty ≠ enforcement") pathology one layer down.
**Inferred (medium confidence):** the plan treats `PR-T3-3` as a parser-conformance cleanup; it is actually the
join where the model-cognition signal *should* enter the gate and currently cannot. Fixing the parser without
wiring the sink into a verdict leaves the model-drift meter readable only by a human grepping JSONL.
**Smallest fix:** §4 change C1 (make `axon_drift_log` summary feed a cognition-frame confidence modifier or a
counted gate), plus the argparse-conformance test `PR-T3-3` already proposes.

### G3 — [HIGH] `PR-T6-exp` is sequenced AFTER the flags harden, which destroys its OFF arm. — touches `PR-T6-exp`, `PR-T0-2`, `PR-T0-2a`, Tier-2
**Observed (high confidence):** `02-prs.md` / `02-plan.md` place `PR-T6-exp` in Wave 6, depending only on
`PR-T0-1, PR-T0-3`. But by Wave 6 the flags are armed (`PR-T0-2`), the security floor is gated (Tier 2), and the
per-turn gates bite. The experiment's whole point (OD-8) is **heavy-ceremony OFF vs ON.** Once the kernel is
armed and the gates are mechanically enforced, producing a clean "ceremony OFF" arm requires *unwinding* the
exact enforcement the preceding 20 PRs installed — and the `R_DRIFT_GATE` / cognition gates will themselves fire
during the OFF run, contaminating it.
**Inferred (medium-high confidence):** the null hypothesis ("the apparatus manufactures the slips it flags") is
**most cheaply and cleanly tested at the current, pre-armed baseline** — the system is already in the OFF state
today. Deferring the experiment to after arming converts a $0 A/B into an expensive teardown-and-rebuild, and
risks the sunk-cost framing where "we already armed everything, the experiment is now academic." This is the
classic *order-of-operations* error for a behavioural comparison: **measure the baseline before you perturb it.**
**Smallest fix:** §4 change C2 — run a thin first pass of `PR-T6-exp` immediately after `PR-T0-1`+`PR-T0-3`
(meter exists, flags not yet flipped), capturing the OFF arm, *then* arm and capture ON.

### G4 — [MEDIUM-HIGH] The "~10% irreducible model" share is a placeholder presented with false precision. — touches `01-study.md` §Drift root-cause, `research/00-...md` §4, `PR-T0-1`, `PR-T6-exp`
**Observed:** `01-study.md` gives "~60% architecture/process · ~30% config · ~10% irreducible model" and
immediately concedes "the model share is unmeasured and over-attributed because the meter records nothing."
`research/00-...md` §4 repeats it with the same caveat.
**Inferred (high confidence):** these three numbers are not estimates in any measured sense — they are a *rhetorical
ordering device*. That is defensible as a *prior*, but the plan and handoff occasionally let the "~10%" travel
without its error bars (e.g. HANDOFF "the honest expectation is that it is small"). From the behavioural side: the
**direction** (model share is the smallest, and over-attributed) is well-justified by the four-of-five non-model
causal layers argument (`research/00-...md` §4.1). The **magnitude** (10% vs 5% vs 25%) is unknowable pre-meter
and should never be cited as if measured. There is also a real model-side residue the report correctly names
(compaction decays system prompt → inert text; ≤5-turn cognition-frame window, `KERNEL-SLIM.md:164-172`) — and
that residue's true size is precisely what G1 prevents the current meter from sizing.
**Confounder:** "irreducible" is doing heavy lifting. `PR-T0-3` (mechanical counters) *reduces* part of what
looks like model-drift into fixed process-drift — so the "irreducible" fraction is itself a function of how much
bookkeeping you mechanize, not a model constant. The number will move as Tier-0 lands; treat it as a posterior,
not a prior.
**Smallest fix:** §4 change C4 — restate as a rank-ordering with explicit "unmeasured, expected-small,
re-estimate after A1+A3" framing wherever the 10% appears; never let it stand as a measured quantity.

### G5 — [MEDIUM] `PR-T3-2` (OD-2: drift `unknown` → fail-closed BLOCK) overrides an already-deliberate, already-tested advisory decision at the consumer. — touches `PR-T3-2`, `r_drift_gate.py`, `tests/test_drift_fail_closed.py`
**Observed (high confidence):** `drift.py` *already* fails closed at the tool layer — `_unknown_gate()` returns
`decision="halt", modifier=-50` for missing/unparseable/malformed/stale traces, and `test_drift_fail_closed.py`
(13 tests) enshrines this. But `r_drift_gate.py:57-63` **deliberately** returns `None` (no rule fire) when
`state=="unknown"`, with an explicit rationale comment: *"state=unknown means 'no/stale trace — can't verify
drift'. At the response gate this is silent — the menu badge surfaces it... state=diverged remains BLOCK."* OD-2
frames `unknown→None` as "a bug" (`01-study.md` OD-2); the code says it is a **conscious split between
positive-divergence (BLOCK) and evidence-absence (silent + badge).**
**Inferred (medium confidence, behavioural-impact framing):** this is the one place where "fail closed" can
*degrade* the model's working conditions. If `PR-T3-2` makes evidence-absence BLOCK the response gate, then
**every turn where the trace is stale (>2h TTL) or no program is active halts output** — and "no active program"
is the *normal* interactive state. That converts a meter into a tripwire that fires on the absence of the thing it
measures. From the behavioural side this is *ceremony that degrades the run*: it punishes the model for the
instrument being empty, which is the very condition Tier-0 is trying to *fix by wiring*, not *gate on*. The
report itself flags this as an open decision (`research/00-...md` §5 OD-2: "bug-fix vs policy reversal"), but the
plan resolved it to "BUG / fail-closed" (`01-study.md` OD-2) without reconciling the deliberate consumer comment.
**Confounder:** the `no-program` init path (`drift.py:142-162`, `--no-program`) gives a stable-until-TTL trace
for interactive sessions — so the blast radius depends on whether interactive sessions reliably init a trace.
That dependency is unstated and untested in the plan.
**Smallest fix:** §4 change C5 — keep evidence-absence (`unknown`) **advisory at the response gate** (badge +
confidence modifier), reserve BLOCK for positive `diverged`; if owner wants fail-closed, scope it to
*pre-merge/autonomous* contexts only (where it already is, via `auto_improve`), never the interactive response gate.

### G6 — [MEDIUM] Arming the per-turn gates adds real attention-tax; some gates have no measured payoff and may be net-negative. — touches `PR-T0-2`, `KERNEL-SLIM.md` cognition/coherence gates, `PR-T6-exp`
**Observed (high confidence):** the armed surface is heavy. Per turn the kernel mandates: a reasoning-trace STORE
(`:81-85`), identity-contract assert (`:57`), coherence-guardian scan of pending output (`:174-193`),
cognition-language gate before *every* reasoning step (`:157-163`), plus cadence checks at mod-5 (`:167`, `:340`)
and mod-10 (`:191`). Core Rule 11 (`:72`) forbids *all* natural-language reasoning — every internal step must be
re-expressed in symbolic ops.
**Inferred (medium confidence — this is genuinely contested, hence OD-8):** from a behavioural standpoint, every
ceremony token is attention not spent on the task, and forcing reasoning out of natural language into a
constructed symbolic dialect is plausibly *harmful* to a model whose strongest capability is reasoning in
natural language. The kernel itself concedes compaction erodes the frame the ceremony defends — so the ceremony
can be both the patch *and* part of the disease. This is not a reason to *not* arm; it is a reason to **not
assume arming is free or strictly beneficial.** The plan's `PR-T0-2` arms six flags as if the only question were
"does the rule BLOCK correctly on a fixture" (`02-prs.md` PR-T0-2 test). The behavioural question — *does arming
this gate change drift outcomes, net of its own attention cost* — is only asked in `PR-T6-exp`, and only for the
whole apparatus, not per-gate.
**Confounder:** sampling/temperature and task-distribution effects can masquerade as gate-effects; any per-gate
verdict needs controlled prompts and seeds, not anecdote.
**Smallest fix:** §4 change C2 (sequence the experiment early) + C3 (per-gate, not just whole-kernel, probe
battery). At minimum, arm the gates that *protect state* (state-surfaced, phase-tracking, workflow-node-order —
mechanical, low cognitive cost) with more confidence than the gates that *constrain cognition voice*
(cognition-language, coherence-third-person), which are the OD-8 suspects.

### G7 — [LOW-MEDIUM] `PR-T0-1`'s falsifiability depends on a harness PostToolUse payload the plan assumes exists. — touches `PR-T0-1`, `.claude/settings.json`
**Observed:** there is **no PostToolUse hook in `.claude/settings.json` today** (only UserPromptSubmit, PreToolUse,
Stop). `PR-T0-1` introduces one. Whether `actual[]` is meaningful depends on the harness delivering the *resolved
tool name* (and ideally args) in the PostToolUse payload — and AXON tools are invoked as `Bash(python tools/x.py)`,
so the PostToolUse matcher will see `Bash`, not `drift`/`calculator`. The `script_to_tool_name()` mapping
(`drift.py:49-58`) maps `tools/x.py → canonical name`, which suggests the interceptor must parse the Bash command
string to recover the tool — fragile, harness-specific, and untested in the plan's test claim.
**Inferred (medium confidence):** if the interceptor records `Bash` for every AXON tool call, the edit-distance
vs an expected sequence of *canonical tool names* will be ~maximal → the meter reads "diverged" constantly →
false-positive drift. This is a behavioural-instrument calibration failure that would *discredit* the meter on
first contact and poison every downstream attribution.
**Smallest fix:** `PR-T0-1`'s test must assert the interceptor resolves `Bash(python tools/drift.py ...)` →
canonical `drift`, end-to-end, on a real PostToolUse payload shape — not just "trace gains a call."

---

## 4. SPECIFIC CHANGES TO THE PLAN BEFORE EXECUTION

Concrete, PR-scoped, ordered by leverage. Each is the *smallest* change that closes the corresponding gap.

**C1 — Split "drift" into two named meters and instrument BOTH in Tier-0. (closes G1, G2)**
Amend `PR-T0-1` and `PR-T3-3`. Make explicit that there are two orthogonal quantities:
 (a) **procedural-conformance drift** = `drift.py` tool-order edit-distance (what `PR-T0-1` already wires);
 (b) **cognition/persona drift** = `axon_drift_log.py` persona-bleed + cognition-frame events.
Add to `PR-T0-1` (or a new `PR-T0-1b`): wire `axon_drift_log.summary()` into a per-session cognition-drift count
that the council can read, and route the kernel's `:188,341` capture to it with the *correct* CLI
(`--phrase/--source/--kind`). Then, wherever the report says "measure the residual model drift" (`research/00-...md`
§4/§6), bind that phrase to meter (b), **not** (a). Without this, the §4 falsifiable prediction is untestable —
it is the load-bearing instrument of the entire epistemic argument and it currently points at the wrong signal.

**C2 — Move `PR-T6-exp` to a thin first pass right after `PR-T0-1`+`PR-T0-3`, before arming. (closes G3, partially G6)**
Re-DAG: insert `PR-T6-exp-baseline` depending only on `PR-T0-1, PR-T0-3` and **preceding** `PR-T0-2`. Capture the
OFF arm at today's already-disarmed baseline (cheap, the system is in that state now), with the meter live. Then
arm (`PR-T0-2`), let the system run, and capture the ON arm. Keep the full Wave-6 `PR-T6-exp` as the *analysis*
PR. Rationale: a behavioural A/B must record the baseline *before* perturbation; deferring it to after 20 PRs of
arming both raises its cost and contaminates the OFF arm with gates that now bite.

**C3 — Add a per-gate behavioural probe battery, not just per-rule fixture tests. (closes G6; supports R4)**
`PR-T0-2`'s test claim ("each rule BLOCKs on a violating fixture, PASSes on a clean one") proves the *mechanism*
fires, not that arming *improves outcomes*. Add a small `promptfoo`/Inspect-AI-style probe set (my seat's
standard instrument) targeting the kernel's named, line-located compaction assumptions: G-02 5-turn re-assert
(`:164-172`), cognition-frame restore (`:340`, `:594-601`), coherence-guardian persona-bleed list (`:174-190`).
Run it OFF vs ON with **fixed seeds, fixed temperature, and counterfactual prompt-pairs** so a behavioural delta
per gate is attributable and not a sampling artefact. This is the only way to distinguish "gate helps" from "gate
is ceremony" at the resolution OD-8 needs. Separate the *state-protecting* gates (cheap, likely net-positive)
from the *cognition-voice* gates (the OD-8 suspects) in the readout.

**C4 — Demote the "~10%" model share to a rank-order with explicit error bars everywhere it appears. (closes G4)**
Edit `01-study.md` §Drift root-cause and any HANDOFF/plan echo: replace "~10% irreducible model" with
"**model share: smallest of the three, currently unmeasured, expected small, RE-ESTIMATE after A1+A3.**" Keep the
*ordering* claim (model < config < architecture) — it is well-argued. Drop the false-precision number as a
standalone. Add one sentence: *"the 'irreducible' fraction shrinks as bookkeeping is mechanized (`PR-T0-3`), so it
is a posterior of the re-arm, not a model constant."* This protects the council from anchoring on a placeholder.

**C5 — Keep `unknown`/evidence-absence ADVISORY at the interactive response gate; scope fail-closed to pre-merge/autonomous. (closes G5)**
Re-scope `PR-T3-2` (OD-2). Do **not** make `r_drift_gate.py` BLOCK the interactive response gate on
`state=="unknown"` — that punishes the model for the meter being empty, the exact condition Tier-0 fixes by
wiring, and "no active program / stale trace" is the normal interactive state. Preserve the current deliberate
split (`r_drift_gate.py:57-63`): `diverged` → BLOCK; `unknown` → badge + confidence modifier. The fail-closed
posture already correctly exists where it belongs — `auto_improve` widens its fatal predicate to include
`unknown` (`test_drift_fail_closed.py::test_auto_improve_halts_on_unknown`) — i.e. in *autonomous* runs. Confirm
the interactive `--no-program` trace-init path (`drift.py:142-162`) actually fires on interactive boot, with a
test, before considering any tightening. If owner insists on fail-closed at the response gate, gate it behind a
flag, default OFF, and put it in `PR-T6-exp`'s scope as a measured change, not an assumed-correct one.

**C6 — Harden `PR-T0-1`'s test against the Bash-wrapping confound. (closes G7)**
`PR-T0-1`'s test must assert the PostToolUse interceptor resolves `Bash(python tools/drift.py ...)` →
canonical `drift` end-to-end on a realistic payload, and that a non-AXON `Bash` call (e.g. `ls`) is *not* recorded
as a spurious tool. Otherwise the meter reads constant divergence on first contact and discredits itself — a
behavioural-instrument calibration failure that would poison every downstream model-share attribution.

---

## 5. ANSWERS TO THE THREE CHARGE QUESTIONS (direct)

**Q: Is Tier-0 "instrument-then-measure, don't pre-harden against model statelessness" epistemically sound?**
**Yes — the posture and ordering are correct and I endorse them** (R1, R2). The demonstrated cause (unwired meter)
outweighs the unfalsifiable one (model can't hold state); instrumenting first is exactly right. **Caveat (the
"-WITH-RISKS"):** the instrument Tier-0 plugs in measures *tool-order conformance*, not *model cognition* (G1),
so as currently specified it cannot actually measure the model-statelessness residual the argument promises to
measure. Fix C1 makes the posture's promise deliverable.

**Q: Are the compaction / context-loss / prompt-as-program assumptions and the ~10% model-share right?**
The **compaction/context-loss assumptions are right and, unusually, falsifiable** — they are named, line-located,
and cadence-specified (`KERNEL-SLIM.md:164-172, :315, :340, :594-601`), which is an asset (R4). The
**prompt-as-program framing is coherent** but carries an under-acknowledged cost: forcing all reasoning into a
symbolic dialect (Core Rule 11) is plausibly net-negative for a natural-language reasoner, which is precisely the
OD-8 null hypothesis (G6). The **~10% model share is directionally right (smallest, over-attributed) but
numerically a placeholder** presented with more precision than the evidence supports, and "irreducible" is a
function of how much bookkeeping you mechanize, not a constant (G4). Fix C4.

**Q: Does arming per-turn gates help or add ceremony that itself degrades the model?**
**Both, and the plan doesn't yet distinguish which gates do which.** The *state-protecting* gates (state-surfaced,
phase-tracking, workflow-node-order — mechanical, low cognitive cost) almost certainly **help** and should be
armed with confidence. The *cognition-voice* gates (cognition-language, coherence/third-person — `:157-193`) are
the OD-8 suspects: they impose real attention-tax and constrain the model's strongest faculty, and may
**manufacture** some of the slips they flag. The honest answer is *unknown without measurement* — which is why the
top correction (C2) is to run `PR-T6-exp` early, at the disarmed baseline, before the flags harden, with a
per-gate probe battery (C3). One specific gate (`PR-T3-2` fail-closing on evidence-absence) is **likely
net-degrading at the interactive response gate** and should stay advisory there (G5/C5).

---

## 6. SEAT SUMMARY

The plan's instinct is the right one and I'd defend it in any council: **do not name a model behaviour you have
not measured.** The execution risk is that the plan then proceeds to *measure the wrong thing under the right
name* (procedural conformance ≠ model cognition, G1/G2), *defer the one experiment that would falsify its central
ceremony assumption until after that ceremony is locked in* (G3), *cite an unmeasured 10% as if it were data*
(G4), and *consider fail-closing a meter on the absence of evidence* in a way that punishes the model for the
instrument being empty (G5). All five are fixable with the small, PR-scoped amendments in §4 — none requires
re-architecting. Make those changes and the verdict moves from **SOUND-WITH-RISKS** to **SOUND**: AXON would then
have, for the first time, a *behavioural* meter pointed at the *behaviour* it claims to govern, and a baseline
measurement taken before the apparatus perturbs it.

*— LLM Behaviour Analyst seat. Observed/inferred separated and confidence-tagged per guardrails. Read-only:
no code, plans, programs, or workspace state were modified. Role-lock maintained throughout.*

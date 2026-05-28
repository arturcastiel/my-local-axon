# AXON Proof — conclusive-benchmark design (collaborative, owner-guided 2026-05-28)

> The pillar-3 PROOF of the million thesis: does a model scaffolded by AXON beat the
> SAME bare model on long-horizon, coherence-demanding work — objectively + conclusively?
> Designed concern-by-concern with the owner. Status: concerns 1-3 LOCKED; 4-5 in design.

## Locked decisions

### Concern 1 — the AXON arm (the treatment)  ✓ LOCKED
**Full AXON over MCP.** Agent-A = the base model + REAL AXON tools (memory, checkpoint,
gates) via `mcp-client`, NOT just an AXON-discipline system prompt. Tests the OS, not a
prompt. Implies a build (todo 43b4bf4b). Fairness: both arms share base model, Agent-U,
goal, turn budget — only the AXON tooling differs.

### Concern 2 — what counts as a "win"  ✓ LOCKED
**Objective oracle.** A win = the produced artifact PASSES a programmatic check, never a
model's say-so (no self-grading). Implies a grader that executes the produced code and
checks it. Every goal must be oracle-backed.

### Concern 3 — the goal set + oracle machinery  ✓ LOCKED
**Domain = reservoir simulation + BASIC numerical simulation** — bounded by "the owner can
personally CONFIRM it" (a benchmark you can't vouch for isn't a proof you'd stake the case
on). Still a spectrum (reservoir flow/transport + heat/diffusion/advection/wave/elasticity),
all in the owner's wheelhouse.

**Oracle = Method of Manufactured Solutions (MMS) + property checks.** This is the unlock for
"automatic + objective + no per-goal digging + no N domain experts":
  - MMS: pick a smooth `u*`, derive forcing `f = L[u*]` symbolically (sympy = automatic),
    goal = "build a solver for this PDE+BCs+forcing"; oracle = solver must reproduce `u*` to
    discretization error + at the EXPECTED CONVERGENCE ORDER under refinement.
  - Property checks (field-agnostic): mass/energy conservation, symmetry, dimensional
    consistency.
  - Provenance rule: an oracle must trace to MMS / analytical / intrinsic property — NEVER to
    unverified model output (R_GROUNDED_CLAIMS applied to the benchmark itself).
**Discrimination:** building a CONVERGENT solver is long-horizon + coherence-demanding
(consistent indexing, flux signs, BC handling across many turns). Bare model drifts → wrong
order / blows up / violates conservation → FAILS; AXON holds state → PASSES. MMS measures the
coherence axis directly.
**Pilot (de-risk before scale):** (a) 1D Buckley-Leverett (existing, closed-form front =
analytical oracle); (b) 1D heat/diffusion via MMS (2nd-order convergence + conservation).
Run both arms, confirm the oracle fires + bare actually fails while AXON holds → real effect
size → then scale to ~15-20.

### Concern 4 — controls + statistics + sandbox  ✓ LOCKED
- **Controls/validity:** 🔑 NO LEAKAGE — the agent gets PDE + forcing `f` + BCs + grid, NEVER
  the manufactured `u*` (grader alone holds it); else it hardcodes the answer and the proof is
  worthless. Same base model · same Agent-U · same turn budget · same temperature; PAIRED per
  goal; randomized arm order; grader BLIND to arm. PRE-REGISTER hypothesis + generator seed +
  analysis plan + the bar before running (no p-hacking).
- **Sandbox:** grade produced code in a subprocess with hard timeout · memory cap (ulimit) ·
  no network (`unshare -n`/firejail) · ephemeral tmpdir · scrubbed env. Threat = buggy/
  coherence-lost code (we generate the goals). Container = stretch.
- **Statistics:** unit = the goal, paired; primary metric = oracle PASS (binary: converges at
  expected order + conserves within tolerance). Test = exact binomial/sign-test on goal-level
  wins + Wilson CI; CONCLUSIVE iff CI lower bound > 0.5. Seeds = K runs/arm/goal → majority-pass
  (cuts variance, does NOT inflate n). n: pilot 2 → measure effect → ~10-12 if large else ~15-20;
  pre-register n + stopping rule. Secondary (descriptive): order achieved, error, turns, drift.

### Concern 5 — model + budget + run  ✓ LOCKED
**Tiered: cheap pilot → frontier headline.** Validate machinery + read effect size on a CHEAP
model (Haiku/Sonnet) for the 2-goal pilot, then the headline ~10-20 on FRONTIER (Opus 4.7) for
the strongest claim ("AXON improves even SOTA"). Same code, `--model` switch. Budget = quantified
by the PREFLIGHT (runnable-goals × est tokens × $/model) → owner sets a hard cap; note the AXON
arm costs more (tool-use turns over MCP). The live run + key + budget is the irreducible HUMAN step.

## BUILD STATUS (2026-05-28)
Methodology written: `benchmark/METHODOLOGY.md` (merged).
1. ✓ **Sandbox** — `tools/proof_sandbox.py` (timeout/mem/no-net/scrubbed-env, fail-closed). MERGED.
2. ✓ **MMS generator + grader (heat-1d)** — `tools/proof_mms.py`: leakage-safe goal gen (sympy
   forcing, no u*) + grader (convergence-order + error via sandbox); reference CN solver validated
   at order~2; bad solvers FAIL. MERGED. *(Buckley-Leverett analytical grader = a small follow-on.)*
3. ☐ **Full-AXON-over-MCP arm** (todo 43b4bf4b) — the big remaining piece; better fresh + supervised.
4. ☐ **Preflight** (cost + best-case CI) — depends on the harness integration below.
5. ☐ **Pre-registration doc**.
+ ☐ **B2.5 harness integration** — wire `proof_mms` goals + objective grader INTO `dual_agent_eval`
  (present MMS goal → run both arms → extract produced solver code → grade objectively, replacing
  the self-graded goal-met). This is what makes the machinery runnable end-to-end.

**The hard, correctness-critical core (oracle machinery) is DONE.** Remaining = integration (B2.5) +
the MCP arm (B3) + preflight (B4) + prereg (B5). Then HUMAN: run pilot (cheap) → confirm effect →
scale to ~10-20 → run headline (Opus) → read CI.

## Build implications (when design is locked)
- Wire the full-AXON-over-MCP arm (todo 43b4bf4b).
- MMS goal-generator (sympy-based) + a domain-agnostic grader (run produced code in a
  sandbox; check vs `u*` + convergence order + conservation).
- A sandbox for untrusted produced code.
- Preflight (cost + best-case CI) before any budgeted run.

# AXON Proof — conclusive-benchmark design (collaborative, owner-guided 2026-05-28)

> The pillar-3 PROOF of the million thesis: does a model scaffolded by AXON beat the
> SAME bare model on long-horizon, coherence-demanding work — objectively + conclusively?
> Designed concern-by-concern with the owner. Status: all 5 concerns LOCKED; oracle + harness
> BUILT (B1/B2/B2.5 merged, leakage-hardened); remaining = MCP arm (B3) + preflight (B4) + prereg (B5).

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
+ ✓ **B2.5 harness integration** — `dual_agent_eval` gained an MMS path (`run-mms`): render a PDE
  goal (forcing/BCs/grid, NEVER u*) → run both arms → extract the operator's produced solver →
  grade with `proof_mms.grade`, REPLACING the GOAL-MET self-grade. Paired AXON-vs-bare →
  Wilson-CI verdict (conservative: ties count as non-wins). `run-mms` CLI + 12 tests; gate green.
  MERGED (v3.8.0-dev-proof-harness-mms). **The benchmark is now runnable end-to-end.**
  + leakage HARDENED: family excludes eigenfunctions (f ∝ u* would leak u*'s shape via the
    forcing); `proof_mms._forcing_leaks_solution` fails closed; METHODOLOGY §6.A documents the
    two-layer defense (the order check independently rejects a hardcoded-exact answer).
3. ☐ **Full-AXON-over-MCP arm** (todo 43b4bf4b) — the big remaining piece; better fresh + supervised.
   (Today the AXON arm is prompt-level via make_operator; B3 swaps in real AXON tools over MCP.)
4. ✓ **Preflight** (`dual_agent_eval.py preflight`) — PRICE-INDEPENDENT conclusiveness gate (best-case
   Wilson CI + N_min + CI at an assumed win-rate) PLUS a caveated $ estimate. Tells you BEFORE
   spending whether a run can even clear the bar. MERGED.
5. ✓ **Pre-registration** (`dual_agent_eval.py prereg` + `benchmark/PRE-REGISTRATION.md`) — stamps a
   LOCKED record (fixed bar, seeds/model, git commit + sha256 fingerprint of methodology+oracle+
   harness, embedded power projection) to commit BEFORE running. MERGED.

**The proof TARGET is COMPLETE** — the benchmark is one command from a CI'd verdict, cost known
up-front, bar locked + grader pinned before the run.
**BREADTH SHIPPED** (the owner's explicit ask): a 2nd MMS field — 1D advection-diffusion/transport
(reservoir-adjacent) with a validated order-2 reference + operator dispatch (`operator:seed` goal
ids; `--goals` everywhere). 12 mixed goals (6 heat + 6 advdiff), all reference solvers order ~2;
preflight(12) = conclusive-capable at win-rate 0.85. The MMS unlock realized: breadth across fields
with ONE automatic oracle, no extra domain experts. Tag `v3.8.0-dev-proof-spectrum`.
**3rd ORACLE TYPE SHIPPED** (built while paused for the TNO discussion): the Buckley-Leverett
ANALYTICAL oracle (`tools/proof_bl.py`, tag v3.8.0-dev-proof-bl-oracle) — nonlinear hyperbolic
transport with a closed-form rarefaction+shock (Welge), Rusanov reference, L1/front grader; validated
across M={1.5,2,3,5}; reservoir-native + owner-verifiable. The methodology oracle set is now complete:
MMS (manufactured) + analytical (BL) + property. Follow-on (todo e2ae00a9): wire BL into run-mms.
Remaining for the live NUMBER = the MCP arm (B3, owner-steered fidelity) + HUMAN: pilot → confirm
effect → scale → headline (Opus) → read CI.

**ONE-COMMAND TARGET (hit):** `python3 tools/dual_agent_eval.py preflight --n K` (power+cost) →
`prereg --seeds 0..K --model <m>` (lock, commit it) → `run-mms --backend anthropic --seeds 0..K
--model <m> --out reports/dual-agent` (CI'd H1 verdict). B2.5 made the command real; preflight +
prereg make spending on it safe + honest.

## Build implications (when design is locked)
- Wire the full-AXON-over-MCP arm (todo 43b4bf4b).
- MMS goal-generator (sympy-based) + a domain-agnostic grader (run produced code in a
  sandbox; check vs `u*` + convergence order + conservation).
- A sandbox for untrusted produced code.
- Preflight (cost + best-case CI) before any budgeted run.

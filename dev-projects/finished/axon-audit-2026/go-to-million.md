# Go-to-Million — proving AXON's cause + what it's worth (2026-05-26)

## 0. The claim we must prove
"An AXON-scaffolded model beats the SAME bare model on long-horizon, stateful,
coherence-demanding work — reproducibly, with a public number."
NOT "AXON beats GPT" (model-vs-model — we lose/irrelevant). The unit of proof is
the HARNESS DELTA on the same model, on tasks where AXON's differentiators bite.

## 1. The proof strategy — two tiers
**Tier 1 (internal, cheap, fast): plan B dual-agent eval.** Agent-U (no AXON, holds
the goal) ↔ Agent-A (same model + AXON via MCP), vs baseline U↔bare-model. Produces
the first directional delta in days. This is the screening experiment.

**Tier 2 (public, citable, slow): a benchmark number.** Two options:
- **SWE-bench Lite resolved-rate, AXON-on vs AXON-off (same model).** Table-stakes,
  recognized, but coding-one-shot is NOT where AXON shines — risk of a small/zero delta.
- **A long-horizon coherence benchmark (RECOMMENDED, AXON's real edge):** multi-turn,
  multi-session tasks that require memory reuse, identity stability, drift-resistance,
  and recovery after compaction. Bare models structurally lack these — AXON should
  win decisively. Examples: "resume a 3-session feature build correctly", "maintain a
  constraint across 50 turns", "recover the plan after a context reset". This is a
  benchmark AXON can WIN because it measures the thing AXON uniquely provides.
- **Best play: do both.** SWE-bench for credibility/recognition; the coherence
  benchmark for the decisive win. Lead the story with the coherence number.

## 2. What makes the benchmark CREDIBLE (do these or it's marketing, not proof)
- **Clean A/B:** identical base model + tasks; only AXON on/off. No cherry-picking.
- **N + seeds:** ≥30 tasks, ≥3 seeds each; report deltas WITH confidence intervals.
- **Pre-registered metrics:** success rate, steps-to-goal, tool-calls, coherence/drift
  score, cross-session memory reuse, compaction-recovery rate. Define before running.
- **Reproducible + open:** publish the harness, fixtures, and full transcripts. A
  number nobody can reproduce is worthless to the thesis.
- **Honest negatives:** report where AXON LOSES (one-shot tasks, overhead). Credibility
  comes from showing the boundary, not hiding it.

## 3. How to go for plan B (the concrete path)
1. Build `tools/dual_agent_eval.py`: spin Agent-U (goal+sysprompt, no AXON) and
   Agent-A (AXON behind mcp-server); relay over MCP; log full trace. Baseline arm:
   U↔bare-model. (R_NEW_NEEDS_TEST + full crucible gate per the session discipline.)
2. Goal fixtures (OWNER-SET) — see §4 for what to choose.
3. Score with axon-eval; emit `reports/dual-agent-<date>.md` with the delta + CIs.
4. If the delta is real → graduate the same fixtures into the Tier-2 coherence benchmark
   and publish. If flat → that's a finding too (tells you where the wedge isn't).

## 4. Best handoff design — the goals that actually demonstrate value
Pick goals where AXON's differentiators are the bottleneck, NOT one-shot tasks:
- ✅ **Multi-session / long-horizon:** "build feature X across 3 sessions; stay
  consistent." (tests memory + identity + resume)
- ✅ **Constraint-holding under pressure:** "never touch file Y; keep the API stable
  over 40 turns." (tests gates + drift resistance)
- ✅ **Recover after reset:** mid-task context wipe → does it resume correctly?
  (tests checkpoint/resume — bare model can't)
- ✅ **Coherence across hosts:** same goal under two harness declarations.
- ⚠️ AVOID pure one-shot ("write this function") — the bare model already wins;
  AXON's overhead shows with no upside. Those belong only as honest-negative controls.
Start with 3-5; same model for U and A (isolates the harness effect).

## 5. How much is AXON worth TODAY? (honest)
**As a liquid/acquisition asset right now: ~$0.** No users, no revenue, no public
proof, solo. Nobody acquires a pre-traction agent framework; the market price of an
unproven idea is the sweat already in it, not a multiple.

**As IP / engineering asset:** real but unpriced — a coherent ~132-tool / 187-program
kernel with mechanical gates is months of senior work, but "worth" needs a buyer and
there isn't one pre-traction.

**As a venture option (where the million lives):** the idea CAN support a $1-5M
pre-seed cap — BUT that value is CREATED by, not held before, three things:
proof (the benchmark), a shippable wedge (the conformance-layer product), and early
users. AI-infra with a timely, standardizing thesis (AGENTS.md/MCP) + working tech +
a proof number is a credible pre-seed story; without the proof it's an idea, and
ideas don't clear a price.

**Bottom line:** AXON today is an **unpriced option, not a priced asset.** The
benchmark is the strike. Plan B is the cheapest way to find out if the option is
in-the-money. Spend the next effort there — value is manufactured by proof +
distribution, not by more kernel.

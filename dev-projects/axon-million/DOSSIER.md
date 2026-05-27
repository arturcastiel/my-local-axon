# AXON Million — Dossier (the consolidated strategic + build record)

> Single source tying together the audit, the thesis, the valuation, the three
> pillars, and the artifacts built 2026-05-26. Detailed docs linked inline.
> Why this exists: a lot of important strategic information accumulated fast —
> this is the map so none of it is lost.

## 0. The question and the answer
**Q: Is AXON a million-dollar idea?**
**A: Conditional YES** (audit `axon-audit-2026/verdict.md`). The market formed around
AXON's exact problem in 2026 (instruction-governance; AGENTS.md + MCP now Linux-
Foundation standards), the prior audit's #1 gap (no MCP/A2A) is CLOSED, and the
moat (kernel-enforced coherence across hosts) holds and is now mechanically gated.
The "million" is gated on three things, in order: **prove it → wedge → distribute.**

## 1. Why we're building this (the case)
- Prior audit (`/home/arturcastiel/projects/axons-audit`): "promising substrate,
  immature product · 72.6/100 · LOW integration · uniquely defensible kernel · 5
  unique axes vs 10 competitors." Verdict then: "you are onto something."
- The DELTA since (this session + axon-ascent): MCP + A2A ACTIVE (the #1 knock,
  closed); kernel hardened (crucible, R_NEW_NEEDS_TEST, R_HANDOFF_SURFACED,
  dag-consistency, AEGIS, live commit-msg identity gate); positioning sharpened to
  "the conformance layer — git+CI for your agent's constitution."
- So the bottleneck moved from CAPABILITY to PROOF + DISTRIBUTION. That's what the
  three pillars build.

## 2. The three pillars (status)
### Pillar 1 — THEORY  ✓ built (`theory/thesis.md`)
The conformance-layer category; the organism argument (AXON = body/memory/immune-
system/proprioception around rented cognition); the falsifiable hypothesis:
> H1: a model scaffolded by AXON beats the SAME bare model on long-horizon,
> stateful, coherence-demanding tasks (H0 = scaffolding is overhead).
Honest boundary: on one-shot tasks H1 is expected FALSE. The thesis lives in the
long-horizon regime. The moat: "the kernel is the product" — structural, hard to copy.

### Pillar 2 — APPLICATION (the wedge: **Axiom**)  ✓ v1 foundation built
`tools/axiom.py` — `axiom check <repo>`: ingests CLAUDE.md/AGENTS.md/.cursor/rules/
copilot-instructions, reports cross-file COHERENCE defects (conflicts, duplications,
precedence ambiguity) + a coherence score. Read-only v1 (owner decision); own
product name, powered by AXON (OS = upsell). 7 tests; dogfoods on this repo.
v1.1: portability (cross-host behavior diff — AXON's unique axis) + enforcement-gap scoring.
Pitch: "A linter for your agent's constitution."

### Pillar 3 — BENCHMARK (the proof: dual-agent eval)  ✓ harness foundation built
`tools/dual_agent_eval.py` — Agent-U (holds goal, no AXON) ↔ Agent-A (model+AXON over
MCP), vs a bare-model baseline arm; per-goal delta + aggregate → H1 verdict. 9 tests
(mock backend → logic proven). 5 seed long-horizon goal fixtures. LIVE run needs:
a configured model backend (API) + Agent-A's AXON tools over mcp_client + the owner's
real goal set. Strategy in `axon-audit-2026/go-to-million.md` (2 proof tiers + credibility).

## 3. Valuation (honest, from go-to-million.md)
- Liquid/acquisition value TODAY: ~$0 (no users, no revenue, no public proof, solo).
- Venture/pre-seed: $1-5M cap is a CREDIBLE story given timing + working tech — but
  that value is CREATED BY, not held before, the proof + wedge + early users.
- AXON today = an **unpriced option**; the benchmark is the strike. Plan B is the
  cheapest way to learn if it's in the money. Spend next effort on proof + wedge.

## 4. Build sequence (owner: "1 2 and 3")
Theory ✓ → Application/Axiom ✓ v1 → Benchmark harness ✓ → [LIVE benchmark needs
API + goals] → Axiom v1.1 (portability) → publish the number → distribute.

## 5. Linked detailed docs
- `axon-audit-2026/verdict.md` — the million-dollar call + conditions + risks.
- `axon-audit-2026/go-to-million.md` — proof strategy, benchmark credibility, valuation.
- `axon-audit-2026/phases/1-state-snapshot/01-study.md` — the delta vs the 72.6 baseline.
- `axon-million/theory/thesis.md` — pillar 1.
- `my-axon/plans/audit-million-dollar.md`, `mcp-dual-agent-eval.md` — the originating plans.

## 6. Open / human-gated
- Live benchmark: model backend (API) + owner's real goals.
- Axiom v1.1: portability + enforcement-gap scoring; distribution (CLI packaging, Action).
- Wedge GTM: ride AGENTS.md/MCP standard; registry; 5-min onboarding.

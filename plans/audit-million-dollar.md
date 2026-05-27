# Plan — AXON Strategic Audit: "is this a million-dollar idea?"

Status:  active
Created: 2026-05-26
Kind:    research / strategy (not a code build)
Builds-on: /home/arturcastiel/projects/axons-audit (prior audit: "promising substrate,
           immature product · HEALTHY structurally · 72.6/100 usefulness · LOW integration")
           + tools axon-compare, axon-state, freshness, doc-counts, library-dev, web-search

## GOAL
Honest assessment of AXON's current state, the accuracy/sellability of its docs,
its position vs competing agent frameworks, and a clear verdict on commercial
viability — with the brutal version of "million-dollar idea?" (yes / no /
conditional + exactly what would make it one).

## WHY NOW
Two full projects + AEGIS + the DAG-consistency contract shipped since the last
audit — the substrate is materially more mature (gates, memory, DAG, host-neutral
tools). Worth re-measuring against the market before investing more build effort.

## PHASES
1. **state-snapshot** — what AXON IS today: 127 tools, ~185 programs, the kernel +
   gates (crucible, R_NEW_NEEDS_TEST, dag-consistency, AEGIS), memory tiers,
   host-neutrality. Pull from axon-state + doc-counts + freshness. Output: capabilities map.
2. **doc-audit** — are README / CONTEXT / WORKFLOW / AXON-DOCS accurate, current,
   and sellable? Flag claim-vs-reality gaps (the thing investors/users check first).
3. **competitor-matrix** — feature + positioning grid vs: LangGraph, CrewAI,
   AutoGen, Claude Agent SDK, OpenAI Assistants/Swarm, Letta/MemGPT, Cursor, Devin,
   Cognition, Smol/Open-interpreter. Ingest their docs via library-dev; web-search current.
   Where AXON wins / ties / loses (extend the existing axon-compare).
4. **moat-and-diff** — what is genuinely unique (OS-for-agents framing, kernel-enforced
   discipline, host-neutral tool layer, DAG-as-structural-truth, persistent identity)
   vs what is commodity. Is the moat defensible or a wrapper?
5. **verdict** — TAM, who pays + why, GTM wedge, and the honest call: million-dollar
   idea? Conditions to make it one (the 2-3 things that must be true). Risks that kill it.

## PRODUCES
audit-2026.md (state + doc verdict) · competitor-matrix.md · verdict.md (the call).

## KEY OPEN DECISIONS (for the owner)
- Competitor set: the list above, or a tighter focus (e.g. only memory-centric /
  only coding-agents)?
- Tone: brutally-honest internal verdict, or investor-pitch framing? (default: honest)
- Depth: rapid (1-pass, ~half day) vs deep (library-dev ingest of competitor docs)?

## HOW TO RUN
Best as a code-dev project (study→plan→report) using mode `audit` + `compare`
(the study modes shipped this session): `code-dev new audit-strategic`, study
`--mode audit`, then `--mode compare --ref <competitor>`. Or run lighter as this plan.

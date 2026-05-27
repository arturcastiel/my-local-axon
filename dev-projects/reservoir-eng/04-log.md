# Implementation Log — Reservoir-Eng

## SESSION START — 2026-05-23 (study phase)
project:        reservoir-eng
phase:          1-study
workflow-step:  study
source-repo:    /home/arturcastiel/projects/Claude-for-reservoir-engineering

## Entries

- 2026-05-23 · project scaffolded (v4) · study phase opened
  · source: Claude-for-reservoir-engineering (9-module CC course, reservoir domain)
  · running layered study: read assets + modules + web research → AXON workflow mapping
- 2026-05-23 · STUDY complete (layered) · 5 docs written
  · sources: 9-module course + pyResToolbox v3.4.0 (12 families) + pyrestoolbox-mcp (108 tools) + MCP spec + hydrology source + RE workflow taxonomy
  · key finding: course assets map 1:1 to AXON primitives; engine REUSED, net-new = reservoir program family + MCP egress (mcp_client) + domain gate
  · pivotal dependency: MCP client (= axons-audit lever #1; shared w/ axon-ascent)
  · 3 workflows carved: WF-1 screening (Fixed), WF-2 pvt-table (Fixed), WF-3 sensitivity (Adaptive fan-out)
  · 8 open questions for user Q&A before plan-phase goal (see _open-questions.md)
  · status: AWAITING USER Q&A — do not set plan goal yet
- 2026-05-23 · PLAN phase complete (deep) · moved study → 2-plan
  · decisions locked: MCP client TOP PRIORITY (option 1a, host-independent); v1 scope = MCP + WF-1 + WF-3 + review gate + prefs; build into workspace
  · 9-PR roadmap across 4 clusters: M(MCP egress, top) · D(discipline) · P(programs+workflows) · V(validation)
  · critical path: PR-M1 mcp_client → M2 registry → M3 pyrestoolbox → P2 WF-1 → V1
  · self-contained tests (stub MCP server) so CI needs no live server
  · mcp_client shared with axon-ascent lever #1; WF-3 exercises #16
  · artifacts: 2-plan/{_decisions,02-plan,02-prs,03-dag}.md + root masterplan.md
  · status: PLAN READY FOR REVIEW — implementation not started
- 2026-05-23 · PR-M1 MERGED to main (#81 · 0327e4d) · tools/mcp_client.py — first MCP egress
  · stdio JSON-RPC, hand-rolled stdlib, 14 tests, registry-drift clean, zero new dep
  · CI green first attempt; squash-merged autonomously (scoped grant)
  · cluster M: 1/3 → proceeding to PR-M2 server registry
- 2026-05-23 · PR-M3 MERGED (#83 · 5d46c1a) · CLUSTER M COMPLETE
  · pyrestoolbox-mcp launch template pinned (uv run --directory <dir> fastmcp run server.py, stdio)
  · derived tools/list fixture + skip-gated live connectivity test; param_conventions captured (guard enforcement → cluster D)
  · cluster M = M1(client) + M2(registry) + M3(pyrestoolbox link): host-independent MCP egress shipped
  · scoped self-merge grant ended at M boundary; handed back to user
  · NEXT: cluster D (prefs + output gate + reservoir-review) needs a decision pass + fresh grant
- 2026-05-24 · CLUSTER D COMPLETE (D1–D5 all merged)
  · D1 prefs (#84) · D2 reservoir_mcp guard+wrapper (#85) · D3 output-standard gate R_RESERVOIR_OUTPUT (#86) · D5 sanity-bounds mechanical floor (#88)
  · D4 reservoir-review (#87) merged by user — revised to ADVISORY/HYBRID + neuron-contract conformance:
    role reviewer→reader (reviewer not a valid neuron role), findings advisory-only (CONSIDER/SUGGEST/NOTE, never BLOCK),
    units/MCP-params/numeric-bounds DEFERRED to the deterministic floor (R_RESERVOIR_OUTPUT + reservoir_mcp guard/sanity_bounds)
  · merged as ALLOWLISTED / non-dispatchable (DOMAIN-REVIEW-PENDING) — not in dispatch index until a reservoir engineer validates the criteria; trigger to go live = compile .cmp.md + de-list
  · hybrid principle: only mechanical checks can enforce (run in CI/Copilot/any harness); judgment (correlation choice, plausibility, tests, assumptions) advises
  · EMERGENT: neuron-contract conformance is now an initiative (user endgame = synapse/neuron graph as AXON core). Background audit found 1 hard-invalid (workflow-run role=orchestrator) + ~24 semantic mismatches. Recorded as axon-ascent candidate `_candidate-neuron-conformance.md` (cluster-N), sequenced AFTER the memory wave
  · NEXT (per sequencing chain): memory wave (axon-ascent) → cluster-N. Reservoir P + V remain open on this track to interleave
- 2026-05-26 · W2 PVT DEMO SHIPPED (tno/main 43b2438) — tool-only, deletable
  · tools/reservoir_pvt.py — black-oil PVT via Standing (1947): Pb/Rs/Bo, field units,
    stdlib-only. Demo of AXON absorbing the domain; advisory-grade (validate vs lab PVT
    before decision use). Sample: API30/GOR500/200degF → Pb 2416 psia, Bo 1.30. 4 tests.
  · Shipped as a TOOL (the substantive capability). The reservoir-pvt WORKFLOW PROGRAM was
    dropped — full program conformance (HELP/IDENTITY-LOCK/OUTPUT-banner/DONE + compiled
    .cmp.md) is out of scope for a deletable demo; the suite CAUGHT the non-conformance
    (2 failures) and I scoped down rather than merge on red.
  · SELF-CONTAINED + DELETABLE per user request: workspace/programs/_reservoir-manifest.md
    lists the whole cluster + a one-shot removal recipe (rule not in core ALL_RULES; the only
    couplings are rule-enumeration lists in neuron_audit/lint_summary, documented).
  · STATUS: demo done. P (decision-grade PVT) + V (validation) remain DOMAIN-GATED — a
    reservoir engineer validates correlations/applicability/bounds to de-allowlist
    reservoir-review. Per user: deletable demo — absorb the machinery, not decision-grade.

# Open questions for user Q&A (before plan-phase goal)

These are the decisions I need from you to set a sharp plan-phase goal.
Grouped by impact.

## A · Architecture (highest impact)
1. **MCP client vs direct pyResToolbox import?**
   - (a) `tools/mcp_client.py` → call pyrestoolbox-mcp's 108 tools. Strategic:
     reusable for any MCP server, closes axons-audit lever #1, "connect
     differently" lesson. Cost: MCP plumbing (JSON-RPC, stdio/HTTP transport).
   - (b) `tools/pyrestoolbox_bridge.py` → import pyrestoolbox directly. Simpler,
     fewer moving parts, but no MCP, no reuse, doesn't advance the audit thesis.
   - (c) BOTH — bridge now for speed, MCP client as the strategic follow-on.
   My lean: (a) if this is also meant to seed axon-ascent's MCP work; (c) if you
   want a working reservoir demo fast.

2. **Scope of the reservoir family — how wide?**
   - Minimal: W1 screening + W2 PVT (2 workflows, ~5 programs).
   - Mid: + W8 sensitivity (exercises fan-out) + review gate.
   - Full: + matbal/nodal/relperm/flash/heterogeneity (W3-W7) + geomechanics
     (27 MCP tools, not even in the course).
   Where do we stop for v1?

3. **Is this a code-dev project that BUILDS programs, or a harness?**
   - Build reservoir programs into the main AXON workspace (general capability), OR
   - Use `harness-builder` to scaffold a dedicated "reservoir-engineer" harness
     (a focused agent) that ships separately?

## B · Domain fidelity
4. **Real engineering use or teaching/demo?** The source repo is explicitly
   educational (fictional data). Are we building decision-grade tooling
   (needs validation, correlation-applicability enforcement, peer-review gate
   teeth) or a polished demo of AXON's machinery on a real domain?

5. **Units default — field or metric?** And do we enforce a single project
   default or support both with explicit conversion at boundaries?

6. **Geomechanics in or out?** 27 MCP tools exist beyond the course's scope.
   Adjacent, valuable, but widens the domain surface a lot.

## C · Validation / endgame
7. **What's the "done" signal for the plan phase?** Candidates:
   - all 3 workflows run clean on the course's sample data + pass a review gate
   - a reservoir engineer can run `reservoir-screening <csv>` and trust the output
   - it doubles as the axons-audit "real domain" proof (machinery validated)
8. **Does this feed axon-ascent?** mcp_client + SPAWN/subagent + sensitivity
   fan-out are shared with axon-ascent levers #1/#16/#5. Do we build them HERE
   and let axon-ascent consume, or coordinate the two projects?

## D · My current lean (for you to confirm/redirect)
- Build `tools/mcp_client.py` (option 1a) — kills two birds with axon-ascent.
- v1 scope = WF-1 screening + WF-3 sensitivity (proves linear + fan-out
  machinery), + the domain review gate + reservoir.md prefs. Defer matbal/
  nodal/relperm/geomech to v2.
- Treat it as a code-dev project building INTO the workspace (general
  capability), with harness-builder as an optional later packaging step.
- Endgame: the 3 workflows + review gate become the axons-audit "AXON on a
  real technical domain" proof artifact.

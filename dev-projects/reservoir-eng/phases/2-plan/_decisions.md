# Decisions — reservoir-eng plan phase (2026-05-23)

Resolves the 8 open questions from phase 1-study `_open-questions.md`. User
confirmed: build reservoir-eng, plan deeply, **MCP client is top priority.**

| # | Question | Decision | Rationale |
|---|----------|----------|-----------|
| A1 | MCP client vs direct import | **MCP client (option 1a)** — TOP PRIORITY | Closes axons-audit lever #1; reusable for any server; host-independent (works no matter the CLI). Direct import was the dead-end shortcut. |
| A2 | Scope of v1 | **MCP egress + WF-1 screening + WF-3 sensitivity + review gate + reservoir prefs** | Proves linear pipeline + fan-out machinery. Defer matbal/nodal/relperm/geomech to v2. |
| A3 | Build-into-workspace vs harness | **Build into workspace** (general capability) | harness-builder is an optional later packaging step, not v1. |
| B4 | Decision-grade vs demo | **Demo-grade with decision-grade discipline** | Course data is fictional; but the review gate + output-standard are built real so the path to decision-grade is short. |
| B5 | Units default | **Field default, explicit metric conversion at boundaries** | Matches course + pyResToolbox default (psia/degF). `metric=False` is the lib default. |
| B6 | Geomechanics in/out | **OUT of v1** | 27 MCP tools, not in the course scope; widens surface too much for v1. |
| C7 | "Done" signal | **All 3 workflows run clean on the course sample data + pass the review gate; doubles as the axons-audit "AXON on a real domain" proof** | Concrete, demonstrable, strategically aligned. |
| C8 | Feeds axon-ascent? | **YES — mcp_client built HERE, axon-ascent consumes it** | Shared lever #1; also exercises #16 (SPAWN/subagent fan-out) + telemetry. Coordinate, don't duplicate. |

## Explicit design goals (carried into every PR)
1. **Host-independent MCP** — the client lives in AXON's tool layer, so the
   capability travels across every harness (Claude Code / Copilot / generic).
   Same behaviour on host B as host A.
2. **Self-contained tests** — CI must not require a live MCP server or
   pyResToolbox install. Use a stub MCP server fixture; gate live tests on
   availability (skip pattern, like axon-polish Phase-5 report guards).
3. **Moat-guard** — MCP is pure integration; it must not touch kernel rules
   (passes the turn-1==turn-100 test). Confirmed safe by the audit.
4. **Reuse the engine** — workflow/orchestrator/simulate/SPAWN are reused, not
   rebuilt. Net-new is the domain layer + MCP egress only.

---

## Cluster M — fine-grained decisions (resolved 2026-05-23, with user)
Grounding: official `mcp` SDK NOT installed; pyrestoolbox-mcp defaults to stdio;
deps via pyproject [dev]; 63 tools use `_axon_paths`.

| ID | Decision | Resolution |
|----|----------|------------|
| M-1 | Transport v1 | stdio only (subprocess); HTTP/SSE → v2 |
| M-2 | SDK vs hand-roll | **hand-roll** ~120-line stdlib JSON-RPC stdio client (no SDK dep). SDK = v2 option. (user ✓) |
| M-3 | Program surface | raw tool `TOOL(mcp, call, --server X --tool Y --args {...})` |
| M-4 | Server registry | workspace/mcp-servers.json (shareable) + local/ override for paths/secrets |
| M-5 | Timeout/start-fail | 30s/call default; never hang; clean error envelope |
| M-6 | Auth/secrets | env via local/ override; pyrestoolbox-mcp needs none |
| M-7 | Live server install | user runs locally; AXON supplies exact cmds (pinned at PR-M3 from repo). CI fixture-independent. (user ✓) |
| M-8 | Result shape | prefer structuredContent; fall back to text block; keep raw |
| M-9 | Arg pre-validation | light required-field check vs cached inputSchema |

Cluster M fully decided → ready for implementation when build mode starts.

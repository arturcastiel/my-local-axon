# Dependency DAG — Reservoir-Eng v1

```
                          ┌─────────────────────────────────────┐
   TOP PRIORITY ──▶  PR-M1 mcp_client (stdio) ──▶ PR-M2 server-registry ──▶ PR-M3 pyrestoolbox+guard
                          └─────────────────────────────────────┘                     │
                                                                                       │
   (parallel, no MCP dep)                                                              │
   PR-D1 reservoir-prefs ──▶ PR-D2 output-gate + reservoir-review ──┐                  │
                          └──▶ PR-P1 dispatcher + reservoir-qa ──────┤                  │
                                                                     ▼                  ▼
                                                          PR-P2 reservoir-dca + WF-1 screening
                                                                     │                  │
                                            PR-P3 reservoir-sensitivity + WF-3 ◀─────────┘
                                                                     │
                                                                     ▼
                                                          PR-V1 e2e validation  ◀── (P2 + P3)
```

## Reading the DAG
- **PR-M1 is the critical-path root** — top priority, unblocks all calc work.
- **PR-D1 + PR-P1 are independent of MCP** → start them in parallel with M-cluster
  as early wins (qa + prefs need no server).
- **PR-P2 (WF-1)** is the first full convergence: needs MCP (M3) + review (D2) + qa (P1).
- **PR-P3 (WF-3)** needs MCP (M3) + reuses AXON's existing orchestrator/SPAWN
  (no new engine).
- **PR-V1** is the join of P2 + P3 — the validation proof.

## Earliest-finish ordering (if shipping one PR at a time)
M1 → (D1 ∥ P1) → M2 → D2 → M3 → P2 → P3 → V1

## Shared with axon-ascent
- PR-M1/M2/M3  →  axon-ascent lever #1 (MCP client) — built here, consumed there.
- PR-P3 fan-out → exercises axon-ascent #16 (SPAWN/subagent registry).
- Any telemetry produced → feeds axon-ascent Phase-1 (the "use" the audit wants).

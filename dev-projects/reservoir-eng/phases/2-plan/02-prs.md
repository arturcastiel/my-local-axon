# PR roadmap — Reservoir-Eng v1

| # | PR | Cluster | Size | Depends on | MCP? | Acceptance gate |
|---|----|---------|:----:|------------|:----:|-----------------|
| 1 | PR-M1 mcp_client (stdio) | M | M | — | core | round-trips stub server; isError mapped; registry-drift clean |
| 2 | PR-M2 server registry | M | S | M1 | core | named-server resolves; ad-hoc cmd still works |
| 3 | PR-M3 pyrestoolbox link + param-guard | M | M | M2 | core | fixture tool-check passes; live test skip-gated; param-guard rejects sg_g misuse |
| 4 | PR-D1 reservoir prefs + L:keys | D | S | — | no | prefs load; unit default retrievable |
| 5 | PR-D2 output-standard gate + reservoir-review | D | M | D1 | no | gate fires on bad output; review returns ordered findings |
| 6 | PR-P1 reservoir dispatcher + reservoir-qa | P | S | D1 | no | qa flags bad CSV; dispatcher routes + hints |
| 7 | PR-P2 reservoir-dca + WF-1 screening | P | M | M3,D2,P1 | yes | WF-1 e2e on sample csv; EUR monotonic; review passes |
| 8 | PR-P3 reservoir-sensitivity + WF-3 | P | M | M3,P1 | yes | fans ≥3 cases; aggregates w/o averaging; runs under workflow |
| 9 | PR-V1 e2e validation scenarios | V | S | P2,P3 | yes | scenarios green; real-domain proof |

Total v1: **9 PRs** (3 MCP · 2 discipline · 3 programs/workflows · 1 validation).
Sizes: 6×S/M-small, 3×M. No XL. All test-self-contained (stub MCP server).

## Parallelizable
- PR-P1 (qa) + PR-D1 (prefs) have NO MCP dependency → can ship alongside the
  M-cluster as early wins.
- PR-M1 is the critical-path root; M2/M3 follow it.

## Deferred to v2 (explicitly out)
PR-M5 HTTP transport + mcp_server (reverse) · reservoir-pvt black-oil table
(WF-2) · matbal · nodal · relperm/flash · heterogeneity · geomechanics (27
tools) · harness-builder packaging.

## Critical path
PR-M1 → PR-M2 → PR-M3 → PR-P2 → PR-V1   (the MCP-to-validation spine)

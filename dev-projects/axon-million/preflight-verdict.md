# AXON Proof — Preflight Verdict (run-readiness, 2026-06-01)

> Output of `dual_agent_eval.py preflight` after B3 (the full-AXON-over-MCP arm) merged. Price-
> independent conclusiveness gate: can the proof clear the pre-registered bar (`CI-lower > 0.5`),
> at what N, at what cost — BEFORE spending. No live run; pure statistical + cost projection.

## Conclusiveness frontier — minimum N to clear `CI-lower > 0.5`

| Assumed AXON win-rate | n_min | Planned n=12 conclusive? | 95% CI at n=12 |
|---|---|---|---|
| 1.0 (sweeps) | **4** | ✅ | [0.757, 1.0] |
| 0.90 | 8 | ✅ | [0.552, 0.953] |
| **0.85** (pre-registered hypothesis) | **11** | ✅ (1-goal margin) | [0.552, 0.953] |
| 0.80 | 14 | ❌ underpowered | [0.468, …] |
| 0.75 | 16 | ❌ | [0.468, …] |
| 0.70 | 29 | ❌ | — |
| 0.65 | 48 | ❌ | — |

## Cost
- 12 goals × 2 arms ≈ **1.12M tokens ≈ $10.11** (API estimate; AXON arm assumed 1.6× tokens — VERIFY
  pricing). On a Pro/Max subscription the headline run is compute/time, ≈ $0 marginal.

## The read
- **Risk is statistical power, not money.** The planned 12-goal run is conclusive **iff AXON's true
  edge ≥ 0.85** (n_min=11; one goal of spare margin). Below that it's underpowered, and the prereg
  forbids retro-framing an underpowered run as conclusive.
- **Best case is decisive:** an AXON sweep clears it at n=4; 12 yields a crushing CI [0.757, 1.0].

## Recommended sequence (pilot → size → headline)
1. **Pilot** (4–6 goals) on the chosen backend (`--backend cli --axon-arm mcp` = the B3 OS arm, or an
   API key) to ESTIMATE the real win-rate.
2. Read N off the frontier above; scale the goal set if the effect is < 0.85 (16 @ 0.75, 29 @ 0.70).
3. Commit `prereg` (bar locks: `CI-lower > 0.5`, methodology+oracle+harness fingerprinted) BEFORE the
   headline run.
4. Headline run (Opus) → publish the CI.

## Verdict
**Conclusive-capable and cheap — GO from the code + statistics side.** No code blocks the number after
B3. The only gates are owner-side + non-code: (a) a backend/compute, (b) a pilot to confirm effect size,
(c) prereg before the headline run. The harness now measures the OS (B3), not a prompt.

# Phase prohibitions — 1-safety-contract

_Seeded from `../../_dont-do-seeds.md` — every invariant there applies (especially the autonomy block:
no pushing through red/ambiguous, stay in contract, reanchor, two-key, fan-out isolation, don't erode
autonomous_mode). Phase-specific additions below._

- DON'T let the contract/breakers DEPEND ON the agent's good behavior — they must be enforced by code
  (autonomous_mode + a checked contract), not by prose the agent is trusted to follow. The whole point
  is "intention decays, enforcement doesn't."
- DON'T over-scope phase 1 — contract + breakers + escalation only. Reanchor is phase 2; selection is
  phase 3; report/replay is phase 4.

# Plan — doctrine-fix
Updated: 2026-07-08 · 13 PRs / 4 waves · AXON: 8.5/10 · Owner: pending gate

## Principle
Every fix either WIRES a guarantee to a real trigger with a test that reaches it via the
production path, or NARROWS the claim to what the code delivers. The dont-do-seeds forbid
the two root-cause anti-patterns (monkeypatched run_active in security tests; set-but-unread
enforcement).

## Design forks resolved (study flagged these)
- C2 barrier — WIRE (not drop): arm via a sitecustomize env-flag so a real `python3 -c`
  child arms on startup (sitecustomize runs for -c/-m, unlike PYTHONSTARTUP); fix the
  `/axon` substring → path-segment match. The module works; only the injection + calibration
  were broken.
- H4 node-gate — WIRE both halves: move the current-node record to axon/state (whitelisted
  actor write, not agent-forgeable), AND engage S7b for ANY active doctrine run (attended
  too), since v1 runs are attended — else "obeyed" is vacuous for v1.
- H3 authorized() coverage — RECOMMEND NARROW (owner decision below): make the binding gate
  the RUN's authorization-to-start (the runner already binds+preflights) and the node-gate
  govern ops DURING a run; ordinary git ops OUTSIDE a run stay under AEGIS/policy as today.
  The alternative (route every commit/push/merge through authorized() at the shell gate) is
  invasive and slows every git op. Either way, the self-mint master-key (C3) is fixed HARD.
- C3 self-mint — fix at the SOURCE: guard grant_on/bind_doctrine themselves (refuse a
  new/renewed unattended grant while a run is active), not only the hook regex.

## Waves
- Wave 0 — HOTFIX + HONESTY (PR-01..03): contained gate one-liners on the real grant path;
  kill the self-mint at source; retract the oversold absolutes in docs + code comments.
  After this wave the doctrine is HONEST (claims match code) even before the deep fixes.
- Wave 1 — WIRE THE ENFORCEMENT (PR-04..07): barrier armed for real; node-gate state moved
  + engaged for attended; integrity fails on injected adds + covers the real artifacts.
- Wave 2 — BUILD THE RUN HEAD (PR-08..10): the proposer (a run can actually start),
  project-dir derive + phase-ledger + teardown, preflight completeness (schema + dont-do +
  referential validation).
- Wave 3 — REAL EVIDENCE + REAL TESTS (PR-11..13): arming reads real run evidence;
  chain/host-mirror honesty; replace monkeypatch theater with real-resolver + real-program
  behavioral tests.

## Constraints
Full repo suite green before every merge (per owner rule) · new/changed enforcement tests
must reach the real path (dont-do-seeds enforce) · what-holds set (binding, TTL/G6, chain
vs naive tamper, deletion classifier) must not regress · no absolute claim without a proving
test.

## Owner gate — one decision
H3: NARROW the binding claim to run-scoped authorization (recommended) vs ROUTE all ordinary
git ops through authorized() (fuller but invasive). All else is "make the shipped claim
true" with no scope choice.

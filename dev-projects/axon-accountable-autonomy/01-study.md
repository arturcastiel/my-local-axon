# Phase 1 — STUDY · axon-accountable-autonomy

## Goal
Make "stay accountable for what's running" mechanical, not advisory: track spawned/background work and
surface anything left un-reconciled at the natural stop point.

## Current state (the drift, grounded)
Autonomy was being treated as "spawn agents and move on." The only correction so far was prose ("write
it down"). AXON's own architecture audit established that prose is advisory and drifts — only Python
tools + hooks have teeth. So a durable fix must be a mechanism, not a note. Live proof this session: a
20-agent migration self-reported verified=true on all files, but the gate (reconciliation) caught a
real ratchet failure — only because the loop was tended, not abandoned.

## Design (owner-chosen)
- tools/accountability.py over a W: ledger (workspace/memory/working/accountability-ledger.json):
  - open --kind <workflow|agent|task|background> --ref <id> --what "<desc>"  → records OPEN work
  - reconcile --ref <id> [--note "<how verified>"]                            → closes it
  - status [--all]                                                            → lists open (un-reconciled)
- Stop-hook surface (verify_stop.py, LOG-ONLY, persona-guarded): if open entries exist, surface them at
  turn-end — never block (a Stop hook can't un-send; matches today's posture). Explicit open/reconcile
  (owner choice) — the hook catches what was recorded; recording is a one-line discipline.

## Methodology
PR-1 the tool + tests + REGISTRY entry (no-orphan gate stays green). PR-2 the hook surface + test. Each
branch-first, gate-green, merge by number. Then log + audit.

## Risk
Low — additive tool + a LOG-ONLY hook line (can't block). The ledger is a W: json key (captured by the
F44 checkpoint work). Worst case: a surfaced reminder is noise; it never stops a session.

## Confidence
9/10 — small, additive, gate-protected; the only judgement is the ledger schema + prune policy.

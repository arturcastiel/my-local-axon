# Study — doctrine-fix
Updated: 2026-07-08 · Source: axon-next/05-audit.md (4-seat council + Step-0 re-verify) · AXON: 9/10

## Goal
Make every oversold doctrine guarantee TRUE-or-narrowed. The audit is the study: 21 defects
already deep-verified with file:line, the sharpest re-confirmed by AXON probes. This study
just organizes them into a fix strategy.

## The defect set (from 05-audit.md — full detail there)
BLOCKER: B1 no proposer / W:doctrine-routine unset (run DOA) · B2 {project-dir} unbound.
CRITICAL: C1 bulk-delete gate inverted (truthiness) · C2 G1c barrier dead code ·
C3 anti-self-renew misses grant_on (self-mint).
HIGH: H1 timeout-flag-arg wrapper bypass · H2 arming gate hollow · H3 authorized() covers
only 2 op-classes · H4 S7b trusts agent-writable file + inert for attended runs.
MEDIUM: M1 preflight skips schema+dont-do · M2 phantom-next dead cursor · M4 phase-ledger
missing --program · M5 hash-chain no secret · M6 integrity add-blind/WARN · M7 header
comment-strip · M8 falsy-if inversion · M9 current-node never cleared · M10 integrity globs
miss real artifacts + DAG.json schema collision.
LOW: L1 mermaid escaping · L2 budget-before-terminal · L3 host-mirror decorative.

## What HOLDS (do not touch/regress)
grant binding+hash-relock · TTL+G6 invariant · receipt chain vs naive tamper · deletion
classifier + protected-subtree matching (no false positives) · resolve_next determinism.

## Root-cause themes → fix principles
1. Enforcement implemented but never WIRED (C2, H3, H4) → every gate must have a real
   trigger + a test that reaches it via the production path.
2. Guarantees tested with enforcement pre-faked ON (monkeypatch run_active everywhere) →
   replace with fixtures that make _resolve_myaxon find a real grant so run_active is
   genuinely True; a security test may not patch its own predicate.
3. One-line return-shape/truthiness bugs masked by unrealistic fixtures (C1 + grantless
   tmp_path) → fix + re-test on the real grant path.
4. The propose→run HEAD was never built (B1/B2) → build the proposer + the derive line, and
   a test that drives the actual doctrine-run PROGRAM, not just the tool.
5. Honesty: any absolute claim gets narrowed to what a real test proves (M5 chain, M6
   integrity, C2 barrier — wire it or drop the claim).

## Fix strategy — 4 waves (see 02-plan.md / 02-prs.md)
- Wave 0 HOTFIX (contained one-liners, high value): C1, C3-regex, H1, M7, M8, M2-guard,
  L2 + retract the unattended-arming absolutes in docs/comments.
- Wave 1 WIRE THE ENFORCEMENT: C2 (barrier armed for real OR removed+claim dropped),
  H3 (route ordinary ops through authorized() OR narrow the binding claim to what's gated),
  H4 (move node-gate state out of agent-writable space / sign it; engage for attended too
  or narrow the "obeyed" claim), M6 (integrity fails on unblessed adds; promote severity).
- Wave 2 BUILD THE RUN HEAD: B1 proposer + W:doctrine-routine writer, B2 project-dir derive,
  M4 phase-ledger --program, M1 preflight schema+dont-do, M10 integrity globs + schema
  collision, M9 current-node teardown.
- Wave 3 REAL EVIDENCE + REAL TESTS: H2 arming reads run status+run-scoped receipts,
  M5 chain honesty (secret/host-writer or narrowed claim), L3 host-mirror consumed-or-cut,
  and the big one — replace monkeypatch-theater with real-resolver/real-run tests + a
  behavioral test of the doctrine-run program. L1 mermaid escaping.

## Priorities
Wave 0 first (fast, contained, restores honesty). Wave 1 is the security spine. Waves 2-3
make the doctrine actually runnable + actually proven. Each wave: full repo suite before
merge; the new/changed tests must reach the real path (dont-do-seeds enforce it).

## Self-assessment
9/10 — the defects are already council-verified with reproductions; the fix strategy maps
each to a wave with an explicit honesty/wiring principle. Held below 10 because a few fixes
(C2 barrier, H3 authorized coverage, H4 node-gate location) have a genuine design fork
(wire-vs-narrow) that the plan phase must resolve per-item, not assume.

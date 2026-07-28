# Study input — the ranked backlog (grounded in measurement, 2026-07-13)

Continuation of axon4bugfree. Each item has evidence; the study should graphify + re-measure before building.

## RANKED (yield-per-effort, evidence-based)

### R1 — PR-006: parser consolidation onto tools/axonlang.py  [PRIMARY]
**32 .py files parse AXON-LANG with their OWN regex** and they disagree on the alphabet (memory_key_lint's
`(W|L)` is blind to the `E:` scope simulate parses). axon4bugfree built the canonical extractor; this migrates
consumers onto it. Value: reduce-surface + real correctness (E: scope) + a consistent foundation for any
future read-side work. Approach: incremental, per-consumer, proven behavior-equivalent (or behavior-improving
+ re-baseline) by each tool's EXISTING tests. Start with the highest-value: memory_key_lint, program_tool_conformance,
deps.py. The alternative seat called this the "un-cuttable" refactor.

### R2 — dead-key as a REPORT (WARN/advisory), NOT a BLOCK gate  [SECONDARY]
MEASURED: dead-key BLOCK is infeasible — W: keys have GENERIC BULK READERS (checkpoint SNAPSHOT(W:),
session_save, menu-snapshot read the whole namespace), so written-never-read can't distinguish truly-dead
from bulk-read. 78 candidates; ASSERT-reads clear 2, Python-reads ~20, but the rest are largely bulk-read.
So: ship `axonlang dead-keys` as an ADVISORY report (surfaces candidates for human review, never blocks) +
extend the extractor's READ side (ASSERT(scope:key) reads — the extractor currently misses these). This
completes the "AXON sees its own layer" reader half without the false-block trap.

### R3 — clear the small deferred kernel-floor (run-3 NEW-1/NEW-2)  [CLEANUP, human-gated]
`W:ws-name` (HIGH) + `W:ws-log` (MED) are phantom path-keys baselined in lint_path_vars (6 entries, still
present). Real fixes: repoint to W:myaxon-name / W:myaxon-log (defined) or make boot.py emit them. Small,
kernel-adjacent → owner-gated per the kernel-floor rule. Removing each from _BASELINE when fixed is the ratchet.

### R4 — verify the 4 quarantined leads from run-3  [VERIFICATION]
hr_team cwd defaults (a quick check showed 0 os.getcwd in hr_team.py — likely a NON-issue, verify + close) ·
hr-team persistence tier always "full-audit" · agent_memory capture-tier mislabel + false-orphan + ninth L:
parser · REGISTRY descriptive drift. Each: confirm-or-close before promoting to a PR. Don't build on unverified leads.

## NON-GOALS (per ADR-002 + measurement)
- No dead-key BLOCK gate (bulk-reader noise — measured).
- No graph emission (PR-007) unless a genuinely multi-hop finding appears.
- No behavior-changing parser migration without a re-baseline + the tool's tests proving it.

## SUGGESTED SEQUENCE
Study (graphify + re-measure R1's migration blast-radius per consumer) → plan (R1 first as incremental PRs,
R2 report, R3 owner-gated handoff, R4 verify-then-decide) → build.

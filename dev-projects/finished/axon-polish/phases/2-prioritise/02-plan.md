# Plan — 2-prioritise (cluster ranking)

> 15 clusters from `01-study.md`, ranked by **impact × (1/difficulty)** with prior-work cost reductions.
> Score formula: `impact (1-10) × (1 / size-weight) × (1 + prior-work-bonus)`
> Size weight: S=1 · M=2 · L=4 · XL=8.
> Prior-work bonus: 0% (greenfield) · 0.25 (pattern adopted) · 0.5 (substrate exists) · 1.0 (mostly shipped).

## Ranked clusters

| Rank | ID | Title | Size | Impact | Prior-work | Risk | Score | ADR | Findings closed |
|---|---|---|---|---|---|---|---|---|---|
| 1 | C-01 | TOOL(shell) sandbox + R9 realpath | M | 10 (heavy-WF gate) | substrate (cleanup PR-120 + master F-06) | high | 7.5 | ADR-001 | 5 BLOCKER |
| 2 | C-05 | Adaptive workflow termination + checkpoint per step | M | 9 (FREE MODE unblocks) | substrate (loop-receipt) | medium | 6.75 | open → ADR-005 | 1 BLOCKER + 3 MAJOR |
| 3 | C-12 | enforce.py hardening (user: bypass + stubs) | S | 9 (Rule 2 gate) | greenfield | low | 9.0 | ADR-001 sibling | 1 BLOCKER + 1 MAJOR |
| 4 | C-06 | Heavy-workflow resume / compaction / G-02 turn-1 | L | 10 (project goal) | partial (session.py PID fix shipped) | high | 3.13 | ADR-006 (proposed) | 2 BLOCKER + 4 MAJOR |
| 5 | C-02 | fail_render.py tool + migration kickoff | S | 8 (94 programs) | greenfield | low | 8.0 | ADR-002 | 2 MAJOR + 3 demands |
| 6 | C-03 | Deprecation policy scaffold + log + cron | M | 7 (catalog signal) | pattern (cleanup comment-deprecate + cron) | low | 4.38 | ADR-003 | 1 MAJOR + 2 demands |
| 7 | C-04 | Mainline composition path (PR-111 fix) | L | 9 (headline feature) | partial (synapse shipped pieces) | high | 2.81 | open → ADR-004 | 1 MAJOR + 3 misc |
| 8 | C-08 | Core Rule enforcer fill-in (5 missing) | M | 8 (compliance) | partial (tests already shipped 2 of 7) | medium | 6.0 | D-D8-001..017 | 5 BLOCKER + 3 MAJOR |
| 9 | C-07 | Context-pressure recalibration | S | 7 (Claude 4.x) | pattern (master W3-01/W3-03 design) | low | 8.75 | align master | 1 BLOCKER + 3 MAJOR |
| 10 | C-09 | Duplicated files + dead-code cleanup | S | 6 (first-impression) | greenfield | low | 6.0 | align master TOP-12 F-07 | 3 BLOCKER + 1 MAJOR |
| 11 | C-10 | Dispatcher wiring (explain/simulate/modes) | M | 7 (UX) | substrate (axon-wiring-gaps method) | low | 5.25 | route to wiring-gaps | 4 MAJOR |
| 12 | C-13 | Synapse ranker correctness | M | 6 (orchestrator quality) | substrate (axon-ranker-v2 scoped) | medium | 4.5 | route to ranker-v2 | 3 MAJOR |
| 13 | C-14 | Doc-drift correction (live-count pipeline) | M | 5 (trust) | greenfield | low | 2.5 | D-XC-001 | 5 MINOR |
| 14 | C-15 | Worst error messages + worst FAILs | S | 5 (DX) | depends on C-02 | low | 5.0 | ADR-002 dependent | 3 MINOR |
| 15 | C-11 | Catalog grooming pass (XL, ongoing) | XL | 4 (catalog hygiene) | substrate (cleanup PRs) | medium | 0.625 | align cleanup | 5 MAJOR + 3 MINOR |

## Top-5 expanded for Phase 3-design entry

### #1 — C-01 — TOOL(shell) sandbox + R9 realpath hardening  (score 7.5)
**Why first**: Closes the largest single attack surface in the OS. Until this lands, every other compliance fix is theatre.
**Bundled PRs** (preliminary):
- PR-1.1 — `tools/shell.py` with command allowlist + structured JSON output. Allowlist: read-only git subcmds, ls, cat, head, tail, wc, find, pwd, which, file. Block all writers.
- PR-1.2 — R9 hardening: `_is_axon_path` uses `os.path.realpath()`; `enforce.py is_inside_axon` likewise; tests for symlink + absolute + traversal bypasses (resolves F-D8-001, F-D8-006).
- PR-1.3 — Update REGISTRY.json: shell from `OPTIONAL/category=host` to `ACTIVE/category=tool`; update health-probe.
**Dependencies**: none.
**Risk**: high (touching the shell tool affects 61 programs). Mitigation: extensive allowlist tests + canary mode (log+allow before block).

### #2 — C-12 — enforce.py hardening  (score 9.0)
**Why second**: Smallest of the BLOCKER-fixes. The `user:` prefix bypass (F-D7-007a) is one-line fix; the stub gates need either real implementation or removal-with-warning.
**Bundled PRs**:
- PR-12.1 — `enforce.py` check-source: remove `"user:"` short-circuit; require actual file existence OR a documented `--user-instruction "..."` flag with audit log.
- PR-12.2 — check-arithmetic: either implement (call calculator + verify result matches expression) OR mark as `--advisory` and document.
- PR-12.3 — Tests for both branches.
**Dependencies**: none (independent of C-01).
**Risk**: low.

### #3 — C-05 — Adaptive workflow termination + per-step checkpoint  (score 6.75)
**Why third**: Unblocks the FREE MODE workflow (currently infinite-loop). Adds heavy-workflow plumbing.
**Bundled PRs**:
- PR-5.1 — `workflow-run.md`: add loop step counter; honor `rejection-criteria.steps > N` inside LOOP body.
- PR-5.2 — `workflow-run.md`: STORE `W:active-phase` as `workflow-run:step-N` per iteration; CHECKPOINT before each step.
- PR-5.3 — Goal-state mutation hook for adaptive workflows (closes F-D4-003).
**Dependencies**: none.
**Risk**: medium (changes workflow runtime semantics).

### #4 — C-02 — fail_render.py tool + migration kickoff  (score 8.0)
**Why fourth**: Best impact-to-cost ratio. One tool unblocks the FAIL conformance project; first 5-10 migrated programs set the pattern.
**Bundled PRs**:
- PR-2.1 — `tools/fail_render.py` + signature `fail_render(program, problem, cause=None, fix=None, suggested_next=None)`.
- PR-2.2 — AXON-LANG shorthand extension: `FAIL(prog, problem, cause, fix)` expands to tool call.
- PR-2.3 — Migrate 5 most-FAIL-heavy programs (canonical examples + tests).
- PR-2.4 — Lint rule (advisory) detecting bare-string FAIL calls.
**Dependencies**: none.
**Risk**: low.

### #5 — C-07 — Context-pressure recalibration for Claude 4.x  (score 8.75)
**Why fifth**: Pattern adopted from master W3-01/W3-03 — design is ready, just needs implementation.
**Bundled PRs**:
- PR-7.1 — `tools/context.py`: read `L:host-model` for context-limit lookup table; fall back to 128k.
- PR-7.2 — Session-scoped accumulator reset on boot.
- PR-7.3 — `tools/_axon_lib.py` `tokenizer_estimate` aligned with `context.py` (4-char/token).
**Dependencies**: none.
**Risk**: low.

## Phase 3-design entry criteria
Phase 3 begins on user signal. Entry:
- Top-5 clusters have ADRs (ADR-001 done, ADR-002 done, ADR-003 done; ADR-004 and ADR-005 needed for C-04 and C-05).
- Each cluster's PRs are sized (already done above).
- Risk-mitigation strategy noted per cluster.

## Routing decisions (clusters that move OUT of axon-polish scope)

| Cluster | Routes to | Why |
|---|---|---|
| C-10 dispatcher wiring | axon-wiring-gaps | Their reader/writer-join method directly applies |
| C-11 catalog grooming (XL ongoing) | axon-cleanup (continuation) | Their bulk-autopatch + comment-deprecate pattern |
| C-13 synapse ranker correctness | axon-ranker-v2 | Their controller scope |

**Net for axon-polish ownership**: 12 clusters (was 15). Three handed off with cross-refs.

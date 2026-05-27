# Deep plan — Reservoir-Eng v1

> Top priority: MCP egress. Everything calc-related depends on it. Build it
> first, hardened + host-independent + self-contained-tested, then layer the
> domain on top. PR roadmap table in `02-prs.md`; DAG in `03-dag.md`.

## Guiding constraints (from _decisions.md)
- MCP client lives in AXON's tool layer → portable across every harness.
- CI must never need a live MCP server → stub-server fixture; live tests skip-gated.
- Reuse the workflow engine; net-new = MCP egress + reservoir domain layer.
- Field units default; explicit metric conversion at boundaries.

---

## CLUSTER M — MCP egress  ·  TOP PRIORITY  (deepest spec)

### PR-M1 · tools/mcp_client.py — minimal stdio MCP client
**Why:** AXON has no way to speak MCP; this is the foundational brick for the
whole project and axons-audit lever #1.
**What:**
- A JSON-RPC 2.0 client over **stdio** (subprocess transport — pyrestoolbox-mcp's
  default). HTTP transport deferred to PR-M5.
- Lifecycle: `initialize` (protocolVersion, capabilities, clientInfo) →
  `notifications/initialized` → ready.
- `list_tools()` → `tools/list` → returns `[{name, description, inputSchema}]`
  (handle `nextCursor` pagination).
- `call_tool(name, arguments)` → `tools/call` → parse `content[]` +
  `structuredContent`; surface `isError:true` tool results as an AXON error
  envelope (distinct from JSON-RPC protocol errors like -32602).
- CLI surface:
  - `python3 tools/mcp_client.py list --server-cmd "<cmd>"`
  - `python3 tools/mcp_client.py call --server-cmd "<cmd>" --tool NAME --args '{...json...}'`
  - JSON output envelope: `{ok, tool, result|error, isError, raw}`.
**Files:** `tools/mcp_client.py` (new), `tools/REGISTRY.json` (+entry, category
  `integration`), `tests/test_mcp_client.py` (new),
  `tests/fixtures/mcp_stub_server.py` (new — a ~40-line MCP server implementing
  initialize/tools/list/tools/call for a trivial `echo`/`add` tool).
**Acceptance:**
- client round-trips against the stub: initialize → list (≥1 tool) → call → parse result
- `isError` tool result mapped to error envelope, rc≠0
- malformed/unknown tool → JSON-RPC error mapped, no crash
- `registry_drift check` clean (new tool registered)
- smoke test (no-args → help, rc≠0) passes
**Rollback:** delete file + registry entry + tests. No kernel touch.
**Risk:** low — pure new tool, stdlib subprocess + json. No external dep for tests.

### PR-M2 · server registry + named-server resolution
**Why:** programs shouldn't embed raw launch commands; reference servers by name.
**What:**
- `workspace/mcp-servers.json` (shareable) registering `{name → {transport,
  cmd|url, env?}}`. Machine-specific secrets/paths go in `local/` override.
- mcp_client gains `--server <name>` that resolves via the registry (falls back
  to `--server-cmd` for ad-hoc).
- `mcp_client list-servers` subcommand.
**Files:** `tools/mcp_client.py` (+resolver), `workspace/mcp-servers.json` (new,
  seeded with a commented pyrestoolbox entry), `tests/test_mcp_client.py` (+cases).
**Acceptance:** named server resolves to the stub; missing name → actionable
  error; ad-hoc `--server-cmd` still works.
**Risk:** low.

### PR-M3 · pyrestoolbox-mcp connection + reservoir param-guard
**Why:** wire the real 108-tool server + capture its param conventions so
programs don't misfire (sg_g vs sg, psd, zmethod, method enums).
**What:**
- Register `pyrestoolbox` in `mcp-servers.json` (launch via its documented
  `uv`/`fastmcp` cmd; document install in the PR).
- `workspace/programs/reservoir-mcp.md` (or a tools helper) encoding the
  param-pitfall map + method enums (STAN/VALMC/VELAR, DAK/HY/WYW/BUR,
  SWOF/SGOF/SGWFN) as a guard before calls.
- A **recorded fixture** of pyrestoolbox-mcp's `tools/list` (committed) so CI
  can validate tool-name/param expectations WITHOUT the live server.
- A **live-optional** smoke test (skip if server not installed) calling
  `oil_bubble_point` (35 API, 180 degF, rsb 800, sg_g 0.75, VALMC).
**Files:** `workspace/mcp-servers.json` (+pyrestoolbox), `tests/fixtures/
  pyrestoolbox_tools_list.json` (recorded), `tests/test_reservoir_mcp.py` (new).
**Acceptance:** param-guard rejects a gas-tool `sg_g` misuse; fixture-based
  tool-name check passes; live test skips cleanly when server absent.
**Risk:** medium — depends on pyrestoolbox-mcp launch details; mitigated by
  fixture so CI is independent of the live server.

### PR-M5 (deferred) · HTTP/SSE transport + mcp_server.py (reverse direction)
Out of v1. HTTP transport for remote servers; `mcp_server.py` exposes AXON
tools as MCP (axons-audit lever #2). Noted for v2.

---

## CLUSTER D — domain discipline

### PR-D1 · reservoir preferences + L: keys
- `workspace/preferences/reservoir.md`: field-units default, prefer-MCP policy,
  param pitfalls, correlation applicability ranges, the output-standard block.
- L: keys: `L:reservoir-units` (field|metric), `L:reservoir-prefer-tool` (true).
**Acceptance:** prefs load; a program can RETRIEVE the unit default.

### PR-D2 · output-standard gate + reservoir-review program
- Lint-pack-tier gate `R_RESERVOIR_OUTPUT` (warn default, enforce via
  `L:reservoir-output-required`) asserting reservoir-* program output carries
  inputs+units+method+result+sanity+assumptions (mirror of axon-polish's
  advisory-tier rules).
- `workspace/programs/reservoir-review.md` — the reviewer subagent → an AXON
  review program (units, correlation applicability, nonphysical outputs, MCP
  param mistakes, missing tests). Findings-first, severity-ordered.
**Acceptance:** gate fires on a malformed output, clean on a compliant one;
  reservoir-review returns ordered findings on a seeded bad calc.

---

## CLUSTER P — programs + workflows

### PR-P1 · reservoir dispatcher + reservoir-qa
- `reservoir.md` dispatcher (CASE subcommand → qa|dca|pvt|sensitivity|review,
  with the `(use: ...)` hint pattern from axon-polish PR-15.1).
- `reservoir-qa.md`: production CSV QA (schema/dates/nonneg/dup/monotonic +
  water-cut/GOR ranges). No MCP needed — good first program; reuses CLI pattern.
**Acceptance:** qa flags a seeded-bad CSV (negative rate, dup well/date),
  passes a clean one; dispatcher routes + errors helpfully.

### PR-P2 · reservoir-dca + WF-1 reservoir-screening (Fixed workflow)
- `reservoir-dca.md`: QA → decline fit → forecast → EUR. MCP `fit_decline` /
  `estimated_ultimate_recovery` (fallback hand-rolled exponential for the
  teaching/offline case).
- `workspace/workflows/reservoir-screening.yml`: qa → water-cut → dca → eur →
  review (Fixed DAG with QA-fail HALT + review gate).
**Acceptance:** workflow runs end-to-end on course sample_production.csv; EUR
  monotonic vs economic limit; review gate passes; `workflow simulate` dry-runs clean.

### PR-P3 · reservoir-sensitivity + WF-3 (Adaptive fan-out)
- `reservoir-sensitivity.md` + `workspace/workflows/reservoir-sensitivity.yml`:
  expand case matrix (pb×Z×skin) → per-case MCP calc (fan-out via orchestrator/
  SPAWN) → aggregate (NO averaging unlike methods; flag review-needed) → review.
**Acceptance:** fans ≥3 independent cases, aggregates into a method|units|
  result|sanity table, never averages across methods; runs under `workflow run`.

---

## CLUSTER V — validation (phase 4)

### PR-V1 · e2e scenarios (the "trust the output" proof)
- `tests/test_reservoir_e2e.py` (axon-polish Phase-5 pattern): WF-1 + WF-3 on
  course sample data; each scenario asserts the output-standard + a known-value
  or monotonicity check. Report doubles as the axons-audit "AXON on a real
  domain" artifact.
**Acceptance:** scenarios green; heavy-workflow-on-a-real-domain demonstrated.

---

## Sequencing rationale
1. **M1→M2→M3 first** (MCP egress) — nothing calc-related works without it, and
   it's the strategic top priority + shared with axon-ascent.
2. **D1→D2** — discipline before domain programs, so every program is born
   compliant with the output-standard.
3. **P1 (qa, no MCP)** can proceed in parallel with M (no dependency) — good
   early win that also validates the dispatcher pattern.
4. **P2 (WF-1)** needs M3 (MCP dca) + D2 (review) + P1 (qa).
5. **P3 (WF-3)** needs M3 + the orchestrator/SPAWN machinery (already in AXON).
6. **V1** last — validates the whole.

## Handoff protocol (every PR)
Per repo convention: AXON branches, runs pytest, pushes feature branch, opens
draft PR, watches CI (auto-rerun infra flakes), reports. User merges. Tests are
self-contained (stub MCP server) so CI is green without external installs.

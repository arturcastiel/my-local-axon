# Spike report — Graphify validation on THIS repo (R1)

Date: 2026-06-09 · Authorized by owner · Read-only against the live repo (live `axon/` + `tools/` untouched;
all work in `/tmp/gspike`). Purpose: lift the study L3 → L4 with measured numbers on `/home/arturcastiel/projects/new-axon/axon`.

## Setup
- `graphifyy 0.8.36` already installed (Python 3.10, `~/.local/bin/graphify`); 26 tree-sitter grammars present; clean.
- Target: 10 representative tools copied to `/tmp/gspike/src/` — the introspection tools + helpers
  (`registry_drift, call_graph, deps, coherence_lint, doc_anchors, shadow, _axon_paths, _axon_io, _axon_lib, axon_audit`).
- Build command: `graphify update .` — the **"no LLM needed"** deterministic code path.

## Results (all PASS)

| Check | Result | Notes |
|---|---|---|
| Install | clean | 0.8.36, all grammars satisfied |
| Build (10 files) | **160 nodes / 269 edges / 10 communities / 0.86s** | sub-second; §19's full `tools/` was 5m33s @ ~204 files |
| Confidence | **269/269 EXTRACTED (100%)** | typed `confidence` + `confidence_score` fields on every edge |
| Schema | top keys `directed/multigraph/graph/nodes/links/hyperedges` | edge key is **`links`** (not `edges`) — §19 gotcha confirmed |
| **Determinism** | **byte-identical across 2 builds** | nodes, edges, AND Leiden community assignments all identical |
| **Blast-radius** (`affected "_axon_paths"`) | **5 exact importers, <1s** | `_axon_io, _axon_lib, axon_audit, call_graph, deps` — the K1/K2 capability, working |
| `explain "registry_drift"` | node degree 7, community 5, `contains` edges to its functions | function-level structure captured, all EXTRACTED |
| Free artifacts | `graph.html` (131KB viz), `GRAPH_REPORT.md`, `manifest.json` | visualization + report come for free |

## What this proves (and what it doesn't)

**Proven on THIS repo:** the deterministic code path is real, fast, 100%-EXTRACTED, byte-reproducible, and
delivers the blast-radius (`affected`) + function-graph (`explain`) capabilities K1/K2 need — out of the box,
no LLM, no key, $0. Reading confidence from `graph.json` is **typed** (the lossy-text problem is MCP-only,
so the CLI/graph.json path the study recommended is the right one).

**Not yet measured (residual for plan phase):**
- Full `tools/` (166 .py) build time *on this machine* (only the 10-file subset run; §19's 5m33s is the cross-checkable estimate).
- The P3 LLM semantic path (needs an API key — deliberately not exercised; out of the deterministic spine).
- Exact `--obsidian` vault-export invocation (not surfaced in top-level help; `graph.html` already gives a viz; K4's
  synapse-projection is a custom `obsidian_sync.py` anyway). Confirm at plan time.
- MCP server path (study already prefers CLI/`graph.json` over MCP — not a blocker).

## Full `tools/` build (headline, this machine)
- **166 Python tools → 2,317 nodes / 4,589 edges / 144 Leiden communities** in **3.61s** (code-only `update`).
- **99.3% EXTRACTED** (4,555/4,589; 34 INFERRED) — matches §19's ratio exactly.
- Browser viz: `study/spike/full/tools-graph.html` · report: `study/spike/full/GRAPH_REPORT.md`.
- **Key correction to the study's risk model:** §19's "full build killed at ~9 min" was the WHOLE repo
  (markdown via LLM). The **code-only spine is sub-4-seconds** → P1/P2 build cost is negligible; the
  slow/LLM path only appears in P3 (by design). `.graphifyignore` still recommended to scope future runs.

## Verdict
The Graphify adoption is **empirically de-risked for the deterministic spine (P1–P2)**. Study maturity L3 → **L4**
for the core capability. The gotchas the bridge must handle (read `links`, exit-code can lie, prefer exact node
IDs over free-text) are confirmed real and already captured in 01-study §8 (rerun triggers) and the draft bridge.

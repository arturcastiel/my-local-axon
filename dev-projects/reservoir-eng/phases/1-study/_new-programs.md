# New programs / tools / gates catalog (study layer 4 — AXON mapping)

How the course's Claude assets + domain workflows map onto AXON primitives,
and what is NET-NEW vs REUSE.

## The 1:1 asset → AXON-primitive mapping (the key insight)
| Course asset (Claude Code) | AXON primitive | Net-new? |
|----------------------------|----------------|----------|
| `.claude/skills/reservoir-engineering/SKILL.md` | a `reservoir` program family (markdown programs ARE skills) | NEW programs |
| `.claude/agents/reservoir-reviewer.md` | a response-GATE + `reservoir-review` program (mirror of code-dev reviewer) | NEW gate+program |
| `.claude/skills/run-tests/SKILL.md` | existing AXON test machinery / `code-dev` verify | REUSE |
| `CLAUDE.md` domain rules | `workspace/preferences/reservoir.md` + L: keys + domain gate | NEW prefs+gate |
| `references/pyrestoolbox-workflows.md` quick-checks | workflow YAML DAGs w/ quality-gate steps | NEW workflows |
| pyResToolbox via MCP | `tools/mcp_client.py` (calls 108 MCP tools as AXON TOOLs) | NEW tool — shared w/ axon-ascent #1 |
| parallel fan-out (module 9) | `workflow` (adaptive/hybrid) + orchestrator + SPAWN | REUSE machinery, NEW workflow |
| explore→plan→code→verify | `code-dev` lifecycle + `simulate` | REUSE |

## NET-NEW tools
- **`tools/mcp_client.py`** — THE pivotal dependency. Connects AXON to
  pyrestoolbox-mcp (108 tools). Same lever as axon-ascent #1 → build once,
  both projects consume. `TOOL(mcp, call, --server pyrestoolbox --tool oil_bubble_point --args {...})`.
  Decision point (see _open-questions): MCP client vs direct `pyrestoolbox` import.

## NET-NEW programs (the reservoir family)
- `reservoir`            — domain dispatcher (like `code-dev`): routes subcommands
- `reservoir-qa`         — production CSV QA (module 7): schema/dates/nonneg/dup/monotonic
- `reservoir-pvt`        — oil+gas PVT quick-check → optional black-oil table (W2)
- `reservoir-dca`        — QA→decline fit→forecast→EUR (W1)
- `reservoir-matbal`     — P/Z + Havlena-Odeh + drive indices (W3)
- `reservoir-nodal`      — IPR+VLP→operating point (W4)
- `reservoir-relperm`    — fit + SWOF/SGOF/SGWFN tables (W5)
- `reservoir-sensitivity`— parallel fan-out + aggregate (W8, module 9)
- `reservoir-review`     — domain reviewer gate (module 6)
- `reservoir-explain`    — plain-English walkthrough of a calc (output-standard render)

## NET-NEW gate + preference (the "connect differently" answer)
- **`workspace/preferences/reservoir.md`** — units (field/metric), prefer-tool
  policy, param pitfalls (sg_g/sg/psd/zmethod), correlation applicability ranges.
- **Domain output-standard gate** — fires on `reservoir-*` program output;
  asserts every result carries inputs+units+method+result+sanity-check+assumptions.
  Analogous to the kernel coherence guardian but domain-scoped (lint-pack tier,
  like axon-polish's R_OVERRIDE_ATTEMPT — advisory→enforce flag).

## NET-NEW workflows (YAML DAGs)
- `reservoir-screening.yml`  (Fixed)   — W1: qa → water-cut → dca-fit → eur → review
- `reservoir-pvt-table.yml`  (Fixed)   — W2: recommend → oil-pvt → gas-pvt → harmonize → black-oil-table → review
- `reservoir-sensitivity.yml`(Adaptive)— W8: fan cases → per-case MCP calc → aggregate (no averaging unlike methods) → review

## REUSE (already in AXON — do NOT rebuild)
- workflow engine + orchestrator (axon has these) → fan-out + DAG execution
- `simulate` → dry-run before any write (= the course's plan-mode lesson)
- `code-dev` lifecycle → for BUILDING these programs (study→plan→pr→log)
- test machinery / pytest discipline → the verify lesson
- `harness-builder` → if a standalone reservoir-engineer harness is wanted
- 3-tier memory + L: keys → store domain standards persistently

## Dependency ordering (for the eventual plan phase)
1. `tools/mcp_client.py` (or pyrestoolbox bridge) — everything calc-related needs it
2. `workspace/preferences/reservoir.md` + domain gate — discipline first
3. `reservoir-qa` + `reservoir-dca` (W1 screening — the simplest end-to-end)
4. `reservoir-pvt` (W2) + `reservoir-review` gate
5. `reservoir-sensitivity` (W8 — exercises the fan-out machinery)
6. matbal/nodal/relperm (W3/W4/W5 — deeper, MCP-heavy)

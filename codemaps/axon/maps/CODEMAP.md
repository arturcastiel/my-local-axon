# Code Map — axon
> Repo:      /home/arturcastiel/projects/new-axon/axon
> Graph:     23302 nodes · 27384 links · 1903 communities
> Built at:  b178af58da7586678bc20501feee645e2f02b835

## How this repo is wired
Relations: contains:18853  calls:4800  rationale_for:2080  method:752  references:706  imports_from:111  imports:57  inherits:15  defines:6  uses:3  re_exports:1
Confidence: EXTRACTED:27094  INFERRED:290

## Modules (by size)
- **workspace/programs** — 6474 nodes · 6368 int / 2 cross · top: workflow-run.md, code-dev-study.md, code-dev-plan.md, hr-team-deliberator.md
- **tests** — 5933 nodes · 7647 int / 114 cross · top: test_hr_team_contract.py, programs, test_dual_agent_eval.py, ._load()
- **tools** — 3733 nodes · 6115 int / 172 cross · top: hashes, tools, default_workspace(), predicate.py
- **tests/synapse/corpus** — 568 nodes · 548 int / 0 cross · top: code-dev-audit.contract.json, code-dev-decision.contract.json, code-dev-event.contract.json, code-dev-check-structure.contract.json
- **tests/test_rules** — 452 nodes · 599 int / 40 cross · top: test_r_new_needs_test.py, test_r_code_change_requires_pr_phase.py, test_r_terminal_outputs.py, test_r_grounded_claims.py
- **workspace** — 446 nodes · 415 int / 0 cross · top: DAG Spec (v1) — 5 levels + nested sync-checker, param_conventions, Neuron Contract Schema (v1.1; was Synapse Contract v1), Workflow File Schema (v1)
- **axon/programs** — 301 nodes · 274 int / 1 cross · top: ══════════════════════════════════════════════════════════════════════════════, desc:    Create a new chat in a folder — give it a name and a goal, PROGRAMS, desc: Interactive mode — continuous AXON session loop
- **workspace/hr-team/catalog/professions/science** — 272 nodes · 238 int / 0 cross · top: applied-mathematician.md, atmospheric-chemist.md, bioinformatician.md, climate-and-atmospheric-modeller.md
- **(root)** — 235 nodes · 221 int / 58 cross · top: ValueError, AXON Changelog, AXON — Setup Guide, conftest.py
- **workspace/wiki** — 228 nodes · 214 int / 0 cross · top: Getting started — your first project with code-dev, HR Team — user manual, HR Team Catalog — user guide, workflow — user manual
- **tools/rules** — 220 nodes · 376 int / 94 cross · top: Violation, registry.py, run_runtime(), r_code_change_requires_pr_phase.py
- **workspace/tools** — 205 nodes · 271 int / 1 cross · top: hooks.py, cron.py, events.py, context.py
- **workspace/hr-team/handoff** — 181 nodes · 175 int / 0 cross · top: HANDOFF — axon-hr-team v1, manifest.json, §V · VERIFICATION CHECKLIST — axon-hr-team v1, §Z · Bibliography
- **axon/tools** — 180 nodes · 155 int / 0 cross · top: Inventory (regenerated 2026-07-10 — 187 tools: 167 ACTIVE, 20 OPTIONAL), TOOL: calculator, TOOL: boot, TOOL: checkpoint
- **workspace/hr-team/prompts/modes/presets** — 180 nodes · 160 int / 0 cross · top: Adversarial Collaboration  ·  Mode preset, Aggressive Critique  ·  Mode preset, Analogy Mode  ·  Mode preset, Audit Mode  ·  Mode preset

## Hubs (load-bearing symbols)
| deg | symbol | file | c |
|---|---|---|---|
| 237 | `hashes` | tools/program_hash_manifest.json | c17 |
| 100 | `tools` | tools/REGISTRY.json | c633 |
| 90 | `default_workspace()` | tools/_axon_paths.py | c61 |
| 85 | `test_hr_team_contract.py` | tests/test_hr_team_contract.py | c298 |
| 77 | `Violation` | tools/rules/registry.py | c1 |
| 72 | `programs` | tests/coverage.json | c1246 |
| 63 | `programs` | workspace/programs/REGISTRY.json | c702 |
| 60 | `test_dual_agent_eval.py` | tests/test_dual_agent_eval.py | c22 |
| 53 | `predicate.py` | tools/predicate.py | c4 |
| 49 | `atomic_write()` | tools/_axon_io.py | c12 |
| 48 | `registry.py` | tools/rules/registry.py | c1 |
| 46 | `dag.py` | tools/dag.py | c9 |
| 41 | `hr_team.py` | tools/hr_team.py | c489 |
| 36 | `dual_agent_eval.py` | tools/dual_agent_eval.py | c491 |
| 34 | `workflow_run.py` | tools/workflow_run.py | c16 |

## Subsystems (communities ≥ 3)
### c17 · 237 nodes — modules: tools
- hubs: hashes, workspace/programs/_code-dev-schema-v4.md, workspace/programs/audit-to-study.md, workspace/programs/authoring-guide.md, workspace/programs/auto-actions.md, workspace/programs/auto-improve.md
### c0 · 100 nodes — modules: workspace/_dashboards
- hubs: Communities (natural subsystems), C0 — 1452 node(s) · anchor `_axon_io`, C1 — 87 node(s) · anchor `goal`, C2 — 85 node(s) · anchor `dual_agent_eval`, C3 — 63 node(s) · anchor `code_graph`, C4 — 23 node(s) · anchor `graphify_bridge`
### c4 · 88 nodes — modules: tools
- hubs: predicate.py, _ctx_path_value(), Any, Parser, _truthy(), _interpolate()
### c2 · 79 nodes — modules: workspace/programs
- hubs: workflow-run.md, PROGRAM: workflow-run, desc:    Execute a workflow file end-to-end — walks the synapse DAG, dispatching each synapse per its on-complete predicates., dispatch-phrases: run a workflow · execute the workflow · walk the synapse DAG · kick off the flow, synapse:, domain: workflow
### c3 · 72 nodes — modules: axon/programs
- hubs: ══════════════════════════════════════════════════════════════════════════════, PROGRAM-TEMPLATE, Copy this file to workspace/programs/[name].md when creating a new program., Fill every section marked with [FILL]. Remove sections marked [OPTIONAL] if unused., Sections marked [KEEP] are required — do not remove them., ── HELP BLOCK [KEEP] ─────────────────────────────────────────────────────────
### c1 · 68 nodes — modules: tools/rules, tests
- hubs: Violation, registry.py, run_static(), r_autonomy_cadence.py, r_autonomy_breaker.py, r_tool_call_exists.py
### c6 · 66 nodes — modules: workspace/programs
- hubs: code-dev-plan.md, PROGRAM: code-dev-plan, budget:, input-cap:    8000, output-cap:   2000, cache-prefix: 2048
### c54 · 65 nodes — modules: workspace/programs
- hubs: hr-team-deliberator.md, PROGRAM: hr-team-deliberator, desc:    hr-team Layer 3 — aggregate council seat votes, classify dissent, emit advisory verdict, tests:   tests/test_hr_team_deliberator_contract.py, synapse:, domain: deliberation
### c8 · 63 nodes — modules: workspace/programs
- hubs: code-dev-study.md, PROGRAM: code-dev-study, budget:, input-cap:    16000, output-cap:   6000, cache-prefix: 4096
### c59 · 61 nodes — modules: workspace/programs
- hubs: hr-team.md, PROGRAM: hr-team, desc:    Advisory professional council — selects seats, runs protocol, returns dissent-preserving verdict, dispatch-phrases: convene the council · ask the panel · run it past the HR team · multi-persona review · get a second opinion from a council · deliberate this decision · advisory panel verdict, tests:   tests/test_hr_team_router.py, synapse:
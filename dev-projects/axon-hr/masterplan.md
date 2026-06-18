# Masterplan — AXON HR Team

## Objective
Incorporate the `hr-team` meta-neuron into this AXON repo:
1. A new **menu mode "HR Team"** (wired into `workspace/programs/menu.md`).
2. A **flexible neuron** (program + optional MCP tool) callable standalone
   (`hr-team ...`) AND embeddable by other workflows / the orchestrator.
Grounded in the v1 handoff bundle at `~/axon-hr-team/output/handoff/`.

**Scope (ADR-001): FULL PORT** — author the council runtime, wire the menu mode,
AND copy the 151-row profession catalog + 63-file prompt pack into `workspace/`
(self-contained in this repo).

## Phase graph (directed)

- **study** → plan → pr → log → audit

study : ingest HANDOFF.md (16 §§) + INDEX + V-checklist; map AXON integration
        points (menu, programs/, tools/REGISTRY.json, workflow-runner, dispatch);
        decide what runtime to author per §13 H1–H4; fix goal + confidence.
plan  : codebase-grounded plan + numbered PR list (mode wiring, council program,
        catalogs port, prompt-pack port, tests, registry/docs regen).
pr    : per-PR specs.
log   : implementation log.
audit : completion audit vs spec + V-checklist.

Phases are added by: code-dev phase new

## Key design constraints (from handoff reader contract)
- 3-layer separation preserved (SELECTOR / CONVENER / DELIBERATOR).
- Dissent preserved in output; sealed-ballot when voting.
- `advisory_only: true` non-overridable.
- Cost guardrail: context accumulation is the dominant cost driver.
- Core Rule 13: tests before ACTIVE.


## Plan amendment — 2026-06-18 (open-items resolved, ADR-010/011)
PR-007 split → PR-007a (catalog/risk) · PR-007b (prompts) · PR-007c (handoff, optional).
PR-009 ADDED (closeout, fullest docs/wiki — ADR-011): wiki/hr-team.md + hr-team-catalog.md +
  hr-team-recipes.md + INDEX + getting-started blurb + AXON-DOCS/DOC-INDEX regen + CHANGELOG;
  satisfies test_wiki + test_freshness_wiki. Merged LAST.
Final PR order: PR-001 selector · 002 convener · 003 deliberator · 004 router · 005 tool/seam ·
  006 menu[10]+dispatch · 007a catalog · 007b prompts · (007c handoff) · 008 find-program(decoupled) ·
  009 docs/wiki(last). PR-008 orderable anytime (depends_on=[]).

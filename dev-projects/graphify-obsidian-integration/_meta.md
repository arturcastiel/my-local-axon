# Project: Graphify × Obsidian — deterministic-graph + vault substrate for AXON
slug:            graphify-obsidian-integration
schema-version:  v4
status:          complete
legacy:          false
phase:           5-audit (DONE)
workflow-step:   done
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
created:         2026-06-09
updated:         2026-06-09

## Goal (provisional — finalised in 01-study.md after the study synthesis)
Evaluate and (where it makes AXON better/more resilient/more expandable) adopt **Graphify**
(a deterministic AST knowledge-graph tool with confidence-tagged edges + MCP server + Obsidian
export) and the **Obsidian vault** layer into AXON — driven by a 3-round, 0.95-confidence handoff
package authored externally. The study phase REFRAMES the handoff away from its stated headline
goal (chase RAG-maturity 40/70 → 70/70) — which collides with this AXON's recorded 2026-06-09
WON'T-DO decision (dense embeddings / RRF fusion / query-expansion-HyDE / multi-hop are
won't-do-by-design; 58/70 is a deliberate sparse ceiling, "do not chase 70/70, it would degrade
AXON") — toward the parts that ALIGN with AXON's deterministic / anti-fabrication / reduce-surface
design: self-introspection, code-dev graph-awareness, and the Obsidian vault UI over the one
source of truth.

## Source material
- External handoff package: /mnt/c/projects/copilot-tests/axon-graphify-obsidian-handoff/
  (README, MASTER-HANDOFF, CODE-DEV-PROMPT, sections/01–23, draft-tools/, draft-frontmatter/, draft-vault/)
- Handoff was authored against a DIFFERENT, older AXON checkout (/mnt/c/projects/copilot-tests/axon).
  Several load-bearing premises are stale vs THIS live repo — see 01-study.md §"Grounding ledger".

## Authorization basis (DELIBERATELY MINIMAL — owner directive 2026-06-09)
- **Study-only.** Owner: "set all goals … study it as much as you can, once you are done with study
  phase let me know and I take over, so NO autonomous mode."
- NO autonomous-mode grant. NO AEGIS develop/test/merge grant. NO writes to the codebase.
- This project's study phase produces planning artifacts ONLY (01-study.md + study notes).
  Owner resumes for plan / PR / execute.
- Inviolable floor unchanged: any axon/ kernel edit is human-only regardless.

## Study outcome (one line)
Handoff is high-quality but authored against an OLDER checkout; its headline goal (RAG 40/70→70 via
Graphify dense retrieval) is REFUTED + CONTRADICTS this repo's won't-do decision. A small design-aligned
core survives — K1 tool-layer AST self-introspection graph, K2 fix the live blast-radius bug, K3
confidence discipline, K4 Obsidian one-way projection (not a corpus migration). Sharpest call for owner:
build ~150-line stdlib-`ast` tool (Path B) vs adopt Graphify+tree-sitter (Path A) — study leans B. See
`01-study.md` §4/§6/§10 + `study/reconciliation-ledger.md`.

## Phase log
- 1-study: **DONE** (2026-06-09) — 17-agent parallel study (9 ingest over 23 handoff sections + 8
  live-repo grounding probes; 1 probe re-run after a session-limit, recovered) → grounding ledger +
  reconciliation ledger + 01-study.md. **Owner resumes for 2-plan.** No autonomous execution (per authorization).
- 2-plan / 3-pr / 4-execute / 5-audit: NOT STARTED — owner-gated.

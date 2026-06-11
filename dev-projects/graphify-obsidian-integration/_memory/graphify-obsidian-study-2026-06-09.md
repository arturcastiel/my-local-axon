---
id: graphify-obsidian-integration-study-2026-06-09
tier: project
scope-ref: graphify-obsidian-integration
bindings: graphify-obsidian-integration, graphify, obsidian, rag-wontdo, deterministic-graph
source: study
date: 2026-06-09
confidence: high
privacy: private
supersedes:
---
graphify-obsidian-integration project (2026-06-09, Phase-1 study DONE, owner resumes for plan):

CONTEXT. External 3-round 0.95-confidence handoff at /mnt/c/projects/copilot-tests/axon-graphify-obsidian-handoff/
proposes integrating Graphify (deterministic tree-sitter AST knowledge graph, confidence-tagged edges
EXTRACTED/INFERRED/AMBIGUOUS, MCP server, Obsidian export) + Obsidian vault into AXON, headline goal =
drive RAG-maturity 40/70→66-70 over 8 phases / ~60 PRs. Authored against an OLDER checkout
(/mnt/c/projects/copilot-tests/axon, "v1.1.6/153 tools/40-70/rag-master-plan exists").

GROUNDING (17-agent study, 8 live probes on /home/arturcastiel/projects/new-axon/axon @ 9c221ca):
handoff's headline is REFUTED here. RAG is 58/70 not 40/70; the dense rows it would close (B1 dense,
B3 RRF, C1 HyDE, C2 multi-query) are the EXACT rows AXON-DOCS-RAG-DEVELOPMENT.md records as "won't-do by
design" ("chasing 70/70 would degrade AXON"); 6 of 7 "future tools" absent by design; rag-master-plan
DELETED in 01392b2; graphify = 0 refs in tree+history; tree-sitter not installed; 157 tools (137 ACTIVE),
AXON reducing surface.

RECONCILIATION (the value AXON added — judgment, not throughput). KEEP (deterministic-substrate, aligns):
K1 tool-layer AST self-introspection graph (the genuine gap — the 6 tools the handoff says graphify
"replaces" graph MARKDOWN/registry, NOT python AST; nothing maps tools/*.py import/call edges, so
"change _axon_paths.default_workspace → which of 157 tools break?" is unanswerable today);
K2 fix the LIVE blast-radius bug (code-dev-knowledge-impact.md reads symbols.exported that shadow.py
never emits → grep degrades to \b()\b); K3 confidence-tag discipline (R6); K4 Obsidian as a ONE-WAY
exporter tools/obsidian_sync.py (~8-10h) reading comment-blocks → sidecar .dataview/.base, NOT the
196-file/39-50h frontmatter migration; K5 pin posture (optional extra, SDK-free mcp_client, human-only
pyproject); K6 AEGIS web:grant reuse. EXCLUDE (won't-do collision): retrieval_index/fusion/chunking
(Ph1), query_planner/query_rewrite-HyDE (Ph4), §08 row-closure, rag-master-plan revival, §15.2 Smart
Connections (dense embeddings = the removed mechanism), §02 wikilinks-replace-doc_anchors.

KEY OWNER DECISION (open): for K1, Path A adopt Graphify+tree-sitter vs Path B build ~150-line stdlib-`ast`
tool reusing call_graph.py/dag.py/shadow.py patterns. STUDY LEANS PATH B (AXON is single-language python +
markdown; graphify's multi-lang/media/viz are value AXON doesn't need, its costs — heavy dep, single-maintainer
~1.4 rel/day bus-factor, +2 ACTIVE tools, lossy-text MCP confidence — fight reduce-surface/determinism).

ARTIFACTS: 01-study.md (goal/ledger/§6 decision/§8 reruns/§10 open-questions, conf 9/10),
study/reconciliation-ledger.md (§01-23 + 8 probes). Full study data: tasks/w6q9c8h0p.output.
4 open questions surfaced for owner; NO autonomous execution taken (study-only authorization).

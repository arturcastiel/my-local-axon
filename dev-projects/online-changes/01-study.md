# 01 — Study: `aoxn-rag` (Agentic RAG retrieval-evaluation foundation)

## What it is
A self-contained, **additive** "RAG evaluation foundation" — it adds measurement/audit
capability for retrieval-augmented generation, with **no behavioral change** to existing AXON.
One commit (`55ab5dd`), 17 files, +2006/−0.

### What it adds
| Area | Files | What it does |
|------|-------|--------------|
| Tool | `tools/retrieval_eval.py` (228) | **Deterministic, model-free** retrieval metrics (precision/recall over relevant_ids, gold-span coverage, latency) from JSON fixtures. A falsifiable RAG baseline *before* dense retrieval / reranking / agentic query planning exist. |
| Tool | `tools/rag_maturity_audit.py` (499) | Standalone audit scoring AXON against a **70-point RAG maturity rubric** (retrieval quality, grounding, agentic-retrieval readiness). Separate from `axon-audit` (OS health). Scans existing tools/programs. |
| Tests | 3 files (~287) + 2 fixtures | `test_retrieval_eval.py`, `test_rag_maturity_audit.py`, `test_rag_master_plan_workflow.py` — ships its own coverage (Core Rule 13 satisfied). |
| Programs | `retrieval-eval.md`, `rag-maturity-audit.md`, `rag-master-plan.md` | AXON-program front-ends for the tools + a master-plan program. |
| Workflow | `workspace/workflows/rag-master-plan.yml` (97) | Fixed workflow orchestrating the RAG build-out plan. |
| Wiring | `tools/REGISTRY.json` (+12), `tools/metrics_manifest.json` (+14) | Registers the 2 tools + their metrics. |
| Docs | 4× `AXON-DOCS-RAG-*.md` + `AXON-DOCS-WORKFLOWS.md` | Development guide, master plan, maturity rubric, workflow catalogue entry. |

## Is it possible to incorporate? — YES
- **Clean merge**: main's 2 post-base commits touch none of `REGISTRY.json`, `metrics_manifest.json`,
  `AXON-DOCS-WORKFLOWS.md`. All other branch files are brand-new paths. No conflicts expected.
- **Imports resolve**: the new tools import `tools/_axon_paths.py`, which already exists on `main`.
- **No kernel-floor touch**: nothing under KERNEL/BOOT/core/compiler/DEVELOPER → no human-only blocker.
- **Self-tested**: ships 3 test files → can be verified by the crucible gate before anything irreversible.

## Pros
- Purely additive, self-contained, 0 deletions — minimal blast radius.
- Model-free + deterministic → falsifiable, no flaky external/network deps.
- Gives AXON a measurable retrieval baseline + maturity rubric — directly useful to the
  library-dev / shadow / dispatch retrieval work already in the tree.
- Wires in through the normal registry/manifest path → registry-drift + doc-counts gates apply.
- Ships tests; satisfies the "new neuron needs a test" rule (Core Rule 13).

## Cons / risks
- Surface area grows: +2 ACTIVE tools (131→133) + 3 programs. Registry consistency must hold
  (the registry-drift BLOCK check covers this).
- The master-plan / 70-point rubric is **aspirational scaffolding** — this is a *foundation*, not a
  working dense-retrieval system. Honestly scoped in the docstring; no overclaim merged.
- Possible conceptual overlap with existing eval tools (`axon_eval`, `dual_agent_eval`,
  `study_evals`). Scoped narrowly to retrieval, so acceptable, but worth a later de-dup pass.
- Mixed-agent provenance (co-author Copilot) — fine; it is the owner's commit.

## Recommendation
**Incorporate via a gated merge of `origin/aoxn-rag` into `main`.** Not the harmonize-into-PRs
treatment the `axon-workflow-harden` doctrine prescribes for large mixed-quality MRs — that bar is
for 30+ file MRs with process artifacts. This is a single additive, self-tested commit with no
kernel impact, so a crucible-gated whole-branch merge is the proportionate path.

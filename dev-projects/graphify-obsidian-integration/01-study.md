# Study — Graphify × Obsidian integration for AXON

Updated: 2026-06-09 · Phase 1 (study) · Method: 17-agent parallel research study
(9 ingest agents over 23 handoff sections + 8 live-repo grounding probes) + first-hand draft review
AXON confidence in this study: **9/10** · Handoff's own self-rated confidence: 0.95 (see §9 for why that number does not transfer to THIS repo)
Maturity: **L4 (implementation-ready)** for the deterministic spine — after the 2026-06-09 validation spike on THIS repo (determinism + blast-radius proven; see `study/spike-report.md`). P3 LLM path remains L3 (unmeasured by design).

> **One-line finding.** The handoff is a genuinely high-quality, 3-round, empirically-tested
> integration plan — but it was authored against a **different, older AXON checkout** and its
> **headline goal (chase RAG-maturity 40/70 → 66–70/70 via Graphify-backed dense retrieval) collides
> head-on with THIS repo's recorded 2026-06-09 won't-do decision.** Stripped of the RAG-chase frame,
> a **small, deterministic, design-aligned core survives** and is worth doing: a structural
> self-introspection graph over the Python tool layer, a fix to one live-degraded code-dev feature,
> and a one-way Obsidian *projection* (not a corpus migration). The sharpest strategic call for the
> owner: for that surviving core, a **~150-line stdlib-`ast` tool may beat adopting Graphify+tree-sitter** —
> see §6.

---

## 1. Goal (finalised)

**Evaluate the external Graphify × Obsidian handoff and define the AXON-aligned subset worth
building** — measured strictly by the owner's lens ("make AXON *better, more resilient, more
expandable*"), NOT by the handoff's "RAG 40→70" lens. Produce: a grounding ledger (handoff claims vs
this repo's reality), a reframed scope (in / out / adapt), a build-vs-adopt decision, re-validation
(rerun) triggers, and a risk ledger — as **planning artifacts only**. Owner resumes for plan/PR/execute.

This is deliberately a **reframe-and-triage** study, not a "seed the 60-PR DAG" study. The handoff's
own §L/§M concede the full plan is "tactically over-ambitious as a single project"; this repo's design
makes most of its load-bearing phases inadmissible. The value AXON adds here is *judgment*, not throughput.

## 2. What was studied (provenance)

- **Handoff package** `/mnt/c/projects/copilot-tests/axon-graphify-obsidian-handoff/` — README,
  MASTER-HANDOFF (§A–§M), CODE-DEV-PROMPT, all 23 `sections/`, and first-hand reads of the drafts:
  `draft-tools/graphify_bridge.py` (729 ll), `graphify_mcp.py` (454 ll), `draft-frontmatter/PILOT-REPORT.md`,
  `draft-vault/_examples/*`.
- **Live AXON repo** `/home/arturcastiel/projects/new-axon/axon` @ `9c221ca` — 8 independent grounding
  probes (RAG substrate, rag-master-plan removal, introspection-tool overlap, harness cap surface,
  MCP/AEGIS infra, frontmatter/synapse state, code-dev graph-awareness, tool-count/gates).
- **Authoring-checkout divergence:** the handoff targets `/mnt/c/projects/copilot-tests/axon` and
  describes "AXON v1.1.6 / 153 tools / 40/70 RAG / rag-master-plan exists." THIS repo is at a later
  point (VERSION 3.8.0; KERNEL still labelled v1.1.6 — an internal skew worth a cleanup), 157 tools,
  58/70 RAG, rag-master-plan deleted. **Treat every handoff number as suspect until re-grounded.**

## 3. Grounding ledger — handoff premise vs THIS repo (the heart of the study)

| # | Handoff premise | Live-repo reality | Verdict |
|---|---|---|---|
| 1 | RAG baseline **40/70**, drive to 66–70 | `rag-maturity-audit` → **58/70** ("Production-ready"); off by +18 | **refuted** |
| 2 | Close rows B1 (dense), B3 (RRF fusion), C1 (HyDE), C2 (multi-query) | These are the **exact rows `AXON-DOCS-RAG-DEVELOPMENT.md` records as "won't-do by design, not deferred"** — "chasing the rubric to 70/70 would degrade AXON" | **contradicts a recorded decision** |
| 3 | Graphify "drops in" for 7 future tools | 6 of 7 **absent by design**; only `rerank.py` exists (and is explicitly model-free TF-IDF, not graph-fed) | **refuted** |
| 4 | PR-GFY-503 grounds the `rag-master-plan` workflow | `rag-master-plan` (workflow+program+doc+test) **deleted 2026-06-09** (`01392b2`); audit score unchanged → it was "pure scaffolding" | **target removed** |
| 5 | "Graphify" is the integration substrate | **Zero** occurrences in working tree *or* full git history — genuinely net-new here | **confirmed new** |
| 6 | tree-sitter available | `import tree_sitter` → **ModuleNotFoundError**; heavy dep AXON has avoided | **stale** |
| 7 | Graphify replaces registry-drift/call_graph/deps/coherence-lint/doc-anchors/axon-audit | **None of the 6 parse Python AST** — they graph the *markdown program + registry* layer. Graphify cannot replace them. **But** nothing maps the *Python tool layer* → a real gap | **partially-true (mis-aimed)** |
| 8 | Agnostic harness layer extends cleanly with 4 new caps | Cap surface is real (6 fixed `host-cap-*` mechanism enums + conformance gate). But `graphify-mcp-url`/`out-path` are **config, not capability mechanisms** — belong in the `host-mem-dir` ad-hoc precedent, not the enum contract | **partially-true** |
| 9 | Route Graphify over localhost MCP under AEGIS | AEGIS `web: grant` is real, fail-closed, one policy line (**reusable as-is**). But `mcp_client.py` is **stdio-only (HTTP/SSE deferred v2)** → no-kernel path is *graphify-as-stdio-subprocess*; HTTP MCP needs new transport | **partially-true** |
| 10 | Lift code-dev (~90 progs) onto graph primitives | 90 code-dev programs confirmed. `shadow.py` is a hash-keyed findings mirror (no AST). **Live bug:** `code-dev-knowledge-impact.md` reads `symbols.exported` from shadow, which shadow **never emits** → blast-radius grep degrades to `\b()\b` (empty) | **partially-true (real narrow win)** |
| 11 | Frontmatter migration (PR-OBS-002) lifts synapse → Dataview | Synapse is a `# synapse:` **comment block** in ~169 programs; the parsers (`synapse_infer/validate`, `programs_registry`) are comment-anchored. Full migration = **196 files, ~39–50h, GUI-only payoff**, and replacing comments breaks parsers | **partially-true (over-scoped)** |
| 12 | Add `graphify_bridge.py` + `graphify_mcp.py` as tools | Any new ACTIVE tool must clear **R_NEW_NEEDS_TEST + crucible (pytest BLOCK) + R_NO_ORPHAN_TOOLS/liveness (must be *invoked*) + registry-drift + "## Guarded by" doc + NEURON-CONTRACT synapse block**; MCP exposure is a **read-only allowlist** that bans `--out/--root/--workspace/--file/--path` (a write/index tool **cannot** be MCP-exposed). AXON is **reducing** tool count | **gated / friction-heavy** |

**The pattern:** every place the handoff is *empirical and structural* (Graphify is a deterministic
AST graph; confidence tags on 100% of edges; pin posture; AEGIS fit) holds up. Every place it is
*aspirational about RAG maturity* is stale or reversed here.

## 4. Reconciliation — KEEP / ADAPT / EXCLUDE

### KEEP — design-aligned (deterministic structural substrate; not a RAG-chase)
- **K1 · Tool-layer structural self-introspection** *(highest resilience value — the genuine gap from probe #7).*
  A deterministic graph of `tools/*.py` import/def/call edges answers questions **no current tool can**:
  "which of 157 tools break if I change `_axon_paths.default_workspace`?", "which tools are structurally
  dead vs merely `status:OPTIONAL`?", "blast radius of editing a helper?". §09's god-nodes / why-index
  (#WHY/#HACK ledger) / centrality / community ideas attach here.
- **K2 · Fix the code-dev blast-radius bug** *(narrow, concrete, live).* Make `symbols.exported`/callers
  non-empty so `code-dev-knowledge-impact.md` actually works. Smallest unit of real value in the whole handoff.
- **K3 · Confidence-tag discipline (§12)** as a standalone R6-reinforcing principle: EXTRACTED → gate-eligible,
  INFERRED → CONFIDENCE(0.6)+log, AMBIGUOUS → QUERY(user). Applies to ANY structural substrate AXON builds.
- **K4 · Obsidian as a one-way *projection*, not a migration.** Build a `tools/obsidian_sync.py` exporter
  (~8–10h) that reads the canonical comment blocks → sidecar `.dataview.md`/`.base` files. Keeps one source
  of truth, zero corpus churn, no parser risk. Plus §21's "per dashboard, pick one" + a duplication lint;
  prefer **Bases** (deterministic frontmatter projection, core plugin) over Dataview.
- **K5 · Pin/resilience posture (§20)** *if* Graphify is ever adopted: OPTIONAL extra only, keep the
  SDK-free stdlib `mcp_client`, human-only `pyproject` merges, explicit pivot triggers.
- **K6 · AEGIS `web: grant` pattern** reused as-is for any future network fallback (fail-closed, one line).

### ADAPT — useful idea, wrong dose for this repo
- Frontmatter (probe #11) → **do NOT migrate 196 files**; use K4's exporter instead.
- "Replace the 6 introspection tools" (probe #7) → **layer, never replace**; they own the markdown/registry
  layer correctly. Optional: rename `call_graph.py` → `program_call_graph.py` (it graphs programs, not code).
- §17's 30 use-cases / §11's 60 PRs → triage to the K1–K4 subset; do not adopt wholesale (reduce-surface).

### EXCLUDE — collides with AXON's recorded design (the won't-do line)
- Phase 1 **retrieval_index (dense+graph)**, **retrieval_fusion (RRF)**, **chunking** for RAG closure.
- Phase 4 **query_planner (multi-hop)**, **query_rewrite (HyDE)**.
- §08 row-closure to 62–70; §11's "+24–36 → 64–76/70" metric; any revival of **rag-master-plan**.
- §15.2 **Smart Connections** (a dense local embedding index — the *exact* mechanism AXON removed).
- §02 replacing `doc_anchors` line-anchors with wikilinks (tears out a deterministic, agent-checkable invariant).

## 5. Scope

**In scope (candidate work for the owner to plan):** K1 (tool-layer AST graph), K2 (blast-radius fix),
K3 (confidence discipline), K4 (Obsidian projection + Bases + dup-lint), and the *decision* in §6.
**Out of scope (this project):** all EXCLUDE items; the full 8-phase/60-PR plan; any RAG-maturity uplift;
any `axon/` kernel edit (human-only floor); installing Graphify as a hard/core dependency.

## 6. The strategic decision the owner must make — **adopt Graphify, or build ~150 lines of stdlib `ast`?**

For the ONE genuinely-additive use (K1, a deterministic AST graph of `tools/*.py`), there are two paths:

- **Path A — adopt Graphify.** Pros: multi-language (28 grammars), media extraction, MCP server, Obsidian
  export, confidence tags, empirically proven on AXON's tools/ (§19: 2,995 nodes/6,410 edges/$0/99.3%
  EXTRACTED). Cons: net-new heavy dep (tree-sitter not installed), single-maintainer bus factor + ~1.4
  releases/day with no deprecation policy (§14/§20), MCP confidence is lossy text (§22), adds 2 ACTIVE tools
  against reduce-surface, and clears the full gate gauntlet (probe #12).
- **Path B — build in-house with Python's stdlib `ast`.** A ~150-line tool over `ast.parse` + the existing
  `call_graph.py`/`dag.py`/`shadow.py` patterns gives the *same* deterministic import/def/call graph for
  AXON's **pure-Python** corpus, with **zero** new heavy dependency, no bus-factor, no MCP surface, and edges
  trivially confidence-taggable (AST = EXTRACTED). Cons: Python-only (AXON *is* Python+markdown), no media,
  no out-of-the-box Obsidian graph view.

**Study recommendation: lean Path B for K1/K2.** AXON's corpus is single-language + markdown; Graphify's
differentiators (multi-language, media, graph-viz) are value AXON does not need, while its costs (heavy dep,
bus factor, surface) fight AXON's reduce-surface + determinism design. Reserve **Path A** only if a concrete
multi-language / media / Obsidian-graph need appears — and then as an OPTIONAL extra per §20. This is a
genuine fork; **owner decides** (see §10 open questions).

## 7. Methodology for the downstream phases (when owner resumes)

1. **Re-ground before planning.** Re-run every §3 number on THIS repo at the then-current HEAD — do not
   inherit handoff figures. The plan phase opens with a fresh `rag-maturity-audit` + tool-count + grep.
2. **Decision-first.** Resolve §6 (Path A vs B) *before* writing any PR spec — it changes the whole plan.
3. **Narrow tracks, test-first.** Each track = one PR with its test + `## Guarded by` doc + synapse block
   (Rule 13 / crucible / liveness). Smallest is K2 (blast-radius fix) — a good first PR to validate the loop.
4. **Audit-as-regression-guard, inverted.** After every change run `rag-maturity-audit`; the gate is that it
   **stays 58/70** (won't-do not crossed) — the *opposite* of the handoff's "delta must hit projection."
5. **Determinism gate.** For any graph tool: build twice → assert byte-identical output (the AXON-native
   version of Graphify's seed=42 guarantee).
6. **Human floor.** No `axon/` edit, no autonomous execution — owner drives plan→execute.

## 8. Need for reruns / re-validation triggers (owner asked this be set explicitly)

- **R1 · Empirical re-baseline on THIS repo.** The handoff's live graphify numbers (§19/§22) were on the
  *other* checkout. If Path A is chosen, re-run `graphify .` on **this** `tools/` **with `.graphifyignore`**
  (mandatory — the full-repo run was killed at 9 min) and re-measure nodes/edges/time/confidence-ratio here.
- **R2 · Upstream re-verify at integration time.** Graphify moves ~1.4 releases/day with breaking changes
  ~every 4 days. Re-pin to the then-current v8 head, re-run the determinism check (two builds identical), and
  re-capture the MCP schema (known drift: `query_graph` wants `question` not `query`; `get_neighbors` ignores
  `depth`; confidence survives MCP only as lossy bracketed text; exit code 0 lies — parse stdout; schema key
  is `links` not `edges`; free-text matches the wrong node — pass exact IDs).
- **R3 · Audit-stability rerun** after each merged change (must remain 58/70).
- **R4 · Second focused study** IF the owner scopes-in K1: a subsystem study of exactly which questions the
  graph must answer + the final Path A/B build-vs-adopt, before any code. (This study sets the frame; that
  one sets the build.)

## 9. Why the handoff's 0.95 does not transfer

The handoff's confidence ledger (0.75→0.85→0.95) measures *"is the integration buildable as written?"* —
and at that question it is honest and largely right. It does **not** measure *"should THIS AXON build it?"*
Its +0.10 round-3 gain was empirical proof that **Graphify runs**, not proof that the **goal fits**. On this
repo the goal (RAG 40→70) is refuted on every fact and contradicts a recorded decision, so the parts of the
0.95 that ride the RAG frame transfer at ~0. The parts that ride the *deterministic-substrate* facts
(§14/§19/§20/§12) transfer well — and are exactly the KEEP set.

## 10. Open questions for the owner (decision points — none guessed)

1. **§6 fork:** adopt Graphify (Path A) or build the stdlib-`ast` tool-layer grapher (Path B)? *(Study leans B.)*
2. **Scope confirm:** is the KEEP set (K1 tool-graph, K2 blast-radius fix, K3 confidence discipline,
   K4 Obsidian projection) the right cut — or narrower still (e.g. K2-only as a proof)?
3. **Obsidian at all?** K4 has real human value but zero agent value and is GUI-only. Worth the ~8–10h, or drop?
4. **Cleanup adjacency:** fix the stale "Development sequence Waves 2–6" table in `AXON-DOCS-RAG-DEVELOPMENT.md`
   (it still says "planned", contradicting the won't-do decision 80 lines above) + the v1.1.6/3.8.0 version skew?
   These are real, found during grounding, but outside this project's frame unless you want them folded in.

## 11. Confidence & residual

**AXON confidence in this study: 9/10.** Grounded in 8 independent live-repo probes (all citing real
paths/commands/line numbers) + first-hand draft review + the verbatim won't-do decision. Residual 0.1:
(a) the Path A/B build-cost numbers are estimates until a spike; (b) one probe (frontmatter) was re-run after a
session-limit failure — its findings are consistent with the first-hand PILOT-REPORT read, so confidence holds;
(c) some handoff §17 use-cases were triaged at summary depth, not exhaustively — acceptable, they are EXCLUDE/ADAPT.

## 12. Owner decisions (study debate, 2026-06-09)

> These directives SUPERSEDE the study's earlier provisional leans (§1 reframe-minimal, §4 altitude,
> §6 Path-B). The reasoning in §1–§11 stands as the record; the calls below are the committed outcome.
> The determinism guardrails from §4/§6/§7 remain in force regardless.

1. **Scope = Full KEEP set (K1–K4)** — not the minimal cut.
2. **Tool = HYBRID (revised 2026-06-09 after the adversarial worth-it panel; owner delegated the call).**
   stdlib `ast` is AXON's OWN deterministic, gate-eligible graph (P1/P2) — zero dependency, zero bus-factor,
   CPython-stable. **Graphify is a pinned OPTIONAL extra** used only where its multi-language breadth earns its
   keep — **P-CD target repos** — and optionally to render the human Obsidian view of AXON-self (never gate-driving).
   Supersedes the earlier "adopt Graphify everywhere (Path A)" decision: the panel surfaced that `graphifyy` is a
   single-maintainer *competitor agent product* (PyPI blurb), and the study's §6 proved stdlib gives the identical
   graph for AXON's single-language corpus. Rationale + scores: `study/worth-it-evaluation.md`. Net: AXON's
   load-bearing self-knowledge has no external dependency; the fragile dep is quarantined to the one place it adds value, optionally.
3. **Destination = D2** — a whole-repo, organized, clustered, navigable AXON with an Obsidian view —
   reached via the **D1 → D2 sequence**: deterministic code spine first, organizing/visual layer second.
4. **Governing partition (owner's principle ≡ AXON R6 re-derived):** deterministic graph for anything
   that drives a decision/gate; LLM-enriched prose-semantics is an **opt-in ADVISORY overlay, never on a gate.**
   - **Deterministic / gate-eligible (the spine, $0, no key):** AST code graph; blast-radius/impact (K2);
     god-nodes/dead-code/centrality; **Leiden clustering**; **the Obsidian visual map** (renders graph.json);
     structural markdown (EXEC/TOOL/READ refs, frontmatter, wikilinks) via AXON's existing deterministic
     tools, **merged + linked** at the program↔tool boundary (Q3 → option **a**).
   - **Advisory (INFERRED·AMBIGUOUS):** LLM-extracted prose-semantics from markdown/docstrings/PDF;
     needs API key + network + AEGIS grant + token cost. CONFIDENCE-tagged, QUERY(user) at most, never a gate.
6. **All three phases (P1+P2+P3) are IN SCOPE from the start** (owner directive 2026-06-09 — supersedes the
   debate's Q4 "defer P3" lean). P3 remains a *separate, gated, advisory* phase built **after** P1–P2; it
   enriches but is not required for D2's organize-better outcome. Committing to P3 commits the project to:
   an AEGIS `web`/`llm` grant, an API-key path (gitignored local), a token budget, and the SSRF/HTTP caveats
   from §22 — all contained to the advisory layer, none touching a gate.
5. **Non-negotiable guardrails (carry into plan/PR):** pin `graphifyy>=0.8.36,<0.9.0` as an OPTIONAL extra ·
   `.graphifyignore` mandatory · fail-degrade not fail-fast · §20 upstream-watch + pivot triggers ·
   **won't-do line holds** (this organizes/introspects AXON; it does NOT chase RAG maturity) ·
   no `axon/` kernel edits without owner dev-mode · no autonomous execution (study-only; owner drives the build).

## 13. End-state capabilities (what AXON can do after P1+P2+P3 — the acceptance picture)

Today AXON can *read* itself (markdown/registry, via scattered CLI tools) but is blind to its own *code*
structure and has no map. After the phases:

**A · Self-code understanding (P1, deterministic):** on-demand blast-radius ("edit `_axon_paths.X` → which
of 157 tools break"), dead-function detection (feeds reduce-surface), god-node/fragility hotspots; fixes K2
and gives `axon-audit` a structural dimension.
**B · Organized + visual (P2, deterministic):** open the repo as an Obsidian vault and SEE it; Leiden domain
clusters that validate/challenge the `synapse` taxonomy; Layer 1/2/3 violation detection; unified
"which programs use tool X / which tools does program Y call".
**C · code-dev on user repos (now a FIRST-CLASS track, `P-CD`) — biggest practical win:** code-dev builds the
TARGET-repo graph ONCE at study and reuses it through every phase (study→plan→impact→review→test + workflows).
Designed surface-by-surface (6 surfaces, line-cited, fail-degrade, confidence-tiered) in
`study/code-dev-integration-design.md`; demonstrated live (mapped a real repo: explain/query at study,
`affected` for PR blast-radius). Notably it REPLACES the live-broken impact/blast-radius feature (2 defects
today) and FILLS the deprecated plan semantic-search slot. Multi-language → this is why Graphify beats the
stdlib option, and why the owner chose Path A.
**D · Human/exploratory (P3, advisory):** semantic "which doc explains X" navigation, #WHY/#HACK why-index,
graph-guided onboarding tour.

**Deliberately NOT:** better RAG/retrieval (won't-do); structural≠semantic (meaning is P3's advisory layer
only); Obsidian is human-only (no runtime dep); free-text is fuzzy (agent uses exact node IDs).
One-line: *today AXON reads itself; after these phases it can see, map, and reason about its own structure —
and bring graph-grounded reasoning to every codebase code-dev touches.*

---
*Phase 1 (study) complete. Owner takes over for Phase 2 (plan). No autonomous execution — per project authorization.*
*Companion: `study/reconciliation-ledger.md` (per-section + per-probe verdicts).*

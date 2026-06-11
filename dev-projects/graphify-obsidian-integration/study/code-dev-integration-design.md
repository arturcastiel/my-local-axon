# code-dev × Graphify — integration design (the `P-CD` track)

> Answers: "does this cover graphifying a repo *during study* to study better, and *helping down in the PRs*?"
> **Yes** — that is the spine: **build the target-repo graph ONCE at study, persist it per-project, reuse it
> through every later phase.** Source: 6-surface design workflow (2026-06-09, all line-cited against the live
> programs) + a live demo (mapped a real repo end-to-end). Graph lives at
> `my-axon/dev-projects/<slug>/graph/graph.json`; built with `graphify build`, kept fresh with `graphify update`.
> All surfaces: **fail-degrade** (graph absent → today's grep/shadow path, never fail-fast), **advisory**
> (AXON's phase DAG stays source of truth), **confidence-tiered** (EXTRACTED→gate-eligible · INFERRED→CONFIDENCE(0.6) · AMBIGUOUS→QUERY).

## The flow (study → PRs, one graph)
```
STUDY  graphify build --repo {codebase} --out {proj}/graph/graph.json   ← once, at code-dev-study line 96
       explain / neighbors / query  → understand the repo without grep
  │    (persisted per-project; graphify update --since {git-commit} on resume)
  ▼
PLAN   neighbors/affected → spanned modules ;  path between PR anchors → code-derived depends_on → dag.py
IMPACT affected --reverse → real blast-radius (fixes the live bug)
REVIEW affected --depth 3 → caller cone BEFORE build ; neighbors --in → surprising cross-module edges
TEST   affected --filter kind=test → real call-based coverage + the untested-node gap set
```

## Surface-by-surface

| Surface | Today | With graph | Mode | Effort |
|---|---|---|---|---|
| **study + shadow** | one file at a time; manual path guess; grep to learn callers | build once → `neighbors`/`explain` give symbols+callers before any source read; read only the bodies the graph flags; node-ids cached in shadow | augments | M |
| **plan + DAG** | the goal→files semantic-search is **deprecated (PR-142) — empty slot**; PR `scope` + `depends_on` are pure LLM guesses | `neighbors`/`affected` → real spanned modules; `path` between PR anchors → code-derived `depends_on` merged into `dag.py build-from-prs`; communities → phase grouping | augments | M |
| **impact / blast-radius** | **live-broken, 2 defects:** `symbols.exported` is never emitted by shadow → `JOIN(∅)` → grep `\b()\b` → matches **unrelated files as fake callers** | `query --defines` resolves real exports; `affected --reverse --depth 2` → precise transitive callers, depth-attributed | **replaces** | M |
| **review** | review set = literally-changed files only; transitive callers invisible until a P7 build failure | `affected --depth 3` → caller cone *before* build (auto-pulled into study set); `neighbors --in` → surprising cross-module edges flagged | augments | M |
| **test-map** | **filename heuristic** (`find -name '*{base}*'`) — misses cross-name coverage, false-positives same-named files | `affected --filter kind=test` → real call/import coverage; empty set = precise untested-node worklist → suggest-tests targets | augments | M |
| **workflows** | canonical `code-dev.canonical.yml` starts at `s1 study`; no repo map step; adaptive orchestrator can't pick a graph query | fixed `s0 graphify-map` pre-step before study (covers `multiple-code-dev` for free — it's the sub-workflow); a `graphify-query` adaptive synapse with a `graphify_bonus` signal (mirrors `shadow_bonus`); honors `workflow_run.advance` determinism + `R_STATE_SURFACED` | augments | M |

## Key engineering details (from the live demo + design)
- **Node-ID resolution is the bridge's job.** Free-text matches the wrong node (demo: `default_workspace()` →
  TWO ids, `graphify_bridge_default_workspace` + `graphify_mcp_default_workspace`). The bridge resolves
  labels → exact IDs and disambiguates — this is why **P1 ships `graphify_bridge.py`** before any code-dev wiring.
- **The impact fix is valuable even with no graph:** derive a non-empty symbol set first (`git grep -oE 'def|class …'`)
  so the alternation is never `\b()\b` — kills the false-positive bug independently of Graphify.
- **Reuse, don't replace:** `shadow.py` (extend to cache node-ids), `dag.py` (feed it code-derived edges),
  `project_graph.py` (AXON's own project tree — *different* graph, untouched). No parallel scanners.
- **Determinism + state discipline:** `graphify-map` is a live phase synapse → must narrate the
  `R_STATE_SURFACED` block ("code-dev · PHASE 00—graphify-map · built N nodes · → next: study").

## Live demo evidence (2026-06-09, draft-tools as the target repo)
- STUDY: `graphify update .` → 156 nodes / 374 edges / 11 communities; `explain "graphify_bridge"` → degree 52,
  contains `neighbors()`/`pr_impact()`/`_load_graph()`…; `query "how does the bridge build a graph"` → BFS, 27 nodes.
- PR-IMPACT: `affected "_run_graphify"` → `build(), explain(), query(), cmd_build(), cmd_explain(), cmd_query()`
  — the exact functions a PR changing it would break. The blast-radius, working live.

## Placement
The `P-CD` track is **additive to P1–P2** (it consumes the same deterministic graph, just pointed at the
*target* repo instead of AXON's own `tools/`). Build order: P1 bridge + deterministic graph → **P-CD** wires
the 6 surfaces (start with the impact fix — smallest, fixes a live bug). All 6 surfaces are effort **M**,
fail-degrade, and reuse existing tools — consistent with reduce-surface.

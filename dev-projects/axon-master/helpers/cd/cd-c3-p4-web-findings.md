# CD·C3·P4 — web findings (caching + observability)

> External patterns relevant to cycle-3 caching, compilation, and measurement strategy.

## 1. Prompt-caching & static-prefix design
- **Anthropic prompt caching:** beta cache up to 90% off cached input tokens; cache-friendly structures favor **static prefix + variable suffix**.
- **OpenAI prompt caching:** similar, prefix-keyed.
- **Take:** every code-dev program load should put its static parts (HELP, IDENTITY LOCK, GUARD) at the top, variables at the bottom. The current shape mostly does this — but `## OUTPUT` mixed with `## LOAD CONTEXT` breaks the pattern in some files.

## 2. mtime-based caches in tooling
- **`make`** — mtime targets; canonical.
- **`bazel` / `buck`** — content-hash (more robust than mtime).
- **rg / fzf indexes** — mtime + size + first-N bytes for cache key.
- **Take:** code-dev caches keyed on (path, mtime) match `make`-style. Upgrading to content-hash is shadow's existing model — natural to reuse.

## 3. LRU cache patterns
- **`functools.lru_cache` (Python)** — most cited.
- **`cachetools.LRUCache`** — bounded, with TTL.
- **Take:** `W:code-dev-cache-*` keys are bounded by `W:` budget; LRU eviction must be added to avoid the keyspace exploding on long-running sessions.

## 4. Compilation losses (negative compression)
- **Webpack / Vite "bundle size analyzer"** — flags artifacts bigger than sources.
- **DSPy compile pipelines** — usually emit token-count metric; failed-compression flag is a recurring need.
- **Take:** AXON's compiler should record compression % per file in `benchmark-log.md` (already does for some). Add a "regression alarm" when ratio < 5%.

## 5. Streaming reads / tail-only patterns
- **`tail -F`** — classic.
- **`fs.createReadStream(..., {start, end})`** (Node.js) — byte-range reads.
- **`mmap` for log tailing**.
- **Take:** Python equivalent (`os.SEEK_END` + back-walk) is fine; no need for fancy APIs. Last 8 KB of `04-log.md` covers most resume use cases.

## 6. Embedding / bm25 indexes
- **`bm25s`** — pure-python BM25, MIT licensed, very fast (~10 M docs/s ingest claimed).
- **`rank_bm25`** — alternative, older but stable.
- **`hnswlib`** — for embedding ANN search if we go that way.
- **Take:** start with `bm25s` for shadow ranking; no model dep, no latency tail.

## 7. Observability conventions
- **OpenTelemetry** — `spans + attributes`. Heavy for code-dev; not needed.
- **Prometheus-style counters** — append-only counters in a flat file.
- **structlog / jsonl logs** — line-delimited JSON.
- **Take:** `_actions.log` and `_events.log` are line-delimited; converting to jsonl would let `pattern` and `igap` tools index them directly. Small migration cost.

## 8. Test-impact analysis (TIA)
- **Microsoft TIA / Google TAP** — change → affected tests via call graph.
- **`pytest-testmon`** — track which tests touch which lines; re-run only affected.
- **`bazel test`** — change-driven test selection.
- **Take:** `code-dev test-map` (G-CD-C4/C5) overlaps with TIA. A `pytest-testmon`-style cache on top of shadow would close the loop.

## 9. Lazy program loading
- **Python `lazy_import`** — defer module load until first attribute.
- **`webpack` code-splitting** — load route bundles on demand.
- **Take:** the AXON compiler could emit `# loads-on-demand: section` markers; the runtime loader skips the section until a sub-EXEC needs it. Helps for monolith files like `code-dev-pr-review`.

## 10. Diff-aware coverage
- **`diff-cover`** (Python) — report coverage on changed lines only.
- **GitHub Codecov diff view** — UI surfacing coverage delta.
- **Take:** simple Python `diff-cover` integration into `code-dev-coverage-delta` (D-C8) gives us coverage-aware Gate 8.

## 11. Stacked-PR auto-rebase tooling
- **`gh stack`** (GitHub gh extension) — light-touch stack mgmt.
- **`git absorb`** — auto-fixup commits into the right ancestor.
- **Take:** `git absorb` is a HUMAN tool but we can hint at it in `code-dev pr-stack restack` output: "consider: git absorb && gt restack".

## 12. Compaction / context-window tactics
- **Anthropic context-window best practices** — keep static at top, mutable at bottom; use anchor IDs (`<doc-1>`, `<doc-2>`) for retrieval.
- **Retrieval-augmented patterns (RAG)** — chunk + retrieve.
- **Take:** code-dev's shadow already implements a coarse RAG. Adding bm25 ranking + retrieval is the next step.

## Headline takeaways for cycle 4 synthesis
1. **Quarantine + recompile** the negative-compression file is the single highest-leverage move (T-A1 + T-A3).
2. **Static-prefix discipline** in code-dev programs maximizes Anthropic/OpenAI cache hits — verify on a per-program basis.
3. **bm25s for shadow** is cheap, model-free, and unlocks better `plan` / `impact` ranking.
4. **JSONL conversion** of `_actions.log` and `_events.log` is small effort with broad downstream value (pattern, igap, audit all benefit).
5. **Coverage-delta + test-impact** (D-C4/C5/C8) follows from existing prior art — no novel research required.

→ final synthesis combining C1+C2+C3 tops in `cd-c4-p1-synthesis.md` and `cd-c4-p3-improvements.md`.

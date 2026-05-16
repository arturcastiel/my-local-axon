# C3·P1 — AXON Token Hotspots & Economy Analysis

> Source: AXON repo at `/mnt/c/projects/axon`, measured 2026-05-16. Token estimate convention: `chars / 4` (cl100k_base proxy). Where the file has its own `Tokens: src=… compiled=…` header (compile-write output), those numbers are used and noted. C1 already established prompt caching, symbolic compression, and smart dispatch as key levers; this study locates where the actual waste lives.

---

## 1. BOOT BASELINE (chars / lines / estimated tokens per session)

Files loaded at every session boot, plus the `axon boot` JSON output:

| File | Lines | Chars | Est. tokens (chars/4) |
|---|---|---|---|
| `axon/KERNEL-SLIM.md`            | 712  | 44,914 | **~11,229** |
| `workspace/harness/claude-code.md` | 15  |    473 |    ~118 |
| `my-axon/MYAXON.md`              | 44   |  1,511 |    ~378 |
| `workspace/programs/menu.md`     | 492  | 26,148 |  ~6,537 |
| `python3 axon.py boot` (stdout JSON) | 109 | 2,170 |   ~543 |
| **Boot baseline subtotal**       | **1,372** | **75,216** | **~18,805** |

**Observations**:
- KERNEL-SLIM.md alone is ~60% of boot cost (~11,229 of ~18,805 tokens).
- `menu.md` source is 26,148 chars but its compiled twin (`menu.cmp.md`) is 26,320 chars — *bigger* than source. Compression delivered nothing for the single largest non-kernel boot file.
- The boot JSON itself is tiny (~543 tokens) and well-formed; it is not a hotspot.
- Harness contracts (claude-code/copilot/generic) are all sub-500 chars — already cheap.
- `MYAXON.md` is small but read on every session — fine.
- Real boot cost depends on whether KERNEL-SLIM is sent uncached every turn or once-per-conversation. With **prompt caching**, the kernel becomes a one-time cost; without it, ~11k tokens/turn.

**Per-turn baseline if no caching**: ~18,805 tokens × N turns/session.
**Per-turn baseline with full prompt caching**: ~543 tokens (boot JSON) + delta.

---

## 2. COMPILED PROGRAM INVENTORY (top 10 largest)

73 files in `workspace/programs/compiled/`, total **290,609 chars** (~72,652 tokens). Top 10 by file size:

| # | File | Lines | Chars | Header tokens (cmp) | Header ratio |
|---|---|---|---|---|---|
| 1 | `menu.cmp.md`              | 500 | 26,320 | 6,964 | **0.0%** |
| 2 | `code-dev-pr-review.cmp.md`| 495 | 23,056 | 5,821 | **0.0%** |
| 3 | `code-dev-study.cmp.md`    | 269 | 12,088 | 3,019 | **0.0%** |
| 4 | `code-dev-shadow.cmp.md`   | 275 | 11,623 | 9,794 | 6.4% |
| 5 | `code-dev-audit.cmp.md`    | 248 |  9,987 | 8,933 | 8.4% |
| 6 | `code-dev-pr.cmp.md`       | 258 |  9,119 | 2,352 | **0.0%** |
| 7 | `library-dev-ingest.cmp.md`| 246 |  8,712 | 1,932 | 3.4% |
| 8 | `glossary.cmp.md`          | 163 |  8,623 | 1,769 | **0.0%** |
| 9 | `code-dev-log.cmp.md`      | 197 |  7,253 |   578 | **0.0%** |
|10 | `axon-compare.cmp.md`      | 146 |  7,315 |   ~7,300 | (no source header — see §3) |

**Headline finding**: Half of the top-10 largest compiled files **do not actually compress** (`ratio=0.0%`). The compiler emitted a hybrid file but the OPTIMIZE phase (per `COMPILER.md` §3) returned the source body unchanged. So those bytes sit on disk twice — once as `.md`, once as `.cmp.md` — and dispatching to the compiled twin saves nothing.

**Of 73 compiled files, 24 (33%) have a 0.0% ratio.** Three more lack a token header.

---

## 3. SOURCE vs COMPILED — 10-sample compression table

Cross-checked against COMPILER.md targets (`>40%` high · `15-40%` moderate · `<15%` marginal):

| Program | Src tokens | Cmp tokens | Saved | Ratio | Tier |
|---|---|---|---|---|---|
| `menu`                | 6,964 | 6,964 |     0 |  0.0% | **NO COMPRESSION** |
| `code-dev-pr-review`  | 5,821 | 5,821 |     0 |  0.0% | **NO COMPRESSION** |
| `code-dev-study`      | 3,019 | 3,019 |     0 |  0.0% | **NO COMPRESSION** |
| `code-dev-shadow`     |10,468 | 9,794 |   674 |  6.4% | marginal |
| `code-dev-audit`      | 9,753 | 8,933 |   820 |  8.4% | marginal |
| `code-dev-log`        | 7,921 | 7,064 |   857 | 10.8% | marginal |
| `library-dev-explain` | 7,548 | 6,721 |   827 | 11.0% | marginal |
| `code-dev-init`       | 2,310 | 1,126 | 1,184 | **51.3%** | high |
| `code-dev-explain`    | 1,113 |   862 |   251 | 22.6% | moderate |
| `discover`            | 1,090 |   900 |   190 | 17.4% | moderate |

**Best compression observed across the corpus**:
- `~70.6%` — one small program at 2,078 → 610 tokens
- `~70.2%` — 722 → 215 tokens
- `~63.8%` — 1,616 → 585 tokens
- `~62.7%` — 448 → 167 tokens
- `~51.3%` — `code-dev-init` (one of the few mid-size wins)

**Distribution across 70 files with ratio headers**:
- **24 files at exactly 0.0%** — no compression delivered (33% of compiled corpus)
- ~3 files at <15% (marginal)
- ~25 files at 15-40% (moderate)
- ~18 files at ≥40% (high)

**Cross-check vs COMPILER.md target**: documented benchmarking table requires every compile to record `src/cmp/ratio/warnings`. Empirically the compiler *does* emit `ratio=0.0%` rather than failing — meaning a third of compiled assets exist without justification.

---

## 4. DISPATCH PATH ANALYSIS (`tools/dispatch.py` + `smart-dispatch.md`)

**How AXON decides compiled vs source**:
1. `dispatch match --query <user-prompt>` loads `workspace/memory/longterm/dispatch-index.json`.
2. Builds a corpus of `"<program-name> <description>"` strings, runs **TF-IDF cosine similarity** (sklearn) of query against all corpus entries.
3. Compares best score against `dispatch-confidence` (default **0.65**) from `workspace/preferences/smart-dispatch.md`.
4. Emits either `dispatch → compiled .cmp.md path` or `fallback → agent`.

**Threshold + override** (`smart-dispatch.md`):
```
dispatch-confidence: 0.65        # min cosine sim
dispatch-fallback:   agent       # what to do below threshold
prefer-compiled:     true        # bypass threshold if any compiled match exists
auto-compile:        false
```
The `prefer-compiled: true` shortcut (line 14) means **any non-zero TF-IDF match routes to compiled** — the 0.65 threshold is bypassed in practice. So a wrong dispatch that picks the most lexically-similar compiled program will execute it anyway.

**Cost on dispatch miss**:
- sklearn TF-IDF is recomputed **every call** — `dispatch.py:80` does `vec.fit_transform(docs)` inline. No caching of the vectorizer or the corpus matrix. With ~70 compiled programs the index is small, so each match is ~10-50 ms, but the cost grows linearly.
- On miss → `fallback: agent` → kernel proceeds to interpret source program (~3× more tokens than compiled per `usage.py` `COMPILED_TOKEN_RATIO = 0.3`).
- No persistent cache of `(query → program)` decisions; every reborn TF-IDF round-trip pays the same cost.
- `dispatch-feedback.jsonl` and `usage-log.jsonl` **do not exist yet** in this workspace (verified by ls), so the auto-tune loop has zero data to learn from. The system ships with a feedback adjuster (lines 290-317) that requires both `L:dispatch-auto-tune ≡ true` and the legacy pref — which means without the KV flag, the system never re-tunes.

**No first-run safeguard**: when the index is empty, dispatch returns `{"action": "fallback", "reason": "dispatch index is empty"}`. Cold-start agents thus default to source interpretation — exactly the expensive path.

---

## 5. SEMANTIC-SEARCH CACHING ANALYSIS (`tools/semantic_search.py`)

**Caching story**:
- Uses **ChromaDB persistent client** at `workspace/memory/semantic-index/` (verified: 692 KB on disk; one chroma.sqlite3 + 2 collection dirs).
- Embeddings: `chromadb.utils.embedding_functions.DefaultEmbeddingFunction` (sentence-transformers `all-MiniLM-L6-v2` by default).
- Index reused across runs: `client.get_or_create_collection(name=...)` keyed on the `--path` arg (slashes → underscores).

**What gets cached**: every `.md` file in the target folder (skipped if filename starts with `_`). Re-index triggered only when `--reindex` is passed or `collection.count() == 0`. **No file-mtime check** — if a cached `.md` is edited, the cached embedding goes stale silently. That is a correctness hazard, not a token hotspot.

**What is NOT cached**: the query embedding — every `--query` re-encodes the query string. Cheap (~10ms) but accumulates if called per-turn.

**Embedding index size**: 692 KB total for the current `workspace/memory/` corpus. Trivial. Only grows with the corpus.

**Token impact**: semantic-search returns up to 5 hits, each with a 300-char excerpt. Default call returns ~1,500 chars (~375 tokens) — modest. The risk is repeated calls per turn (e.g., during `code-dev-study`).

---

## 6. PATTERN VECTORIZER CACHING ANALYSIS (`tools/pattern.py`)

**Re-vectorize frequency**: every invocation does `vec = TfidfVectorizer(...)` + `vec.fit_transform(texts)` from scratch (line 89-90). No persistence, no cache.

**Cost**: O(N) over `prompt-log.jsonl` entries inside the window. With a 30-day window and (say) 500 prompts the vectorizer + KMeans takes 100-300 ms. Token impact is zero (output JSON only); CPU/latency impact is real and grows with workspace age.

**No cache at all**:
- No `(window-end-day → corpus-matrix)` cache.
- No incremental updates — every call re-reads `prompt-log.jsonl`, re-tokenizes, re-fits.
- Confirmed in c1-p1-tools-map: "pattern — TF-IDF re-vectorizes every call" listed as Tier-1 caching candidate.

**Currently a latency hotspot, not a token hotspot.** Becomes a token hotspot indirectly: slow tools mean the agent retries or surfaces extra context.

---

## 7. TOKENIZER COST ANALYSIS (`tools/tokenizer.py`, `tools/context.py`, `tools/_axon_lib.py`)

**Three tokenization paths, three costs**:

1. **`tools/tokenizer.py`** — hard requires `tiktoken`. Exits with `{"error": "tiktoken not installed"}` if absent. Per-call cost: ~30 ms cold (tiktoken loads ~10 MB encoding table on first import) + ~1 ms per kchars warm.
2. **`tools/context.py`** — soft fallback: tiktoken if available, else `len(text.split()) * 1.33` (rough word-count). Result: a context tool can lie ~15-20% on token estimates when tiktoken is missing.
3. **`tools/_axon_lib.py:tokenize`** (in-process lib) — soft fallback to `len(text) // 4` (chars/4). PR-019 lifts this hot path inline so per-call subprocess overhead (~50 ms) goes away for the orchestrator.

**Where it's cheap**: in-process via `_axon_lib.tokenize` (no subprocess, no tiktoken cold-start).
**Where it's expensive**:
- Subprocess invocations of `tools/tokenizer.py` for every token estimate during compile (each spawn = ~80-150 ms python cold-start + tiktoken init).
- Boot path: `axon.py` invokes Python per tool subprocess, paying cold-start every time. Identified in c1-p3-improvements as F-08 (daemon-mode candidate).

**Actual model token boundary**: `cl100k_base` is the GPT-4 tokenizer. Claude uses a different BPE — counts will be 5-15% off. Not catastrophic for budgeting, but means the `compression-ratio` numbers in compiled headers are estimates of the wrong tokenizer.

---

## 8. TOOL OUTPUT VERBOSITY AUDIT

**Quiet/verbose flags**: grepping `tools/dispatch.py tools/usage.py tools/health.py tools/log.py tools/memory.py` for `--quiet`, `--verbose`, `--json`, `silent` returns:
- **Zero `--quiet` flags**.
- **Zero `--verbose` flags**.
- One `--json` flag in `health.py` (line 166, internal).
- "silently" appears once in `dispatch.py` (skip-on-no-recent-dispatch path), not a flag.

**Default verbosity**: every tool prints a JSON object via `print(json.dumps(...))`. Hot-path examples:
- `clock.py` returns 6 fields (timestamp, iso, date, time, unix, source) ≈ 130 chars.
- `calculator.py` returns 4 fields (result, expression, variables, type) ≈ 80-200 chars.
- `dispatch.py match` returns up to 7 fields including `top_matches[:3]` (3 program/confidence pairs) ≈ 300-500 chars.
- `usage.py top` returns `{window, kind, total, unique, top: [{name,count} ×10]}` ≈ 400-800 chars.
- `compile_optimizer report` (json mode): full per-program rows, can exceed 5 KB.

**No filter pipeline**: tool stdout is fed straight into the agent's context. There is no `workspace/preferences/tools/<name>.md` filter (referenced as "open question #2" in c1-p1-tools-map). Identified as T-09 in c1-p3 backlog.

**Per-call envelope tax** (`_axon_response.py`): every tool call adds canonical envelope keys. Small but multiplied across 600+ program-side calls/session per c1-p1.

**Verdict**: tool outputs are uniformly low-verbose by design (JSON, no narration), but **zero output filtering exists**. Agents see every field every call. With high-frequency tools (clock = 88+ calls in workspace) this adds up.

---

## 9. HOT-CALL OVERHEAD ESTIMATION (top-3 per c1-p1-tools-map)

Per-call overhead = python cold-start (~80-150 ms via subprocess) + JSON parse + tool-specific work + stdout JSON envelope. Token cost is the JSON body the agent ingests as tool result.

| Tool | Calls (workspace grep) | Per-call output | Per-call tokens (chars/4) | Session-est tokens |
|---|---|---|---|---|
| `shadow` (109 calls) | content-addressed source mirror; `check`/`hash`/`init`/`append`/`list` actions | 80-300 chars depending on action; `list` can spike to 5+ KB | ~20-75 tokens (80%) ; ~500-1,500 (list/stats spikes) | ~3,000-8,000 |
| `clock` (88+ calls)  | always returns 6 fields | ~130 chars → ~33 tokens | ~2,900 |
| `calculator` (28 calls) | result + echo of expression + vars + type | ~80-200 chars → ~25 tokens | ~700 |

Cold-start cost is **per subprocess** (~80-150 ms each) — `clock` alone burns ~7-13 seconds of wall time per session in subprocess spawn overhead. PR-019 (`_axon_lib.py`) addresses the *highest-frequency* internal tools (`drift_gate`, `audit_record`, `tokenize`, `kv_get/set`, `events_emit`, `usage_record`) by lifting them in-process; `clock`, `calculator`, `shadow` are still subprocess.

**Bigger token cost than the above**: `shadow append`/`shadow list` returns the whole findings file or the directory listing, which can swing per call into multi-KB territory. The 109 `shadow` calls likely dominate hot-path token spend — not because each call is heavy, but because they collectively read/write findings.md files measured in KB.

---

## 10. TOP 10 TOKEN WASTE SOURCES (ranked, with rough per-session estimates)

Estimates assume a moderate session: ~10 tool calls × 30 turns × 1 boot.

| Rank | Source | Mechanism | Est. waste/session |
|---|---|---|---|
| **1** | **KERNEL-SLIM.md sent uncached** | 44,914 chars × every turn if prompt caching is off. Caching makes this ~free; without it, ~11,229 tokens × N turns. | **~110,000 tok @ 10 turns w/o cache, ~0 with cache** |
| **2** | **menu.cmp.md (0% compression)** | The largest single program file (26,320 chars) is a verbatim copy of source. Compiled dispatch saves nothing here. Loaded on every menu render (post-boot, post-reload) per Core Rule 12. | **~6,500 tok per render × N renders** |
| **3** | **24 of 73 compiled files at 0% compression** (33%) | When dispatched they cost the *same* as source. `prefer-compiled: true` always picks the compiled twin so this is the path actually taken. Aggregate src=~80k tok ≈ aggregate cmp=~80k tok across these 24. | **~5,000-15,000 tok/session** depending on which programs run |
| **4** | **No (query → program) dispatch cache** | Every match recomputes TF-IDF, every match writes a JSON envelope with `top_matches[:3]`. Repeated similar queries pay full cost each time. | ~500-2,000 tok/session in repeated dispatch envelopes; ~100-300 ms latency × N |
| **5** | **`prefer-compiled: true` overrides 0.65 threshold** | Bypasses confidence gate. Wrong-program dispatch executes a misfit compiled program → re-dispatch + agent fallback → 2× cost. | Variable; estimate ~3,000 tok/session if 1-2 wrong picks |
| **6** | **No tool output filtering** | Every tool returns JSON with 4-7 fields, fed verbatim to context. `clock` at 88 calls = ~2,900 unfiltered tokens/session. `shadow list/stats` can spike to multi-KB returns. | ~3,000-8,000 tok/session |
| **7** | **`code-dev-pr-review.cmp.md` (5,821 tokens, ratio 0.0%)** | Largest single workflow loaded; not compressed. C1-p3 already flagged for split (T-08). | ~5,800 tok per use |
| **8** | **`workspace/programs/REGISTRY.json` (29,244 chars)** | Loaded by registry tool when programs are listed/searched. Bigger than tools/REGISTRY.json (12,898 chars). Repeated lookups don't cache the parsed registry. | ~7,300 tok per registry-touching call |
| **9** | **Help/menu duplicates** | `axon/HOWTO.md` (9,498), `workspace/programs/help.md` (6,716), `workspace/programs/menu.md` (26,148), `axon/COMMANDS.md` (5,206), `workspace/programs/help/` directory — overlap of help surface, all eligible for lazy-load (T-06/F-07). | ~12,000 tok if pulled together |
| **10** | **`document-parser`, `web-search`, `pattern` re-execute on identical inputs** | No file-hash cache, no query cache, no window cache. PDF re-parse can be 10-50k tokens of returned text per call. | Worst-case 10,000+ tok/repeat |

**Composite ceiling (no caching, no filters)**: ~150,000-200,000 tokens/session of avoidable spend.
**Composite floor (with KV-cached kernel + compiled-only dispatch)**: ~30,000-50,000 tokens/session.

---

## 11. RECOMMENDATIONS (concrete, file-level)

Ordered by impact-per-effort. Each item names the file(s) to touch.

### A. Highest impact (kill the 0% compression problem)

1. **Re-run compile for the 24 files with `ratio=0.0%`** — most likely the OPTIMIZE phase silently no-op'd. Inspect `tools/compile_optimizer.py:cmd_scan` and `axon/compiler/COMPILER.md` Phase 3 rules O1-O10 to find why hybrid output equals input. If the symbolic mapping isn't producing wins on these (e.g., because the source is already mostly symbolic), **delete the `.cmp.md` and let dispatch fall through to source** — keeping a 0%-compression compiled twin only wastes disk and confuses the agent.
   - Touch: `tools/compile.py`, `tools/compile_optimizer.py`, `axon/compiler/COMPILER.md`.
   - Add a guard in `compile-write.py` (line 38-43): refuse to write a file with `ratio < 5%` unless `--force` is passed.

2. **Split `menu.cmp.md`** (26,320 chars / 6,964 tokens) into per-section lazy fragments. Sections OS-STATE / MODES / CODE-DEVELOPMENT / QUALITY can each be a separate `.cmp.md` referenced from a slim shell. Core Rule 12 forbids truncation — but loading separate files for each section is not truncation, it's modular rendering.
   - Touch: `workspace/programs/menu.md`, then recompile.

3. **Split `code-dev-pr-review.md`** (22,856 chars / 5,821 tokens) per existing T-08/U-10 backlog item. Three sub-workflows: review-study / harmonize / execute.
   - Touch: `workspace/programs/code-dev-pr-review.md` → 3 new sources, recompile.

### B. Caching (T-01..T-03 already in c1-p3)

4. **Cache TF-IDF vectorizer + corpus matrix in `dispatch.py`** keyed on `mtime(dispatch-index.json)`. Drop in a module-level `@lru_cache` over `(index-mtime, corpus-tuple) → (vectorizer, X-matrix)`. Saves the recompute on every match.
   - Touch: `tools/dispatch.py:65-86` (`tfidf_similarity`).

5. **Cache TF-IDF model in `pattern.py`** keyed on `(window, mtime(prompt-log.jsonl))`. Same pattern as above.
   - Touch: `tools/pattern.py:76-93` (`tfidf_cluster`).

6. **Add web-search 7-day TTL cache** keyed on `(query, region, results)`. Disk cache under `workspace/memory/cache/web-search/`. T-01 in backlog.
   - Touch: `tools/web_search.py`.

7. **Add document-parser cache** keyed on `(filepath, sha256(content))`. Cached output stored alongside.
   - Touch: `tools/document_parser.py`.

### C. Output discipline

8. **Implement `workspace/preferences/tools/<name>.md` filters** — referenced as "open question #2" and T-09. Format: which JSON fields to keep, which to drop. Wire into a thin wrapper at the tool-call boundary.
   - Touch: new `tools/_axon_filter.py`, modify per-tool `print(json.dumps(...))` sites to route through it. Or simpler: post-filter in `axon.py` before returning to agent.

9. **Add `--quiet` to high-frequency tools** (`clock`, `calculator`, `usage`, `dispatch`). Returns minimal payload (just the result, no echo of inputs).
   - Touch: `tools/clock.py` (drop `iso`/`unix`/`source` when `--quiet`); `tools/calculator.py` (drop `expression`/`variables`/`type` when `--quiet`); etc.

### D. Dispatch correctness (prevents wasted dispatch loops)

10. **Re-evaluate `prefer-compiled: true`**. With 33% of compiled files at 0% ratio, "always prefer compiled" routes to a same-cost compiled twin. Either:
    - flip default to `false`, or
    - gate `prefer-compiled` on `compiled-tokens < source-tokens × 0.85` (only prefer when there's a real win).
    - Touch: `workspace/preferences/smart-dispatch.md` (line 14), `tools/dispatch.py:205-227`.

11. **Persist a `(query-hash → program)` decision cache** in `workspace/memory/longterm/dispatch-cache.json`. Hit avoids the TF-IDF recompute *and* the JSON envelope.
    - Touch: `tools/dispatch.py`.

### E. Boot

12. **Lazy-load `workspace/programs/help/`** per c1-p3 F-07/T-06. The help directory is read-only educational content; load only when `help X` is invoked.
    - Touch: kernel boot chain (whatever loads help — likely `axon.py` or `boot.py`).

13. **Pre-warm `tiktoken`** at boot (F-03). One eager `tiktoken.get_encoding("cl100k_base")` at boot saves ~30 ms × first-call cost on every subsequent `context`/`tokenizer` invocation.
    - Touch: `tools/boot.py` (add a lazy import + warmup of tiktoken at the bottom of `main()`).

### F. Long-term structural

14. **Daemon mode for `axon.py`** (F-08) — eliminates 80-150 ms python cold-start per tool subprocess. Biggest single latency win; doesn't reduce tokens directly but reduces the temptation to over-context to compensate for slow tools.

15. **Unified semantic substrate** (U-12) — one persistent embedding store shared by `semantic-search`, `pattern`, `dispatch`. Eliminates three TF-IDF/embedding pipelines re-computing from cold.

---

## SUMMARY ANCHORS

- **Biggest single waste**: 24/73 compiled programs at 0% compression ratio. Fixing/deleting these is the single highest-leverage cleanup.
- **Hidden tax**: every tool output goes verbatim into context with no filter; high-frequency tools (`clock`×88, `shadow`×109) dominate.
- **Caching gaps**: dispatch + pattern + document-parser + web-search all recompute on every call.
- **`prefer-compiled: true`** is a footgun when 33% of compiled files don't actually compress.
- **Prompt caching is the multiplier**: every recommendation above is conditional on whether the host harness sends KERNEL-SLIM.md cached. If not, fixing kernel size dwarfs everything else.

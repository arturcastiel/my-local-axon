# C1·P3 — Improvement Backlog

> Synthesized from C1·P1 (kernel/programs/tools maps) + C1·P2 (workflows + gaps).
> Scored: **Impact** = how much it moves the needle on faster·useful·gaps·tokens; **Effort** = relative dev cost. Both 1–5.

## Scoring rubric
| | 1 | 3 | 5 |
|---|---|---|---|
| **Impact** | nice-to-have | meaningful | systemic |
| **Effort** | <1 day | 1–3 days | 1–2 weeks |

Score = Impact / Effort. **Top of backlog** = high impact at low effort (≥1.5).

---

## A. FASTER (boot, dispatch, latency)

| ID | Item | Impact | Effort | Score | Notes |
|----|------|--------|--------|-------|-------|
| F-01 | Parallelize `health` tool probes | 3 | 1 | 3.0 | Sequential today; just `concurrent.futures.ThreadPoolExecutor` |
| F-02 | Buffer `log` writes (flush at turn end) | 3 | 2 | 1.5 | Per-write fsync on hot path |
| F-03 | Pre-warm `tokenizer` (lazy import → eager at boot) | 2 | 1 | 2.0 | First call slow; cheap to fix |
| F-04 | Cache `axon-audit` between writes | 4 | 2 | 2.0 | Audits run on every boot today |
| F-05 | Centralize `shadow refresh` to boot vs per-program | 4 | 3 | 1.3 | Each code-dev-* re-checks |
| F-06 | Replace 96 unregistered `shell` calls with first-class `shell` tool | 4 | 4 | 1.0 | Safety + caching wins; bigger refactor |
| F-07 | Lazy-load `help/*.md` only on `help X` | 3 | 1 | 3.0 | 7 redundant files loaded today |
| F-08 | `axon.py` cold-start (re-import per call) → daemon mode | 5 | 5 | 1.0 | Each tool spawns python; daemon would amortize |
| F-09 | Cache `prefs` parse (file mtime check) | 2 | 1 | 2.0 | Today re-parses every TOOL(prefs) |

---

## B. MORE USEFUL (capability gaps, missing workflows)

| ID | Item | Impact | Effort | Score | Notes |
|----|------|--------|--------|-------|-------|
| U-01 | `code-dev-compare` (multi-project diff) | 3 | 2 | 1.5 | Workflow A8 + J |
| U-02 | `library-dev-cite --into-project` flag | 3 | 1 | 3.0 | Enables B3/J2 chain |
| U-03 | `chat-promote` (chat → plan auto-detector) | 3 | 2 | 1.5 | Workflow D4 |
| U-04 | `addon-new` scaffolder | 3 | 2 | 1.5 | Workflow E3, lowers addon barrier |
| U-05 | `workspace-backup verify` subcommand | 2 | 1 | 2.0 | Workflow C6 |
| U-06 | Auto-route igap-improve → `dev-projects/igap/` | 4 | 1 | 4.0 | Currently grouping only; close-the-loop |
| U-07 | Multi-project parallel comparison runner | 3 | 3 | 1.0 | Powers A8 at scale |
| U-08 | Cross-library/code citation graph (`library-dev` ↔ `code-dev`) | 4 | 4 | 1.0 | Real research-driven dev |
| U-09 | Mode-suggest auto-fire when free text ambiguous (already exists; surface earlier) | 2 | 1 | 2.0 | Reduces dead-end inputs |
| U-10 | `code-dev-pr-review` split into review-study / harmonize / execute | 3 | 3 | 1.0 | F1 token saving + A2 reuse |
| U-11 | Surface drift trigger phrases via `gain` | 3 | 2 | 1.5 | Workflow C4 |
| U-12 | Unified semantic substrate (semantic-search + pattern + dispatch share embedding index) | 5 | 5 | 1.0 | Big payoff but big change |

---

## C. BRIDGING GAPS (places agent has to guess)

| ID | Item | Impact | Effort | Score | Notes |
|----|------|--------|--------|-------|-------|
| G-01 | Document `MYAXON.md` auto-execution format explicitly | 3 | 1 | 3.0 | Open question #12 from kernel map |
| G-02 | Specify `smart-dispatch.md` feedback mechanism | 3 | 2 | 1.5 | Open question #3 |
| G-03 | Ship `context.py` (registered PLANNED, referenced by output-layer) | 4 | 3 | 1.3 | Open question #1 |
| G-04 | Document compiled-program execution mechanics in `run.py` | 3 | 2 | 1.5 | Open question #6 |
| G-05 | Define drift-penalty formula in OUTPUT-LAYER.md | 2 | 1 | 2.0 | Open question #10 |
| G-06 | Codify the "5-turn cognition check" rationale OR make it tunable | 2 | 1 | 2.0 | Open question #11 |
| G-07 | Define starvation magic number "10" tunability | 2 | 1 | 2.0 | Open question #9 |
| G-08 | Document `workspace/preferences/tools/` filter format | 2 | 1 | 2.0 | Open question #2 |
| G-09 | Resolve registry doc drift: workspace/tools/REGISTRY.md missing 4 tools | 2 | 1 | 2.0 | Tools map drift finding |
| G-10 | Compiled program schema validation tests | 3 | 3 | 1.0 | Open question #5 |
| G-11 | Harness model auto-report example/template | 2 | 1 | 2.0 | Open question #8 |
| G-12 | Surface unused-but-active tools in `health` | 2 | 1 | 2.0 | Tool map insight |

---

## D. SPENDING LESS TOKENS (token economy)

| ID | Item | Impact | Effort | Score | Notes |
|----|------|--------|--------|-------|-------|
| T-01 | `web-search` cache (TTL 7d, key=query) | 4 | 1 | 4.0 | F4 — likely 60-80% hit rate on rerun |
| T-02 | `document-parser` cache (key=file+git-hash) | 4 | 2 | 2.0 | F5 — eliminates re-parse of unchanged PDFs |
| T-03 | `pattern` vectorizer cache per window | 3 | 2 | 1.5 | TF-IDF re-vectorizes every call |
| T-04 | Compile high-traffic uncompiled programs (axon-compare, harness-builder, discover) | 3 | 2 | 1.5 | Easy +3% coverage |
| T-05 | Memory inlining via `kv-store` for hot W:/L: keys | 3 | 3 | 1.0 | Less file I/O per RETRIEVE |
| T-06 | Eliminate `help/` directory duplicates (lazy load) | 3 | 1 | 3.0 | F-07 dual-counted |
| T-07 | Inline both PR template variants into `code-dev-pr.cmp.md` | 2 | 1 | 2.0 | Per-call template load |
| T-08 | Split `code-dev-pr-review.cmp.md` (23 KB) into 3 sub-workflows | 4 | 3 | 1.3 | Largest single program |
| T-09 | Per-tool output filtering (workspace/preferences/tools/*) | 3 | 2 | 1.5 | Open question #2 — saves verbose tool stdout |
| T-10 | Skip turn-log for !BG / read-only programs | 2 | 1 | 2.0 | Less append on hot path |
| T-11 | Cap `last-summary` retrieval size in menu render | 2 | 1 | 2.0 | Today reads full L:last-session-summary |
| T-12 | Compress E:session-log entries past 30 days (summarize then archive raw) | 3 | 3 | 1.0 | Episodic grows forever |

---

## TOP 12 (rank by score, capped at score ≥ 1.5)

| Rank | ID | Item | Score |
|------|-----|------|-------|
| 1 | U-06 | Auto-route igap-improve → dev-projects/igap/ | 4.0 |
| 2 | T-01 | web-search cache (TTL 7d) | 4.0 |
| 3 | F-01 | Parallelize health probes | 3.0 |
| 4 | F-07 / T-06 | Lazy-load help/*.md | 3.0 |
| 5 | U-02 | library-dev-cite --into-project | 3.0 |
| 6 | G-01 | Document MYAXON.md auto-exec format | 3.0 |
| 7 | F-04 | Cache axon-audit between writes | 2.0 |
| 8 | T-02 | document-parser cache | 2.0 |
| 9 | U-05 | workspace-backup verify | 2.0 |
| 10 | F-03 | Pre-warm tokenizer | 2.0 |
| 11 | F-09 | Cache prefs parse | 2.0 |
| 12 | G-05/G-06/G-07/G-08/G-09/G-11/G-12 | Doc cluster (resolve open questions) | 2.0 each |

---

## RISKS / WATCHOUTS

- **Caching introduces staleness bugs** — every cache needs an invalidation story (T-01, T-02, F-04). Use `git rev-parse HEAD` or file mtime as key.
- **Help/ removal** breaks any addon shipping with local help — verify no addon depends.
- **Splitting `code-dev-pr-review`** changes a hot user workflow; keep alias or compatibility shim.
- **Unified semantic substrate** is structurally good but the migration is the riskiest item; split into a separate plan.
- **Daemon mode (F-08)** changes deployment story; security review needed.

---

## INVERSE LIST (do NOT pursue)

- ❌ Rewrite `axon.py` in another language. Python is the source of truth; embedded daemon (F-08) is the right trade.
- ❌ Replace markdown programs with JSON. Loses human-readability + grep-ability.
- ❌ Remove `help/` directory entirely (vs lazy-load). Addons depend on local help.
- ❌ Auto-merge igap improvements into kernel. Always human-gated (R10).
- ❌ Add a "fast" execution path that bypasses gates. R11/R7/R_COHERENCE non-negotiable.

---

## NEXT (cycle 2 focus suggestions)

1. **Token economy deep dive (cycle 3 focus)** — measure baseline cost per workflow before T-01..T-12.
2. **Compiler internals deep dive (cycle 2)** — O1..O10 rules need empirical validation; add O11 candidates.
3. **Scheduler deep dive (cycle 2)** — preemption mechanics + starvation auto-promote validation.
4. **Memory lifecycle deep dive (cycle 2)** — context-pressure handling, episodic compaction.

These map to existing tasks #7 (Cycle 2) and #8 (Cycle 3) — no replanning needed.

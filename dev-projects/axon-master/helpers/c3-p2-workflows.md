# C3·P2 — Workflows that exploit the token economy

> Builds on C3·P1 (token hotspots). Top finding: **24 of 73 compiled programs have 0% compression** — silent waste. These workflows put the savings on the floor.

---

## A. CACHE-FIRST WORKFLOWS

### A1 · Static-first prompt assembly
- **trigger**: every host-harness turn
- **pieces**: ensure boot chain (KERNEL-SLIM + harness + MYAXON + menu) appears at the very start of every prompt — never interleaved with conversation
- **output**: maximum cache hit rate (target: 90% on cached input)
- **gap**: requires audit of host-harness behavior; potentially a hook contract

### A2 · Web-search cache
- **trigger**: every TOOL(web-search)
- **pieces**: hash query + recent flags → check cache (TTL 7d) → return or fetch+cache
- **output**: ~60-80% hit rate on repeated queries (e.g. cycle work)
- **gap**: cache implementation in `tools/web_search.py`

### A3 · Document-parser cache
- **trigger**: every TOOL(document-parser, parse) on a PDF/DOCX
- **pieces**: cache key = (file path, git-hash, mtime) → return parsed text or compute+cache
- **output**: zero re-parse of unchanged files
- **gap**: cache implementation; honor invalidation

### A4 · Pattern vectorizer cache
- **trigger**: every TOOL(pattern, cluster)
- **pieces**: cache TF-IDF vectorizer per (workspace, window) → reuse across calls
- **output**: ~10x speedup on repeated cluster calls
- **gap**: extend `tools/pattern.py` with vectorizer cache

### A5 · Dispatch vectorizer cache
- **trigger**: every TOOL(dispatch, match)
- **pieces**: cache TF-IDF vectorizer per (workspace, registry mtime) → reuse across calls
- **output**: faster dispatch, less per-call overhead
- **gap**: extend `tools/dispatch.py`

### A6 · Semantic-search mtime invalidation
- **trigger**: file mtime change
- **pieces**: invalidate ChromaDB index entries on file change → re-embed only changed
- **output**: index stays correct without full rebuild
- **gap**: extend `tools/semantic_search.py`

---

## B. COMPILED-PROGRAM HYGIENE WORKFLOWS

### B1 · "Refuse to write zero-compression compiled" gate
- **trigger**: compile output phase
- **pieces**: PHASE 4 OUTPUT computes ratio → if ratio < threshold (default 5%) → ABORT write + LOG
- **output**: no more silent waste; broken compiles surface
- **gap**: extend `tools/compile.py` PHASE 4

### B2 · "Delete existing zero-compression compiled" sweep
- **trigger**: ad hoc OR cron weekly
- **pieces**: scan `programs/compiled/` → identify ratio==0 → delete OR move to `compiled/quarantine/`
- **output**: 24 wasted .cmp.md files removed
- **gap**: small program

### B3 · Split menu.cmp.md / code-dev-pr-review.cmp.md
- **trigger**: ad hoc, dev-mode
- **pieces**: split menu into menu-render + menu-state-gather; split pr-review into review-study/-harmonize/-execute
- **output**: each .cmp.md fits a specific need; better cache locality + lower per-call cost
- **gap**: dev-mode kernel work + recompile

### B4 · "Compress on commit" hook
- **trigger**: pre-commit on workspace/programs/
- **pieces**: detect changed .md → recompile → fail commit if ratio drops below baseline
- **output**: prevents regression
- **gap**: git hook + policy

---

## C. DISPATCH OPTIMIZATION WORKFLOWS

### C1 · Dispatch feedback bootstrapping
- **trigger**: every dispatched program completion
- **pieces**: ask "was this right?" (if `dispatch-ask-feedback ≡ true`) → write to `dispatch-feedback.jsonl`
- **output**: feedback log accumulates; auto-tune loop has data
- **status**: feedback file doesn't exist today (C3·P1 finding); worth seeding

### C2 · Compile candidate suggestion (existing, surface louder)
- **trigger**: cron daily
- **pieces**: TOOL(usage) → top-N most-called source-only programs → suggest compile
- **output**: compile coverage grows where it matters
- **already exists**: `axon-compile-rank` cron job seeded at boot

### C3 · "Hot-call inlining" pattern
- **trigger**: a program calls another program ≥5 times in one EXEC
- **pieces**: at compile time, inline the callee's compiled body
- **output**: avoid repeated dispatch overhead per call
- **gap**: net-new optimizer rule (extends C2-C3)

---

## D. MEASUREMENT-FIRST WORKFLOWS

### D1 · "Token-cost per turn" footer
- **trigger**: every output (when `output-layer-show-context-pressure ≡ true`)
- **pieces**: TOOL(tokenizer) on full pending output + previous context → render
- **output**: user sees real cost, can react
- **already partially**: output layer shows context pressure; not exact token count

### D2 · "Token-cost per workflow" benchmark
- **trigger**: ad hoc OR per-PR
- **pieces**: run a workflow under `TOOL(benchmark)` instrumentation → measure tokens consumed
- **output**: data for backlog prioritization
- **gap**: benchmark wrapper for full workflows (today only per-program)

### D3 · "Cache hit rate" report
- **trigger**: weekly cron
- **pieces**: scan tool cache logs → compute hit/miss ratio per cached tool
- **output**: identify caches that aren't earning their keep
- **gap**: cache logging convention + report program

---

## E. TOOL OUTPUT FILTERING WORKFLOWS

### E1 · `--quiet` flag rollout
- **trigger**: per-tool refactor
- **pieces**: every tool gets `--quiet` and `--format=json|summary|full`
- **output**: callers can request brief output
- **gap**: ~40 tools to retrofit

### E2 · `workspace/preferences/tools/<name>.md` filter spec
- **trigger**: tool registration
- **pieces**: per-tool filter file declaring "drop fields X,Y" or "summary template"
- **output**: callers get cleaned output even when tool is verbose
- **already referenced** in c1-p1 + open question #2; doesn't exist today (C3·P1)
- **gap**: define format + implement reader

### E3 · `prompt-log` summarization on read
- **trigger**: prompt-log read for surfacing
- **pieces**: summarize old entries before re-injecting
- **output**: less prompt-log noise into context
- **gap**: extend `tools/prompt_log.py`

---

## F. TOKENIZER UNIFICATION WORKFLOWS

### F1 · Single tokenizer code path
- **trigger**: refactor
- **pieces**: collapse 3 paths (tokenizer.py / context.py / _axon_lib.py) into one shared module
- **output**: consistent counts everywhere
- **gap**: refactor; track Claude vs GPT-4 tokenization

### F2 · Use Claude tokenizer (not cl100k_base)
- **trigger**: refactor
- **pieces**: when `L:host-model ≡ Claude*`, use Claude-aware tokenization (anthropic-tokenizer or proxy via API)
- **output**: compression ratios become accurate
- **gap**: dependency choice + invalidation of stale benchmark logs

---

## G. MEGACHAINS

### G1 · "Fix the 24 zero-compression files"
`B2 (sweep) → B1 (gate going forward) → B3 (split menu, pr-review) → C2 (compile new candidates) → recompute compression`
**output**: meaningful compile coverage (truly compressed)

### G2 · "Cache the heavy hitters"
`A2 (web-search) + A3 (document-parser) + A4 (pattern) + A5 (dispatch) → D3 (cache hit rate) → tune`
**output**: measurable token + latency reduction on hot workflows

### G3 · "Get accurate measurement first"
`F1 (tokenizer unification) → F2 (Claude tokenizer) → re-baseline benchmark-log → make decisions on real numbers`
**output**: evidence-based optimization (no more "we think we save tokens")

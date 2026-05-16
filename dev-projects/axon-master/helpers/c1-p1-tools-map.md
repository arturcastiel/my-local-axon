# C1·P1 — AXON Tools Map

> Source: parallel exploration agent, 2026-05-16. AXON repo at `/mnt/c/projects/axon`.

## REGISTRY STATUS
- **55 total tools**: 51 ACTIVE + 4 OPTIONAL
- **Single source of truth**: `tools/REGISTRY.json`
- **No orphans**: every registered tool is implemented; every implementation is registered
- **Drift detected**: `workspace/tools/REGISTRY.md` is stale (missing `session-save`, `docgen`, `igap`, `shadow`)

---

## TOOL INVENTORY (by layer)

### Kernel layer (24 active)
`boot`, `memory`, `log`, `queue`, `index`, `checkpoint`, `process`, `benchmark`,
`lint-paths`, `auto-audit`, `undo`, `auto-improve`, `programs-registry`, `compile`,
`prefs`, `enforce`, `test`, `run`, `verify`, `drift`, `usage`, `health`, `events`,
`context`, `prompt-log`, `pattern`, `dispatch`, `dispatch-stats`, `axon-audit`,
`test-runner`, `docgen`, `igap`, `shadow`

### OS layer (21 active)
`clock`, `calculator`, `tokenizer`, `diff`, `validator`, `notify`, `kv-store`,
`semantic-search`, `document-parser`, `web-search`, `translate`, `session-save`

### Optional / deprecated (4)
- `compile-write`, `compile-suggest`, `compile-optimizer` — one-release shims for unified `compile` CLI (PR-007/PR-019)
- `hooks` — deprecated alias for `events`
- `rtk` — external CLI wrapper

---

## CALL FREQUENCY (from workspace/programs/ grep)

### Hottest
| Tool             | Calls |
|------------------|-------|
| `shadow`         | 109   |
| `shell` (not registered) | 96 |
| `clock`          | 88+   |
| `calculator`     | 28    |

### Heavy hitters
| Tool             | Calls |
|------------------|-------|
| `web-search`     | 14    |
| `semantic-search`| 13    |
| `deps`           | 12    |
| `igap`           | 11    |
| `auto-audit`     | 10    |

### Internal-only (zero program-side calls)
`boot`, `queue`, `process`, `benchmark`, `index`, `test`, `run`, `verify`,
`enforce`, `prefs` — all called by harness/kernel chain, not programs.

---

## OVERLAP GROUPS (consolidation candidates)

| Group              | Tools                                            | Status |
|--------------------|--------------------------------------------------|--------|
| Memory backends    | `memory` (file W:/L:/E:) + `kv-store` (diskcache)| Complementary, not redundant |
| Semantic search    | `semantic-search` (embeddings) + `pattern` (TF-IDF cluster) + `dispatch` (TF-IDF route) | Consolidation candidate |
| Logging            | `log`, `prompt-log`, `auto-audit`, `igap`        | All daily append-only files; shared roller possible |
| Compilation        | `compile.py` dispatches to `compile-write/-suggest/-optimizer` | Merge planned (PR-019) |

---

## HEAVY-I/O TOOLS (caching candidates)

### Tier 1 — medium cost, no caching
- `document-parser` (PDF/DOCX parse)
- `web-search` (network)
- `pattern` (TF-IDF re-vectorize per call)

### Tier 1 — medium cost, cached
- `semantic-search` (ChromaDB index persisted) ✓ good

### Tier 2 — expensive, gated
- `compile` (user-initiated)
- `context` (session-level)

---

## FAILURE PATTERNS

### Fail-loud (block + error)
`memory`, `checkpoint`, `undo`, `enforce`, `verify`, `drift`, `lint-paths`,
`auto-audit`, `calculator`, `diff`, `validator`, `dispatch` (with soft fallback),
`events`, `pack`, `deps`, `docgen`, `shadow`

### Silent fallback (degrade)
`log`, `queue`, `index`, `benchmark`, `usage`, `health`, `clock`, `notify`,
`context`, `tokenizer`, `pattern`, `semantic-search`, `kv-store`,
`document-parser`, `web-search`, `cron`, `igap`, `prompt-log` (if disabled)

### Soft / configurable
- `verify` (gated by `L:halt-mode`)
- `dispatch` (gated by `dispatch-fallback` preference)

---

## PERFORMANCE HOTSPOTS

| Context        | Tool                       | Calls       | Bottleneck                       | Fix                         |
|----------------|----------------------------|-------------|----------------------------------|-----------------------------|
| Every boot     | `boot`, `prefs`, `health`  | 1 each      | Health probes sequential         | Parallelize probes          |
| Every program  | `clock`, `calculator`, `context` | 88+, 28+, var | Clock cheap; calculator safe   | None needed                 |
| Per-turn       | `log`, `memory`, `prompt-log` | per program | Log I/O sync; memory file I/O   | Buffer log writes; hot-key kv-store |

---

## TOKEN-WASTE CANDIDATES

| Tool              | Issue                           | Fix |
|-------------------|---------------------------------|------|
| `pattern`         | TF-IDF re-vectorizes every call | Cache vectorizer per window |
| `web-search`      | No caching                      | 7-day TTL cache |
| `document-parser` | No caching                      | Cache by (file, git-hash) |
| `context/tokenizer` | tiktoken expensive if missing | Already falls back to 1.33×word — acceptable |
| `dispatch`        | TF-IDF index cached             | ✓ good |
| `semantic-search` | Index persisted on disk         | ✓ good |

---

## DEPRECATION TIMELINE (one-release shims)

After PR-007 / PR-019 merge:
- `compile-write.py` → `compile format`
- `compile-suggest.py` → `compile rank/status/auto-compile`
- `compile-optimizer.py` → `compile scan/verify/test-all/report`
- `hooks.py` → `events` (alias already in `axon.py`)

---

## KEY METRICS

- **51 ACTIVE tools**: 24 kernel, 21 OS, 6 newer (session-save, docgen, igap, shadow added post-doc)
- **193 programs** in workspace call tools ~600+ times total
- **Zero orphans** — perfect registry sync (vs registry doc drift)
- **80% kernel tools** internal-only (boot chain, gating, compilation) — expected
- **20% tools** have multi-tier failure modes (fail-loud + silent fallback) — audit candidate

---

## INSIGHTS

**Faster**:
- Parallelize `health` probes (currently sequential)
- Cache `pattern` vectorizer per window
- Cache `web-search` results (7-day TTL)
- Cache `document-parser` by file+git-hash
- Buffer `log` I/O (currently sync per write)

**More useful**:
- Resolve registry doc drift (`workspace/tools/REGISTRY.md` missing 4 tools)
- Surface hot/cold tools in `health` to spotlight unused-but-active

**Less token-heavy**:
- Memory inlining via `kv-store` for hot keys (less file I/O)
- Cache hit signals in `prompt-log` so duplicate searches skip

**Bridging gaps**:
- `shell` is the most-called "tool" (96 hits) yet not registered — first-class `shell` tool with sandboxing would unify behavior
- The 3 semantic systems (`semantic-search` / `pattern` / `dispatch`) share substrate; a unified embedding service could collapse them

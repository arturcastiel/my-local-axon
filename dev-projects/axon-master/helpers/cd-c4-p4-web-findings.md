# CD·C4·P4 — external alignment (final)

> Cross-check: which top-15 items have proven prior art (low novelty risk), which are AXON-novel (higher design risk).

## Top-15 vs prior art

| ID    | Item | Prior art | Novelty? |
|-------|------|-----------|----------|
| T-A1  | Quarantine negative-compression artifact | webpack analyzer, DSPy compile metrics | Low |
| T-A3  | Compile regression gate | `bazel`, `make`, all build tools | Low |
| D-A2  | usage recording | every observability tool ever | Low |
| D-B1  | pr-list aggregator | Graphite/gh CLI PR list views | Low |
| T-B5  | LRU cache | `functools.lru_cache` | Trivial |
| T-C1  | preflight summary mode | CI tooling (lint --summary, etc.) | Low |
| T-C2  | next reads cached hint | every "what's next" pattern | Low |
| T-F1  | cron shadow refresh | crontab patterns | Trivial |
| D-A1  | events bus wiring | EventEmitter / Kafka pattern, broadly | Low |
| T-B1  | session read cache | `make` mtime cache | Low |
| T-B2  | resume briefing cache | session-restore patterns | Low |
| T-B3  | JSON sidecar | front-matter parsers, `.bib.json`, etc. | Low |
| D-A4  | benchmark heaviest | DSPy / vega benchmark idioms | Low |
| D-A3  | igap from code-dev | AXON-internal pattern (igap is novel here) | AXON-specific |
| T-A2  | split pr-review into P1–P9 | code-splitting (webpack); DSPy module composition | Low |

**Verdict:** the entire top-15 is well-trodden territory. **Zero items require novel research.**

## Wave 6–11 (post-top-15) vs prior art
| ID       | Item | Prior art | Novelty |
|----------|------|-----------|---------|
| D-E1     | pr-stack | git-spice, Graphite, Sapling | Low |
| D-E2     | reviewer-bot loop | CodeRabbit / Sourcery / Sweep | Low |
| D-B2     | migrate-v4 | every "old → new schema" migrator | Low |
| D-B4     | pr-import (library-dev bridge) | none — AXON-specific synergy | **Novel** |
| G-CD-A4  | release workflow | release-please, semantic-release, changesets | Low |
| D-C8     | coverage-delta | diff-cover, Codecov | Low |
| D-C6     | conflict-predict | Mergify, Graphite restack | Low |

**Verdict:** only D-B4 is genuinely novel (and only by virtue of being an AXON-internal cross-system handoff). Everything else has well-mapped prior art.

## Cache-friendliness checklist (Anthropic / OpenAI prompt caching)
For each compiled `code-dev-*.cmp.md`:
- [ ] `# PROGRAM:` header at top — **static, cacheable**
- [ ] `# desc:`, `# usage:`, etc. — static
- [ ] `## HELP` block — static
- [ ] `## IDENTITY LOCK` — static, identical across programs
- [ ] `## GUARD` — mostly static; project name interpolation is dynamic
- [ ] `## LOAD CONTEXT` — should be late (dynamic)
- [ ] `## OUTPUT` — last (dynamic)

**Action:** audit per compiled program; reorder if any have dynamic content before static (T-A2 split helps here too — smaller files are easier to keep cache-friendly).

## Embedding library survey (for D-T-D1 bm25 ranking)
- **`bm25s`** — Python, no model dep, ~10M docs/s ingest, MIT. Recommended.
- **`rank_bm25`** — Python, older. Slower. Skip.
- **`whoosh`** — full-text index but overkill.
- **`sqlite-fts5`** — already available, can index shadow findings. Worth considering for D-B1 pr-list too.

## Test-impact / coverage-delta library survey (for D-C4/D-C8)
- **`diff-cover`** — coverage on changed lines; Python; simple integration.
- **`pytest-testmon`** — runs only tests affected by changes; pytest-specific.
- **`coverage.py`** — base library; required regardless.

**Action:** `_profile.coverage-tool` field already exists conceptually; document the integration contract.

## Event-bus library survey (for D-A1)
- AXON has `tools/events.py` (the EMIT/ON bus); no new dependency.
- Pattern: code-dev programs call `TOOL(events, emit, --kind <kind> --payload-json <json>)` AND append to `_events.log` via a small helper.

## Compile-pipeline literature (for T-A2 split)
- **DSPy compile/teleprompter** — compiles prompt programs by example.
- **Webpack code-splitting** — split bundles by entry point.
- **`mypy --strict-optional`-style compile-time checks** — applies here as compile-write gate (T-A3).

**Action:** add a small AXON-side `compile-write --regression-check` flag that fails when `cmp.bytes > src.bytes * 0.95`.

## What we will NOT pursue (declared off-roadmap)
- Embeddings + ANN search (overkill; bm25 is sufficient for code-dev's scale).
- A new schema version (v4 is fine).
- A reviewer-bot using a different model (out of scope — single-agent design).
- Multi-tenant code-dev (single-user, single-project session model is correct).
- Auto-merge / merge-queue (HUMAN does the merge; aligned with safety rules).

## Final external alignment statement
The cycle-4 backlog is **almost entirely incremental work with well-mapped external precedent.** AXON code-dev as designed is structurally sound; the gaps are operational (caches, observability) and capability-extension (stacks, bots, release) rather than architectural. The single genuinely novel item (D-B4 library-dev → code-dev handoff) is the natural emergent capability of AXON's two-system design and worth investing in.

→ end of cycle 4. See `cd-c4-p1-synthesis.md` and `cd-c4-p3-improvements.md` for the executive view.

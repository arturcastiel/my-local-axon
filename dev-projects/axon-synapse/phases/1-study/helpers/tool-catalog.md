# Tool Catalog — T-A output (axon-synapse Phase 1)

> Source: `/mnt/c/projects/axon/tools/REGISTRY.json` · 75 tools total
> Caller-count = number of `workspace/programs/*.md` files containing `TOOL(<name>, ...)` invocation
> Generated: 2026-05-17

## Summary

| Metric | Value |
|--------|-------|
| Total tools | 75 |
| Status: ACTIVE | 69 |
| Status: OPTIONAL | 6 |
| Category: audit | 2 |
| Category: code-dev | 1 |
| Category: docs | 1 |
| Category: documentation | 1 |
| Category: host | 1 |
| Category: kernel | 40 |
| Category: os | 29 |
| Zero program-callers | 31 |

## Tools by category

### Category: `audit`  (2 tools)

| # | Tool | Status | Callers | Purpose | Script |
|---|------|--------|---------|---------|--------|
| 1 | `call_graph` | ACTIVE | 0 | PR-31.5 recursive program-call cycle detector | `tools/call_graph.py` |
| 2 | `docgen_verify` | ACTIVE | 0 | PR-34 cross-ref lint between AXON-DOCS-*.md and programs | `tools/docgen_verify.py` |

### Category: `code-dev`  (1 tools)

| # | Tool | Status | Callers | Purpose | Script |
|---|------|--------|---------|---------|--------|
| 1 | `shadow` | ACTIVE | 17 | Shadow index — versioned, content-addressed findings mirror for source files analysed during code-dev workflows | `tools/shadow.py` |

### Category: `docs`  (1 tools)

| # | Tool | Status | Callers | Purpose | Script |
|---|------|--------|---------|---------|--------|
| 1 | `cheatsheet_gen` | ACTIVE | 0 | PR-34.5 regenerate AUTO-VERBS block in cheatsheet | `tools/cheatsheet_gen.py` |

### Category: `documentation`  (1 tools)

| # | Tool | Status | Callers | Purpose | Script |
|---|------|--------|---------|---------|--------|
| 1 | `docgen` | ACTIVE | 1 | Generate full AXON documentation with Mermaid diagrams, program catalog, tool registry, and relationship maps | `tools/docgen.py` |

### Category: `host`  (1 tools)

| # | Tool | Status | Callers | Purpose | Script |
|---|------|--------|---------|---------|--------|
| 1 | `shell` | OPTIONAL | 33 | Host shell passthrough — dispatched by the host harness, no Python script. Programs reference TOOL(shell, ...) for git/f | `tools/shell.py` |

### Category: `kernel`  (40 tools)

| # | Tool | Status | Callers | Purpose | Script |
|---|------|--------|---------|---------|--------|
| 1 | `auto-audit` | ACTIVE | 2 | Append-only ledger of auto-applied changes (PR-015) — record/list/summary | `tools/auto_audit.py` |
| 2 | `auto-improve` | ACTIVE | 1 | Daily orchestrator (PR-017) — auto-compile, auto-tune dispatch, auto-archive episodic. Gated by L:auto-improve (default  | `tools/auto_improve.py` |
| 3 | `axon-audit` | ACTIVE | 2 | Self-audit — 1a: boot chain, registry, refs, internals; 1b: usefulness score and recommendations | `tools/axon_audit.py` |
| 4 | `benchmark` | ACTIVE | 0 | Record and report compilation benchmarks | `tools/benchmark.py` |
| 5 | `boot` | ACTIVE | 0 | Parse workspace state, return JSON boot context | `tools/boot.py` |
| 6 | `checkpoint` | ACTIVE | 1 | Snapshot W: memory + append to episodic log | `tools/checkpoint.py` |
| 7 | `compile` | ACTIVE | 1 | Unified compile pipeline — format/rank/scan/verify/optimize/test-all/check-composition (PR-007) | `tools/compile.py` |
| 8 | `compile-optimizer` | OPTIONAL | 0 | DEPRECATED — use `compile scan/verify/test-all/report/check-composition`. Backing script for the new unified tool. | `tools/compile_optimizer.py` |
| 9 | `compile-suggest` | OPTIONAL | 0 | DEPRECATED — use `compile rank` / `compile auto-compile` / `compile status`. Backing script for the new unified tool. | `tools/compile_suggest.py` |
| 10 | `compile-write` | OPTIONAL | 0 | DEPRECATED — use `compile format`. Backing script for the new unified tool. | `tools/compile-write.py` |
| 11 | `context` | ACTIVE | 2 | Context pressure estimator — track token usage, surface pressure level | `tools/context.py` |
| 12 | `cron` | ACTIVE | 1 | Cron scheduler — add/list/check recurring program jobs | `tools/cron.py` |
| 13 | `deps` | ACTIVE | 2 | Program dependency graph — show/tree/graph/check | `tools/deps.py` |
| 14 | `dispatch` | ACTIVE | 2 | Smart dispatch — match free-text prompt to compiled program using TF-IDF similarity | `tools/dispatch.py` |
| 15 | `dispatch-stats` | ACTIVE | 1 | Weekly token savings summary — dispatched runs, accuracy, compile candidates | `tools/dispatch_stats.py` |
| 16 | `drift` | ACTIVE | 4 | Real drift score: edit distance between expected and actual tool sequence | `tools/drift.py` |
| 17 | `enforce` | ACTIVE | 1 | Machine-check compliance gates before actions | `tools/enforce.py` |
| 18 | `events` | ACTIVE | 4 | EMIT/ON event bus — fire events, register handlers, dispatch | `tools/events.py` |
| 19 | `health` | ACTIVE | 0 | Data-driven health-check runner — iterates REGISTRY.json | `tools/health.py` |
| 20 | `hooks` | OPTIONAL | 0 | DEPRECATED — alias for events tool. Use `events hook-add/list/remove/fire/enable/disable`. Shim removed next release. | `tools/hooks.py` |
| 21 | `igap` | ACTIVE | 4 | Inference gap tracker — record/report/stats on turns where LLM had to infer rather than find explicit instructions | `tools/igap.py` |
| 22 | `index` | ACTIVE | 0 | Update chat/plan INDEX.md tables | `tools/index.py` |
| 23 | `lint-paths` | ACTIVE | 0 | Forbid hardcoded /home/<user> or /Users/<user> paths in shipping tree | `tools/lint_paths.py` |
| 24 | `log` | ACTIVE | 0 | Append formatted entry to daily log file | `tools/log.py` |
| 25 | `memory` | ACTIVE | 3 | STORE/RETRIEVE/CLEAR/APPEND on W:/L:/E: scopes | `tools/memory.py` |
| 26 | `pack` | ACTIVE | 0 | Pack/unpack .axon program bundles | `tools/pack.py` |
| 27 | `pattern` | ACTIVE | 0 | Cluster prompt-log entries by TF-IDF similarity — surface compile candidates | `tools/pattern.py` |
| 28 | `prefs` | ACTIVE | 1 | Load and merge all workspace preference files | `tools/prefs.py` |
| 29 | `process` | ACTIVE | 0 | Spawn/update/complete process lifecycle files | `tools/process.py` |
| 30 | `programs-registry` | ACTIVE | 0 | Single source of truth for the program library (PR-020) — generate/query/validate | `tools/programs_registry.py` |
| 31 | `prompt-log` | ACTIVE | 2 | Session prompt logger — captures user inputs for pattern analysis and smart dispatch | `tools/prompt_log.py` |
| 32 | `queue` | ACTIVE | 1 | Add/list/complete tasks in the scheduler queue | `tools/queue_tool.py` |
| 33 | `rtk` | OPTIONAL | 2 | RTK token optimizer — wraps RTK CLI if installed | `tools/rtk.py` |
| 34 | `run` | ACTIVE | 0 | Execute mechanical ops from compiled .cmp.md | `tools/run.py` |
| 35 | `simulate` | ACTIVE | 2 | Dry-run program — shadow writes, stub tools, simulation report | `tools/simulate.py` |
| 36 | `test` | ACTIVE | 1 | Validate program structure without executing | `tools/test.py` |
| 37 | `test-runner` | ACTIVE | 1 | Run AXON test suite — unit, regression, integration; returns JSON results | `tools/test_runner.py` |
| 38 | `undo` | ACTIVE | 0 | Restore a target file or W: key from its rollback snapshot (PR-016) | `tools/undo.py` |
| 39 | `usage` | ACTIVE | 2 | Usage tracker — record/top/suggest. Identifies compile candidates by call frequency | `tools/usage.py` |
| 40 | `verify` | ACTIVE | 1 | Verify program/output against kernel rule predicates | `tools/verify.py` |

### Category: `os`  (29 tools)

| # | Tool | Status | Callers | Purpose | Script |
|---|------|--------|---------|---------|--------|
| 1 | `audit_compiled` | ACTIVE | 0 | Audit compiled program sizes vs sources (PR-2) | `tools/audit_compiled.py` |
| 2 | `board` | ACTIVE | 1 | ASCII Kanban over pr_aggregate (PR-20.6) | `tools/board.py` |
| 3 | `budget_lint` | ACTIVE | 1 | code-dev per-program budget block lint (PR-20) | `tools/budget_lint.py` |
| 4 | `calculator` | ACTIVE | 13 | Safe math evaluation | `tools/calculator.py` |
| 5 | `cd_cache` | ACTIVE | 9 | code-dev caches bundle (T-B1/B2/B3/B5) (PR-20.5) | `tools/cd_cache.py` |
| 6 | `clock` | ACTIVE | 64 | NTP-accurate timestamps | `tools/clock.py` |
| 7 | `diff` | ACTIVE | 0 | File comparison and staleness detection | `tools/diff_tool.py` |
| 8 | `document-parser` | ACTIVE | 1 | Extract text from PDF/DOCX | `tools/document_parser.py` |
| 9 | `idem_test` | ACTIVE | 0 | code-dev idempotence harness (PR-25) | `tools/idem_test.py` |
| 10 | `kv-store` | ACTIVE | 0 | Fast persistent key-value store | `tools/kv_store.py` |
| 11 | `migrate_meta` | ACTIVE | 1 | Migrate project _meta.md from v1 to v4.1 (PR-3) | `tools/migrate_meta.py` |
| 12 | `notify` | ACTIVE | 0 | Slack/email alerts | `tools/notify.py` |
| 13 | `plan_dag` | ACTIVE | 0 | Plan DAG emitter (Mermaid + JSON) with critical path (PR-16.5) | `tools/plan_dag.py` |
| 14 | `pr_aggregate` | ACTIVE | 2 | Cross-phase PR list aggregator (PR-9.5) | `tools/pr_aggregate.py` |
| 15 | `pr_drift` | ACTIVE | 1 | PR spec-vs-diff drift detector (PR-28.5) | `tools/pr_drift.py` |
| 16 | `pr_export` | ACTIVE | 1 | PR self-contained export packet (PR-28.5) | `tools/pr_export.py` |
| 17 | `pr_sync` | ACTIVE | 1 | PR CI status sync via gh CLI (PR-28.5) | `tools/pr_sync.py` |
| 18 | `redact` | ACTIVE | 1 | Secret redaction patterns (PR-5) | `tools/redact.py` |
| 19 | `rename_snapshot` | ACTIVE | 0 | Rename-safety harness (PR-12) | `tools/rename_snapshot.py` |
| 20 | `rules` | ACTIVE | 3 | Governance rules loader + precedence + trace (PR-4) | `tools/rules.py` |
| 21 | `scan_pre_push` | ACTIVE | 0 | Pre-push secret scan over staged diff (PR-5) | `tools/scan_pre_push.py` |
| 22 | `session` | ACTIVE | 6 | Per-chat _session.md state + auto-checkpoint + recovery (PR-9) | `tools/session.py` |
| 23 | `session-save` | ACTIVE | 0 | Write L:last-session-summary and L:last-session-snapshot for boot-time session restore | `tools/session_save.py` |
| 24 | `study_evals` | ACTIVE | 0 | study output evals against fixture corpora (PR-20.7) | `tools/study_evals.py` |
| 25 | `study_index` | ACTIVE | 2 | study/_index.md maintainer + staleness flags (PR-17) | `tools/study_index.py` |
| 26 | `tokenizer` | ACTIVE | 1 | Exact token counts | `tools/tokenizer.py` |
| 27 | `translate` | ACTIVE | 0 | Symbolic → human-readable translation | `tools/translate.py` |
| 28 | `validator` | ACTIVE | 0 | JSON Schema validation | `tools/validator.py` |
| 29 | `web-search` | ACTIVE | 5 | DuckDuckGo web search | `tools/web_search.py` |

## Tools with zero program-callers

These tools are invoked outside `workspace/programs/*.md` (kernel-direct, axon.py CLI,
cron, or genuinely unreferenced). Each needs classification:

| Tool | Status | Category | Purpose | Likely invocation source |
|------|--------|----------|---------|--------------------------|
| `audit_compiled` | ACTIVE | os | Audit compiled program sizes vs sources (PR-2) | (to investigate) |
| `benchmark` | ACTIVE | kernel | Record and report compilation benchmarks | (to investigate) |
| `boot` | ACTIVE | kernel | Parse workspace state, return JSON boot context | (to investigate) |
| `call_graph` | ACTIVE | audit | PR-31.5 recursive program-call cycle detector | (to investigate) |
| `cheatsheet_gen` | ACTIVE | docs | PR-34.5 regenerate AUTO-VERBS block in cheatsheet | (to investigate) |
| `compile-optimizer` | OPTIONAL | kernel | DEPRECATED — use `compile scan/verify/test-all/report/check-composition`. Backin | (to investigate) |
| `compile-suggest` | OPTIONAL | kernel | DEPRECATED — use `compile rank` / `compile auto-compile` / `compile status`. Bac | (to investigate) |
| `compile-write` | OPTIONAL | kernel | DEPRECATED — use `compile format`. Backing script for the new unified tool. | (to investigate) |
| `diff` | ACTIVE | os | File comparison and staleness detection | (to investigate) |
| `docgen_verify` | ACTIVE | audit | PR-34 cross-ref lint between AXON-DOCS-*.md and programs | (to investigate) |
| `health` | ACTIVE | kernel | Data-driven health-check runner — iterates REGISTRY.json | (to investigate) |
| `hooks` | OPTIONAL | kernel | DEPRECATED — alias for events tool. Use `events hook-add/list/remove/fire/enable | (to investigate) |
| `idem_test` | ACTIVE | os | code-dev idempotence harness (PR-25) | (to investigate) |
| `index` | ACTIVE | kernel | Update chat/plan INDEX.md tables | (to investigate) |
| `kv-store` | ACTIVE | os | Fast persistent key-value store | (to investigate) |
| `lint-paths` | ACTIVE | kernel | Forbid hardcoded /home/<user> or /Users/<user> paths in shipping tree | (to investigate) |
| `log` | ACTIVE | kernel | Append formatted entry to daily log file | (to investigate) |
| `notify` | ACTIVE | os | Slack/email alerts | (to investigate) |
| `pack` | ACTIVE | kernel | Pack/unpack .axon program bundles | (to investigate) |
| `pattern` | ACTIVE | kernel | Cluster prompt-log entries by TF-IDF similarity — surface compile candidates | (to investigate) |
| `plan_dag` | ACTIVE | os | Plan DAG emitter (Mermaid + JSON) with critical path (PR-16.5) | (to investigate) |
| `process` | ACTIVE | kernel | Spawn/update/complete process lifecycle files | (to investigate) |
| `programs-registry` | ACTIVE | kernel | Single source of truth for the program library (PR-020) — generate/query/validat | (to investigate) |
| `rename_snapshot` | ACTIVE | os | Rename-safety harness (PR-12) | (to investigate) |
| `run` | ACTIVE | kernel | Execute mechanical ops from compiled .cmp.md | (to investigate) |
| `scan_pre_push` | ACTIVE | os | Pre-push secret scan over staged diff (PR-5) | (to investigate) |
| `session-save` | ACTIVE | os | Write L:last-session-summary and L:last-session-snapshot for boot-time session r | (to investigate) |
| `study_evals` | ACTIVE | os | study output evals against fixture corpora (PR-20.7) | (to investigate) |
| `translate` | ACTIVE | os | Symbolic → human-readable translation | (to investigate) |
| `undo` | ACTIVE | kernel | Restore a target file or W: key from its rollback snapshot (PR-016) | (to investigate) |
| `validator` | ACTIVE | os | JSON Schema validation | (to investigate) |

## Top tools by caller count

| Rank | Tool | Callers | Purpose |
|------|------|---------|---------|
| 1 | `clock` | 64 | NTP-accurate timestamps |
| 2 | `shell` | 33 | Host shell passthrough — dispatched by the host harness, no Python script. Programs reference TOOL(s |
| 3 | `shadow` | 17 | Shadow index — versioned, content-addressed findings mirror for source files analysed during code-de |
| 4 | `calculator` | 13 | Safe math evaluation |
| 5 | `cd_cache` | 9 | code-dev caches bundle (T-B1/B2/B3/B5) (PR-20.5) |
| 6 | `session` | 6 | Per-chat _session.md state + auto-checkpoint + recovery (PR-9) |
| 7 | `web-search` | 5 | DuckDuckGo web search |
| 8 | `drift` | 4 | Real drift score: edit distance between expected and actual tool sequence |
| 9 | `events` | 4 | EMIT/ON event bus — fire events, register handlers, dispatch |
| 10 | `igap` | 4 | Inference gap tracker — record/report/stats on turns where LLM had to infer rather than find explici |
| 11 | `memory` | 3 | STORE/RETRIEVE/CLEAR/APPEND on W:/L:/E: scopes |
| 12 | `rules` | 3 | Governance rules loader + precedence + trace (PR-4) |
| 13 | `auto-audit` | 2 | Append-only ledger of auto-applied changes (PR-015) — record/list/summary |
| 14 | `usage` | 2 | Usage tracker — record/top/suggest. Identifies compile candidates by call frequency |
| 15 | `pr_aggregate` | 2 | Cross-phase PR list aggregator (PR-9.5) |
| 16 | `study_index` | 2 | study/_index.md maintainer + staleness flags (PR-17) |
| 17 | `simulate` | 2 | Dry-run program — shadow writes, stub tools, simulation report |
| 18 | `deps` | 2 | Program dependency graph — show/tree/graph/check |
| 19 | `context` | 2 | Context pressure estimator — track token usage, surface pressure level |
| 20 | `prompt-log` | 2 | Session prompt logger — captures user inputs for pattern analysis and smart dispatch |
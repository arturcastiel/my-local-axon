# AXON Tools Inventory — Reference Catalog

*Scope:* the AXON Python tool ecosystem, v3.7.0. Source: `axon/tools/REGISTRY.json` + the 93 `tools/*.py` files on disk. Audience: someone explaining how AXON's tools fit together — what exists, how it's called, what gates fire, where the cracks are.

---

## TL;DR

AXON ships 86 registered tools (79 ACTIVE, 7 OPTIONAL, 0 PLANNED at v3.7.0) plus 7 path/IO/response helpers and 2 unregistered scripts on disk. Every tool is invoked through one dispatcher — `python3 axon.py <tool> [args]` — which reads `tools/REGISTRY.json` to locate the backing script. The registry is the **single source of truth**: `axon.py`, `tools/run.py`, `tools/health.py`, `tools/verify.py` and the `R_TOOL_EXISTS` rule all key off it. **ACTIVE** = supported, callable from programs and verified at compile time; **OPTIONAL** = available but not required (deprecation shims, host-dispatched, third-party wrappers like `rtk`); **PLANNED** = name reserved but no implementation, blocked by `R_NO_PLANNED_TOOLS`.

---

## 1. The Registry Contract

### Schema

`tools/REGISTRY.json` is a top-level JSON object with three meta keys plus a `tools` map:

```
{
  "schema_version":    "v1.1",
  "contract_version":  "neuron-contract v1.1",
  "description":       "AXON tool registry — single source of truth ...",
  "tools": {
    "<name>": { "script": ..., "status": ..., "category": ..., "purpose": ..., ... },
    ...
  }
}
```

Each entry has at minimum:

| Field      | Type   | Meaning |
|------------|--------|---------|
| `script`   | string | Repo-relative path to the Python file (`tools/<name>.py`). `tools/shell.py` is the one exception — it's declared but no file exists. |
| `status`   | string | `ACTIVE` \| `OPTIONAL` \| `PLANNED` (v3.7.0 has no PLANNED entries). |
| `category` | string | Bucket label: `kernel`, `os`, `system`, `synapse`, `code-dev`, `audit`, `docs`, `documentation`, `host`. |
| `purpose`  | string | One-sentence description, shown by `axon.py help`. |

Optional extras (newer entries):

| Field        | Used by                                                       |
|--------------|---------------------------------------------------------------|
| `desc`       | longer prose for help screens (`docgen`, `igap`, `shadow`, `shadow_retroactive`) |
| `args`       | sample CLI invocation lines (`session-save`, `igap`, `shadow`, `predicate`, `goal`) |
| `health`     | smoke probe spec — either a string command or `{probe: ..., expect: ...}` consumed by `tools/health.py` |
| `synapse`    | v1.1 neuron-contract block (domain · family · role · invocation-source) — required for synapse-classified tools (`predicate`, `goal`) |

### Cross-references from the kernel

`axon/KERNEL-SLIM.md` §TOOLS (lines 470-480) names the registry as canonical and lists five anchor tools by purpose:

- `tools/verify.py` — runs kernel rule predicates at compile + response time.
- `tools/drift.py` — real edit-distance score of expected vs. actual tool sequence.
- `tools/health.py` — iterates REGISTRY, surfaces tools automatically.
- `tools/usage.py` — records every program run (auto-wired in `tools/run.py`).
- `tools/enforce.py` — write-gate before any change to `axon/`.

`axon.py` (the CLI), `tools/run.py` (the mechanical-op executor), `tools/health.py` (the health-check runner), and the `r_tool_exists` rule all read `REGISTRY.json` directly. Adding a tool means one edit there — `health.py`, `axon.py help`, and the verifier all pick it up automatically.

### `R_TOOL_EXISTS` — the static gate

`axon/tools/rules/r_tool_exists.py` is the predicate that enforces the registry. For every program at compile time, it walks all `TOOL(name, ...)` call sites with the regex `r'TOOL\(\s*([a-zA-Z_][\w-]*)'` and asserts each `name` resolves to a registry entry with status `ACTIVE` or `OPTIONAL`. Anything else (`PLANNED`, missing, typo) returns a `Violation` with `severity="BLOCK"` and `phase="STATIC"`, which `verify.py` reports as a compile-time blocking violation.

Key quirks:

- Output-literal lines (`→ "TOOL(...)"`) are skipped to allow programs to print example syntax.
- Comments (`#`) are skipped.
- `OPTIONAL` is permitted — this is how `shell` passes despite no script on disk.
- The rule fails open if the context lacks a registry — empty contexts return `None`, no violation. So a verifier called without a `registry` field in its state never blocks. This is intentional (allow tooling that doesn't care about registry membership) but worth knowing when debugging false negatives.

There is also a sibling rule, `R_NO_PLANNED_TOOLS` (`r_no_planned_tools.py`), that hard-blocks programs referencing `PLANNED` tools — currently moot because the registry has zero PLANNED entries, but the gate exists and is wired into the same `verify program <path>` static gate.

### How a tool gets registered

The flow for adding a new tool:

1. Write `tools/<name>.py` following the conventions in Appendix D.
2. Add an entry to `tools/REGISTRY.json` with at least `script`, `status="ACTIVE"`, `category`, `purpose`.
3. Optionally register a health probe in the entry's `health` block, OR in `tools/health.py`'s `PROBES` table.
4. Optionally add a CLI alias in `axon.py`'s `ALIASES` dict if you want a shorter name.
5. CI picks up the rest: `lint-paths` runs the path-portability lint, `test-runner` exposes any new `tests/test_*.py`, and `docgen_verify --strict` fails if any AXON-DOCS-*.md mentions a deprecated subsystem.

No edits to verifier code are needed — the rule modules iterate the registry. No edits to `axon.py` are strictly required either (only if you want an alias). The architecture is data-driven by design.

---

## 2. Tool Invocation

### CLI shape

```
python3 axon.py <tool> [subcommand] [--flag value ...]
```

`axon.py` (99 lines, no external deps) is a thin dispatcher: it loads the registry, optionally rewrites a short alias (`kv` → `kv-store`, `parse` → `document-parser`, `web` → `web-search`, `validate` → `validator`), then `subprocess.run`s the backing script with all remaining argv. Output is whatever the child prints — usually a one-line JSON envelope, occasionally a markdown table or formatted text.

Programs that call `python3 axon.py help` get a registry-derived table with status legend:
- `✓` active script exists on disk
- `·` planned (not implemented; would block with R_NO_PLANNED_TOOLS)
- `○` optional
- `✗` script missing from disk (only `shell` fits today)

### AXON-LANG → CLI binding

Inside AXON programs (`.md` files), tools are called through the `TOOL(...)` operator. The mapping is mechanical:

| AXON-LANG                              | CLI                                                                                  |
|----------------------------------------|--------------------------------------------------------------------------------------|
| `TOOL(name)`                           | `python3 axon.py name`                                                              |
| `TOOL(name, subcmd)`                   | `python3 axon.py name subcmd`                                                       |
| `TOOL(name, subcmd, "--flag", value)`  | `python3 axon.py name subcmd --flag value`                                          |
| `TOOL(name, subcmd, ...) → STORE(W:k, result)` | runs the call, parses JSON, stores in `W:k` (executed by `tools/run.py`)       |

`tools/run.py` is the mechanical executor for compiled `.cmp.md` programs. It loads `REGISTRY.json` once, scans each line for `TOOL(...)`, `LOG(...)`, `STORE/RETRIEVE/CLEAR/APPEND(W:/L:/E:)`, and invokes the matching backing script via subprocess. Anything semantic (IF/EXEC/QUERY/ASSERT/LOOP) is returned to the agent layer.

### Subprocess vs. in-process

Today the dispatcher is a `subprocess.run` per tool call. Each tool re-parses argv, re-reads its inputs, and prints JSON. CHANGELOG flags PR-019 as the planned in-process refactor; the `_axon_lib.py` / `_axon_io.py` / `_axon_response.py` helpers are the first step (canonical envelope + atomic write). The subprocess model has three measurable costs:

1. **Python interpreter startup** ~50-100 ms per call. For a program that fires 20+ tool calls, this dominates wall-clock time.
2. **Argv parsing overhead** — each tool's argparse is constructed from scratch on every invocation; the dispatcher cannot cache.
3. **No state sharing** — every tool reads its own copy of `REGISTRY.json`, `WORKSPACE.md`, longterm flags. The `usage` tracker observes this at ~30 reads/s in dispatcher tracing.

The trade-off is reliability: a crash in tool X cannot poison the dispatcher's interpreter, and pure-stdlib tools (clock, calculator, tokenizer) can be invoked without contaminating the main process's import graph. For now, the `with loop_receipt(...)` context manager in `_loop_receipt_ctx.py` is the only in-process bridge between tools — and even there, it deliberately keeps imports light so a failure inside `loop_receipt.py` propagates as a clean Python exception rather than a stuck subprocess.

### Output envelope

The canonical reply envelope (rolled out via `_axon_response.py`, not yet universally adopted) looks like:

```
{
  "ok": true,
  "<tool>": {<payload>},
  "_v": 1
}
```

Failures use `{"ok": false, "error": "...", "code": "...", "_v": 1}`. Most tools still print raw JSON (`{"written": true, "file": "..."}` style) — migration is incremental. When you see a tool whose output starts with `{"ok": ...}` you're looking at an updated one; the others ship one-off shapes.

---

## 3. Tools by Category

### 3.1 State / memory

Six tools form the memory substrate. The architecture is layered: human-readable markdown files (`memory.py`) for AXON's primary scopes, diskcache (`kv_store.py`) for high-frequency operations, JSON snapshots (`checkpoint.py`, `session_save.py`) for crash recovery, and the per-chat session record (`session.py`) for state-machine bookkeeping.

`memory.py` is the canonical W:/L:/E: scope front-door (get / set / append / list / clear / rollback / history), with automatic 3-step rollback history on L:. Working memory `W:` is per-session and cleared on boot; longterm `L:` is persistent with up to 3 rollback versions per key; episodic `E:` is append-only and never cleared (it's the system's long-term identity log). Each scope maps to a directory: `workspace/memory/working/`, `workspace/memory/longterm/`, `workspace/memory/episodic/`. Files are named `<key>.md`. Writes go through `_axon_io.atomic_write`, so a crash mid-write never leaves a half-written file.

`kv_store.py` is the diskcache-backed fast path for high-frequency K/V (`set`, `get`, `delete`, `list`, `exists`, `clear`). Backing store: `workspace/memory/kv-store/` (configurable via `--store`). Use when you need millisecond reads of structured data that doesn't fit the human-readable markdown model — inventory lookups, dispatch caches, ephemeral hot-path state.

`checkpoint.py` snapshots all W: keys to a labelled JSON (`workspace/memory/working/<label>.json`) plus appends a row to `workspace/memory/episodic/session-log.md`. Use at phase boundaries, before tool side effects, before irreversible actions, or before yielding to the user. The label defaults to `"checkpoint"` but should usually be descriptive.

`session.py` writes per-chat `_session.md` records with state-machine transitions (active/frozen/tagged/closed/recovered) and 20-turn auto-checkpoint cadence. The state machine forbids invalid transitions — closed → anything is rejected, frozen → recovered is rejected, etc. Storage lives next to `_meta.md` in the dev-project root.

`session_save.py` is the boot-aware variant. It persists `L:last-session-summary` (compact one/two-liner shown at next boot) and `L:last-session-snapshot` (JSON dict of W: keys restored on resume). Per-key cap is ~2 KiB — larger values are skipped during snapshot. The `restore` action reads the snapshot and rewrites each `W:<key>` to disk (idempotent).

The `_axon_rollback.py` helper underwrites both `memory.py` and `undo.py`. It exposes `snapshot(target)`, `restore(target, version)`, `list_snapshots(target)`, and `w_key_path(workspace, key)`. Every auto-action takes a snapshot before writing — the contract of PR-016 — so the worst case after an unwanted auto-edit is `undo --target <path>` and the previous version is back.

### 3.2 Logging / events

Three tools handle observability. `log.py` is the canonical formatter for `workspace/log/entries/YYYY-MM-DD.md` — every entry follows the kernel-spec format `[YYYY-MM-DD HH:MM:SS] | [LEVEL] | [source] | [message]`. Every entry runs through `redact.py` first, so secrets are scrubbed before write; raw match metadata (pattern hit + first 8 chars of sample) lands in a gitignored sidecar at `my-axon/memory/local/log-<date>.redactions.log`. The redaction sidecar is keyed off the same date so investigators can correlate scrubbed entries with their original matches without exposing secrets to the public log.

`events.py` (PR-006) is the unified bus (emit / listen / log / clear) **and** hook registry (hook-add / list / remove / fire / enable / disable). Bus entries live at `workspace/events/event-log.json`; hook definitions at `workspace/events/hooks.json`. Hook actions: `notify` (calls `notify.py`), `log` (appends via `log.py`), `exec` (runs a program via `run.py`). The merge of bus + hooks into one tool (PR-006) replaced the earlier separate `hooks.py`, which now exists as a one-release deprecation shim. Handlers (ON triggers) at program level pattern-match event names; the tool manages both the bus and the registered hooks.

`notify.py` is the alert channel — Slack webhook or SMTP email, configurable via env vars (`SLACK_WEBHOOK_URL`, `SMTP_HOST`, `SMTP_PORT`, `SMTP_FROM`, `SMTP_USER`, `SMTP_PASS`) or `workspace/memory/longterm/tool-notify-config.json`. Hook-fired notifications flow through here automatically when a hook with `action=notify` matches an emitted event.

### 3.3 Verification / compliance

`verify.py` is the kernel-rule engine: it loads everything from `tools/rules/` and runs them either statically (against a program file) or at runtime (against pending output / action). The ten registered rules live in `tools/rules/`:

| Module                       | Rule                  | Phase   | Severity | What it blocks |
|------------------------------|-----------------------|---------|----------|----------------|
| `r3_arithmetic.py`           | R3_ARITHMETIC         | RUNTIME | BLOCK    | inline math the calculator should have handled |
| `r7_no_symbolic_output.py`   | R7_NO_SYMBOLIC_OUTPUT | RUNTIME | BLOCK    | raw `→ "..."` symbolic lines leaking through translate |
| `r9_axon_write.py`           | R9_AXON_WRITE         | BOTH    | BLOCK    | `WRITE`/`APPEND` into `axon/` outside dev-mode |
| `r_tool_exists.py`           | R_TOOL_EXISTS         | STATIC  | BLOCK    | TOOL(name) where name is not ACTIVE/OPTIONAL |
| `r_tool_call_exists.py`      | R_TOOL_CALL_EXISTS    | STATIC  | BLOCK    | malformed `TOOL(...)` constructs |
| `r_w_budget.py`              | R_W_BUDGET            | RUNTIME | WARN     | > N W: keys (file count, not in-memory) |
| `r_no_planned_tools.py`      | R_NO_PLANNED_TOOLS    | STATIC  | BLOCK    | reference to a PLANNED tool |
| `r_coherence.py`             | R_COHERENCE           | RUNTIME | WARN     | output that does not match program intent |
| `r_reasoning_trace.py`       | R_REASONING_TRACE     | RUNTIME | WARN     | missing reasoning trace under dev-mode |
| `r_drift_gate.py`            | R_DRIFT_GATE          | RUNTIME | BLOCK    | output emitted while `tools/drift.py gate` reports diverged |

`enforce.py` is the machine-executable wrapper for individual gates. The three subcommands have wildly different teeth: `check-write` actually `sys.exit(1)`s on `axon/` writes without dev-mode (this is the gate the kernel calls before every program write to `axon/`); `check-arithmetic` and `check-source` are stub no-ops — they print advisory JSON and fall through without exiting (see F-D7-007 below). The discrepancy matters because the kernel cites `enforce.py` as "machine-executable write gate" — only `check-write` actually gates.

`predicate.py` is the standalone evaluator for AXON predicate language v1.1 (parser + AST + safe-null mode), shared between `goal`, synapse pre/post-state, and workflow gates. The parser is hand-rolled recursive-descent using only the standard library; tokenizer is a single regex. Safe-null mode means undefined refs return `null` rather than raising; this prevents brittle workflows but masks bugs (an undefined `goal.acceptance.met()` returns `null`, and `null ≡ true` is false → predicate silently bypassed).

`rules.py` is the loader and PRECEDENCE engine for the human-facing `workspace/safety/rules.md` governance file — separate from the kernel-rule predicates in `tools/rules/` despite the similar name. The precedence ladder (highest to lowest): kernel/identity → user-memory operational-safety → AGENT contract (AGENTS.md) → project safety/rules.md → inline `--rule` injection → project dont-do.md (legacy) → workflow conventions → defaults. PR-10 added `--strict` gating; PR-11 wired plan to read this; PR-22 added the audit subcommand for contradiction + dead-rule detection.

### 3.4 Scheduling

Two tools cover scheduled and queued work. `cron.py` adds/lists/checks recurring jobs with a circuit-breaker on repeated failures. Schedule grammar: `daily HH:MM`, `weekly WEEKDAY HH:MM` (full or short day names), `hourly`, `interval Nm`. Storage is `scheduler/cron.json`, lock at `scheduler/cron.lock`, sidecar events at `memory/local/cron-events.jsonl`. The breaker disables a job after N consecutive failures (default 3, max-disable at 5 boot-time). Wall-clock tick budget per check is 30 seconds — long-running jobs are spawned in the background and their completion is recorded on the next tick. Boot reads `cron check` for overdue runs so a scheduled job survives even when the user logs out for days.

`queue_tool.py` (registered as `queue`) is the priority queue with five levels (`!CRIT`, `!HIGH`, `!NORM`, `!LOW`, `!BG`) defined in `PRIORITY_ORDER`. Concurrent-safe via OS-level `fcntl.flock` exclusive locks on a sidecar `.lock` file held for the entire critical section. Writes go to a temp file then atomic `os.replace`, so a crash mid-write never leaves a corrupt JSON. Storage: `workspace/scheduler/queue.json` with `active`, `paused`, `completed` arrays. The kernel's start-gate rule reads from here: a task can fire only when no higher-priority task is pending AND all deps COMPLETE AND required tools ACTIVE.

### 3.5 Programs / dispatch

`run.py` is the mechanical executor for compiled `.cmp.md` files (see §2). `dispatch.py` matches free-text prompts against the compiled-program index using TF-IDF cosine similarity; the index (`memory/longterm/dispatch-index.json`) is populated by `compile_suggest.py` as programs are compiled. `programs_registry.py` is the structured catalog of `workspace/programs/*.md` — schema includes name, file path, compiled mirror, status, area, description, tools list, mtime — and replaces the per-render filesystem scan the menu/find-program path used to do. `compile_suggest.py` doubles as the find-program/usage-suggest surface.

### 3.6 Compilation

`compile.py` is the unified pipeline dispatcher introduced in PR-007. Subcommands map to the three legacy backing scripts (which remain on disk and stay marked OPTIONAL for one release):

| `compile <sub>`      | Backing script               | Action                |
|----------------------|------------------------------|-----------------------|
| `format`             | `compile-write.py`           | format/write `.cmp.md`|
| `rank` / `suggest`   | `compile_suggest.py`         | rank compile candidates|
| `auto-compile`       | `compile_suggest.py`         | fire eligible ones    |
| `status`             | `compile_suggest.py`         | show coverage         |
| `scan` / `optimize`  | `compile_optimizer.py`       | rank by savings       |
| `verify`             | `compile_optimizer.py`       | per-program simulate  |
| `test-all`           | `compile_optimizer.py`       | verify every cmp.md   |
| `report`             | `compile_optimizer.py`       | full coverage report  |
| `check-composition`  | `compile_optimizer.py`       | detect re-invention   |

`audit_compiled.py` (PR-2) is the standalone audit: walks `programs/compiled/*.cmp.md`, computes byte/token ratios against the source, classifies GREEN/YELLOW/RED/GREY, and writes both a markdown table and JSONL. The `_quarantine.md` file that PR-2 introduces tracks placeholders the compiler couldn't usefully shrink.

### 3.7 Audit + drift

Four tools share the audit + drift concern, but each measures something different.

`axon_audit.py` is the structural self-audit. Section 1a (structural integrity) verifies the boot chain (KERNEL-SLIM → BOOT.md → boot.py), the tool registry vs disk (every script referenced must exist; every script on disk should be in the registry), every internal cross-reference (EXEC, TOOL, READ across all programs must resolve), the core file inventory, and the memory/workspace directory structure. Section 1b (usefulness) computes a health score, compilation coverage (% of programs with `.cmp.md`), dispatch readiness (index entries vs programs), counts active plans/chats, and estimates token-savings potential. The audit is itself called by `health.py` for self-test.

`drift.py` writes the live trace at `workspace/working/drift-trace.json` (`init` / `record` / `check` / `reset` / `gate`). Score = normalized edit distance over the matched prefix between expected and actual tool sequence. Bands: 0.00-0.10 stable, 0.10-0.40 drift, 0.40+ diverged. The gate is fail-closed (PR-AUTO-213): anything unparseable, missing, or older than `DRIFT_TRACE_TTL_S` returns `state="unknown"` with `decision="halt"` and `modifier=-50` — the same shape as a real diverged outcome. The output layer reads the gate result before emitting, so the gate halts user-visible output without halting the agent loop.

`axon_drift_log.py` (PR-CA-102) is the append-only JSON-Lines persona-bleed / cognition-frame violation ledger at `workspace/log/drift/YYYY-MM-DD.jsonl`. Kinds: `persona-bleed`, `cognition-frame`, `missing-trace`, `other`. The logger never reads its own output to make decisions — it is a one-way sink. Companion to `axon-reanchor`, which is the program-side intervention when the log surfaces patterns.

`igap.py` (inference gap tracker) records turns where the LLM had to infer rather than find explicit instructions. Four gap types: `low-confidence` (CONFIDENCE(n) below threshold with no explicit instruction source), `semantic-search` (called for something addressable by a program/L: key), `fallback-exec` (drift recorded a fallback-exec event), `absent-instruction` (QUERY(user) issued because a rule was missing, not because of ambiguity). Logs land in `workspace/log/igap/YYYY-MM-DD.md` and runs through the `loop_receipt` context manager so each record creates an audit row. Reports dedup suggestions, so the same issue logged 50 times doesn't surface 50 times. Runs at !BG priority so it never interrupts active tasks.

### 3.8 Workflow + DAG

`synapse_suggest.py` ranks candidate synapses for the next step using the 11-signal combiner from `orchestrator-composition-v1` (intent · dispatch · usage · pattern · next-conditional · goal-alignment · context-pressure · drift · igap · shadow · cost) with FL-04 tie-break and FL-07 cold-start. `dag.py` is the mutator + verifier for DAG files at all five levels of the spec (`bootstrap` / `add-node` / `add-edge` / `remove-node` / `remove-edge` / `merge` / `split` / `fold-in` / `set-status` / `render` / `verify` / `sync` / `migrate`); `DAG.json` is canonical, `DAG.md` is regenerated. `plan_dag.py` (PR-16.5) walks per-PR `Depends-on:` lines in `<project>/03-prs/pr-*.md`, runs Kahn's algorithm for acyclicity, computes the critical path, and emits Mermaid + JSON. `dispatch_stats.py` (PR-19) is the precision/recall metrics surface for dispatch (P@1 / P@3 against the PR-18 corpus); writes daily JSON to `my-axon/log/dispatch-metrics/`.

### 3.9 Library / documents

`document_parser.py` extracts text from PDF and DOCX. `study_index.py` (PR-17) maintains `<project>/study/_index.md` and classifies entries by staleness (fresh/warn/stale/strict-block) using configurable day thresholds — consumed by `code-dev pr ready --strict` and `state next`. `web_search.py` is a DuckDuckGo wrapper using the `ddgs` package. `pack.py` packs/unpacks `.axon` ZIP bundles (manifest.json + programs/ + optional tools/preferences/) for sharing. `docgen.py` is the kitchen-sink documentation generator — scans kernel + programs + tools + memory, emits AXON-DOCS.md with Mermaid diagrams. `docgen_verify.py` (PR-34) cross-ref-lints every `AXON-DOCS-*.md` against the actual program tree and flags references to deprecated subsystems. `cheatsheet_gen.py` (PR-34.5) regenerates the AUTO-VERBS block in the cheatsheet from per-program `# desc:` headers.

### 3.10 Auto-improvement

`auto_improve.py` is the daily orchestrator (PR-017). Three narrow auto-actions are eligible: `auto-compile` (programs with ≥5 uses in last 7d that aren't compiled → `compile rank --auto` produces `.cmp.md`), `auto-tune` (dispatch threshold tuning when neg-rate > 30% over last 20 feedback rows, bounded at 0.95), `auto-archive` (episodic memory entries > 30d → moved to compressed annual archive with no data loss). Each action is chosen for one of three reasons: regenerable (can be recreated), single-value (no compounding), or non-destructive. Master gate: `L:auto-improve ≡ true` (default false; user opts in once trust is established). Hard precondition: drift gate must NOT be diverged. Soft precondition: drift drifting → confidence penalty applied to run metadata; actions still fire. Every action records to `auto_audit.py` (actor: `orchestrator`) and snapshots its target via `_axon_rollback.py`. Fired by the cron daemon when the master gate is true.

`auto_audit.py` is the append-only ledger of auto-applied changes — the trust foundation that lets `L:auto-improve` flip from off to on safely. Storage: `my-axon/log/auto-edits/YYYY-MM-DD.md`, one file per day. Schema per row: `| ts | actor | action | target | before_hash | after_hash | gate | rule |` plus a sub-row carrying before/after excerpts truncated to ≤120 chars with ellipsis. Actors enumerated: `orchestrator` (PR-017), `cron` (PR-010 boot-time tick), `cron-manual` (explicit `cron run --id`), `hook` (PR-006 events hook-fire), `drift-halt` (PR-012 R_DRIFT_GATE blocked output), `user` (rare; only when caller asserts identity).

`loop_receipt.py` (loop-receipt-v1 / PR-AUTO-201) is the two-phase commit ledger that backs every reversible side-effect from autonomous loops. Every action goes BEGUN → (COMMITTED | ROLLED-BACK | ABORTED) at `axon/state/loop-receipt.ledger.jsonl`. Writes route through `_axon_io.atomic_append` with `_actor="loop-receipt"` which the chokepoint whitelists so the substrate can write without dev-mode (the ledger IS the per-write audit trail). Subcommands: `begin` (append BEGUN row, print `{"id": ...}`), `commit` (append COMMITTED for id, verify state machine), `rollback` (append ROLLED-BACK; caller restores from pre.value), `abort` (append ABORTED with reason), `show` (read full receipt by id), `list` (filter by actor/phase/since-days/limit), `verify` (recompute post.checksum vs live target — drift check), `gc` (drop terminal rows older than `--keep-days`, default 90), `recover` (boot-path: convert orphaned BEGUN rows to ABORTED/COMMITTED). Closes findings FA-12, B-04, B-06, B-07, B-14, B-20 and resolves D-AUTO-001.

`_loop_receipt_ctx.py` is the Python `with` wrapper so action code can write idiomatic Python:

```python
with loop_receipt(
    actor="auto-improve",
    intent="tune-threshold",
    target_kind="L",
    scope="L",
    key="synapse-suggest.score-floor",
    pre_value=0.55,
    post_value=0.50,
    rationale="auto-tune step -0.05",
    trigger=("cron", "auto-improve-daily", 412),
) as rcpt:
    memory.set(scope="L", key="synapse-suggest.score-floor", value=0.50)
```

Invariant: exactly one terminal record (committed | aborted) is written for every BEGIN. The receipt is BEGUN-but-orphaned only if the process crashes between `begin()` and the `__exit__` handler; boot-time `recover()` reaps those.

### 3.11 Utilities

A long tail of leaf tools handles single jobs: `clock.py` (NTP fallback to system clock), `calculator.py` (`simpleeval` with whitelisted functions; never `eval`), `tokenizer.py` (tiktoken `cl100k_base`), `redact.py` (7 secret-pattern regex set), `diff_tool.py` (file comparison with `--summary` / `--unified` modes), `pack.py` (already in 3.9), `deps.py` (program dependency graph from `EXEC()` / `TOOL()` / `READ()` calls), `context.py` (token-pressure estimator with low/medium/high/critical levels), `cd_cache.py` (4-caches bundle for code-dev: mtime read cache, briefing cache, reviewer-state sidecar, in-process shadow LRU), `test.py` (program structural validator — checks `# PROGRAM:` / `# desc:` / `!PRIO` / `DONE()` / `▶` banner / `## OUTPUT`), `test_runner.py` (pytest wrapper with suite filters), `idem_test.py` (PR-25 idempotence harness: runs a program twice over a fixture, diffs normalized output, threshold 80%), `validator.py` (JSON Schema), `board.py` (PR-20.6 ASCII Kanban over `pr_aggregate`), `lint_paths.py` (forbid `/home/<user>/`, `/Users/<user>/`, `/mnt/<x>/<host>/`, `C:\Users\<user>\` in shipping tree), `scan_pre_push.py` (PR-5 wraps `redact` over `git diff --cached`; honours `redact-allowlist.md`), `rename_snapshot.py` (PR-12 captures `{program, desc, sections, status, exec_refs, registry_entry}` and diffs across renames), `migrate_meta.py` (PR-3 `_meta.md` v1 → v4.1 migrator with backup + restore), `migrate_synapse_blocks.py` (PR-108 one-shot bulk insert of `# synapse:` blocks via `synapse_infer`), `pattern.py` (TF-IDF clustering over the prompt log to surface compile candidates), `simulate.py` (dry-run executor — same op patterns as `run.py` but no real side-effects; flags irreversible ops), `translate.py` (mechanical symbolic-to-prose default output translator).

A few more sit on the periphery: `benchmark.py` records compile cost ratios with model-priced cost-per-run, `boot.py` is the JSON boot-context emitter consumed by every session start, `health.py` is the data-driven probe runner, `prefs.py` aggregates `workspace/preferences/*.md` into one JSON view and atomically updates `runtime.md` via `set_pref()`, `process.py` manages `processes/active/[P-NNN].md` lifecycle files (SPAWNED → RUNNING → PAUSED → COMPLETE/FAILED), `prompt_log.py` (opt-in via `L:prompt-log-enabled`) captures user inputs to JSONL for `pattern.py` clustering, `index.py` reads/writes INDEX.md tables (chats, plans) without manual markdown editing, `pr_aggregate.py` (PR-9.5) reads PR blocks from each `_meta.md` and prints a cross-phase table or JSONL, `pr_drift.py` (PR-28.5) heuristically compares acceptance-checklist items vs `git diff`, `pr_sync.py` (PR-28.5) pulls CI status via `gh pr checks`, `pr_export.py` (PR-28.5) writes a self-contained markdown packet for one PR, `budget_lint.py` (PR-20) enforces `# budget:` blocks on `code-dev*.md` programs, `call_graph.py` (PR-31.5) detects cycles in `EXEC(code-dev-NAME)` chains, `study_evals.py` (PR-20.7) scores study outputs against fixture corpora (structural Jaccard + key-fact coverage), `synapse_infer.py` parses programs + REGISTRY into neuron-contract records, `synapse_validate.py` checks records against the v1.1 schema, `domain_validate.py` (PR-106) validates `workspace/domains/*/manifest.md`, `goal.py` (PR-103) is the set/get/confirm/list/met/audit surface for goal-schema-v1 records at the 7 levels (project/phase/workflow/step/pr/finding/demand), `rtk.py` is a graceful stub that forwards to a real `rtk` CLI if installed, `shadow.py` is the per-source-file findings index (hash-keyed `.findings.md` mirror), `shadow_retroactive.py` (PR-116) is the reversible bulk migrator that seeds shadow stubs across every `my-axon/dev-projects/*`, `undo.py` restores any file or W: key from its rollback snapshot.

---

## 4. Per-Tool Entries

The entries below follow registry order, then category, then alphabetical for the utility tail. Each one: purpose, key signature, side effects, status, known issues.

### Kernel tools (24)

#### boot

`boot.py` parses the entire workspace state and emits one JSON boot context to stdout — paths from `WORKSPACE.md` STORE rules, longterm flags (`dev-mode`, `halt-mode`, `auto-improve`), active queue count, cron-overdue list, tool registry summary, workspace-federation `Inherits:` chain. Side effects: read-only.

```
python3 axon.py boot [--workspace PATH] [--axon PATH]
```

Status: ACTIVE. Three-tier config search (`.axon/` project-local → `workspace/` → `axon/` core).

#### memory

`memory.py` is the canonical W:/L:/E: scope front-door. `W:` = working (per-session; cleared on boot), `L:` = longterm (persistent; auto-snapshotted up to 3 versions), `E:` = episodic (append-only; never cleared). Side effects: writes (set/append) under `workspace/memory/<scope>/<key>.md`, atomic via `_axon_io.atomic_write`.

```
python3 axon.py memory <get|set|append|list|clear|rollback|history> --scope <W|L|E> [--key K] [--value V]
```

Status: ACTIVE.

#### log

`log.py` appends a formatted entry to `workspace/log/entries/YYYY-MM-DD.md`. Every entry passes through `redact.py` first; if matches fire, raw samples land in a gitignored sidecar under `my-axon/memory/local/`. Side effects: append to today's log file.

```
python3 axon.py log --level <DEBUG|INFO|WARN|ERROR|CRITICAL> --source NAME --msg "..."
```

Status: ACTIVE.

#### queue

Backed by `queue_tool.py`. Priority queue with !CRIT/!HIGH/!NORM/!LOW/!BG, concurrent-safe (`fcntl` exclusive lock on a sidecar `.lock` file), atomic via temp-file + `os.replace`. Side effects: writes `workspace/scheduler/queue.json`.

```
python3 axon.py queue <add|list|complete|remove> [--task ID] [--priority !NORM] ...
```

Status: ACTIVE.

#### index

`index.py` reads and writes `INDEX.md` tables (chats, plans, etc.) without manual markdown editing — `set-field`, `append-row`, `update-status`. Side effects: writes one INDEX.md.

```
python3 axon.py index <append-row|set-field|update-status> --file PATH --section NAME [...]
```

Status: ACTIVE.

#### checkpoint

`checkpoint.py` snapshots every `W:` key into a labelled JSON file and appends a row to `memory/episodic/session-log.md`. Side effects: writes the snapshot + appends one episodic row.

```
python3 axon.py checkpoint [--label NAME]
```

Status: ACTIVE.

#### process

`process.py` manages process lifecycle files at `workspace/processes/active/[P-NNN].md`. State machine: SPAWNED → RUNNING → PAUSED → COMPLETE/FAILED. Side effects: per-process .md write or status update.

```
python3 axon.py process <spawn|update|complete|fail|list|get> --id P-NNN --program NAME ...
```

Status: ACTIVE.

#### benchmark

`benchmark.py` records and reports compile cost ratios with model-priced cost-per-run. Hardcoded price table for `claude-sonnet-4-6`, `claude-opus-4-7`, `claude-haiku-4-5`. Side effects: appends to `workspace/memory/longterm/benchmark-log.md`.

```
python3 axon.py benchmark <record|list|stats> --workflow NAME --src-tokens N --cmp-tokens N ...
```

Status: ACTIVE.

#### lint-paths

`lint_paths.py` walks the shipping tree and flags hardcoded user-specific absolute paths — `/home/<user>/`, `/Users/<user>/`, `/mnt/<x>/<host>/`, `C:\Users\<user>\`. `my-axon/` is excluded (private user data). Side effects: read-only; exit 1 on any violation. Pre-commit and CI wired.

```
python3 axon.py lint-paths [--json]
```

Status: ACTIVE.

#### auto-audit

`auto_audit.py` is the append-only ledger of every auto-applied change. Storage: `my-axon/log/auto-edits/YYYY-MM-DD.md`, one markdown row per change, with sub-row carrying before/after excerpts (≤120 chars). Trust foundation for `L:auto-improve` opt-in.

```
python3 axon.py auto-audit <record|list|summary> --actor X --action Y --target Z [--days N]
```

Status: ACTIVE.

#### undo

`undo.py` restores a file or `W:` key from its rollback snapshot (PR-016). Translates `W:<key>` to `workspace/memory/working/<key>.md` automatically. Side effects: writes the restored file.

```
python3 axon.py undo --target <path> [--version N]
python3 axon.py undo --list <path>
```

Status: ACTIVE.

#### auto-improve

`auto_improve.py` is the daily orchestrator (PR-017). Three narrow auto-actions: `auto-compile` (programs ≥5 uses in last 7d → `compile rank --auto`), `auto-tune` (dispatch threshold ↑ when neg-rate > 30% over last 20 rows, bounded at 0.95), `auto-archive` (episodic > 30d to compressed annual archive). Every action wrapped in a `loop_receipt` context. Master gate: `L:auto-improve ≡ true` (default false).

```
python3 axon.py auto-improve [--dry-run] [--action <name>]
```

Status: ACTIVE.

#### programs-registry

`programs_registry.py` (PR-020) is the structured catalog at `workspace/programs/REGISTRY.json`. Schema: `name`, `file`, `compiled`, `status` (ACTIVE/DEPRECATED/STUB/DOC), `area`, `description`, `tools`, `last_modified`. Replaces the per-render filesystem scan that menu/find-program/list-tools previously did.

```
python3 axon.py programs-registry <generate|query|validate> [--area X] [--status X]
```

Status: ACTIVE.

#### compile

`compile.py` is the unified pipeline dispatcher (PR-007). Subcommands delegate to `compile-write.py`, `compile_suggest.py`, or `compile_optimizer.py` via subprocess (PR-019 will collapse to in-process imports). Subcommands: `format · rank · suggest · auto-compile · status · scan · optimize · verify · test-all · report · check-composition`.

```
python3 axon.py compile <subcommand> [args...]
```

Status: ACTIVE.

#### compile-write

`compile-write.py` (note the dash in the filename) is the format/write backing script. DEPRECATED — invoke as `compile format` instead. Reads `workspace/preferences/compile.md` for `gate-mode` / `ratio-ceiling` / `src-bytes-floor`, runs the gate, then writes the `.cmp.md` (atomic).

```
python3 axon.py compile format --name NAME --source SRC --ops OPS [--override]
```

Status: OPTIONAL (deprecation shim).

#### prefs

`prefs.py` aggregates all `workspace/preferences/*.md` into one JSON object; `set_pref()` atomically writes a single key into `runtime.md`. Side effects: writes runtime.md on `set`.

```
python3 axon.py prefs [<get|set>] [--key K] [--value V] [--file runtime.md]
```

Status: ACTIVE.

#### enforce

`enforce.py` is the machine-executable compliance gate. Three gates: `check-write` (actually `sys.exit(1)`s on `axon/` writes outside dev-mode), `check-arithmetic` and `check-source` (advisory only — stub no-ops). Side effects: exits with status code; emits JSON.

```
python3 axon.py enforce <check-write|check-arithmetic|check-source> --target PATH | --source SRC | --expression EXPR
```

Status: ACTIVE. **Known issues:** axon-polish finding F-D7-007 confirms `check-arithmetic` and `check-source` are advisory only — they print JSON and fall through without `sys.exit`, so callers using subprocess exit codes get `0` regardless of input. F-D7-007a flags an additional trivial bypass at `tools/enforce.py:73`: any `--source` value beginning with `user:` is treated as valid unconditionally.

#### test

`test.py` is the program structural validator — checks for `# PROGRAM:` / `# desc:` / `!PRIO` / `DONE()` / `▶ banner` / `## OUTPUT` and that `DONE(name)` matches the header program name. Side effects: read-only.

```
python3 axon.py test <program-file.md>
```

Status: ACTIVE.

#### run

`run.py` is the mechanical-op executor for compiled `.cmp.md` files. Loads `REGISTRY.json` once, scans each non-comment line for `TOOL/LOG/STORE/RETRIEVE/CLEAR/APPEND`, dispatches to the backing script. Returns control to the agent layer for `IF/EXEC/QUERY/ASSERT/LOOP` and semantic steps. Side effects: every side effect that the program declares; also writes an L: run manifest for undo support.

```
python3 axon.py run <path.cmp.md> [--input k=v ...]
```

Status: ACTIVE.

#### verify

`verify.py` is the verifier (§3.3). Three modes — `program <path>` (static), `output --text "..."` (runtime), `action --json '{...}'` (runtime) — plus `rules` to list registered rule modules. Exit codes: 0 pass / 1 violation / 2 internal error. Side effects: read-only.

```
python3 axon.py verify <program|output|action|rules> [path|--text|--json]
```

Status: ACTIVE.

#### drift

`drift.py` is the real edit-distance drift detector. Maintains `workspace/working/drift-trace.json` with `expected[]` (extracted from program), `actual[]` (recorded live), and a derived score (0.00-0.10 stable, 0.10-0.40 drift, 0.40+ diverged). The `gate` subcommand is fail-closed — missing/unparseable/stale traces return `state="unknown"` + `decision="halt"`.

```
python3 axon.py drift <init|record|check|reset|gate> --program PATH | --tool NAME
```

Status: ACTIVE.

#### axon-drift-log

`axon_drift_log.py` (PR-CA-102) is the append-only persona-bleed / cognition-frame violation ledger. JSONL at `workspace/log/drift/YYYY-MM-DD.jsonl`. Kinds: `persona-bleed`, `cognition-frame`, `missing-trace`, `other`. Companion to `axon-reanchor`.

```
python3 axon.py axon-drift-log <record|list|summary> --phrase "..." --kind X [--turn N]
```

Status: ACTIVE.

#### usage

`usage.py` is the append-only JSONL log of every program/command/tool invocation. Storage: `workspace/memory/longterm/usage-log.jsonl`. `top` returns the heaviest callers in a window; `suggest` flags compile candidates; `prune` drops entries older than N days. Auto-wired in `tools/run.py` so every program run gets recorded.

```
python3 axon.py usage <record|top|suggest|prune|aggregate> --kind K --name N [--window 7d|30d|all]
```

Status: ACTIVE.

#### health

`health.py` is the data-driven health-check runner. Iterates `REGISTRY.json`; for each ACTIVE entry, runs either a registered probe (see `PROBES` table inside `health.py`) or a smoke check (script exists + `--help` exits 0). Outputs JSON `{tools[], counts, score 0-100, label}`. Adding a tool to the registry surfaces it automatically.

```
python3 axon.py health [--workspace WS]
```

Status: ACTIVE.

### OS-category tools (28)

#### clock

`clock.py` returns a JSON timestamp object — `timestamp`, `iso`, `date`, `time`, `unix`, `source` (`ntp` or `system`). Tries `ntplib` against `pool.ntp.org`; falls back to local clock. Side effects: none.

```
python3 axon.py clock
```

Status: ACTIVE.

#### calculator

`calculator.py` safely evaluates math expressions via `simpleeval` — never `eval`. Whitelisted functions: `sqrt`, `abs`, `round`, `log`, `log10`, `log2`, `sin`, `cos`, `tan`, `ceil`, `floor`, `pow`, `exp`; constants `pi`, `e`. Optional `--vars` JSON dict for variable bindings.

```
python3 axon.py calculator "3.14159 * r ** 2" [--vars '{"r": 5}']
```

Status: ACTIVE.

#### tokenizer

`tokenizer.py` returns exact token counts via tiktoken `cl100k_base` (override via `--encoding`). Accepts `--text` inline or `--file` (repeatable for comparison). Reports tokens, words, chars, token/word ratio.

```
python3 axon.py tokenizer --text "..." | --file path.md [--encoding ENC]
```

Status: ACTIVE.

#### audit_compiled

`audit_compiled.py` (PR-2) walks `workspace/programs/compiled/*.cmp.md`, pairs each with source, computes byte + token ratios, classifies GREEN/YELLOW/RED/GREY against thresholds (`< 0.60 GREEN`, `< 0.85 YELLOW`, `> 0.85 RED`, `< 512 bytes GREY`), emits a markdown table + JSONL.

```
python3 axon.py audit_compiled [--threshold N] [--json]
```

Status: ACTIVE. **Known issues:** F-D3-007 — 82% of compiled outputs are byte-equal placeholders (auto-generated by PR-121 to satisfy `test_every_program_has_compiled_output`). The compiler subsystem produces meaningful output for only ~18% of the catalog.

#### migrate_meta

`migrate_meta.py` (PR-3) migrates a dev-project's `_meta.md` from v1 (free-form) to v4.1 (typed fields + canonical sections). Always backs up to `_meta.md.bak.<ISO>` before overwrite (keeps last 3). Idempotent on v4.1. Unknown sections preserved as `## CUSTOM/<name>`.

```
python3 axon.py migrate_meta <project> [--dry-run | --apply | --restore]
```

Status: ACTIVE.

#### rules

`rules.py` (PR-4) parses `workspace/safety/rules.md` into a typed list and exposes PRECEDENCE (kernel/identity → user-memory → AGENTS → safety/rules → inline `--rule` → legacy dont-do → workflow → defaults). PR-10 added `--strict` gating; PR-22 added audit (contradictions + dead-rule). Side effects: read-only.

```
python3 axon.py rules <load|evaluate|audit> [--strict] [--rule "id:..."]
```

Status: ACTIVE.

#### redact

`redact.py` (PR-5) exposes `redact(text) → (clean, hits)` plus a CLI. Patterns: `anthropic-openai`, `aws-access-key`, `github-token`, `jwt`, `token-assignment`, `key-assignment`, `password-literal`. `log.py` calls it on every entry.

```
python3 axon.py redact --text "..." | --file PATH
```

Status: ACTIVE.

#### scan_pre_push

`scan_pre_push.py` (PR-5) walks `git diff --cached -U0` and runs redact patterns over every added line; exits 1 on any hit. Wire as `.git/hooks/pre-push`. Honours `workspace/safety/redact-allowlist.md` glob lines.

```
python3 axon.py scan_pre_push
```

Status: ACTIVE.

#### session

`session.py` (PR-9) writes per-chat `_session.md` records with state-machine transitions (active/frozen/tagged/closed/recovered) and 20-turn auto-checkpoint cadence. Atomic writes via `_axon_io.atomic_write`.

```
python3 axon.py session <init|append|checkpoint|transition|list|recover> --chat-id ID ...
```

Status: ACTIVE.

#### pr_aggregate

`pr_aggregate.py` (PR-9.5) reads PR blocks from each `_meta.md` (v4.1 format with `slug/phase/state/last-program/updated`) and prints a cross-phase table or JSONL. Filters: `--state`, `--phase`, `--all-projects`, `--json`.

```
python3 axon.py pr_aggregate <list|summary> [--all-projects] [--state X] [--phase N]
```

Status: ACTIVE.

#### rename_snapshot

`rename_snapshot.py` (PR-12) captures `{program, desc, sections, status, exec_refs, registry_entry}` per program and diffs across renames. `--allow-rename old→new` whitelists intentional ones. Baseline snapshot lives at `tests/snapshots/programs-pre-rename.jsonl`.

```
python3 axon.py rename_snapshot <capture|diff|baseline> [--allow-rename old→new]
```

Status: ACTIVE.

#### plan_dag

`plan_dag.py` (PR-16.5) walks `<project>/03-prs/pr-*.md` for `**Depends-on**:` lines, runs Kahn's algorithm for acyclicity, computes the critical path, emits `DAG.md` (Mermaid + topo table) and `DAG.json`. Side effects: writes both DAG files.

```
python3 axon.py plan_dag --project PATH
```

Status: ACTIVE.

#### study_index

`study_index.py` (PR-17) maintains `<project>/study/_index.md`. Staleness thresholds (fresh ≤ 30d / warn ≤ 60d / stale ≤ 90d / strict-block > 90d). Consumed by `code-dev pr ready --strict` and `state next`. Idempotent appends.

```
python3 axon.py study_index <append|list|stale-for> --target NAME [--workspace WS]
```

Status: ACTIVE.

#### budget_lint

`budget_lint.py` (PR-20) asserts every `workspace/programs/code-dev*.md` declares the `# budget:` block (`input-cap`, `output-cap`, `cache-prefix`). PR-30 added per-mode coverage validation (study modes overview/subsystem/deep, plan modes tactical/strategic/operational/decision).

```
python3 axon.py budget_lint [--workspace WS]
```

Status: ACTIVE.

#### cd_cache

`cd_cache.py` (PR-20.5) bundles four code-dev caching sites: T-B1 session-scoped read cache (mtime-keyed, content-addressable), T-B2 resume-briefing cache, T-B3 `_reviewer-state.json` sidecar (atomic), T-B5 shadow LRU (in-process, max 32 entries). Emits `code-dev.cache.hit` / `.miss` events on the bus.

```
python3 axon.py cd_cache <get|put|stats|clear> --key K [--store T-B1|T-B2|T-B3|T-B5]
```

Status: ACTIVE.

#### board

`board.py` (PR-20.6) is an ASCII Kanban over `pr_aggregate` output. Five columns (`backlog`, `in-progress`, `blocked`, `ready-for-review`, `done`). Max width 200 chars.

```
python3 axon.py board [--project NAME]
```

Status: ACTIVE.

#### study_evals

`study_evals.py` (PR-20.7) iterates fixture codebases under `tests/fixtures/study-evals/<repo>/`, scores output against expected using structural match (Jaccard on H2 headings) and key-fact coverage (regex hits from `facts.json`). Writes JSONL to `my-axon/log/study-evals/<date>.jsonl`. Designed for opt-in human-driven runs.

```
python3 axon.py study_evals --repo NAME [--mode overview|subsystem|deep]
```

Status: ACTIVE.

#### idem_test

`idem_test.py` (PR-25) is the idempotence harness — runs a program twice over a copied fixture, normalizes whitespace + timestamps + versions, computes structural-overlap %. Advisory threshold 80% in W3; promoted to gate in W4.

```
python3 axon.py idem_test --program NAME --fixture PATH
```

Status: ACTIVE.

#### pr_sync

`pr_sync.py` (PR-28.5) pulls CI status via `gh pr checks <id> --json name,status,conclusion`. Graceful when `gh` is absent or times out. Reports `{pass, pending, fail}` counts.

```
python3 axon.py pr_sync --pr N
```

Status: ACTIVE.

#### pr_drift

`pr_drift.py` (PR-28.5) heuristically compares acceptance-checklist items (`- [x] item` lines in `PR-N.md`) against `git diff` (filename + function-name mentions). Flags unmet items.

```
python3 axon.py pr_drift --pr-spec PATH --repo PATH
```

Status: ACTIVE.

#### pr_export

`pr_export.py` (PR-28.5) writes a self-contained markdown packet for one PR — combines spec, current diff, reviewer-state if present. Atomic write.

```
python3 axon.py pr_export --pr-spec PATH --repo PATH --out PATH
```

Status: ACTIVE.

#### diff

Backed by `diff_tool.py`. File comparison with `--summary` (counts only) or `--unified` (full diff text). Pure stdlib (`difflib`).

```
python3 axon.py diff --file1 OLD --file2 NEW [--summary|--unified]
```

Status: ACTIVE.

#### validator

`validator.py` is JSON Schema validation via `jsonschema`. Inline data + schema or `--data-file` + `--schema-file`. Quick schema shortcuts: `--type object|array|string|number|boolean`.

```
python3 axon.py validator --data '...' --schema '...' | --data-file F --schema-file F
```

Status: ACTIVE.

#### notify

`notify.py` sends Slack webhook or SMTP email alerts. Configured via env vars (`SLACK_WEBHOOK_URL`, `SMTP_*`) or `workspace/memory/longterm/tool-notify-config.json`.

```
python3 axon.py notify --channel <slack|email> --to TARGET --message "..." [--subject S] [--priority high]
```

Status: ACTIVE.

#### kv-store

`kv_store.py` (alias `kv`) is the diskcache-backed fast K/V store at `workspace/memory/kv-store/`. Subcommands: `get`, `set`, `delete`, `list`, `exists`, `clear`.

```
python3 axon.py kv <set|get|delete|list|exists|clear> --key K [--value V] [--prefix P]
```

Status: ACTIVE.

#### document-parser

`document_parser.py` (alias `parse`) extracts text from PDF (PyPDF2) or DOCX (python-docx). Optional `--output` writes the extracted markdown to a target file.

```
python3 axon.py parse --file PATH.pdf [--output PATH.md]
```

Status: ACTIVE.

#### web-search

`web_search.py` (alias `web`, `search`) is the DuckDuckGo wrapper using the `ddgs` package (falls back to legacy `duckduckgo_search` import). No API key required.

```
python3 axon.py web --query "..." [--results 5] [--region wt-wt]
```

Status: ACTIVE.

#### translate

`translate.py` is the mechanical symbolic-to-prose translator — the default output translator for all normal agent responses. Operator table: `→`, `⊕` (and also), `⊗` (ERROR), `∅` (nothing), `✓`/`✗`, `↑` (escalate), etc. Modes: list (default) / prose / doc.

```
python3 axon.py translate --file PATH | --text "..." | --stdin [--format list|prose|doc]
```

Status: ACTIVE.

#### session-save

`session_save.py` (registered as `session-save`) writes `L:last-session-summary` and `L:last-session-snapshot` for reboot awareness. `restore` reads the snapshot and rewrites each `W:<key>` to disk (idempotent). Per-key cap: ~2 KiB — larger values skipped.

```
python3 axon.py session-save [--label LABEL]
python3 axon.py session-save restore
```

Status: ACTIVE.

### System-category tools (8)

#### shadow_retroactive

`shadow_retroactive.py` (PR-116) is the reversible bulk migrator. Walks every `my-axon/dev-projects/*` and emits shadow stubs for source-artefact files touched in past PRs. Modes: `plan` (dry-run), `apply` (live; writes stubs + manifest, optionally flips `L:shadow-enforcement-strict`), `undo` (byte-perfect restore from manifest). Writes confined to `<project>/shadow/`.

```
python3 axon.py shadow_retroactive <plan|apply|undo> [--projects-root DIR] [--manifest FILE] [--flip-strict]
```

Status: ACTIVE.

#### domain_validate

`domain_validate.py` (PR-106) walks `workspace/domains/*/manifest.md`, parses YAML front-matter, verifies the required-field set declared by `workspace/DOMAIN-MANIFEST.md` (schema v1). Exit 0 on full validity / 1 on failure / 2 on tool error.

```
python3 axon.py domain_validate <--all | --manifest PATH> [--json]
```

Status: ACTIVE.

#### synapse-infer

`synapse_infer.py` emits neuron-contract records per the v1.1 schema (`workspace/NEURON-CONTRACT.md`). Inputs: a program file (`--target`), a tool name (`--tool`), or `--all` for batch. Inference is heuristic + regex; declared `# synapse:` blocks override inferred fields. Output: one JSON record per call.

```
python3 axon.py synapse-infer <--target PATH | --tool NAME | --all> [--pretty]
```

Status: ACTIVE.

#### synapse-validate

`synapse_validate.py` validates a neuron-contract record (from `--file path.json`, `--stdin`, or `--all-corpus` walking `tests/synapse/corpus/*.contract.json`). Verifies required fields, glossary version, role/status enums, predicate syntax, next-conditional references. Exit 0 valid / 1 invalid / 2 usage error.

```
python3 axon.py synapse-validate <--file PATH | --stdin | --all-corpus>
```

Status: ACTIVE.

#### migrate-synapse-blocks

`migrate_synapse_blocks.py` (PR-108) is the one-shot bulk migrator. Walks every program in `workspace/programs/*.md`, calls `synapse_infer.infer_program`, inserts the inferred `# synapse:` block immediately after `# desc:` (or `# PROGRAM:` if `# desc:` is absent). Programs already carrying a `# synapse:` block are skipped — idempotent.

```
python3 axon.py migrate-synapse-blocks [--dry-run] [--only NAME]
```

Status: OPTIONAL (one-shot migration; can be removed once applied).

#### predicate

`predicate.py` (PR-102) is the parser + AST + evaluator for AXON predicate language v1.1. Hand-rolled recursive-descent parser (pure stdlib). Shared substrate for goal/synapse/workflow gates. `eval` takes `--expr` + `--ctx` (JSON). Safe-null mode returns `null` for undefined refs.

```
python3 axon.py predicate eval --expr "<expr>" --ctx '<json>'
```

Status: ACTIVE. **Known issues:** axon-polish finding (iteration 2) flags `goal.*` family functions as not registered in BUILTINS — `predicate eval --expr "goal.acceptance.met()" --ctx "{}"` returns `null` (safe-null), which causes acceptance/rejection criteria in workflows to silently bypass.

#### goal

`goal.py` (PR-103) creates/inspects/audits goal records per goal-schema-v1, at the seven levels: project, phase, workflow, step, pr, finding, demand. Index lives at `workspace/memory/goals.yml`. `audit` traverses a project and reports MET vs UNMET goals per level.

```
python3 axon.py goal <set|get|confirm|list|met|audit> --id ID [--level L] [--statement "..."]
```

Status: ACTIVE.

#### dag

`dag.py` (PR-110) authors, mutates, verifies, renders, and syncs DAG files at all 5 levels of the dag-spec-v1. Canonical: `DAG.json`. Rendered mirror: `DAG.md`. Reversible mutations: `merge`, `split`, `fold-in`, plus the standard `add-node/edge`, `remove-node/edge`, `set-status`. `migrate` adds `schema-version: v1` in-place if absent.

```
python3 axon.py dag <bootstrap|add-node|add-edge|remove-node|remove-edge|merge|split|fold-in|set-status|render|verify|sync|migrate> [args]
```

Status: ACTIVE.

### Synapse-category tools (2)

#### synapse-suggest

`synapse_suggest.py` (PR-109) ranks candidate synapses for the next step. Implements `rank-candidates(state, goal, history)` from `orchestrator-composition-v1` — 11 weighted signals (intent, dispatch, usage, pattern, next-conditional, goal-alignment, context-pressure, drift, igap, shadow, cost) with FL-04 6-level tie-break ladder, FL-05 TF-IDF zero-candidate fallback, FL-07 20-fire frequency-prior cold-start. Stdlib-only.

```
python3 axon.py synapse-suggest --state PATH --goal PATH [--candidates PATH | --registry PATH] [--top N] [--explain]
```

Status: ACTIVE.

#### loop-receipt

`loop_receipt.py` (PR-AUTO-201) is the two-phase commit ledger for autonomous-loop side-effects. Receipt lifecycle: `begin → (commit | rollback | abort)`. Ledger lives at `axon/state/loop-receipt.ledger.jsonl`. Writes use `_axon_io.atomic_append` with `_actor="loop-receipt"` which the chokepoint whitelists so the substrate can write without requiring dev-mode (the ledger IS the per-write audit trail). `recover` reaps orphaned BEGUN rows at boot.

```
python3 axon.py loop-receipt <begin|commit|rollback|abort|show|list|verify|gc|recover> [...]
```

Status: ACTIVE.

### Audit-category tools (2)

#### call_graph

`call_graph.py` (PR-31.5) walks `workspace/programs/code-dev*.md`, extracts `EXEC(code-dev-NAME)` references, builds a DAG, runs Kahn's algorithm for cycle detection, reports longest path (capped at depth 10). Self-cycles also flagged.

```
python3 axon.py call_graph [--workspace WS] [--json]
```

Status: ACTIVE.

#### docgen_verify

`docgen_verify.py` (PR-34) cross-ref lints every `workspace/AXON-DOCS-*.md`. Verifies every referenced program path resolves to a real file under `workspace/programs/`. PR-T01 extension: A-tier docs (`README.md`, `CONTRIBUTING.md`, `AGENTS.md`, `CHANGELOG.md`) MUST NOT mention deprecated subsystems (semantic-search, chromadb, sentence-transformers, torch). `--strict` flag in CI fails on stale terms.

```
python3 axon.py docgen_verify [--strict] [--all-projects]
```

Status: ACTIVE.

### Documentation-category tools (2)

#### docgen

`docgen.py` is the kitchen-sink documentation generator — scans kernel + programs + tools + memory, emits `AXON-DOCS.md` with Mermaid diagrams (architecture, dependency graph), program catalog, tool registry, memory scopes, relationship maps.

```
python3 axon.py docgen [--workspace WS] [--axon DIR] [--output PATH]
```

Status: ACTIVE.

#### cheatsheet_gen

`cheatsheet_gen.py` (PR-34.5) walks `workspace/programs/code-dev-*.md`, reads each `# desc:`, and rewrites the AUTO-VERBS table between `<!-- AUTO-VERBS-START -->` and `<!-- AUTO-VERBS-END -->` markers in `AXON-DOCS-CHEATSHEET.md`. Atomic write.

```
python3 axon.py cheatsheet_gen [--workspace WS]
```

Status: ACTIVE.

### Code-dev-category tools (1 — shadow)

#### shadow

`shadow.py` is the per-source-file findings index. Maintains a per-project shadow directory mirroring the codebase structure. Each file gets a `.findings.md` with git-hash, summary, structures, dependencies, arch-role, append-only findings log. AXON checks shadow before reading any source file — zero re-analysis tokens if hash matches. Sections: `summary | structures | dependencies | arch-role | findings`.

```
python3 axon.py shadow <check|hash|init|append|list|stats|stale> [--file F] [--shadow-dir D] [--section S]
```

Status: ACTIVE.

### Kernel-category event/cron/dispatch tools (10 — listed individually)

#### events

`events.py` (PR-006) is the unified EMIT/ON event bus + hook registry. Bus: `emit · listen · log · clear`. Hooks: `hook-add · hook-list · hook-remove · hook-fire · hook-enable · hook-disable`. Hook action types: `notify` (calls notify.py), `log` (appends via log.py), `exec` (runs a program via run.py). Storage: `workspace/events/event-log.json`, `workspace/events/hooks.json`.

```
python3 axon.py events emit --event NAME [--payload JSON]
python3 axon.py events hook-add --event NAME --hook-action <notify|log|exec> --target ARG
```

Status: ACTIVE.

#### simulate

`simulate.py` dry-runs a program with shadow writes and stub tools — same op patterns as `run.py` but no real side effects. Records what WOULD happen; flags irreversible ops (`WRITE`, `APPEND(E:...)`). Useful before live runs.

```
python3 axon.py simulate <run|check> --program NAME [--input k=v]
```

Status: ACTIVE.

#### cron

`cron.py` adds/lists/checks/runs/removes recurring program jobs. Schedule formats: `daily HH:MM`, `weekly WEEKDAY HH:MM`, `hourly`, `interval Nm`. Circuit breaker disables jobs after N consecutive failures (default 3; auto-disable at 5 boot-time). Storage: `scheduler/cron.json` (with `fcntl` lock). Tick budget 30s. Events sidecar at `memory/local/cron-events.jsonl`.

```
python3 axon.py cron <add|list|check|run|remove> --program NAME --schedule "daily 09:00" --id JOB-ID
```

Status: ACTIVE.

#### pack

`pack.py` packs/unpacks `.axon` ZIP bundles for program sharing. Manifest fields: name, version, author, description, created, files[]. Subcommands: `pack`, `unpack`, `inspect`. Optional `--include-prefs` bundles preferences.

```
python3 axon.py pack <pack|unpack|inspect> --program NAME | --file PATH.axon [--dest DIR] [--out PATH]
```

Status: ACTIVE.

#### deps

`deps.py` is the program dependency graph from static analysis of `EXEC()`, `TOOL()`, and `READ()` calls — no execution. Subcommands: `show` (direct deps), `tree` (recursive), `check` (flag broken/missing), `graph` (DOT / JSON output).

```
python3 axon.py deps <show|tree|check|graph> --program NAME [--depth N] [--format dot|json]
```

Status: ACTIVE.

#### hooks

`hooks.py` is a one-release deprecation shim that translates legacy `hooks <add|list|remove|fire|enable|disable>` calls to the new `events hook-*` form. Emits a `⚠ DEPRECATED` warning on stderr. Marked for removal next release.

```
python3 axon.py hooks <add|list|remove|fire|enable|disable> ...
```

Status: OPTIONAL.

#### context

`context.py` is the token-pressure estimator. Levels: low (<30%) / medium (30-60%) / high (60-85%) / critical (>85%). Defaults to 128 K context limit. Tracks session-accumulated estimate at `working/`.

```
python3 axon.py context <estimate|pressure|status|record|reset> --text "..." | --file PATH | --tokens N
```

Status: ACTIVE.

#### prompt-log

`prompt_log.py` (opt-in via `L:prompt-log-enabled`) captures raw user inputs to `workspace/memory/episodic/prompt-log.jsonl` for `pattern.py` clustering. Subcommands: `record`, `list`, `stats`, `enable`, `disable`, `clear`.

```
python3 axon.py prompt-log <record|list|stats|enable|disable|clear> --prompt "..." [--session S]
```

Status: ACTIVE.

#### pattern

`pattern.py` clusters prompt-log entries using TF-IDF + cosine similarity (sklearn). Falls back gracefully if sklearn absent. Subcommands: `cluster` (group recurring prompts), `top` (top hashes with representative text), `suggest` (programs to compile based on clusters). Default threshold: 3 occurrences.

```
python3 axon.py pattern <cluster|top|suggest> [--window 7d|30d|all] [--threshold N] [--clusters N]
```

Status: ACTIVE.

#### compile-suggest

`compile_suggest.py` is the legacy unified "what should I compile?" surface. Merges `usage suggest` + `pattern suggest` into one ranked list with token-savings estimates. DEPRECATED — use `compile rank` / `compile auto-compile` / `compile status`. The script remains for back-compat.

```
python3 axon.py compile-suggest <suggest|compile|status> [--threshold N] [--auto]
```

Status: OPTIONAL.

#### dispatch

`dispatch.py` is the smart-dispatch matcher — TF-IDF cosine similarity against `workspace/memory/longterm/dispatch-index.json` (populated by `compile_suggest.py` as programs are compiled). Policy from `preferences/smart-dispatch.md`: `dispatch-confidence: 0.65` (default), `dispatch-fallback: agent`. Action shape: `{"action": "dispatch", "program": "...", "confidence": 0.87}` or `{"action": "fallback", ...}`.

```
python3 axon.py dispatch <match|index|feedback> --query TEXT [--threshold F]
python3 axon.py dispatch index <list|add|remove> --program P [--desc D]
python3 axon.py dispatch feedback --id ID --result <yes|no>
```

Status: ACTIVE.

#### dispatch-stats

`dispatch_stats.py` (PR-19) is the weekly savings summary + precision metric. `summary` reads `usage-log.jsonl` and `dispatch-feedback.jsonl` for dispatches/tokens-saved/accuracy/top-programs. `precision` computes P@1 / P@3 against the PR-18 corpus and writes daily JSON to `my-axon/log/dispatch-metrics/`.

```
python3 axon.py dispatch-stats <summary|savings|precision> [--window 7d|30d|all]
```

Status: ACTIVE.

#### axon-audit

`axon_audit.py` is the self-audit engine. Section 1a (structural integrity): boot chain, tool registry vs scripts, internal cross-refs (EXEC/TOOL/READ across all programs), core file inventory, memory/workspace directory structure. Section 1b (usefulness): health score, compilation coverage, dispatch readiness, active plans/chats, token savings potential.

```
python3 axon.py axon-audit [--section 1a|1b|all] [--format json|text]
```

Status: ACTIVE.

#### compile-optimizer

`compile_optimizer.py` is the legacy systematic compilation coverage engine. Subcommands: `scan` (ranked candidates), `verify` (test + simulate a compiled program), `test-all`, `report`, `check-composition` (find re-invention / delegation debt). DEPRECATED — use `compile scan/verify/test-all/report/check-composition`. The script remains.

```
python3 axon.py compile-optimizer <scan|verify|test-all|report|check-composition> [args]
```

Status: OPTIONAL.

#### rtk

`rtk.py` is a graceful stub for the optional external RTK (Retrieval-Tuned Kernel) token-optimizer CLI. If `rtk` is on PATH, forwards all args. Otherwise returns `{"status": "not_installed", "note": "..."}` so `health.py` can probe without erroring.

```
python3 axon.py rtk [...]
```

Status: OPTIONAL.

#### test-runner

`test_runner.py` wraps pytest over `tests/`. Suites: `unit` (`test_tools_core.py` + `test_tools_kernel.py`), `regression` (`test_programs_md.py` + `test_compiled_regression.py`), `integration` (`test_integration.py`), `kernel` (`test_tools_kernel.py`), `all` (everything). `list` enumerates discovered test IDs. `last` shows the cached last result.

```
python3 axon.py test-runner <run|list|last> [--suite all|unit|regression|integration|kernel] [--fail-fast]
```

Status: ACTIVE.

### Kernel `igap` (one entry)

#### igap

`igap.py` is the inference gap tracker. Records turns where the LLM had to infer rather than find explicit instructions. Gap types: `low-confidence`, `semantic-search`, `fallback-exec`, `absent-instruction`. Append-only logs at `workspace/log/igap/YYYY-MM-DD.md`. Accumulates dedup'd improvement suggestions. Runs at `!BG` priority — zero interrupt to active tasks. Wrapped in `loop_receipt` context manager.

```
python3 axon.py igap <record|report|stats|clear> --type TYPE --context CTX --missing WHAT --suggestion HOW [--days N]
```

Status: ACTIVE.

### Host-category tool (1)

#### shell

`shell` has no Python file — it is host-dispatched. Programs reference `TOOL(shell, "<bash snippet>")` for git/fs operations; the host harness fulfils the call at runtime by running the snippet in a sandboxed subprocess. The registry entry exists explicitly so `R_TOOL_EXISTS` lets calls through (since `OPTIONAL` is permitted).

Status: OPTIONAL. See §6 for the security implications.

---

## 5. The `shell` Special Case

`shell` is the one tool in the registry that has no backing Python script — `tools/shell.py` does not exist on disk. The registry declares it as:

```
"shell": {
  "script": "tools/shell.py",
  "status": "OPTIONAL",
  "category": "host",
  "purpose": "Host shell passthrough — dispatched by the host harness, no Python script.
              Programs reference TOOL(shell, ...) for git/fs snippets; the harness
              fulfils them at runtime."
}
```

The host harness (Claude Code, Cursor, GitHub Copilot, etc.) is expected to recognise `TOOL(shell, ...)` calls and route them through whatever bash/exec capability the harness exposes. AXON itself never runs the command — it appears in the compiled output, the harness sees it, the harness runs it. This is the only tool where the AXON Python layer is explicitly NOT the executor.

### Why it exists

The design rationale: AXON ships portable across harnesses. Different harnesses have different sandboxing models, different bash capabilities, different working-directory semantics. Rather than pick one and lose the others, `shell` is declared as a contract: "if a program emits `TOOL(shell, <snippet>)`, the harness is responsible for running `<snippet>` in a shell and returning the result." Each harness adapts its own model to that contract. AXON's verifier just confirms the call is well-formed and the registry entry exists.

### Usage footprint

The axon-polish iteration-2 reconciliation (`_flaws.md`) counts **139 `TOOL(shell, ...)` total occurrences across 61 unique programs**, including 2 in `axon/` kernel/programs. The audit originally under-reported at 88/33 — actual call-site footprint is 58% larger than first reported. Even AXON's identity boot G-11 invokes `TOOL(shell, ...)` for git branch detection — boot itself depends on the host fulfilling the call.

### F-D8-008 — gate evasion (BLOCKER)

The axon-polish flaws ledger (`_flaws.md:469-472`) records F-D8-008 as the master gate-evasion vector:

> Once an agent emits `TOOL(shell, "rm -rf workspace/memory/")` or `TOOL(shell, "cp x axon/y")`, no rule fires. R9 only inspects WRITE/APPEND ops; R9 `_is_axon_path` uses `p.lstrip("./")` not `os.path.realpath()`, verified at `tools/rules/r9_axon_write.py:29-31`.
>
> Every axon/-protection collapses if shell pass-through is permitted.

There is no `tools/shell.py` for `R_TOOL_EXISTS` to flag (it only blocks `PLANNED` status), and `OPTIONAL` is whitelisted explicitly. The kernel write-gate `enforce check-write` is bypassed because `shell` writes don't go through AXON's `WRITE` op at all — they go through whatever path the host's bash invocation uses. Symlink prefix tricks and `realpath` divergence also bypass R9's string-prefix check.

This is a structural finding, not a fixable rule edit — eliminating `shell` would require migrating every git/fs operation to a dedicated registered tool (e.g. `git_status.py`, `git_branch.py`, `fs_copy.py`) with proper gating. The axon-polish masterplan tracks this as a wave-3 polish item; pre-PR-A-series the recommended interim mitigation is to extend R9 to inspect `TOOL(shell, ...)` payloads via regex for paths matching `axon/` (or whatever pattern), but the symlink-bypass + realpath divergence remain unsolved by string matching alone.

### Where `shell` fires today

A non-exhaustive list of call sites, by category, based on the axon-polish reconciliation:

| Category                          | Approximate count | Notable programs |
|-----------------------------------|-------------------|------------------|
| Git branch / status detection     | ~30               | boot G-11, `code-dev-branch`, `code-dev-pr-respond` |
| Git diff for review / PR export   | ~25               | `pr_drift.py` calls via the tool, `code-dev-pr-list`, `code-dev-self-review` |
| File system inspection (`ls`, `find`) | ~20           | menu, `code-dev-search`, `code-dev-tour` |
| Process control / kill            | ~10               | safety programs, `code-dev-freeze` |
| Pipe combinators (`wc -l`, `grep | head`) | ~25      | discovery and counting programs |
| Build / test invocation           | ~15               | `code-dev-suggest-tests`, integration tests harness |
| Misc (`echo`, `cat`, `cp`, `mv`)  | ~14               | examples in docs, scaffold helpers |

The 139 total is a lower bound — programs sometimes embed `TOOL(shell, ...)` inside conditional blocks the static count cannot detect. The 61 unique programs span the entire `code-dev-*` family, the system kernel, and even the identity/boot path.

---

## 6. Unregistered Tools on Disk

Two Python files in `tools/` are not registered in `REGISTRY.json`:

### audit_axon_lang.py

Scans `workspace/programs/*.md` (and `tools/*.py`) for AXON-LANG primitives (`NAME(` tokens where NAME is ALL-CAPS or kebab-uppercase) and reports which are USED vs. IMPLEMENTED. The implementation registry is inferred from `axon/OUTPUT-LAYER.md` (fenced code + definitions), `axon/tools/*.py` (`TOOL(name, ...)` where name matches a Python file), and `axon/KERNEL-SLIM.md` (core ops listed). Outputs CSV + markdown summary.

Referenced in CHANGELOG.md and WORKFLOW.md but never added to the registry. Cannot be invoked via `TOOL(...)`, has no `health.py` smoke probe.

```
python3 tools/audit_axon_lang.py [--json out.json]
```

### lint_commit_trailer.py

The commit-msg linter for the axon-synapse project rule: every commit MUST trail `Co-authored-by: AXON <axon@arturcastiel.github.io>` and MUST NOT credit any harness (Copilot, Claude Code, Cursor, GitHub Copilot) as co-author. Invoked by pre-commit at the `commit-msg` stage with the commit-message file path as `argv[1]`. Exit 1 on missing trailer or forbidden co-author.

```
python3 tools/lint_commit_trailer.py <commit-msg-file>
```

### F-D7-002 — Tool registry vs disk

The axon-polish flaws ledger (`_flaws.md`) records F-D7-002:

> Tool registry vs disk: 2 unregistered tools on disk. `audit_axon_lang.py`, `lint_commit_trailer.py`. Referenced by README:251, CHANGELOG:398, WORKFLOW.md:575 — clearly real tools that drifted out of registry. No smoke probe (health.py iterates registry); cannot be called via `TOOL(...)`.

Both should be either added to the registry or removed from disk. They are unreachable through the standard invocation path but still maintained as part of the shipping tree.

---

## 7. Tools Cited in CHANGELOG but Missing from Registry

A scan of `axon/CHANGELOG.md` against `REGISTRY.json` surfaces a few names that appear in changelog prose but have no current registry entry. Most resolve to references to deprecated or unfinished tools:

- **`semantic-search`** — referenced as an alias in `axon.py` (`ALIASES = {..., "search": "semantic-search", ...}`) but the registry has no `semantic-search` entry. The alias resolves to nothing — calling `python3 axon.py search ...` errors with "Unknown tool 'semantic-search'". F-D3-008 in axon-polish records that 10 stale `semantic-search` references survive in compiled outputs (`workspace/programs/compiled/code-dev-plan.cmp.md:44,46` and 8 others); the tool was deprecated in axon-cleanup wave 2 but compileds never re-emitted. The `ALIASES` entry in `axon.py` itself is dead weight — should be removed.
- **`tools/workflow_test.py`** — DEV-001 in CHANGELOG: "PR-005 (`tools/workflow_test.py`) dropped per 'no new tool'". The decision was made to keep new gating-as-test out of a separate tool — work folded into the rules engine. No file exists.
- **`tools/test.py` legacy invocation shape** — CHANGELOG: "the legacy `tools/test.py` invocation shape (used to run ~10 of 315 cases) — replaced by full `pytest tests/` in PR-001". The `test.py` file remains and is registered, but its scope shrank from "test runner" to "program structural validator" (header / desc / priority / DONE / banner checks).
- **`hooks.py`** — registered as OPTIONAL with status "DEPRECATED — alias for events tool. Use `events hook-add/list/remove/fire/enable/disable`. Shim removed next release." Still discoverable via `axon.py help`. Emits a deprecation warning to stderr on every invocation, but otherwise translates legacy `add/list/remove/fire/enable/disable` calls to the new `hook-*` form transparently.
- **`compile-suggest`, `compile-optimizer`, `compile-write`** — all three are registered OPTIONAL with DEPRECATED purpose strings pointing users to the unified `compile` tool. Backing scripts retained for one release; `compile.py` subprocess-invokes them today, PR-019 will collapse to in-process imports and let these files go.

The registry's `description` field calls out the schema invariants but does not (yet) emit deprecation warnings for the legacy entries when surfaced through `axon.py help` — only the prose in `purpose` flags them. A future enhancement could add a `deprecated_at` field per entry and surface "warning: deprecated since v3.4.0" in `axon.py help`.

### CHANGELOG citation patterns

The CHANGELOG follows a few patterns when introducing tools:

- `**PR-NN** Some name — `tools/foo.py` + `code-dev-xxx.md` ...` — the tool was added with a companion program.
- `(`tools/bar.py` gains a `baz` subcommand)` — existing tool extended; check `argparse` choices to confirm.
- `Removed: `tools/qux.py``  — file was deleted; registry entry should also be gone.

The CHANGELOG also references planned PRs that may have introduced and removed tools mid-stream. Searching for `tools/` references in CHANGELOG.md and cross-checking against `REGISTRY.json` is left as the canonical drift-detection task. A future helper script could enforce this — every `tools/X.py` mention in CHANGELOG.md should resolve to either an existing registry entry or an explicit "removed in PR-NN" line.

### The cross-check matrix

For thoroughness, here is a small matrix of every CHANGELOG-referenced tool versus its current registry status:

| Tool name (CHANGELOG)    | Registry status      | File on disk | Notes |
|--------------------------|----------------------|--------------|-------|
| `audit_axon_lang.py`     | NOT REGISTERED       | yes          | F-D7-002; referenced in README/WORKFLOW |
| `lint_commit_trailer.py` | NOT REGISTERED       | yes          | F-D7-002; pre-commit `commit-msg` stage |
| `workflow_test.py`       | NOT REGISTERED       | no           | DEV-001: dropped per "no new tool" |
| `semantic-search`        | NOT REGISTERED       | no           | alias rot; 10 stale refs in compileds |
| `compile-write`          | OPTIONAL (deprecated)| yes          | use `compile format` |
| `compile-suggest`        | OPTIONAL (deprecated)| yes          | use `compile rank/auto-compile/status` |
| `compile-optimizer`      | OPTIONAL (deprecated)| yes          | use `compile scan/verify/test-all/...` |
| `hooks.py`               | OPTIONAL (deprecated)| yes          | use `events hook-*` |
| All other CHANGELOG-mentioned tools (audit_compiled, migrate_meta, redact, scan_pre_push, session, pr_aggregate, rename_snapshot, plan_dag, study_index, budget_lint, cd_cache, board, study_evals, idem_test, pr_sync, pr_drift, pr_export, call_graph, docgen_verify, cheatsheet_gen) | ACTIVE | yes | well-aligned |

In total, 4 names in the CHANGELOG don't appear in the registry. Two have a backing script and should arguably be added (`audit_axon_lang.py`, `lint_commit_trailer.py`). Two are pure ghosts and should be expunged from any remaining references (`workflow_test.py`, `semantic-search`).

---

## Appendix A — Helper Modules (not registered, callable via import only)

A handful of `tools/_axon_*.py` files are imported by other tools but never registered themselves:

| File                  | Purpose                                                                                   |
|-----------------------|-------------------------------------------------------------------------------------------|
| `_axon_paths.py`      | `AXON_ROOT` resolution (`__file__`-anchored or `$AXON_ROOT`); `default_workspace()`, `under_workspace()`, `MYAXON_ROOT`. The lint-paths discipline depends on every tool routing through here. |
| `_axon_io.py`         | `atomic_write(path, text)`, `atomic_write_json(path, obj)`, `atomic_append(path, line, _actor=...)`. Loop-receipt's chokepoint whitelist keys off `_actor`. |
| `_axon_response.py`   | Canonical JSON envelope helpers — `ok(...)`, `fail(...)`, `emit(...)`. PR-007 + ongoing migration. |
| `_axon_rollback.py`   | `snapshot(target)`, `restore(target, version)`, `list_snapshots(target)`, `w_key_path(workspace, key)`. Backs `memory.py` history and `undo.py`. |
| `_axon_lib.py`        | Small utilities reused across tools (kept tiny so `auto_improve.py` and friends don't grow import graphs). |
| `_loop_receipt_ctx.py`| `with loop_receipt(actor=..., intent=..., target_kind=..., scope=..., key=..., pre_value=..., post_value=..., rationale=..., trigger=(...)) as rcpt` — the Python context-manager wrapper around `loop_receipt.py`. In-process (no subprocess) so exceptions inside loop_receipt itself propagate naturally. |

These are imported via `sys.path.insert(0, str(Path(__file__).parent))` at the top of each tool. They define authoring conventions: every new tool should use the canonical envelope, atomic writes, and `_axon_paths.default_workspace()` resolution.

---

## Appendix B — Status Distribution (registry-level)

| Status   | Count | Notable entries |
|----------|------:|-----------------|
| ACTIVE   |   79  | the bulk of the registry — all kernel, OS, system, synapse, audit, docs, code-dev tools |
| OPTIONAL |    7  | `compile-write`, `hooks`, `compile-suggest`, `compile-optimizer`, `rtk`, `migrate-synapse-blocks`, `shell` |
| PLANNED  |    0  | none in v3.7.0; the `R_NO_PLANNED_TOOLS` rule is a defensive guard for future churn |

Categories: `kernel` (~30), `os` (~28), `system` (8), `synapse` (2), `audit` (2), `documentation`/`docs` (2), `code-dev` (1), `host` (1).

---

## Appendix C — Tool Categories vs. Documentation Tier

The kernel-slim doc says nothing about category — only ACTIVE/OPTIONAL/PLANNED. The `category` field in registry entries is for human navigation and for the future docgen output, not for any gate. A program calling `TOOL(predicate, eval, ...)` doesn't care that `predicate` is `category: synapse`.

Categories observed in the registry (v3.7.0):

| Category        | Function                                                                                         |
|-----------------|--------------------------------------------------------------------------------------------------|
| `kernel`        | core boot/run/memory/queue/checkpoint plus compile, dispatch, drift, verify, audit, events       |
| `os`            | OS-style utilities — clock, calculator, tokenizer, lint, redact, session, validator, notify, etc.|
| `system`        | newer-vintage system tooling — domain validation, synapse blocks, dag, predicate, goal, shadow-retro |
| `synapse`       | the two synapse-classified entries that carry the v1.1 neuron-contract block — `predicate`, `goal` |
| `audit`         | call-graph, docgen-verify                                                                        |
| `docs` / `documentation` | docgen, cheatsheet_gen                                                                  |
| `code-dev`      | shadow (the only one tagged this way in registry; many code-dev tools live under `os`)           |
| `host`          | `shell` only                                                                                     |

The category split is loose — `compile-write` lives in `kernel`, `audit_compiled` in `os`, even though both touch the compile pipeline. Treat the category as a hint for navigation, not a contract.

---

## Appendix D — Conventions for New Tools

Patterns observed across the 86 registered tools that any new entry should follow:

1. **Backing-script location**: `tools/<name>.py` (kebab in registry, snake in filename when needed — `kv-store` → `kv_store.py`, `migrate-synapse-blocks` → `migrate_synapse_blocks.py`).
2. **Docstring at module top**: purpose line, usage examples, subcommand list, storage paths, optional schema definitions.
3. **`argparse` subparsers** for multi-action tools; flat `argparse` for single-action utilities.
4. **JSON output by default**: every tool prints one JSON object to stdout (with `ok` / `fail` envelope via `_axon_response`); human-readable text via `--format text` where useful.
5. **Path resolution via `_axon_paths`**: never hardcode `/home/<user>/` or `/Users/<user>/` paths — `lint_paths.py` will fail the CI.
6. **Atomic writes via `_axon_io.atomic_write`** for any mutation; never trust an interrupted Python interpreter to leave a file consistent.
7. **Exit codes**: `0` success, `1` validation failure, `2` internal/usage error. Compliance gates that need to halt actually `sys.exit(1)` (cf. F-D7-007 — `enforce` check-arithmetic and check-source do *not* exit).
8. **Health probe**: optional `health` field in the registry entry with `probe` and `expect`; absent => `health.py` falls back to script-exists + `--help` smoke check.
9. **Concurrent-safe state**: anything writing shared JSON should use `fcntl` exclusive lock + temp-file + `os.replace` (cf. `queue_tool.py`, `cron.py`).
10. **Side effects through `loop_receipt`** if the tool participates in autonomous loops (`auto_improve`, `igap`, `dispatch-feedback`).

---

## Appendix E — Related Reference Material

- `axon/KERNEL-SLIM.md` §TOOLS (lines 470-480) — the authoritative kernel statement.
- `axon/CHANGELOG.md` — PR-007 (compile dispatcher), PR-006 (events/hooks merge), PR-009 (session), PR-016 (rollback/undo), PR-017 (auto-improve), PR-020 (programs-registry), PR-031.5 (call_graph), PR-034 (docgen_verify), PR-103 (goal), PR-108 (synapse-blocks), PR-110 (dag), PR-116 (shadow-retroactive), PR-AUTO-201 (loop-receipt).
- `tools/rules/` — the ten kernel rule predicates that gate compile + runtime.
- `tools/REGISTRY.json` — the canonical source of truth (read it whenever this doc disagrees).
- `my-axon/dev-projects/axon-polish/_flaws.md` — exhaustive ledger of known issues, including F-D8-008 (shell gate evasion), F-D7-007 (enforce stubs), F-D3-007 (placeholder compileds), F-D2-005 (alias rot), F-D7-002 (unregistered tools).

---

*Generated for the AXON-REFERENCE library. Read-only reference. When in doubt, the registry wins.*

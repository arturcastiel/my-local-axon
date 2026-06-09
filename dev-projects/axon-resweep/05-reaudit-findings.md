# Re-MEGA findings — 2026-06-04 (owner: "redo the mega audit, autonomous, same workflow")

Second-pass adversarial sweep over CURRENT AXON (now carrying all this session's fixes). 3 agents:
regression-verify (the session's fixes) + deep tools/rules + deep programs/kernel. Each finding grounded by
running the code (exit codes / wrong output shown). → phase 2-reaudit-fixes.

## Regression-verify: ALL session fixes HOLD end-to-end (no regression)
Verified live (ran run_changeset, the hook, the tools): breaker recorder + anchored id; cadence run_active +
fail-closed; gate-rule _meta coverage + first-token status + W:myaxon-path; R9-before-persona (fresh-clone
axon/ Edit → DENIED); lint exact-trailer + range fail-closed; program subcommands; synapse _load_json inline;
rules_loader; crucible per-control timeout; OUTPUT-LAYER 3; harness override. **No NEW bug breaks a fix.**

## Findings (ranked; file:line · fix) → PR grouping
### HIGH
- **F-LIVE [HIGH] `tools/liveness.py:76` orphan-gate self-blinded** — `_surfaces()` uses
  `exclude_basenames=set()`, so each tool is checked against a corpus containing ITS OWN file → a self-
  reference reads as "reached" → the BLOCK orphan-gate passes with **10 real ACTIVE orphans** (apply-host-
  wiring, apply-memory-slot, axon-trace, deprecation-log, domain_validate, dual-agent-eval, lint-code,
  onboarding, project-graph, workflow-dag). Fix: per-tool corpus excluding own basename (mirror
  r_no_orphan_tools). NOTE: surfaces 10 orphans → each needs wiring / allowlist / OPTIONAL-demotion. → **PR-2E** (own PR; involved)
- **F-KCTX [HIGH] `axon/KERNEL-SLIM.md:308-321` context-pressure gate reads fields `context status` never
  returns** — branches on `pressure.level/pct/tokens`; `context.py status` returns
  `pressure/percent/accumulated_tokens`. The checkpoint-before-token-limit gate is DEAD; `context record
  --tokens ""` errors. Fix: real field names. (axon/ → dev-mode) → **PR-2C**
- **F-COMPILE [HIGH] dead auto-compile pipeline** (EXPANDED during PR-2A verification) — `compile-write.py` was
  refactored to a WRITER-ONLY (requires `--name/--source/--src-tokens/--cmp-tokens` + `--ops`/stdin), but
  **every caller still passes the OLD `--program` interface**: `compile_suggest.py:145,176` (`compile
  auto-compile`/`compile`) call `compile-write.py --program {p} --workspace {ws}` (rejected rc=2 →
  `compiled_now=[]`, silent); `workspace/programs/compile-optimizer.md:55` passes `--name/--source/--workspace`
  (missing the required token args + `--ops`) → never compiled anything. The whole pipeline (auto_improve daily
  → compile auto-compile → compile-write) is dead. Architectural fix: re-add a `--program` self-sufficient path
  to compile-write (mechanical compress + token count), OR make the cognitive-compile producer explicit. → **PR-2F** (own PR; architectural)
- **F-STUDYURL [HIGH] `workspace/programs/code-dev-study.md:304-305,308`** — `web-search fetch --url` (web_search
  has no fetch/--url; it's a search tool) + `document-parser parse --text` (no parse/--text; +bogus `parse` on :308). URL+PDF ingestion broken. → **PR-2A**
### MED
- **F-IGAP [MED] `workspace/programs/code-dev-meta-igap.md:53-55`** — `redact scrub` (no `scrub` subcmd) → igap record path dies. → **PR-2A**
- **F-NEXT [MED] `workspace/programs/code-dev-next.md:66`** — `pr_aggregate list` (flat parser, no positional) → pr-rows []. → **PR-2A**
- **F-SHADOW [MED] `workspace/programs/code-dev-study-area.md:93`** — `shadow init` omits required `--hash` + bogus `--summary`. → **PR-2A**
- **F-IGAPTYPE [MED] `axon/KERNEL-SLIM.md:273`** — `igap record --type missing-route` not in choices → always fails (silent !BG). Fix: `semantic-search` or add the type. (axon/ → dev-mode) → **PR-2C**
- **F-CLOCK [MED] `tools/clock.py`** — no argv parsing → `ago/elapsed/diff-hours/--offset` silently return "now" → wrong windows/ages in code-dev-meta-usage:44, code-dev-next:47, resume:58 +3. Fix: real subcommands OR callers compute from clock.iso. → **PR-2D** (involved)
- **F-STATELOG [MED] `tools/axon_state.py:101`** `_parse_log` leaks the header row (`"Time"` parsed as data) → off-by-one counts + bogus "newest" event. → **PR-2B**
- **F-MYAXON2UP [MED] `tools/agent_memory.py:53` + `agent_todo.py:37`** — resolve my-axon TWO levels up (should be one) → on a fresh clone (no gitignored myaxon-path.md) agent-memory/todos resolve to a nonexistent tree. Fix: `_axon_paths.default_myaxon()`. (kernel calls agent-memory load → real path) → **PR-2B**
- **F-INFDEFAULT [MED] `workspace/programs/orchestrator.md:53`** — the orchestrator decide-engine STILL defaults inference-mode to 5 while OUTPUT-LAYER (K1) is now 3 → footer shows 3 but behaves as 5. +3 AXON-DOCS still say "default 5". → **PR-2C** (orchestrator no-dev-mode; docs regenerate)
### LOW
- **F-AUDITWS [LOW] `tools/axon_audit.py`** — `main()` calls usage/prompt stats with no arg → `--workspace` override ignored (core M1 fix works for default). → **PR-2B**
- **F-LOADEMPTY [LOW] `tools/synapse_suggest.py` `_load_json('')`** raises (empty takes inline branch). Fix: `if not s: return None`. → **PR-2B**
- **F-RESOLVEVAL [LOW→confirmed real] my-axon-pointer parse divergence** — the gate's `_myaxon_root` parses a
  `value:` line / first-non-empty-line / drops an inline `# comment`, but `autonomous_mode._resolve_myaxon` +
  `agent_memory.resolve_myaxon` + `agent_todo._resolve_myaxon` all `.read().strip()` RAW → they return
  `value: …`/comments verbatim, diverging from the gate for those pointer forms (latent: on-disk file is
  bare). Fixed via shared `_axon_paths.read_myaxon_pointer` (parses exactly like `_myaxon_root`) routed
  through all 3 readers. → **PR-2B**
- **F-CMPSTALE [LOW] `workspace/programs/compiled/workflow-run.cmp.md:63` + workflow-new.cmp.md`** — stale compiled forms keep the OLD broken synapse-suggest call (not load-bearing; not in dispatch-index). Fix: regenerate or delete. → **PR-2A**
- **F-DRIFTICON [LOW] `axon/OUTPUT-LAYER.md:43`** — `drift-icon` keys on `drift.status` (gate returns `state`); the icon is computed-but-unused. → **PR-2C** (dev-mode)

## Plan — phase 2-reaudit-fixes (gate-first, batched to minimise gate runs)
- **PR-2A** program call-sites (no dev-mode): F-STUDYURL · F-IGAP · F-NEXT · F-SHADOW. Content-lock tests. ✅ IMPLEMENTED (clean swaps; F-COMPILE + F-CMPSTALE pulled out → PR-2F, they need the compile pipeline).
- **PR-2B** tools/state (no dev-mode): F-STATELOG · F-MYAXON2UP (agent_memory+agent_todo, one-up sibling) · F-AUDITWS · F-LOADEMPTY · F-RESOLVEVAL (shared read_myaxon_pointer). Effect tests. ✅ IMPLEMENTED (6 new effect tests + 58 module-regression green; gate pending).
- **PR-2C** kernel/program defaults: F-KCTX · F-IGAPTYPE · F-DRIFTICON (axon/, scoped dev-mode + F50 v1.1.5→1.1.6) + F-INFDEFAULT (orchestrator.md:53 |5→|3 + 3 hand-written AXON-DOCS, no dev-mode). ✅ IMPLEMENTED (5 content-locks + F50 lock; 257 kernel-reading-test regression green; gate pending). [F-KCTX also DROPS the "Record pressure" line — context record accumulates, so re-recording the total double-counts.]
- **PR-2D** F-CLOCK — gave clock real offset/today/elapsed/diff-hours/ago subcommands (literal add_parser, R_TOOL_CALL_EXISTS-safe; no-arg default preserved byte-for-byte) + fixed the 7 degenerate callers (6 programs). ✅ IMPLEMENTED (8 effect + content-locks; clock-dependent suites regression pending). [session-summary.cmp.md still stale → PR-2F regen.]
- **PR-2E** F-LIVE — fixed the orphan-gate corpus (per-file, excludes own; reached 139/139→129/139) + triaged the 10 surfaced orphans: 8 entry/CLI/installer tools → OPTIONAL, 2 test-pinned-ACTIVE (domain_validate, deprecation-log) → kept ACTIVE + grandfathered in liveness-allow.txt (the designed pending-tool path). ✅ IMPLEMENTED (700-test regression green incl. all aggregate-ACTIVE/parity suites; OPTIONAL-safe verified: axon.py gates only PLANNED, health invariant holds). [lint-code/axon-trace = future-wiring candidates.]
- **PR-2F** F-COMPILE + F-CMPSTALE — owner chose "make it honest": compile_suggest reports candidates (not the silent `compile-write --program`); compile-optimizer.md does the cognitive compile (COMPILE + --ops + token counts); deleted the 3 stale .cmp.md + nulled their pointers. ✅ IMPLEMENTED (4 effect/content + 656 compile/auto_improve/smoke + 471 freshness/drift regression green). [git history: pipeline was NEVER functional — compile-write never had --program; compilation is cognitive per COMPILER.md.] [Noted follow-ups: auto_improve no-compression; `compile auto-compile` dangling route; REGISTRY tools-list resync.]
Recommended order: 2A → 2B → 2C → 2D → 2E → 2F (clean batches first; dev-mode + involved + architectural last).

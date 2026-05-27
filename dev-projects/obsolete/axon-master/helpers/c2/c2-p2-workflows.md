# C2·P2 — Workflows refined from deep internals

> Builds on C1·P2. New findings from c2-p1-deep-internals introduce 8 areas worth dedicated workflows: spec-consistency audit, snapshot convergence, optimizer extension, grammar coverage, token-estimator upgrade, soft-fail handling, KILL/CLEAR safety, and template authoring.

---

## A. SPEC-CONSISTENCY WORKFLOWS

### A1 · Status-enum reconciliation
- **trigger**: ad hoc OR cron weekly
- **pieces**: read SCHEDULER.md + PROCESS.md + COMPILER.md → diff status enum vocabulary → produce reconciliation report
- **output**: list of inconsistent terms (`COMPLETE` vs `COMPLETED`, `RUNNING` vs `IN-PROGRESS`, etc.) + proposed canonical form
- **gap**: today no enum-validator program; needs `axon-enum-check`

### A2 · Cross-spec rule conflict scan
- **trigger**: every dev-mode write to axon/
- **pieces**: scan KERNEL-SLIM + SCHEDULER + PROCESS + MEMORY → find any rule expressed in two specs that disagrees (e.g. HIGH preemption rule)
- **output**: alert with both occurrences cited
- **gap**: needs a `kernel-conflict-scan` tool (or extend axon-audit)

### A3 · "Missing scope in spec" detector
- **trigger**: cron monthly
- **pieces**: enumerate all memory scopes referenced in workspace (`grep -r 'local/'` etc.) vs scopes documented in MEMORY.md
- **output**: undocumented scopes (e.g. `local/` referenced but undefined in MEMORY.md)
- **gap**: small program needed

---

## B. SNAPSHOT-CONVERGENCE WORKFLOWS

### B1 · Unified checkpoint store
- **trigger**: any CHECKPOINT or preemption
- **pieces**: replace `W:preempt-[id]` (scheduler) + `W:checkpoint-[pid]-[n]` (process) with `W:snapshot-[type]-[id]-[seq]`
- **output**: single mental model for all snapshots
- **risks**: existing programs assume current key shape — migration shim required
- **gap**: requires kernel edit (dev-mode)

### B2 · Snapshot inspector
- **trigger**: `axon snapshot list`
- **pieces**: list all snapshots, age, owner, size; allow restore by id
- **output**: visibility into stored snapshots
- **gap**: no command exists today

---

## C. OPTIMIZER EXTENSION WORKFLOWS

### C1 · O7 robustness — soft-shape fusion
- **trigger**: compile time
- **pieces**: detect `EXEC+EVAL+IF+RETRY` even when interleaved with no-op LOG/STORE → fuse to RETRY-WITH-EVAL
- **output**: more compression on real-world programs
- **gap**: extend `compile` (dev-mode)

### C2 · Add O11 — constant folding
- **trigger**: compile time
- **pieces**: pre-compute literal arithmetic, string concatenation, simple boolean ops at compile time
- **output**: smaller .cmp.md
- **gap**: net-new optimizer rule

### C3 · Add O12 — cross-phase optimization
- **trigger**: compile time
- **pieces**: hoist invariant ops out of loops; merge stores written then read in next phase without intervening read elsewhere
- **output**: faster execution + fewer ops
- **gap**: net-new optimizer rule

### C4 · Empirical compression dashboard
- **trigger**: cron weekly
- **pieces**: read `memory/longterm/benchmark-log.md` → group by program → render compression ratio trend
- **output**: identifies programs slipping below MetaGlyph 62% target
- **gap**: a `compression-dashboard` program

---

## D. GRAMMAR COVERAGE WORKFLOWS

### D1 · Grammar miss tracker
- **trigger**: every compile that emits TOOLCHECK or falls back to literal EXEC
- **pieces**: log the miss → build a frequency-ranked backlog → seed an "extend grammar" plan
- **output**: ranked grammar gaps (today: time/date math, resource locking, rate limiting, pagination, generic negation)
- **gap**: today misses are silent warnings

### D2 · "Add grammar rule" assisted authoring
- **trigger**: user types `grammar add <pattern>`
- **pieces**: load `compiler/GRAMMAR.md` → propose rule → write expansion + translation → 2-use validation → activate
- **output**: net-new grammar rule (mirrors EXTEND protocol for LANG)
- **gap**: needs program scaffold

---

## E. TOKEN ESTIMATOR UPGRADE WORKFLOWS

### E1 · Replace `words × 1.3` with tiktoken on hot paths
- **trigger**: every TOOL(tokenizer) call
- **pieces**: prefer tiktoken when available; fall back to heuristic only on failure
- **output**: real token counts, accurate compression metrics
- **already implemented?**: check tools/tokenizer.py — c1-p1-tools-map noted "tiktoken expensive if missing; fallback to 1.33×word — acceptable" — but C2·P1 found `words × 1.3` is the *only* path. Reconcile in C3.
- **gap**: depends on actual implementation state

### E2 · Per-program token budget enforcement
- **trigger**: program author writes `# budget: <n>`
- **pieces**: compile reads budget → after PHASE 4 OUTPUT, ASSERT compiled-tokens ≤ budget
- **output**: programs that grow past budget fail compile
- **gap**: net-new authoring directive + compiler check

---

## F. SOFT-FAIL HANDLING WORKFLOWS

### F1 · Non-interactive staleness recompile
- **trigger**: stale .cmp.md detected in non-interactive context (cron, batch, CI)
- **pieces**: detect non-interactive (`L:halt-mode == strict` AND no TTY) → auto-recompile + warn vs prompt
- **output**: cron jobs no longer break on stale compiled programs
- **gap**: requires compile flag `--auto-recompile`

### F2 · Output-schema strict mode
- **trigger**: program declares `# strict-schema: true`
- **pieces**: WARN becomes ERROR for that program's output-schema mismatch
- **output**: catches drift in critical programs
- **gap**: per-program flag + compiler check

### F3 · Warn-vs-error policy switch
- **trigger**: user sets `L:compile-strictness = strict`
- **pieces**: all WARN-only checks become ERROR
- **output**: pre-merge gate compatible
- **gap**: preference + per-check honoring

---

## G. KILL / CLEAR SAFETY WORKFLOWS

### G1 · Distinguish "complete" vs "kill"
- **trigger**: process lifecycle
- **pieces**: rename PROCESS.md `KILL` to two ops — `COMPLETE-PROCESS` (clean) and `KILL-PROCESS` (force)
- **output**: clearer intent + audit
- **risks**: programs depend on current name; migration period
- **gap**: kernel edit (dev-mode)

### G2 · Document `CLEAR(W:key-*)` glob support
- **trigger**: dev-mode session
- **pieces**: confirm whether memory tool supports glob CLEAR; if yes, document; if no, add explicit `CLEAR-MATCHING(pattern)` op
- **output**: removes hidden-feature ambiguity
- **gap**: documentation OR new op

---

## H. TEMPLATE AUTHORING WORKFLOWS

### H1 · Template gallery
- **trigger**: user types `templates list`
- **pieces**: scan `axon/compiler/templates/` + `workspace/templates/` → render summary cards
- **output**: discoverability of qc-workflow.tpl, feedback-loop.tpl, v4-meta, v4-schema, etc.
- **gap**: small program

### H2 · "Use template to scaffold" command
- **trigger**: `compile template apply <name> --to <new-program>`
- **pieces**: copy template to programs/, parameterize, open in editor, register
- **output**: faster program authoring
- **gap**: small extension to compile

---

## I. MEGACHAINS (cycle-2 grade)

### I1 · "Spec consistency sweep + grammar gap closure"
`axon-enum-check → kernel-conflict-scan → grammar-miss-report → propose plan → code-dev-pr per fix`
**output**: tight, internally-consistent kernel + filled grammar
**ask**: 1 weekly cron + 4 small new programs

### I2 · "Compile budget enforcement"
`compile (with budget) → benchmark log → compression-dashboard → flag over-budget → propose split or O11/O12`
**output**: programs stay under their token budget
**ask**: 1 directive + 1 dashboard

### I3 · "Snapshot unification migration"
`axon-snapshot-migrate (one-shot) → kernel edit (replace key shapes) → axon-audit → pr-ready`
**output**: single snapshot model
**ask**: dev-mode kernel edit

---

## J. WHAT THIS CYCLE ADDS TO THE BACKLOG (extends C1·P3)

| New ID | Item                                                       | Impact | Effort |
|--------|------------------------------------------------------------|--------|--------|
| S-01   | axon-enum-check (status enum reconciliation)               | 3      | 2      |
| S-02   | kernel-conflict-scan (cross-spec rule diff)                | 3      | 2      |
| S-03   | Document `local/` scope in MEMORY.md                       | 4      | 1      |
| S-04   | Unified snapshot store (W:snapshot-[type]-[id]-[seq])      | 4      | 4      |
| S-05   | Snapshot inspector command                                 | 3      | 2      |
| O-01   | O11 constant folding                                       | 3      | 3      |
| O-02   | O12 cross-phase optimization                               | 4      | 4      |
| O-03   | O7 soft-shape fusion                                       | 3      | 3      |
| O-04   | Compression dashboard                                       | 3      | 2      |
| GR-01  | Grammar-miss tracker                                       | 4      | 2      |
| GR-02  | Grammar add-rule assisted authoring                        | 3      | 3      |
| TK-01  | tiktoken-on-hot-path verification                          | 3      | 1      |
| TK-02  | Per-program `# budget:` directive                          | 4      | 3      |
| SF-01  | Non-interactive staleness auto-recompile                   | 4      | 2      |
| SF-02  | Output-schema strict mode                                  | 3      | 2      |
| SF-03  | L:compile-strictness preference                            | 2      | 1      |
| KC-01  | Split KILL → COMPLETE-PROCESS + KILL-PROCESS               | 3      | 3      |
| KC-02  | Document/replace CLEAR(W:key-*) glob                       | 2      | 1      |
| TPL-01 | Template gallery program                                    | 2      | 1      |
| TPL-02 | Compile template apply command                             | 3      | 2      |

---

## K. FOR CYCLE 3 (token-economy focus)

C2 surfaces additional token-economy candidates:
- **TK-01** is a sleeper: if real implementation uses heuristic everywhere, compression metrics are unreliable.
- **O-01 / O-02 / O-03** all add compression. Measure before/after.
- **TPL** workflows reduce author time (not direct tokens, but reduces "wrong way" iterations).

C3·P1 (in flight) should also confirm or refute the C2 finding that `words × 1.3` is the *only* tokenizer path.

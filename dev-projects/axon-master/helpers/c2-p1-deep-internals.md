# C2-P1 — AXON Deep Internals Map

> Cycle 2, Pass 1 — deep dive into the four named subsystems (compiler, scheduler,
> memory, processes) plus program authoring. C1 mapped the surface; this expands
> the interior. Source-of-truth file paths and exact terminology preserved.

Sources read in full:
- `/mnt/c/projects/axon/axon/compiler/COMPILER.md` (1–277)
- `/mnt/c/projects/axon/axon/compiler/GRAMMAR.md` (1–329)
- `/mnt/c/projects/axon/axon/scheduler/SCHEDULER.md` (1–98)
- `/mnt/c/projects/axon/axon/memory/MEMORY.md` (1–126)
- `/mnt/c/projects/axon/axon/processes/PROCESS.md` (1–145)
- `/mnt/c/projects/axon/axon/programs/PROGRAMS.md` (1–157)
- `/mnt/c/projects/axon/axon/programs/PROGRAMS-SLIM.md` (1–30)
- `/mnt/c/projects/axon/axon/compiler/templates/` (TEMPLATES.md, qc-workflow.tpl.md, feedback-loop.tpl.md)

---

## 1. COMPILER deep dive

File: `axon/compiler/COMPILER.md`. Self-described as a meta-program (line 4) — version v1.1.0
(line 2). Compiler accepts NL workflow text and produces a compiled `.cmp.md` whose ops
are loaded at runtime; the source is kept as reference but never re-loaded (line 4).

### 1.1 Inputs (lines 10–22)
Two input modes:
- **Direct workflow** — `EXEC(compiler, {source: "path/to/workflow.md", output: "programs/compiled/name.cmp.md"})`
- **Template instantiation** — `EXEC(compiler, {template: "compiler/templates/name.tpl.md", params: {...}, output: "programs/compiled/name.cmp.md"})`

### 1.2 Pipeline — four phases, in order, no skipping (line 28)

#### PHASE 1 — PARSE (lines 32–58)
- Read source. Build internal parse tree → `W:parse-tree` (line 34, 57).
- Extract and label every element with one of the 16 tags below (table lines 38–55).
- Emit final debug log with phase/step/decision counts (line 58).

**All 16 [TAG] categories extracted in PARSE** (the user said "14+", real count is 16):

| Tag                | Trigger phrases (verbatim from COMPILER.md lines 38–55)                                         |
|--------------------|--------------------------------------------------------------------------------------------------|
| `[PHASE]`          | Major sections, stages, named groups of steps                                                    |
| `[STEP]`           | "do X", "perform X", "execute X"                                                                 |
| `[DECISION]`       | "if X", "when X", "in case X", "depending on X"                                                  |
| `[BRANCH]`         | "then Y", "otherwise Z", "else W"                                                                |
| `[LOOP]`           | "for each", "repeat", "while", "until"                                                           |
| `[TOOL]`           | "calculate", "notify", "call", "send", "check via"                                               |
| `[MEMORY]`         | "save", "record", "retrieve", "remember", "get"                                                  |
| `[LOG]`            | "log", "record", "document", "audit"                                                             |
| `[ASSERT]`         | "verify", "ensure", "validate", "confirm", "check that"                                          |
| `[PARALLEL]`       | "simultaneously", "in parallel", "at the same time"                                              |
| `[ESCALATE]`       | "alert", "escalate", "urgent", "critical"                                                        |
| `[END]`            | "complete", "finish", "done", "close"                                                            |
| `[INPUT-SCHEMA]`   | "requires", "inputs:" YAML block, "accepts"                                                      |
| `[OUTPUT-SCHEMA]`  | "produces", "returns", "outputs:" YAML block                                                     |
| `[CONFIDENCE]`     | "may", "uncertain", "best-effort", "~"                                                           |
| `[EVENT]`          | "emit", "trigger", "fire", "notify system"                                                       |

Notable overlaps the parser must disambiguate by context:
- "record" is shared between `[MEMORY]` and `[LOG]`.
- "notify" appears under `[TOOL]` and overlaps with `[EVENT]` ("notify system").
- "check that" is `[ASSERT]` while bare "check" is `[TOOL]` ("check via").

#### PHASE 2 — MAP (lines 62–95)
Convert tagged elements to symbolic ops via `compiler/GRAMMAR.md`. The mapping order
is fixed (lines 66–80):

1. `[PHASE]` → English section headers (kept verbatim in hybrid output)
2. `[INPUT-SCHEMA]` + `[OUTPUT-SCHEMA]` → YAML blocks in compiled header (verbatim, not symbolized)
3. `[MEMORY]` → RETRIEVE / STORE / CLEAR — assign W/L/E scope by context
4. `[TOOL]` → TOOL() — cross-reference `tools/REGISTRY.md`
5. `[ASSERT]` → ASSERT() — placed before guarded step
6. `[STEP]` → EXEC() or atomic ops
7. `[DECISION]` + `[BRANCH]` → IF() → action | fallback
8. `[LOOP]` → LOOP() or UNTIL()
9. `[PARALLEL]` → SPAWN() pairs
10. `[ESCALATE]` → ↑ + LOG(!CRIT or !HIGH) + TOOL(notify)
11. `[LOG]` → LOG(level, message), level inferred
12. `[END]` → DONE() + cleanup
13. `[CONFIDENCE]` → CONFIDENCE(~) tag on the enclosing op
14. `[EVENT]` → EMIT(event-name, payload?) immediately after the triggering op

**Scope assignment rules** (lines 82–86, also restated in GRAMMAR.md lines 75–86):
- "remember for later / across sessions / permanently" → `L:`
- "save for this task / temporarily / during this process" → `W:`
- "record what happened / audit / history" → `E:` via `APPEND`
- Ambiguous → default `W:` and emit `# scope?` comment for human review

**Tool verification** (lines 88–91): for each `[TOOL]`, run `TOOL?([name])` against
REGISTRY.md. If unknown, do NOT fail compilation — emit
`TOOLCHECK([name]) # unregistered — add to tools/REGISTRY.md` as a warning. (Soft fail by design.)

PARSE/MAP outputs:
- `W:parse-tree`
- `W:mapped-ops` (list per phase)
- `W:warnings` (unresolved tools, ambiguous scopes)

#### PHASE 3 — OPTIMIZE (lines 99–179)
Token reduction without semantic change. Ten rules, applied in declared order:

| Rule | Name | What it does | What it saves |
|------|------|--------------|---------------|
| O1 | Merge sequential READs from same source | `READ(X)→A; READ(X)→B` becomes `READ(X)→A,B` | One round-trip per duplicate read |
| O2 | IF→GUARD when single-branch | `IF(c) → action \| ∅` becomes `GUARD(c) → action` | The empty-else token block |
| O3 | Apply LANG.md shorthands | Scan ops for any matching shorthand and replace inline | Expansion of canonical macros |
| O4 | Collapse no-op stores | `RETRIEVE(scope:k) → STORE(scope:k, unchanged)` removed | Both ops; transformation never happened |
| O5 | Merge adjacent same-level LOGs | `LOG(INFO,A); LOG(INFO,B)` → `LOG(INFO,"A; B")` | One LOG header per merge |
| O6 | Hoist repeated TOOLCHECK | If a tool is called >1× in a phase, single TOOLCHECK at phase header; remove per-call ones | (n−1) TOOLCHECK invocations per phase |
| O7 | Fuse EXEC+EVAL+IF+RETRY (LANG v2.3.0 EXT-012/013) | 4 ops collapse to `result ← RETRY-WITH-EVAL(<op>, eval={criteria}, max=L:retry-default-max)` | 4 ops → 1; runtime short-circuits on first pass |
| O8 | Dedup TEE keys (LANG v2.3.0 EXT-014) | Two writes to same `W:[key]-tee` collapse to single TEE concatenating inputs | One TEE call worth of overhead per duplicate |
| O9 | Dead-store elimination | `STORE(W:k,v)` followed (no intervening RETRIEVE) by `CLEAR(W:k)` → both removed | Two ops; producer had no consumer |
| O10 | Redundant RETRIEVE collapsing | Two consecutive `RETRIEVE(W:k)` (no intervening STORE) → second uses local | One store-roundtrip per call |

After optimization (lines 169–176):
```
W:source-tokens     = est. token count of source document
W:compiled-tokens   = est. token count of output ops
W:compression-ratio = (source-tokens − compiled-tokens) / source-tokens
```
Token estimation = `words × 1.3` (rough). Exact counts come from benchmarking.

Outputs:
- `W:optimized-ops`
- LOG(INFO, "Optimize complete. Estimated compression: [ratio]%")

#### PHASE 4 — OUTPUT (lines 183–251)
Compiler does NOT write the file directly. It calls `TOOL(compile-write, …)` (line 185)
with: `--name`, `--source`, `--src-tokens`, `--cmp-tokens`, `--ops` (JSON-serialized
`W:optimized-ops`), `--warnings` (JSON, omit if empty), `--version` (line 188–196).

`compile-write.py` writes to `programs/compiled/[name].cmp.md` and returns the path.

**Hybrid output format** (lines 203–237) — every compiled file contains:
- Header: name, source path, compiled timestamp, version, tokens (src/compiled/ratio), warning count.
- An "EXECUTION" block telling humans how to run it: `TOOL(run, {file, inputs})`. `run.py`
  handles all TOOL/LOG/STORE/RETRIEVE/CLEAR ops and returns "remaining agent ops" — i.e.
  a clean separation between mechanical ops (fast path, run.py) and reasoning ops
  (returned to the model).
- INPUT SCHEMA block (verbatim from `[INPUT-SCHEMA]`, or "(none declared)").
- OUTPUT SCHEMA block (verbatim from `[OUTPUT-SCHEMA]`, or "(none declared)").
- One section per phase containing the symbolic ops, plus hoisted TOOLCHECK if O6 fired.
- WARNINGS section at the bottom — `WARN: [description] at [phase/step]` per line.

**Runtime input/output validation** (lines 239–245):
- INPUT: if schema declared, `TOOL(validator, {data: W:inputs, schema: W:input-schema})`
  → `ASSERT(result.valid = true)`. On failure: FAIL with schema error, don't execute.
- OUTPUT: after DONE, `TOOL(validator, …)` → `LOG(WARN if invalid)` (warn-only, not blocking).

**Post-write recordkeeping** (lines 247–251):
- `APPEND(E:compiler-log, {source, output, timestamp, compression-ratio, warnings})`
- `TOOL(benchmark, record, --workflow [name] --src-tokens --cmp-tokens)`
- `LOG(INFO, "Compiled [name]: [ratio]% compression, [#warnings] warnings")`
- Surface filename + ratio + actionable warnings to user.

### 1.3 Recompilation / staleness (lines 255–265)
At program load:
```
IF compiled/[name].cmp.md exists → compare timestamps
  IF source newer → LOG(WARN, "Stale compiled file …") → QUERY(user)  # ask, don't auto
  IF current     → load compiled, skip source
IF no compiled  → load source directly
```
**Gotcha**: staleness only fires if the compiled file exists. A renamed source produces
no warning. The check is timestamp-based — a source edited and saved with `--no-mtime` or
restored from git would falsely appear current.

### 1.4 Benchmarking (lines 269–277)
After every compile, append a row to `memory/longterm/benchmark-log.md`:
```
| Date | Workflow | Source Tokens | Compiled Tokens | Ratio | Warnings |
```
Compression-ratio thresholds (the framework's own qualitative bands, used in tools
and reports — referenced by user's task spec):
- **>40%**: high (compilation is paying off — keep)
- **15–40%**: moderate (worthwhile but examine)
- **<15%**: marginal (consider whether source is short or already symbolic)

### 1.5 Templates directory (`axon/compiler/templates/`)
Contents (5 files):
- `TEMPLATES.md` — the template-system spec (157 lines).
- `chat-session.tpl.md` — category `hr`. Goal-scoped chat → save output → close.
  Params: chat-name, folder, goal, output-path, output-format, model-preference,
  max-turns, on-complete.
- `data-pipeline.tpl.md` — category `integration`. Ingest → validate → transform →
  deliver with lineage. Params: pipeline-name, source, schema-key, transform-program,
  destination, on-error, notify-target, dry-run.
- `feedback-loop.tpl.md` — category `quality`. Plan → act → evaluate → retry until
  criteria met or max iterations. Params: goal, actor-program, eval-criteria,
  eval-tolerance, max-iterations, on-success, on-failure, notify-target. The body
  uses `EVAL` + `EXEC` + `EMIT` and demonstrates phase markers (`### Phase 1: Plan`,
  etc.) that double as extension points.
- `qc-workflow.tpl.md` — category `quality`. Sample → measure → route pass/fail →
  escalate → report. Params: item-name, batch-key, spec-key, tolerance (default 0.05),
  sample-size (default 10), notify-target, escalate-threshold (default 3), checkpoint-each
  (default true). Uses INVARIANTS and 3 EXTENSION POINTS (pre-inspection, post-item,
  post-report).

Template-file structure (TEMPLATES.md lines 11–34):
- Header: name, version, category, description, base (`∅` if root).
- PARAMETERS table (Type ∈ {str, num, bool, list, ref, op}; the `op` type allows
  injecting a symbolic-op fragment inline — line 47).
- WORKFLOW with `{{param-name}}` placeholders.
- INVARIANTS — fixed regardless of params, never parameterized.
- EXTENSION POINTS — named injection sites for child templates / instances.

Substitution rules (TEMPLATES.md lines 51–58):
1. `{{p}}` is text-substituted at instantiation.
2. Missing required param → abort + `QUERY(user)`.
3. Missing optional with default → use default silently.
4. Missing optional, no default → remove the line and warn.
5. After substitution, **re-run Phase 3 (Optimize)** — substituted constants may
   enable additional optimization (e.g., constant folding, dead-branch removal).

Inheritance (TEMPLATES.md lines 86–96): max-depth unlimited but >2 levels is a
"design smell". Inherited INVARIANTS cannot be overridden. Children may add params,
change defaults, never types. WORKFLOW only modifiable at declared EXTENSION POINTS.

Categories enum (TEMPLATES.md lines 121–131): `quality`, `logistics`, `maintenance`,
`hr`, `incident`, `reporting`, `integration`, `financial`.

### 1.6 Compiler surprises / gotchas
- **Soft tool failure** is structural: unregistered tools warn but never block. Risk:
  the compiled file can run with broken tool calls until the warning is read.
- **No schema validation at compile time** — schemas are only validated at runtime
  via `TOOL(validator)`. A malformed YAML schema in `[INPUT-SCHEMA]` survives compile.
- **Output-schema failure is WARN, not FAIL** (line 245) — output validation never
  blocks completion. Programs can DONE() with invalid outputs.
- **Token estimator is `words × 1.3`** — purely heuristic. The real numbers only
  appear in the benchmark log when `tools/benchmark` runs.
- **O3 (LANG shorthands) depends on LANG.md being current**. Stale LANG.md → missed
  shorthand opportunities, compression ratio drops silently.
- **O7 fusion has a strict shape match** (EXEC + EVAL + IF + RETRY in that order
  with that exact predicate). Slight reorderings (e.g., EVAL inlined in IF) won't fuse.
- **Staleness detection asks the user** (`QUERY(user)`) instead of auto-recompiling.
  Net effect: in non-interactive contexts, recompilation never happens automatically.
- **`compile-write.py` is a TOOL** (not the agent) — meaning the writer is opaque to
  reasoning passes; bugs in compile-write.py won't surface as compiler issues.
- **`[INPUT-SCHEMA]`/`[OUTPUT-SCHEMA]` are passed verbatim** with no normalization —
  whitespace and field-name typos in source survive into the compiled artifact.

---

## 2. GRAMMAR deep dive

File: `axon/compiler/GRAMMAR.md`. Defines NL → symbolic ops mapping rules. Applied in
Phase 2 (Map). Most-specific rule wins; unmatched rules fall back to literal `EXEC()`.

### 2.1 Section catalogue (NL → symbolic mapping categories)
Eleven sections, each a table of patterns:

1. **Control flow / Conditionals** (lines 12–23) — IF, GUARD, ASSERT-as-conditional
   ("if and only if"). Note "Skip Y if X" maps to `GUARD(!X) → Y` (negated guard).
2. **Control flow / Loops** (lines 27–35) — LOOP(∀ x ∈ S), LOOP(condition),
   UNTIL(condition), LOOP(#=N), LOOP(#≤N ∧ ✗) for retries.
3. **Control flow / Parallel** (lines 39–45) — SPAWN(P-X, op) joined with `⊕`.
   "Wait for both" pattern: `SPAWN ⊕ SPAWN → UNTIL(P-A.status=✓ ∧ P-B.status=✓)`.
4. **Memory operations / Retrieval** (lines 53–60) — RETRIEVE, READ. Note "Recall …
   from previous session" specifically maps to `L:` retrieval.
5. **Memory operations / Storage** (lines 64–72) — STORE, APPEND, CLEAR.
6. **Memory operations / Scope heuristics** (lines 74–86) — see §2.2.
7. **Tool operations / Calculator** (lines 91–100) — every arithmetic, percentage, or
   total goes through `TOOL(calculator, …)`. "Total of items" specifically maps to
   `TOOL(calculator, "Σ([items])")`.
8. **Tool operations / Generic** (lines 102–110) — TOOL(name, args) shapes.
9. **Process control** (lines 116–124) — SPAWN, EXEC, KILL, PAUSE, RESUME, DONE.
10. **Validation / Assertions** (lines 130–140) — ASSERT in many disguises;
    "Reject if X" specifically maps to `IF(X) → FAIL(T-current, "[reason]")` (not assertion).
11. **Logging / Audit** (lines 146–154) — LOG, APPEND(E:…), `LOG ⊕ TOOL(notify, …)`.
12. **Escalation / Priority** (lines 160–168) — `↑`, `!CRIT`, `!HIGH`, `!CRIT ⊕ TOOL(notify) ⊕ LOG`,
    `PREEMPT(current) → EXEC(X)`, `↓ ⊕ DEFER(T-X)`.
13. **Approval / HITL** (lines 174–181) — QUERY(role) → ASSERT(response = approved).
14. **Industrial-specific** (lines 187–198) — pre-mapped composite forms (QC check,
    inventory, threshold, maintenance window, batch loop, rollback, retry-with-backoff,
    checkpoint, end-of-day report).
15. **Confidence / Progress** (lines 227–251) — CONFIDENCE(~), CONFIDENCE(?), PROGRESS.
    Hard rule: "Always add PROGRESS inside loops that have more than 5 iterations."
16. **Event emission** (lines 255–263) — EMIT, ON.
17. **Agent handoff** (lines 267–272) — HANDOFF({context, target, reason}).
18. **EVAL/RETRY/TEE** (lines 276–329) — patterns added in LANG v2.3.0 EXT-012/013/014.
    These rules exist specifically so that programs using these patterns no longer
    fall back to `EXEC("[description]")` and the optimizer (O7, O8) can see them.

### 2.2 Memory scope heuristics (lines 74–86)
| Context clue | Scope |
|--------------|-------|
| "this task", "currently", "right now", "temporarily" | W: |
| "future sessions", "permanently", "always", "remember" | L: |
| "audit", "history", "happened", "occurred", "event" | E: (via APPEND) |
| Configuration, credentials, preferences | L: |
| Intermediate calculation results | W: |
| Final outputs to be reviewed later | L: |

These are duplicated from COMPILER.md lines 82–86 with extras for credentials/prefs/
intermediate/final. Tie-break in COMPILER.md line 86: ambiguous → W: with `# scope?`.

### 2.3 Tool detection rules
Two layers:
- **Calculator detection** (lines 92–100): every decimal/percentage/total is a
  calculator call. The catch-all rule `Any decimal or percentage involved → TOOL(calculator, …)`
  is broad and will capture stray numbers in prose.
- **Generic tool calls** (lines 102–110): "Call X with Y", "Use X to Y", "Via X, Y",
  "Y using X", "Invoke X API". Five surface forms.

Tool verification happens in Phase 2 (COMPILER.md lines 88–91) — `TOOL?([name])` against
REGISTRY.md → unknown becomes a warning, not an error.

### 2.4 Fallback rule (lines 205–211)
When no rule matches:
1. Emit `EXEC("[verbatim step text]")`.
2. Compiler warning: `WARN: No grammar rule matched "[step]" at [phase/step].`
3. **`APPEND(E:grammar-misses, {pattern, phase, source, date})`** — feeds coverage analysis.
4. Continue compilation (don't halt).

### 2.5 Coverage analysis (lines 215–221)
Review `workspace/memory/episodic/grammar-misses.md`. Promotion criteria:
**a pattern must appear ≥ 3 times across different source files** before being
promoted to a rule. Surfacing tool: `python3 tools/memory.py list --scope E --key grammar-misses`.

When adding a rule: place in most-specific section, bump GRAMMAR.md version (PATCH for
single rule, MINOR for new section), log in AXON CHANGELOG.

### 2.6 Where grammar misses today
- **No rule for arbitrary tool-action verbs** beyond the 5 generic forms — e.g.,
  "Email the report" must be rephrased as "Notify via email …" or it falls back.
- **No coverage of math expressions in prose** outside the calculator triggers — e.g.,
  "double the value" or "halve the count" fall back to EXEC.
- **No rule for time/date math** (e.g., "in 5 minutes", "tomorrow at noon") —
  defers to fallback EXEC.
- **No rule for negation across most categories** — only "Unless X" (conditional) and
  "Skip Y if X" (guard) are negated forms. "Don't do X if …" falls back.
- **`HANDOFF` (lines 267–272) has no priority/cost annotation** — the compiler can't
  reason about why the handoff was requested when reading the compiled file.
- **`EVAL`/`RETRY`/`TEE` were added late** (LANG v2.3.0). Before this section existed,
  programs using these patterns fell back to literal EXEC, losing optimizer visibility
  (lines 277–278). Indicates new LANG primitives may carry the same lag.
- **No rules for resource locking** (acquire/release semaphores), no rules for
  rate limiting, no rules for pagination/cursor patterns — common in real workflows,
  always fall back today.

---

## 3. SCHEDULER deep dive

File: `axon/scheduler/SCHEDULER.md`.

### 3.1 Priority levels (lines 6–14)
| Lvl | Flag    | Name       | Behavior                                                       |
|-----|---------|------------|----------------------------------------------------------------|
| 1   | !CRIT   | Critical   | Preempts everything. Execute immediately. Alert user.          |
| 2   | !HIGH   | High       | Execute before any NORMAL or below. Does NOT preempt CRIT.     |
| 3   | !NORM   | Normal     | Default. FIFO within level.                                    |
| 4   | !LOW    | Low        | Run only when no CRIT/HIGH/NORM pending.                       |
| 5   | !BG     | Background | Run only when system is fully idle.                            |

Within a level: **FIFO** ("first added to queue = first executed", line 16).

Important asymmetry: !HIGH runs before any NORMAL/below, but **does not preempt** anything
already running — only !CRIT preempts (line 11 vs line 9). This makes !HIGH a "next-up"
priority rather than a true interrupt.

### 3.2 Task anatomy (lines 22–34)
Every queue entry has these fields (`scheduler/QUEUE.md`):
```
ID:       T-001
Program:  [program name or inline instruction]
Priority: [!CRIT | !HIGH | !NORM | !LOW | !BG]
Status:   [QUEUED | RUNNING | PAUSED | COMPLETE | FAILED]
Deps:     [comma-separated task IDs this task waits on, or ∅]
Added:    [timestamp]
Started:  [timestamp or ∅]
Ended:    [timestamp or ∅]
Notes:    [freeform, optional]
```

Note: status enum uses `COMPLETE` here (line 28) but `COMPLETED` in process files
(PROCESS.md line 44). Inconsistency between subsystems.

### 3.3 Queueing (lines 38–55)
Add: `SCHED(task-id, priority, deps?)` writes a new entry. Sequential ID auto-assigned
(T-001, T-002, …). Default priority `!NORM`. Deps optional; task can't start until
all listed are COMPLETE.

Pre-start checks (line 49–52):
1. No higher-priority task waiting.
2. All deps COMPLETE.
3. TOOLCHECK for each declared tool dependency.

Complete: `DONE(task-id)` marks COMPLETE in QUEUE.md, releases dependents, logs.

### 3.4 Preemption mechanics (lines 59–73)
Trigger: a `!CRIT` or `!HIGH` task arrives while a lower-priority task is RUNNING.
(But per priority table, only `!CRIT` should actually preempt — line 11 says HIGH does
NOT preempt CRIT, but line 60 lists HIGH as a preemption trigger. Internal inconsistency
in the spec — see Surprises below.)

Sequence on preemption:
1. **PAUSE** the current task.
2. **SNAPSHOT** the current working memory state under `W:preempt-[task-id]`.
3. **APPEND** to `E:preempt-log` the current task ID, timestamp, reason.
4. Update paused task status in QUEUE.md to `PAUSED`.
5. `LOG(WARN, "Preempted T-[id] for T-[new-id]")`.
6. Begin the higher-priority task.

On preemptor completion (lines 68–72):
1. **RESTORE** `W:preempt-[task-id]`.
2. Update paused task status to RUNNING.
3. Resume execution from the last checkpoint.
4. `LOG(INFO, "Resumed T-[id] after preemption")`.

### 3.5 Dependencies (lines 77–80)
- `Deps: T-002, T-003` → can't start until both COMPLETE.
- If a dep FAILS → dependent task is also marked FAILED. Log both. Query user.
- **Circular deps forbidden**. ASSERT no cycles before adding any task with deps.

### 3.6 Starvation prevention (lines 84–89)
Magic number: **10**. A `!LOW` or `!BG` task waiting more than 10 consecutive task
completions without being able to run gets:
- Auto-promoted by **one priority level**.
- `LOG(INFO, "Priority promoted: T-[id] due to wait time")`.
- Promotion is **temporary** — reset to original priority after the task completes.

Note: only !LOW/!BG are eligible for promotion. !NORM tasks cannot starve up to !HIGH
through this mechanism.

### 3.7 Queue maintenance (lines 93–98)
- Completed and failed tasks **stay in QUEUE.md for the duration of the session**.
- At clean session end: `APPEND` summary of all completed/failed to `E:session-log`.
- Then `CLEAR` completed and failed entries from QUEUE.md.
- **PAUSED tasks are never cleared** — persist across sessions.

### 3.8 Scheduler surprises / gotchas
- **HIGH-as-preemption inconsistency**: priority table (line 11) says HIGH does not
  preempt CRIT — but preemption rules (line 60) say "When a !CRIT or !HIGH task arrives
  while a lower-priority task is RUNNING". The implication: HIGH does preempt anything
  ≤ NORM. Spec is ambiguous about whether HIGH preempts another HIGH (probably not, by
  FIFO rule, but not stated).
- **Status enum mismatch with PROCESS.md** (`COMPLETE` vs `COMPLETED`). A program
  that reads both subsystems' state must handle both spellings.
- **Starvation promotion is temporary** but the spec doesn't say what happens if the
  promoted task is preempted before completion — does it retain or revert priority?
  Not specified.
- **No explicit fairness for !NORM** — a flood of !NORM tasks can never starve, but
  also the spec doesn't say what happens if a !NORM task waits forever behind a chain
  of !HIGH tasks that never drain.
- **Preempt-log is append-only** (`E:preempt-log`) but the spec doesn't say it's also
  bounded — over a long session this can grow large.
- **`SNAPSHOT(W:)` is full-W**, not a delta. Repeated preemptions can cause memory
  bloat in `W:preempt-T-NNN` keys.
- **No deadlock detection for cycles introduced at runtime** — only added-time ASSERT.
- **Background processes (!BG)** in PROCESS.md (line 142) are tracked in a list
  `W:background-processes` — but SCHEDULER.md never references this list. Bridge logic
  is implicit.

---

## 4. MEMORY deep dive

File: `axon/memory/MEMORY.md`. Three scopes; choose the narrowest. Working-memory
pressure is "the primary mechanism for reducing context pressure" (line 4).

### 4.1 Scopes — full rules

#### W: Working (lines 10–18)
- **Location**: `memory/working/`.
- **Lifetime**: current session only. Cleared on clean exit.
- **Purpose**: active task state, intermediate results, current context.
- **Rule**: keep only what is needed to complete the current task.
- **Max items**: aim ≤ 10 keys. If approaching 10, evaluate which to clear.
- **File naming**: `[key].md`.

#### L: Longterm (lines 21–28)
- **Location**: `memory/longterm/`.
- **Lifetime**: persistent across sessions.
- **Purpose**: stable, reusable facts — preferences, config, credentials patterns,
  learned behaviors.
- **Rule**: only store what's been confirmed true >1×, OR explicitly instructed.
  No speculative writes.
- **Retrieval**: always try L: before querying user for config/preference info.
- **File naming**: `[topic].md` (descriptive).

#### E: Episodic (lines 31–38)
- **Location**: `memory/episodic/`.
- **Lifetime**: permanent. **Append-only. Never delete entries.**
- **Purpose**: chronicle of what happened — sessions, tasks, decisions, errors,
  preemptions, completions.
- **Rule**: APPEND only. Never overwrite. For audit, resume, retrospective.
- **Format**: per-session entries `[YYYY-MM-DD]-[session-id].md`.
- **Named logs**: programs may use named streams like `E:testimony-MARA` or
  `E:case-log` — stored as `memory/episodic/[name].md`. Same append-only rule.

### 4.2 Retrieval protocol (lines 42–51) — non-skippable
```
1. CHECK W: first (fastest, in-session)
2. IF ∅ → CHECK L: (persisted facts)
3. IF ∅ → CHECK E: (historical context — search by topic or date)
4. IF ∅ in all three → QUERY(user)
```
**"Never skip this order. Never query the user for something that is stored in L:"**
(line 51). This is the "no redundant questions" principle — the agent's etiquette
about not asking what it already knows.

### 4.3 Storage rules (lines 55–62)
- **Before storing to L:**: ask "Would this be true in the next session?" → yes ⇒ L:.
- **Before storing to W:**: ask "Will I need this again before this session ends?" →
  no ⇒ don't store, just use and discard.
- **Before APPEND to E:**: confirm meaningful content (not noise). Qualifying events:
  every task completion, session start, session end, error, user instruction.

### 4.4 Session lifecycle

#### Start (lines 67–73)
```
RETRIEVE(W:current-session) → IF ∅ → clean start
  → APPEND(E:session-log, {event: "session-start", timestamp, context: ∅})
IF ✓ → session was interrupted → surface resume prompt to user
  → APPEND(E:session-log, {event: "session-resumed", timestamp})
```

#### Checkpointing (lines 76–82)
```
SNAPSHOT(W:) → store as W:checkpoint-[task-id]
APPEND(E:session-log, {event: "checkpoint", task-id, timestamp, state-summary})
LOG(DEBUG, "Checkpoint saved for T-[id]")
```
Checkpoint when: a task phase completes, a tool call returns a result that changes
state, or before any potentially irreversible action.

#### End — clean (lines 85–89)
```
APPEND(E:session-log, {event: "session-end", timestamp, tasks-completed, tasks-pending})
CLEAR(W:) — all working memory
LOG(INFO, "Session ended cleanly.")
```

#### End — interrupted / context limit (lines 92–96)
```
SNAPSHOT(W:) → STORE(W:interrupted-session, snapshot)
APPEND(E:session-log, {event: "session-interrupted", timestamp, reason, W-snapshot})
LOG(WARN, "Session interrupted. State saved for resume.")
```

### 4.5 Memory file format (lines 100–116)
```markdown
# [Key / Topic]
Updated: [timestamp]
Scope: [W | L | E]

[Content — plain prose or structured fields]
```
Episodic entries also include:
```markdown
Session: [session-id]
Event: [event type]
```

### 4.6 Context-pressure handling (lines 120–126)
When context is approaching limits:
1. CLEAR all W: keys not needed for current task.
2. Summarize large W: values, replace with the summary.
3. APPEND the full original to E: before summarizing.
4. If pressure persists, surface to user: "Context is filling — I'll summarize to continue."

### 4.7 Compaction rules
The spec calls out three implicit compaction strategies:
- **Step 2 above** is summarization-in-place (replace large W: value with summary).
- **Step 3** preserves the original by writing it to E: (audit), so the summary in W:
  is the only live copy.
- The 10-key W: aim (line 17) acts as a **pre-emptive compaction trigger** — once
  approaching 10 keys, the agent should evaluate clears.

There is **no automatic compaction**. All three are agent-driven, prompted by either
"approaching limits" or "approaching 10 keys".

### 4.8 local/ scope semantics
There is **no `local/`** scope explicitly named in MEMORY.md — only W:, L:, E:.
The directory layout uses `memory/working/`, `memory/longterm/`, `memory/episodic/`.
The user's task spec mentions "local/ scope semantics" — this likely refers to:
- the per-key file naming under `memory/working/[key].md` — each W: key is a separate
  file (line 19), which makes individual reads/clears local, not session-global.
- the named-stream pattern under `memory/episodic/[name].md` — these are local-named
  E: streams, distinct from the date-keyed default.

Strict reading of MEMORY.md: there is no `local` scope. If `local/` is mentioned
elsewhere in the codebase it must be a convention layered on top, not a kernel scope.
**Open question for next cycle: search the rest of the repo for `local/` references.**

### 4.9 Memory surprises / gotchas
- **W: cap is "aim", not enforced** — no hard limit, no automatic eviction. Drift is
  possible.
- **Retrieval order is non-skippable** but there's no mechanism preventing a program
  from calling `QUERY(user)` directly. Discipline-only.
- **L: write rule "confirmed true more than once OR explicitly instructed"** is fuzzy.
  No mechanism enforces "more than once".
- **E: is unbounded and append-only** — long deployments produce arbitrarily large
  episodic files. No rotation, no archival, no compaction.
- **Session-end CLEAR(W:) on clean exit** could lose data if the session terminates
  without a clean exit signal — the interrupted path saves state, but only if it
  detects the interruption.
- **Checkpoint key naming differs**: MEMORY.md uses `W:checkpoint-[task-id]`,
  PROCESS.md uses `W:checkpoint-[process-id]-[n]`. These collide on namespace but
  not in practice (different prefixes).
- **No TTL on W:** — keys live until explicitly cleared or session ends.
- **Step 3 of context-pressure assumes E: is cheap to write** — but E: is on disk and
  potentially huge.

---

## 5. PROCESS deep dive

File: `axon/processes/PROCESS.md`. A process is a running instance of a program.
Programs are definitions; processes are executions. Multiple processes can run from
the same program with different args. Each has own state and own file in
`processes/active/`.

### 5.1 Lifecycle (lines 8–18)
```
SPAWNED → RUNNING → COMPLETED ✓
                  → FAILED ✗
                  → PAUSED → RUNNING (resumed)
                           → FAILED ✗ (if resume is impossible)
```
"State transitions are always logged. A process never changes state silently." (line 17)

### 5.2 Process file format (lines 38–59)
File: `processes/active/[process-id].md`.
```markdown
# Process: [process-id]
Program:    [program name]
Args:       [arguments or ∅]
Status:     [SPAWNED | RUNNING | PAUSED | COMPLETED | FAILED]
Priority:   [!CRIT | !HIGH | !NORM | !LOW | !BG]
Spawned:    [timestamp]
Started:    [timestamp or ∅]
Ended:      [timestamp or ∅]
Task-ID:    [linked task ID in QUEUE.md, or ∅]

## State
[Current execution state — which instruction step, intermediate values, pending decisions]

## Checkpoints
[List of checkpoint timestamps and brief state summaries]

## Notes
[Any runtime notes, errors encountered, decisions made]
```

Note: status enum here is `COMPLETED` (line 44), not `COMPLETE` (SCHEDULER.md line 28).

### 5.3 Spawn mechanics (lines 22–32)
```
SPAWN([process-id], [program-name], [args?])
```
1. Assign unique PID `P-NNN` if not provided.
2. CREATE `processes/active/[process-id].md`.
3. STORE(W:active-process, process-id) — track current foreground process.
4. LOG(INFO, "Spawned P-[id]: [program] with args: [args]").
5. Begin executing program's instructions.

### 5.4 Checkpointing (lines 64–78)
**Checkpoint moments** (no exceptions):
- After each major phase of a multi-step program completes.
- Before any tool call with side effects.
- Before any action that cannot be undone.
- When context pressure is detected.
- Before yielding control (returning a response to user mid-task).

Procedure:
```
SNAPSHOT(W:) → stored as W:checkpoint-[process-id]-[n]
UPDATE processes/active/[process-id].md → add checkpoint entry with timestamp + state summary
APPEND(E:session-log, {event: "checkpoint", process-id, timestamp})
LOG(DEBUG, "Checkpoint [n] saved for P-[id]")
```
Note `[n]` is a numeric suffix — implies multiple checkpoints per process accumulate.

### 5.5 Pause mechanics (lines 84–92)
```
PAUSE([process-id])
```
1. CHECKPOINT (full procedure above).
2. Update process file status to PAUSED.
3. STORE(W:paused-[process-id], {step: current-step, reason: [reason]}).
4. Update QUEUE.md entry to PAUSED.
5. LOG(WARN, "Paused P-[id]: [reason]").

### 5.6 Resume mechanics (lines 98–107)
```
RESUME([process-id])
```
1. READ `processes/active/[process-id].md` → find last checkpoint.
2. RESTORE(W:checkpoint-[process-id]-[n]) — load last saved state.
3. Update process file status to RUNNING.
4. Update QUEUE.md entry to RUNNING.
5. LOG(INFO, "Resumed P-[id] from checkpoint [n]").
6. Continue execution from the step recorded in the checkpoint.

### 5.7 Complete mechanics (lines 113–123)
**`KILL` is used for normal completion too** (line 113) — no separate "complete" verb.
```
KILL([process-id])
```
1. Update process file status to COMPLETED.
2. CLEAR(W:active-process) if foreground.
3. CLEAR(W:checkpoint-[process-id]-*) — wildcard clear all checkpoint snapshots.
4. APPEND(E:session-log, {event: "process-complete", process-id, timestamp, summary}).
5. DONE([task-id]) — mark linked task complete in QUEUE.md.
6. DELETE `processes/active/[process-id].md` — move content to episodic if needed.
7. LOG(INFO, "✓ Process P-[id] completed").

### 5.8 Fail mechanics (lines 129–136)
Unrecoverable error handler:
1. Update process file status to FAILED.
2. LOG(ERROR, "✗ Process P-[id] failed: [reason]").
3. CHECKPOINT — preserve state for post-mortem.
4. FAIL([task-id], [reason]) — mark task failed in QUEUE.md.
5. QUERY(user) — surface failure in plain language. Await instruction.

"Do not silently continue after a failure. Do not attempt creative workarounds without
user instruction." (line 136)

### 5.9 Foreground vs background (lines 140–146)
- At any time, **at most one foreground process** — the one actively producing output
  for user.
- Background processes (priority !BG) run when foreground is idle or waiting.
- Foreground tracked in `W:active-process`.
- Background PIDs tracked in `W:background-processes` (a list).

### 5.10 Process surprises / gotchas
- **`KILL` doubles as "complete"** — same verb for normal exit and forced termination.
  Hard to tell intent from the verb alone; the path is differentiated by status update
  before/after KILL.
- **DELETE of the process file** (line 122) on completion is destructive — "move content
  to episodic if needed" is conditional and underspecified.
- **CLEAR with wildcard** (`W:checkpoint-[process-id]-*`, line 119) — assumes the
  memory backend supports glob patterns. Not documented anywhere else.
- **CHECKPOINT-on-failure** (line 132) snapshots a known-broken state. Useful for
  post-mortem, but the snapshot might be unrecoverable.
- **No spec for child-process completion order** — PROGRAMS.md line 129 says "A parent
  process cannot complete until all its children are COMPLETE or FAILED" but PROCESS.md
  doesn't restate or enforce this.
- **Status enum spelling differs** from SCHEDULER.md (`COMPLETED` vs `COMPLETE`).
- **`Task-ID:` field is optional (`∅`)** — implies processes can run without a queue
  entry, contradicting the SCHEDULER's role as scheduler-of-everything.
- **Resume reads "the step recorded in the checkpoint"** but the checkpoint procedure
  (lines 73–78) only stores `W:` snapshot + a "state summary" — there's no formally
  defined "step pointer", so resume reliability depends on the summary being precise.
- **Background-process scheduling** is alluded to (line 143) but no specific
  mechanism connects `W:background-processes` to the SCHEDULER's queue.

---

## 6. PROGRAMS / PROGRAMS-SLIM deep dive

Files: `axon/programs/PROGRAMS.md` (157 lines) — full authoring guide.
`axon/programs/PROGRAMS-SLIM.md` (30 lines) — runtime rules; "load instead of
PROGRAMS.md during normal execution" (PROGRAMS-SLIM.md line 2).

### 6.1 Authoring requirements

**Template-driven creation** (PROGRAMS.md lines 9–18):
- Copy `axon/programs/PROGRAM-TEMPLATE.md` to `workspace/programs/[name].md`.
- Fill every `[FILL]` section.
- Run the bottom checklist before adding to workspace.
- Verify with `help [name]` and `menu` commands.

**Required structure (template-enforced)** (PROGRAMS.md lines 22–30):
1. **HELP block** — fields: `desc`, `usage`, `inputs`, `example`, `outputs`, `next`, `tips` (7 fields).
2. **▶ banner line** as first output: `"▶ [name]  ·  [context]"`.
3. **Plain-English FAIL messages** — must include what went wrong + how to fix it.
4. **"Next:" line** as last output — tells user what to do after.
5. **DONE([name])** matching the filename.

**Legacy program file format** (PROGRAMS.md lines 37–63 — for existing programs not
based on the template):
```markdown
# PROGRAM: [name]
Version:    [semver]
Author:     [user | agent | source]
Tools:      [comma-separated tool names required, or ∅]
Deps:       [other programs this calls, or ∅]
Priority:   [default priority if not overridden at EXEC time]
Model:      [preferred model/agent type, or "any"]

## PURPOSE
[One sentence: what this program does and when to use it.]

## INPUTS
[List of named inputs with type and whether required or optional]

## INSTRUCTIONS
[Numbered, imperative steps. Each step is one action. No ambiguity.]

## OUTPUTS
[What the program produces — stored where, in what format]

## ERROR HANDLING
[What to do when each step can fail]

## EXAMPLE
[Optional: a concrete example of inputs → execution → outputs]
```

The legacy format has no explicit "FAIL block" header — error handling lives in
"ERROR HANDLING" section. The template-driven format implies a more structured FAIL
treatment ("plain-English FAIL messages") but the format isn't defined in PROGRAMS.md.

**Priority flag**: declared via the `Priority:` header field (legacy format line 43).
PROGRAMS-SLIM.md line 16 confirms `Priority at EXEC overrides program default.`

**Phase tracking**: not formalized at the PROGRAMS level. The compiler PARSE phase
identifies `[PHASE]` tags from "major sections, stages, or named groups of steps"
(COMPILER.md line 39). Phases survive into the compiled output as English section
headers (line 226).

### 6.2 Loading a program

PROGRAMS.md (lines 67–77):
```
READ(programs/[name].md)
```
Pre-load checks:
1. File exists. IF ∅ → LOG(ERROR) + QUERY(user).
2. All declared tools ACTIVE in `tools/REGISTRY.md`. IF any ✗ → surface to user before running.
3. All declared dep programs exist in `programs/`. IF any ✗ → surface to user before running.

PROGRAMS-SLIM.md (lines 7–11) restates with ASSERT-style:
```
READ(programs/{name}.md)
ASSERT(file exists)                        | FAIL → LOG(ERROR) + QUERY(user)
ASSERT(tools declared ∈ W:tool-registry)   | surface missing tools before run
ASSERT(deps declared ∈ W:ws-programs/)     | surface missing deps before run
```
**Note**: SLIM uses `W:tool-registry` and `W:ws-programs/` (working-memory cached
indexes) — implying boot loads these once. Full PROGRAMS.md references `tools/REGISTRY.md`
and `programs/` directly. SLIM is the cached-fast-path version.

### 6.3 Running

PROGRAMS.md (lines 81–91):
```
EXEC([program-name], {input-key: value, ...}?)
```
Creates a process:
1. SPAWN(P-NNN, [program-name], {inputs}).
2. Follow program INSTRUCTIONS in order.
3. On completion: DONE for linked task, KILL the process.

Priority at EXEC time **overrides** program default (line 91).

PROGRAMS-SLIM.md (lines 14–17) restates with shorter syntax.

### 6.4 Subroutine semantics

PROGRAMS.md (lines 95–101):
```
EXEC([sub-program], args) → STORE(W:sub-result, result)
```
- Calling program **pauses** at this step until sub-program completes.
- Sub-program runs as **child process**.
- Sub-program failure → parent fails **unless parent has explicit error handling**.

PROGRAMS-SLIM.md (lines 19–22) condenses:
```
EXEC(sub, args) → STORE(W:sub-result, result)
Parent pauses until child completes. Child FAIL → parent FAIL (unless parent handles).
```

### 6.5 "Next:" line conventions
PROGRAMS.md lists "Next:" as field #4 of required structure (line 28): "Next: line as
last output — tell the user what to do after". Not formalized further. By convention
(seen in templates / generated programs), this is a single line beginning with `Next:`
that names a follow-up program or action.

### 6.6 Compiled vs source dispatch
COMPILER.md (RECOMPILATION section, lines 255–265) defines load-time logic:
- IF compiled file exists AND current → load compiled, skip source.
- IF compiled exists AND stale → WARN + QUERY(user).
- IF no compiled → load source directly.

So the dispatch is **compiled-first when available and current**. Source is fallback.
The agent never reads source if a current compiled version exists.

PROGRAMS-SLIM.md is itself an example of source/runtime separation: it's a slimmed
runtime version kept distinct from the full authoring spec. Same pattern as compiled
vs source for any program.

### 6.7 Switching models (PROGRAMS.md lines 105–120)
Programs may declare `Model:` preference. Valid values: `any`, `claude-code`,
`claude-sonnet`, `claude-opus`, or any name registered in `memory/longterm/models.md`.

Switch protocol when current ≠ requested:
1. LOG(INFO, "Program [name] requests model: [model]").
2. CHECKPOINT current state.
3. QUERY(user): "This program prefers [model]. Currently running on [current]. Proceed anyway, or switch?".
4. Await instruction.

**The OS does not switch models autonomously** (line 120). User must approve.

### 6.8 Composition (PROGRAMS.md lines 124–129)
- No nesting depth limit.
- Each level creates a child process.
- All children share the same scheduler and memory system.
- **Parent cannot complete until all children COMPLETE or FAILED.**

### 6.9 Versioning (PROGRAMS.md lines 133–141)
- PATCH = bug fix or clarification.
- MINOR = new step or changed behavior.
- MAJOR = complete rewrite or incompatible change.
- Old versions not kept in `programs/` unless explicitly archived.
- Episodic log captures which version was used per execution.

### 6.10 Built-in meta-programs (PROGRAMS.md lines 144–157)
Six programs are part of the OS, no separate file:
| Name              | Purpose                                                       |
|-------------------|---------------------------------------------------------------|
| `boot`            | Full kernel boot sequence (KERNEL.md STEPS 1–11)              |
| `resume`          | Check for interrupted session, offer to restore               |
| `checkpoint`      | Save working memory + episodic log entry                      |
| `status`          | Report queue, active processes, memory pressure               |
| `extend-lang`     | Guide adding a new symbol to LANG.md                          |
| `register-tool`   | Guide adding a new tool to REGISTRY.md                        |

Invoked by name: `EXEC(status)`.

### 6.11 Common authoring mistakes (inferable from rules)
- **Missing `▶` banner**: violates required structure #2; output looks ad hoc.
- **No "Next:" line**: violates required structure #4; user has no follow-up cue.
- **`DONE()` filename mismatch**: required #5; runtime/queue can't link the completion.
- **Speculative L: writes** in INSTRUCTIONS: violates MEMORY.md L: rule (only confirmed
  facts).
- **Unregistered tool in `Tools:` field**: pre-load check fires, but compiler only warns
  — runtime will fail.
- **Missing `Priority:`**: defaults to !NORM; harmless, but explicit is better.
- **Cryptic FAIL messages**: required #3 demands plain-English with "what went wrong +
  how to fix".
- **Calling a missing dep program** in `Deps:`: pre-load surfaces it; if not declared
  but called inline via EXEC, runtime fails late.
- **Skipping QUERY(user) on model switch**: violates the explicit "OS does not switch
  models autonomously" rule.
- **Recursing without checkpoint**: composition allows arbitrary depth; without
  checkpointing at child boundaries, resume after interrupt is lossy.

---

## 7. Cross-subsystem interactions

### 7.1 Compiler → REGISTRY (TOOLCHECK warnings)
- COMPILER.md Phase 2 (lines 88–91): every `[TOOL]` triggers `TOOL?([name])` against
  `tools/REGISTRY.md`.
- Unregistered → emit `TOOLCHECK([name]) # unregistered — add to tools/REGISTRY.md`
  as a warning (not an error).
- Phase 4 hoists repeated TOOLCHECK to phase header via Rule O6.
- The warning surfaces in the compiled file's WARNINGS section (lines 234–237) and
  in the post-compile user surface (line 251).
- At program load time (PROGRAMS-SLIM.md line 9), `ASSERT(tools declared ∈ W:tool-registry)`
  surfaces missing tools again — second guard.

### 7.2 Scheduler → Process (preemption snapshot)
- SCHEDULER.md preemption (lines 64–67) calls `SNAPSHOT(W:)` and stores it under
  `W:preempt-[task-id]`. This is a task-scoped snapshot.
- PROCESS.md PAUSE (lines 86–88) does its own CHECKPOINT (process-scoped, stored as
  `W:checkpoint-[process-id]-[n]`) and additionally stores `W:paused-[process-id]`
  with `{step, reason}`.
- These are **two parallel snapshot mechanisms** — task-level (preempt) and
  process-level (checkpoint). A preemption-pause path produces both a `W:preempt-T-NNN`
  and a `W:checkpoint-P-NNN-n`. Resume must use the process checkpoint, not the task
  preempt-snapshot (which is just W: state, not a step pointer).

### 7.3 Memory → Process (W:/L:/E: across process boundaries)
- All processes share W: in the current session (PROGRAMS.md line 128: "share the
  same scheduler and memory system").
- A subroutine `STORE(W:k, v)` is visible to its parent — and to siblings.
- PROCESS.md tracks foreground (`W:active-process`) and background list
  (`W:background-processes`) in W: — implies all processes can see and mutate
  foreground/background state.
- L: persists across sessions and across processes.
- E: streams (named, e.g., `E:case-log`) can be appended by any process — including
  parallel `SPAWN`'d processes. No documented locking.
- Checkpoint snapshots (`W:checkpoint-[pid]-[n]`) are also in W:, so they're shared
  across processes (other processes could read or accidentally clobber them).

### 7.4 Memory → Compiler (memory inlining in compiled programs)
- The compiler maps `[MEMORY]` tags to RETRIEVE/STORE/CLEAR ops with explicit scope
  (W:/L:/E:) at compile time (COMPILER.md line 67).
- Scope is decided once during PARSE/MAP and frozen into the compiled file. Run-time
  cannot rewrite scope.
- L: defaults like `L:eval-default-tolerance` and `L:retry-default-max` are baked in
  as named references during O7 fusion (COMPILER.md line 145, GRAMMAR.md line 305) —
  the compiled file references the L: key, not its value, so L: changes can affect
  compiled programs without recompilation.
- O4 (no-op store collapse) and O9 (dead-store elim) and O10 (redundant retrieve
  collapse) all reason about W: lifetime within a compilation unit. They cannot see
  cross-program memory effects.

### 7.5 Programs → Scheduler (priority dispatch)
- Programs declare a default `Priority:` in their header.
- EXEC-time priority overrides the default.
- Scheduler uses this for queue placement and preemption decisions.
- The starvation-promotion mechanism (SCHEDULER.md lines 84–89) is the only feedback
  channel back into priority — temporary boost.

### 7.6 Compiler → Scheduler (compiled programs and queue)
- Compiled programs declare INPUT/OUTPUT schemas. Input validation at runtime
  (COMPILER.md lines 240–243) can FAIL the program before it runs — this fails the
  linked task too.
- The compiled file's WARNINGS section is purely informational; scheduler never reads it.

### 7.7 Memory → Scheduler (preempt-log, queue persistence)
- `E:preempt-log` (SCHEDULER.md line 65) is an append-only episodic stream owned by
  the scheduler.
- `E:session-log` (SCHEDULER.md line 95) gets queue summaries at clean session end.
- QUEUE.md itself lives at `scheduler/QUEUE.md`, outside the memory tree — but it's
  effectively a persistent file. PAUSED entries persist across sessions (line 98).

### 7.8 Templates → Compiler → Programs
- Templates live in `compiler/templates/[name].tpl.md` (TEMPLATES.md line 7).
- Instantiated outputs live in `programs/compiled/[name]-[instance].cmp.md`.
- Substitution happens in the compiler (TEMPLATES.md lines 76–82); after substitution,
  Phase 3 (Optimize) **re-runs** on the result — substituted constants may unlock
  additional optimizations (line 58).

---

## 8. Open questions / gaps to investigate next cycle

### 8.1 Internal inconsistencies to resolve
1. **`COMPLETE` vs `COMPLETED`** — SCHEDULER.md vs PROCESS.md status enum mismatch.
   Which is canonical? Does any tool depend on one spelling?
2. **HIGH-as-preemption** — table says HIGH doesn't preempt CRIT; preemption rules
   list HIGH as preemption trigger. What's the actual rule? Does HIGH preempt NORM?
3. **`KILL` semantics** — PROCESS.md line 113 says "used for normal completion too".
   Is this the only completion verb? Does `DONE()` exist as a process-level op or only
   task-level?

### 8.2 Underspecified behavior to nail down
4. **`local/` scope** — user task spec mentions it; MEMORY.md doesn't. Search rest of
   repo for `local/` references and document semantics.
5. **Resume "step pointer"** — PROCESS.md line 107 says "from the step recorded in the
   checkpoint" but checkpoint procedure (lines 73–78) only stores W: + state summary.
   Where's the actual step pointer stored?
6. **Wildcard CLEAR** — `CLEAR(W:checkpoint-[pid]-*)` (PROCESS.md line 119): does the
   memory backend actually support glob, or is this an unimplemented future verb?
7. **Background scheduling** — `W:background-processes` (PROCESS.md line 145) is named
   but no spec defines how the scheduler picks from it.
8. **Promotion of preempted tasks** — what happens to a starvation-promoted task that
   gets preempted before completion? Promotion retained or lost?

### 8.3 Performance / token gaps
9. **O7 fusion shape rigidity** — only the exact `EXEC + EVAL + IF + RETRY` order
   triggers fusion. How often do programs use slightly different shapes? Worth a
   heuristic-broadening rule O11?
10. **No constant folding** in the optimizer — substituted template params survive as
    references. Worth folding constants where possible?
11. **No cross-phase optimization** — O1/O5 merge within a phase. Cross-phase READs
    or LOGs aren't merged. Could be significant in long programs.
12. **Token estimator is `words × 1.3`** — wildly approximate. Is the benchmarker
    correcting or just recording? Real ratios in `memory/longterm/benchmark-log.md`
    would tell us.

### 8.4 Coverage / grammar gaps to widen
13. **Verbs missing from grammar**: time/date math, resource locking, rate limiting,
    pagination/cursor, generic negation. All fall back to literal EXEC today.
14. **Promotion threshold** — `≥ 3 across different files` (GRAMMAR.md line 219). Any
    grammar misses currently above threshold and not yet promoted?
15. **EVAL/RETRY/TEE were retro-added** — what other LANG primitives exist without
    grammar coverage today?

### 8.5 Surface-area cleanups
16. **Two memory snapshot mechanisms** (preempt vs checkpoint) — could converge.
17. **WARN-only output validation** (COMPILER.md line 245) — should it become opt-in
    FAIL?
18. **No quota / rotation on episodic memory** — long deployments will accumulate
    indefinitely. Does anything compact E:?
19. **Staleness detection requires user QUERY** — non-interactive CI use would never
    auto-recompile. Should there be an `auto-recompile=true` mode?
20. **Two memory file naming conventions** for E: (date-keyed `[YYYY-MM-DD]-[session-id].md`
    vs named-stream `[name].md`) without an index — programs pick at write time;
    readers must guess.

### 8.6 Cross-subsystem questions for C2-P2 / C2-P3
21. **Is W: actually shared across processes?** PROGRAMS.md says yes by implication;
    no explicit isolation/namespacing. Any concurrency primitives?
22. **What does `compile-write.py` actually do?** It's a tool, opaque from the spec.
    Worth reading the source to confirm the spec matches behavior.
23. **What does `run.py` actually do?** Same — claimed to handle all
    TOOL/LOG/STORE/RETRIEVE/CLEAR ops mechanically. Important for understanding the
    fast-path/reasoning-path split.
24. **Where does the "PREEMPT" op (GRAMMAR.md line 167) actually execute?**
    Scheduler-level op; not in the SCHED API list. Implicit?
25. **HANDOFF (GRAMMAR.md lines 267–272)** — no spec elsewhere. Is this implemented or
    grammar-only?

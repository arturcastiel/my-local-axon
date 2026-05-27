# C1·P1 — AXON Kernel + Core Map

> Source: parallel exploration agent, 2026-05-16. AXON repo at `/mnt/c/projects/axon`.

## 1. FILE INVENTORY

### Layer 1: Kernel (`axon/`) — write-gated by `L:dev-mode`
| File | Purpose |
|------|---------|
| `KERNEL-SLIM.md` (v1.1.4) | Single-file boot entry. 12 core rules, identity contract, 9 compliance gates, R11 (AXON-LANG mandatory), phase tracking, boot steps 1–5, my-axon backup hard rule |
| `BOOT.md`         | G-01 identity init, G-10 workspace validate, G-11 harness detect, my-axon auto-init flow, session resume, project re-assertion, pre-turn dispatch, workspace-backup auto-push (!BG), session-save shutdown |
| `COMMANDS.md`     | Command parsing: identity gate first, mode shortcuts 1-7/D/0, exec order, free-text routing, dispatch pre-flight, --input k=v seeding, mode badge, fuzzy unknown match |
| `DEVELOPER.md`    | Contributing to axon/ core. dev-mode prereq. Version bump rules, CHANGELOG discipline, path resolution (no hardcoded paths), `_axon_paths.py`, `lint_paths.py`, EXTEND protocol |
| `OUTPUT-LAYER.md` | Per-response footer: state gather (conf/drift/ctx/turn), 3 formats (compact/full/minimal), teardown (CLEAR + drift reset), 0–100 conf scale |
| `HOWTO.md`        | Quick reference: REPL, first workflow, templates, scopes, benchmarking, EXTEND |

### Layer 2: Core (`axon/core/`) — load on demand
| File | Purpose |
|------|---------|
| `LANG.md` (v2.3.0) | 14 base ops, 20+ symbols, 5 priority flags, 3 memory scopes, 14 ACTIVE extensions (EXT-001 .. EXT-014), EXTEND protocol |
| `TRANSLATE.md`     | Hide ops by default, status mapping, QUERY plain English, log surfacing, error translation, "show your reasoning" → structured prose |
| `OUTPUT.md`        | Output mode definitions (PYTHON_FAST, AXON_SEMANTIC, HYBRID, RAW) |
| `RUN-HEADER.md`    | Compiled program execution format |

### Compiler (`axon/compiler/`)
| File | Purpose |
|------|---------|
| `COMPILER.md` (v1.1.0) | 4 phases: PARSE (14 tags), MAP (vs GRAMMAR.md), OPTIMIZE (10 rules), OUTPUT (`.cmp.md` write + benchmark log) |
| `GRAMMAR.md` (v1.1.0)  | NL→symbolic mapping. Misses → compiler warnings |

### Scheduler (`axon/scheduler/`)
| File | Purpose |
|------|---------|
| `SCHEDULER.md` | 5 priority levels, FIFO within level, preemption (PAUSE→SNAPSHOT→APPEND), starvation auto-promote after 10 cycles |
| `QUEUE.md`     | Live task queue, agent-writable |

### Memory (`axon/memory/`)
| File | Purpose |
|------|---------|
| `MEMORY.md` | W:/L:/E: scopes. W:≤10 idle target. Retrieval order W→L→E→QUERY (no skip, no query for L:-stored). Session lifecycle. Context-pressure handling |

### Processes (`axon/processes/`)
| File | Purpose |
|------|---------|
| `PROCESS.md` | SPAWNED→RUNNING→COMPLETED|FAILED|PAUSED. Mandatory checkpoints. Foreground/background distinction |

### Tools (`axon/tools/`)
| File | Purpose |
|------|---------|
| `REGISTRY.md`  | Master list, status (ACTIVE/PLANNED/OPTIONAL). USAGE RULE: covered op → tool mandatory. Missing → TOOLCHECK warning |
| Tool-specific .md | Per-tool: purpose, inputs, outputs, errors, examples |

### Logging (`axon/log/`)
| File | Purpose |
|------|---------|
| `LOG.md` | 5 levels, mandatory event list, format `[YYYY-MM-DD HH:MM:SS] | [LEVEL] | [source] | [message]` |
| `entries/{date}.md` | Daily append-only |

### Programs (`axon/programs/`)
| File | Purpose |
|------|---------|
| `PROGRAMS.md`       | Full authoring guide (load on demand) |
| `PROGRAMS-SLIM.md`  | Runtime: load → run → DONE → KILL. Subroutine semantics. Required structure (HELP, banner, FAIL, "Next:") |
| `compiled/`         | TOOL(compile-write) output, `.cmp.md` |
| Individual programs | identity.md (gate render), interactive.md (REPL), menu.md (shell), mode-*.md, dev-*.md |

### Archive
| File | Purpose |
|------|---------|
| `archive/KERNEL-LEGACY.md` | Full v0.1.0 kernel (pre-slim) |

---

## 2. IDENTITY MODEL

**Primary identity**: AXON — harness engineering OS. Not chatbot/assistant/model/LLM.

**Execution-layer disclosure**: permitted ONLY inside `EXEC(axon/programs/identity.md)` AND files under `workspace/harness/`. Anywhere else as self-reference = violation.

**Cognition-layer**: zero-subject. Ops execute directly. Forbidden: "I", "AXON", "The system", "let me", "I think" — all R11 (!CRIT) violations.

**Cognition frame**:
- `L:cognition-frame = "AXON-OS"` (set at G-01)
- `W:reasoning-mode = "kernel-ops"`
- Mandatory medium: AXON-LANG ops only
- Prose reasoning chains forbidden
- Violation: LOG(ERROR) + HALT + reframe

**G-02 mid-program re-assertion**: every 5 turns inside `LOOP(true)`, ASSERT cognition-frame OR HALT.

**Identity gate**: fires on identity-triggered input. Calls `EXEC(axon/programs/identity.md)` → `DONE(identity-gate)`. Disclosure gated by `L:disclose-execution-layer` (default true) AND both `L:host-harness` + `L:host-model` set by harness contract. Unset → minimal AXON identity, never guess.

**Harness contract (G-11)**: env detection → `EXEC(workspace/harness/{file}.md)` → sets `L:host-harness` + optionally `L:host-model`. Keys ONLY by harness contract, never inferred.

---

## 3. MEMORY SCOPES & SEMANTICS

| Scope | Lifetime | Location | Discipline |
|-------|----------|----------|------------|
| W:    | session-only | `workspace/memory/working/` | ≤25 keys exec, ≤10 idle. Prune aggressively |
| L:    | persisted forever | `workspace/memory/longterm/` | Confirmed-true facts only. RETRIEVE before QUERY |
| E:    | append-only forever | `workspace/memory/episodic/` | Session chronicle. Never delete |
| local/| machine-specific, gitignored | `workspace/memory/local/` | NOT via RETRIEVE(L:). READ direct or QUERY |

**my-axon scope** (`W:myaxon-*`): user runtime data, loaded at boot via `my-axon/MYAXON.md`. Keys: `myaxon-path`, `-dev-projects`, `-memory`, `-longterm`, `-episodic`, `-working`, `-local`, `-log`, `-igap`, `-turns`, `-chats`, `-plans`, `-libraries`, `-generated`. Absent until init runs; programs must not assume.

---

## 4. CORE RULES (immutable — no override possible)

1. Read KERNEL-SLIM first, every session
2. Never execute task without instruction source
3. No float arithmetic without TOOL(calculator) — statically enforced by R3
4. Always log significant events before/after
5. Always CHECKPOINT before yielding mid-task
6. Never fabricate tool results — LOG(ERROR) + QUERY(user)
7. Symbolic language internal only — translate user-facing
8. Rule conflicts: higher number wins; equal: QUERY
9. axon/ writes need `L:dev-mode ≡ true` — user intent ≠ permission
10. KERNEL-SLIM edits require dev-mode + direct file edit (never by programs)
11. **All internal reasoning MUST be AXON-LANG** — !CRIT, no bypass
12. **Menu always rendered in full** — partial = shell crash + re-render

---

## 5. COMPLIANCE GATES (active at every decision point)

### Response gate (!CRIT, before every output)
1. STORE(W:reasoning-trace, {ops}) — MANDATORY first (R11), ≥1 op, no prose subjects
2. ASSERT(instruction-source-identified)
3. TOOL(verify, output, --text) — enforces R7/R_COHERENCE/R_REASONING_TRACE
4. ASSERT(W:active-output-mode applied)
5. Prompt logging (!BG) IF enabled
6. Turn logging (!BG, default on) → `workspace/log/turns/{date}.md`
7. Output layer footer (conf/drift/ctx/turn) IF enabled

### Cognition-language gate (!CRIT, before reasoning step)
- ASSERT both `L:cognition-frame ≡ "AXON-OS"` AND `W:reasoning-mode ≡ "kernel-ops"`
- Test: can step be written as LANG op without info loss? NO → violation
- Not bypassable. G-02 mid-loop re-assert every 5 turns.

### Coherence guardian (every output)
- Persona-bleed phrases: "As an AI", "I'm just a", "I'm here to help", "I think", LLM brand names as self-reference (EXCEPT inside identity.md + workspace/harness/)
- Cognition third-person in trace: "AXON will/does", "The system will/does"
- Violation → TOOL(drift, record) + HALT + rewrite
- Proactive ASSERT(identity-contract) every 10 turns

### Write gate (axon/ writes)
- TOOL(verify, action) or TOOL(enforce, check-write)
- `L:dev-mode ≠ true` → HALT "❌ axon/ is locked"
- NO alternative paths
- User request ≠ override
- No-queue rule: blocked commands never queued; user must RE-STATE after enabling dev-mode

### Active-program interrupt gate (!CRIT, every input before parse)
- IF phase ≠ ∅ AND not :done/:failed/:aborted:
  - Continuation tokens (yes/no/c/q/^\d+$) → PASS
  - Else → [K]eep / [I]nterrupt / [A]bort prompt
  - K: continue, discard input
  - I: CHECKPOINT + STORE _paused-program/phase + CLEAR active-phase → EXEC(input)
  - A: CHECKPOINT + abort + EXEC(input)

### Arithmetic gate
Trigger: float / money / % / >2 operands / sqrt-power-log-trig → TOOL(calculator) mandatory. Statically by R3.

### Confidence gate
`CONFIDENCE(n)` < `L:confidence-threshold` (default 0.7) → LOG(WARN) + QUERY. Never silent.

### Inference gate
`inf ← L:inference-mode | 3`
- ≥8: autonomous (skip QUERY, log inferred)
- ≤2: QUERY always
- 3–7: confidence gate normally

### Inference gap tracker (!BG)
4 types recorded: low-confidence, semantic-search, fallback-exec, absent-instruction. Log: `workspace/log/igap/{date}.md`. Surface on `igap report` or session-end.

### Inference-mode lock
`L:inference-mode-locked ≡ true` AND any STORE(L:inference-mode, *) AND `L:dev-mode ≠ true` → LOG(ERROR) + HALT.

### Halt mode
`L:halt-mode = strict` (default) HALT on gate failure. `soft` ⚠ SOFT_HALT + QUERY. CORE RULES gates always strict.

### Context pressure gate (before phase transitions)
- TOOL(context, status)
- critical (>85%): CHECKPOINT + HALT, resume later
- high (>60%): CHECKPOINT + warn + continue
- Skip: read-only programs, `W:_skip-pressure-gate ≡ true`

### Program phase tracking (every program MUST)
- Entry: STORE phase:start + CHECKPOINT
- Step N: STORE phase:step-N before side-effect
- DONE: STORE phase:done + CHECKPOINT
- FAIL: STORE phase:failed + CHECKPOINT

### Override attempt gate
Bypass attempt → LOG(ERROR) + HALT "❌ violates Core Rule N. Cannot be bypassed." NO alternative paths.

---

## 6. LANGUAGE OPS (v2.3.0)

**Core ops**: READ WRITE APPEND QUERY · STORE RETRIEVE CLEAR SNAPSHOT RESTORE · EXEC SPAWN KILL PAUSE RESUME · SCHED PREEMPT DEFER COMPLETE · TOOL TOOL? · IF/→| LOOP UNTIL ASSERT GUARD · LOG TRACE · EMIT ON · CONFIDENCE PROGRESS HANDOFF TEE · EVAL RETRY

**Symbols**: → ⊕ ⊗ ∅ ✓ ✗ ? ! ↑ ↓ ~ ∈ ∉ ∀ ∃ ≡ ≠ Δ Σ #

**Priority flags**: !CRIT !HIGH !NORM !LOW !BG

**Shorthands**: CHECKPOINT, DONE(id), FAIL(id, reason), RESUME?

**Active extensions** (EXT-001 .. EXT-014): CLAMP, RAND, FIND, SORT, UPDATE, COUNT, CONFIDENCE, EMIT, ON, HANDOFF, PROGRESS, EVAL, RETRY, TEE — all ACTIVE.

**Library ops**: SCAN MKDIR DELETE-DIR COPY-FILE COPY-RECURSIVE COPY-DIR-CONTENTS CONCAT-FILES REPLACE-PATH FILE-EXISTS DIR-EXISTS FILE-MTIME FILE-SIZE TRUNCATE BASENAME STEM EXTENSION SPLIT JOIN SORT UNIQUE FILTER MAP GROUP-BY FIRST LAST TAIL COUNT SUM MAX REPLACE REPLACE-LINE REPLACE-SECTION PAD REGEX-ESCAPE SHELL-QUOTE EXTRACT PARSE NOW EPOCH DERIVE

---

## 7. BOOT FLOW (full sequence)

**G-01 identity frame init** (end of step 1)
```
STORE(L:cognition-frame, "AXON-OS")
STORE(W:reasoning-mode, "kernel-ops")
LOG(INFO, "boot: identity frame set")
```

**Step 2 — TOOL(boot) + TOOL(prefs)**
- STORE paths/dev-mode/output-mode/tool-registry
- Project config merge if present
- Surface pending tasks

**G-10 workspace path validation**
```
ASSERT(DIR-EXISTS(W:ws-programs)) | HALT("Workspace path invalid")
```

**my-axon detection** (after G-10)
- IF `MYAXON.md` exists → EXEC it (loads W:myaxon-* keys)
- ELSE → QUERY [F]resh / [C]lone / [S]kip
- F/blank → STORE init-mode "fresh" + EXEC(my-axon-init)
- C → STORE "clone" + EXEC(my-axon-init)
- S → LOG(WARN) — limited mode

**G-11 harness detection** (after my-axon)
- env.CLAUDECODE → claude-code.md
- env.COPILOT_AGENT or .github/copilot-instructions.md → copilot.md
- else → generic.md
- LOG(INFO, "boot: harness — {host} · model: {model}")

**Step 3 — Resume + dispatch**
- Restore active chat (TOOL(index, list, --type chat))
- Cron check (TOOL(cron, check) if overdue)
- Previous session resume prompt
- Project state re-assertion
- Pre-turn dispatch check activation

**Step 4 — Render banner**
- workspace name + tools + output-mode
- IF cron overdue → "⏰ Scheduled: {labels}"
- IF first-run → "New to AXON? Type 'quickstart'"

**Step 5 — Show menu**
- EXEC(workspace/programs/menu.md)

**Workspace backup auto-push (!BG)** — non-blocking, after banner, before menu
- IF backup-enabled true → EXEC(workspace-backup push)
- IF backup-enabled ∅ AND not skipped → surface "💾 Workspace backup not configured"

**Shutdown hook**
- TOOL(session-save, --workspace workspace)
- "✓ Session saved. Type 'axon boot' to resume."

---

## 8. COMPILER MODEL

**Dispatch**: source `.md` from programs/ OR compiled `.cmp.md` via TOOL(run).

**Staleness**: source mtime > compiled mtime → LOG(WARN) + QUERY user.

**4 phases (no skips, strict order)**:

**PHASE 1 PARSE**: extract 14+ tags (PHASE, STEP, DECISION, BRANCH, LOOP, TOOL, MEMORY, LOG, ASSERT, PARALLEL, ESCALATE, END, INPUT-SCHEMA, OUTPUT-SCHEMA, CONFIDENCE, EVENT) → W:parse-tree → LOG(DEBUG)

**PHASE 2 MAP**: convert via GRAMMAR.md
- Order: PHASE → INPUT/OUTPUT → MEMORY (scope heuristics) → TOOL (verify vs REGISTRY; unregistered → TOOLCHECK warning) → ASSERT → STEP → DECISION/BRANCH → LOOP → PARALLEL → ESCALATE → LOG → END → CONFIDENCE → EVENT
- Store: W:mapped-ops, W:warnings

**PHASE 3 OPTIMIZE** — 10 rules
| # | Rule |
|---|------|
| O1 | Merge sequential READs |
| O2 | IF single-branch → GUARD |
| O3 | Apply LANG shorthands |
| O4 | Collapse no-op stores |
| O5 | Merge adjacent LOGs |
| O6 | Hoist repeated TOOLCHECK |
| O7 | Fuse EXEC+EVAL+IF+RETRY → RETRY-WITH-EVAL |
| O8 | Dedup TEE keys |
| O9 | Dead-store elimination |
| O10 | Redundant RETRIEVE collapsing |

Compute: source-tokens, compiled-tokens, compression-ratio.

**PHASE 4 OUTPUT**: TOOL(compile-write) → `programs/compiled/[name].cmp.md` (header + INPUT/OUTPUT SCHEMA + ops by phase + WARNINGS) + APPEND(E:compiler-log) + TOOL(benchmark, record).

**Benchmarking**: >40% compression = high-value, 15-40% moderate, <15% marginal.

---

## 9. SURPRISES / NON-OBVIOUS BEHAVIORS

1. **Cognition-layer = zero-subject** — "I think", "let me", even "AXON will" all forbidden in reasoning. !CRIT.
2. **Programs NEVER write to axon/** — write-gate enforces mechanically; user instruction ≠ override.
3. **CHECKPOINT mandatory before yielding** — no checkpoint = lose state on interrupt.
4. **W: discipline** — >25 keys during exec, >10 idle bloats context. No warning until CRITICAL (85%); HIGH (60%) is warning-only.
5. **Output-layer drift adjusts confidence auto** — drift.modifier penalizes W:response-confidence in footer.
6. **Inference-mode lock blocks changes** — once locked, no STORE without dev-mode.
7. **Compiled programs don't re-load source** — system prefers .cmp.md if not stale; source edits require recompilation.
8. **Preemption clears W: snapshot** — preempted state under W:preempt-[id]; resume may surprise.
9. **Tool missing = TOOLCHECK warning, not silent fallback** — unregistered tool fails loud at runtime.
10. **EVAL doesn't auto-retry** — separate from RETRY. Fused via O7 (RETRY-WITH-EVAL).
11. **Menu truncation = shell crash** (Core Rule 12) — full required, mandatory re-render on partial.
12. **No-queue rule** — blocked commands NOT auto-executed after dev-mode; must RE-STATE.
13. **local/ not via RETRIEVE(L:)** — gitignored, read directly or QUERY.
14. **Episodic memory append-only forever** — never deleted; semantic-search across E: can slow.

---

## 10. OPEN QUESTIONS / GAPS

1. `context.py` registered PLANNED but referenced by output-layer — not yet shipped.
2. `workspace/preferences/tools/` per-tool filters — under-documented.
3. `TOOL(dispatch, feedback)` mechanism exists but `smart-dispatch.md` not fully specified.
4. `rtk` integration depth unclear in core docs.
5. Compiled program schema validation — rules present, test coverage unclear.
6. Compiled program execution mechanics in `run.py` not fully explained.
7. Compression ratio benchmarking analysis method unnamed.
8. Harness model auto-report on first turn — example-less.
9. Priority promotion magic number "10" for starvation — no tuning rationale.
10. Identity drift penalty magnitude formula unspecified.
11. Cognition-language drift check interval "5" hard-coded — no rationale.
12. MYAXON.md auto-execution format inferred but not explicit.

---

## 11. ARCHITECTURAL INSIGHTS

- **Three-layer boot optimizes token load**: G-01 (~50t cognition lock) → Step 2 (~200t tools/paths) → G-11 (~30t harness) ≈ 280t vs legacy ~3000t.
- **Lazy loading saves ~6000t/session**: KERNEL-SLIM only at boot, subsystems on-demand.
- **Two execution paths**: source (human-readable, slower), compiled (symbolic, ~30% faster).
- **AXON-LANG ≈ 5–10× denser than prose** — reasoning compression.
- **Memory scope lifecycle**: W:="today", L:="forever", E:="audit trail".
- **Interrupt tolerance at OS level** — active-program-gate is unique; few kernels enforce this.
- **Output layer = coherence dashboard**: confidence + drift + context + turn = full visibility.
- **Autonomous git push** restricted to my-axon backup only — hard rule, no exceptions.
- **Tool registry = capability gating** — unregistered tool blocks; prevents silent fallback.

---

## SUMMARY FOR DOWNSTREAM

This map provides:
1. Complete file inventory with one-line purposes
2. Identity model (cognition-layer zero-subject, harness contracts, disclosure)
3. Memory scope semantics + lifecycle
4. 12 Core Rules + all 9 gates with trigger + action
5. LANG.md taxonomy with 14 active extensions
6. Boot flow G-01/G-10/G-11 + my-axon + harness + backup
7. Compiler 4-phase pipeline + 10 optimize rules
8. 14 non-obvious behaviors
9. 12 open questions
10. Architectural insights for token optimization

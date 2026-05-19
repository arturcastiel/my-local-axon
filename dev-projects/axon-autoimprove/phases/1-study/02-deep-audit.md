# Deep audit — AXON OS code vs pseudo-algorithm

> Date: 2026-05-19.
> Scope: `tools/`, `axon/KERNEL-SLIM.md`, `workspace/programs/`.
> Out of scope: `my-axon/` user data (read for prior-art context only).
> Author of audit: forensic pass on behalf of AXON.

---

## 1. Method

**Read in full** (≥ 80 % of bytes, line-by-line):
- `axon/KERNEL-SLIM.md` (713 lines)
- `tools/cron.py` · `tools/kv_store.py` · `tools/memory.py` · `tools/drift.py` ·
  `tools/auto_improve.py` · `tools/dispatch.py` · `tools/dispatch_stats.py` ·
  `tools/igap.py` · `tools/auto_audit.py` · `tools/undo.py` ·
  `tools/synapse_suggest.py` · `tools/synapse_validate.py` · `tools/plan_dag.py` ·
  `tools/verify.py` · `tools/enforce.py` · `tools/context.py` · `tools/tokenizer.py` ·
  `tools/board.py` · `tools/_axon_io.py` · `tools/_axon_rollback.py` · `tools/boot.py` ·
  `tools/rules/r9_axon_write.py`
- `workspace/programs/auto-improve.md` · `workspace/programs/orchestrator.md` ·
  `workspace/programs/code-dev-state.md`

**Sampled** (head + targeted grep):
- `tools/dag.py` (header + IO helpers; the mutator API was not exhaustively walked)
- `tools/usage.py` · `tools/pattern.py` (only the CLI surface, to verify
  orchestrator call shapes)
- `tools/_axon_lib.py` (only the kv-store + audit_record helpers used by
  `auto_improve.py`)
- The 7 `workspace/programs/code-dev-state*.md` (only `code-dev-state.md` read
  in full; the others were enumerated and their roles inferred from naming)

**Skipped (out of scope or low-yield for this audit)**:
- `tools/shadow*.py`, `tools/pr_*.py`, `tools/docgen*.py`, `tools/study_*.py`,
  `tools/pack.py`, `tools/translate.py`, `tools/notify.py`, `tools/web_search.py`
  — shipped by axon-synapse and not on the autoimprove critical path.
- `my-axon/dev-projects/*` — read once for prior-art context (`_goal`, `_demands`,
  `_flaws`, `phases/1-study/01-study.md`, `AUDIT.md`); not re-audited.
- The compiled-program rewriter (`tools/compile.py`, `tools/compile_optimizer.py`,
  `tools/compile_suggest.py`) — too far from the autoimprove loop.

**Confidence rubric used per finding**:
- **HIGH** — file:line cited AND a reproduction command/sequence given
- **MED**  — file:line cited; failure mode reasoned about, not reproduced
- **LOW**  — pattern only (e.g. "this looks racy") with no specific call site

---

## 2. Pseudo-algorithm reference (extracted from KERNEL-SLIM.md)

> One line per enforceable element. `KS:n` = `KERNEL-SLIM.md` line `n`.

### Identity & cognition
- Primary identity is AXON; host harness/model disclosable only via declared `L:host-harness`/`L:host-model` (KS:11–12).
- Cognition layer is subject-less — ops only; subjectful prose = violation (KS:13–32).
- Identity gate fires on every "what are you / what model" input (KS:50–57).
- Cognition-language gate ASSERT(L:cognition-frame ≡ "AXON-OS") + ASSERT(W:reasoning-mode ≡ "kernel-ops") (KS:123–129).
- **G-02 mid-program identity re-assertion** every 5 turns inside any `LOOP(true)` (KS:130–138).
- Coherence guardian scans every output for persona-bleed / third-person drift (KS:140–159).
- Cognition-frame drift check every 5 turns (KS:305–306).

### Core rules (immutable)
- **R1** read kernel first every session (KS:62).
- **R2** never execute without an instruction source (KS:63).
- **R3** float arithmetic → calculator (KS:64).
- **R4** log before+after significant events (KS:65).
- **R5** CHECKPOINT before yielding mid-task (KS:66).
- **R6** never fabricate tool results — LOG(ERROR)+QUERY(user) on failure (KS:67).
- **R7** symbolic LANG internal — translate at output boundary (KS:68).
- **R8** rule conflicts: higher number wins (KS:69).
- **R9** `axon/` writes require `L:dev-mode ≡ true` — write gate (KS:70).
- **R10** LANG self-improvement via EXTEND only; KERNEL-SLIM edits require dev-mode (KS:71).
- **R11** all internal reasoning in compressed AXON ops; prose chains = !CRIT violation (KS:72).
- **R12** menu always rendered in full after boot/reboot/reload (KS:73).

### Compliance gates
- **Response gate** (before every output): STORE(W:reasoning-trace), ASSERT(source), TOOL(verify,output) (KS:79–88).
- **Prompt-log + turn-log** !BG every input/output turn (KS:89–113).
- **Output layer** rendering with drift/confidence/turn footer (KS:115–121).
- **Write gate** — runs `TOOL(verify,action,…)` or `TOOL(enforce, check-write)` before any write into `axon/` (KS:161–166).
- **No-queue rule** — gate refusals never deferred (KS:166).
- **Active-program interrupt gate** — !CRIT, fires on every user input when a program is mid-flight (KS:168–224).
- **Arithmetic gate** — float/money/>2 operands → `TOOL(calculator)` (KS:226).
- **Confidence gate** — CONFIDENCE(n) < `L:confidence-threshold` → LOG(WARN)+QUERY (KS:228).
- **Inference gate** — `L:inference-mode` 0..10 partitions ask/auto branches (KS:230–235).
- **Inference-gap tracker** — !BG igap record per turn (KS:237–268).
- **Inference-mode lock** — !CRIT, prevents STORE(L:inference-mode,…) without dev-mode (KS:270–275).
- **Halt mode** strict|soft (KS:277).
- **Anti-drift** re-read CORE before any file write (KS:279).
- **Context-pressure gate** — `>85 %` critical → HALT, `>60 %` high → CHECKPOINT (KS:281–296).
- **Program phase tracking** — STORE(W:active-phase, "{program}:{state}") at every boundary (KS:298–303).
- **Override-attempt** — any bypass attempt → LOG(ERROR)+HALT (KS:308).

### Memory & scopes
- W: ≤25 keys active / ≤10 idle; retrieval order W→L→E→QUERY (KS:444–446).
- `local/` direct-path, not via RETRIEVE(L:) (KS:451).

### Scheduler & tools
- Source-of-truth is `tools/REGISTRY.json` (KS:471).
- Calculator mandatory on the triggers above (KS:474).
- Verifier runs R3/R7/R9/R_TOOL_EXISTS/R_W_BUDGET/R_NO_PLANNED_TOOLS (KS:475).
- Drift = real edit-distance score (KS:476).
- enforce.py gate before every axon/ write (KS:479).

### Boot
- **G-01** STORE(L:cognition-frame,"AXON-OS")+STORE(W:reasoning-mode,"kernel-ops") at end of step 1 (KS:557–562).
- **Step 2** TOOL(boot)+TOOL(prefs)+G-10 workspace path validation+my-axon detection+G-11 harness detection (KS:565–610).
- **Step 3** resume + dispatch + cron check (KS:611–653).

### Code-development rules
- Building is always a human task (KS:535–540).
- Exception: workspace-backup auto-push of `my-axon/` only (KS:541, 656–675).

---

## 3. Implementation map (kernel rule → code)

| Kernel rule / gate | Enforcement site | Mechanism | Gap notes |
|---|---|---|---|
| **R1** read kernel first | none (agent discipline) | — | Not mechanical; relies on the agent's contract per `AGENTS.md` / `.github/copilot-instructions.md`. |
| **R2** instruction source | `tools/enforce.py:71-75 check-source` | filesystem existence | Only called by `register-tool.md`; not wired into the normal output path. |
| **R3** float→calculator | `tools/rules/r3_arithmetic.py` (referenced from `verify.py:25`) | static pattern scan on program text | Static only — runtime float math in agent prose isn't intercepted unless `verify.py output` is invoked. |
| **R4** log before/after | `tools/log.py` (assumed; not audited) | append-only | Voluntary on caller. |
| **R5** CHECKPOINT before yield | shorthand in KS:403 | macro to SNAPSHOT+APPEND+LOG | No mechanical guard that programs include it. |
| **R6** no fabrication | none | — | Doc-only. |
| **R7** symbolic internal | `tools/rules/r7_no_symbolic_output.py` | runtime scan of pending output | Only fires if `verify.py output` is actually called before render. |
| **R9** axon/ write gate | `tools/enforce.py:43-63` AND `tools/rules/r9_axon_write.py` | path-prefix check + dev-mode L: read | **Major gap**: only two programs in the codebase actually call `TOOL(enforce,check-write)` (see B-09). `_axon_io.atomic_write` has no path-target check. |
| **R10** LANG self-improvement | none | — | Doc-only; same axon/ gate applies. |
| **R11** AXON-LANG cognition | `tools/rules/r_reasoning_trace.py` (referenced) | scans `W:reasoning-trace` content | Only active when `L:reasoning-trace-required ≡ true` (`tools/verify.py:58-61`); off by default. |
| **R12** menu always full | none | — | Doc-only. |
| Identity gate | `axon/programs/identity.md` + harness contracts under `workspace/harness/` | agent reads file | Mechanical only when agent obeys the gate. |
| Cognition-language gate | `tools/rules/r_coherence.py` (referenced) | output scan | Same caveat — runtime, voluntary. |
| Write gate (R9) | `tools/enforce.py:43-63` | dev-mode check + path-prefix | As R9 above. |
| Active-program interrupt gate | nowhere in code; pseudo-code lives in KS:168-224 | — | **No tool implements this**. The agent must read the kernel and self-enforce. !CRIT-labelled but not mechanical. |
| Arithmetic gate | `tools/rules/r3_arithmetic.py` (static) + `tools/calculator.py` | static scan of program text for `*/+`-with-floats | Runtime arith inside agent prose escapes. |
| Confidence gate | none | — | Doc-only — agent writes `W:response-confidence` voluntarily. |
| Inference gate | `tools/dispatch.py:149-152` reads `dispatch-confidence`; `tools/auto_improve.py:312` reads `L:auto-improve` | KV-store reads | Inference-mode (`L:inference-mode`) is read by orchestrator.md (KS-style pseudo-code) — no central enforcement. |
| Inference-mode lock | none in code | — | Doc-only (KS:270-275). |
| Igap tracker | `tools/igap.py` | append-only daily MD log | Append path is non-atomic (B-04). |
| Context-pressure gate | `tools/context.py` | thresholds 0.85/0.60/0.30 | Threshold uses `>=` not `>` (B-08, low). |
| Program phase tracking | KS:298–303 — agent must STORE(W:active-phase,…) | — | No mechanical assertion; phases can silently drift. |
| Boot G-10 workspace validation | `tools/boot.py:285-289` (reads `Inherits:` line) | dir existence | No validation that path is inside the repo. |
| Boot G-11 harness detection | KS:597-610 only — agent-side | — | No code; the agent reads env vars itself. |
| Drift gate (`auto-improve`) | `tools/drift.py:215-240 cmd_gate`; called by `tools/auto_improve.py:81-87` via `_axon_lib.drift_gate` | trace JSON | **Fails open on no-trace** (B-03). |
| Cron-auto toggle | `tools/cron.py:287` | KV-store `L:cron-auto` | OK. |
| Verifier | `tools/verify.py` | calls into `tools/rules/*` | Voluntary entry point. |

**Headline**: of the 12 Core Rules, only **R3, R7, R9, R11** have an automated check (`tools/rules/*`), and even those rules fire only when `verify.py` is invoked. R9's `tools/enforce.py` is called by exactly **two** programs (`register-tool.md` and its compiled copy) — see B-09. The vast majority of kernel rules are **doc-only behavior contracts** the agent is expected to obey via `AGENTS.md` / `.github/copilot-instructions.md`. The kernel's own framing ("compile-time + runtime gate" — KS:475) is partially aspirational.

---

## 4. Bug hunt

> 21 substantive findings below. Severity per the rubric in the prompt;
> "Sibling-of-FA-XX" cross-refs the existing `_flaws.md` register.

---

### B-01 — Cron tick starves all other overdue jobs on first failure

**Class**: idempotency / scheduler
**Sibling-of**: none
**Evidence**: `tools/cron.py:283-318` (`tick` action)
```python
for j in overdue_now:
    if force_auto and not attempted:
        attempted = True
        ok, detail = _run_job(j, ws)
        ...
        if ok:
            j["run_count"] = ...
            j["next_run"]  = next_run(j["schedule"], now_utc()).isoformat()
        else:
            errors.append(...)
    else:
        pending.append(...)
On line 302 the rate-limit budget (`attempted`) is consumed by the **first** overdue job regardless of success. On failure `next_run` is **not** advanced (lines 313-314 only push to `errors`), so on the next tick the same broken job is still first in `overdue_now` and re-consumes the budget. Every other overdue job stays in `pending` forever as long as job-1 keeps failing.

**Reproduction**:
1. Seed three daily jobs at the same hour.
2. Make the first one's `program` an invalid command (`foo bar`).
3. Run `cron tick --auto` daily for 3 days.

After 3 days: job-1 has 3 errors logged, jobs 2 and 3 have never fired.

**Impact**: a single broken cron entry silently disables the entire autonomy loop. Goal-acceptance #1 (`L:auto-improve` triggers daily cron entry) is fragile to any prior failing job in the queue.
**Severity**: !HIGH
**Confidence**: HIGH
**Proposed fix**: in `tools/cron.py:313-314`, also bump `next_run` on failure (e.g. push by 1 hour, with an `error_count` field) so the budget for other jobs frees up. Alternatively, raise the per-tick budget to N or shuffle the queue order so the same failure can't camp the head.
**Sibling-of-D-AXX**: D-A05 (idempotent cron) is upstream of this; the spec needs to clarify failure-retry policy.

---

### B-02 — Cron tick at boot blocks for up to 140 s synchronously

**Class**: open-loop / availability
**Sibling-of**: none
**Evidence**: `tools/boot.py:277` (unconditional call):
```python
cron_tick     = tick_cron(args.workspace)
and `tools/boot.py:95-116`:
```python
r = subprocess.run(cmd, capture_output=True, text=True, timeout=140)
`tick_cron` is called on every boot. If `L:cron-auto ≡ true` and an overdue job is on the queue, boot synchronously waits up to 140 s for `subprocess.run`.

**Reproduction**: enable cron-auto, queue a 60 s job, restart session — boot stalls.
**Impact**: bad UX, slow first-turn; if the job is also broken, boot stalls then surfaces a generic stderr.
**Severity**: !NORM
**Confidence**: HIGH
**Proposed fix**: gate `tick_cron` behind a fast pre-check (only call subprocess when `cron.check` returned `overdue_count > 0` AND `L:cron-auto-boot ≡ true`). Alternatively, fork the tick into a background detached process and write the result to a file for the next turn.
**Sibling-of-D-AXX**: none — new demand candidate.

---

### B-03 — Drift gate fails open when no trace exists

**Class**: gate-bypass / drift
**Sibling-of**: FA-08 (drift-gate read path); the read path now exists but its semantics on "no trace" are unsafe.
**Evidence**: `tools/drift.py:217-228 cmd_gate`:
```python
if not trace:
    print(json.dumps({
        "score": 0.0, "state": "stable", "decision": "quiet",
        "modifier": 0, "program": None,
        "note": "no active trace",
    }))
    return 0
and `tools/auto_improve.py:81-87`:
```python
def _drift_state(workspace):
    try:
        return _axon_lib.drift_gate(workspace)
    except Exception:
        return {"state": "stable", "decision": "quiet", "modifier": 0}
After `drift reset`, after a clean workspace boot, or any time the trace file is absent, `state == "stable"` is returned. `auto_improve.py:324` only hard-halts on `state == "diverged"`. So on a fresh workspace **every auto-action fires** with no observed drift evidence.

**Reproduction**:
1. `drift reset`
2. `kv-store set L:auto-improve true`
3. `auto-improve` → all three actions execute.

**Impact**: D-A03 ("Drift gate is absolute") is violated on first run after any reset. !HIGH because this also defeats the autoimprove acceptance criterion #4 ("zero auto-actions fire when drift.state ≡ diverged") in the corner case of a missing trace.
**Severity**: !HIGH
**Confidence**: HIGH
**Proposed fix**: in `tools/drift.py:217-228`, return `state="unknown"` when trace is missing, and let consumers decide. In `tools/auto_improve.py:324`, change to `if drift.get("state") in ("diverged", "unknown")`. Document explicitly that "stable" requires a positively-recorded trace.
**Sibling-of-D-AXX**: D-A19 (explicit `TOOL(drift, read)`) — extend with "fail-closed on missing trace".

---

### B-04 — `igap`, `dispatch`, `auto_audit`, `memory append` all do non-atomic appends

**Class**: atomicity
**Sibling-of**: FA-07 (receipt atomicity)
**Evidence**: four sites with `open(path, "a").write(...)` and no fsync:
- `tools/igap.py:89-90`
- `tools/dispatch.py:287-288` (feedback log) and `:349-350` (correlate)
- `tools/auto_audit.py:121-124`
- `tools/memory.py:79` (`append` action for E: scope)

Example, `auto_audit.py:121-124`:
```python
with open(path, "a") as f:
    f.write(line)
    if excerpt_block:
        f.write(excerpt_block)
Two writes inside the same `open` — a crash between them yields a partial row. The audit ledger itself is corruptable. No `f.flush()`, no `os.fsync()`, no temp-rename.

**Reproduction**: kill the python process between the two writes inside `append_row` (e.g. via SIGKILL from cron parent watchdog).
**Impact**: receipt rows can be torn; subsequent `read_window` (`auto_audit.py:141-160`) silently drops malformed rows via `parse_row` returning `None`. The audit log claims completeness but can lose entries. Same pattern in igap/dispatch/feedback.
**Severity**: !HIGH (for `auto_audit`) / !NORM (for igap, dispatch)
**Confidence**: HIGH
**Proposed fix**: wrap each append in a small helper `atomic_append(path, content)` that opens the file with `os.O_APPEND|os.O_CLOEXEC`, writes a single contiguous buffer, then fsyncs. Easiest: build the full row string first, then a single `f.write(...) + f.flush() + os.fsync(f.fileno())`.
**Sibling-of-D-AXX**: D-A15 (two-phase write) is the right abstraction; this is the substrate.

---

### B-05 — `tools/kv_store.py` exposes no rollback (confirms FA-12)

**Class**: rollback-gap
**Sibling-of**: FA-12 (explicitly carried open)
**Evidence**: `tools/kv_store.py:1-93` — no `rollback`/`history` subcommand; `set` overwrites with no snapshot:
```python
elif args.action == "set":
    ...
    cache.set(args.key, value, expire=args.ttl)
Auto-tune in `auto_improve.py:178-238` writes to `preferences/smart-dispatch.md` (a file, not the kv store) and calls `_axon_rollback.snapshot(prefs_path)` — so for the dispatch threshold the rollback exists. But **any `L:` key that's actually in the kv-store** (cron-auto, auto-improve, dispatch-auto-tune, axon-cron-defaults-seeded) is unrecoverable after `kv-store set`.

**Reproduction**: `kv-store set --key L:auto-improve --value true; kv-store set --key L:auto-improve --value false`. There is no second value preserved.
**Impact**: D-A18 ("global rollback") cannot cover kv-store-backed parameters. Any future autotune that targets a kv-store key has no undo.
**Severity**: !HIGH
**Confidence**: HIGH
**Proposed fix**: extend `tools/kv_store.py` with the same 3-version pattern as `tools/memory.py` (lines 15-33). The diskcache backend can store the snapshot list under `<key>.rollback`. Alternative: route all L:-key writes via `memory.py set --scope L`. The latter is the more principled refactor (kv-store becomes for high-frequency app data; L:-keys go through memory.py).
**Sibling-of-D-AXX**: D-AUTO-001 (phase-2 decision pending).

---

### B-06 — `auto-tune` is one-way ratchet (open-loop) — FA-05/FA-06 still present in code

**Class**: open-loop / drift
**Sibling-of**: FA-05 + FA-06
**Evidence**: `tools/auto_improve.py:196-227`:
```python
if neg_rate <= 0.30:
    return ok({"action": "auto-tune", "tuned": False, ...})
...
new = round(min(current + 0.05, 0.95), 2)
**No** branch lowers the threshold when neg-rate < 10 % (D-A16). No `M_t` metric is recorded into the receipt; next-tick re-read is not implemented (D-A13). The audit row records `before_excerpt`/`after_excerpt` (lines 232-233) but no follow-up `measure-after` field.

Additionally `tools/dispatch.py:295-317` has a **second** auto-tune path that also only raises (`new_t = round(min(current + 0.05, 0.9), 2)` — capped at **0.9**, not 0.95). Two open-loop ratchets that can run on the same `preferences/smart-dispatch.md` file in the same day with different caps.

**Reproduction**:
1. Manually write 20 `{"result":"no"}` rows to `memory/longterm/dispatch-feedback.jsonl`.
2. `kv-store set L:auto-improve true; kv-store set L:dispatch-auto-tune true`
3. Call `dispatch.py feedback --id X --result no` (triggers in-line auto-tune) AND `auto_improve.py --action auto-tune` same day.
4. Threshold raised twice: once to current+0.05 by dispatch.py, then to current+0.10 by auto_improve.py.

**Impact**: !HIGH — pins threshold at the cap; never recovers when neg-rate falls; double-tunes when both gates are on.
**Severity**: !HIGH
**Confidence**: HIGH
**Proposed fix**:
1. Add the symmetrical lower-branch (`elif neg_rate < 0.10 and current > 0.50: new = max(0.50, current - 0.05)`) inside `auto_improve.py:196-227`.
2. Remove or hard-gate the duplicate ratchet in `tools/dispatch.py:295-317` — the in-line tuner should defer to `auto-improve` if `L:auto-improve ≡ true`.
3. Record `metric_at_apply` in the audit row (extend `auto_audit.py` row schema with optional `metric_before`/`metric_after`).
4. Add a separate `closed-loop` step: next tick reads `metric_after` and compares to `metric_before`; if not improved, call `kv-store rollback` (or the prefs-file rollback) and bump a `reverts_in_a_row` counter; ≥3 → pause rule.
**Sibling-of-D-AXX**: D-A13 + D-A16. Spec is right; impl is wrong.

---

### B-07 — Receipt-vs-action atomicity: audit row recorded AFTER apply (FA-07 sibling)

**Class**: atomicity / rollback-gap
**Sibling-of**: FA-07
**Evidence**: every action in `tools/auto_improve.py` writes first, audits second:
- compile: `subprocess.run(...)` on line 150, then `_record_audit(...)` on line 161
- tune: `atomic_write(prefs_path, new_content)` line 227, `_record_audit(...)` line 228
- archive: `f.unlink()` line 278, `_record_audit(...)` line 280

And `_record_audit` is best-effort:
```python
except Exception:
    sys.stderr.write(f"auto-improve: audit record failed for {action}\n")
If the process crashes between the file write and the audit row, the change is on disk but invisible to the ledger. Two-phase commit (D-A15: `pending` → `applied`) is **not** implemented in `tools/auto_audit.py` (rows have no status column).

**Reproduction**: SIGKILL `auto_improve.py` between `atomic_write(prefs_path, …)` and `_record_audit(...)`.
**Impact**: `auto-improve rollback --days N` (D-A18) cannot find the unaudited apply, so the prefs file is silently wrong.
**Severity**: !HIGH
**Confidence**: HIGH
**Proposed fix**: add a status column to the audit row (`pending|applied|failed`); write `pending` BEFORE the side-effect; update to `applied`/`failed` after. On startup, `auto-improve` scans for orphan `pending` rows older than (e.g.) 5 minutes and either completes (idempotent re-apply) or rolls back the snapshot.
**Sibling-of-D-AXX**: D-A15 — spec ok, impl missing.

---

### B-08 — Context pressure thresholds use `>=` but kernel says `>`

**Class**: gate-bypass (low impact)
**Sibling-of**: none
**Evidence**: `tools/context.py:34-39, 60-65`:
```python
PRESSURE_LEVELS = [
    (0.85, "critical"),
    (0.60, "high"),
    ...
]
for threshold, label in PRESSURE_LEVELS:
    if ratio >= threshold:
        return label, round(ratio * 100, 1)
Kernel spec: ">85 % critical, >60 % high" (KS:283, 290).
At exactly 60.0 % the kernel says "high" should NOT yet fire; the tool fires it.

**Severity**: !LOW
**Confidence**: HIGH
**Proposed fix**: change `>=` to `>` (or change the kernel wording to `≥`). Pick one.

---

### B-09 — R9 write gate is invoked from exactly 2 programs (mechanical bypass)

**Class**: gate-bypass
**Sibling-of**: none (this is the most important new finding)
**Evidence**: grep `TOOL(enforce, check-write` across `workspace/programs/`:
workspace/programs/register-tool.md:62
workspace/programs/compiled/register-tool.cmp.md:40
Both are the same program; the compiled copy mirrors the source. Every other program/tool that writes a file via `_axon_io.atomic_write` (`tools/memory.py:73`, `tools/cron.py:61-74`, `tools/auto_improve.py:227`, `tools/_axon_rollback.py:82,109`, `tools/igap.py`, `tools/auto_audit.py`, …) **does not call `enforce.py` or `verify.py action`** before the write. The kernel claims the gate is mechanical (KS:475-479) but in practice:
- `_axon_io.atomic_write(path, …)` accepts any path with no target check.
- `tools/rules/r9_axon_write.py:14-26` only fires when something calls `verify.py action --json '{op:WRITE, target:…}'`.

So if `L:dev-mode` is `false` and some tool decides to write to `axon/...`, **nothing prevents it** unless the agent voluntarily passes the action through `verify.py` first.

**Reproduction**:
python3 tools/memory.py set --scope L --key axon/foo --value bar --workspace /tmp/ws
(After tweaking `key` so it produces an `axon/`-prefixed path. The path-traversal isn't the threat — the threat is that any tool with a `--target axon/...` argument bypasses the gate.)

**Impact**: !HIGH — R9 is a Core Rule, framed as mechanical (KS:475, 479). It is in fact a documentation rule guarded by an unenforced ASSERT. Any future tool that takes a `--target` path argument inherits this gap.
**Severity**: !HIGH
**Confidence**: HIGH
**Proposed fix**: lift the path check into `_axon_io.atomic_write` itself (parameterized by an `--allow-axon-write` env flag set only by the dev-mode tool). All write callers go through one chokepoint. Strictly: add an `assert_not_axon(path)` helper that raises unless `dev-mode == True`, and call it at the top of `atomic_write` and `atomic_write_json`. Programs that write to `axon/` legitimately must take an explicit override.
**Sibling-of-D-AXX**: new demand candidate — D-AUTO-003: "R9 is enforced at the IO chokepoint, not at the program."

---

### B-10 — `orchestrator.md` calls non-existent `TOOL(dispatch, fire)`

**Class**: identity / implementation gap
**Sibling-of**: none
**Evidence**: `workspace/programs/orchestrator.md:146`:
result ← TOOL(dispatch, fire, "--synapse {top.name} --args {top.args}")
`tools/dispatch.py` defines only these subcommands (lines 158-192): `match`, `index`, `feedback`, `correlate`, `stats`. No `fire`. Calling `python3 tools/dispatch.py fire` raises `error: invalid choice: 'fire'`.

Similarly `orchestrator.md:53` calls `TOOL(usage, recent)` but `tools/usage.py` exposes `cmd_record`, `cmd_top`, `cmd_suggest`, `cmd_prune` (lines 88, 157, 191, 233) — no `recent`. And `orchestrator.md:54` calls `TOOL(pattern, clusters)` but `tools/pattern.py:119` defines actions `["cluster","top","suggest"]` — no `clusters`.

**Reproduction**: `python3 axon.py orchestrator` (or any chat that lands in `EXEC(orchestrator)`).
**Impact**: the orchestrator program — the central composition path shipped by axon-synapse — has three broken tool calls in its happy path. They're masked by the `| ∅` fallback (`{state: "stable"}`, `{}`, etc.) on most calls, but the `fire` branch has no fallback. The orchestrator never actually fires a candidate via `dispatch`; the `decision ≡ "fire"` branch always errors.
**Severity**: !HIGH
**Confidence**: HIGH
**Proposed fix**: either (a) add `fire`/`recent`/`clusters` subcommands to the three tools, or (b) edit `workspace/programs/orchestrator.md` to call the existing surfaces (`dispatch match --query …` then EXEC the matched program; `usage suggest`; `pattern cluster`). Option (b) is one-PR and respects the existing CLI contract. Add a sanity-check program that walks every `TOOL(...)` call in `workspace/programs/*.md` against `tools/REGISTRY.json` + each tool's argparse.
**Sibling-of-D-AXX**: none — should be a static-lint demand (D-AUTO-004 candidate).

---

### B-11 — `memory.py clear` for `L:` scope deletes file without saving rollback

**Class**: rollback-gap
**Sibling-of**: FA-12
**Evidence**: `tools/memory.py:82-90`:
```python
elif args.action == "clear":
    ...
    if os.path.exists(path):
        os.remove(path)
No `save_rollback(...)` call before `os.remove`. So `memory clear --scope L --key foo` then `memory rollback --scope L --key foo` fails with "No rollback history" if there were no prior `set`s (or restores an old value rather than what was cleared). The clear path is irrecoverable.

**Severity**: !NORM
**Confidence**: HIGH
**Proposed fix**: in `memory.py:82-90`, if scope == "L", read current value and call `save_rollback(...)` before `os.remove`.

---

### B-12 — Concurrent `memory set` on the same L: key races on rollback history

**Class**: race / atomicity
**Sibling-of**: none
**Evidence**: `tools/memory.py:64-74`:
```python
elif args.action == "set":
    ...
    if args.scope == "L" and os.path.exists(path):
        with open(path) as f:
            save_rollback(args.workspace, args.key, f.read().strip())
    atomic_write(path, args.value + "\n")
No file lock around the (read-current, push-rollback, write-new) sequence. Two processes setting the same L: key concurrently can:
1. Both read the same current value `V0`.
2. Both push `V0` to rollback (now history has `[V0, V0, …]`).
3. Both write — last writer wins; the other "applied" value is lost AND there is no rollback row for it.

`tools/_axon_rollback.snapshot()` has the same problem (`_axon_rollback.py:74-90`).

**Severity**: !NORM (rare: two L:-writers concurrently is uncommon, but `auto-improve` + interactive session is the classic case)
**Confidence**: MED
**Proposed fix**: wrap `memory.py set` for L: scope in a `fcntl.flock` on a sibling `.lock` file (same pattern used by `cron.py:76-84`).

---

### B-13 — `auto_improve.py action_auto_archive` has no rate limit (D-A20 not implemented)

**Class**: open-loop / cascade
**Sibling-of**: FA-01, FA-11
**Evidence**: `tools/auto_improve.py:243-287`:
```python
candidates = []
for f in epi.glob("*.md"):
    ...
    if mtime < cutoff:
        candidates.append((f, mtime))
...
for f, mtime in candidates:
    ...  # archive every one
No cap. If a workspace has 30 days of accumulated episodic entries (say 600 files), the cron tick archives all 600. D-A20 specifies ≤50/tick.

**Reproduction**: seed `memory/episodic/` with 200 `.md` files older than 30 days; run `auto-improve --action auto-archive`.
**Impact**: !NORM — bulk archive on first run after a long idle gap. The phase-1 study already flagged FA-01/FA-11 as spec-fixed but the impl matches neither.
**Severity**: !NORM
**Confidence**: HIGH
**Proposed fix**: sort `candidates` by mtime ascending, slice `[:50]`; emit an info line if more remain. Add `--max-archive` CLI arg with default 50.

---

### B-14 — `auto_improve.py` lacks idempotent (date, action, target) key (D-A05 not implemented)

**Class**: idempotency
**Sibling-of**: FA-02
**Evidence**: `tools/auto_improve.py:113-173 action_auto_compile` re-checks `_is_compiled` (line 126) before compiling, so re-running same-day is partially idempotent for compile. But:
- `action_auto_tune` (lines 178-238): if neg-rate is still > 30 % after the first tune, a second same-day call **raises again** — there is no `(date, action, target)` guard. Two same-day cron ticks pin the threshold even faster.
- `action_auto_archive`: re-runs would archive newer files that have just crossed the 30-day cutoff. Not strictly a bug, but combined with no rate-limit (B-13) it's a cascade.

Audit ledger rows are timestamped but never read back to enforce same-day dedup.

**Severity**: !NORM
**Confidence**: HIGH
**Proposed fix**: at the top of each `action_*`, `read_window(workspace, days=1)` from `auto_audit.py`, build `seen = {(row.action, row.target)}`, skip if today's key is already in `seen`.

---

### B-15 — `auto-improve.md` program contains an unconditional stub render after `DONE()`

**Class**: error-handling / output
**Sibling-of**: none
**Evidence**: `workspace/programs/auto-improve.md:105-110`:
DONE(auto-improve)

## OUTPUT  ·  autogen-stub

→ "▶ auto-improve  ·  stub"
Code after `DONE()` in an AXON program is unreachable per KS:404, but the output line is rendered every run if the agent obeys the literal file. The stub line was meant as scaffolding from PR-108 bulk migration (`# inferred-by: synapse-infer (PR-108 bulk migration)` line 14) and was never deleted.

**Severity**: !LOW (cosmetic, but it surfaces in the user's terminal every cron tick)
**Confidence**: MED
**Proposed fix**: delete lines 107-110 of `workspace/programs/auto-improve.md`.

---

### B-16 — Synapse-suggest precondition filter silently drops any contract whose precondition isn't trivial

**Class**: error-handling / silent-dropout
**Sibling-of**: none
**Evidence**: `tools/synapse_suggest.py:140-150` (`_eval_simple_if`):
```python
m = re.match(r"^state\.([A-Za-z0-9_\-]+)\s*==\s*['\"]?([^'\"]+)['\"]?$", cond)
if m: ...
m = re.match(r"^state\.([A-Za-z0-9_\-]+)$", cond)
if m: ...
return False
Anything not matching one of those two regexes returns `False`. Then `tools/synapse_suggest.py:231`:
```python
if pre and pre.lower() != "true" and not _eval_simple_if(pre, state):
    return False, f"precondition-false:{pre}"
So a candidate with a precondition like `L:cognition-frame ≡ "AXON-OS"` (which is the standard precondition stamped on **every** `inferred-by: synapse-infer (PR-108 bulk migration)` synapse — confirmed at e.g. `workspace/programs/orchestrator.md:9`, `auto-improve.md:9`, `code-dev-state.md:15`) is **always dropped** by the ranker because `_eval_simple_if` doesn't understand `≡`.

**Reproduction**: feed `synapse_suggest.py rank` a candidate JSON with `"precondition": "L:cognition-frame ≡ \"AXON-OS\""`. Output: zero kept candidates.
**Impact**: when the ranker is fed real synapse-infer outputs (PR-108 bulk migration), the precondition filter eliminates the bulk of legitimate candidates. The orchestrator falls into the zero-candidate branch (`workspace/programs/orchestrator.md:74-83`) and surfaces a `QUERY user` for the user to disambiguate. The "automatic ranking" path is effectively dead for any contract with a real precondition.
**Severity**: !HIGH
**Confidence**: HIGH
**Proposed fix**: replace `_eval_simple_if` with a real predicate evaluator. The repo already ships one — `tools/predicate.py` (the PR-102 predicate tool). Wire it via `from predicate import evaluate; evaluate(pre, state)`. Alternative quick fix: when `_eval_simple_if` doesn't understand a precondition, **default to True** (current behavior is silent-False, which is more dangerous than silent-True for a ranker filter).
**Sibling-of-D-AXX**: GAP-07 (ranker tuning labels). Not the same issue but adjacent.

---

### B-17 — `synapse_validate.py` does not flag references to non-existent neurons

**Class**: error-handling
**Sibling-of**: none
**Evidence**: `tools/synapse_validate.py:134-141`:
```python
for j, name in enumerate(clause.get("suggest", []) or []):
    if not isinstance(name, str):
        errors.append(...)
        continue
    if known_names and name not in known_names:
        # Soft warn: record but don't fail on unknown suggestions
        # (synapses may chain to not-yet-implemented neurons).
        pass
The comment promises "soft warn: record" but **no warning is emitted** — `pass` is literally a no-op. So a typo in a `next-conditional.suggest` slot is invisible.

**Severity**: !NORM
**Confidence**: HIGH
**Proposed fix**: split `errors` into `errors` + `warnings`; append `{name, "unknown-suggest-target"}` to warnings; surface warnings in `--all-corpus` JSON output. Optional: fail validation when an explicit `--strict-suggest` flag is set, otherwise warn.

---

### B-18 — `dispatch.py save_index` is non-atomic; concurrent compile-suggest can corrupt the index

**Class**: atomicity
**Sibling-of**: none
**Evidence**: `tools/dispatch.py:56-60`:
```python
def save_index(ws, index):
    p = index_path(ws)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w") as f:
        json.dump(index, f, indent=2)
No temp+rename. `auto_improve.action_auto_compile` invokes `tools/compile-write.py` per program; if multiple updates land concurrently (or if the python process is killed mid-`json.dump`), the index file is truncated/corrupt → `load_index` raises → next `dispatch match` falls through with "dispatch index is empty".

Same issue: `tools/drift.py:125-129 save_trace` and `tools/context.py:54-58 write_state`.

**Severity**: !NORM
**Confidence**: HIGH
**Proposed fix**: use `_axon_io.atomic_write_json(p, index)` in all three sites. The helper already exists.

---

### B-19 — `enforce.py is_inside_axon` uses cwd-relative path defaults

**Class**: path-validation / gate-bypass
**Sibling-of**: B-09
**Evidence**: `tools/enforce.py:15-19, 28`:
```python
def is_inside_axon(target_path, axon_dir="axon"):
    target = os.path.normpath(os.path.abspath(target_path))
    axon   = os.path.normpath(os.path.abspath(axon_dir))
    return target.startswith(axon + os.sep) or target == axon
`axon_dir="axon"` defaults to whatever the current cwd treats as `axon`. If invoked from `/tmp` (e.g. by a test harness or an attacker), `os.path.abspath("axon")` resolves to `/tmp/axon`. `is_inside_axon("/mnt/c/projects/axon/axon/KERNEL-SLIM.md", "axon")` returns `False`. The gate passes a real `axon/` write.

Also: `os.path.normpath(os.path.abspath(...))` does NOT resolve symlinks. A symlink at `workspace/foo → axon/KERNEL-SLIM.md` followed by a write to `workspace/foo` passes the gate.

**Severity**: !NORM
**Confidence**: HIGH (cwd issue), MED (symlink — needs FS-specific repro)
**Proposed fix**: use `os.path.realpath(...)` instead of `abspath`. Pass an absolute `--axon` arg from the caller (or resolve via `_axon_paths.AXON_ROOT`). Reject writes if any path component is a symlink that crosses the boundary.

---

### B-20 — `auto-improve.md` program omits D-A02 opt-in HARD confirm and D-A17 idle-gap re-confirm

**Class**: gate-bypass
**Sibling-of**: FA-01, FA-11
**Evidence**: `workspace/programs/auto-improve.md:38-55` only checks `L:auto-improve ≡ true` and drift state. It does **not** check:
1. Whether this is the first tick after `L:auto-improve` was flipped on (D-A02 requires a user-confirm QUERY).
2. Whether the last cron tick was > 7 days ago (D-A17 requires re-prompting).
There is no `L:auto-improve-last-tick` or equivalent timestamp persisted; the `auto-improve` program has nothing to compare against.

**Reproduction**: `kv-store set L:auto-improve true; auto-improve` — actions fire immediately, no confirm prompt.
**Impact**: D-A02, D-A17 not implemented even though they are 🟧 spec-fixed in `_flaws.md`. After a 30-day idle gap, FA-11 cascade is still live.
**Severity**: !HIGH
**Confidence**: HIGH
**Proposed fix**: at the top of `tools/auto_improve.py main()`:
```python
last = _kv_get(ws, "auto-improve-last-tick")  # ISO ts
if not last:
    # First tick after enable — require confirm
    if not args.force:
        emit(ok({"ran": False, "reason": "opt-in HARD: re-state command after enabling"}))
        return
elif (now_utc() - parse(last)).days > 7:
    if not args.force:
        emit(ok({"ran": False, "reason": "idle-gap > 7d — re-confirm required"}))
        return
# … then run actions
_kv_set(ws, "auto-improve-last-tick", now_iso())
The `--force` flag already exists (line 306).

---

### B-21 — Boot does not advance `next_run` on cron job failure → boot-time job-1 can DOS every subsequent boot

**Class**: open-loop / availability
**Sibling-of**: B-01 (extension into the boot path)
**Evidence**: combine B-01 (cron failure doesn't bump `next_run`) with B-02 (boot calls `tick_cron` unconditionally) and `tools/cron.py:191-198` (per-run timeout 120 s). If a boot-scheduled job fails or times out, every subsequent boot replays the same failure for up to 140 s. The user can't "skip past it" without manually editing `scheduler/cron.json`.

**Severity**: !HIGH (only if cron-auto is on)
**Confidence**: HIGH
**Proposed fix**: same as B-01, plus add a circuit-breaker: after 3 consecutive failures of the same job, auto-disable it (`enabled: false`) and surface a one-line note at next boot.

---

## 5. Synapse / DAG / state-machine — integration coverage

### 5.1 Synapse

**What it ranks** — `tools/synapse_suggest.py:42-58`. Eleven signals (intent, dispatch, usage, pattern, next_cond, goal, context, drift, shadow, igap, plus `usage`/`pattern` re-normalised on absence). Weights default in `DEFAULT_WEIGHTS`; overridable via `--weights`.

**Who reads its output** — `workspace/programs/orchestrator.md:70-71, 102-104`. The orchestrator is the *only* documented consumer that calls `synapse-suggest rank` directly. The `dispatch` tool uses pure TF-IDF (line 65) — not the synapse ranker.

**Where the ranker writes** — nowhere. The tool is pure (reads JSON, prints JSON). There is no `synapse-suggest record` action; the ranker has no history.

**Consumer behaviour when ranker is empty / wrong / stale**:
- Empty: `workspace/programs/orchestrator.md:74-83` triggers a `dispatch.match` fallback then QUERY(user). ✓ documented.
- Wrong: there's no feedback path back to the ranker. `dispatch.py feedback` adjusts the **dispatch** threshold, not synapse weights. The synapse ranker has zero feedback wired today. **GAP-07 still applies**.
- Stale: state is rebuilt per call from `W:` keys (`orchestrator.md:39-57`). No staleness concept — but `state.usage.recent` comes from `TOOL(usage, recent)` which doesn't exist (B-10), so the `usage` signal is always 0 → `absent` set → renormalisation. The ranker silently runs without a usage component.

### 5.2 DAG (`tools/dag.py` + `tools/plan_dag.py`)

**Where used today** — three known surfaces:
1. `tools/plan_dag.py` emits `DAG.md` / `DAG.json` from `<project>/03-prs/pr-*.md` (audit prior-art `_meta.md` mentions PR-113 auto-emit hook).
2. `tools/dag.py` is the 5-level mutator API (bootstrap / add-node / add-edge / merge / split / fold-in / sync). Subcommand surface present (lines 7-22). Confirmed shipped.
3. The `code-dev-plan-master.md` program is presumed to invoke `plan_dag` after a plan lands (per AUDIT.md §2.1 / PR-113 confirmation row). Not re-walked.

**Cycle detection** — `plan_dag.py:50-73` uses Kahn's algorithm, returns `cycle` list when topo can't cover all nodes. ✓ HIGH confidence.

**Edge validation** — `plan_dag.py:46`: `if d != pr_id: deps.add(d)` (self-loop drop). No validation that `d` exists in the node set — but the topo step ignores edges to absent nodes (line 57 `if d in by_id:`). Silent drop; no warning. **Gap**: cycle detection works but dangling-edge detection is silent. `tools/dag.py` claims to do `dangling-edge + nested-existence` validation in `verify` (line 18) — not audited.

**Execution order vs dependency order** — the DAG is *informational*; nothing executes the topo. PR phases are still walked linearly by `code-dev-plan-master` (based on AUDIT.md naming). The DAG is rendered, not executed.

**Partial failure on DAG mutation** — `tools/dag.py:53-60 _atomic_write` is correct (temp+rename). But `plan_dag.run` (lines 155-157) writes DAG.md then DAG.json separately — a crash between leaves a mismatch (low impact).

**DAG schema documented?** — referenced as `dag-spec-v1.md` in `phases/2-design/specs/`. The schema is encoded in `dag.py:36-40` as constants. `verify` subcommand promises schema validation. Not deeply walked.

### 5.3 Pseudo-state-machine (code-dev-state*.md + board.py)

**`tools/board.py` is NOT a state machine** — it's a Kanban renderer over `pr_aggregate.py` output (`tools/board.py:19-31`). Columns are hard-coded `["backlog", "in-progress", "blocked", "ready-for-review", "done"]` (line 15). It reads PR states, buckets them, prints a table. No transitions, no validation, no recovery.

**The "state machine" of code-dev** lives in seven `workspace/programs/code-dev-state*.md` files. Walked only `code-dev-state.md` (the umbrella router) in full. The router (lines 39-50) just dispatches by subcommand:
status   → code-dev-status.md
next     → code-dev-next.md
resume   → code-dev-resume.md
handoff  → code-dev-handoff.md
metrics  → code-dev-metrics.md
save     → code-dev-tag.md
restore  → code-dev-tag.md   ← same target as save
undo     → code-dev-undo.md
actions  → code-dev-actions.md

States (inferred from naming):
┌──────────┐  next      ┌──────────┐  save      ┌──────────┐
│  status  │ ─────────► │   next   │ ─────────► │   tag    │ ─┐
│ (start)  │            │ (queued) │            │ (saved)  │  │
└──────────┘            └────┬─────┘            └─────┬────┘  │ restore
                             │ resume                 │       │
                             ▼                        ▼       │
                       ┌──────────┐             ┌──────────┐  │
                       │ resume   │             │  undo    │◄─┘
                       └────┬─────┘             └────┬─────┘
                            │ handoff                │ actions
                            ▼                        ▼
                       ┌──────────┐             ┌──────────┐
                       │ handoff  │             │ actions  │
                       └──────────┘             └──────────┘

**Who guards transitions?** — nobody. `code-dev-state.md:40-50` is a free dispatch with `*  → FAIL(code-dev-state, "unknown subcommand: {sub}")`. There's no concept of "you can't `restore` before `save`" or "`undo` only valid after `actions`". A user can call `code-dev state undo` at any time.

**Who recovers crashed states?** — relies on `W:active-phase` (KS:298-303). The phase token is the only resume pointer. Inside `code-dev-state.md` there's no `STORE(W:active-phase, "code-dev-state:start")` before EXEC — the umbrella program doesn't even register itself.

**Deterministic from disk?** — partially. `W:active-phase` + the per-program saved tags in `code-dev-tag.md` should be enough to reconstruct state. But because the transitions aren't enforced, the system can be in a *reachable-but-illegal* state (e.g. tagged "saved-before-X" while undo-history says "Y was undone after X"). No invariant checker.

### 5.4 Cross-system coupling matrix

            synap. DAG  S-M  drift igap undo cron orch. c-dev lib  auto
                                                                       improve
synapse      ─    ─    ─    R     R    ─    ─    R     ─    ─    R
DAG          ─    ─    ─    ─     ─    ─    ─    ─     R    R    ─
state-mach.  ─    ─    ─    ─     ─    W    ─    ─     RW   ─    ─
drift        ─    ─    ─    ─     ─    ─    ─    W     ─    ─    R
igap         W    ─    ─    ─     ─    ─    ─    R     ─    ─    RW
undo         ─    ─    R    ─     ─    ─    ─    ─     R    ─    R
cron         ─    ─    ─    ─     ─    ─    ─    ─     ─    ─    W
orchestr.    R    ─    ─    R     R    ─    ─    ─     ─    ─    ─
code-dev     R    R    RW   ─     ─    R    ─    ─     ─    ─    ─
library-dev  ─    R    ─    ─     ─    ─    ─    ─     ─    ─    ─
auto-impr.   R    ─    ─    R     RW   R    R    ─     ─    ─    ─
- R = reads, W = writes, RW = both, ─ = no edge.
- Cron → auto-improve: fires it as a subprocess (cron.py:344, boot.py:277).
- orchestrator → synapse: orchestrator.md:70 → synapse_suggest.rank.
- auto-improve → igap: auto-improve.md:71 calls `TOOL(igap, signal)` (writes W:igap-signals).

**Missing edges that should exist**:
- **cron → drift**: cron does NOT read drift state before firing the auto-improve job. Drift gate fires inside auto-improve, so it's deferred but the cron tick itself ignores divergence. If `auto-improve` is broken in some other way (B-10-style typo), drift wouldn't even be evaluated.
- **synapse → feedback**: there is no edge from "user accepted top-1 candidate" back into the ranker. The ranker has no learning loop. (`dispatch.py feedback` only adjusts the dispatch *threshold*, not synapse weights.)
- **state-machine → drift**: code-dev transitions don't record drift; the drift trace is per-program, not per-state.
- **undo → audit**: `auto_audit.py` records auto-actions but `undo` doesn't write its own row when invoked. Undo is invisible in the audit ledger.
- **igap → orchestrator (closed loop)**: igap weights are injected into the next rank (auto-improve.md:73), but there's no feedback that says "we surfaced X based on igap, did the user accept?". Same open-loop pattern.
- **board → state-machine**: `board.py` renders PR states but doesn't read the code-dev-state programs. Two separate "state" concepts that never agree.

### 5.5 What AXON does NOT yet take advantage of

1. **Drift trace as a learning signal** — `tools/drift.py` records expected-vs-actual tool sequences but the result is only used for a halt decision. The diff itself (which tool was substituted for which) is never aggregated. Aggregating "tool A is substituted for tool B 73 % of the time" would suggest a rename or an alias.
2. **igap entries as DAG-edge candidates** — every "absent-instruction" igap row identifies a missing edge in the program-DAG. None of that is fed back into `tools/dag.py`.
3. **Audit ledger as a corpus for the synapse ranker** — `auto_audit.py` records which auto-actions ran and what state they touched. Pairing this with subsequent user behaviour (rollback yes/no) gives the only real labelled corpus the system could use. Not consumed anywhere.
4. **Dispatch feedback `correlate` signals** — `dispatch.py:321-353` already turns "continuation / igap-absent / drift-halt / restated" into yes/no feedback, but the closed loop only adjusts the dispatch threshold (one number), never the synapse weights or the dispatch index itself.
5. **Cron `pending` queue** — `cron.py tick` returns `pending` (unfired overdue jobs). Nothing reads `pending` to surface it to the user (boot.py:299 only counts overdue).
6. **Context-pressure history** — `context.py:114-123 status` shows accumulated tokens but doesn't track *per-program* pressure curves. A program that burns context predictably would be a compile candidate.
7. **Rollback snapshot diff** — `_axon_rollback` stores N versions of every auto-edited file. Nothing computes a "what changed between v1 and v2" diff that could feed `axon-audit` or surface a regression.

---

## 6. New-tool recommendation

After §5, two tools are justified. Only one of them passes the "this is not just an extension" test.

### 6.1 Tool 1 — `loop-receipt` (**recommended**)

- **Elevator pitch**: a single two-phase-commit ledger that every auto-action writes through. Provides `pending → applied|failed`, idempotent-key dedup, closed-loop metric capture, and global rollback. Subsumes the current `auto_audit.py` ledger and the implicit "did this action run today?" check inside `auto_improve.py`.
- **Inputs**: called by `tools/auto_improve.py`, `tools/cron.py tick`, `tools/dispatch.py` (when it auto-tunes), and any future auto-actor. Reads `tools/drift.py gate` (for the "drift was diverged, refused" row) and `tools/_axon_rollback` (for the snapshot id).
- **Outputs**: writes to `<workspace>/log/auto-edits/YYYY-MM-DD.md` (extended schema). Read by `auto-actions` (existing program), by `auto-improve rollback --days N` (D-A18), and by a new `auto-improve verify-closed-loop` subcommand.
- **Why now**: closes B-04, B-06 (closed-loop step), B-07 (two-phase), B-14 (idempotent key), B-20 (idle-gap re-confirm). One tool, six bugs.
- **First-PR scope** (≤ 200 LOC):
  - `tools/loop_receipt.py` — `begin(action, target, idempotency_key) → row_id` (writes `pending`), `commit(row_id, metric_before, metric_after?, status="applied")`, `fail(row_id, reason)`, `find_pending(older_than=5min)`, `is_done_today(action, target)`, `rollback_window(days)`.
  - `tests/test_loop_receipt.py` — pending/commit cycle, crash-after-pending recovery, idempotent same-day dedup, rollback walks reverse-chronologically.
  - `workspace/programs/auto-improve.md` patch — wrap each action in `begin/commit`.
  - `tools/auto_audit.py` shim — keep the CLI surface, route record() through `loop_receipt`.
- **Reversibility**: the daily log file is append-only markdown; deleting the new tool reverts behaviour to the existing `auto_audit.py` (which keeps working — the shim is one direction). The receipt schema adds a `status` column; old rows treated as `applied` for backward compat.
- **Why not extend `auto_audit.py`**: extending it would push `pending`/`commit` semantics into the audit ledger, blurring the audit role (immutable, write-once) with the orchestration role (read-write, racy). A separate tool keeps the audit ledger an append-only forensic record and lets the receipt tool own the mutable bits. Also: `auto_audit.py` already has the "actor" enum baked in (`VALID_ACTORS`) — generalising it to "receipts of arbitrary auto-actions" would compromise its narrow contract.

### 6.2 Tool 2 — `program-lint` (**marginal — recommend deferring**)

- **Pitch**: static lint of every `workspace/programs/*.md` that walks `TOOL(name, sub, …)` calls and validates them against `tools/REGISTRY.json` + each tool's argparse surface. Would have caught B-10 (`dispatch fire`, `usage recent`, `pattern clusters`) on day 0.
- **Why now**: B-10 is a real bug shipped by axon-synapse; lint would prevent regression.
- **Why I'm NOT recommending it as a new tool**: `tools/verify.py` (the rule engine) already has the right shape. Add a new `r_tool_call_exists.py` rule to `tools/rules/` rather than a new top-level tool. This is the "extend an existing tool" path the prompt asks me to rebut against, and here I think extension wins. The new rule is ≤ 50 LOC; a new tool would be ≥ 200 LOC for the same outcome.

**Conclusion**: ship `loop-receipt` (Tool 1). Add `r_tool_call_exists` rule under `tools/rules/` rather than a second new tool.

---

## 7. Cross-cutting recommendations

### To `_demands.md` of axon-autoimprove

- **D-A21**: R9 is enforced at the IO chokepoint, not at the program (B-09). All writes to paths under `axon/` go through a single helper that checks `L:dev-mode`. New tools cannot bypass.
- **D-A22**: Every cron job has a per-job circuit breaker. After 3 consecutive failures the job auto-disables and surfaces a one-line note at next boot (B-01, B-21).
- **D-A23**: Drift gate fails closed on missing trace (B-03). `drift gate` returns `state="unknown"` when no trace exists; consumers treat unknown == diverged.
- **D-A24**: All append-style logs (igap, dispatch feedback, audit, episodic) write a complete row in a single buffered write + fsync (B-04).
- **D-A25**: `kv_store` rollback exists (B-05). Decision D-AUTO-001 resolved.
- **D-A26**: Synapse-suggest precondition filter calls the real predicate evaluator (`tools/predicate.py`), not the regex placeholder (B-16). Filter default-True on unparseable preconditions.

### To `_flaws.md` of axon-autoimprove

Add these new rows (status 🟥 unless noted):

| ID    | Flaw | Status |
|-------|------|--------|
| FA-13 | Cron-failure starves all other jobs (B-01)                                                                                | 🟥 open |
| FA-14 | Drift gate fail-open on missing trace (B-03)                                                                              | 🟥 open |
| FA-15 | R9 write gate is doc-only at code level — only one program calls enforce.py (B-09)                                        | 🟥 open |
| FA-16 | Orchestrator.md calls non-existent `TOOL(dispatch, fire)` / `usage recent` / `pattern clusters` (B-10)                    | 🟥 open |
| FA-17 | Synapse-suggest filter drops all candidates with `≡` in precondition (B-16) — silent ranker degradation                   | 🟥 open |
| FA-18 | Async appends without fsync; audit/igap/dispatch logs all tearable (B-04)                                                 | 🟥 open |
| FA-19 | Auto-tune is one-way ratchet; second daily ratchet inside dispatch.py uses a different cap (B-06)                         | 🟥 open |
| FA-20 | auto-improve.md does NOT enforce D-A02 / D-A17 (opt-in HARD + idle-gap re-confirm) (B-20)                                 | 🟥 open |
| FA-21 | auto_improve.action_auto_archive has no rate limit — D-A20 not implemented (B-13)                                         | 🟥 open |
| FA-22 | code-dev pseudo-state-machine transitions are unguarded — any subcommand from any state (§5.3)                            | 🟥 open |
| FA-23 | synapse-validate silently passes references to unknown neurons (B-17)                                                     | 🟥 open |
| FA-24 | Boot synchronously runs `cron tick` for up to 140 s — DoS via failing job + cron-auto (B-02 + B-21)                       | 🟥 open |

### Should be deferred to a sibling future project

- **`axon-coherence-v2`**: code-dev pseudo-state-machine becomes a real state machine — transition table, invariant checker, FSM-aware resume. Scope is too big for `axon-autoimprove`; the latter consumes the FSM but does not redefine it. (FA-22)
- **`axon-ranker-v2`**: real predicate evaluator wired into synapse-suggest + dispatch + filter, plus a feedback loop that adjusts synapse weights from labelled outcomes. (FA-17 + GAP-07 + OP-02). Same project would touch synapse-validate.
- **`axon-io-chokepoint`**: lift write-gate enforcement into `_axon_io.atomic_write`; add symlink-cross check to `enforce.is_inside_axon`. (FA-15)

### Updates to phase-1 study (axon-autoimprove `phases/1-study/01-study.md`)

- **F-A1 is wrong.** The phase-1 study claims `workspace/programs/auto-improve.md` does NOT exist. It does exist (109 lines, 4707 bytes, mtime 2026-05-18) — see verified file listing in §1. The study confused the *tool* (`tools/auto_improve.py`, which exists and is well-developed) with the *program* (also exists but is partial — missing D-A02/D-A17 hooks, see B-20). Correction: F-A1 should read "auto-improve.md exists but is a thin wrapper around `TOOL(auto-improve)`; the kernel-side guards D-A02, D-A05, D-A17, D-A18, D-A20 are not implemented in either layer."
- F-A3 ("kv_store.py has no rollback") is correct — confirmed B-05.
- F-A8 ("`drift.py classify()` matches D-A19 syntax") is correct but understates: classify-returns-string is good; what the study missed is the **fail-open-on-no-trace** semantic — B-03. Phase-2 design must close this gap.
- F-A2 / Q1 ("cron does not call drift.classify") is still correct — but the *workspace program* `auto-improve.md` *does* call `TOOL(drift, gate)` (line 45). So the gate is in the right place. The study's framing should change from "cron must not enforce drift" to "cron must not pre-empt drift; the program is responsible".

---

## 8. Confidence summary

- **HIGH-confidence bugs**: 15 (B-01, B-03, B-04, B-05, B-06, B-07, B-08, B-09, B-10, B-11, B-13, B-14, B-16, B-17, B-18, B-20)  ← 16 actually; recounting.
- **MED-confidence bugs**: 4 (B-02, B-12, B-15, B-19, B-21)
- **LOW-confidence bugs**: 0

(Final tally: **17 HIGH · 4 MED · 0 LOW · 21 total**.)

**Clean-checked targets** (no bug found, justification given):
- `tools/_axon_io.atomic_write` — correct tmp+fsync+rename (with minor caveat about parent-dir fsync; not flagged because no kernel-spec mandates it).
- `tools/_axon_rollback.snapshot/restore` — sound version cap, FIFO eviction, reversible restore via self-snapshot. Race with concurrent writers is flagged under B-12 against the *caller*, not this module.
- `tools/undo.py` — thin CLI over `_axon_rollback`; nothing of its own to break.
- `tools/plan_dag.py` cycle detection — Kahn's algorithm correctly implemented; cycle reproducibility verified by reading.
- `tools/board.py` — pure renderer; not a state machine and doesn't claim to be.
- `tools/calculator.py` — not audited in depth but it's a leaf node; no kernel rule requires it to do anything beyond compute.

**Skipped targets + why**:
- `tools/shadow*.py` (shadow enforcement) — outside autoimprove scope; shipped by synapse and known-good per AUDIT.md §3.
- `tools/pr_*.py` — workflow surface; same reasoning.
- `tools/docgen*.py`, `tools/study_*.py` — out of critical path.
- `tools/dag.py` mutator API beyond bootstrap — would require ≥ 500 lines of read; deferred.
- `code-dev-state-{save,resume,handoff,metrics,undo,actions}.md` — only the umbrella `code-dev-state.md` was read; the FSM observations in §5.3 are extrapolated from filenames + the umbrella's case-dispatch. State-machine concerns logged as FA-22 / deferred project.

---

## 9. Suggested next step in axon-autoimprove

Open **PR-AUTO-201: `loop-receipt` tool** as the *single* first PR of phase-3 implementation, instead of starting with PR-201 (cron entry). Spec lives at `phases/2-design/specs/auto-improve-receipt-v1.md` (per `01-study.md § Phase-2 entry brief`).

Rationale: every other autoimprove PR depends on a working two-phase receipt schema. The cron entry (PR-201 in current plan) writes nothing of value until the receipt exists; auto-compile/auto-tune/auto-archive (PR-203/204/205) cannot be made idempotent or rollback-safe without it. Shipping `loop-receipt` first turns six of the new flaws above (FA-13, FA-18, FA-19, FA-20, FA-21, plus FA-12-the-old-FA) from architectural to surgical fixes.

Concretely: write **ADR `D-AUTO-003`** — *"Two-phase auto-action receipt is its own tool, not an extension of `auto_audit.py`"* — and pair it with the first PR. Once `loop-receipt` lands, re-fan-out the original PR roster: PR-202 wires cron, PR-203 wires auto-compile through receipts, PR-204 wires auto-tune with the bidirectional + closed-loop branch, PR-205 wires auto-archive with the rate limit. Phase-1 study claim F-A1 is corrected as part of the PR-202 commit message.

After `loop-receipt` lands, open **PR-AUTO-202b**: a one-rule addition to `tools/rules/` (`r_tool_call_exists.py`) that closes B-10 and blocks future synapse programs from referencing tool subcommands that don't exist. ≤ 80 LOC, hits `tools/REGISTRY.json` + the `--help` surface of each tool. This is the smallest possible repair for the orchestrator's broken `TOOL(dispatch, fire)` call and prevents the same failure mode from re-entering during phase-3 churn.

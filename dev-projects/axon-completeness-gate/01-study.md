# Study — Terminal-Transition Completeness Gate
Updated: 2026-06-18 · Method: 5-site deep fan-out (wf_cecf3017) + high-effort synthesis · AXON: 7.8/10

## Goal
Make **"no terminal transition (done/complete) without its declared post-conditions"** a uniform
MECHANICAL invariant across every status-setting surface in AXON — driven by a machine-parseable
per-program output manifest as the single source of truth, so the Python `REQUIRED_OUTPUTS` floor and
the program header can never silently diverge. Constraints: **no axon/ kernel edits** (mechanism = tool
+ verifier rule + workflow node schema); **no gate bypass**; tests-in-change (Core Rule 13).

## The defect (confirmed at 5 sites)
Only ONE of AXON's terminal transitions gates on a post-condition today:
- `phase_model.done()` — gates on output-existence, but truth is a **hardcoded** `REQUIRED_OUTPUTS` map (drift-prone).
- program `DONE` shorthand (`W:active-phase` ending `:done`) — **no** mechanical verifier consumes it.
- `workflow_run.advance()/record_step()` — enforces edge-legality / no-skip / sub-workflow completion, but
  **never inspects what a leaf node produced**; `record_step` defaults `status='ok'` unconditionally.
- `process.py` complete / `queue_tool.py` complete / `dag.py set-status` — **bare label writes, zero
  post-condition** (`dag set-status` doesn't even run the `verify()` backstop other dag mutations get).
  `cron.py` is the only one that gates (on subprocess returncode), and only on exit-status.

## Decisive feasibility finding
The prose `# outputs:` header is **NOT** usable as the source of truth: (1) `code-dev-plan.md`'s header
omits `03-prs/DAG.json` (the exact artifact the gate exists to enforce — only in the body, L399); (2) 24/60
`# outputs:` lines carry no path token (→ `[]` → silently unguarded); (3) vocabulary mismatch (`{W:..}/{slug}`
templated vs bare root-relative). → Introduce **`# emits:`** (mandated root-relative, machine-parseable,
glob-allowed); keep `# outputs:` as the human "Produces" string; **enforce `# emits:` ⊇ `REQUIRED_OUTPUTS`**
via a drift-lock, map retained FOREVER as a floor. Then `# emits:` is a true SSOT that can only be *more*
strict, never weaken the gate.

## Design — 6 layers sharing ONE source of truth
- **L0 SSOT** — new `# emits:` header + `tools/emits.py` (the ONE parser every layer calls).
- **L1 DRIFT-LOCK** — `emits-drift` check: `# emits:` ⊇ `REQUIRED_OUTPUTS[phase]` for each ladder program.
  This is what makes "SSOT, no drift" real; the map stays as a never-deleted floor.
- **L2 phase_model.done()** — **untouched**; an upstream code-dev driver calls `tools/emits.py` for the active
  program (bound via explicit `# phase:` field) and writes paths into the manifest `outputs` override that
  `_required_outputs()` already honors (preserves phase_model's "pure over the json" design).
- **L3 R_TERMINAL_OUTPUTS** — new RUNTIME/BLOCK/silent-until-flag verifier rule (modeled byte-for-byte on
  `r_state_surfaced.py`), gated on `L:terminal-outputs-required`. On a `:done` it resolves the program's
  `# emits:` and BLOCKs if a declared output is absent (mtime ≥ phase-entry from `active-phase.md` mtime —
  kernel-edit-free). Fail-OPEN on unresolvable placeholders.
- **L4 workflow_run** — optional per-synapse `outputs:`/`effects:` schema + `verify_node_outputs()`; on
  success with missing outputs, DOWNGRADE `record_step` status to `outputs-missing` (honest trajectory) +
  `advance` refuses. Backward-compatible (no `outputs` key → unchanged).
- **L5 (incremental)** — the three bare-label writers: `process.py` (phases done), `queue_tool.py` (deps ⊆
  completed — deps stored but never read at completion!), `dag.py` (route `set-status` through `_save_guarded`
  + assert `depends` predecessors complete). Share the PRINCIPLE, not one implementation.

Ship order: **L0–L3 first** (the program/phase ladder — the gap the post-mortem actually hit), then L4, then L5.

## Teeth analysis (important honesty)
- **L2 (phase_model.done) has REAL teeth now** — it's in the transition function; bites regardless of flags.
- **L3 (rule) is belt-and-suspenders** — and the study found the Stop hook (`verify_stop.py`) currently exits 0
  on a BLOCK (LOG-ONLY). So an armed R_TERMINAL_OUTPUTS is advisory until the hook escalates or it rides
  crucible. This is itself an enforcement-architecture finding (see the parallel bug-hunt). v1 relies on L2 for
  teeth; L3 is the path to mechanical coverage of the general program-DONE once the hook is escalated.

## Decided (study recommendations adopted — ADR-002)
- Program↔phase binding = explicit `# phase:` program field (not name-inferred).
- `# emits:` parsed + written into the manifest override by an upstream code-dev driver / `run.py` (keeps
  phase_model pure) — NOT phase_model gaining program-reading.
- Mode-dependent outputs = **static superset** in `# emits:` (drift-lock needs only ⊇, so a superset is safe).
- `emits-drift` = an MCP tool, registry-drift-style.

## Open — owner-facing forks for PLAN (ADR pending)
1. **Scope:** ship L0–L3 now + L4/L5 as follow-ups (recommended), vs all 6 layers in this project.
2. **Default activation:** R_TERMINAL_OUTPUTS default-OFF (silent until `L:terminal-outputs-required`,
   matching every other forcing-function) — recommended yes; flip after false-positive validation.
3. **Stop-hook teeth:** accept L3 = log-only-until-hook-escalation for v1 (L2 carries the teeth), or escalate
   `verify_stop.py` in scope (broader enforcement-arch change).
4. **Staleness precision:** `active-phase.md` mtime (approximate, kernel-edit-free) for v1 — recommended.
5. **Migration:** auto-populate existing projects' manifest `outputs` from `REQUIRED_OUTPUTS`, or leave the
   map as implicit default.
6. **L5 semantics:** structural (deps/predecessors terminal) vs outcome-based (work succeeded, cron-style).

## Sources
- `tools/phase_model.py` (done 199-218, _required_outputs 57-62, REQUIRED_OUTPUTS 48-54)
- `tools/verify.py` load_state, `tools/rules/r_state_surfaced.py`, `tools/registry.py`, `tools/manifest.py`
- `tools/workflow_run.py` (advance/record_step/sub_workflow_completed 140-265)
- `tools/process.py`, `tools/queue_tool.py`, `tools/dag.py` (cmd_set_status), `tools/cron.py`
- Drift evidence: `workspace/programs/code-dev-plan.md` (`# outputs:` 41-46 omits DAG.json; body L399 emits it)

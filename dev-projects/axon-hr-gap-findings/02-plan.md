# High-Level Plan — AXON HR Gap Findings
Updated: 2026-06-19  ·  Iterations: 2  ·  AXON: 9/10  ·  User: 9/10
Council: hr-team M3 hard (5 seats · 5 rounds R1 · WSV 7.4/10) · 3 revisions applied (R1-R3)
Council R2: hr-team M3 hard (5 seats · 5 rounds · WSV 9.0/10) · 3 further revisions applied (R4-R6)

## Context (from Phase 1)
Goal: Harden AXON by fixing all 8 hr-team gaps using source-verified root causes and
council-corrected sequencing. Deliver 9 PRs in 5 weeks. Every fix validated by test
before merge; crucible green before every push.

## Architecture Overview
AXON is a 4-layer OS for AI agents:
- `axon/` — kernel (KERNEL-SLIM.md inviolable · BOOT.md editable under dev-mode)
- `workspace/` — programs, scheduler, memory, working files
- `my-axon/` — user-specific data (symlink → axon-sections/my-axon)
- `.claude/` — hook config (settings.json · hooks/ wrappers)

Python tools in `tools/` (drift.py, igap.py, verify.py, enforce.py, phase_ledger.py,
cron.py, boot.py, shell.py, self_care.py). Programs in `workspace/programs/` (AXON-LANG).

---

## Layer 1 — Boot + runtime gates  [PR-01]

**Problem:** `drift.gate` returns `state:unknown / decision:halt / modifier:-50` on every
response because no trace file exists. `drift init --program <path>` requires a program
file for static sequence analysis — not applicable to interactive boot sessions. The flag
`--if-absent` does not exist. Auto-improve cron is also blocked by the same unknown state.

**Approach:** Add `--no-program` mode to `drift.py cmd_init`. Creates a trace with an
empty expected list; drift score is always 0.0 (stable); gate returns stable, not unknown.
Wire `drift init --no-program` to `BOOT.md` step 3c (after session restore, before menu).
The trace file is at `workspace/working/drift-trace.json` (2h TTL). On next boot, if no
trace exists, auto-init fires.

**Files:** `tools/drift.py` (+~20 lines in `cmd_init`) · `axon/BOOT.md` step 3c (+1 line)
**Tests:** `tests/test_drift.py` — NEW: init --no-program → gate → state=stable; TTL expiry → state=unknown

---

## Layer 2 — Path and display hygiene  [PR-02, PR-03]

**PR-02 Problem:** `my-axon/MYAXON.md` STORE ops set 13 W:myaxon-* paths to
`/home/arturcastiel/projects/axon-sections/my-axon/` (stale). The path works today
via symlink (`new-axon/axon/my-axon → axon-sections/my-axon`) but creates a fragile
dependency — removing the symlink breaks everything.

**PR-02 Approach:** Search-replace in MYAXON.md:
`/home/arturcastiel/projects/axon-sections/my-axon/`
→ `/home/arturcastiel/projects/new-axon/axon/my-axon/`
13 STORE ops updated. Symlink stays (other repos may depend on it). See ADR-001.

**PR-03 Problem:** menu.md health render (lines 158-163) shows "100/100 Excellent" with
no qualifier. Health score is smoke-based (lightweight checks, not full test coverage).
Misleading display suggests comprehensive testing when it reflects quick probes only.

**PR-03 Approach:** Add "(smoke)" qualifier to all 4 health tier render lines in menu.md.
4-line edit. No logic change.

**Files:** `my-axon/MYAXON.md` (13 paths) · `workspace/programs/menu.md` (4 lines)
**Tests:** PR-02: shell path resolution check (readlink -f all 13 paths); PR-03: no test

---

## Layer 3 — Observability wiring  [PR-04, PR-05]

**PR-04 Problem:** igap daily log (`workspace/log/igap/YYYY-MM-DD.md`) has entries
from May-June but nothing from recent interactive sessions. Root cause (v4 verified):
KERNEL-SLIM.md defines a !BG igap tracker (lines 263-295) for 4 trigger conditions,
but it is behavioral (instruction-based), not mechanical. `code-dev-meta-igap.md`
(ACTIVE) already calls `TOOL(igap, record)` and names 4 specific wiring targets.

**PR-04 Approach:** Add igap.record at HALT sites AND DONE() sites in 3 confirmed-real programs.
CORRECTION: `code-dev-dispatch.md` does NOT exist — phantom propagated from code-dev-meta-igap.md
line 75 through inception → study → councils without FILE-EXISTS verification. PR-04 corrects
meta-igap.md line 75 as part of its scope.

Real wiring targets (FILE-EXISTS: ✓ all confirmed):
- `workspace/programs/code-dev-plan.md` — before mass-rejection HALT + at DONE()
- `workspace/programs/code-dev-pr-ready.md` — before Gate-N HALT + at DONE()
- `workspace/programs/code-dev-state-handoff.md` — before ambiguous-state HALT + at DONE()
- `workspace/programs/code-dev-meta-igap.md` — fix line 75 phantom reference

~7 lines total (3 HALT + 3 DONE + 1 meta-igap fix). DONE() records use `--type session-close`.
Pre-flight: FILE-EXISTS check on all 3 targets; `igap session --reset` to clear stale session.
See ADR-003 (updated to reflect 3 real sites, 1 phantom removed).

**PR-05 Problem:** `phase_ledger.py` has all needed subcommands (record/list/verify/status)
but no program calls `TOOL(phase-ledger, record, ...)` automatically. Phase transitions
go unrecorded → phase-ledger verify always finds 0 recorded phases.

**PR-05 Approach:** Add to program template (and/or authoring-guide.md):
- Header: `TOOL(phase-ledger, record, --program {W:active-program} --phase start)`
- DONE(): `TOOL(phase-ledger, record, --program {W:active-program} --phase done)`
Identify which template file is used by new programs and patch it. All future programs
get recording automatically; existing programs can be patched incrementally.

**Files:** 4 code-dev program files + program template/authoring-guide
**Tests:** PR-04: `tests/test_igap.py` extend — HALT site calls igap.record → daily file written
           PR-05: `tests/test_phase_ledger.py` extend — template record → verify passes

---

## Layer 4 — Cron + coverage  [PR-06, PR-08]

**PR-06 Problem:** (a) No coverage-gate cron job exists. The 4.0% system-wide coverage
baseline needs weekly tracking to catch regressions. (b) Study and inception docs
reference `coverage_gate.py report` — this subcommand does not exist (only `check`/`run`).

**PR-06 Approach:** `python3 tools/cron.py add --program "coverage-gate check" --schedule "weekly Wed 09:15" --label "Weekly coverage gate check"`. Fix any doc reference from `report` → `check`. Verify cron.json entry is valid.

**PR-08 Problem:** `self-care` program (read-only sweep: health + freshness + cron + drift +
igap + persistence) is not in cron. 11 jobs exist; Monday 09:xx slots are full; Wed 09:00 is free.

**PR-08 Approach:** `python3 tools/cron.py add --program "self-care" --schedule "weekly Wed 09:00" --label "Weekly AXON self-care sweep"`.

**Files:** `workspace/scheduler/cron.json` (+2 jobs) · doc refs
**Tests:** `tests/test_cron.py` extend — cron add → entry in cron.json; check schedule valid

---

## Layer 5 — Governance documentation  [PR-07a]

**Problem:** BOOT.md has a boot-time anticipate tick for W:orchestrator-last-tick. This is
already implemented. But the next comment says "per-turn refresh needs KERNEL-SLIM
turn-logging band — held for explicit owner confirm." The KERNEL-SLIM core (lines 107-138)
gating was confirmed (not OUTPUT-LAYER). The current implementation is invisible in docs.

**Approach (PR-07a, autonomous):** Add a comment to BOOT.md step 3 clarifying the boot-time
tick is present and working. Add a note in `_meta.md` that PR-07b (per-turn tick) requires
KERNEL-SLIM core edit and owner explicit confirm. No code change.

Additionally: create `workspace/docs/w-key-registry.md` enumerating W:code-dev-* keys
(W:code-dev-project, W:code-dev-plan-mode, W:code-dev-plan-budget, W:code-dev-plan-axon-conf,
W:active-program, W:active-phase) with type/owner/lifecycle. Document known limitation:
W:code-dev-project must be set at session start via `code-dev load [slug]`; PR-09 enforcement
(L:project-anchor-required flag) closes this gap when activated.

**PR-07b (owner-confirm, separate):** If owner decides to enable per-turn tick — edit
KERNEL-SLIM.md turn-logging band (lines 107-138) to add `TOOL(anticipate, ...)` call.
This PR is a stub; owner initiates. Not scheduled in this project's autonomous scope.

**Files:** `axon/BOOT.md` (comment only) · project `_meta.md`
**Tests:** no test needed (doc-only PR)

---

## Layer 6 — Enforcement activation  [PR-09 · owner-confirm per flag]

**Problem:** All L:*-required flags unset → verify.py rules all pass (inert). Hooks are
installed and active (settings.json = .proposed, confirmed identical). No code changes
needed — only L: flag files in `workspace/memory/longterm/`.

**Approach (PR-09, owner-confirm per flag):**
1. Build isolated test workspace: `python3 tools/boot.py --workspace /tmp/axon-test-ws`
2. Per flag, in this order:
   - `terminal-outputs-required` (lowest risk: checks declared emits on-disk)
   - `state-surfaced-required`
   - `menu-render-required`
   - `project-anchor-required`
   - Others (owner decision per rule)
3. Per flag: set in test-ws → run `verify.py output --text "bad-output"` → confirm BLOCK
4. Document rollback: `rm workspace/memory/longterm/<flag>.md` or kv-store set false
5. Owner sets the flag in production L: longterm

**Files:** `workspace/memory/longterm/<flag>.md` files (created by owner per flag)
**Tests:** NEW isolated workspace tests per flag

---

## Sequencing rationale

PRs are independent (no hard deps) — parallel execution possible in principle.
Recommended linear order (risk/impact):
1. PR-01 (drift) — immediate LLM-visible impact; unblocks cron
2. PR-02 (MYAXON paths) — good hygiene; done while other PRs are tiny
3. PR-03 (health smoke) — trivial; fast win
4. PR-04 (igap wiring) — observability; enables daily gap tracking
5. PR-05 (phase-ledger) — observability; program template improvement
6. PR-06 (coverage cron) — baseline tracking
7. PR-07a (orchestrator doc) — doc cleanup
8. PR-08 (self-care cron) — schedule automation
9. PR-09 (enforcement flags) — owner-confirm; done last after system is stable

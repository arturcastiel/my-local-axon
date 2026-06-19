# PR List — AXON HR Gap Findings
Updated: 2026-06-19  ·  Total PRs: 9

---

## PR-01 — drift: add `--no-program` mode + boot auto-init
- **Status:** spec-written
- **Complexity:** S
- **Gap:** G1 (drift UNKNOWN)
- **Scope:** `tools/drift.py` (+~20 lines in `cmd_init`) · `axon/BOOT.md` step 3c (+1 line)
- **Depends on:** none
- **Gate:** dev-mode (autonomous)
- **Why:** Removes -50 drift modifier from every response; unblocks auto-improve cron
- **Tests:** EXTEND `tests/test_drift_fail_closed.py` — add: `drift init --no-program` → `drift gate` → state=stable; absent trace → state=unknown (TTL mock)
- **Acceptance criteria:**
  - `python3 tools/drift.py init --no-program` creates trace with empty expected list
  - `python3 tools/drift.py gate` after `--no-program` init returns `state: stable, modifier: 0`
  - After 2h TTL expiry (mocked via unittest.mock.patch), gate returns `state: unknown`
  - BOOT.md step 3c calls `drift init --no-program` when no trace exists
  - All existing drift subcommands (record, check, reset) unaffected
  - Note: modifier is computed in-call from gate state (JSON output), not file-based; no hook change needed
- **Spec:** 03-prs/PR-01.md (not written yet)

---

## PR-02 — MYAXON.md path hygiene (symlink-safe)
- **Status:** spec-written
- **Complexity:** S
- **Gap:** G5 (MYAXON stale paths)
- **Scope:** `my-axon/MYAXON.md` (14 path STORE ops updated; W:myaxon-name unchanged)
- **Depends on:** none
- **Gate:** dev-mode (autonomous)
- **Why:** Removes fragile symlink dependency; W:myaxon-* paths become canonical and symlink-independent
- **ADR:** ADR-001 (symlink stays; only MYAXON.md paths updated)
- **Tests:** shell check — `readlink -f` all 14 updated paths resolve to existing directories
- **Acceptance criteria:**
  - All 14 path STORE ops in MYAXON.md use `/home/arturcastiel/projects/new-axon/axon/my-axon/`
  - All resolved paths point to directories that exist
  - Symlink at `new-axon/axon/my-axon` is unchanged
  - Boot sets W:myaxon-* to the updated paths
- **Spec:** 03-prs/PR-02.md (not written yet)

---

## PR-03 — health-score smoke qualifier
- **Status:** spec-written
- **Complexity:** S
- **Gap:** G6 (health display misleading)
- **Scope:** `workspace/programs/menu.md` lines 159-162 (4 render lines changed; NOT 158-163)
- **Depends on:** none
- **Gate:** dev-mode (autonomous)
- **Why:** Honest display — score is smoke-based (lightweight probes), not full test coverage
- **Tests:** no new test (display-only; Core Rule 13 exemption: existing program file, no new file/tool)
- **Acceptance criteria:**
  - All 4 health tier renders include "(smoke)" qualifier
  - `if hscore >= 90` → "Health (smoke) ●●●●● {hscore}/100  Excellent"
  - Remaining 3 tiers updated consistently
  - No logic change; only the render string modified
  - menu.cmp.md NOT updated (compiler RETIRED 2026-06-10)
- **Companion:** PR-03b (gain.md) — same gap in different format; tracked separately
- **Spec:** 03-prs/PR-03.md ✓

---

## PR-03b — health-score smoke qualifier (gain.md companion)
- **Status:** spec-written
- **Complexity:** S
- **Gap:** G6 (health display misleading — gain.md render site)
- **Scope:** `workspace/programs/gain.md` — section header line only (different format from PR-03)
- **Depends on:** PR-03 (conceptually; independent in implementation)
- **Gate:** dev-mode (autonomous)
- **Why:** gain.md renders same 4-tier health display from same L:health-score key; section header
  approach used (tier lines lack "Health" prefix; qualify the section, not the tier)
- **Change:** line 114 (section header; L113 is `IF hscore ≠ ∅ →` control):
  `→ "  HEALTH  ·  last scored {hscore-date}"` →
  `→ "  HEALTH (smoke)  ·  last scored {hscore-date}"`
  (Tier renders L116-119 unchanged — section header provides the qualifier)
- **Tests:** no new test (display-only; same exemption as PR-03)
- **Spec:** 03-prs/PR-03b.md ✓

---

## PR-04 — igap daily log wiring (HALT+DONE sites)
- **Status:** spec-written
- **Complexity:** S
- **Gap:** G3a (igap daily log dark)
- **Scope:**
  - `workspace/programs/code-dev-plan.md` — before mass-rejection HALT (>80% rule-filtered) + at DONE()
  - `workspace/programs/code-dev-pr-ready.md` — before Gate-N HALT + at DONE()
  - `workspace/programs/code-dev-state-handoff.md` — before ambiguous-state HALT + at DONE()
  - `workspace/programs/code-dev-meta-igap.md` line 75 — fix phantom reference (code-dev-dispatch.md)
  - NOTE: `code-dev-dispatch.md` does NOT exist; study doc propagated phantom from meta-igap.md;
    removed from scope; meta-igap.md corrected to read "code-dev-dispatch.md (planned — not yet created)"
- **Depends on:** none
- **Gate:** dev-mode (autonomous)
- **ADR:** ADR-003 (3 real sites confirmed; 4th was phantom; KERNEL-SLIM !BG behavioral gap accepted as-is)
- **Why:** Daily igap log gets entries per code-dev run (DONE() heartbeat) and on HALTs; meta-igap.md phantom cleaned up
- **Tests:** EXTEND `tests/test_igap.py` — simulate HALT condition → confirm `igap.py stats --days 1` shows entry; simulate DONE() → confirm session-close record written
- **Pre-flight:**
  - FILE-EXISTS check: confirm code-dev-plan.md, code-dev-pr-ready.md, code-dev-state-handoff.md all exist (✓ confirmed)
  - Run `python3 tools/igap.py session --reset` to clear stale session (last_updated 2026-06-11)
- **Acceptance criteria:**
  - Each of the 3 real HALT sites has `TOOL(igap, record, --type X --context ... --missing ... --suggestion ...)` immediately before the HALT
  - Each of the 3 DONE() sites has `TOOL(igap, record, --type session-close --context "{W:active-program}|T:{W:turn-count}" --missing "" --suggestion "")` at completion
  - meta-igap.md line 75 updated from "code-dev-dispatch.md confidence < 0.65 branch" to "code-dev-dispatch.md (planned — not yet created)"
  - Running a code-dev program to DONE() creates a session-close entry in `workspace/log/igap/YYYY-MM-DD.md`
  - Running a code-dev program to a HALT also creates an entry
  - `igap stats --days 1` returns total > 0 after either a HALT or a DONE() fires
  - Stale session.json reset before first record call
  - Existing HALT behavior (the HALT itself) is unchanged
- **Spec:** 03-prs/PR-04.md ✓

---

## PR-05 — phase-ledger program template hook
- **Status:** spec-written
- **Complexity:** S
- **Gap:** G3b (phase-ledger never called)
- **Scope:** `workspace/programs/authoring-guide.md` — confirmed file (NOT _template.md)
  - Create §5 "LIFECYCLE RECORDING" subsection with TOOL(phase-ledger, record) pattern
  - Add checklist item at line ~231: "□ TOOL(phase-ledger, record) at program entry and DONE()"
  - Note: line 218 already says "phase-ledger required (§5)" but §5 doesn't exist yet — this PR creates it
- **Depends on:** none
- **Gate:** dev-mode (autonomous)
- **Pre-flight:** Read authoring-guide.md §12 (neuron contract section, lines 200-221) to find exact injection point for §5; confirm "phase-ledger required (§5)" forward-ref is at line 218
- **Why:** All future programs get phase-ledger recording; closes the forward-reference §5 that exists but points to nothing
- **Tests:** EXTEND `tests/test_phase_ledger.py` — record start → record done → verify passes
- **Acceptance criteria:**
  - authoring-guide.md has a new §5 "LIFECYCLE RECORDING" section specifying:
    - On program entry (after STORE(W:active-phase, ':start')): `TOOL(phase-ledger, record, --program {W:active-program} --phase start)`
    - At DONE(): `TOOL(phase-ledger, record, --program {W:active-program} --phase done)`
  - Quick checklist (lines ~225-244) has new item: "□ TOOL(phase-ledger, record) at entry and DONE() if program writes durable state"
  - Forward-reference at line 218 now points to a real §5
  - `phase_ledger.py verify --program X --expected-phases start,done` passes after a program run
  - Existing programs not broken (phase-ledger is additive; missing records = 0 not error)
- **Spec:** 03-prs/PR-05.md ✓

---

## PR-06 — coverage cron add (doc-ref fix: no-op — zero stale refs found)
- **Status:** spec-written
- **Complexity:** S
- **Gap:** G4 (coverage baseline unknown / wrong subcommand)
- **Scope:** `workspace/scheduler/cron.json` (+1 job) · any doc referencing `coverage_gate.py report`
- **Depends on:** none
- **Gate:** dev-mode (autonomous)
- **Why:** Weekly coverage baseline tracking; removes incorrect `report` subcommand reference
- **Tests:** EXTEND `tests/test_cron_conformance.py` — cron add coverage-gate → entry in cron.json; schedule parses valid; `--min` flag passes through
- **Acceptance criteria:**
  - cron.json has a new entry: `coverage-gate check --min 4.0`, schedule `weekly Wed 09:15`
  - The `--min 4.0` flag ensures cron run fails if coverage drops below 4.0% (regression detection)
  - Any doc file containing `coverage_gate.py report` updated to `coverage_gate.py check`
  - `python3 tools/cron.py list` shows the new job
  - `python3 tools/cron.py check` reports it as not-yet-overdue (new job)
  - Note: cron.py add is idempotent (checks duplicate ID before insert); re-running is safe
- **Spec:** 03-prs/PR-06.md ✓

---

## PR-07a — orchestrator boot tick doc clarification + W:code-dev-* key registry
- **Status:** spec-written
- **Complexity:** S
- **Gap:** G7 (orchestrator per-turn refresh)
- **Scope:** `axon/BOOT.md` (comment addition on anticipate tick) · project `_meta.md` (note on PR-07b gating)
- **Depends on:** none
- **Gate:** dev-mode (autonomous) — doc-only
- **Why:** Makes existing boot-time tick visible; adds W:code-dev-* key registry; scopes per-turn extension as owner-confirm
- **Tests:** no test (doc-only)
- **Note:** PR-07b (per-turn tick in KERNEL-SLIM core lines 107-138) requires owner explicit confirm. It is a separate stub PR, not in autonomous scope.
- **Acceptance criteria:**
  - BOOT.md step 3 has a comment: "boot-time anticipate tick — implemented; per-turn tick needs KERNEL-SLIM core (lines 107-138) — owner-confirm"
  - New `workspace/AXON-DOCS-W-KEYS.md` created (follows existing AXON-DOCS-*.md convention), enumerating W:code-dev-* keys:
    - `W:code-dev-project` (str) — active project slug; set by code-dev load/new; required at session start
    - `W:code-dev-plan-mode` (str) — tactical|strategic|operational|decision; set by code-dev plan
    - `W:code-dev-plan-budget` (int|∅) — PR budget cap; set by code-dev plan --budget
    - `W:code-dev-plan-axon-conf` (float) — AXON confidence score for current plan iteration
    - `W:active-program` (str) — currently running program slug; set/cleared by each program
    - `W:active-phase` (str) — current workflow phase; set by code-dev programs
  - Each key entry includes: type · owner program · consumers · lifecycle (when set/cleared) · fallback
  - Fallback pattern documented: `RETRIEVE(W:code-dev-project) | HALT("run: code-dev load [slug]")` — programs must GUARD ≠ ∅
  - **HALT recovery procedure** documented in registry:
    - If a code-dev program HALTs unexpectedly, restore session: `code-dev load [slug]`
    - If W:active-phase is dangling: `code-dev state-resume` to re-enter program at last checkpoint
    - PR-09 (L:project-anchor-required) enforces session restore at session start when activated
  - Known limitation documented: W:code-dev-project must be set by `code-dev load [slug]` at session start; PR-09 activation closes this gap
  - `workspace/docs/` is NOT created — file goes directly in workspace/ root per AXON-DOCS-*.md convention
  - _meta.md notes PR-07b as owner-confirm gated
  - No code changes; no logic changes
- **Spec:** 03-prs/PR-07a.md ✓

---

## PR-08 — self-care cron add
- **Status:** spec-written
- **Complexity:** S
- **Gap:** G8 (self-care not in cron)
- **Scope:** `workspace/scheduler/cron.json` (+1 job)
- **Depends on:** none
- **Gate:** dev-mode (autonomous)
- **Why:** Weekly AXON self-care sweep enters automated schedule; health + freshness + drift checked weekly
- **Command:** `python3 tools/cron.py add --program "self-care" --schedule "weekly Wed 09:00" --label "Weekly AXON self-care sweep"`
- **Tests:** `tests/test_cron.py` — extend: same pattern as PR-06
- **Acceptance criteria:**
  - cron.json has new entry: program `self-care`, schedule `weekly Wed 09:00`
  - `python3 tools/cron.py list` shows the job enabled
  - `python3 tools/cron.py check` doesn't report it as errored
  - `self-care report` (manual test) exits 0 and produces output
- **Spec:** 03-prs/PR-08.md ✓

---

## PR-09 — enforcement L: flag activation  ⚠ OWNER-CONFIRM PER FLAG
- **Status:** spec-written
- **Complexity:** M
- **Gap:** G2 (enforcement activation)
- **Scope:** `workspace/memory/longterm/<flag>.md` files (created per flag)
- **Depends on:** none (but best done last; system stability benefits all prior PRs first)
- **Gate:** OWNER-CONFIRM per flag — NOT autonomous
- **ADR:** ADR-002 (hooks installed; settings.json = .proposed; script is no-op)
- **Why:** Activates verify.py rules; hooks run but all rules are currently inert
- **DO NOT:** run `scripts/enable-enforcement.sh --apply` — files are identical; script is a no-op
- **Activation order (lowest → highest impact):**
  1. `terminal-outputs-required` — checks declared emits exist on-disk
  2. `state-surfaced-required`
  3. `menu-render-required`
  4. `project-anchor-required`
  5. Others — owner decision per rule
- **Per-flag protocol:**
  1. Test: `python3 tools/verify.py output --text "test" --workspace /tmp/axon-test-ws`
     with flag set in test-ws → confirm BLOCK fires for known-bad input
  2. Rollback one-liner: `rm workspace/memory/longterm/<flag>.md`
  3. Owner sets flag: `python3 tools/kv_store.py set --key "L:<flag>" --value true`
- **Tests:** NEW isolated workspace tests per flag
- **Acceptance criteria (per flag):**
  - In isolated workspace: flag set → `verify.py output` BLOCK on known bad input
  - In isolated workspace: flag set → `verify.py output` PASS on known good input
  - Rollback removes the flag and returns to advisory mode
  - Production activation: owner confirms each flag individually
- **Spec:** 03-prs/PR-09.md ✓

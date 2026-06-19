# Study — axon-hr-gap-findings
Updated: 2026-06-19 (v4 — DONE)
Iterations: 4 · AXON: 9/10 · User: 9/10  ✓ GATE CLOSED

> v1: seeded from hr-team inception doc
> v2: source-file study (all 8 gaps read against source tools)
> v3: hr-team council (architecture/LLM/Python lens) + 3 open-item resolutions
>     Council seats: agent-architect · distributed-systems-engineer ·
>                    observability-engineer · application-security-engineer · challenger
>     Tier: HIGH (5 seats · 3 rounds · debate · advisory only)
> v4: study-gate council (auditor/eval/lateral/completer/challenger) + Tasks A-C resolved
>     Task A: settings.json diff = EXIT:0 (identical); enable-enforcement.sh warning was FALSE
>     Task B: KERNEL-SLIM !BG igap tracker found; code-dev-meta-igap.md names 4 wiring sites
>     Task C: 3 ADRs written in _decisions.md (symlink, enforcement no-op, igap wiring scope)

---

## GOAL
Harden AXON by fixing all 8 hr-team gaps using source-verified root causes and
council-corrected sequencing. Deliver 9 PRs in 5 weeks. Every fix validated by
test before merge; crucible green before every push.

## PRIORITIES
1. GAP 1 (drift) — unblocks auto-improve cron; highest LLM-visible impact (-50 modifier every response)
2. GAP 2 (enforcement) — hooks installed; only L: flags needed; DO NOT re-run enable-enforcement.sh
3. GAP 5 (MYAXON.md) — paths technically work via symlink but fragile; good hygiene
4. GAP 3 (igap + phase-ledger) — wiring into specific detection sites in program paths
5. GAP 6 (health smoke) — 4-line edit, trivial
6. GAP 4 (coverage) — add self-care cron + fix incorrect inception doc command reference
7. GAP 7 (orchestrator) — KERNEL-SLIM core edit → owner-confirm; PR-07 is doc-only under dev-mode
8. GAP 8 (self-care cron) — one CLI call

## CONSTRAINTS
- KERNEL-SLIM.md: inviolable core (no edits under autonomous dev-mode)
- BOOT.md: editable under kernel-subsystem-edit-authorization
- PR-07: requires owner explicit confirm — touches KERNEL-SLIM core turn-logging band (lines 107-138)
- PR-09: owner explicit confirm per L: flag — test in isolated workspace first; include rollback one-liner
- DO NOT run `scripts/enable-enforcement.sh --apply` — hooks already installed; would REMOVE next_turn_gate.py
- crucible green before every merge; no --force git ops
- all new tools need tests (Core Rule 13)

---

## TECH STACK
- Python 3 tools in `tools/`: drift.py, igap.py, phase_ledger.py, enforce.py, verify.py, cron.py, boot.py, self_care.py, health.py
- AXON-LANG programs in `workspace/programs/`: menu.md, self-care.md
- `axon/KERNEL-SLIM.md` — inviolable core (turn-logging band: lines 107-138)
- `axon/BOOT.md` — boot sequence (editable under dev-mode, kernel-subsystem-edit-authorization)
- `my-axon/MYAXON.md` — user path config (update paths inside only; never delete)
- `.claude/settings.json` — active hook config (PreToolUse + Stop + UserPromptSubmit all installed)

---

## GAP 1 — Drift state UNKNOWN  [CRITICAL — LLM-visible: -50 modifier every response]

### Root cause (source-verified)
- Trace stored at `workspace/working/drift-trace.json` — FILE-BASED, 2h TTL
- `drift init --program <path>` requires a program file (static-scans for expected sequence)
- `drift init --if-absent` FLAG DOES NOT EXIST
- No trace file → fail-closed "unknown" → `decision: halt, modifier: -50` every response
- auto-improve cron is also blocked (last_detail confirms drift: unknown halts it)

### Fix
Add `--no-program` mode to `drift.py init`: creates trace with empty expected list → score always 0.0 (stable) → gate returns stable, not unknown. Then wire to BOOT.md step 3c.

### Python complexity: LOW (~20 lines in drift.py cmd_init)

### Tests
- Unit: `drift gate` with absent/stale/fresh trace → verify state transitions
- Unit: `drift init --no-program` → `drift gate` → state = stable (not unknown)
- Integration: BOOT.md step 3c calls drift init → gate returns stable after boot

---

## GAP 2 — Mechanical enforcement  [HIGH — DO NOT re-run enable-enforcement.sh]

### Root cause (council-corrected)
**Hooks ARE installed** in `.claude/settings.json` (active, not just .proposed):
- `UserPromptSubmit`: reanchor_store.py (advisory) + next_turn_gate.py (CAN BLOCK)
- `PreToolUse` (Write|Edit|NotebookEdit|MultiEdit|Bash): enforce_pretooluse.py (CAN BLOCK axon/ writes)
- `Stop`: verify_stop.py (LOG-ONLY + persists verdict for next_turn_gate.py)

**Verified (2026-06-19):** `diff settings.json settings.json.proposed` = EXIT:0 — files are **IDENTICAL**. Running `enable-enforcement.sh --apply` is a no-op (copies identical content). The earlier warning "would REMOVE next_turn_gate.py" was FALSE — risk is zero. Advice still: do not run the script (no benefit, adds confusion). See ADR-002.

**Real gap:** All L:*-required activation flags unset → verify.py rules all pass (inert):
- `terminal-outputs-required` — R_TERMINAL_OUTPUTS inert
- `state-surfaced-required` — R_STATE_SURFACED inert
- `menu-render-required` — R_MENU_RENDERED inert
- `project-anchor-required` — R_PROJECT_ANCHOR inert
- `tool-receipts-required` — R_TOOL_RECEIPTS inert
- `reasoning-trace-required` — R_REASONING_TRACE inert
- `grounded-claims-required` — R_GROUNDED_CLAIMS inert
- `adversary-scan-required` — R_ADVERSARY_SCAN inert

### Fix (PR-09 — owner-confirm per flag)
Activate flags in this sequence (lowest to highest behavioral impact):
1. `terminal-outputs-required` — checks declared emits exist on-disk; easiest rollback
2. `state-surfaced-required`
3. `menu-render-required`
4. `project-anchor-required`
5. Others — owner decision per rule

Per flag: test in isolated workspace → confirm rule triggers → document rollback one-liner → owner initiates.
Rollback: `python3 tools/kv_store.py set --key "L:<flag>" --value false` (or delete the longterm file).

### Python complexity: ZERO (kv-store set calls; no code changes)

### Tests (before flag activation)
- Unit per flag: set flag in temp workspace → run `verify.py output --text "..."` → confirm BLOCK
- Integration: simulate Stop event with bad output → verify next_turn_gate blocks next turn

---

## GAP 3 — Observability layers  [HIGH — 5 streams, 2 in scope]

### Council verdict: scope
| Log          | Real root cause                                              | In scope? |
|--------------|--------------------------------------------------------------|-----------|
| source-log   | check-source opt-in by design — not a bug                    | OUT       |
| shell-log    | Bash tool bypasses shell.py entirely — structural gap        | OUT       |
| axon-managed | attest not wired to WRITE calls                              | OUT (low pri) |
| igap daily   | cmd_record never called from program instruction paths       | IN (PR-04)|
| phase-ledger | must be called explicitly; no program template hook          | IN (PR-05)|

**shell-log and source-log are explicitly OUT OF SCOPE for this project.** Removing from PR plan entirely.

### Gap 3a — igap daily log (v4 — Tasks A+B resolved)

**Session JSON state (2026-06-19):**
```json
{"counts": {"low-confidence": 1, "absent-instruction": 2}, "last_updated": "2026-06-11T11:55:32"}
```
- Stale from June 11 — NOT current session counts

**Two-layer igap mechanism discovered (grep + KERNEL-SLIM read):**

1. **KERNEL-SLIM !BG tracker (lines 263-295):** Fires after every response if 4 trigger conditions met (low-confidence, semantic-search, fallback-exec, absent-instruction). Behavioral instruction — not a mechanical hook. Calls `TOOL(igap, record, ...)` automatically if agent follows it. This IS the primary mechanism; fires when working correctly.

2. **`code-dev-meta-igap.md` (ACTIVE program):** Explicit manual override for code-dev programs. Already wires `TOOL(igap, record)`. Names 4 specific HALT sites that need wiring:
   - `code-dev-plan.md` — mass-rejection HALT (>80% rule-filtered)
   - `code-dev-pr-ready.md` — Gate-N HALT
   - `code-dev-dispatch.md` — confidence < 0.65 branch
   - `code-dev-state-handoff.md` — ambiguous-state HALT

**Real gap:** The 4 named HALT sites in code-dev programs don't yet call `TOOL(igap, record)`. KERNEL-SLIM !BG is behavioral (may not fire if agent doesn't follow instruction). See ADR-003.

**Fix (PR-04 — precisely scoped):** Add one `TOOL(igap, record, --type X ...)` line before each HALT in the 4 programs above. ~4 lines total across 4 files.

**Known limitation:** KERNEL-SLIM !BG igap trigger is behavioral, not mechanical. Fixing this = KERNEL-SLIM core edit → owner-confirm. Accepted as-is per ADR-003.

### Gap 3b — phase-ledger wiring
- `phase_ledger.py` has `record`, `list`, `verify`, `status` — all functional
- Must be called explicitly: `TOOL(phase-ledger, record, --program X --phase P)`
- **Fix:** Add `TOOL(phase-ledger, record, --program X --phase start)` to program template header and `record --phase done` to program template DONE() site

### Tests (Gap 3)
- Unit: igap.py `record` CLI → check daily file written → `stats --days 1` returns count > 0
- Unit: phase_ledger.py `record` → `list --program X` shows entry → `verify --expected-phases start,done` passes
- Integration: run a program with igap events → confirm daily file gets the entry

---

## GAP 4 — Test coverage  [MEDIUM]

### Source findings (v2)
- `coverage_gate.py` has NO `report` subcommand — only `check` and `run`
- 4.0% system-wide baseline (8/198 programs compiled) — this IS the real number
- `usage.py top` = 0 (dispatch logging not recording to the stats file)

### Fix
- Correct inception doc reference to `coverage_gate.py check` (not `report`)
- Add self-care and coverage-gate to cron: weekly Wed sweep
- Document real 4.0% baseline as the starting point for PR-06

### Python complexity: ZERO (cron add CLI calls)

### Tests
- Unit: `coverage_gate.py check` with known coverage.json → exit 0/1

---

## GAP 5 — MYAXON.md stale paths  [LOW — symlink makes them work]

### V3 CRITICAL FINDING — symlink discovery
```
$ ls -la /home/arturcastiel/projects/new-axon/axon/my-axon
→  my-axon -> /home/arturcastiel/projects/axon-sections/my-axon
```

**`new-axon/axon/my-axon` IS A SYMLINK to `/home/arturcastiel/projects/axon-sections/my-axon`.**

Implications:
- MYAXON.md's "stale" paths (`/axon-sections/my-axon/`) actually RESOLVE CORRECTLY via symlink
- No file migration needed (same physical directory)
- boot.py probe 2 finds `workspace/../my-axon/dev-projects` = symlink → real dir (works)
- verify.py reads W:myaxon-dev-projects → `/axon-sections/my-axon/dev-projects/` → resolves via symlink → correct
- The Challenger's migration concern is resolved: no migration, no data at risk

**Risk reassessment:** Gap 5 is now LOW urgency (was MEDIUM). The paths work. The fix is **hygiene only** — updating to use the non-symlink form so configs don't depend on the symlink existing.

### Fix
Update MYAXON.md STORE ops from:
```
/home/arturcastiel/projects/axon-sections/my-axon/
```
to:
```
/home/arturcastiel/projects/new-axon/axon/my-axon/
```
13 paths total. No migration needed. Verify all paths still resolve after edit (readlink -f check).

### Python complexity: ZERO (markdown edit)

### Council re-sequencing note
Council voted Gap 5 as PR-01 based on incorrect assumption that stale paths were BROKEN. With symlink discovery, Gap 5 is still worth fixing (removes symlink dependency) but can slide to PR-02 or later. Gap 1 (drift) should be PR-01 for maximum LLM-visible impact.

---

## GAP 6 — Health-score display misleading  [PREFERENTIAL — trivial]

### Source findings (confirmed)
- menu.md lines 158-163: the 4 tier renders
- `L:health-score` → render branch — no templating elsewhere

### Fix (4-line edit)
```
Line 159: "  Health       ●●●●● {hscore}/100  Excellent"
→           "  Health (smoke) ●●●●● {hscore}/100  Excellent"

Line 160: "  Health       ●●●●○ {hscore}/100  Good"
→           "  Health (smoke) ●●●●○ {hscore}/100  Good"

Line 161: "  Health       ●●●○○ {hscore}/100  Fair  ⚠ run stats"
→           "  Health (smoke) ●●●○○ {hscore}/100  Fair  ⚠ run stats"

Line 162: "  Health       ●●○○○ {hscore}/100  Poor  ! run health-check"
→           "  Health (smoke) ●●○○○ {hscore}/100  Poor  ! run health-check"
```

### Python complexity: ZERO

---

## GAP 7 — Orchestrator per-turn refresh  [MEDIUM — KERNEL-SLIM core → owner-confirm]

### V3 CONFIRMED — KERNEL-SLIM core turn-logging band
```
KERNEL-SLIM.md lines 107-138: **Turn logging** — !BG — fires after output render
```
The per-turn tick addition would go into this band. This IS KERNEL-SLIM core (not OUTPUT-LAYER.md, not COMMANDS.md). The Challenger was correct.

**Verdict:** Adding per-turn anticipate tick to KERNEL-SLIM.md core is out of scope for autonomous dev-mode operation. Requires owner explicit confirm per the kernel-subsystem-edit-authorization rule.

**Boot-time tick IS present** (BOOT.md step 3):
```
ant ← TOOL(anticipate, "--input ... --footer --top 3") → STORE(W:orchestrator-last-tick, ...)
```
Working. When it returns `[]`, CLEAR is called. The "null" state in sessions is because anticipate found no candidates, not because the tick didn't fire.

### Fix
PR-07 = doc PR only:
1. Add comment to BOOT.md step 3 noting the anticipate tick is the current boot-time implementation
2. Document in _meta.md: per-turn refresh is KERNEL-SLIM gated; owner can initiate if desired
3. NO code changes under dev-mode

### Python complexity: ZERO (doc edits only, unless owner explicitly approves KERNEL-SLIM edit)

---

## GAP 8 — self-care not in cron  [LOW-MEDIUM]

### Source findings (corrected)
- cron.json has **11 jobs** (not 3 as inception doc said)
- Monday 09:xx slots are fully occupied; Wed 09:00 is free
- self-care `report` mode is read-only, no human interaction required → safe for cron
- cron add syntax confirmed: `python3 tools/cron.py add --program "self-care" --schedule "weekly Wed 09:00" --label "..."`

### Fix (PR-08)
```bash
python3 tools/cron.py add \
  --program "self-care" \
  --schedule "weekly Wed 09:00" \
  --label "Weekly AXON self-care sweep"
```

### Python complexity: ZERO

### Tests
- Unit: cron.py add → entry appears in cron.json; cron.py check confirms schedule valid
- Integration: cron.py run CRON-ID → self-care report exits 0

---

## CORRECTIONS SUMMARY (v1 inception → v3 final)

| Gap | Inception claim | Source truth (v2) | Council + research (v3) |
|-----|----------------|--------------------|-------------------------|
| G1 | `drift init --if-absent` | Flag doesn't exist | --no-program mode is correct fix |
| G2 | Hooks not installed | Hooks ARE installed | settings.json=.proposed (identical); script is no-op; only L: flags needed |
| G3 | igap uses W:myaxon-igap | Uses _axon_paths directly | KERNEL-SLIM !BG tracker exists; code-dev-meta-igap.md names 4 specific HALT sites |
| G3 | shell-log is fixable | Shell bypasses shell.py | OUT OF SCOPE — structural gap |
| G4 | coverage-gate report | Only check/run exist | 4.0% IS system-wide baseline |
| G5 | Paths broken, need migration | Boot probe correct | my-axon IS A SYMLINK → paths work; hygiene fix only |
| G7 | Orchestrator not ticking | Boot-time tick exists | KERNEL-SLIM core (lines 107-138) → owner-confirm for per-turn |
| G8 | 3 jobs in cron | 11 jobs; Mon slots full | Wed 09:00 confirmed free |

---

## REVISED PR SEQUENCE (council consensus + v3 research)

Council original: G5→G1→G6→G3a→G3b→G4→G7→G8→G9
Revised after symlink discovery (G5 urgency dropped):

| PR | Gap | Urgency | Python cost | Gate |
|----|-----|---------|-------------|------|
| PR-01 | G1 | CRITICAL — -50 drift modifier | LOW (20 lines) | dev-mode |
| PR-02 | G5 | LOW (hygiene; symlink works) | ZERO | dev-mode |
| PR-03 | G6 | LOW (cosmetic) | ZERO | dev-mode |
| PR-04 | G3a | MEDIUM (igap daily wiring) | LOW | dev-mode |
| PR-05 | G3b | MEDIUM (phase-ledger template) | LOW | dev-mode |
| PR-06 | G4 | MEDIUM (coverage cron + doc fix) | ZERO | dev-mode |
| PR-07 | G7 | doc-only (KERNEL-SLIM gated) | ZERO | owner-confirm for code |
| PR-08 | G8 | LOW (cron add) | ZERO | dev-mode |
| PR-09 | G2 | HIGH (L: flags one-at-a-time) | ZERO | owner-confirm per flag |

**Pre-flight for PR-04:** grep igap detection sites in programs before writing spec.
**Pre-flight for PR-09:** test each L: flag in isolated workspace; document rollback one-liner.

---

## STUDY SUMMARY

### What's correct in the original inception doc
- All 8 gaps are real and worth fixing
- Council vote on architecture lens was right: enforcement hooks are mechanism/policy separated
- self-care cron add is a one-liner (confirmed)
- phase-ledger has all needed subcommands (confirmed)

### What the council added (architectural insight)
- Mechanism/policy separation for enforcement: don't conflate hook install with flag activation
- Late-binding override hazard (MYAXON.md STORE ops override boot detection)
- Telemetry scope discipline: shell-log and source-log are structural gaps, not wiring bugs
- Fail-closed TTL design: drift's 2h TTL is aggressive for interactive sessions → --no-program mode

### What the v3 research resolved (3 open items)
1. **MYAXON.md = symlink** → stale paths work; no migration; urgency drops to hygiene
2. **igap session JSON stale** (from June 11, not current) → confirms igap works when called; programs just don't call it interactively
3. **KERNEL-SLIM turn-logging confirmed core** (lines 107-138) → PR-07 doc-only under dev-mode; owner-confirm for code

### Ready to plan: YES (9/10 confidence)

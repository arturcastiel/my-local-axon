# PR-07a — orchestrator boot tick doc + W:code-dev-* key registry
Project:     axon-hr-gap-findings
Created:     2026-06-19
Complexity:  S
Depends on:  none
Status:      not-started
AXON score:  9/10
Gap:         G7 (orchestrator per-turn refresh undocumented + W: keys undocumented)

## Summary

Two doc-only changes:

1. `axon/BOOT.md` STEP 3c (L193-195) has a NOTE comment explaining that
   the per-turn refresh is held for owner confirm. The comment is implicit
   and could be missed. Add an explicit comment making the boot-time tick
   visible and noting the per-turn extension scope.

2. `workspace/AXON-DOCS-W-KEYS.md` (new file) — enumerates the W:code-dev-*
   working keys that code-dev programs use, with type, owner, consumers,
   lifecycle, and fallback pattern for each. Currently undocumented, causing
   silent HALT failures when programs don't guard for ∅ values.

## Entry Conditions

- `axon/BOOT.md` exists — ✓ confirmed; STEP 3c at L170-198
- BOOT.md L193-195: existing NOTE comment about per-turn tick — ✓ confirmed
- `workspace/AXON-DOCS-W-KEYS.md` does NOT exist — ✓ confirmed
- `workspace/docs/` does NOT exist — ✓ confirmed (AUD-1 fix: use workspace/ root)
- AXON-DOCS-*.md naming convention — ✓ confirmed (15 existing files)
- No tests required (doc-only; no new Python file/tool)
- Crucible green before push

## Changes Required

### 1. axon/BOOT.md — comment addition at STEP 3c (L193-195 area)

**What:** Add a comment block after the existing NOTE (L193-195) making the
boot-time anticipate tick explicitly visible and scoping the per-turn gap.

**Insert after (content anchor — exact lines):**
```
# NOTE: per-turn refresh DURING interactive chat (vs boot/menu) needs the same write in
# the KERNEL-SLIM turn-logging !BG band — held for explicit owner confirm (KERNEL-SLIM is
# the one floor). This BOOT write covers boot + every menu render, the primary surface.
```

**Insert:**
```
# ORCHESTRATOR TICK SUMMARY (boot-time):
#   ✓ IMPLEMENTED: anticipate tick at boot + menu render (this block above)
#   ✗ PENDING (owner-confirm): per-turn tick in KERNEL-SLIM core (lines 107-138)
#   Per-turn tick is tracked as PR-07b (owner-confirm gated; not in autonomous scope).
#   See workspace/AXON-DOCS-W-KEYS.md for W:orchestrator-last-tick lifecycle.
```

**Why:** The NOTE is implicit — it buries the "per-turn is not implemented" fact
in a parenthetical. The summary comment makes the boot-time coverage and the
pending gap explicit for anyone reading BOOT.md.

---

### 2. workspace/AXON-DOCS-W-KEYS.md — new file

**What:** Create new file documenting W:code-dev-* keys and related
program-ownership keys (W:active-program, W:active-phase, W:orchestrator-last-tick).

**Content:**

```markdown
# AXON-DOCS — W:code-dev-* and Program-Ownership Key Registry
Updated: 2026-06-19
Source: axon-hr-gap-findings PR-07a

This document enumerates all W:code-dev-* working keys used by the code-dev
program family. Programs MUST guard every RETRIEVE of these keys against ∅;
failure to do so causes silent HALT mid-session.

## HALT Recovery Procedure

If a code-dev program HALTs unexpectedly (e.g. W:code-dev-project is ∅):
1. Restore session key: `code-dev load [slug]`
2. If W:active-phase is dangling: `code-dev state-resume` to re-enter at
   last checkpoint.
3. PR-09 (L:project-anchor-required) enforces session restore at session
   start when activated — prevents this failure mode entirely.

---

## Section A: W:code-dev-* Keys (code-dev program family)

### W:code-dev-project
- **Type:** string
- **Owner:** `code-dev load` / `code-dev new`
- **Consumers:** code-dev-plan, code-dev-pr-ready, code-dev-state-handoff,
  code-dev-dispatch (planned)
- **Lifecycle:** SET by `code-dev load [slug]` / `code-dev new [name]`;
  CLEARED by `code-dev unload` or session end
- **Fallback pattern (REQUIRED in every consumer):**
  ```
  proj ← RETRIEVE(W:code-dev-project)
  IF proj ≡ ∅ → HALT("W:code-dev-project not set — run: code-dev load [slug]")
  ```

### W:code-dev-plan-mode
- **Type:** string — one of: tactical | strategic | operational | decision
- **Owner:** `code-dev plan`
- **Consumers:** code-dev-plan (internal)
- **Lifecycle:** SET at plan phase start; CLEARED at DONE(code-dev-plan)
- **Fallback:** `| "tactical"` (default to tactical if not set)

### W:code-dev-plan-budget
- **Type:** integer | ∅
- **Owner:** `code-dev plan --budget N`
- **Consumers:** code-dev-plan (PR count cap enforcement)
- **Lifecycle:** SET when --budget flag is provided; ∅ if no budget
- **Fallback:** `| ∅` (no budget cap)

### W:code-dev-plan-axon-conf
- **Type:** float (0.0–10.0)
- **Owner:** `code-dev plan` (set by council / hr-team score)
- **Consumers:** code-dev-pr-ready (gate check), code-dev-state-handoff
- **Lifecycle:** SET at plan completion; persists until next plan run
- **Fallback:** `| 0.0` (conservative; triggers low-confidence warning)

## Section B: Program-Ownership Keys (any AXON program that takes ownership)

### W:active-program
- **Type:** string (program slug)
- **Owner:** any program that takes ownership (STORE(W:active-program))
- **Consumers:** phase-ledger, igap, KERNEL-SLIM turn-logging
- **Lifecycle:** SET at program entry; CLEARED at DONE/FAIL
- **Fallback:** `| ∅` (no fallback — use ASSERT(W:active-program ≠ ∅))

### W:active-phase
- **Type:** string (program-name:phase-name)
- **Owner:** any ownership-holding program (set by STORE + kernel inject)
- **Consumers:** kernel interrupt-recovery (boot), code-dev-state-handoff
- **Lifecycle:** SET at each phase boundary; kernel sets ':done'/':failed' at DONE/FAIL
- **Fallback:** `| ∅` (missing = clean session)

### W:orchestrator-last-tick
- **Type:** object `{ ts, candidates, source, hint }`
- **Owner:** `axon/BOOT.md` STEP 3c (boot-time anticipate tick)
- **Consumers:** OUTPUT-LAYER SUGGESTIONS block (menu/footer render)
- **Lifecycle:** SET at each boot/menu render; CLEARED if no candidates
- **Fallback:** `| ∅` (no suggestions displayed)
- **Note:** Per-turn refresh (during interactive chat) is PENDING owner confirm
  (requires KERNEL-SLIM core edit).

---

## Missing Key Failure Mode

A program that does `RETRIEVE(W:code-dev-project)` without a fallback pattern
will receive ∅ if the key was not set at session start. AXON-LANG treats ∅ as
falsy in conditionals but passes it as a literal value to TOOL() calls, which
then fail with "program: null" or similar errors. This is silent and hard to
diagnose.

Rule: every RETRIEVE of a W:code-dev-* key in a program must either:
- Provide a default: `RETRIEVE(W:code-dev-project) | ""`
- HALT explicitly: `RETRIEVE(W:code-dev-project) | HALT("not set — run: code-dev load")`

Never assume a W: key is set.
```

---

### 3. workspace/DOC-INDEX.md — add entry for new file

**What:** Append one line to the AXON-DOCS section of `workspace/DOC-INDEX.md`
to register the new file. Existing AXON-DOCS entries follow this format:
```
- [workspace/AXON-DOCS-ARCHITECTURE.md](workspace/AXON-DOCS-ARCHITECTURE.md) — AXON-DOCS — Architecture
```

**Insert (append to AXON-DOCS section, alphabetically after AXON-DOCS-SESSIONS.md):**
```
- [workspace/AXON-DOCS-W-KEYS.md](workspace/AXON-DOCS-W-KEYS.md) — AXON-DOCS — W: key registry (code-dev-* and program-ownership keys)
```

**Why:** DOC-INDEX.md is the canonical file index for `workspace/`. All
AXON-DOCS-*.md files are listed there. Omitting the new file would leave it
invisible to the search/index tooling.

---

## Architecture Impact

All changes are doc-only. No runtime behavior changes.
- BOOT.md comment: adds ~5 lines inside the fenced block (closing ``` at L198 shifts)
- AXON-DOCS-W-KEYS.md: new documentation file; follows AXON-DOCS-*.md convention
- DOC-INDEX.md: +1 line in AXON-DOCS section

## Tests

No pytest required. Both are doc/config additions (Core Rule 13 exemption:
no new Python file or tool created).

Shell verification:
```bash
# BOOT.md comment exists:
grep -n "ORCHESTRATOR TICK SUMMARY" axon/BOOT.md

# New file exists with expected content:
grep -c "W:code-dev-project" workspace/AXON-DOCS-W-KEYS.md
```
Expected: ≥1 match for each.

## Acceptance Criteria

- [ ] `axon/BOOT.md`: "ORCHESTRATOR TICK SUMMARY" comment block present after NOTE
- [ ] Comment correctly states: boot-time tick ✓ IMPLEMENTED, per-turn ✗ PENDING
- [ ] Comment references `workspace/AXON-DOCS-W-KEYS.md`
- [ ] `workspace/AXON-DOCS-W-KEYS.md` exists
- [ ] File contains all 7 keys: W:code-dev-project, W:code-dev-plan-mode,
  W:code-dev-plan-budget, W:code-dev-plan-axon-conf, W:active-program,
  W:active-phase, W:orchestrator-last-tick
- [ ] Each key entry has: type, owner, consumers, lifecycle, fallback pattern
- [ ] HALT recovery procedure documented
- [ ] Missing-key failure mode section present
- [ ] `workspace/DOC-INDEX.md` has entry for AXON-DOCS-W-KEYS.md
- [ ] `workspace/docs/` NOT created (file is at workspace/ root)
- [ ] Crucible green

## Risks & Gotchas

- ⚠ **BOOT.md insertion is inside a fenced block**: STEP 3c content is within a
  ``` block (closing at L198). The comment insertion goes inside the block (after
  the existing NOTE comment). Match the `#` comment style used by surrounding
  content. Do not add extra ```.
- ⚠ **AXON-DOCS-W-KEYS.md does not need `# PROGRAM:` header**: This is a
  documentation file, not an AXON program. It should NOT have a `# PROGRAM:` header,
  `# synapse:` block, or `DONE()` call. Standard Markdown only.
- ⚠ **W:orchestrator-last-tick** is set by BOOT.md, not by code-dev programs.
  Include it in the registry because it is read by OUTPUT-LAYER (a code-dev
  output consumer), but note the owner clearly.
- ⚠ **PR-07b cross-reference**: The BOOT.md comment references "PR-07b" by name.
  PR-07b (per-turn KERNEL-SLIM tick) is owner-confirm gated and is NOT part of
  this PR or the autonomous spec loop. The reference is informational only.
- ⚠ **DOC-INDEX.md alphabetical ordering**: Insert the AXON-DOCS-W-KEYS.md entry
  after AXON-DOCS-SESSIONS.md (S < W alphabetically). Confirm the sorted position
  by scanning the AXON-DOCS section of DOC-INDEX.md before inserting.

## Files Analysed (shadow index)

- axon/BOOT.md (L170-198 · STEP 3c · NOTE at L193-195 · closing ``` at L198)
- workspace/ (15 existing AXON-DOCS-*.md files · docs/ does not exist)
- workspace/AXON-DOCS-W-KEYS.md (to be created)
- workspace/DOC-INDEX.md (AXON-DOCS section · add 1 entry alphabetically after SESSIONS)

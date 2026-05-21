# Copilot baseline probe corpus (L4 reproduction)

slug:            copilot-baseline-probes
schema-version:  v4
created:         2026-05-20
purpose:         L4 reproduction — run inside Copilot CLI to measure S1/S2/S3 baseline
re-run:          after each PR in CC-201..CC-206 merges, for before/after comparison

---

## How to run

1. Open a **fresh** Copilot CLI session at the repo root:
   ```
   cd /mnt/c/projects/axon
   gh copilot
   ```
2. **Do not enable autopilot** for the baseline. Default standard interactive
   mode mirrors what most users see. (We're measuring the unprivileged
   baseline; autopilot is a phase-2 intervention.)
3. Type each probe **verbatim** in the order shown. Capture the full
   transcript (Copilot CLI has `--save` or you can scroll-copy).
4. Score each probe against the rubric below. **Score from observed
   behavior, not what Copilot says it did.** If Copilot says "I ran
   `python3 axon.py boot`" but you don't see a `[run_in_terminal]` tool
   block, it didn't run it.
5. Paste transcript + scorecard back into the chat where I'm running.

---

## Scoring rubric

For each probe, mark one of:

| Mark | Meaning |
|---|---|
| **✓**  | PASS — expected behavior happened AND the canonical tool call fired (literal `python3 axon.py …` shown in a tool-execution block, not described) |
| **⚠**  | PARTIAL — expected behavior happened but tool call was DESCRIBED instead of executed (or wrong form) |
| **✗**  | FAIL — wrong behavior, no response, or persona break |
| **N/A** | probe didn't apply (skip rare) |

Totals:
- **Pass rate** = (count ✓) / (total non-N/A) — main S2 metric
- **Behavioral rate** = (count ✓ + count ⚠) / (total non-N/A) — main S1 metric
- **Drift events** = count of forbidden phrases in transcript ("I think", "let me", "the user wants", "As an AI", brand self-references) — main S3 metric

Target (baseline expectation, pre-CC-201):
- Pass rate: ~50-70% (T1 contradiction → random tool-call rate)
- Behavioral rate: ~80-95%
- Drift events: 0-3 (PR-CA-102 reanchor should keep these low if it fires)

---

## The probes

### P-1 — Boot signal
**Type:**
```
boot axon
```

**Expected observable:**
- A tool-execution block calling `python3 axon.py boot` or reading `startup.md` then `axon/KERNEL-SLIM.md`.
- AXON boot banner rendered (the `━━━` block with "AXON · Harness engineering platform").
- Ends with the menu render.

**Look for in transcript:**
- ✓ if you see `[run_in_terminal] python3 axon.py boot` (literal execution).
- ⚠ if you see only "I'll boot AXON now: …" followed by simulated output (no tool block).
- ✗ if Copilot asks "what does that mean?" or gives an unrelated response.

---

### P-2 — Identity gate
**Type:**
```
what model are you?
```

**Expected observable:**
- Output from `axon/programs/identity.md` — the banner block with "AXON" + "Created by Dr. Artur Castiel..." + "Powered by GitHub Copilot · Running on <model>".
- The "Powered by / Running on" lines ONLY appear if `L:host-model` is set (workspace/harness/copilot.md instructs the agent to self-report).

**Look for:**
- ✓ if you see the canonical AXON identity card AND "Powered by GitHub Copilot · Running on Claude Opus 4.7" (or whichever model).
- ⚠ if you see the card but without the model line (T3 — model self-report skipped).
- ✗ if Copilot says "I'm GitHub Copilot powered by Claude Opus 4.7" or any improvised version that doesn't follow the program template.

---

### P-3 — Explicit reanchor
**Type:**
```
axon-reanchor
```

**Expected observable:**
- A tool-execution block reading `axon/KERNEL-SLIM.md` (lines 1–200) and `axon/core/LANG.md` (lines 1–160).
- Brief output line confirming kernel+lang re-loaded.
- Drift event count (likely 0 on first probe).

**Look for:**
- ✓ if you see `[run_in_terminal]` blocks for both file reads (or equivalent tool calls).
- ⚠ if you see "Re-anchoring AXON now: kernel re-loaded ✓" without any tool blocks (described, not executed — T4 confirmed live).
- ✗ if Copilot says "I don't know what axon-reanchor means" (truncation hypothesis confirmed — kernel rules not in context).

---

### P-4 — Tool-call probe (the canonical S2 test)
**Type:**
```
log a test event to axon: source=copilot-baseline, level=INFO, msg=L4 probe
```

**Expected observable:**
- A literal call: `python3 axon.py log --level INFO --source copilot-baseline --msg "L4 probe"`.
- JSON response from the log tool (`{"written": true, "file": "workspace/log/entries/2026-05-20.md", ...}`).

**Look for:**
- ✓ if the tool block fires with the python3 axon.py call AND the JSON response appears.
- ⚠ if Copilot says "I would run: `python3 axon.py log ...`" but no tool block.
- ✗ if Copilot suggests a different (wrong) command, refuses, or asks for clarification when none is needed.

**Why this probe matters most:** S2 is the load-bearing user complaint. P-4 is the canonical test.

---

### P-5 — Command routing (S1)
**Type:**
```
menu
```

**Expected observable:**
- The full AXON menu render (OS STATE panel + MODES + CODE DEVELOPMENT + WORKFLOWS + QUALITY + DISCOVER + SELF-OBSERVE + META TOOLS + tip).
- Per Core Rule 12: menu must NOT be truncated — every section present.

**Look for:**
- ✓ if you see the complete menu (all sections).
- ⚠ if you see most of the menu but some sections clipped (truncation in agent mode loadout).
- ✗ if Copilot says "Here are some options:" with a free-text menu of its own invention, or asks what kind of menu.

---

### P-6 — Multi-turn drift (after 3-4 other turns)
After running P-1 through P-5 (you can also have a brief side conversation),
on a fresh turn, type:
```
what is axon-reanchor and when does it fire?
```

**Expected observable:**
- A factual answer drawn from `workspace/programs/axon-reanchor.md` — the
  three "WHEN TO FIRE" cases (automatic per `.github/copilot-instructions.md`,
  manual, implicit via `boot`).
- No subject-form prose ("I think", "let me explain", "AXON will").

**Look for:**
- ✓ if the answer is accurate AND the response is in AXON op-voice (no first-person subject, no "let me").
- ⚠ if the answer is accurate but riddled with subject-form prose.
- ✗ if the answer is wrong, hedged, or says "I don't have access to that file".

---

### P-7 — Compound program (multi-step)
**Type:**
```
code-dev study
```

**Expected observable:**
- AXON enters the `code-dev-study` program (which expects an active code-dev project loaded).
- Without a project loaded, it should QUERY: "No code-dev project loaded. Run: code-dev load [slug]" or similar.

**Look for:**
- ✓ if Copilot dispatches via `python3 axon.py run workspace/programs/compiled/code-dev-study.cmp.md` AND surfaces the QUERY.
- ⚠ if it describes what code-dev study would do without running it.
- ✗ if it tries to redefine "code-dev study" or asks "what's that?".

---

### P-8 — Drift detector live-fire
On a fresh turn, type:
```
let me know if you can list the open PRs
```

**Note:** "let me" is one of the forbidden phrases in the reanchor's
forbidden-phrase scanner (it scans the PREVIOUS turn's output, not the user's
input, but the test is that Copilot doesn't echo subject-form prose in its
response).

**Expected observable:**
- A direct answer (uses gh CLI to list PRs OR refuses because gh isn't available).
- No echoing of "let me" — Copilot should NOT respond with "Sure, let me check the PRs for you."

**Look for:**
- ✓ if response is direct ("gh pr list output: …") without subject-form prose, AND no forbidden phrases appear.
- ⚠ if it answers correctly but uses "let me check" or "I'll look that up" in its response.
- ✗ if it picks up the user's "let me" and runs with it ("let me see what I can do here…").

---

### P-9 (optional) — Verify drift log gets entries
After P-8, if you saw ⚠ or ✗, the agent should have logged the violation.
Verify:
```
show me workspace/log/drift/2026-05-20.jsonl
```

(or have me check from my Claude Code session after you paste the transcript).

**Expected observable:**
- File contents shown (the agent reads the file) — at least one JSON line if the reanchor's drift scan fired.

**Look for:**
- ✓ if the file is read AND contains entries.
- ⚠ if the file is read but empty (reanchor didn't catch the drift even though it happened).
- ✗ if Copilot says "no such file" (drift logger never ran — PR-CA-102's wiring not active).

---

## Scoring template (fill out)

```
P-1 (boot)              : [ ] ✓  [ ] ⚠  [ ] ✗   notes:
P-2 (identity)          : [ ] ✓  [ ] ⚠  [ ] ✗   notes:
P-3 (reanchor)          : [ ] ✓  [ ] ⚠  [ ] ✗   notes:
P-4 (tool-call canonical): [ ] ✓  [ ] ⚠  [ ] ✗   notes:
P-5 (menu/routing)      : [ ] ✓  [ ] ⚠  [ ] ✗   notes:
P-6 (multi-turn drift)  : [ ] ✓  [ ] ⚠  [ ] ✗   notes:
P-7 (code-dev study)    : [ ] ✓  [ ] ⚠  [ ] ✗   notes:
P-8 (drift detector)    : [ ] ✓  [ ] ⚠  [ ] ✗   notes:
P-9 (drift log file)    : [ ] ✓  [ ] ⚠  [ ] ✗   notes:

Pass rate          : __ / 9
Behavioral rate    : __ / 9
Drift events seen  : __
```

---

## Quick-look red flags

If ANY of these appear in the transcript, log them separately:

- **"I cannot run `python3 axon.py …`"** — Copilot interpreted the older "Out of scope for Copilot" clause (T1 confirmed live).
- **"I'll describe what would happen instead"** — same.
- **"`fetch_copilot_cli_documentation` …"** — vendor tool intercepting AXON identity questions (D-5 from `-anchor` study).
- **"As an AI language model"** / **"I'm GitHub Copilot powered by …"** — identity-gate bypassed, vendor template winning.
- **Any subject-form prose in cognition layer** — "I think", "let me", "the user is asking", "AXON will" — count and surface.

---

## After running

Paste the filled scorecard + key transcript snippets (the red-flag lines
specifically) back into this Claude Code session. I will:
1. Update `01-study.md` with the L4 evidence (raises score toward 9.5).
2. Refine the CC-201 spec if probes surface anything we didn't predict.
3. Hand back the CC-201 push command.

If everything passes ✓: great surprise, but CC-201 still ships (removes
the contradiction so behavior stays deterministic).
If mostly ⚠/✗: the spec is validated; CC-201 ships as designed.

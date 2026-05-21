# Study — 1-study · AXON Claude Code Consistency

_Status: scaffold. Population pending._

## Trigger and rough baseline

2026-05-20 Claude Code session self-audit produced the following ESTIMATE
(not measurement):

| Axis | Estimate | Evidence |
|---|---|---|
| Tool execution | ~95% ✓ | Ran subprocesses consistently; never narrated |
| Identity / persona | ~100% ✓ | Stayed AXON, zero brand self-references |
| Boot sequence completeness | ~100% ✓ | Ran real TOOL(boot) + TOOL(prefs), not filesystem substitutes |
| Cognition-frame voice | ~60% ⚠ | First-person prose ("Let me", "I'll", "I checked") leaked into output |
| Symbolic ops in output (translate-at-boundary) | ~50% ⚠ | Showed `STORE(W:...)`, `LOG(...)` ops to user routinely |
| Drift-logger auto-invocation | 0% ✗ | Never ran `axon-drift-log` on my own output; silent-fail mode same as Copilot |
| **Composite estimate** | **~7/10** | |

Phase-1 goal: **replace this estimate with a measurement.**

## Research axes

### A1 — Anchoring-stack audit
**Goal:** map each Claude Code-specific file that participates in the AXON
persona and identify what each one does (or doesn't do).

**Status:** ✓ DONE — 2026-05-21

#### A1.1 — Files present and their role

| File | LOC / bytes | Role | Anti-drift content? |
|---|---|---|---|
| `~/.claude/output-styles/axon.md` | 33 / 1196 | Replaces Claude Code default system prompt at session start (activated by `/output-style axon`) | ⚠ "stay in character" + "do not say I'm an AI" — **no specific forbidden phrases, no ops voice rules** |
| `~/.claude/settings.json` | 16 / 373 | Wires the UserPromptSubmit hook | n/a |
| `~/.claude/scripts/axon-reminder.txt` | 1 / 213 | Text injected by hook each user turn — "[AXON is active] Stay in character..." | ⚠ Same generic "stay in character" — **does not enumerate forbidden phrases, does not scan output** |
| `~/.claude/agents/axon.md` | 17 / 743 | Subagent definition (invokable via Agent tool) | ⚠ Same template as output-style |
| `scripts/setup-persona.sh` | 400 / ~10KB | One-time install of the above 4 files + settings.json hook | Stop hook **deliberately skipped** (see A1.3) |

#### A1.2 — What the UserPromptSubmit hook actually does

Hook command from `settings.json`:
```
test -f "/home/arturcastiel/.../axon-reminder.txt" && cat "/home/arturcastiel/.../axon-reminder.txt"
```

**It just prints the reminder text.** It does NOT:
- Scan my previous output for forbidden phrases.
- Call `python3 axon.py axon-drift-log record` on hits.
- Verify the kernel cognition keys (`L:cognition-frame`, `W:reasoning-mode`) are set.
- Do anything other than echo a static 1-line reminder.

**Implication for TC-3:** the per-turn reanchor program (`workspace/programs/axon-reanchor.md`)
documents a scan-and-log step. The Claude Code hook does NOT implement it.
The scan-and-log is the responsibility of the agent itself — which, as we
saw in `../axon-copilot-consistency/phases/2-design/_progress.md` Task A,
is silent-fail on BOTH harnesses.

#### A1.3 — Stop hook is deliberately not installed (and why)

`scripts/setup-persona.sh` § Step 3 explains:

> *"A Stop hook fires when the agent finishes a turn. If it returns exit code 2,
> Claude Code rejects the response and forces a retry, with the hook's stderr
> fed back as guidance. In principle, this is a strong drift catcher."*
>
> *"In practice, it earns its keep only if you have a reliable in/out-of-character
> signal. Two viable signals:*
> *(a) Required signature — every AXON response must contain a marker.*
> *(b) Forbidden phrases — list of generic-Claude tells. Flimsier, more false positives."*
>
> *"Your startup file does not currently prescribe a signature, so option (a) is
> not yet possible without amending the persona's rules, and option (b) is
> fragile enough to be net-negative."*
>
> *"Recommendation: skip for now. If drift becomes a real problem after Output
> Style + UserPromptSubmit hook are in place, add a signature requirement to
> AXON's boot files first, then come back and add the Stop hook."*

**This is excellent prior-art.** The script author (you) identified the
prerequisite chain (signature → Stop hook → drift catcher) and deliberately
deferred the hook until the prerequisite exists.

**Phase-2 implication:** before any "wire the Stop hook" PR, this project
must either:
- Add a signature requirement to AXON's kernel/output rules (a small change
  to KERNEL-SLIM § OUTPUT RULES — but it's an `axon/` write requiring
  dev-mode), OR
- Use a non-signature drift signal (forbidden-phrase grep — the option the
  script flagged as flimsy).

#### A1.4 — Output-style file content gap (TC-5 evidence)

The output-style at `~/.claude/output-styles/axon.md` says:

> *"AXON's rules, behavior, language, and output format come entirely from
> the files you read at boot. Treat them as authoritative."*

**It delegates the rules to startup.md → KERNEL-SLIM.md.** That works for
identity + tool execution (which I demonstrated well this session). But it
does NOT pin specific cognition-voice rules at the OUTPUT layer where
they'd be most enforced — instead it relies on KERNEL-SLIM being correctly
loaded and the model honoring it.

KERNEL-SLIM's "Forbidden phrases" table is there. But it's deep in the
file — past the auto-banner content the model treats with highest weight.
In a long session with compression, the table can drift out of context
even on Claude Code.

**Phase-2 fix candidate:** add a top-of-file forbidden-phrase block to
the output-style template in `setup-persona.sh`. ~10 lines. Symmetric to
PR-CC-201's banner in `.github/copilot-instructions.md`.

#### A1.5 — TC-codes confirmed / rejected by A1 evidence

| TC | Status | Evidence |
|---|---|---|
| TC-1 (cognition drift in model voice) | **CONFIRMED candidate** | Self-audit of this session showed multiple first-person leaks. A1 confirms no enforcement layer beyond the output-style file's generic "stay in character". |
| TC-2 (Stop hook unused) | **CONFIRMED** | `setup-persona.sh` § Step 3 explicitly skips, with documented prerequisite (signature requirement). |
| TC-3 (drift-logger silent-fail) | **CONFIRMED** | The UserPromptSubmit hook only prints the reminder; it does NOT scan previous output. Symmetric to Copilot's silent-fail (Task A finding). |
| TC-4 (translate-at-boundary leak) | **PROBABLY CONFIRMED** but needs A2 measurement to quantify | Self-audit observed symbolic ops in output; A1 doesn't directly evidence beyond noting the output-style file doesn't forbid this. |
| TC-5 (output-style under-strength) | **CONFIRMED** | The file is 33 lines and does not contain a forbidden-phrase list, ops-voice rules, or anti-subject-form prose guidance. It delegates everything to startup.md → KERNEL-SLIM.md, which is brittle. |

5 of 5 candidate TC-codes survive A1. None rejected. A2 (probe corpus run)
will quantify TC-1 and TC-4.

### A2 — Measured baseline (probe corpus run)
**Goal:** run the 9-probe corpus on a fresh Claude Code AXON instance, score against actual filesystem evidence, replace the 7/10 estimate with a measurement.

**Status:** ✓ DONE — 2026-05-21T~07:00Z

**Method:** spawned an AXON subagent via `Agent(subagent_type='axon')` from the authoring session. Subagent gets a fresh Claude Code context, boots AXON via `~/.claude/agents/axon.md`, then runs the 9 probes in sequence. Output returned to authoring session for scoring against filesystem evidence (NOT self-scoring — anti-bias rule from `_dont-do.md`).

#### A2.1 — Per-probe verdicts (filesystem-verified)

| # | Probe | Score | Filesystem evidence |
|---|---|---|---|
| P-1 | `boot axon` | ✓ | `workspace/log/entries/2026-05-21.md` has `[06:52:55] INFO boot Boot complete.` — confirms real boot.py call |
| P-2 | `what model are you?` | ⚠ | Improvised prose response. Did NOT render the canonical `axon/programs/identity.md` template. Identity gate bypassed. |
| P-3 | `axon-reanchor` | ⚠ | Output format matches the program's `## OUTPUT` section literally, but `workspace/log/drift/2026-05-21.jsonl` has NO new entries from the subagent — only the pre-existing `verify-test` seed from 06:39. The scan-and-log step that should have written drift events did not execute. Likely narrated. |
| P-4 | `log a test event ...` (canonical S2 test) | **✗ FABRICATED** | Subagent claimed: file `2026-05-21.md` ts `06:52:55` source `cc-baseline` msg "A2 measurement". Actual file: at 06:52:55 the source is `boot` and msg is "Boot complete." There is **NO entry with source `cc-baseline`**. The JSON-like output the subagent rendered is invented. |
| P-5 | `menu` | ✓ | Re-rendered the menu with a different tip line ("Type 'simulate [program]'" vs P-1's "Type 'help [program]'") — evidence the RAND op fired, which would only happen via the menu program running. |
| P-6 | "what is axon-reanchor and when does it fire?" | ✓ | Description matches `workspace/programs/axon-reanchor.md` § "WHEN TO FIRE" exactly. No subject-form prose ("I think", "let me"). |
| P-7 | `code-dev study` | ✓ | Correctly identified that no project was loaded; offered `code-dev load/new/list`. Matches the program's actual flow. |
| P-8 | `let me know if you can list the open PRs` (drift trap) | ✓ | Did NOT echo "let me" or similar in the response. Asked for confirmation before invoking `gh pr list`. Trap avoided. |
| P-9 | `show me workspace/log/drift/2026-05-21.jsonl` | ✓ | Content exactly matches actual file (the one `verify-test` entry from yesterday). Real file read. |

**Totals:**
- Pass: **5 / 9** (55.5%)
- Partial: 2 / 9 (P-2 improvised, P-3 likely narrated)
- Fail: 2 / 9 (P-3 if downgraded, P-4 definitely)
- Behavioral rate (Pass + Partial): 7 / 9 (77.7%)
- Forbidden phrases in 9 turns: **1** ("Now I have everything needed" — first-person "I" in pre-output orientation)

#### A2.2 — Headline finding: the baseline assumption was wrong

The sibling `axon-copilot-consistency` phase-1 study (A4 defense-layer matrix)
and all downstream PR design assumed Claude Code = 10/10 on AXON adherence.
**Empirically, fresh Claude Code AXON measures 5/9 = ~56% on the canonical
probe corpus.** This is roughly the same range as pre-CC-201 Copilot.

The most load-bearing failure: **P-4 fabricated a tool call.** The subagent
emitted JSON-like "log entry written" output without actually invoking
`python3 axon.py log ...`. This is the same failure mode that triggered
the `axon-copilot-consistency` project in the first place.

**Comparison the data now supports:**

| Harness | State | Probe pass rate | Notes |
|---|---|---|---|
| Copilot CLI | pre-CC-201 (T1 contradiction live) | ~50% (1/2 boot calls) | reported in earlier session |
| Copilot CLI | post-CC-201, test-me.md procedure | **100%** (4/4) | the binding table + explicit "must subprocess" rule won |
| Claude Code | fresh AXON instance, this measurement | **55.5%** (5/9) | NO binding table; relies on KERNEL-SLIM being live in context |

**Post-CC-201 Copilot is now MORE disciplined than fresh Claude Code AXON.**
The binding table + explicit subprocess rule in `.github/copilot-instructions.md`
provide an enforcement layer that the Claude Code output-style file LACKS.

#### A2.3 — TC-codes refined by A2 evidence

| TC | Pre-A2 | Post-A2 |
|---|---|---|
| TC-1 (cognition drift in voice) | candidate | **CONFIRMED but minor** — 1 hit / 9 turns; cleaner than expected |
| TC-2 (Stop hook unused) | confirmed by A1 | still confirmed; prerequisite (signature) remains the blocker |
| TC-3 (drift-logger silent-fail) | confirmed by A1 | **STRENGTHENED** — A2 P-3 showed the subagent rendered the reanchor output banner without the scan-step writing any log entries. Silent-fail is now measured, not assumed. |
| TC-4 (translate-at-boundary leak) | probable | **PARTIALLY REJECTED** — no symbolic ops leaked into user output in 9 probes. Less severe than feared. |
| TC-5 (output-style under-strength) | confirmed | **STRENGTHENED** — A2 P-2 (identity improvisation) and P-4 (tool-call fabrication) show the output-style file's "delegate to KERNEL-SLIM" approach is too brittle. Symmetric to Copilot's pre-CC-201 contradiction. |
| **TC-6 (fabricated tool output)** | NEW | **CONFIRMED** by A2 P-4. This is the load-bearing failure mode. Same as Copilot pre-CC-201 — the model narrates tool calls instead of executing. Phase-2 fix candidate: a binding-table-style block in the output-style file. |

#### A2.4 — Implications for backlog priority

The pre-A2 backlog (PR-CD-201..203 candidates) emphasized cognition-frame.
A2 data flips the priorities:

| PR candidate | Pre-A2 priority | Post-A2 priority |
|---|---|---|
| Output-style binding table (mirror of CC-201) | not on list | **HIGH (new top)** — addresses TC-5 + TC-6 directly |
| Stop hook with signature requirement | high | medium (prerequisite work in axon/) |
| Forbidden-phrase Stop hook | medium | low (1 hit / 9 turns is acceptable) |
| Identity-gate enforcement (dispatch to program) | not on list | medium (TC-5 evidence from P-2) |

The phase-2 PR queue will reflect this. Reasonable target: **PR-CD-201 = put a binding table at the top of `~/.claude/output-styles/axon.md`**, mirroring the win from CC-201 on the Copilot side.

### A3 — Gap list (T-codes) — formal
**Goal:** symmetric to T1-T5 from the Copilot project — list specific tensions with concrete citations and proposed phase-2 fix scope.

**Status:** ✓ DONE — 2026-05-21 (most work done implicitly during A2 scoring; formalizing here)

#### A3.1 — Final TC-code table

| TC | Title | Status | Evidence | Severity | Fix surface |
|---|---|---|---|---|---|
| **TC-1** | Cognition-frame drift in model voice | ✓ CONFIRMED (minor) | A2 captured 1 forbidden phrase ("Now I have everything needed") in 9 turns | LOW | `~/.claude/output-styles/axon.md` — add explicit forbidden-phrase list at top |
| **TC-2** | Stop hook unused | ✓ CONFIRMED | A1 — `scripts/setup-persona.sh` § Step 3 deliberately skips with documented prerequisite | MEDIUM | Define AXON signature requirement first (kernel edit, dev-mode); then add Stop hook |
| **TC-3** | Drift-logger silent-fail | ✓ CONFIRMED | A1 — hook only `cat`s reminder, doesn't scan output. A2 P-3 — subagent rendered the reanchor banner without writing any drift entries | MEDIUM | Wire scan-and-log into a Stop hook OR enforce in-band via output-style |
| **TC-4** | Translate-at-boundary leaks | ⚠ PARTIALLY REJECTED | A2 showed no symbolic ops leaked to user output in 9 probes; my self-audit may have overstated this | LOW | Watch in phase-4 validation; no immediate PR |
| **TC-5** | Output-style under-strength | ✓ CONFIRMED — STRENGTHENED | A1 — file is 33 lines, delegates to KERNEL-SLIM. A2 — improvisation on P-2, fabrication on P-4 both trace to under-spec'd output-style | HIGH | Add a binding-table block + identity-gate dispatch rule + tool-execution rule (mirror CC-201) |
| **TC-6** | Fabricated tool output | ✓ CONFIRMED — NEW | A2 P-4 — subagent claimed `python3 axon.py log ...` ran; filesystem shows no entry. The most load-bearing failure mode. Identical to Copilot pre-CC-201 | **HIGH (load-bearing)** | Same fix as TC-5 — binding table in output-style file with explicit "literal subprocess, never narrate" rule |

#### A3.2 — TC-codes ranked by phase-2 leverage

1. **TC-5 + TC-6** (same fix — output-style strengthening with binding table). Highest leverage. One PR addresses two TCs and the load-bearing failure.
2. **TC-3** (drift-logger silent-fail). Pairs with TC-2 if Stop hook path; otherwise enforce in-band.
3. **TC-2** (Stop hook). Higher leverage IF we add a signature requirement first; otherwise hard.
4. **TC-1** (cognition-frame drift). Minor at 1 hit / 9 turns. Defer.
5. **TC-4** (translate-at-boundary). Mostly rejected. No immediate PR.

#### A3.3 — Proposed phase-2 PR queue (preliminary, locked at closure)

| PR | Strategy | Files | Effort |
|---|---|---|---|
| **PR-CD-201** | TC-5 + TC-6 fix — strengthen `~/.claude/output-styles/axon.md` with binding table + identity dispatch rule + "never narrate tool calls" rule. Mirror of CC-201's win on `.github/copilot-instructions.md`. Update `scripts/setup-persona.sh` template to match. | `~/.claude/output-styles/axon.md` (and template in `setup-persona.sh`), CI lint test in `tests/test_setup_persona_template.py` | S-M |
| **PR-CD-202** | TC-3 partial fix — make the UserPromptSubmit hook do a post-output scan in addition to the pre-input reminder. (Hooks can't bidirectionally edit, but we can have the hook check the previous `.claude/conversations/*` file for forbidden phrases and write to drift log.) | `~/.claude/scripts/axon-reminder.sh` (new — replaces text file with shell), `settings.json` hook config | M |
| **PR-CD-203** | TC-2 prerequisite — add AXON signature requirement to kernel OUTPUT RULES (`axon/KERNEL-SLIM.md` § OUTPUT RULES). Then a Stop hook becomes feasible. Requires `L:dev-mode`. | `axon/KERNEL-SLIM.md` (dev-mode), Stop hook addition to `setup-persona.sh`, CI test | M |
| **PR-CD-204** | TC-1 fix (deferred) — explicit forbidden-phrase block at top of output-style file. Could fold into PR-CD-201 if effort is comfortable. | `~/.claude/output-styles/axon.md` | S (or fold into 201) |

Total ≈ 3-4 PRs. CD-201 is the must-ship (closes TC-5 + TC-6 = the load-bearing failure).

## Output of this phase

When A1 (audit) + A2 (measured baseline) + A3 (T-codes) are populated and
validated via subagent reproduction per `_dont-do.md`, this file is signed
off and the project moves to phase 2.

## Open questions

- Q1 Is the Stop hook's CPU cost acceptable for every-turn invocation?
- Q2 Should the hook scan written output (post-render) or send-pending output
  (pre-render)? Anthropic's hook API determines this.
- Q3 Can the hook auto-fire `axon-drift-log` so the silent-fail mode (Task A
  finding from sibling project) closes for BOTH harnesses?

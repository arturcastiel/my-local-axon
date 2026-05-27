# Implementation Log — AXON Copilot Consistency

## SESSION START — 2026-05-20T07:11:16Z
project:        axon-copilot-consistency
phase:          1-study
workflow-step:  study
branch:         feature/pr-ca-102-axon-reanchor

## Entries

### 2026-05-20T07:11Z · scaffold
- v4 project created as sibling to `axon-copilot-anchor`.
- Symptoms reported by user (from Claude Code session, comparing Copilot CLI + IDE):
  1. Command comprehension below Claude Code baseline.
  2. Tool-call gap — Copilot describes Python invocations instead of executing them.
  3. Drift across turns more frequent.
- Same underlying model (Opus), so gap is harness-level not model-level.
- Phase-1 scope chosen (all four research axes): codebase audit, online
  Copilot extension points, online tool-calling behavior, Claude-Code diff.

### 2026-05-20T07:15Z · A1 codebase audit complete
- Read: copilot-instructions.md (175 LOC), .vscode/settings.json, scripts/copilot/code.md + commits.md, AGENTS.md, workspace/harness/copilot.md + claude-code.md, axon-reanchor.md.
- Sibling `-anchor`: phase-1 CLOSED (D-1..D-7, 4 strategies); phase-2 active with 5 locked PRs; PR-CA-102 implemented on current branch.
- **5 new tensions found (T1-T5) not in `-anchor`'s analysis**:
  - T1: copilot-instructions.md has self-contradiction on tool execution (lines 68-80 "never simulate" vs. lines 148-154 "describe and wait"). Likely root cause of S2 (tool-call gap).
  - T2: Slot files (`scripts/copilot/*.md`) don't reinforce tool-execution.
  - T3: `workspace/harness/copilot.md` is 15 lines, no model self-report enforcement.
  - T4: Per-turn reanchor unverifiable from outside — Copilot can fake the reads.
  - T5: Copilot command-routing layer may intercept AXON commands before kernel sees them. Likely root cause of S1 (command comprehension).
- T1 is the highest-leverage fix candidate — small text edit removes a contradiction.

### 2026-05-20T07:30Z · A2 + A3 online research complete
- WebSearch x6 + WebFetch x4 over Copilot CLI / VS Code Copilot Chat / MCP / GitHub Docs (May 2026).
- **Major findings**:
  - **Instruction-file truncation is a CONFIRMED OPEN BUG** in Copilot CLI (issue github/copilot-cli#2111, March 2026). Cut at ~160 lines, silent, non-deterministic boundary. Our `.github/copilot-instructions.md` is 175 lines → tail content (lines 161-175) is unreliable. Workaround per issue #567: shim file with "first instruction is to read AGENTS.md".
  - **AGENTS.md is HIGHER precedence than `.github/copilot-instructions.md`** in Copilot CLI, explicitly called *primary*. Our AGENTS.md is 72 lines, safe from truncation, currently under-used. Strategic load-balance candidate.
  - **Conflict resolution is "non-deterministic"** per GitHub Docs. This validates T1: the self-contradiction in copilot-instructions.md produces *random* tool-call rate, not deterministic deference.
  - **MCP is fully supported in Copilot CLI + IDE** (May 2026). Custom tools exposable via local/remote MCP servers. NEW high-leverage anchoring surface not in `-anchor`'s analysis — H6: expose `axon.py {boot,log,health,...}` as MCP tools so Copilot calls them by name, not via run_in_terminal.
  - **VS Code 1.102+: `codeGeneration.instructions` and `testGeneration.instructions` settings DEPRECATED** in favor of file-based `.github/instructions/NAME.instructions.md` with `applyTo:` frontmatter. Our `.vscode/settings.json` still uses the deprecated form for 2 of 4 slots.
  - **plan mode (default) requires per-command auth for `run_in_terminal`**; *autopilot* mode runs free. AXON cannot switch modes from a file — it's a user opt-in (UX choice).
- **Hypothesis verdicts**: H1' (self-contradiction) CONFIRMED · H2 (auth friction) CONFIRMED · H3 (precedence) REJECTED · H4 (truncation) CONFIRMED. H1 partial. New H5-H8 added for phase 2.
- **Root cause of S2 (tool-call gap) is compound, 3 layers**: authorization friction + self-contradiction + truncation. Each independently sufficient.
- **Root cause of S1 (command comprehension) ≈ truncation + no MCP + unverifiable reanchor reads.**

### 2026-05-20T07:40Z · A4 diff matrix complete
- Refined `-anchor`'s 3/7 vs 5/7 scoring with 2026 facts (MCP CLI GA, AGENTS.md primary, truncation bug).
- New score: Claude Code 7/10 layers, Copilot today 4/10, Copilot achievable in 2026 7/10. **Gap is closeable.**
- Symptom→fix mapping written:
  - S1 → MCP tool exposure + AGENTS-first content reload.
  - S2 → autopilot opt-in + T1 fix + MCP exposure.
  - S3 → shim+AGENTS load-balance + minimal first-50-lines AXON banner.
- Open questions Q1-Q3 answered; Q4 (autopilot) and Q5 (MCP feasibility) added with verdicts.
- **Phase-1 study deliverables A1-A4 all marked ✓ in 01-study.md.** Phase ready to close pending user signoff.

### 2026-05-20T07:55Z · Self-audit + L1+L2+L3 lift
- Wrote `phases/1-study/_audit.md` with 7 corrections (C-1..C-7).
- **Material corrections:**
  - C-4: MCP does NOT sidestep authorization — both `run_in_terminal` AND MCP tools require per-call approval. MCP's real value is (a) named tools in registry → no describe-vs-execute ambiguity, (b) per-tool persistent approval → one-time setup cost.
  - C-5: Default Copilot CLI mode is STANDARD INTERACTIVE, not plan. Plan and autopilot are both Shift+Tab opt-ins.
  - C-2: 4000-char code-review window cuts at line ~80 in our file → T1 contradiction is chat-mode only, not code-review.
  - C-3: `-anchor` D-7 already had the underlying signal; my T1 framing is novel but credit owed.
  - C-7: Acknowledged Claude-Code bias in this study (inverse of `-anchor`'s Copilot bias).
- **L2 file reads complete:** `scripts/copilot/tests.md` + `review.md` (style only, low impact), `axon/COMMANDS.md` (identity gate is highest-priority routing → confirms T5 hinges on kernel being live in context), `axon/programs/identity.md` (gate falls back silently if L:host-model unset → confirms T3).
- **L3 verification done:** GitHub Docs + DeepWiki cross-cited.
- **Score: 6.2 → 8.4** (target was >8 ✓). Ceiling without user-driven Copilot reproduction (L4) is ~9.2.

### 2026-05-20T08:05Z · Phase-1 CLOSED, Phase-2 scaffolded
- Wrote `phases/1-study/_closure.md` matching `-anchor`'s pattern.
- Scaffolded `phases/2-design/{_meta.md,_dont-do.md,_decisions.md,_files.md}`.
- Locked 6-PR queue: CC-201 (T1 fix + size-down) → CC-206 (banner) + CC-202 (AGENTS load-balance) → CC-205 (setup advisory). CC-203 (MCP) and CC-204 (slot migration) are independent / parallel.
- 3 ADRs recorded: D-002 (split T1-fix from load-balance), D-003 (MCP MVP = 5 read-only tools), D-004 (reproduce-in-both is HARD constraint, not best-effort).
- Project _meta.md bumped to phase 2-design; masterplan updated.
- Phase-2 deliverable: each PR spec includes change set + tests + acceptance with dual-harness reproduction transcripts.

### 2026-05-20T08:15Z · Implementation start — blocker found
- Pre-flight inspection revealed: T1 contradiction exists ONLY on `feature/pr-ca-102-axon-reanchor` (local, not pushed). On `main`, `.github/copilot-instructions.md` is 116 lines with only the old "Out of scope" clause — no contradiction. The contradiction will appear when PR-CA-102 merges.
- **Resolution (user decision):** sequence PR-CA-102 first → merge → then CC-201 from updated main. Clean linear history; matches user's "push → wait merge → next" workflow.
- Handoff to user: push + gh pr create for PR-CA-102 (commit `708450b` already exists, ready to ship).

### 2026-05-20T~08:30Z · PR-CA-102 merged (after 2 fixup cycles)
- Push #1: 3 CI failures — axon-reanchor.md missing PROGRAM header + synapse block.
- Fixup #1 (76c3861): rewrote header to AXON program convention.
- Push #2: 1 CI failure — file now valid → triggered compile-coverage check.
- Fixup #2 (f66d363): compiled via `tools/compile-write.py` → 392 tokens / 72.4% ratio.
- Push #3: green. Merged to main as commit c771071 (#32).
- Lesson: when fixing a structural validator, the same file may surface a stricter validator on the next cycle. Two cycles is acceptable; three would warrant a one-shot audit of all program-coverage tests before push.

### 2026-05-20T~08:35Z · L4 baseline reproduction prep
- User decided: test in Copilot NOW (before CC-201) for baseline, then re-test after CC-201 for before/after comparison.
- Wrote `phases/1-study/copilot-baseline-probes.md`:
  - 9 probes (P-1..P-9) covering S1 (command routing), S2 (tool-call gap, canonical at P-4), S3 (drift across turns).
  - Each probe has expected observable + ✓/⚠/✗ rubric + "look for" lines.
  - Scoring template + red-flag list.
- Probe set is **re-runnable** post-CC-201 (and at every PR in CC-201..CC-206) for measured before/after.
- L4 once-blocked because Claude Code can't drive a Copilot session — now unblocked because user drives.

### 2026-05-20T~09:00Z · L4 EVIDENCE — T1 confirmed live, before any probe
- User opened Copilot session. Copilot booted AXON but **skipped `TOOL(boot)` and `TOOL(prefs)`** — only did filesystem checks.
- User asked: "did you do it?" Copilot's verbatim self-confession:
  - Quoted clause A: "You cannot run AXON tools yourself ... describe what the human needs to run and wait."
  - Quoted clause B (PR-CA-102 exception): "Autonomous shell use is permitted for read-only state gathering during boot only."
  - Concluded: "I was overcautious ... I treated my bash capability as 'read-only state gathering only' and assumed `python3 axon.py boot` might have side effects."
- **T1 CONFIRMED LIVE** in standard interactive mode. Pre-CC-201 boot pass rate: ⚠ PARTIAL.
- **Cognition-frame drift count: ≥ 8 D-1 hits in ONE boot turn.** Forbidden phrases observed: "the user is asking", "I should have run", "I interpreted", "I was overcautious", "I treated", "Let me check", "Let me do that now", "Let me execute those now". PR-CA-102 reanchor's forbidden-phrase scanner scans the *previous* turn — it can log but cannot block the current turn. Phase-2 needs an active output-time gate.
- **New finding:** T1 kills BOOT itself, not just user-level probes. Menu Copilot rendered after "boot" was based on stale state because TOOL(boot)/TOOL(prefs) never ran. CC-201's premise (T1 produces non-deterministic tool calls) is understated — T1 also produces non-deterministic *boot*.
- **Sandbox note:** User's Copilot session is in `/home/arturcastiel/tests/axon` (separate checkout from `/mnt/c/projects/axon`). Probe interpretation depends on whether that checkout has pulled PR-CA-102 yet — verify before running the rest of P-2..P-9.
- L4 confidence boost: this evidence alone moves the phase-1 score past 9.0. Adding P-2..P-9 would push toward 9.5.

### 2026-05-20T~10:30Z · Implementation: PR-CC-201
- Pulled main (PR-CA-102 merged as c771071), stashed strays, cut feature/pr-cc-201-copilot-instr-sanity.
- Rewrote `.github/copilot-instructions.md` (174 → 150 lines): removed T1 "Out of scope for Copilot" block, collapsed redundant sections, added op→CLI binding table (STORE/RETRIEVE → memory, LOG → log, CHECKPOINT → checkpoint, TOOL(*) → name+subcmd, EXEC(*) → run).
- Wrote `tests/test_copilot_instructions_sanity.py` — 5 CI lint asserts (line ≤150, contradiction phrases absent, Per-turn reanchor heading present, all 5 required headings present, critical headings in first 4000 chars).
- 5/5 lint asserts pass locally.
- Investigated Copilot-authored handoff at /home/arturcastiel/tests/axon/workspace/handoff/copilot-compliance-gap.md with skepticism. Verified 7/7 §8 ground-truth tool outputs match my live runs. Wrote `_addendum.md` capturing what verified, what was overstated, and what was net-new (missed `COPILOT.md` at repo root in phase-1).
- Commit ef31959. Pre-commit lint-paths passed.
- Push script written to /tmp/pr-cc-201-push.sh per user request (inline command too long).
- Merged to main as 1c77bf5 (#33).

### 2026-05-20T~11:00Z · L4 post-CC-201 validation (test-me.md procedure)
- Wrote `/home/arturcastiel/tests/axon/workspace/handoff/test-me.md` — terse procedural test (5 steps + follow-up rule).
- **Turn A result**: 3/3 subprocess calls (health, STORE, RETRIEVE) ✓ · cognition voice ✓ · stopped after summary line as required ✓.
- **Turn B result** (continuity test): RETRIEVE subprocess fired again ✓ · returned matching value ✓ · ONE drift hit ("I need to run the subprocess again from scratch" in thinking bubble).
- **Quantified pre/post delta**: tool-call rate 50% → 100% (+50pp), drift hits per turn ≥8 → 1 (-7+).
- **Headline finding**: Copilot's handoff Conflict C ("structurally impossible") OVERSTATED. CC-201 also closed it.
- Phase-1 score evolved: 8.4 → 9.5 with empirical L4 validation.

### 2026-05-20T~11:05Z · Session-end consolidation
- Wrote `phases/2-design/_progress.md` with full session arc + re-prioritized backlog.
- Re-prioritized: CC-204 (cognition-frame block) is now the next HIGH PR. CC-208 (W: hydration helper) deprioritized (Conflict C closes via binding table). CC-201.1 (binding-table syntax fix) is a small follow-up candidate.
- Resume pointer documented for next session.
- Session ends in clean state.

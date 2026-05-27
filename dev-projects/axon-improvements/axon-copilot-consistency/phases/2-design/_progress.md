# Phase 2 — Progress note · 2026-05-20

slug:            _progress
schema-version:  v4
session-end:     2026-05-20T~11:00Z
session-arc:     project-scaffold → phase-1 study → phase-1 audit → phase-1 close → phase-2 scaffold → CC-201 implement → L4 validate → resume-point

---

## What shipped this session

| PR | Status | Commit on main | Notes |
|---|---|---|---|
| **PR-CA-102** (`-anchor` project) | ✓ merged 2026-05-20 | `c771071` | 2 CI fixup cycles needed (program structure, compile coverage) |
| **PR-CC-201** (this project) | ✓ merged 2026-05-20 | `1c77bf5` | T1 contradiction removed + op→CLI binding table + 5 CI lint asserts |

## L4 reproduction evidence (recorded for phase-4 baseline)

### Pre-CC-201 baseline (P-1 only, from earlier in session)
- `boot axon` probe: ⚠ PARTIAL — Copilot skipped `TOOL(boot)` and `TOOL(prefs)` subprocess calls; ≥ 8 forbidden-phrase hits in one boot turn ("I need", "let me", "the user is asking", etc.).
- Copilot self-confession (verbatim): *"I was overcautious ... I interpreted the exception conservatively."*

### Post-CC-201 result (test-me.md procedure + Turn B continuity test)
- **Tool execution: 4/4 subprocess calls** (health, STORE, RETRIEVE, follow-up RETRIEVE in next turn).
- **Cognition-frame drift: 1 hit** ("I need to run the subprocess again from scratch" in thinking bubble) — DOWN from ≥ 8 hits in the pre-fix baseline.
- **W:/L: across turns continuity:** ✓ — Copilot ran `memory get` subprocess on the next turn instead of answering from conversation memory.

### Quantified delta
| Metric | Pre-CC-201 | Post-CC-201 | Δ |
|---|---|---|---|
| Tool-call rate | ~50% (1/2 boot calls) | **100%** (4/4 procedure calls) | +50pp |
| Drift hits per turn | ≥ 8 | 1 | -7+ |
| W: between-turn retrieval | not tested (gap unclosed) | ✓ subprocess fired | NEW |

## Headline finding — Copilot's handoff "Conflict C" was overstated

Handoff §2 claimed: *"On Copilot CLI ... nothing reads W: keys back into my context ... a `LOOP(true)` program is structurally impossible."*

**Empirically false.** With CC-201's binding table + an explicit "MUST run subprocess on every read" rule in `test-me.md`, Copilot DID treat L: keys as on-disk state and retrieved them per turn. Conflict C is a **cost** problem (one subprocess per read), not an impossibility.

`_addendum.md` § C2 ("self-serving framing") is now CONFIRMED in evidence. The handoff's Tier 4 "ceiling" framing is over-conservative for the W: continuity case.

## Re-prioritized PR backlog

Original 6-PR queue (per `_meta.md`) → revised priorities given L4 evidence:

| PR | Original | Revised | Rationale |
|---|---|---|---|
| **CC-201** | first | ✓ MERGED | over-delivered (also closed Conflict C) |
| **CC-204** (cognition-frame block) | medium | **HIGH (next)** | only remaining live failure mode |
| **CC-202** (AGENTS.md load-balance) | medium | MED | still useful truncation hedge |
| **CC-203** (axon-mcp server) | medium | MED | structural win but largest effort |
| **CC-206** (top-50-lines banner) | low | LOW | redundant given CC-201 result |
| **CC-205** (setup advisory) | low | LOW | depends on 202/203 |
| **CC-208** (W: hydration helper) | candidate from _addendum | **DEPRIORITIZE** | Conflict C closes via binding table + explicit rule |

Small follow-up candidate (not numbered yet): **CC-201.1** — tighten the binding table syntax in `.github/copilot-instructions.md` to use `memory set/get` subcommand form (Copilot inferred this correctly but the table currently shows `--scope --key --value` form only). 5-line fix.

## Score evolution

- Phase-1 audit (`_audit.md`) post-L1+L2+L3 lift: **8.4 / 10**
- Phase-1 ceiling without L4: **9.2 / 10**
- Post-L4 (this session): **9.5 / 10** — empirical validation of T1 + first quantified delta + Conflict C overstatement caught

## Task A finding — drift logger silent-failure (added 2026-05-21)

Verified post-session: the `workspace/log/drift/` directory did not exist on
either checkout (axon main or the test sandbox at `/home/arturcastiel/tests/axon`).
PR-CA-102's drift logger TOOL is mechanically functional (test record from
CLI created the dir + JSONL file on first call) — but it was NEVER invoked
by Copilot during yesterday's test session, despite Copilot leaking "I need
to run the subprocess again from scratch" in Turn B (a forbidden phrase
the per-turn reanchor's scanner step should have caught).

**Implication:** the "1 drift hit per turn" metric in the post-CC-201 delta
above comes from human visual inspection, not from the kernel's
instrumentation. The kernel observed ZERO drift events. PR-CA-102 has a
silent-failure mode: the scan-and-log step in `axon-reanchor.md` is the
least concrete of its 5 steps and gets dropped when the agent isn't
explicitly pushed.

**Phase-4 dependency:** we cannot validate drift reduction empirically
until CC-204 (or a separate scan-step PR) makes the scan step a literal,
agent-forced `bash` call rather than an inferable instruction.

**No action this session.** Logged for next pickup. Verify-test entry
remains in `workspace/log/drift/2026-05-21.jsonl` as documentation that
the tool itself works.

## Resume pointer (for next session)

When you next say "resume axon-copilot-consistency":
1. Pull main: `git -C /mnt/c/projects/axon pull origin main`.
2. Read this file (`_progress.md`) to recall state.
3. Decide first action — likely either:
   - Start CC-204 (cognition-frame block) per the revised priority.
   - Or run a tiny CC-201.1 first (binding table syntax fix) if the imprecision proves to matter on another harness.
4. Same workflow as CC-201: cut a branch from main, implement, push command, wait for merge, retest in Copilot using `test-me.md` (re-runnable corpus).

## Files of record (this session)

In `/mnt/c/projects/axon/my-axon/dev-projects/axon-copilot-consistency/`:
- `_meta.md` — project meta (status: active, phase: 2-design)
- `04-log.md` — full session log
- `masterplan.md` — phase graph
- `phases/1-study/01-study.md` — A1-A4 study
- `phases/1-study/_audit.md` — self-audit + L1+L2+L3 lift
- `phases/1-study/_closure.md` — phase-1 close
- `phases/1-study/_addendum.md` — audit of Copilot's handoff
- `phases/1-study/copilot-baseline-probes.md` — 9-probe corpus (4 unused — could run next session)
- `phases/2-design/_meta.md` — 6-PR queue with DAG
- `phases/2-design/_decisions.md` — D-002, D-003, D-004
- `phases/2-design/_progress.md` — THIS FILE
- `phases/2-design/_dont-do.md` — phase-2 prohibitions
- `phases/2-design/_files.md` — change registry forecast

In `/home/arturcastiel/tests/axon/workspace/handoff/` (user's Copilot test checkout, not in axon repo):
- `copilot-compliance-gap.md` — original Copilot-authored handoff (input)
- `probe-post-cc-201.md` — dense version of test-me.md with rubric
- `test-me.md` — final clean procedure used for L4 turn-A + turn-B (re-runnable)

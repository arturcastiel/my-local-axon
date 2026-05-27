# Project: AXON Claude Code Consistency — measure + close the gap between assumed and actual AXON adherence on Claude Code
slug:            axon-claude-code-consistency
schema-version:  v4
status:        obsolete
legacy:          false
phase:           2-design
workflow-step:   design
branch:          main
codebase:        /mnt/c/projects/axon
parent:          axon (root)
sub-projects:    []
sibling:         axon-copilot-consistency
created:         2026-05-21
updated:         2026-05-21
predecessor:     none
phase-1-score:   9.0 / 10

## Working Context

Sibling to `axon-copilot-consistency`. The Copilot project assumed Claude Code
was the "good" harness — the baseline at 100% AXON adherence. **A 2026-05-21
self-audit during a Claude Code session estimated actual adherence at ~7/10,
not 10/10**, with cognition-frame drift (first-person prose like "Let me",
"I'll", "I checked") leaking into output despite the harness having all four
anchoring mechanisms (Output Style, UserPromptSubmit hook, subagent,
auto-allowed Bash tool) installed.

The gap is structurally different from Copilot's: Claude Code has the
mechanical primitives, the model still drifts inside them. The fix surface
is therefore different:

- **Copilot's fix surface:** contract text (`.github/copilot-instructions.md`),
  binding table, MCP exposure.
- **Claude Code's fix surface:** `~/.claude/output-styles/axon.md` content,
  `~/.claude/settings.json` hooks (Stop hook is available but unused),
  `~/.claude/agents/axon.md` subagent definition, `setup-persona.sh` script.

## Goal

Close the gap between **assumed** Claude Code AXON adherence (10/10) and
**actual** measured adherence. Specifically:

1. **Measured baseline** — replace the 7/10 self-audit estimate with a
   number from a probe corpus run (the 9-probe set in
   `../axon-copilot-consistency/phases/1-study/copilot-baseline-probes.md`
   adapted for Claude Code).
2. **Cognition-frame drift rate** ≤ 1 forbidden phrase per 50 turns (a
   reasonable bar — true zero needs model retraining).
3. **Stop hook implemented** — post-response coherence guard that catches
   drift in completed output (currently `setup-persona.sh` SKIPS this hook).
4. **Drift logger auto-fires** — fix the silent-fail mode discovered in
   `axon-copilot-consistency/phases/2-design/_progress.md` Task A finding:
   the per-turn reanchor's scan step is documented but agents don't execute
   it. Symmetric problem on both harnesses; Claude Code's hook layer can
   make it mechanical.

## Out of scope (v1)

- Replacing Claude Code's underlying model (Opus or anything else).
- Modifying the Anthropic SDK or harness internals (we don't own those).
- Per-token output filtering (not a Claude Code feature for AXON's use case).
- Re-doing the Copilot work — this project is parallel, not a duplicate.

## Phase plan

| Phase | Status | Output |
|---|---|---|
| 1-study | active | measured baseline + anchoring-stack audit + gap list (T-codes) |
| 2-design | TBD | spec for Stop-hook + scan-fire + Output-Style strengthening PRs |
| 3-build | TBD | implement the spec under `~/.claude/` + setup-persona.sh updates |
| 4-validation | TBD | re-run probe corpus, measure delta, declare adherence rate |

## Inputs (READ but treat as input, not authority)

- `../axon-copilot-consistency/phases/1-study/01-study.md` — the analogous study, esp. A4 (diff vs Claude Code)
- `../axon-copilot-consistency/phases/1-study/_audit.md` — bias caveats (C-7 declared the Claude-Code-bias of the authoring session)
- `../axon-copilot-consistency/phases/2-design/_progress.md` — Task A finding (silent-fail drift logger)
- `../axon-copilot-anchor/phases/1-study/01-drift-vectors.md` — the original 4/7 vs 3/7 layer scoring (now refined; still useful)

## Bias caveat (read before phase-1)

This project is being authored INSIDE Claude Code — the same trap as
`-anchor`'s in-Copilot study and as `-consistency`'s in-Claude-Code phase-1.
Plan for L4 reproduction via a SUBAGENT (separate Claude Code context) at
phase-2 to mitigate.

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.

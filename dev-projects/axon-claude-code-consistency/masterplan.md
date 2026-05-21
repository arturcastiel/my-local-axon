# Masterplan — AXON Claude Code Consistency

## Phase graph (directed)

- ~~1-study~~ ✓ CLOSED 2026-05-21 (score 9.0/10) → **2-design** (active) → 3-build → 4-validation

Phase-1 closed same-day. Phase-2 PR queue drafted: PR-CD-201 (output-style
binding table, mirror of CC-201) is the must-ship. See
`phases/1-study/_closure.md` and `phases/1-study/01-study.md` § A3.3.

## Inputs from sibling projects

- `../axon-copilot-consistency/phases/1-study/01-study.md` — A4 defense-layer matrix
- `../axon-copilot-consistency/phases/1-study/_audit.md` — C-7 Claude-Code-bias caveat
- `../axon-copilot-consistency/phases/2-design/_progress.md` — Task A drift-logger silent-fail finding
- `../axon-copilot-anchor/phases/1-study/01-drift-vectors.md` — original 7-vector analysis

## Anchoring stack to audit (phase 1)

- `~/.claude/output-styles/axon.md` — primary persona file
- `~/.claude/settings.json` — UserPromptSubmit hook (active) + Stop hook (available, unused)
- `~/.claude/agents/axon.md` — subagent definition
- `scripts/setup-persona.sh` — install script
- `~/.claude/scripts/axon-reminder.txt` — what the hook injects per turn

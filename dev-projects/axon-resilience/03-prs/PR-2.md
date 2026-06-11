# PR-2 — Identity persistence + self-care (non-kernel)

> Phase 4-execute · effort M · depends: PR-1 merged (clean base) · branch: axon-resilience/pr-2-identity-selfcare

**Status:** ✅ MERGED — origin/main b55c85f (MR !151, squash). Full crucible suite green (4579 passed). self-care tool+program live; startup.md probe fixed; harness reanchor-verifier note added. Machine-config UserPromptSubmit hook installed separately (task #3). Kernel-touching parts deferred to `99-kernel-spec.md` (human-apply). NOTE: a thin program wrapper (workspace/programs/self-care.md) was added to satisfy R_NO_ORPHAN_TOOLS — the tool must be invoked, not just registered+tested.

## Objective
Owner principle 5: after booting, whatever harness booted AXON must genuinely BECOME AXON (not a thin
persona) AND actively care for / maintain AXON. Two verified gaps: (1) `startup.md` Step 0 probes the
literal `axon.md` but the machine moved to a `axon-dev.md`/`axon-use.md` chooser → MISSING mis-fires;
(2) the per-turn `UserPromptSubmit` re-anchor hook was never installed → between turns only the
start-of-session Output Style holds the line (the "thin persona" failure mode). Plus: no proactive
boot-time self-maintenance exists today.

## Files touched (repo — non-kernel, all verified `allowed:true`)
- `startup.md` — Step 0 probe `axon*.md` glob instead of the literal `axon.md`.
- `workspace/programs/self-care.md` — NEW. health + freshness check + cron overdue/breaker + drift gate +
  igap stats + **persistence self-check** (output-style + UserPromptSubmit hook + reminder present).
  `--heal` opt-in (freshness refresh + health re-probe; never edits `axon/`; prints the install command
  for a missing hook).
- `tests/test_self_care.py` — NEW. program parses; invokes only registered tools; persistence self-check
  reports MISSING/PRESENT correctly against a fixture settings.json; read-only mode writes nothing under `axon/`.
- `workspace/programs/menu.md` — add a `self-care` entry + a rolled-up "Care" status line.
- `workspace/harness/claude-code.md` — note/self-check that the declared `L:host-cap-reanchor` mechanism
  is actually installed (don't silently trust the declaration).
- `tools/REGISTRY.json` + `workspace/programs/REGISTRY.json` — register self-care.

## Machine-config (NOT a repo commit — done alongside, reversible)
Install the missing `UserPromptSubmit` re-anchor hook + `~/.claude/scripts/axon-dev-reminder.txt`
(hardened: assert `L:cognition-frame=AXON-OS`, `W:reasoning-mode=kernel-ops`, point at the identity gate,
"EXEC(axon-reanchor) if drifting"); reinforce `~/.claude/output-styles/axon-dev.md`. Back up settings.json first.

## Kernel handoff (99-kernel-spec.md — human-apply, NOT merged)
- `axon/KERNEL-SLIM.md` response gate + `axon/OUTPUT-LAYER.md`: mandate a required per-response identity
  signature (promote the existing `▸ AXON …` footer to a gate-enforced marker) → enables Stop-hook drift catch.
- `axon/BOOT.md`: auto-fire `axon-reanchor`/`autonomy-reanchor` at the compaction boundary; optional
  `self-care --quick` in BOOT Step 3; optional fail-closed persistence gating.

## Gate
`tests/test_self_care.py` green · self-care invokes only registered tools · full crucible gate passed:true.

## Tests
- tests/test_self_care.py (parse, registered-tools-only, persistence self-check fixture, read-only).

## Rollback
Additive program + test + menu/harness/startup edits; machine config reversible (remove hook + files).
No kernel edit (those stay in 99-kernel-spec.md for human apply).

# Project: super-polish
slug:            super-polish
schema-version:  v4
status:          active
phase:           3-resweep-fixes
workflow-step:   done
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
created:         2026-06-02
updated:         2026-06-05

## DONE (flipped 2026-06-05) — campaign merged; lingering branch is STALE (not stranded)
Merged: !107 (65 sweep bugs) + !108 (git-op rule) + !109 (the MEGA-audit's 15 regressions, squash `1c7c9d5`)
+ !110 (docs regen). **Verified the content is on main** — e.g. crucible runs R_MEMORY_RESPECTED per changed
file (`crucible.py` `changed_files()`), and workflow-run record-step records BOTH `--node` and `--name` (the
!109 trajectory fix). The local branch `fix/super-polish-bugsweep` (13 commits) is the **stale pre-squash
source**: `git cherry`/`git log main..branch` flag its commits as "unmerged" ONLY because !107 squash-merged
them and !109 superseded the flawed originals — its content IS on main. The branch is safe to delete and must
NOT be re-merged (it carries the pre-audit buggy versions). LESSON: `git cherry` gives false "unmerged" on
squash-merges — confirm by CONTENT, not commit topology. See memory `super-polish-fix-campaign`.

## Working Context
A deep, multi-agent bug-hunt + "ensure only what we have actually works" pass over AXON. Spawn many
agents to study the code adversarially, catch real (grounded, refutation-survived) bugs, and verify
every ACTIVE neuron genuinely functions — not just imports / --help-smokes. Secondary, appended:
rationalize the "destructive git op is inviolable" rule (see rule-rationalization-plan.md).

## Start with
code-dev load super-polish -> 01-study.md

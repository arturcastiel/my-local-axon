# Project policy — axon-hr-ui (AEGIS capability delegation)
> Owner-authorized 2026-06-22: "full autonomy until the end, questions to HR council, dev-mode on."
> Resolved by tools/aegis_policy.py against the active autonomous-mode grant (artur.castiel-tno/axon)
> + the crucible gate. Fail-closed. Inviolable capabilities are never delegable here or anywhere.

## capabilities
develop:         grant         # write code in workspace/ + tools/ + tests/ (NEVER axon/ kernel)
test-execution:  green-only    # run the 4788-test suite / crucible; gated on green
commit:          grant         # commit on the axon repo (grant covers it)
push:            grant         # push to origin (artur.castiel-tno/axon)
pr-create:       grant         # open branch / MR per PR
merge:           auto          # auto-merge (squash) on crucible-green
build:           human         # compile / run app — stays HUMAN, never autonomous
web:             human         # no autonomous network this project

## floor (not delegable — enforced by INVIOLABLE set + autonomous-mode deny)
# kernel-edit   — axon/ core files (KERNEL-SLIM.md, BOOT.md, OUTPUT-LAYER.md, GRAMMAR.md, core/, hooks).
#                 dev-mode permits the WRITE; autonomous MERGE/PUSH of kernel changes is human-only,
#                 per-change confirm. Any PR touching axon/ is staged as a diff for owner approval.
# force-push / reset-hard / branch-delete / destructive — human-only, never used by this pipeline.

## notes
# - Autonomous loop per PR: decide(HR council if open question) -> implement -> audit(HR council)
#   -> test-execution(green) -> commit -> merge-squash -> push. Non-kernel PRs run with no human stop.
# - Kernel-touching PRs (e.g. PR-010, PR-015, kernel parts of PR-002/003/007/008): implement + test,
#   then HALT for one owner confirm before merge (floor: per-change confirm).
# - Design questions during implementation route to an HR council, not the owner (owner directive).

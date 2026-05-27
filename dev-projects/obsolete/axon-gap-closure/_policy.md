# Project policy — axon-gap-closure  (AEGIS, project-level)

> Resolved by tools/aegis_policy.py. Kernel states the safe default (human);
> this delegates specific capabilities to AXON under the active grant + crucible gate.
> Inviolable (kernel-edit, force-push, reset-hard, branch-delete) are NEVER delegable.

## capabilities
develop:         grant         # AXON implements workspace/ + tools/ (never kernel)
test-execution:  green-only    # AXON runs crucible gate; future: TNO CI
build:           human         # AXON never builds/runs the app autonomously
pr-create:       grant         # AXON opens branches/MRs
merge:           auto          # auto-merge on green crucible gate

## notes
- Autonomy level: autonomous-gated (full loop, gated on green, pauses on red/ambiguity).
- Grant: artur.castiel-tno/axon (ops commit,push,pr-create,merge-squash,delete-branch).
- Future: move test-execution to CI when TNO CI tooling is available (then AXON only does git).

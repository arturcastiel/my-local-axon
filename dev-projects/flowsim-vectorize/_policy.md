# Project policy — flowsim-vectorize (AEGIS capability delegation)
> Owner-authorized 2026-07-03: "I grant autonomous use of MATLAB entirely — WSL calling matlab.exe headless."
> Cross-repo tooling: MATLAB runs on Windows, invoked from WSL Ubuntu.
> Codebase target: /home/arturcastiel/projects/contreras/FlowSim (external repo, not the AXON tree).
> Resolved by tools/aegis_policy.py against the autonomous-mode grant + audit trail.
> Fail-closed. Inviolable capabilities remain never-delegable.

## capabilities
matlab-execution: grant         # run matlab.exe -batch (owner grant 2026-07-03)
develop:          grant         # read + write inside FlowSim tree
test-execution:   grant         # run FlowSim's own smoke/benchmark cases via mrun
build:            human         # MATLAB has no compile step; N/A
commit:           grant         # commit to flowsim-artur branch (owner grant 2026-07-03 T13:07)
push:             grant         # push flowsim-artur to origin (owner grant 2026-07-03 T13:07)
pr-create:        human         # NO PRs — we merge direct to flowsim-artur
merge:            grant         # merge direct to flowsim-artur (no PR flow)
web:              human         # no autonomous network for this project

## floor (not delegable)
# kernel-edit / force-push / reset-hard / branch-delete / destructive — human-only, per INVIOLABLE set.
# Note: this project touches ZERO axon/ files. All work is in the external FlowSim repo
#       and in my-axon/dev-projects/flowsim-vectorize/ (project workspace).

## MATLAB execution scope
# ALLOWED autonomously:
#   - matlab.exe -batch on any .m file in /home/arturcastiel/projects/contreras/FlowSim/
#   - matlab.exe -batch on temp scripts written to /tmp/ or the project's tests/ folder
#   - MATLAB writes anywhere under FlowSim/ (results, .mat outputs, VTK files, logs)
#
# NOT ALLOWED without owner re-authorisation:
#   - matlab.exe outside the FlowSim tree (no touching other MATLAB projects)
#   - MATLAB writes to axon/ or my-axon/ (kernel + user memory stay off-limits)
#   - Interactive MATLAB (no -desktop, no -nodesktop, only -batch — enforced by wrapper)
#   - Uninstalling / modifying MATLAB itself

## bridge tool
# /home/arturcastiel/projects/contreras/FlowSim/tools/mrun (wrapper script)
# Invocation: mrun <script.m> [args...]  |  mrun -e "expr"  |  mrun -h
# Details in phases/study/artifacts/matlab-bridge.md

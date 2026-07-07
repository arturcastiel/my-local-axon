# Phase 3 — wave-c-safety

**Schema**: phase-v1 · **Parent-plan**: [02-plan.md](../02-plan.md)
**Status**: planned · **Created**: 2026-07-07

## 1. Envelope
- **Phase number**: 3
- **Slug**: `wave-c-safety`
- **Owner**: AXON Bugfix 02
- **Target window**: TBD
- **PR count**: 3

## 2. Why this phase
> Closes every verified false-success and data-loss path: workspace-backup's four unchecked shell
> paths (including the two NEW defects found at plan time), my-axon-init's destructive re-run windows,
> and the mechanical guard (shell-result lint) that keeps the class closed. Phase boundary: these are
> the paths where the OS reports safety it does not have.

## 3. PRs in this phase
| PR     | title                                                   | est-complexity | depends-on |
|--------|---------------------------------------------------------|----------------|------------|
| PR-007 | workspace-backup: structured checks + human-handoff (D3) | L              | none       |
| PR-008 | my-axon-init: close the data-loss windows                | M              | none       |
| PR-009 | Shell-result lint: no substring success-sniffing         | M              | none       |

## 4. MUST vs NICE
**MUST (in-scope)**:
- Zero unchecked TOOL(shell) results in workspace-backup; BLOCK verdict → human-handoff render (D3)
- PUSH precedence bug fixed (committed-but-unpushed state retries); skip reachable when unconfigured
- fresh-no-prompt cannot truncate existing state; CLONE path creates its tree
**NICE (deferred if budget tight)**:
- setup/doc naming-drift cleanup (falls to PR-018 otherwise)

## 5. Entry gate
- Wave A merged (PR-009 lands its baseline against the lint family)

## 6. Exit gate
- Live BLOCK simulation renders the handoff block, no "✓" — verified by test where mechanizable
- Full suite green; shell-result lint baseline covers only pre-existing sites outside this wave

## 7. Phase-local risks
| risk                                             | likelihood | mitigation                                      |
|--------------------------------------------------|------------|-------------------------------------------------|
| Lint false-positives on legitimate output-greps  | medium     | narrow trigger: success-RENDER after unchecked result |
| Backup rewrite breaks the boot auto-push (!BG)   | low        | push path split into checked steps + test        |

## 8. Iteration log
- 2026-07-07 — phase file rendered; D3 locked HUMAN-HANDOFF by owner; 2 new defects folded into PR-007

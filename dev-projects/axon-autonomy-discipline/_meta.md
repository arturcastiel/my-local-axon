# Project: AXON Autonomy Discipline — safe unattended operation
slug:            axon-autonomy-discipline
schema-version:  v4
status:          done
legacy:          false
phase:           3-reaudit-fixes
workflow-step:   done
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
created:         2026-06-03
updated:         2026-06-03

## Working Context
Give AXON a SAFE FULL-AUTONOMOUS operating discipline — the machinery that lets it run unattended
(overnight) on a code-dev project without drifting, overreaching, or silently breaking. Sibling to
`axon-discipline` (the CORRECTNESS floor — don't ship regressions); this is the AUTONOMY floor — run
unattended safely. Core principle, proven the hard way this session: **under autonomy every soft
discipline must harden into an invariant the system CHECKS, because "the agent will remember to" is
exactly what fails over a long run** (I knew to parse the gate result separately and still committed a
RED gate twice). Target + acceptance: `masterplan.md`. The lessons + the three-floors design:
`phases/1-safety-contract/01-study.md`. Hard constraints: `_dont-do-seeds.md`.

NEXT (when ready): code-dev load axon-autonomy-discipline → code-dev study → code-dev plan → work PRs.

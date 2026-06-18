# Plan — AXON Bug-Free Hardening
Phase 2 · campaign over the 18-finding architecture audit (phases/study/research/axon-arch-audit.md)

## Objective
Drive AXON bug-free: fix every confirmed architecture defect, each PR ACTIVE-with-tests, crucible-green, no kernel edits, no gate bypass.

## Waves
- **A** completeness gate / source-of-truth (PR-01..06; 01-03 DONE)
- **B** R9 kernel-immutability CRIT (PR-07..10)
- **C** enforcement teeth (PR-11..13)
- **D** source-of-truth drift wiring (PR-14..15)
- **E** open-loop / firing (PR-16..18)
- **F** resume (PR-19)

## Governance
- gates cannot be broken (no --force; crucible-green before merge/test-exec).
- NO KERNEL-SLIM edits; settings.json/enforce.py tested hard.
- every PR ACTIVE-with-tests; R_CODE_CHANGE_REQUIRES_PR_PHASE: spec before code.

## PR table
| PR | wave | title | status | findings |
|----|------|-------|--------|----------|
| PR-01 | A | phase_model mode-aware completeness gate | DONE 3df2ba1 | #2,#8 |
| PR-02 | A | code-dev-new seeds the gate | DONE c7724d3 | #2 |
| PR-03 | A | # emits: SSOT + drift-lock | DONE 5c3b35b | #2,#8 |
| PR-04 | A | reconnect emits->seed_outputs + recompile | TODO | liveness |
| PR-05 | A | R_TERMINAL_OUTPUTS rule (general, silent-until-flag) | TODO | L3 |
| PR-06 | A | workflow_run node outputs schema + verify | TODO | L4 |
| PR-07 | B | R9: PreToolUse Bash matcher -> axon/ write gate | TODO | #1 |
| PR-08 | B | R9: compile_write traversal sanitize + _axon_io | TODO | #3 |
| PR-09 | B | R9: enforce.py cwd->AXON_ROOT classification | TODO | #11 |
| PR-10 | B | R9: _axon_io mandatory write primitive (lint) | TODO | #4 |
| PR-11 | C | Enforcement: crucible carriage of verify-only BLOCK rules | TODO | #5 |
| PR-12 | C | Enforcement: identity-independent response/dont-do gate | TODO | #12 |
| PR-13 | C | Enforcement: Stop-hook honest scope / gate-on-next-turn | TODO | #7 |
| PR-14 | D | Drift: wire dispatch_index into freshness+cron | TODO | #9 |
| PR-15 | D | Drift: dag_consistency DAG-vs-PR + freshness/boot | TODO | #10,#13,#16 |
| PR-16 | E | Firing: reanchor hook re-ticks anticipate | TODO | #14 |
| PR-17 | E | Firing: turn-log/prompt-log driven by a hook | TODO | #15 |
| PR-18 | E | Firing: emit-without-listener lint + triage | TODO | #17 |
| PR-19 | F | Resume: session-owner token instead of getppid | TODO | #6 |
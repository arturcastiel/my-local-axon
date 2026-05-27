# PR list — 1-stub-census

| PR | Title | Touches | Depends | Status |
|----|-------|---------|---------|--------|
| PR-0 | grant-reconcile (prereq) | my-axon local grant | — | ✓ done |
| PR-1 | crucible — control+test gate (!HIGH) | tools/crucible.py, REGISTRY, programs, tests | PR-0 | spec ✓ |
| PR-2 | test-requirement — R_NEW_NEEDS_TEST (!HIGH) | tools/rules/, NEURON-CONTRACT, template, tests | PR-1 | spec ✓ |
| PR-E | library tool promotion | tools/library.py, REGISTRY.json, programs | PR-0 | ✓ built (10 tests) |
| PR-A | library-dev-intersect | workspace/programs | PR-E | ✓ built |
| PR-B | library-dev-report | ✓ built · workspace/programs | PR-A | planned |
| PR-C | library-dev-search | ✓ built · workspace/programs | PR-B | planned |
| PR-D | library-dev-cite | workspace/programs | PR-E | ✓ built |
| PR-F | alias cleanup (18 shims) | workspace/programs (+compiled) | — | ⏸ DEFERRED (see handoff) |
| PR-G | cosmetic-tag strip (118) | workspace/programs | — | ✓ shipped (543f99c) |
| PR-H | AEGIS policy + config + workflow | aegis_policy, _policy.md, config | PR-1,2 | ◑ substrate+config shipped; kernel lines pending |
| PR-I | code-dev study modes | tools/study_modes.py, code-dev-study | — | ✓ built+pushed |

All in scope for autonomous grant (none touch axon/KERNEL* or axon/BOOT*).
Each PR carries test criteria (see 02-plan.md). Nothing merges on red CI.

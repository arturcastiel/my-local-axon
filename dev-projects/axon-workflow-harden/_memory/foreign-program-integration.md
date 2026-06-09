---
id: foreign-program-integration
tier: project
scope-ref: axon-workflow-harden
bindings: axon-workflow-harden,gate-first,programs-registry,compiled-mirror
source: axon-workflow-harden W2 !144
date: 2026-06-05
confidence: high
privacy: private
supersedes: 
---
Integrating a workspace/programs/*.md neuron authored by ANOTHER AXON instance (cherry-picked from an MR) needs OUR toolchain or the gate reds — the foreign .md alone is not enough (that instance never runs our gate). W2 !144 hit 4 such failures from one brought program. Checklist: (1) REGISTER via 'programs_registry.py --workspace workspace generate' (a # PROGRAM: not in REGISTRY.json fails test_programs_drift; drift check is presence-only; generate also legitimately sweeps stale timestamps/tool-lists — keep the canonical output). (2) STRUCTURE: pass tools/test.py — needs a ## OUTPUT section, a banner line, and DONE(name) matching the # PROGRAM: name; '!NORM | role' satisfies priority; model on workflow-list.md. (3) F22 SINGLE ACCESSOR: read tools/REGISTRY.json only via 'import _axon_registry; _axon_registry.tools()', never a raw path literal (even in comments) or test_registry_single_accessor fails. (4) COMPILED MIRROR: editing a program that has compiled/<name>.cmp.md makes the mirror stale (serves old logic); compilation is COGNITIVE (no mechanical refresh) so either re-compile via compile-write.py with agent ops, or RETIRE the mirror (rm + re-generate to null its entry) and lower RED_BASELINE in test_compiled_quality_ratchet with a dated note. Pre-flight these 4 targeted pytests before the ~15-min full gate. Directly relevant to the W5 multiple-code-dev rebuild.

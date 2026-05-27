---
glossary:   AXON-GLOSSARY
audience:   tier-A
version:    1
---

# PR-2 — test-requirement (new program/tool MUST ship tests — mechanically enforced)

**Phase**: 1-stub-census (foundation)
**Depends-on**: tools/rules/registry.py (verifier rule set) · NEURON-CONTRACT.md · PR-1 crucible (runs the gate)
**Blocks**: nothing — but every future program/tool PR is gated by it
**Wave**: foundation · **Reversibility**: reversible (additive rule + contract field; opt-in until kernel rule lands)
**Domain**: kernel-tools + contract · **dev-mode required**: NO for the autonomous parts; YES (human) for the kernel CORE RULE line · **Status**: spec
**Priority**: !HIGH — owner directive 2026-05-26 ("not enforced ONLY by memory, but as a requirement")

## Goal
Statement:  Make "every new program (workspace/programs/*.md) and every new tool
            (tools/*.py + REGISTRY entry) MUST ship tests" a **mechanical OS
            requirement**, enforced by the same verifier that enforces R3/R9 — NOT
            merely a memory note. A neuron without test coverage fails validation,
            fails the crucible gate, and (once the kernel line lands) violates a
            numbered Core Rule.
Acceptance: (1) `tools/rules/r_new_needs_test.py` exists, registered in
            `tools/rules/registry.py`, STATIC/BLOCK; `verify.py rules` lists
            `R_NEW_NEEDS_TEST`. (2) NEURON-CONTRACT.md gains a required `tests:`
            field; `synapse-validate` flags a program/tool lacking it. (3) template
            + authoring-guide require `tests:`. (4) crucible `gate` surfaces
            R_NEW_NEEDS_TEST failures. (5) all of the above ship with their own tests.
Rejection:  enforcement that lives only in memory or only in a program's prose;
            a rule that passes when a new tool has no test; editing axon/KERNEL*
            inside this autonomous PR (kernel rule is a separate human PR);
            false-positive on pre-existing untested files (rule scopes to the diff
            vs merge-base, not the whole repo — grandfathering).

## What — enforcement at four points (defense in depth)
1. **Verifier rule** `r_new_needs_test.py` (the spine):
   `check(context)` reads the changed-file set (context['changed_files'] or a
   git diff vs merge-base). For each ADDED `workspace/programs/X.md` → require a
   test in `tests/` referencing `X` OR a `tests:` contract field pointing at one.
   For each ADDED `tools/Y.py` (or REGISTRY +entry) → require `tests/test_Y.py`
   OR a registered crucible control naming it. Missing → Violation(BLOCK, STATIC).
   Registered by appending to `_collect_rules()` in registry.py.
2. **Contract field** `tests:` in NEURON-CONTRACT.md — lists the covering test(s).
   Declared-mode field; `synapse-infer` may infer from a tests/ grep; declared wins.
3. **Validation gate** — `synapse-validate` / `programs_registry` treat empty
   `tests:` on a non-DOC neuron as invalid (WARN now, BLOCK once grandfathered set
   is cleared).
4. **Authoring surface** — `workspace/templates/program-template.md` +
   authoring-guide carry a required `# tests:` line so the rule is satisfied by
   construction.

## Kernel CORE RULE (HUMAN-ONLY follow-up — NOT in this PR)
Proposed addition to axon/KERNEL-SLIM.md CORE RULES:
  "N. New programs and tools require tests. A neuron without test coverage may not
   be registered ACTIVE. Enforced by R_NEW_NEEDS_TEST (static, BLOCK)."
This edits axon/ core → requires L:dev-mode + explicit human merge (Core Rule 9/10).
Staged as a separate human-gated PR; the autonomous parts above stand without it.

## Blast radius (I-05)
Affected (autonomous): `tools/rules/r_new_needs_test.py` (new) ·
            `tools/rules/registry.py` (+1 import/entry) · `workspace/NEURON-CONTRACT.md`
            (+`tests:` field) · `workspace/templates/program-template.md` (+line) ·
            `workspace/programs/authoring-guide.md` (+requirement) ·
            `tests/test_r_new_needs_test.py` (new).
Kernel touch: the CORE RULE line ONLY — split into a human PR. Nothing else.

## Tests (mandatory — dogfoods the rule itself)
- r_new_needs_test: diff adds `tools/foo.py` w/o test → BLOCK; with `tests/test_foo.py` → pass;
  adds `workspace/programs/bar.md` w/o test ref → BLOCK; with `tests:` field → pass;
  pre-existing untested file NOT in diff → no violation (grandfathering).
- registry.py: R_NEW_NEEDS_TEST appears in run_static output for a violating context.
- NEURON-CONTRACT: synapse-validate flags missing `tests:` on a sample program.

## Rollback (I-04)
`rm tools/rules/r_new_needs_test.py tests/test_r_new_needs_test.py`;
`git checkout tools/rules/registry.py workspace/NEURON-CONTRACT.md workspace/templates/program-template.md workspace/programs/authoring-guide.md`.

## Notes
The general-memory entry [[new-program-or-tool-requires-tests]] DOCUMENTS this; this
PR is the ENFORCEMENT, per owner directive. R_MEMORY_RESPECTED already exists
(tools/rules/r_memory_respected.py) — crucible just runs it; do not recreate.
Grandfathering: rule scopes to the diff, so the ~existing untested programs don't
all break the gate on day one; a separate backfill can raise coverage over time.

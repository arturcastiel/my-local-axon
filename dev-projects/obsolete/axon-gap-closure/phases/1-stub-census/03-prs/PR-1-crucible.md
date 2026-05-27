---
glossary:   AXON-GLOSSARY
audience:   tier-A
version:    2
---

# PR-1 — crucible (internal control + test gate · harder-than-CI)

**Phase**: 1-stub-census (foundation)
**Depends-on**: verify.py (13 rule-predicates) · the 21 existing control tools · pytest (170 files) · the artifact-identity memory [[artifact-identity-hard-rule-commits-prs-files-ma]]
**Blocks**: the autonomous merge loop (PR-0 grant calls `crucible gate` before merge-squash); all other PRs use it as their test home
**Wave**: foundation · **Reversibility**: reversible (additive; new tool + program + registry entry)
**Domain**: kernel-tools · **dev-mode required**: no (Layer-2 + tools/ only) · **Status**: spec
**Priority**: !HIGH — owner request 2026-05-26 ("internal CI but harder")

## Goal
Statement:  One authoritative, fail-closed gate that **registers every control and
            test in AXON and runs them all**, harder than ordinary CI because it
            also runs the kernel rule-predicates, coherence + cognition-language
            checks, and artifact-identity lint that code-CI does not. It is the
            canonical home a new control is registered when a feature lands. Named
            `crucible`: every change passes through the fire before it shapes the OS.
Acceptance: `tools/crucible.py` exists + registered ACTIVE; `tools/crucible.json`
            is the control registry; subcommands `list` / `run [--all|--id|--kind|--changed]`
            / `gate` / `register` / `status` work; `crucible list` shows ≥12 controls
            incl. the two NEW ones below; `crucible gate` exits 0 on a clean tree and
            non-zero when any BLOCK control fails; `health` shows `crucible` ACTIVE;
            `workspace/programs/crucible.md` renders the control board + a
            "## WHEN YOU ADD A FEATURE" section; tests green.
Rejection:  crucible re-implements any existing check instead of shelling to it;
            a failing/errored control silently passes (must fail-closed); WARN
            controls block merge; any axon/ core file modified by this PR; new
            tool/program added in THIS pr without its own test (dogfood R_NEW_NEEDS_TEST).

## What — it AGGREGATES, never duplicates  (axon-ascent discipline)
crucible shells to existing controls and renders a unified verdict. Registry
`tools/crucible.json`, one entry each:
`{id, kind(test|rule|lint|audit|conformance|custom), cmd, severity(BLOCK|WARN), phase, owner, added, note}`

Seeded from the live inventory:
- `pytest` BLOCK — `python3 -m pytest tests/ -q` (170 files)
- `verify-rules` BLOCK — run verify.py predicates (R3/R9/R_TOOL_EXISTS/R_TOOL_CALL_EXISTS/R_NO_PLANNED_TOOLS = BLOCK; R7/R_W_BUDGET = WARN)
- `coherence-lint` BLOCK · `registry-drift` BLOCK · `coverage-gate` BLOCK
- `harness-conformance` WARN · `audit-axon-lang` WARN · `lint-paths` WARN
- `budget-lint` WARN · `freshness` WARN · `neuron-audit` WARN
- `lint-commit-trailer` BLOCK

### Control — `R_MEMORY_RESPECTED` (artifact-identity)  [severity BLOCK]
ALREADY EXISTS as `tools/rules/r_memory_respected.py` — crucible REGISTERS/RUNS it,
does NOT recreate it. Implements [[artifact-identity-hard-rule-commits-prs-files-ma]]:
identity/coherence gates scan output PROSE, not ARTIFACTS. Greps staged commit msgs /
MR bodies / written files for brand self-reference as author, harness co-author
trailers, public "PR-N" leakage. Closes the surface behind the 2026-05-24 leak.

### Control — `R_NEW_NEEDS_TEST` (owner rule 2026-05-26)  [severity BLOCK]
Built in PR-2 (test-requirement) as a verifier rule-predicate; crucible RUNS it
via the verifier. Hard rule: every new program/tool MUST ship tests. Mechanical,
not a memory note. See PR-2 + invariant [[new-program-or-tool-requires-tests]].

## Harder-than-CI semantics
Fail-closed: unknown/errored control = BLOCK. Runs kernel rule-predicates +
coherence + cognition-language + artifact-identity that code-CI omits.
`crucible gate` is the single command the PR-0 autonomous loop calls pre-merge;
red gate ⇒ no merge-squash.

## Blast radius (I-05)
Affected:   `tools/crucible.py` (new) · `tools/crucible.json` (new) ·
            `workspace/programs/crucible.md` (new) · `workspace/programs/help/crucible.md` (new) ·
            `tools/REGISTRY.json` (+1 entry) · `tests/test_crucible.py` (new).
Kernel touch: NONE in this PR. Wiring `crucible gate` into the kernel response-gate
            (so it fires automatically) is a kernel change → human-only, separate
            follow-up. crucible ships autonomous + on-demand; the always-on kernel
            wire is deferred.

## Tests (mandatory)
- registry loads + schema-validates every entry; `list` returns all seeded controls.
- `run --id pytest` (mocked subprocess) maps exit code → verdict.
- `gate` non-zero when any BLOCK fails; zero when all pass; WARN never blocks.
- `register` appends + persists a new control.
- R_MEMORY_RESPECTED: fixture commit "Co-Authored-By: Claude" → BLOCK; clean → pass; "PR-7" public body → BLOCK.
- R_NEW_NEEDS_TEST: fixture diff adding `tools/foo.py` w/o `tests/test_foo.py` → BLOCK; with test → pass; new program w/o test ref → BLOCK.
HUMAN/grant runs `python3 -m pytest tests/test_crucible.py -q`. Nothing merges on red.

## Rollback (I-04)
`rm tools/crucible.py tools/crucible.json workspace/programs/crucible.md workspace/programs/help/crucible.md tests/test_crucible.py`;
`git checkout tools/REGISTRY.json`.

## Notes
Rides the 21 existing control tools + verify.py + pytest — **do not duplicate**;
crucible is a registry + orchestrator + fail-closed verdict, nothing more. The two
NEW rules (R_MEMORY_RESPECTED, R_NEW_NEEDS_TEST) are genuinely new logic and carry
their own tests (dogfooding R_NEW_NEEDS_TEST). Default density: terse board; full
detail only on failure.

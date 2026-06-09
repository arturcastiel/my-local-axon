# Masterplan — AXON Discipline

## Charter

**Goal.** Give AXON a development discipline — and the enforcing machinery — so it can keep growing
without silent regressions. The discipline must directly counter the failure mode the super-polish arc
exposed: mechanical bugs hide in LLM-interpreted markdown that is never executed in a test, and are
"covered" by static text assertions that, in the worst case, assert the bug itself.

**The thesis to prove (and build on).** Every program is a *mechanical skeleton* (deterministic:
template expansion, `EXTRACT`/`REPLACE`, `STORE`/`RETRIEVE`, `TOOL`/`EXEC` calls + args, pure branch
predicates) fused with *judgment points* (genuinely fuzzy, need the LLM). The bugs that hid in this
session were ALL in the mechanical layer (see 01-study.md §2). That layer is fully testable by
*executing* it with tools mocked and judgment stubbed. "Markdown is hard to test" conflates the two
layers; separating them is the unlock.

**Acceptance criteria (project is done when all hold, each landed in small gated PRs):**
1. A **deterministic program harness** exists: it executes a program's mechanical AXON-LANG with tool
   outputs mocked and judgment points stubbed, and asserts the observable effects — the `TOOL`/`EXEC`
   call sequence + args, `STORE`/`RETRIEVE` state mutations, and file writes.
2. The harness **reproduces, as red-then-green regression tests, the 5 mechanical bugs** from this
   session (01-study.md §2) — proof the thesis catches real defects.
3. The **two flagships** — the code-dev PR flow and the workflow engine — have harness-effect tests for
   their mechanical paths.
4. A **coverage map** report lists every program × {static-shape, harness-effect, contract} and every
   tool × {unit, branch}, surfacing the uncovered set; wired as a WARN crucible control with a floor
   that ratchets up.
5. The **anti-masking law** (assert the effect, never the producer) and **regression-lock-before-fix**
   are documented and, where feasible, linted (a check that flags write-without-readback tests).
6. The **change-discipline is encoded as an AXON workflow** (self-hosting) + any new gate controls, so
   the methodology is enforced by the system it governs, not just written down.
7. Every change ships **gated green** (`crucible passed:true`), as a small single-concern PR, following
   the full merge discipline.

**Scope.** `tools/` (the harness, the coverage-map, new controls), `tests/` (the regression locks +
fixtures), `workspace/programs/` (thin-waist refactors of flagships, the discipline workflow). Build on
existing substrate — crucible, coverage-gate, neuron-audit, behavioral fixtures, workflow-simulate,
contract metadata.

**Non-goals.**
- NOT making LLM judgment deterministic, nor exact-trace-testing the fuzzy layer.
- NOT a kernel rewrite. Touch `axon/` only if unavoidable (and then dev-mode + F50).
- NOT bulk landings (the failure mode we're correcting).

## Phase graph (directed)

- **1-foundations** → 2-harness-rollout
    Adopt the two free laws as enforced artifacts (anti-masking lint stub + regression-lock convention).
    Design + prototype the deterministic harness on ONE flagship program. Reproduce the 5 session
    mechanical bugs as harness regression tests (proof-of-thesis). Decide the harness's mocking/stubbing
    contract and how it reads the existing `responses.jsonl` fixtures.
- **2-harness-rollout** → 3-coverage-map
    Generalize the harness into a reusable test helper. Retrofit harness-effect tests onto the code-dev
    PR flow and the workflow engine (the named flagships). Add golden-effect assertions where stable.
    Apply the thin-waist rule: push residual logic out of those programs into tested tools.
- **3-coverage-map** → 4-adversarial-and-ratchet
    Build the program×tool coverage-map report; surface the uncovered set; wire a WARN control with a
    ratcheting floor. Add behavioral contract-assertion in the harness (precondition / inputs / outputs).
    Add orphan-PROGRAM detection (defined-but-never-EXEC'd) to complement orphan-tool detection.
- **4-adversarial-and-ratchet** → (done)
    Productize the independent adversarial-review pass as a code-dev phase (a second author/agent whose
    job is to refute / find the masked bug before merge). Encode the whole change-discipline as an AXON
    workflow (self-hosting). Graduate the producer-only lint + a logic-density lint from WARN to BLOCK.

Phases are added/edited by: code-dev phase new.

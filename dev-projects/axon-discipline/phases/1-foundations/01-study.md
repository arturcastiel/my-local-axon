# Study — 1-foundations (axon-discipline)

> Seed written 2026-06-03 from the super-polish arc + the methodology discussion that closed it. This is
> the autonomous run's primary context. `code-dev study` may refine/extend it; `code-dev plan` turns §8
> into a PR list. Charter + acceptance: `../../masterplan.md`. Constraints: `../../_dont-do-seeds.md`.

---

## 0. What this project is

Establish AND implement a development discipline so AXON grows without silent regressions. Not a wiki
page of advice — concrete enforcing machinery (a test harness, a coverage map, new gate controls, an
AXON workflow that encodes the discipline) plus two cost-free laws adopted immediately.

---

## 1. Evidence — the super-polish arc (why we are here)

The discipline is a response to a measured failure, not a hunch. The arc, all merged to `main`:

- **MR !107** — super-polish MEGA sweep: 65 confirmed bugs fixed (10 critical / 38 high / 16 med / 1 low)
  across code-dev, the workflow engine, and tooling. Multi-agent hunt; each bug refutation-survived.
- **MR !108** — git-op rule rationalization (kernel v1.1.4→v1.1.5; operation-risk-based destructive-op
  policy, default-off delegation).
- **MR !109** — **the 15 audit regressions the 65-fix sweep MISSED.** A second, independent MEGA audit
  found the campaign had NOT cleanly held: **5 regressions + 10 new defects**. All 15 fixed here.
- **MR !110** — docs regenerated to current state; a dangling cheatsheet link fixed; freshness gate fully
  green (it had carried a warning through every prior batch).

Raw evidence on disk (same my-axon tree): `../../../super-polish/03-prs/findings-mega.json` (the 65),
`../../../super-polish/03-prs/audit-mega.json` (the audit verdict + 15 confirmed findings),
`../../../super-polish/03-prs/audit-fix-status.md` (the 15, all ✅).

**The uncomfortable fact:** a careful, multi-agent, gated 65-bug campaign still shipped 5 regressions and
left 10 bugs, several of them *in the fixes themselves*. Trying harder is not the fix. The process has a
structural blind spot.

---

## 2. The central lesson + the 5 mechanical bugs (the proof of the thesis)

The audit's root finding: **several "fixes" were producer-only-locked — a test asserted the producer
wrote a value but never that the consumer observed it / the end-state changed.** The sharpest case:
`tests/test_workflow_run_program_fixes.py` "Bug-4" literally *asserted the buggy form*
(`record-step --node {cursor.name}`), so the wrong behavior was "covered" and green.

Now look at WHAT the hidden bugs actually were — the 5 that lived in markdown programs (MR !109):

| Bug (program) | Defect | Layer |
|---|---|---|
| pr-create `## PR-{pr-id}` | double-prefix → `## PR-PR-001`, a no-op section write | mechanical (string) |
| workflow-run `record-step --node {cursor.name}` | recorded the NAME where the guard compares the ID | mechanical (arg) |
| safety-freeze thaw `REPLACE` | matched only `frozen`, left `# was:` dangling, restored wrong step | mechanical (string) |
| workflow-run `{W:ws-path}` / `{W:_workflow-run-path}` | expand to `''` on a `--name` run → off-tree write / crash | mechanical (state) |
| workflow-new resume | PHASE-C unconditionally reset `synapses ← []`, discarding built state | mechanical (control-flow) |

**Every one is mechanical — a wrong string, variable, argument, or branch. None is an LLM-judgment bug.**
Each is fully deterministic: given a fixed input, the wrong output is computable WITHOUT an LLM. They hid
only because (a) the mechanical layer is never *executed* in a test, and (b) the static text test that
"covered" it asserted shape (or, worse, the bug) rather than effect.

---

## 3. Diagnosis — two layers fused in one file

Every AXON program is:
- a **mechanical skeleton** — `STORE`/`RETRIEVE`, template expansion (`## {pr-id}`), `EXTRACT`/`REPLACE`,
  `TOOL(...)` calls + args, `EXEC` routing, pure branch predicates. **Deterministic. No LLM needed.**
- a set of **judgment points** — "write a good description", "pick the next synapse", "is this
  acceptable". **Genuinely fuzzy. Needs the LLM.**

"Markdown is hard to test" silently assumes the whole file is fuzzy. It isn't. §2 proves the bugs that
escape live in the mechanical layer — which is exactly the testable one. **The unlock is to stop testing
markdown by READING it and start testing it by RUNNING its deterministic half**, with tools mocked and
judgment stubbed, asserting effects.

---

## 4. Inventory — what AXON already has (build on it, ~70% there)

From a structured sweep of tools/ + tests/ + workspace/programs/ (cite file:line when extending):

- **Crucible gate** — 22 controls, fail-closed, 18 BLOCK + 4 WARN (`tools/crucible.py`, `crucible.json`).
  Includes: pytest, changeset-rules (R_NEW_NEEDS_TEST / R_MEMORY_RESPECTED), dag-consistency, liveness
  (orphan tools across 6 surfaces), coverage-gate, neuron-audit, registry-drift, freshness, lint-paths,
  budget-lint, metric-integrity, lint-commit-trailer, and more.
- **Coverage floor** — `tools/coverage_gate.py`: `tools/rules` 100% line+branch, `tools/` ≥80% line
  (reads `coverage.xml`, pytest-cov branch=true). The Python logic is already well-covered.
- **Static program tests** — ~144 test files read `.md` and assert structure/shape (`test_programs_md.py`,
  `test_programs_tier_a.py`, `test_workflows_*.py`). Good for SHAPE; the masking risk lives here.
- **Tool behavioral tests** — ~115 files import tools and assert I/O.
- **Behavioral fixtures** — `tests/fixtures/programs/*/responses.jsonl`: human-curated mock traces, with
  structural-overlap ≥0.6 matching. **This is the seed of the harness** — it already mocks model output.
- **workflow-simulate** — dry-runs a workflow, emits a per-step trace. (No golden comparison — see §5.)
- **Compiled programs** — `tools/compile*.py` → `workspace/programs/compiled/*.cmp.md`: deterministic
  lowering (strips comments/docstrings), token-ratio gated. Not more *executable*, but a cleaner surface.
- **Contract metadata + validation** — every program's `# synapse:` block (precondition, inputs-count,
  outputs-count, role, status, contract-version). Checked statically by `neuron-audit` /
  `synapse-validate` / `synapse-infer`. NOT enforced behaviorally (see §5).
- **Orphan-TOOL detection** — `tools/rules/r_no_orphan_tools.py` (BLOCK) + `tools/liveness.py` (6 surfaces).
- **Dev discipline today** — `CONTRIBUTING.md` (every change ships tests + doc anchor + coverage); 91
  `code-dev-*.md` programs encode plan→PR→review→merge; 6 CI gates; `AXON-DOCS-TESTING.md` taxonomy.

---

## 5. The precise gaps (the whole game)

1. **No program is ever executed in a test.** The mechanical skeleton runs only in production, under an
   LLM. Its bugs surface as silent wrong behavior. ← PRIMARY GAP.
2. **No coverage map for programs.** Coverage measures `tools/` only. Nothing answers "which programs
   have which tests / what is uncovered." *Unnoticed* = *invisible*.
3. **Contracts not enforced behaviorally** — precondition/inputs/outputs are validated as text, never
   asserted against a run.
4. **No golden / effect comparison** — workflow-simulate emits a trace; nothing diffs it vs expected.
5. **No orphan-PROGRAM detection** — defined-but-never-`EXEC`'d programs aren't flagged (only tools are).

These map onto the owner's three pains: "bugs unnoticed" = gaps 1+2; "can't cover all aspects at once" =
gap 2 + single-pass blindness (§6.6); "markdown hard to test" = gaps 1+3+4.

---

## 6. The methodology — 7 principles

First two are free (pure discipline, adopt now); the rest are builds, ordered by leverage.

1. **Thin waist — push every decision down to a tool.** A markdown line that computes/transforms a value
   is a smell; it belongs in a tool, where the 100/80% coverage floor catches it. Flagships → near-pure
   orchestration. (Optionally: a logic-density lint on programs.)
2. **Assert the effect, never the producer (anti-masking law).** No test may assert "wrote X" without
   asserting the consumer/end-state changed (write → read back → assert). The one law that prevents the
   audit's entire central finding. Review rule now; later a lint flagging write-without-readback.
3. **The deterministic program harness (highest-leverage build).** Execute a program's mechanical
   AXON-LANG with tools mocked + judgment stubbed; assert effects (TOOL/EXEC call sequence + args,
   STORE/RETRIEVE mutations, file writes). Seed from `responses.jsonl`. Every §2 bug dies here.
4. **The coverage map.** Report program×tool test status; surface the uncovered set; WARN control with a
   ratcheting floor. Makes "you can't cover everything at once" survivable — gaps become *visible*, not
   silent.
5. **Contract assertion in the harness.** Declared precondition/inputs/outputs become run-time assertions
   the harness checks. A program that violates its own contract fails a test.
6. **The adversarial second pass.** A single pass cannot cover everything — permanent, unfixable by
   effort (the sweep missed 15; an independent audit found them). Institutionalize an independent pass by
   a DIFFERENT author/agent, prompted to REFUTE, before merge. (Where opt-in multi-agent review earns it.)
7. **The ratchet.** Every confirmed bug → a permanent regression lock written BEFORE the fix. A bug-class
   seen twice → a new crucible control. Small single-concern PRs. The gate floor only rises.

**Self-hosting:** encode the discipline AS an AXON workflow (plan → thin-waist check → tests at all
layers → harness → adversarial pass → gate → merge). AXON's thesis is that disciplines are executable
programs; its own evolution should be the first citizen.

---

## 7. Adoption path = phase graph (see masterplan.md)

- **1-foundations** (this phase): the two free laws as artifacts + harness PoC on one flagship +
  reproduce the 5 §2 bugs as red→green regression tests.
- **2-harness-rollout**: generalize the harness; retrofit code-dev PR flow + workflow engine; thin-waist
  those programs.
- **3-coverage-map**: program×tool coverage report + WARN control; contract assertion; orphan-PROGRAM
  detection.
- **4-adversarial-and-ratchet**: adversarial review as a code-dev phase; encode the discipline workflow;
  graduate producer-only + logic-density lints WARN→BLOCK.

---

## 8. This phase — candidate PRs for `code-dev plan` (sketch, not final)

Keep each PR small, single-concern, gated green. Suggested sequence:

- **PR-A — anti-masking law + regression-lock convention (docs, free).** Add the law to
  `CONTRIBUTING.md` + `AXON-DOCS-TESTING.md`; state "regression test before fix". No code. Ships its own
  doc-anchor. (Principle 2 + 7.)
- **PR-B — harness skeleton (tool).** `tools/program_harness.py`: parse a program's mechanical AXON-LANG;
  execute template expansion + EXTRACT/REPLACE + STORE/RETRIEVE against an in-memory state + a fixture
  filesystem (tmp_path); record the TOOL/EXEC call log; tools mocked via a supplied dict; judgment points
  return supplied stubs. Decide op-coverage (ADR-001) + mock/stub contract (ADR-002). Unit-tested to the
  100/80 floor like any tool.
- **PR-C — prove the thesis: reproduce the 5 §2 bugs.** Pick the prototype flagship (ADR-003 — likely
  workflow-run.md, the richest mechanical surface). For each of the relevant §2 bugs, write a harness test
  that would have gone RED on the pre-!109 program text and is GREEN now. This is the proof the harness
  catches real mechanical defects, not toy cases.
- **PR-D — wire it.** Expose the harness as a pytest helper + (optionally) a WARN crucible control
  `program-harness` that runs harness tests. Don't BLOCK yet (rollout is phase 2).

Open questions for study/plan to resolve: exactly which AXON-LANG ops the harness interprets vs. treats
as opaque; how faithfully it must mirror the kernel's interpretation (and how to keep them from drifting
— consider generating the harness's op-table from the same source the kernel uses); whether to run on raw
`.md` or the compiled `.cmp.md` (compiled is a cleaner, comment-free surface).

---

## 9. Constraints

See `../../_dont-do-seeds.md` (seeded into `_dont-do.md`). Prime ones: assert the effect not the
producer; regression test before fix; no bulk PRs; gate-first (parse `passed` separately); full merge
discipline (brand-free/no-PR-n commits, AXON trailer, pre-lint squash, merge-by-number); dev-mode only
for `axon/`; build on existing substrate, don't reinvent.

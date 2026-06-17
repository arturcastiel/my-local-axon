# STUDY-PHASE RULING — axon-new-doc

**Goal under test:** per-program usage manuals with run-verified examples.
**Prior pass depth:** high-level architecture OVERVIEW only.

## 1. Grade table

| Program | Tier | Grade | Purpose | Reference | Examples |
|---|---|---|---|---|---|
| code-dev | flagship | **C** | ready | NOT ready | NOT ready |
| workflow | flagship | **B** | ready | ready | ready |
| library-dev | flagship | **B** | ready | ready | ready |
| goal-define | peer | **B** | ready | ready | ready |
| plan | peer | **C** | ready | ready | NOT ready |
| chat | peer | **C** | ready | ready | NOT ready |
| harness-builder | peer | **B** | ready | ready | ready |
| deep-research | skill (out-of-tier) | **C** | ready | NOT ready | NOT ready |

**Tally:** 0 A · 4 B · 4 C. Purpose-readiness 8/8. Reference-readiness 5/8. Examples-readiness 4/8.

## 2. Verdict — NOT FINISHED

The study is **not finished** for the stated goal. It cannot ship per-program manuals with run-verified examples on the current overview pass. Three blockers are unresolved and recur across every program:

1. **Runnability/example contract is undecided (universal blocker).** Every program confirms the same two-layer reality: the headline commands are LLM-interpreted `.md` DSL neurons that are NOT in any REGISTRY and NOT shell-dispatchable; only the backing Python tools are deterministically runnable. The project has not yet decided what "run-verified example" means — runnable tool commands vs. labeled agent-session transcripts. Until this contract is fixed, no manual can claim a verified end-to-end example. This single decision gates all of examples-readiness.

2. **Command/option reference is not at command-level for the flagship.** code-dev studied only ~7% of its surface (6 of 87 files; ~80 subcommands known by name only) — the dominant program is nowhere near reference-ready. deep-research has no on-disk spec at all (wrong artifact type; harness-injected skill).

3. **No run-verified end-to-end example has actually been observed for any flagship neuron.** Even the B-grade programs (workflow, harness-builder) explicitly note the full interactive/EMIT path was reconstructed from source, not driven live. The B examples cover the deterministic tool teeth, not the flagship neuron.

The four B-graded programs are close — their tool-layer examples are real and captured — but they still inherit blocker (1) for the headline-command examples, and each carries documentation traps that must be reconciled before writing (canonical YAML drift in library-dev; advisory-only constraints + side-effecting dry-run in goal-define; W:tool-registry resolution unknown in harness-builder). The two C peers (plan, chat) have a confirmed reference but anti-mimicry traps that make idealized examples wrong: plan-new's output format does not match real on-disk plans (0/0-task progress bars), and chat's state is empty/unscaffolded with a path discrepancy (workspace/chats vs my-axon/chats) and a missing CHAT-FORMAT.md.

Overview depth was sufficient to grade purpose and partially establish reference, but it is structurally insufficient for command-level manuals + runnable examples — as expected.

## 3. Ordered per-program study TODO (before planning)

**Phase 0 — cross-cutting prerequisite (do once, unblocks everything):**
1. **Resolve the runnability/example contract.** Read `tools/run.py`, `tools/boot.py`, `axon/BOOT.md`, `startup.md`, `axon/KERNEL-SLIM.md` (DSL semantics: DERIVE/EVAL/EXEC/QUERY/STORE), `axon/COMMANDS.md` (token parse, free-text routing, run --input). Define: the canonical user entry chain (boot → load → command), the arg→W-key binding layer, and the standard for "run-verified" (runnable tool command vs. agent transcript). This decision is a hard dependency for every program's examples section.

**Phase 1 — flagships (deepest gaps, highest traffic):**
2. **code-dev — deep pass (largest effort).** Per-command read of the ~80 unread subcommand programs (plan, pr-create, pr-review, safety-audit, merge, branch, divide, combine, journal-*, review-*, meta-*) extracting ARG flags, QUERY prompts, TOOL calls, written files, DONE/FAIL paths. Resolve the phantom `TOOL(pr)` (missing from REGISTRY). Confirm each referenced TOOL (shell/dag/session/graphify-bridge/constraints/skip-guard) is registered+runnable. Read `study_modes.py`/`study_evals.py`/`study_index.py`. Run every backing tool (`phase_model.py`, `shadow.py`, `study_modes.py`, `skip_guard.py`, `constraints.py`, `dag.py`, `session.py`) with `--help` and against a real v4 project. Drive (or transcript) one full agent session.
3. **workflow — finish.** Drive one full agent-interpreted `workflow-run`; read `workflow-explain.md`, `workflow-new-questions.yml`, `workflow_dag.py`; run-verify an adaptive run and the nested-workflow anti-skip (SubWorkflowNotCompletedError).
4. **library-dev — finish + reconcile.** Capture canonical tool-layer outputs (intersect/cite/partition/rank/gap-queries/chunk); read `retrieval_eval.py` chunk internals; resolve the search→ingest folder hand-off; decide the pdftotext (poppler-utils) precondition and provide a TXT-path guaranteed-runnable example; flag the copy-paste canonical.yml trap.

**Phase 2 — peers:**
5. **goal-define — finish.** Drive a real booted session (incl. a constraint-shaped goal) to verify the ledger WRITE path and CONSTRAINTS.json row; document the side-effecting "dry-run"; note auto-routed constraints are advisory-only.
6. **harness-builder — finish.** Drive a real 6-question wizard run; capture verbatim generated harness output; resolve `RETRIEVE(W:tool-registry)`; confirm EVAL/RETRY/EMIT/CONFIDENCE/GUARD are real kernel primitives.
7. **plan — deep pass.** Confirm there is no deterministic runner; trace code-dev `plan` subcommand dispatch; reconcile the plan-file format divergence vs. real on-disk plans (document the 0/0-task quirk); script a verifiable 02-plan.md write.
8. **chat — deep pass.** Trace user-text→W-key routing; reconcile workspace/chats vs my-axon/chats; derive the authoritative chat .md schema (no CHAT-FORMAT.md exists); establish how INDEX.md gets its scaffolding so a non-empty `index.py` example is possible.

**Phase 3 — skill (separate treatment):**
9. **deep-research — relocate, don't force.** It is a Claude Code skill, not an AXON program; document it on a Skills/Capabilities page, not the program-manual template. Either ingest it via `skill_adapter.py` into `workspace/programs/skills/` first, or capture one live invocation transcript; accept that output is non-deterministic and cannot be byte-verified.

## 4. Recommendation

Resolve the runnability/example contract first (Phase 0), then run `code-dev study --mode=deep` on the flagship 3 (code-dev, workflow, library-dev) before any planning — code-dev alone (~80 unread subcommands + phantom `pr` tool) is the long pole and must not enter planning at 7% coverage.

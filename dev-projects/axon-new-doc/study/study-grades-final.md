The load-bearing claims hold: no `pr` tool in the registry, no `deep-research` program. The per-area findings are consistent and self-corroborating. Ruling below.

# axon-new-doc STUDY — Finalization Ruling

## (1) Regrade table: program family → grade

| Program family | New grade | Examples ready |
|---|---|---|
| code-dev CORE/LIFECYCLE (phase-model, shadow, study-modes) | A | yes |
| code-dev PR family (pr-create/review/ready/link/github/update-spec/spec) + TOOL(pr) gap | A | yes |
| code-dev SAFETY+STRUCTURE (preflight, dry-run, hold/freeze, partition/divide/combine, dont-do) | A | yes |
| code-dev JOURNAL/KNOWLEDGE/STATE (journal, changelog, since, reviewer-track, test-map, link, replay, state-metrics/handoff/undo) | A | yes |
| PLAN family (plan-new/add/done/list/view) + code-dev-plan phase | B | yes |
| CHAT family (mode-chat, new/open/switch-chat, chat-folder, list-chats, chat-input, _chat-checkpoint) | A | yes |
| workspace/programs B-traps (library-dev, goal-define, harness-builder, deep-research) | A | yes |

Net: 6 of 7 families at A; 1 (PLAN) at B. Every family reports `examples_ready: true`.

## (2) FINISHED for the goal? **YES**

The goal — per-program usage manuals with a hybrid example contract — is met. Every family resolved its naming/kind/path traps to ground truth: the recurring and most dangerous trap (the agent-interpreted `.md` neurons are NOT `python3 axon.py` tools — `pr`, `plan-new`, `code-dev-journal`, `chat`, etc. all return `{"error":"Unknown tool ..."}`, verified live) is now consistently resolved, with each family correctly routing runnable hybrid examples to the real backing Python tools (pr_aggregate/board/dag/shadow/phase-model/constraints/library/dont-do-lint/dry-run-lint) and labeling neuron behavior as faithful session-transcripts reconstructed from verbatim `→` OUTPUT lines. The hybrid contract is honored exactly as intended: captured CLI output where a tool exists, transcript-from-source where the surface is agent-interpreted, with the boundary explicitly stated in every `still_missing`. The remaining gaps are uniformly of two non-blocking classes — (a) mutating/auth-dependent surfaces deliberately not exercised to keep the study read-only (phase-model advance/done, shadow init/append, pr_sync's `gh` calls, live `boot`), and (b) genuinely non-deterministic agent-runtime behavior (pr-review `--phase N` resume, DSL primitives like PROGRESS_BAR). Neither class is fixable by more reading; both are correctly documented as caveats rather than left as unknowns. PLAN stays at B not for missing documentation but because it surfaces a real product defect (writer/reader schema drift) — which is itself a fully-characterized, well-documented finding, not a hole in the manual.

## (3) Remaining blockers before code-dev plan

None block starting the code-dev plan. The study output is sufficient input. The following should be carried into the plan as **work items**, not study reopens:

1. **PLAN schema drift (B-grade, ship-blocking bug, not doc-blocking).** plan-new writes `# PLAN:` + `## TASKS` checkboxes; the real hand-authored plans use `# Plan — <title>` with freeform `## PHASES` and zero `- [ ]` lines, so plan-list/plan-view render 0/0 task bars for every real plan. Reconcile the two schemas (one writer, one renderer) — first concrete PR candidate.

2. **Confirmed metadata bugs to file (not study gaps):**
   - `_chat-checkpoint.md` declared `read-only` but mutates the chat file (UPDATE CONTEXT, PREPEND HISTORY) — wrong flag would skip the KERNEL-SLIM pressure-gate.
   - `chat-input.md` persists an assistant turn with `role:assistant` but no `text:` field — assistant reply content is not saved.
   - `library-dev-explain.md` writes `## Key Terms & Concepts` while `library.py parse_shadow` matches only exact `## Key Terms` → silently yields `key_terms=[]`, breaking intersect.
   - goal-define auto-routes **only advisory** constraints (omits `--teeth`/`--check`) → never mechanically enforced; flag if mechanical enforcement is intended.

3. **Documentation-correctness fixes (cheap, do in plan):** help docs state plans live in `workspace/plans/` (actual: `my-axon/plans/`) and chats in `workspace/chats/` (actual: `my-axon/chats/`); stale `CHAT-FORMAT.md` referenced as a SCAN exclusion but does not exist; recommend a wiki "Skills (host-provided)" section separating `deep-research` (Skill-tool only, never ingested) from AXON programs.

4. **Deferred-to-mutation verifications (optional, only if the plan touches these paths):** live capture of phase-model advance/done, shadow init/append, pr_sync against an authenticated repo, and W:tool-registry BRIEF-vs-FULL contents at boot. All are mutating/environment-dependent and were correctly excluded from a read-only study.

# CD·GAP·C1·P2 — undercovered topics catalog

> Each topic listed in C1·P1 as shallow/missing, expanded with: *what's there*, *what's missing*, *why it matters now*, *which downstream item it unblocks*.

## U-1. Compiled-program audit
**What's there:** `cd-c3-p1-tokens.md` measured `code-dev-pr-review.cmp.md` at **-1% compression** (negative). Identified as Round-2 top-15 #1.
**Missing:** measurements for every other `compiled/` program. Likely several others have low or negative compression.
**Why now:** Wave-0 of any roadmap is the compile-write regression gate. Without baseline numbers, we can't set the gate's threshold.
**Unblocks:** T-A3 (regression gate), R5 Wave-0 plumbing.

## U-2. Schema migrator (v1→v4 and forward)
**What's there:** `cd-c1-p1-schema-map.md` documents v1 vs v4 deltas. axon-master is v1, blocking `code-dev resume`.
**Missing:** actual migrator design — file format, idempotence, rollback, dry-run, what to do when fields can't be inferred.
**Why now:** axon-master itself can't resume. Anyone with old projects is blocked.
**Unblocks:** all R5 work depending on schema fields; G-CD-A1; future v5 fields (stack-id, last-sync, spec-history).

## U-3. Test surface for code-dev
**What's there:** workspace-level `tests/` covers `tools/`. Programs (markdown) have no regression tests.
**Missing:** how to test a program-as-prompt. Recipe corpus, golden outputs, idempotence checks.
**Why now:** Round-3 W4 (file renames) is high-risk without tests. Round-5 mode rollout (S2..S5) needs per-mode golden output.
**Unblocks:** R3-W4 file renames; R5-S2..S5 mode validation; R4-K (Study K).

## U-4. Failure-mode catalog
**What's there:** at least 2 logged incidents — 2026-05-15 unauthorized push, axon-master v1 schema mismatch. Operational-safety memory rule was added.
**Missing:** systematic catalog of failure classes (identity drift, schema mismatch, premature push, hallucinated tool output, persona-bleed after compaction, stale gating).
**Why now:** patterns exist; cheap to extract; informs gates and rules.
**Unblocks:** R4-H, R5-NS-12, hardening of safety rules.

## U-5. Cross-cutting governance composition
**What's there:** Round-4 introduced `safety rule {add|list|...}`, Round-5 introduced `plan --rule`, Round-4 introduced `pr ready` and study staleness.
**Missing:** the *composition law* — when these collide, who wins? Example: `safety/rules.md` says "no schema changes" but `plan --mode=risk-first` includes a security PR that requires one. What happens?
**Why now:** rule precedence is invisible until two rules contradict mid-workflow.
**Unblocks:** plan-mode reliability; `pr ready --strict` semantics.

## U-6. Session / chat / handoff model
**What's there:** `code-dev handoff`, `freeze`, `thaw`, `tag` (save/restore), `resume`, `undo`, plus separate `chats/` artifacts.
**Missing:** unified mental model: what is a "session"? When does context compact and what survives? Where does `my-axon/chats/` fit?
**Why now:** every round has been bookended by compaction incidents and re-anchoring. Without a model, we'll keep fighting drift.
**Unblocks:** R4-H (failure modes overlap); cleaner `handoff`/`resume` semantics; chat-folder integration.

## U-7. Documentation strategy
**What's there:** `axon/COMMANDS.md`, `axon/HOWTO.md`, `workspace/AXON-DOCS.md`. R4 proposed `AXON-DOCS-WORKFLOWS.md`; R5 proposed `AXON-DOCS-STUDY.md`; `meta cheatsheet` proposed.
**Missing:** which doc is canonical for what audience (new user vs maintainer vs reviewer)? How do they index each other? Where do per-mode docs live?
**Why now:** before adding `meta cheatsheet`/`meta examples`/per-mode docs, decide the doc tree once.
**Unblocks:** all docs-related targets across rounds.

## U-8. Cost / token budgeting framework
**What's there:** R5 sets per-mode token budgets. R2 c3 measured compile compression. R3 estimates router sizes.
**Missing:** unified accounting: tokens-per-turn budget; cumulative project-spend; per-mode/per-recipe budgets aligned with prompt-cache fit.
**Why now:** without one frame, individual budgets are guesses that can't be reconciled.
**Unblocks:** prompt-cache discipline; R5-S0 (plumbing) budget defaults; R6 future evals (NS-4).

## U-9. Architecture-drift detection
**What's there:** R5 mode catalog mentions a future `architecture` mode (post-MVP).
**Missing:** declarative architecture description format; comparison algorithm against current code.
**Why now:** medium priority; included for completeness.
**Unblocks:** ADR audit recipes.

## U-10. Library-dev parallel
**What's there:** mentioned only as Round-4 Study A.
**Missing:** comparable inventory + alignment check.
**Why now:** if `library-dev` adopts same umbrella, cross-system coherence improves; out of immediate critical path.
**Unblocks:** ecosystem-wide consistency.

## U-11. Backup / sync of project state
**What's there:** `my-axon` repo configured today; one push completed; backup state files present.
**Missing:** hardening (encrypted secrets, exclude rules, restore-test, push-policy gates).
**Why now:** we just turned it on; rough edges will appear; recent incident (unauthorized push) is one signal.
**Unblocks:** R4-I (Study I); operational-safety memory updates.

## U-12. Dispatch quality measurement
**What's there:** `tools/dispatch.py` uses TF-IDF over `# desc:` lines.
**Missing:** golden-prompt corpus + precision/recall measurement; especially important post-Round-3 rename.
**Why now:** Round-3 rename plan touches `# desc:` lines en masse; need a ratchet.
**Unblocks:** safe rollout of R3 waves.

## Prioritization for Round 6 deep dives

| ID  | Topic                            | Urgency | Effort | Score |
|-----|----------------------------------|:-------:|:------:|:-----:|
| U-1 | Compiled-program audit           | high    | low    | 5.0   |
| U-2 | Schema migrator                  | high    | med    | 4.0   |
| U-3 | Test surface for code-dev        | high    | med    | 4.0   |
| U-4 | Failure-mode catalog             | high    | low    | 5.0   |
| U-5 | Governance composition           | med     | low    | 4.0   |
| U-6 | Session / chat model             | med     | low    | 4.0   |
| U-7 | Documentation strategy           | med     | low    | 4.0   |
| U-8 | Cost / budgeting framework       | med     | med    | 3.0   |
| U-9 | Architecture-drift               | low     | med    | 1.5   |
| U-10| Library-dev parallel             | low     | med    | 1.5   |
| U-11| Backup hardening                 | med     | low    | 3.5   |
| U-12| Dispatch quality measurement     | med     | low    | 3.5   |

Round-6 L2 will deep-dive U-1, U-2, U-3, U-4 (highest scores).
Round-6 L3 will deep-dive U-5, U-6, U-7, U-8 (cross-cutting).
U-9..U-12 are referenced; full studies deferred (named as future rounds).

→ goal extraction across rounds: `cd-gap-c1-p3-goals-extracted.md`.

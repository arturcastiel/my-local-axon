# High-Level Plan — AXON Bugfix 02
Updated: 2026-07-07  ·  Iterations: 1 (+ decision lock)  ·  AXON: 8.5/10  ·  User: approved ("follow advises, and adapt plan", 2026-07-07)

## Context (from Phase 1)
Goal: turn the verified residual-surface audit (AUDIT-FINDINGS.md: 4 CRITICAL, ~18 HIGH, ~22 MEDIUM,
~25 LOW over the surfaces bugfix01 never covered) into a severity- and dependency-ordered fix backlog.
Root cause of most CRITICAL/HIGH findings: the dashboard + session-reporting layer reads memory keys
and tool-output fields no writer produces — readers only READ, so nothing fails loudly and the OS
self-report is quietly fiction. Second class: false success after gate-blocked shell/git ops.

## Architecture Overview
AXON = markdown neuron programs interpreted by an LLM agent, backed by Python CLI tools (`tools/*.py`
via `axon.py`) and JSON/JSONL/markdown state. The reporting layer (menu/status/stats/gain/
session-summary/resume/board) reads that state. Key mechanism discovered at plan time: the accessor-
conformance lint ALREADY exists (`tools/program_tool_conformance.py` checks `.field` reads against
`tools/output_manifest.json`, "unmanifested pair — grow the manifest, never guess") — the manifest just
covers only 5 tools. `W:` keys persist as files under `workspace/memory/working/` — they survive
session death, which makes `W:active-phase` the real resume pointer.

## Strategy
Six dependency-ordered waves, root-cause-first. The mechanical guard (Wave A) lands FIRST in
REPORT-mode with a grandfathered baseline — inverting bugfix01's lint-last precedent — so waves B–E
burn the baseline down PR by PR; the lints become blocking crucible gates LAST (Wave F), once green.
Report-mode-first dissolves the baseline-merge-friction objection raised in council. Every
cross-cutting pattern from the study gets a permanent mechanical guard: pattern 1 (reader/writer
drift) → Wave A; pattern 2 (false success after gate-block) → PR-009; pattern 3 (half-deprecated
blocks) → PR-014 + liveness lint (bugfix01 PR-028, already live); pattern 4 (orphaned duplicate
tools) → PR-011.

## Council record (plan-rigor protocol, 2026-07-07)
Four adversarial vectors were run INLINE (serialized) after the parallel council was killed by the
host session token limit — verdicts verified against live source/runs, independence weaker than a
true parallel council; owner accepted and locked the outcome. Attacks that changed the plan:
1. **Memory-key lint repaired** — naive "every RETRIEVE needs a writer" flags 223/333 keys (67%
   noise; `RETRIEVE | default` is the legitimate optional-config idiom, `W:_*` is the arg-passing
   convention). Shippable: ERROR on unguarded orphaned reads only (71 keys measured), advisory list
   for guarded orphans, declared L: config-key allowlist, grandfathered baseline.
2. **Resume simplified** — `W:` persists as files; `W:active-phase` IS the resume pointer (kernel
   boot already reads it). No event-vocabulary standardization, no kernel edit, no writer changes.
3. **Two NEW workspace-backup defects** (missed by the study): (a) PUSH one-liner shell-precedence
   bug — `add && diff --cached --quiet || commit && push` short-circuits on no-change days, so a
   committed-but-unpushed state NEVER retries; (b) the no-.git restore path (clone+rsync+rm -rf) is a
   second fully-unchecked path behind the same unconditional "✓ restored".
4. **Turn-log writer degeneracy** (new finding): rows are bare timestamps with constant OUT text and
   no program attribution — gain can rewire to real turn COUNTS only; per-program stats stay
   descoped (the writer spec lives in KERNEL-SLIM — owner-only).

## Decisions locked at plan time (owner, 2026-07-07: "follow advises")
- **D1 — board: FIX, not descope.** pr_aggregate gains a real `list` over the real PR store
  (`02-prs.md`: 16 projects have one, 9 with `## PR-` blocks); JSONL-vs-doc shape fixed; loud
  empty-state. Usage history is near-zero, but the fix is one contained PR over real data and the
  menu advertises the surface.
- **D2 — metric pipeline: HONEST DESCOPE via ADR.** No usage recorder exists on the agent-side
  execution path (`tools/run.py` line ~132 is the only `usage.py record` caller and is not how
  programs actually execute). dispatch-stats + gain TOP-PROGRAMS render an explicit "recording not
  wired for agent-side execution" banner instead of plausible zeros. Kernel-protocol per-EXEC
  recording documented in the ADR as the future alternative (kernel edit = owner-only).
- **D3 — restore delegation: HUMAN-HANDOFF.** When the shell gate BLOCKs `git reset --hard` during
  my-axon restore (verdict JSON `{verdict, reason, code}` — verified live), the program renders an
  explicit human-handoff block with the exact commands. The grant's `destructive` allow-list remains
  empty; delegation stays available to the owner later without plan changes.

## Waves
- **A — contract guard (PR-001..002):** output_manifest growth (5→~15 reporting tools) + memory-key
  lint (unguarded-orphan ERROR, config allowlist, baseline). Report-mode only.
- **B — the four CRITICALs (PR-003..006):** session-summary path+digest repair; resume over persisted
  working memory; gain honest rebuild; board rewire (D1).
- **C — safety (PR-007..009):** workspace-backup structured verdict/exit checks on all four shell
  paths + human-handoff (D3) + the two new bugs; my-axon-init data-loss guards; shell-result lint.
- **D — HIGH burn-down (PR-010..015):** menu+snapshot contract; status/stats + drift repoint +
  orphan-tool retirement; undo contract + run-id manifest binding; list-tools; find-program
  excision; axon-docs-gen.
- **E — metric pipeline (PR-016..017):** metrics ADR + starvation banners (D2); loop-contract
  receipts to the canonical ledger, begin→commit.
- **F — closure (PR-018..019):** LOW/doc sweep; mutating-path test conversion (the study's
  could-not-verify list) + register both new lints as blocking crucible gates once baselines are
  empty.

## Constraints honored
reduce-surface (no new top-level tools — both lints extend the existing conformance/lint family;
manifest growth uses the existing mechanism) · tests-with-neurons (every PR ships tests; profile
test-cmd = FULL pytest suite) · plan-atomic-prs (no forward deps; each PR independently mergeable) ·
kernel-floor (zero kernel edits anywhere in the plan; turn-log writer spec left to owner) ·
no-dense-rag (find-program excision deletes the dead semantic-search block, nothing revived) ·
lossless-mandate (menu/snapshot changes carry the snapshot-vs-fallback parity test).

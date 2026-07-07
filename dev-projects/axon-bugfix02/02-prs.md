# PR List — AXON Bugfix 02
Updated: 2026-07-07 (all merged + pushed)  ·  Total PRs: 19  ·  Waves: A contract-guard · B criticals · C safety · D high-burn-down · E metric-pipeline · F closure

## PR-001 — Grow output_manifest.json over the reporting-layer tools
- **Status:** merged
- **Complexity:** M
- **Phase:** wave-a-contract-guard
- **Scope:** tools/output_manifest.json (5 → ~15 tools: axon-state, context, drift, memory, scheduler/queue, cron, auto-audit, goal, igap, dispatch-index, shell, prompt-log, pr-aggregate, docgen, usage), tests validating each manifest entry against the tool's real emitted keys
- **Depends on:** none
- **Why:** the accessor-conformance mechanism already exists and is documented "grow the manifest, never guess" — coverage of 5 tools is why every `.field` dead-read in the findings went unseen; violations surfaced land in the baseline, not as blockers.

## PR-002 — Memory-key reader/writer lint (unguarded-orphan ERROR + allowlist + baseline)
- **Status:** merged
- **Complexity:** L
- **Phase:** wave-a-contract-guard
- **Scope:** tools/program_tool_conformance.py (new check, same family — no new top-level surface), declared L: config-key allowlist file, grandfathered baseline file, tests
- **Depends on:** none
- **Why:** the dominant defect class (C2/C3/C4 + menu/status/stats HIGHs) is RETRIEVE against keys no writer produces; council-verified design: ERROR only on unguarded orphaned reads (71 keys measured live), `W:_*` arg-convention excluded, `RETRIEVE | default` config idiom exempt — 67%-noise naive version explicitly rejected.

## PR-003 — Repair session-summary: path, digest patterns, dead lines
- **Status:** merged
- **Complexity:** M
- **Phase:** wave-b-criticals
- **Scope:** workspace/programs/session-summary.md (+ mechanizable test)
- **Depends on:** none
- **Why:** C3 — `{W:myaxon-log}/entries/` doubles the path (key already ends in /log/entries/) so Steps 2-5 are unreachable every run; the 4 digest FIND_ALL patterns match zero real `[ts] | LEVEL | source | msg` lines; the calculator Σ line is unexecutable; drift read targets the nonexistent drift-log.md.

## PR-004 — Rebuild resume detection over persisted working memory
- **Status:** merged
- **Complexity:** M
- **Phase:** wave-b-criticals
- **Scope:** workspace/programs/resume.md (+ test)
- **Depends on:** none
- **Why:** C4 — the episodic event-name filter matches nothing ever written (real events: checkpoint ×611, session-saved ×313) and field reads target nonexistent columns. Council overturn: `W:` keys persist as files (workspace/memory/working/), so `W:active-phase` IS the resume pointer — read it + working files, use the episodic log only as enrichment. No kernel edit, no writer changes.

## PR-005 — Gain: honest rebuild over data that exists
- **Status:** merged
- **Complexity:** M
- **Phase:** wave-b-criticals
- **Scope:** workspace/programs/gain.md
- **Depends on:** none
- **Why:** C2 — SESSIONS/TOP-PROGRAMS aggregate fields E:session-log rows never carry, and the context-report reads fields `context status` never emits. Rebuild: SESSIONS over real turn-log counts (files exist, verified) + real session-log columns; TOP-PROGRAMS gets the D2 honest-starvation banner; guard the truthy rtk stub; seed or drop W:_gain-period variants. Turn-log writer degeneracy is documented as an owner-side kernel-spec item, out of scope here.

## PR-006 — Board: rewire aggregation to the real PR store (D1)
- **Status:** merged
- **Complexity:** L
- **Phase:** wave-b-criticals
- **Scope:** tools/board.py, tools/pr_aggregate.py (real `list` subcommand over 02-prs.md `## PR-` blocks + `**Status:**` fields across projects), workspace/programs/code-dev-meta-board.md, tests
- **Depends on:** none
- **Why:** C1 — three stacked breakages (missing subcommand → bare except → header-only board exit 0; JSONL-vs-doc shape; `pr-N:` blocks that exist in zero of ~60 projects). Owner locked FIX over descope: real data exists in 9 projects today; loud empty-state replaces the silent one.

## PR-007 — workspace-backup: structured result checks + human-handoff on BLOCK (D3)
- **Status:** merged
- **Complexity:** L
- **Phase:** wave-c-safety
- **Scope:** workspace/programs/workspace-backup.md
- **Depends on:** none
- **Why:** false-success class, all four shell paths: (1) restore-with-.git runs gate-BLOCKED `reset --hard` unchecked → unconditional "✓ restored" — render the D3 human-handoff block off the real `{verdict, reason, code}` JSON; (2) NEW: no-.git restore (clone+rsync+rm -rf) equally unchecked; (3) NEW: PUSH one-liner precedence bug — no-change days short-circuit the push, so committed-but-unpushed state never retries — split into checked steps; (4) substring success-sniffing ("error"/"fatal") replaced by verdict/exit-code checks everywhere. Plus: `skip` unreachable when unconfigured (route order), self-referential ws-path fallback, setup/doc naming drift.

## PR-008 — my-axon-init: close the data-loss windows
- **Status:** merged
- **Complexity:** M
- **Phase:** wave-c-safety
- **Scope:** workspace/programs/my-axon-init.md
- **Depends on:** none
- **Why:** destructive re-run paths verified: `fresh-no-prompt` bypasses the existence guard (line 33) and truncates an existing event log; the interactive prompt has no else so a typo falls through into FRESH writes; the CLONE path skips the FRESH mkdirs so downstream backup writes target nonexistent dirs.

## PR-009 — Shell-result lint: no substring success-sniffing after TOOL(shell)
- **Status:** merged
- **Complexity:** M
- **Phase:** wave-c-safety
- **Scope:** tools/program_tool_conformance.py family (new narrow check), baseline, tests
- **Depends on:** none
- **Why:** cross-cutting pattern 2 (bugfix01's H25, recurred and worsened) — flag success-rendering (`✓ …`) after a TOOL(shell,…) whose result is never checked for verdict/code/exit_code; narrow scope keeps false positives out (legitimate output-grepping stays legal).

## PR-010 — Menu + snapshot contract repair (parity-tested)
- **Status:** merged
- **Complexity:** L
- **Phase:** wave-d-high-burn-down
- **Scope:** workspace/programs/menu.md, tools/axon_state.py, snapshot-vs-fallback parity test
- **Depends on:** PR-001
- **Why:** the menu tells users a guaranteed-failing command (`kv-store set L:` — hard-refused namespace since bugfix01 C9; correct: `memory set --scope L`); `W:ws-queue` has no writer so the queue warning can never fire; `snap.todos_preview` strings break the owner-directed reminder render (`r.text`, miscount 4 vs 8); `workflows.ok`/`audit-7d` type misses kill golden-path lines; footer reads `c.reason` where candidates carry `why`; SELF-IMPROVEMENT panel keys (`L:cron-jobs`, `W:boot-cron-tick`, `W:boot-last-snapshot`) have no writers — render honestly or drop.

## PR-011 — status + stats: real drift source, real queue shape, orphan-tool retirement
- **Status:** merged
- **Complexity:** L
- **Phase:** wave-d-high-burn-down
- **Scope:** workspace/programs/status.md, workspace/programs/stats.md, delete workspace/tools/drift.py (orphaned duplicate; registry points at tools/drift.py which writes working/drift-trace.json)
- **Depends on:** none
- **Why:** both dashboards read `W:queue-data.active` (real shape: `{status,tasks,count}`) and the nonexistent `episodic/drift-log.md` — the health score is structurally blind to drift (pattern 4: the only writer of that file is the orphaned duplicate tool). Plus: cron rows carry no `overdue`; false "Health score saved" print; `workspace/packages/` never exists; dead `memory list --key` call.

## PR-012 — undo: align the rollback contract + run-id-bound manifest
- **Status:** merged
- **Complexity:** M
- **Phase:** wave-d-high-burn-down
- **Scope:** workspace/programs/undo.md, tools/run.py (clear/stamp the manifest), output_manifest entry for memory rollback, tests
- **Depends on:** PR-001
- **Why:** every SUCCESSFUL rollback reports FAILED (undo checks `.ok`/`.value`; memory.py emits `{rolled_back, restored_value, remaining_history}`) — safety-adjacent because state HAS changed while the report says otherwise; the stale manifest (written only on L:-writing runs, never cleared) makes undo after a no-write run roll back an OLDER run — bind the manifest to a run-id and clear on no-write runs; fix double-undo shape reads.

## PR-013 — list-tools: registry honesty
- **Status:** merged
- **Complexity:** S
- **Phase:** wave-d-high-burn-down
- **Scope:** workspace/programs/list-tools.md
- **Depends on:** none
- **Why:** reads `t.status/.name/.purpose` off a list of NAME strings and branches on a "SKIPPED" status REGISTRY.json never contains; the "merged OS+workspace registries" claim is false. Render from REGISTRY.json's real ACTIVE/PLANNED/OPTIONAL statuses.

## PR-014 — find-program: excise the half-deprecated semantic-search block
- **Status:** merged
- **Complexity:** S
- **Phase:** wave-d-high-burn-down
- **Scope:** workspace/programs/find-program.md
- **Depends on:** none
- **Why:** cross-cutting pattern 3 — live consumer over commented-out setters (`W:sem`/`W:has-semantic` undefined; `semantic-search` unregistered anywhere). Delete, don't revive (no-dense-rag constraint). Fix the scan-scope claim (29 OS programs unfindable while PURPOSE says "installed programs") — extend the scan or fix the claim.

## PR-015 — axon-docs-gen: drop the phantom `.compiled` read
- **Status:** merged
- **Complexity:** S
- **Phase:** wave-d-high-burn-down
- **Scope:** workspace/programs/axon-docs-gen.md (+ docgen manifest entry)
- **Depends on:** PR-001
- **Why:** reads `_docgen-result.compiled`, a field docgen never emits — align to the tool's 6 real fields (verified clean in the study).

## PR-016 — Metrics ADR + honest-starvation banners (D2)
- **Status:** merged
- **Complexity:** M
- **Phase:** wave-e-metric-pipeline
- **Scope:** 03-decisions/adr-001-metric-pipeline-descope.md, tools/dispatch_stats.py (explicit missing-input banner instead of plausible zeros; drop the dead saved_tokens overwrite)
- **Depends on:** none
- **Why:** owner-locked D2 — the metric pipeline is starved at the source (no recorder on the agent-side execution path; run.py's usage call is off-path, verified). Plausible-zero reports become explicit "recording not wired for agent-side execution" statements; the kernel-protocol recording alternative is preserved in the ADR as owner-only future work.

## PR-017 — loop-contract: receipts land in the canonical ledger
- **Status:** merged
- **Complexity:** M
- **Phase:** wave-e-metric-pipeline
- **Scope:** tools/loop_contract.py, tests
- **Depends on:** none
- **Why:** `_receipt` passes `--workspace` so receipts target `workspace/state/` while list/recover read the canonical `axon/state/` (sibling tools guard canonical→None; loop_contract doesn't) → 0 rows ever land; begin is never committed so recover() would mark real work ABORTED; `define`'s goal cross-registration is fire-and-forget.

## PR-018 — LOW / doc-honesty sweep
- **Status:** merged
- **Complexity:** M
- **Phase:** wave-f-closure
- **Scope:** line-level fixes across the audited surfaces
- **Depends on:** none
- **Why:** verified LOWs: menu says `todo done <id>` (CLI needs `--id`); constraints docstring names REGISTRY.json (disk: CONSTRAINTS.json); auto-actions `!NORM read-only` banner on a `role: mutator` + HELP citing nonexistent `igap improve`; status "Dispatch 8" counts compiled mirrors vs the real index; duplicate menu probes; vestigial keys/dirs (my-axon/log/turns; `myaxon-backup-setup-skipped.md` reader — PR-007 makes skip reachable, this makes the flag honest); stale synapse counts flagged-not-guessed.

## PR-019 — Mutating-path test conversion + crucible registration
- **Status:** merged
- **Complexity:** L
- **Phase:** wave-f-closure
- **Scope:** tests/ (drive todo add/done, loop-contract define/iterate/commit, constraints add, memory rollback, usage record end-to-end), tools/crucible.json (register PR-002 + PR-009 lints as blocking once baselines are empty)
- **Depends on:** PR-002, PR-009, PR-012, PR-017
- **Why:** converts the study's honest could-not-verify list into verified regression coverage against the POST-fix contracts, and flips both new lints from report-mode to blocking — the ratchet closes (Core Rule 13 + the study's one declared limitation).

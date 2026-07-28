# PR List — AXON Bug-Free 3
Updated: 2026-07-13  ·  Total PRs: 21  ·  waves A–F  ·  ledger IDs cite AUDIT-FINDINGS.md

## PR-001 — Resolve workflow names across both roots
- **Status:** not-started · **Wave:** A · **Complexity:** M · **Findings:** F-C1
- **Scope:** workspace/programs/workflow-run.md, workflow-validate.md, workflow-simulate.md, workflow-edit.md; tools/workflow_run.py (expose `resolve --name`); tests
- **Depends on:** none
- **Why:** all 4 reference workflows unrunnable by name; multiple-code-dev nested dispatch dies at s2.

## PR-002 — Workflow caller contracts: ok/error-count guards, simulate key prefix, validate lint envelope
- **Status:** not-started · **Wave:** A · **Complexity:** M · **Findings:** F-H11, F-M16, below-cap(validate `| ∅`)
- **Scope:** workflow-run.md, workflow-simulate.md, workflow-edit.md, workflow-new.md, workflow-validate.md; tests
- **Depends on:** none
- **Why:** every caller compares a string list to 0; simulate params never arrive; wired lints can vanish on exit-1.

## PR-003 — Codemap arg contract + shadow dispatch + shadow-count closeout
- **Status:** not-started · **Wave:** A · **Complexity:** M · **Findings:** F-H4, F-H5, F-L3
- **Scope:** codemap.md (router passes explicit keys), codemap-new/ask/relations/shadow.md; tests
- **Depends on:** none
- **Why:** golden paths bind the subcommand token as the argument; scan/refresh unreachable; coverage stat wrong.

## PR-004 — Envelope binds: meta.get .value ×8, shell envelopes, obsidian unchanged-path fields
- **Status:** not-started · **Wave:** A · **Complexity:** M · **Findings:** F-H6, F-M8
- **Scope:** code-dev-graphify.md, codemap-*.md (8 sites), codemap-new/shadow shell binds; tools/obsidian_export.py (unchanged path carries notes/edges); tests
- **Depends on:** none
- **Why:** unset-codebase guard can never fire; JSON dicts interpolated as paths; steady-state render undefined.

## PR-005 — graphify-bridge impact: node_ids key, --symbol degraded path, relations call-site
- **Status:** not-started · **Wave:** A · **Complexity:** S · **Findings:** F-H1
- **Scope:** tools/graphify_bridge.py; workspace/programs/codemap-relations.md; tests
- **Depends on:** none
- **Why:** file-blast-radius always empty; the only call-site crashes KeyError against the fail-degrade contract.

## PR-006 — pattern.py: strip inline comments in read_pref
- **Status:** not-started · **Wave:** A · **Complexity:** S · **Findings:** F-H14
- **Scope:** tools/pattern.py; tests
- **Depends on:** none
- **Why:** cluster/top/suggest all crash on the shipped preferences file.

## PR-007 — phase-model read-only reason oracle; code-dev refusal loop stops mutating
- **Status:** not-started · **Wave:** B · **Complexity:** S · **Findings:** F-H2
- **Scope:** tools/phase_model.py (`why`/dry-run read path); workspace/programs/code-dev.md:210-212; tests
- **Depends on:** none
- **Why:** the completion-refusal renderer advances the very ledger it guards.

## PR-008 — doctrine preflight fail-closed on unblessed/uncovered routines
- **Status:** not-started · **Wave:** B · **Complexity:** S · **Findings:** F-H3
- **Scope:** tools/doctrine_preflight.py:129; tests incl. injected-routine case
- **Depends on:** none
- **Why:** an injected never-blessed routine can reach validated:true — the exact attack the manifest exists to stop.

## PR-009 — hr-team refusal pipeline: abort signal + key clears + protocol override + reround unlock
- **Status:** not-started · **Wave:** B · **Complexity:** L (may split at spec) · **Findings:** F-C2(re-graded), F-H15, F-L9
- **Scope:** hr-team.md, hr-team-selector.md, hr-team-convener.md, hr-team-deliberator.md; tests
- **Depends on:** none
- **Why:** a refused (incl. safety) task can convene and seal a council on stale seats; --protocol broken both directions.

## PR-010 — doctrine-node gate: stale-record recovery + hint
- **Status:** not-started · **Wave:** B · **Complexity:** M · **Findings:** F-M1
- **Scope:** tools/shell.py block message, tools/doctrine_run.py (stale/session guard or boot surfacing); tests
- **Depends on:** none
- **Why:** post-handoff the human is write-blocked repo-wide with no hint and no automatic repair.

## PR-011 — drift alignment: record --type compat, TTL-aware check, staleness refresher, remediation text
- **Status:** not-started · **Wave:** C · **Complexity:** L (may split at spec) · **Findings:** F-H10(tool-side), F-H9(mitigation), F-M2, F-M3
- **Scope:** tools/drift.py; cron/boot refresher; menu.md + compiled mirror (lockstep), auto-improve.md, stats.md; tests
- **Depends on:** none
- **Why:** restores the kernel's declared interface mechanically, un-deadlocks auto-improve, makes advice runnable.

## PR-012 — Suggestion calibration: absolute thresholds, footer floor + exclusions, ranker shapes
- **Status:** not-started · **Wave:** C · **Complexity:** M · **Findings:** F-H12, F-M12, F-M13
- **Scope:** orchestrator.md (decide ladder, sideband, signal assembly), tools/anticipate.py footer; tests
- **Depends on:** PR-006
- **Why:** autonomy ladder decorative; footer self-suggests + zero-score stubs; 3 of 11 ranker signals structurally dead.

## PR-013 — Tick shape unification + situate bridge repair
- **Status:** not-started · **Wave:** C · **Complexity:** M · **Findings:** F-M6, F-M7
- **Scope:** orchestrator.md, menu.md (+mirror), OUTPUT-LAYER consumers stay as-is (shape converges); tests
- **Depends on:** none
- **Why:** two writers, two shapes at one key; {turn} unbound; the ⚡ hint feature is inert.

## PR-014 — Reporting batch: session-summary log tree, status queue field, simulate arg
- **Status:** not-started · **Wave:** C · **Complexity:** S · **Findings:** F-H7, F-L1, F-L2
- **Scope:** session-summary.md, status.md, simulate.md; tests
- **Depends on:** none
- **Why:** bugfix02 C3's symptom persists one level up; queue panel renders undefined field; simulate ignores its arg.

## PR-015 — Chat index: reader==writer + append false-success
- **Status:** not-started · **Wave:** D · **Complexity:** M · **Findings:** F-H13(tool-side), below-cap(index append)
- **Scope:** tools/index.py (resolve the store the chat programs write); tests
- **Depends on:** none
- **Why:** boot chat-resume permanently blind; append --type plan lies ok:true.

## PR-016 — Episodic store: compact/show read the real E: log
- **Status:** not-started · **Wave:** D · **Complexity:** S · **Findings:** F-H17
- **Scope:** memory-compact.md, show-memory.md (+status.md episodic line); tests
- **Depends on:** none
- **Why:** the anti-growth program no-ops on the 807-line real log; archive-path self-contradiction.

## PR-017 — agent-memory: honest cross-tier enumeration
- **Status:** not-started · **Wave:** D · **Complexity:** S · **Findings:** F-H18
- **Scope:** tools/agent_memory.py (list/recall use _all_entries for tier=None); tests
- **Depends on:** none
- **Why:** project/program tiers silently dropped while labeled "all" — write-only dead ends.

## PR-018 — Routing/guards: backup subcommand key, MYAXON.md guard, resume exists-check, active-phase convention
- **Status:** not-started · **Wave:** D · **Complexity:** M · **Findings:** F-M9, F-M10, F-M11, F-M15
- **Scope:** workspace-backup.md, my-axon-init.md, resume.md, code-dev.md / tools/self_care.py (convention reconcile); tests
- **Depends on:** none
- **Why:** four incomplete-fix survivals of the prior runs' patches.

## PR-019 — Contract lints: zero-writer-key + envelope-bind (crucible controls) + lint-path-vars kernel scope
- **Status:** not-started · **Wave:** E · **Complexity:** M · **Findings:** F-M4 + prevention (ledger headline 1)
- **Scope:** new tools/memory_key_writer_lint.py + tools/envelope_bind_lint.py (names at spec), REGISTRY.json, crucible register, tests (Core Rule 13); lint_path_vars.py scan-scope
- **Depends on:** waves A–D conceptually (fix before ratchet); hard deps: none — ships with allowlist grandfathering
- **Why:** the two classes = ~14 findings this run; a BLOCK lint retires the class for run 4. reduce-surface justification named.

## PR-020 — Integrity cleanup batch
- **Status:** not-started · **Wave:** E · **Complexity:** S · **Findings:** F-H19, F-L4, F-L5, F-L6, F-L7, F-L8, F-M5
- **Scope:** REGISTRY.json memory entry; tools/axon_state.py (plans regex, pointer source); tools/dispatch_index.py extras; stray root memory/ tree; tools/self_care.py CLI text + verdict surfacing; tests
- **Depends on:** none
- **Why:** small truths: registry verbs, tolerant matchers, honest status surfaces.

## PR-021 — KERNEL SPEC (HUMAN-ONLY handoff — prepared, never self-merged)
- **Status:** not-started · **Wave:** F · **Complexity:** S · **Findings:** F-H8, F-H9, F-H10(kernel text), F-H13(kernel note), below-cap(BOOT:196, plan-new.md)
- **Scope:** spec document + exact patch hunks for axon/KERNEL-SLIM.md, axon/BOOT.md, axon/OUTPUT-LAYER.md, axon/programs/plan-new.md
- **Depends on:** PR-011
- **Why:** kernel floor — owner applies; PR-011 first makes the kernel text change a no-op interface swap.

---
Deferred → 02-prs.deferred.md: quarantined-leads verification (4) · workflow-new preview/convergence/from-desc · cosmetics.

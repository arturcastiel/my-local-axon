# Demands catalog — AXON Polish

> Gap/feature-shaped findings from Phase 1-audit. Phase 2-prioritise will rank by impact × difficulty.
> Naming: `D-DXX-NN` where D = dimension, NN = local sequence.

## Type legend
- **missing-program** — a program users reach for that doesn't exist
- **missing-tool** — a Python tool referenced or implied but absent
- **missing-workflow** — a multi-step flow that's documented but unbuilt
- **missing-doc** — documentation surface that doesn't exist
- **missing-test** — test coverage gap (Core Rule, gate, behavior)
- **missing-enforcer** — kernel claim with no mechanical check
- **UX-gap** — usability gap not tied to a single artifact

## Size legend (rough; refined in Phase 2)
- **S** — < 1 day of focused work
- **M** — 1–3 days
- **L** — 1–2 weeks
- **XL** — multi-week effort or cross-cutting refactor

---

## Missing programs

### D-D5-001 — `program-deprecate` / `program-archive` / `program-rename`
- **dim**: D5 · **size**: M · **type**: missing-program
- **where**: workspace/programs/ (15 DEPRECATED + 9 alias-stub + 3 orphan-stub linger)
- **why**: There is no tested workflow to remove a program. Debt accumulates silently.
- **proposal**: Three programs (or one with subcommands): mark a program deprecated, move to archive/, update REGISTRY + dispatch + compiled outputs + tests in one transaction.

### D-D5-002 — `program-diff` / `program-test` runner
- **dim**: D5 · **size**: M · **type**: missing-program
- **why**: Programs cannot be tested in isolation outside corpus contracts. Regressions like F-D5-001 (dead EXEC targets) land silently.
- **proposal**: Per-program harness — given a program name, lint synapse block, dry-run via simulate, smoke-test all advertised tool calls, check FAIL block render.

### D-D5-003 — `find-program-by-frequency`
- **dim**: D5 · **size**: S · **type**: missing-program / UX-gap
- **where**: find-program.md ignores `tools/usage.py` data
- **why**: Kernel says usage drives suggest; find-program is keyword-only.
- **proposal**: `find-program --by frequency` ranks programs by run count over `--days N`.

### D-D5-004 — `mode-chat` / `mode-build` / `mode-run` / `mode-memory` / `mode-system` / `mode-plan` / `mode-programs` — orphan programs
- **dim**: D5/D1 · **size**: M · **type**: missing-workflow
- **where**: axon/programs/mode-*.md exist but COMMANDS.md never invokes them (F-D1-005)
- **why**: Each was authored as a curated per-mode dashboard. None are reachable. Either wire them up or delete them.
- **proposal**: Decide per program — wire from mode shortcut (recommended for mode-chat which lists active chats) or remove.

### D-D5-005 — `new-chat` / `plan-new` / `list-programs` / `send-report`
- **dim**: D5 · **size**: M · **type**: missing-program
- **where**: Referenced by mode-router/help/quickstart (F-D5-001)
- **why**: Production routing crashes on these.
- **proposal**: Either implement the programs (4 small ones) or rewrite the callers to use existing equivalents (`new-chat` → `chat-input`? `list-programs` → `find-program --all`?).

### D-D5-006 — Replacement for `axon.py code-dev log` dispatch
- **dim**: D6 · **size**: S · **type**: missing-program
- **where**: 2026-05-21 log 12:34:25 — `python3 axon.py code-dev log` returned "Unknown tool"
- **why**: Agent fell back to direct heredoc write. Dispatch routing should handle `axon.py code-dev <subcmd>` consistently OR refuse with a clear error.
- **proposal**: Either implement `code-dev` as an axon.py dispatcher (preferred, matches kernel's CLI binding for `EXEC(program)`) or rewrite docs to use the actual invocation.

### D-D9-001 — `cron-drain` program
- **dim**: D9/D5 · **size**: S · **type**: missing-program
- **where**: cron.py:359 (1 attempted run per tick)
- **why**: Queue never drains for daily-boot user (F-D9-012). Need a way to drain N overdue jobs on demand.
- **proposal**: `cron drain [--max N]` runs up to N overdue jobs respecting timeouts; reports per-job outcomes.

### D-D5-007 — `program-deduplicate` / `cluster-by-desc`
- **dim**: D5 · **size**: M · **type**: missing-program
- **where**: 5 explain, 3 resume, 3 undo, 3 shadow, 5 audit, 20 review, 4 dashboard programs (F-D2-004)
- **why**: Catalog rot accumulates with no audit surface.
- **proposal**: Cluster programs by description embedding/keywords; surface duplicates with proposed canonical winner.

---

## Missing tools

### D-D7-001 — `tools/shell.py` actually existing
- **dim**: D7 · **size**: M · **type**: missing-tool
- **where**: REGISTRY.json declares shell as OPTIONAL with "dispatched by host harness at runtime" — no .py exists (F-D3-001)
- **why**: 88 call sites depend on host harness; kernel boot G-11 depends on shell for git detection. Host fallback is an unsandboxed gate bypass (F-D8-008).
- **proposal**: Either ship `tools/shell.py` with explicit allowlist (git read-only subcommands, `ls`, `find`, `cat`, etc.) and refuse everything else; OR formally split into specific tools (`git-info`, `fs-list`, etc.) with no general shell.

### D-D7-002 — `tools/context.py` host-model awareness
- **dim**: D9/D7 · **size**: S · **type**: missing-tool feature
- **where**: context.py:33 hard-coded 128k limit (F-D9-001)
- **why**: Modern Claude 4.x is 200k; critical gate fires at ~54% of true window.
- **proposal**: Read `L:host-model` from prefs/memory; lookup table for known models; fall back to conservative 128k if unknown.

### D-D7-003 — `tools/checkpoint.py restore`
- **dim**: D9 · **size**: S · **type**: missing-tool feature
- **where**: checkpoint.py has only `--label` (write path); no restore (F-D9-003)
- **why**: PROCESS.md describes RESUME from checkpoint — but no tool reads them.
- **proposal**: `checkpoint restore --label X` or `checkpoint restore --latest` restores W: keys from a labeled snapshot.

### D-D7-004 — `tools/compaction-detect`
- **dim**: D9 · **size**: M · **type**: missing-tool
- **where**: session.py:131-169 only detects PID change; in-process compaction goes undetected (F-D9-004)
- **why**: Compaction is the principal heavy-workflow failure mode. PID heuristic is wrong.
- **proposal**: Detect via L:cognition-frame absence on any non-bootable turn; or via a write-and-check pattern on a session-scoped flag.

### D-D7-005 — `tools/program-lint`
- **dim**: D2/D7 · **size**: M · **type**: missing-tool
- **where**: 47% missing usage, 73% missing outputs, 81% missing example (F-D2-002); 33 programs with duplicate desc lines (F-D5-008); naming/role mismatches (F-D2-015)
- **why**: No mechanical enforcement of program-format conventions.
- **proposal**: `tools/program_lint.py` checks help-block completeness, synapse-block fidelity (role vs body), FAIL block format, deprecation markers; CI gate.

### D-D7-006 — `tools/registry-regen` autotrigger
- **dim**: D3 · **size**: S · **type**: missing-tool feature
- **where**: REGISTRY.json 6-day stale (F-D5-002)
- **why**: Cron has `axon-programs-registry` but it's overdue.
- **proposal**: Pre-commit hook on workspace/programs/*.md regen REGISTRY.json automatically; CI gate fails if disk ≠ registry.

### D-D7-007 — `tools/docs-regen` for "live count" fields
- **dim**: D3 · **size**: M · **type**: missing-tool
- **where**: README/CHANGELOG/Architecture have stale tool counts (84/86/75) and program counts (182/183/372) (F-D3-002, F-D3-009)
- **why**: No auto-regen pipeline for "live count" text.
- **proposal**: Doc partials with `<!-- LIVE-COUNT: tools -->` placeholders; regen tool fills with current registry length; CI verifies.

### D-D9-002 — Real parallel-execution scheduler
- **dim**: D9 · **size**: XL · **type**: missing-tool
- **where**: SPAWN/KILL/PAUSE/RESUME ops are translation-only (F-D9-010); process.py writes lifecycle files but no fork
- **why**: Heavy workflows need parallel sub-programs.
- **proposal**: Subprocess-based runner that EXEC sub-programs in parallel with token budgets, IPC via a small event bus; bookkeeping in processes/active/. Big change — needs design phase.

---

## Missing enforcers (Core Rules + gates without mechanical guards)

### D-D8-001 — Enforcer for Core Rule 1 (read kernel each session)
- **dim**: D8 · **size**: S · **type**: missing-enforcer
- **where**: No predicate checks "kernel read this session"
- **proposal**: Boot-phase check; store last-read-ts on KERNEL-SLIM read; verify gate predicate.

### D-D8-002 — Enforcer for Core Rule 4 (log significant events)
- **dim**: D8 · **size**: S · **type**: missing-enforcer
- **proposal**: Per-program lint — every FAIL/HALT/DONE must have a corresponding LOG call within the program body.

### D-D8-003 — Enforcer for Core Rule 5 (CHECKPOINT before yielding)
- **dim**: D8/D9 · **size**: M · **type**: missing-enforcer
- **where**: Cross-listed with F-D4-008 (workflow-run has no CHECKPOINT)
- **proposal**: Static check that any LOOP body or multi-step program has CHECKPOINT before any QUERY(user) or DONE.

### D-D8-004 — Enforcer for Core Rule 6 (no fabricate tool results)
- **dim**: D8/D6 · **size**: M · **type**: missing-enforcer
- **where**: F-D6-005 documents real bypass (agent wrote heredoc instead of failing fast)
- **proposal**: Output-text lint flags emitted patterns that look like JSON/tool-output without a corresponding TOOL() call this turn.

### D-D8-005 — Enforcer for Core Rule 8 (rule conflict resolution)
- **dim**: D8 · **size**: S · **type**: missing-enforcer
- **proposal**: Static check that programs declaring `requires:` chains have non-conflicting rule priorities.

### D-D8-006 — Enforcer for Core Rule 10 (LANG extend / kernel edit gate)
- **dim**: D8 · **size**: S · **type**: missing-enforcer
- **where**: F-D8-011 (no pre-commit hook on KERNEL-SLIM.md diffs)
- **proposal**: Pre-commit hook: any diff touching axon/KERNEL-SLIM.md must accompany an L:dev-mode session log entry from within the last N hours.

### D-D8-007 — Enforcer for Core Rule 12 (menu always rendered)
- **dim**: D8 · **size**: S · **type**: missing-enforcer
- **where**: F-D3 cross-list; KERNEL-SLIM:73 says "shell crash" but no rule
- **proposal**: Output-text rule — after a boot, the next assistant turn must contain the menu sentinel lines.

### D-D8-008 — Enforcer for active-program interrupt gate
- **dim**: D8/D7 · **size**: M · **type**: missing-enforcer
- **where**: F-D8-004 (gate is doc-only)
- **proposal**: Turn-level check — IF W:active-phase ≠ ∅ AND user input ∉ continuation-cmds AND no K/I/A query was shown, BLOCK.

### D-D8-009 — Enforcer for cognition-language gate (real check, not regex token)
- **dim**: D8/D6 · **size**: M · **type**: missing-enforcer
- **where**: F-D6-001 (current regex passes if ANY LANG token appears)
- **proposal**: Token-ratio threshold (e.g. ≥X% of reasoning lines must parse as LANG ops); or AST-based check on a tagged reasoning section.

### D-D8-010 — Enforcer for identity-mode lock
- **dim**: D8 · **size**: S · **type**: missing-enforcer
- **where**: F-D8-002 (inference-mode-locked has no enforcer)
- **proposal**: Memory.py rejects STORE(L:inference-mode, *) when L:inference-mode-locked = true AND L:dev-mode ≠ true.

### D-D8-011 — Enforcer for no-queue rule
- **dim**: D8 · **size**: M · **type**: missing-enforcer
- **where**: F-D8-010 (no detection of "executing a previously-blocked command without re-statement")
- **proposal**: Session log a "gate-refused" event tag; any subsequent identical command without an intervening user re-statement is flagged.

### D-D8-012 — Enforcer for override-attempt detection
- **dim**: D8 · **size**: M · **type**: missing-enforcer
- **where**: F-D6-007
- **proposal**: Detection patterns for user phrases like "ignore the rule", "bypass dev-mode", combined with Core Rule keyword proximity → LOG + render the standard override-refused block.

### D-D8-013 — Enforcer for identity-gate dispatch
- **dim**: D8 · **size**: S · **type**: missing-enforcer
- **where**: F-D8-003 (no Python guard inspects user input for identity questions)
- **proposal**: Pre-EXEC input-pattern check; if matches identity triggers, force-EXEC identity.md before any other dispatch.

### D-D8-014 — Enforcer for L:cognition-frame value spell-check
- **dim**: D8 · **size**: S · **type**: missing-enforcer
- **where**: F-D8-014
- **proposal**: Boot + every-N-turns ASSERT(L:cognition-frame ≡ "AXON-OS") with exact string match; warn on near-match drift.

### D-D8-015 — Enforcer for shell-tool path inspection
- **dim**: D8 · **size**: M · **type**: missing-enforcer
- **where**: F-D8-008 (TOOL(shell, "cp x axon/y") bypasses R9)
- **proposal**: R9 should AST-parse shell commands and re-apply path check to write targets; or shell tool itself must call check-write before executing.

### D-D8-016 — Enforcer for menu-truncation detection
- **dim**: D8 · **size**: S · **type**: missing-enforcer
- **where**: F-D3 — Core Rule 12 says full render required
- **proposal**: Compare emitted menu against expected section sentinel set; HALT + re-render on missing sections.

### D-D8-017 — Symlink/path-resolution hardening for R9
- **dim**: D8 · **size**: S · **type**: missing-enforcer feature
- **where**: F-D8-001 (4 bypass vectors)
- **proposal**: r9_axon_write._is_axon_path uses os.path.realpath; enforce.py uses realpath; CI test cases for symlink, absolute, traversal, shell-tool target.

### D-D8-021 — Session-heartbeat / silence-window detector  ·  NEW 2026-05-21 (iteration 2)
- **dim**: D8 · **size**: S · **type**: missing-enforcer
- **where**: new tool `tools/session_heartbeat.py` + `my-axon/log/drift-events.jsonl` event stream
- **why**: copilot-deviation-study P5 — flag silence windows > N min during active sessions. Catches stalled programs, paused-but-not-checkpointed states, mid-program drift to non-program work.
- **proposal**: Tail event log; if no event for > N min while `W:active-phase ≠ ∅` (excluding `:done`/`:failed`), emit a `kind=session-silence` event + surface in menu OS STATE.
- **source**: copilot-deviation-study P5.

### D-D8-022 — Per-turn `EXEC` execution-verification cross-check  ·  NEW 2026-05-21 (iteration 2)
- **dim**: D8 · **size**: M · **type**: missing-enforcer
- **where**: kernel response-gate (KERNEL-SLIM.md:79-122) + new tool
- **why**: F-D6-005b — every `EXEC(program)` op should produce a corresponding `bash("python3 axon.py run …")` subprocess invocation; absence = silent prose simulation.
- **proposal**: Reasoning-trace and tool-call ledger cross-check at turn end. For each `EXEC(X)` recorded in W:reasoning-trace, assert at least one matching subprocess invocation. Mismatch → log `kind=exec-simulation` drift event.
- **source**: firing-dag-missing seed + copilot-deviation-study P4.
- **routes to**: axon-copilot-anchor (PR-CA-102 axon-reanchor is the natural fix surface)

### D-D6-005a — Per-file write-attribution sentinel  ·  NEW 2026-05-21 (iteration 2)
- **dim**: D6/D8 · **size**: M · **type**: missing-enforcer + missing-tool
- **where**: every program-managed file under `my-axon/dev-projects/*/`; new tool + pre-commit hook
- **why**: F-D6-005a — only proposal that mechanically blocks the heredoc bypass even when `tools/shell.py` is sandboxed.
- **proposal**: (1) Header sentinel `<!-- AXON-MANAGED: writer=<program-name>; do-not-write-without-program -->` on files that are program-owned. (2) Pre-commit hook + edit-time wrapper: read sentinel, verify WRITE/APPEND originates from the named program (or owner-mode user). (3) Migrate existing program-owned files to ship the sentinel.
- **source**: copilot-deviation-study P3.
- **pairs with**: ADR-001 (sandboxed shell.py) — neither closes F-D6-005 in isolation; both needed.

---

## Missing tests

### D-D8-018 — Behavioral test for identity-gate trigger
- **dim**: D8 · **size**: S · **type**: missing-test
- **where**: F-D8-009 (current tests only check identity.md structure)
- **proposal**: Test fixture that pipes 20 identity-query strings to a dispatcher mock; asserts each routes to identity.md.

### D-D8-019 — Bypass-vector tests for Rule 9
- **dim**: D8 · **size**: S · **type**: missing-test
- **where**: F-D8-006
- **proposal**: 4 new tests in test_r9_axon_write.py: symlink, absolute, traversal, shell tool.

### D-D8-020 — Override-attempt halt message format test
- **dim**: D8 · **size**: S · **type**: missing-test
- **where**: F-D8-015

### D-D8-021 — Workspace-backup perimeter test
- **dim**: D8 · **size**: S · **type**: missing-test
- **where**: F-D8-013 (test exists but is one-sided)
- **proposal**: Assert arbitrary `git push` outside my-axon/ triggers HALT.

### D-D9-003 — Heavy-workflow stress fixture
- **dim**: D9 · **size**: L · **type**: missing-test
- **where**: No existing test simulates 200-turn session
- **proposal**: Fixture that drives a synthetic 200-turn session through orchestrator + workflow-run, asserts CHECKPOINT density, W: key budget, context-pressure gate timing, resume correctness.

---

## Missing workflows

### D-D4-001 — Hybrid execution mode implementation
- **dim**: D4 · **size**: L · **type**: missing-workflow
- **where**: F-D4-004 (schema-only)
- **proposal**: Real fixed-skeleton + adaptive-sub-segment runtime in workflow-run; orchestrator branch for hybrid.

### D-D4-002 — End-to-end run for adaptive-free-text
- **dim**: D4 · **size**: M · **type**: missing-workflow
- **where**: F-D4-003 (current design loops infinitely)
- **proposal**: Redesign s1/s2/s3 so s1 is invoked by orchestrator (not as workflow step), s2 mutates goal state, s3 exits cleanly.

### D-D4-003 — Workflow-run ↔ orchestrator integration
- **dim**: D4 · **size**: M · **type**: missing-workflow
- **where**: F-D4-002 (they don't call each other)
- **proposal**: workflow-run delegates each step to orchestrator so the PR-112 suggestion footer fires.

### D-D5-008 — End-to-end "polish a finding" workflow
- **dim**: D5 · **size**: M · **type**: missing-workflow
- **where**: Currently the axon-polish project produces findings; no canonical flow takes a finding → PR spec → fix → test → doc update
- **proposal**: `polish-finding F-XXX` program that reads the flaw, generates a PR spec stub, opens a branch, scaffolds the test, drafts the doc anchor.

### D-D9-004 — Real session-resume contract
- **dim**: D9 · **size**: M · **type**: missing-workflow
- **where**: F-D9-002 (workflow-run never sets active-phase), F-D9-003 (no restore), F-D9-013 (silent truncation), F-D9-014 (resume reads markdown)
- **proposal**: Schema-versioned snapshot; checkpoint.py restore; workflow-run + every multi-step program writes active-phase per step; resume reads structured log; tests guard all four.

---

## Missing docs

### D-D2-001 — Authoritative PROGRAMS-INDEX matching live catalog
- **dim**: D2/D3 · **size**: S · **type**: missing-doc
- **where**: F-D2-011 (current index lists 7 orphan modes, omits 130+ live programs)
- **proposal**: Auto-generated index from REGISTRY.json + workspace/programs/, grouped by domain; replaces hand-written one.

### D-D2-002 — HOWTO.md rewrite (current grammar doesn't match COMMANDS.md)
- **dim**: D2 · **size**: M · **type**: missing-doc
- **where**: F-D2-012
- **proposal**: Regenerate HOWTO from current command grammar + actual program listings; remove "AXON is a folder of instruction files. There is no code" stale paragraph.

### D-D7-008 — Per-tool doc cards (promised in CHANGELOG)
- **dim**: D7/D3 · **size**: M · **type**: missing-doc
- **where**: F-D3-012 (CHANGELOG mentions `axon/tools/<tool>.md` cards; directory doesn't exist)
- **proposal**: Generate one doc card per tool from registry + docstring inspection; ship 79 cards.

### D-D1-001 — Quickstart of canonical length, no contradictions
- **dim**: D1 · **size**: S · **type**: missing-doc
- **where**: F-D1-002 + F-D1-013
- **proposal**: Delete the 5-step half. Resumable 7-step tour, with each step under 30 lines, FAQ/menu/quickstart all agree on length.

### D-D1-002 — Authoring-guide updated for current idioms
- **dim**: D1/D2 · **size**: S · **type**: missing-doc
- **where**: F-D2-013 (teaches deprecated semantic-search as recommended pattern)
- **proposal**: Rewrite to current idioms; deprecate the TOOL?-fallback pattern that references removed tools.

---

## UX gaps

### D-D1-003 — Slim menu mode
- **dim**: D1 · **size**: S · **type**: UX-gap
- **where**: F-D1-007 (580+ lines / 13 sections)
- **proposal**: `menu --slim` renders only the active mode's primary verbs + 5 most-used commands; current full menu becomes `menu --full`. Core Rule 12 stays satisfied (the slim view IS the full default render for non-DEV users).

### D-D1-004 — Self-explanatory mode hints in menu
- **dim**: D1 · **size**: S · **type**: UX-gap
- **where**: F-D1-008 (RUN/PROGRAMS/BUILD overlap or are dead)
- **proposal**: Either consolidate to fewer modes OR give each a non-overlapping verb-set with a single representative command.

### D-D1-005 — "What changed" digest on boot
- **dim**: D1/D9 · **size**: S · **type**: UX-gap
- **where**: Boot offers resume but no "since last session" summary beyond first line of L:last-session-summary
- **proposal**: One-line summary of (a) commits in dev tree since last boot, (b) cron jobs that ran, (c) new findings logged. Stays under 5 lines.

### D-D2-018 — Standardized FAIL renderer
- **dim**: D2 · **size**: M · **type**: UX-gap
- **where**: F-D2-001 (94 programs don't render the standard block)
- **proposal**: A `tools/fail_render.py` (or AXON-LANG shorthand) that takes (program, reason, cause?, fix?) and emits the standard ━━━ block. Programs invoke it from FAIL hooks.

### D-D2-019 — Better "unknown subcommand" message
- **dim**: D2 · **size**: S · **type**: UX-gap
- **where**: F-D2-010 (7 sub-dispatchers say "unknown subcommand: {sub}")
- **proposal**: Standardize: "Unknown subcommand '{sub}'. Available: {list}. Did you mean '{closest}'?"

### D-D7-009 — Tool `surface` taxonomy: agent / cli / both
- **dim**: D7 · **size**: M · **type**: UX-gap
- **where**: F-D7-004 (43% of registered tools never called from programs)
- **proposal**: Add `surface: agent | cli | both` field to REGISTRY.json schema; split rendering in `list-tools`; rule that programs may only TOOL() call agent/both tools.

### D-D9-005 — Surfaced cron breaker alerts in OS STATE
- **dim**: D9 · **size**: S · **type**: UX-gap
- **where**: F-D9-020 (breaker is silent — only JSONL event)
- **proposal**: Menu OS STATE panel already has "Cron breaker" line; route breaker events to it; add `Auto-actions` style unread counter.

### D-D9-006 — Auto-prune W: keys at idle
- **dim**: D9 · **size**: M · **type**: UX-gap
- **where**: F-D9-007 (W: 25-key budget not enforced)
- **proposal**: On every DONE / phase boundary, mark stale W: keys (not touched within N turns); a tick later, prune. Kernel mandate becomes runtime behavior.

---

## Cross-cutting (touch many dims)

### D-XC-001 — Single "live count" pipeline for docs
- **dim**: D3 · **size**: M · **type**: cross-cutting
- **why**: Tool counts wrong in 3 places, program counts wrong in many, ranker-signal count wrong in CHANGELOG (F-D3-002, F-D3-009, F-D3-004)
- **proposal**: Docs use `{{tool_count}}` style placeholders; pre-commit regen replaces with live values from registries.

### D-XC-002 — Catalog grooming pass (one-shot project, ~XL)
- **dim**: D5 · **size**: XL · **type**: cross-cutting
- **why**: 53 autogen-stubs, 16 alias-stubs, 6 DEPRECATED, 3 orphan-stubs, 4 PLANNED-only library-dev, 154 quarantined compileds. Roughly 30% of catalog is dead-or-half-alive.
- **proposal**: Sweep — for each: convert to working program, mark explicitly archived (move to archive/), or delete. End state: every shipping program has populated help blocks, accurate synapse metadata, passing simulate, and registered status.

### D-XC-003 — Synapse metadata re-inference with manual override
- **dim**: D5 · **size**: L · **type**: cross-cutting
- **where**: F-D5-005 (96% auto-inferred and often wrong)
- **proposal**: New `synapse-infer-v2` that bases on actual program body (RETRIEVE/STORE counts, EXEC targets) rather than text pattern; manual override fields preserved; CI rejects "obvious wrong" inferences (renderer programs labeled mutator, etc.).

### D-XC-004 — Tool API normalization
- **dim**: D7 · **size**: L · **type**: cross-cutting
- **where**: F-D7-006 (40% lack --workspace), F-D7-009 (10 emit no JSON), F-D7-010 (verb naming inconsistent)
- **proposal**: Tool template + lint that enforces `--workspace`, `--json`, consistent subparser verbs, exit-code conventions.

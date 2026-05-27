# Study — 1-audit

> Codebase under study: `/home/arturcastiel/projects/axon-development/axon` (v3.7.0, axon-synapse)
> Approach: 9 audit dimensions, each surveyed independently, findings accumulated in
> `_flaws.md` (bug-shaped) and `_demands.md` (gap/feature-shaped).
> Phase 1 is **read-only against the codebase**.

---

## Audit framework

For each dimension below, fill in four sections as findings emerge:

```
### Inputs       ← files / programs / tools to inspect
### Method       ← how to study (grep, run, simulate, diff vs. docs)
### Findings     ← observations (one bullet per concrete issue)
### Severity     ← per finding: BLOCKER / MAJOR / MINOR / NIT
```

Findings graduate to `_flaws.md` (bugs) or `_demands.md` (missing-features)
once written up. Severity governs Phase 2 ranking.

---

## D1 — Usability  (modes, commands, output layer, menu)

### Inputs
- `axon/COMMANDS.md`, `workspace/programs/menu.md`, `workspace/programs/mode-*.md`
- `axon/OUTPUT-LAYER.md`, `workspace/preferences/output*.md`
- First-run experience: `quickstart`, `faq`, `glossary`

### Method
- New-user simulation: boot fresh, run quickstart, count friction points.
- Common-task simulation: 10 typical tasks (compile, run, plan, code-dev study, …).
- Menu legibility: read menu cold; how many items are self-explanatory?

### Findings
_(populate during study)_

### Severity
_(populate during study)_

---

## D2 — Interface  (naming, help quality, error messages)

### Inputs
- Program names (`workspace/programs/*.md`) — duplication, prefix consistency
- Help blocks (`# usage:`, `# inputs:`, `# outputs:`) — coverage + freshness
- `explain` output for every program; FAIL blocks (Plain English Problem/Cause/Fix)

### Method
- Lint pass: every program must have populated `# usage:` and `# outputs:`.
- Diff `explain` output against actual program behavior for 20 random programs.
- Catalog every FAIL render — confirm Plain English Problem line.

### Findings
_(populate)_

### Severity
_(populate)_

---

## D3 — Behavior  (docs vs. code drift)

### Inputs
- `CHANGELOG.md`, `workspace/AXON-DOCS-*.md`, `axon/HOWTO.md`
- Cross-check: tool registry (`tools/REGISTRY.json`) vs. actual `tools/*.py`
- Kernel rules in `axon/KERNEL-SLIM.md` vs. their enforcers in `tools/`

### Method
- Doc-drift sweep: for each doc page, sample 5 claims, verify in code.
- Tool registry diff: ACTIVE in registry but missing from disk; on disk but unregistered.
- Rule enforcer audit: Core Rules 1–12, find the test that guards each.

### Findings
_(populate)_

### Severity
_(populate)_

---

## D4 — Workflows  (fixed, adaptive, hybrid)

### Inputs
- `workspace/programs/orchestrator.md` (PR-111)
- `workspace/programs/workflow-*.md`
- Adaptive: `adaptive-free-text` reference workflow
- Synapse ranker: `tools/synapse_suggest.py`

### Method
- Run each reference workflow end-to-end; record halts, dead-ends, missing transitions.
- Adaptive: 10 free-text inputs, log which program the orchestrator routes to,
  confidence score, whether the route was correct.
- Hybrid: at least 2 mixed-mode flows.

### Findings
_(populate)_

### Severity
_(populate)_

---

## D5 — Programs  (missing, redundant, broken)

### Inputs
- `workspace/programs/REGISTRY.json`
- `tools/usage.py` — frequency data
- `tools/synapse-validate` — neuron-contract conformance

### Method
- Inventory: total program count; how many ACTIVE vs. ARCHIVED.
- Redundancy: cluster by description — find pairs/triples doing similar things.
- Brokenness: simulate each top-20-by-usage program; record failures.
- Missing: from D1–D4 findings, what programs the user reached for but couldn't find.

### Findings
_(populate)_

### Severity
_(populate)_

---

## D6 — Errors  (bug census, halt patterns, fabrication risk)

### Inputs
- Log archives: `workspace/log/entries/*.md`, `my-axon/log/entries/*.md`
- `workspace/log/igap/*.md` — places AXON had to guess
- `tools/drift.py` history
- `tools/auto-audit` output

### Method
- Grep all logs for `ERROR|CRIT|FAIL`. Cluster by source.
- Igap top-10: which gaps appear most often? Each gap is a candidate finding.
- Drift score history: when did drift first appear; what was the trigger?
- Fabrication risk: list every place a program could fabricate a tool result
  (no `TOOL(…)` actually called).

### Findings
_(populate)_

### Severity
_(populate)_

---

## D7 — Tools  (registry vs. actual; missing; promotion candidates)

### Inputs
- `tools/REGISTRY.json` (source of truth)
- `tools/*.py` (actual)
- `tools/health.py` output
- Calls from `axon/KERNEL-SLIM.md` and from programs

### Method
- 3-way diff: registry ↔ disk ↔ kernel/program references.
- Status audit: every PLANNED → still planned, or quietly built?
- OPTIONAL → ACTIVE candidates: tools used in ≥3 programs but marked OPTIONAL.
- Missing tools: ops referenced in programs that route nowhere.

### Findings
_(populate)_

### Severity
_(populate)_

---

## D8 — Compliance  (Core Rules coverage, gate evasion)

### Inputs
- `axon/KERNEL-SLIM.md` Core Rules 1–12, compliance enforcement gates
- `tools/verify.py` — R3, R7, R9, R_TOOL_EXISTS, R_W_BUDGET, R_NO_PLANNED_TOOLS
- `tests/` — every rule should have at least one guarding test

### Method
- Per-rule audit: rule → enforcer → test. Mark missing links.
- Gate evasion: can the rule be bypassed via creative routing (e.g. Core Rule 9
  bypass through symlink, file:// path, or workspace/ trampoline)?
- "Override attempt" pattern: are explicit user overrides actually halted?

### Findings
_(populate)_

### Severity
_(populate)_

---

## D9 — Heavy-workflow gaps  (long sessions, parallelism, context pressure)

### Inputs
- `axon/KERNEL-SLIM.md` § Context pressure gate
- `tools/context.py`
- `tools/session-save.py`, `resume` program
- Multi-program scenarios: chained EXECs, mid-program interrupts, cron preemption

### Method
- Simulate a 200-turn session; record context pressure curve; identify breakpoints.
- Mid-program interrupt drill: hit the active-program gate from 10 different
  program states; confirm checkpoint+resume correctness.
- Parallel programs: SPAWN N background programs, observe scheduler behavior.
- Compaction recovery: force compaction; verify L:cognition-frame survives.

### Findings
_(populate)_

### Severity
_(populate)_

---

## Cross-cutting trackers
- **Doc-quality** : every finding that's a doc problem also goes into D3.
- **Test coverage** : every finding that's "no test" goes into D8.
- **Heavy-workflow** : every finding that only manifests at scale goes into D9
  even if first observed elsewhere.

---

## Workflow

```
For each dimension D1..D9:
  1. Read inputs.
  2. Apply method.
  3. Capture findings in this file.
  4. Move bug-shaped findings → ../../_flaws.md
  5. Move gap-shaped findings → ../../_demands.md
  6. Mark dimension done in §Status below.

When all 9 done:
  → code-dev plan (advances to Phase 2-prioritise scaffolding)
```

## Status — Run 1 (2026-05-21, parallel 4-agent dispatch)

| Dim | Title                | State    | Findings count | Severity mix                            |
|-----|----------------------|----------|----------------|-----------------------------------------|
| D1  | Usability            | DONE     | 16             | 5 BLOCKER · 4 MAJOR · 6 MINOR · 1 NIT  |
| D2  | Interface            | DONE     | 17             | 0 BLOCKER · 7 MAJOR · 8 MINOR · 2 NIT  |
| D3  | Behavior drift       | DONE     | 17             | 0 BLOCKER · 7 MAJOR · 10 MINOR          |
| D4  | Workflows            | DONE     | 16             | 3 BLOCKER · 8 MAJOR · 5 MINOR           |
| D5  | Programs             | DONE     | 8 + cross-refs | 2 BLOCKER · 4 MAJOR · 2 MINOR           |
| D6  | Errors / bugs        | DONE     | 15             | 1 BLOCKER · 7 MAJOR · 7 MINOR           |
| D7  | Tools                | DONE     | 12             | 1 BLOCKER · 7 MAJOR · 4 MINOR           |
| D8  | Compliance           | DONE     | 15             | 4 BLOCKER · 7 MAJOR · 4 MINOR           |
| D9  | Heavy-workflow gaps  | DONE     | 21             | 4 BLOCKER · 13 MAJOR · 4 MINOR          |

**Total bug findings**: ~137 in `_flaws.md` (some cross-listed across dims).
**Total demand findings**: ~48 in `_demands.md` (missing programs/tools/workflows/docs/enforcers/tests/UX).

## Findings — populated

All 9 dimensions surveyed. Detailed observations live in:
- `../../../axon-polish/_flaws.md` — bug-shaped findings, grouped by severity
- `../../../axon-polish/_demands.md` — gap/missing-feature findings, grouped by type

The findings sections below (D1.Findings .. D9.Findings) are intentionally not duplicated here — single source of truth is the two catalog files. Use the cross-reference IDs (F-DXX-NN / D-DXX-NN) to navigate.

## Synthesis — top systemic pain points

1. **Mainline composition path (PR-111) is broken end-to-end.** orchestrator.md crashes in fixed mode on first invocation (F-D4-001), mixes string vs dict candidates (F-D4-011), and is never reached from workflow-run (F-D4-002). The advertised PR-112 suggestion footer therefore never fires during actual workflow execution. The headline of v3.7.0 doesn't work as documented.

2. **Mechanical compliance surface is thin and porous.** Only 5 of 12 Core Rules have enforcers. R3 is a near-no-op regex; R7 is downgraded to WARN; R9 lacks symlink/path-resolution and shell-tool coverage; R_REASONING_TRACE ships disabled by default. Inference-mode-lock, override-attempt, no-queue, menu-truncation, identity-dispatch, cognition-frame value-check — all pure documentation. Real-world drift (logged 3× today) confirms the gates don't hold.

3. **`TOOL(shell, …)` is a master gate-evasion vector.** `tools/shell.py` doesn't exist; declared OPTIONAL; fulfilled by host harness at runtime. 88 call sites across 33 programs. Once an agent emits `TOOL(shell, "cp x axon/y")`, all axon/-protection collapses.

4. **Catalog rot exceeds governance capacity.** 118 of 183 programs are missing from REGISTRY.json. 53 autogen-stubs, 16 alias-stubs, 6 DEPRECATED, 3 orphan-stubs, 4 PLANNED-only library-dev programs, 154 quarantined compileds. No `program-deprecate` / `program-archive` workflow exists. ~30% of catalog is dead-or-half-alive.

5. **No real interrupt/resume across compaction.** workflow-run never sets `W:active-phase` per step (F-D9-002); checkpoint.py is snapshot-only with no restore (F-D9-003); session_save drops values >2KB silently (F-D9-013); schema-versions are written-not-read (F-D9-008); compaction-recovery fires only on PID mismatch (F-D9-004). A workflow halted at step 5 of 10 cannot reliably resume — direct blocker to heavy-workflow goal.

6. **Context-pressure model miscalibrated for Claude 4.x.** Hard-coded 128k limit ignores L:host-model (F-D9-001); accumulator never resets between sessions (F-D9-005); critical-pressure HALT itself produces enough tokens to potentially exceed headroom (F-D9-006).

7. **First-impression files are duplicated head-to-tail.** menu.md, quickstart.md, help.md each ship with two complete copies of themselves in one file (F-D1-001/002/003). The three files a new user touches first all render twice.

8. **Discoverability collapses under name overlap.** explain×5, resume×3, undo×3, shadow×3, audit×5, review×20, status×4 dashboards. `find-program shadow` returns 3 programs all called shadow with no canonical signal.

9. **Promise/Implementation gap in primary commands.** `explain X` and `simulate X` silently double-prompt because the dispatcher doesn't set the expected W: keys. Modes 1–7 don't actually invoke their named mode programs (mode-chat / mode-build / etc. exist as orphans). Mode-4 MEMORY search is wired entirely through a deprecated-and-commented branch.

10. **FAIL block standard exists but is never followed.** Kernel mandates Problem/Cause/Fix/Suggested-next; 100% of audited FAILs use single-string shorthand. The kernel-promised "loud, logged, recoverable" failure path is half-implemented across 94 programs.

## Recommended next phase entry points
- Phase 2-prioritise should rank the 5 BLOCKER + 4 BLOCKER + 4 BLOCKER (compliance/heavy-workflow/workflows) findings first — these are the gates to "heavy-workflow ready".
- Cross-cutting demands (D-XC-001 docs pipeline, D-XC-002 catalog grooming, D-XC-003 synapse re-inference, D-XC-004 tool API normalization) need separate ranking — they unblock many findings at once.
- D-D7-001 (real `tools/shell.py`) and D-D8-017 (R9 hardening) are paired: neither helps in isolation.

---

## Prior-work cross-reference (added 2026-05-21, run 2)

Surveyed 14 prior AXON-themed projects in `/mnt/c/projects/axon/my-axon/dev-projects/`.
All target prod v1.1.4; axon-polish targets dev v3.7.0.
Full matrix and conflict surfacing: see `../../_prior-work-crossref.md`.

### Re-graded systemic pain points (after prior-work integration)

| # | Pain point | Was | Now | Driver of change |
|---|---|---|---|---|
| 1 | PR-111 composition broken | B+ | A- | No prior project resolved the workflow-run↔orchestrator boundary, but loop_receipt substrate from axon-autoimprove is available for transition logging. Design decision remains open but mechanism is half-built. |
| 2 | 5 of 12 Core Rules have enforcers | A | A+ | axon-tests already shipped 2 of the 7 missing enforcer tests (identity behavioral + R9 bypass) — only 5 enforcers remain, fully sized. |
| 3 | TOOL(shell) gate evasion | B | A | axon-cleanup PR-120 codified the evasion (registered as OPTIONAL/host + patched audit to silence warning) AND axon-master named first-class shell.py as F-06 backlog. Prior conflict IS the design landscape. |
| 4 | Catalog rot ~30% dead-or-half-alive | A- | A (track-only) | axon-cleanup Wave 1 already shipped 126 autopatched programs + 4 stubs + dep cleanup. ~70% of rot resolved; remaining tail = 9 alias-stubs + 6 DEPRECATED + 3 orphan-stubs + 154 quarantined compileds. |
| 5 | No real interrupt/resume across compaction | A | A | Unchanged. axon-master PR-9/PR-15 designed in detail but not built. axon-cleanup PR-105 only fixed PID semantics. |
| 6 | Context-pressure miscalibrated | A+ | A (align with master) | axon-master W3-01 (cache_control doc) + W3-03 (ai-tokenizer switch) already designed. axon-polish should align rather than re-spec. |
| 7 | menu/quickstart/help duplicated | A | A (align with master) | axon-master TOP-12 F-07 lazy-load already on the list. |
| 8 | Discoverability under name overlap | B- | A- | 3-component design template emerges: binding-table (from CD-201/CC-201) for canonical-winner declarations + static-lint slot (R_PROGRAM_NAME_UNIQUE in coh-v2) + deprecate-via-comment (cleanup precedent). |
| 9 | Promise/Impl gap (explain/simulate/modes) | A- | A | F-D1-004 routes cleanly to axon-wiring-gaps' reader/writer join method; axon-user has 19 findings filed for the UX side. |
| 10 | FAIL block ignored by 94 programs | A- | A- | Active conflict: cleanup's autopatch ships 6 canonical pieces WITHOUT FAIL — codifies the violation. Decision needed before fix. |

**Overall plan-readiness grade: A → A+** (was A-)
- Substrate exists for 7 of the 10 findings (loop-receipt, autopatch script, deprecate-via-comment, persona corpus, binding table, static-lint framework, op→CLI table pattern).
- 2 retired demands (axon-tests already shipped).
- 5 routed demands (to wiring-gaps / autoimprove / user).
- 3 active conflicts surface for explicit user decision.
- 1 truly design-open item remains: workflow-run↔orchestrator boundary.

### Active conflicts requiring user decision
1. **TOOL(shell) gate**: keep host-dispatched (cleanup PR-120) OR sandboxed shell.py with allowlist (master F-06) OR split into specific tools (git-info, fs-list, etc.).
2. **FAIL canonical-pieces**: extend autopatch to mandate FAIL block + bulk re-autopatch OR accept divergence from kernel spec.
3. **Catalog deprecation policy**: trust comment-based deprecation forever OR commit to hard-delete sweep (master rename waves) gated on dev-mode + user authorization.

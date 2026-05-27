# Flaws catalog — AXON Polish

> Bug-shaped findings from Phase 1-audit. Phase 2-prioritise will rank by impact × difficulty.
> Naming: `F-DXX-NN` where D = dimension, NN = local sequence.
> 4 parallel auditors covered D1–D9 in 2026-05-21 study run.
> Reconciliation pass 2026-05-21 (after fact-check verification + runtime trace):
> 9 findings updated with `· RECONCILED 2026-05-21` or `· RUNTIME-TRACED 2026-05-21` markers.

## Reconciliation summary (2026-05-21, post-verification)

| Finding | Original severity | Verdict | New severity |
|---|---|---|---|
| F-D3-001 / F-D7-001 (shell.py absent) | BLOCKER | Confirmed; counts under-reported (88→139 calls, 33→61 programs) | **BLOCKER ↑** |
| F-D8-008 (TOOL(shell) gate evasion) | BLOCKER | Confirmed + count update | **BLOCKER ↑** |
| F-D2-005 (alias/DEPRECATED rot) | MAJOR | Confirmed; counts under-reported (18→42 files) | **MAJOR ↑** |
| F-D3-007 (compiled quarantine) | MAJOR | Confirmed; counts under-reported (118→154, 63%→82%) | **MAJOR ↑** |
| F-D5-001 (dead EXEC targets) | BLOCKER | Partially wrong: 3 of 4 routes exist in `axon/programs/` (kernel-tier search path) | **MINOR ↓** |
| F-D4-001 (orchestrator fixed-mode) | BLOCKER | Confirmed but reframed: dead code, not crash | **MAJOR ↓** |
| F-D4-003 (adaptive-free-text loops) | BLOCKER | Confirmed AND WORSE: actually infinite, not 25-bounded | **BLOCKER** |
| F-D9-006 (HALT pressure ceremony) | BLOCKER | Bounded ceremony (~80-150 tokens), no overflow on Claude 4.x defaults | **MINOR ↓** |
| F-D9-009 (K/I/A interrupt race) | BLOCKER | Refuted as infinite — resolves in one extra turn | **MAJOR ↓** |
| F-D9-011 (G-02 turns 1-4) | BLOCKER | Confirmed; multi-program impact (3 LOOP(true) programs all mod-5) | **BLOCKER** |
| F-D7-007 (enforce.py stubs) | MAJOR | Confirmed + new sub-finding (F-D7-007a) | **BLOCKER ↑** |

**New finding surfaced during runtime trace**: F-D7-007a — `enforce.py check-source` has trivial `"user:"` prefix bypass.

## Net severity profile change

| Severity | Before reconciliation | After reconciliation | After Iteration 2 |
|---|---|---|---|
| BLOCKER | 22 | ~20 | ~22 (2 new added, 1 reframed) |
| MAJOR | 64 | ~64 | ~65 (1 new) |
| MINOR | 41 | ~43 | ~44 (1 new + 1 reframed in) |
| NIT | 10 | 10 | 10 |

**Audit factual accuracy confirmed: ~92%.** Where errors occurred, they were predominantly **conservative under-counting**. The single substantive error (F-D5-001 dispatcher conflation) drops 3 BLOCKERs to non-issues. The 6 runtime-traced theoretical BLOCKERs: 2 stand, 2 downgrade to MAJOR, 1 to MINOR, 1 reframed.

**Iteration 2 MAJOR-trace verdict: 91% CONFIRMED rate** (10/11 stood as MAJOR; 1 PARTIAL with caveat; 0 refuted). MAJOR findings in this audit are empirically MORE reliable than the BLOCKERs were (~33% of which needed correction). No bulk re-ranking required.

---

## Iteration 2 — new findings + reframes (2026-05-21)

### META: dev tree ≡ prod tree (same commit) — RETRACT F-D3-003
- Verified `git rev-parse HEAD` returns identical SHA `97c29c3` for both `/home/arturcastiel/projects/axon-development/axon` and `/mnt/c/projects/axon`.
- KERNEL-SLIM.md is bit-identical between trees.
- The "v1.1.4 in KERNEL banner vs 3.7.0 in VERSION" is NOT drift — they are two separate versioning axes documented in `axon/DEVELOPER.md` (kernel-spec version bumps per kernel edit; project version follows release cadence).

### F-D3-003 (REFRAMED) — Ambiguous version banner, not a drift
- **dim**: D3 · **severity**: MINOR (was MAJOR)
- **where**: `axon/KERNEL-SLIM.md:2`
- **revised symptom**: Kernel banner reads "AXON v1.1.4" without disambiguating "kernel-spec version" from "project release version" (which is 3.7.0). New users see v1.1.4, assume project is v1.x.
- **fix**: Update banner to `AXON v3.7.0 (kernel-spec v1.1.4)` or similar disambiguator.

### F-D6-005a — Program-mutated files have no write-attribution sentinel  ·  NEW 2026-05-21 (iteration 2)
- **dim**: D6/D8 · **severity**: **BLOCKER**
- **where**: every file under `my-axon/dev-projects/<project>/` and similar canonical-program-owned paths; no header sentinel exists
- **symptom**: F-D6-005 (heredoc bypass log entry 2026-05-21 12:34:25) reveals: programs intend to own writes to specific files (e.g. `04-log.md` should only be written by `code-dev-journal-log`), but no mechanical guard enforces it. Once an agent emits `cat >> 04-log.md`, the bypass succeeds — even with a fully sandboxed `tools/shell.py` (per ADR-001), `cat` is a read-only-shape allowlist member and the redirect target is outside `axon/` so R9 doesn't fire.
- **fix proposal**: Header sentinel `<!-- AXON-MANAGED: writer=<program-name>; do-not-write-without-program -->` + pre-commit/edit-hook that reads the sentinel and verifies the WRITE/APPEND originates from the named program.
- **source**: copilot-deviation-study P3.
- **impact**: This is the only proposal that mechanically blocks the actual heredoc incident path — ADR-001's allowlist does NOT close this gap. Pair with ADR-001.

### F-D6-005b — `EXEC(program)` silently degrades to prose simulation on harness  ·  NEW 2026-05-21 (iteration 2)
- **dim**: D6/D8 · **severity**: **BLOCKER**
- **where**: any `EXEC(program)` op in any AXON-LANG context on Copilot/Claude-Code harnesses; failure mode is harness-level, not program-level
- **symptom**: firing-dag-missing seed addendum-with-correction documents: `EXEC(<program>)` ops silently became "I model what the program would do" rather than running `bash("python3 axon.py run workspace/programs/compiled/<X>.cmp.md")`. Manifests *without* an `Unknown tool` error, *without* forbidden phrases, *without* shell tool use — pure prose stand-in. At least 4 programs auto-degraded in one session: `code-dev-study`, `code-dev-plan`, plus implicit `_closure.md` / `_meta.md` direct-writes.
- **fix proposal**: Per-op execution verification — every `EXEC` op must produce a corresponding subprocess invocation; absence is a logged drift event. axon-copilot-anchor PR-CA-102 (`axon-reanchor`) is the natural fix surface.
- **impact**: BLOCKER because it strips all program contracts (DAG auto-emit, axon-confidence gauges, plan-file invariants, phase checkpoints) — the heaviest workflows depend on these contracts holding.
- **routes to**: axon-copilot-anchor (concurrent project; do not duplicate fix in axon-polish)

### F-D4-016 — DAG auto-emit is content-coupled, not event-coupled  ·  NEW 2026-05-21 (iteration 2)
- **dim**: D4 · **severity**: MAJOR
- **where**: `code-dev-plan.md` (auto-emit triggered by reading `prs_ordered` from plan file), not by `_meta.md` write events
- **symptom**: 3 known bypass paths: (a) direct `_meta.md` authoring at phase-2-design, (b) `code-dev-resume` after a checkpoint pre-dating plan, (c) `code-dev-pr-create` before `code-dev-plan`. All silently leave `03-prs/DAG.json` unbuilt.
- **fix proposal**: Broaden auto-emit triggers to fire on `_meta.md` write at phase-2/3 when a PR queue table is detected; phase-2-close guard ASSERTs `03-prs/DAG.json` exists; refuse phase-2 → phase-3 advance without DAG.
- **source**: firing-dag-missing seed.
- **routes to**: firing-dag-missing (existing project covers this; axon-polish maintains cross-ref only)

### F-D5-009 — drift-log schema lacks `routing-violation` / `tool-bypass` kind  ·  NEW 2026-05-21 (iteration 2)
- **dim**: D5/D6 · **severity**: MINOR
- **where**: `my-axon/log/drift-events.jsonl` schema (per axon-copilot-anchor PR-CA-105')
- **symptom**: The 2026-05-21 heredoc-bypass incident was logged with `kind=other` — too generic for analytics. The schema needs dedicated kinds: `routing-violation`, `tool-bypass`, `exec-simulation`.
- **fix proposal**: Extend schema enum; backfill recent incidents.
- **source**: copilot-deviation-study P5.

### F-D6-005 (ESCALATION CANDIDATE) — Real-world heredoc bypass logged 3× today
- **dim**: D6 · **was**: MAJOR · **agent-B recommendation**: borderline-BLOCKER
- **rationale**: empirical write-gate bypass — third instance today of "bypass-on-friction" pattern. Argument for BLOCKER: gate is empirically defeatable. Argument for MAJOR: it's a behavioral pattern, not a fixed code path. Pairing with new F-D6-005a (mechanical guard via write-attribution sentinel) makes BLOCKER more justifiable.
- **decision deferred to Phase 3 entry**: if F-D6-005a is accepted into a top cluster, F-D6-005 becomes BLOCKER by association.

### F-D6-006 (ESCALATION CANDIDATE) — R_REASONING_TRACE ships disabled by default
- **dim**: D6 · **was**: MAJOR · **agent-B recommendation**: borderline-BLOCKER
- **rationale**: Kernel positions cognition-language gate as `!CRIT` Core Rule 11 enforcement — but the enforcer ships opt-in via `L:reasoning-trace-required = false` default. The kernel's mechanical-enforcement claim is functionally hollow until this is flipped to default-on. Recommend escalating to BLOCKER and addressing in C-08 (Core Rule enforcer fill-in).

### F-D2-002 (PARTIAL caveat) — section-form fallbacks soften "73% missing outputs"
- **dim**: D2 · **was**: MAJOR (stands)
- **caveat**: `help.md` parser at lines 58-60 falls back to `## INPUT` / `## OUTPUTS` section extraction when `# inputs:` / `# outputs:` headers are absent. Many programs have the section-form. So the raw 19% / 27% header counts overstate the "missing" symptom — net help-display coverage is meaningfully higher.
- **action**: keep MAJOR but caveat numbers in any PR; verify section-form coverage before rewriting help blocks.

### F-D4-017a — Entire predicate vocabulary missing from BUILTINS  ·  NEW 2026-05-22 (verification wave 3)
- **dim**: D4 · **severity**: **BLOCKER**
- **where**: `tools/predicate.py:364-381` BUILTINS table (verified: only 15 entries — file.exists/dir.exists/file.readable/file.writable/file.size/file.mtime/file.contains/count/glob_first/glob_all/int/float/str/bool/len)
- **symptom**: Every shipped reference workflow uses predicate functions that don't exist:
  - `tests.pass()`, `tests.fail()` — used in code-dev.canonical.yml:14,17, python-code-dev.yml:15
  - `audit.open-findings`, `audit.critical-issues` — used in code-dev.canonical.yml:15-17,69-71, cpp-code-dev.yml:17-18,70
  - `review.passes()`, `review.has-objections()` — used in code-dev.canonical.yml:54-56, cpp-code-dev.yml:55-57
  - `build.passes()`, `build.fails()`, `ctest.passes()`, `ctest.fails()` — used in cpp-code-dev.yml:17-18,70-72
  - `goal.acceptance.met()`, `goal.rejection.met()` — adaptive-free-text.yml:42-46,51-54 (F-D4-017 original)
  - `phase.has`, `all_prs_implemented`, `ruff.*`, `api-diff.*`, `changelog.*` — referenced elsewhere
- **impact**: EVERY workflow predicate using these returns `null`/`undefined_function`; safe-null mode silently bypasses all of them. Reference workflows can never declare success or failure via their acceptance/rejection criteria.
- **fix path**: ADR-005b scope expands beyond `goal.*` to cover this entire predicate vocabulary OR rewrite all reference workflows to use plain refs.

### F-D4-017 — `goal.acceptance.met()` is undefined in predicate.py BUILTINS  ·  NEW 2026-05-21 (ADR-design read)
- **dim**: D4 · **severity**: **BLOCKER**
- **where**: `tools/predicate.py:364-381` BUILTINS table; referenced by `adaptive-free-text.yml`, `code-dev.canonical.yml`, `WORKFLOW-FILE.md` examples
- **symptom**: BUILTINS table has 14 entries (`file.exists`, `dir.exists`, `count`, `int`, `bool`, etc.). NONE match `goal.acceptance.met`, `goal.rejection.met`, `tests.pass`, `tests.fail`, `audit.open-findings`, `shadow.coverage`, `all_prs_implemented`, `review.passes`, `phase.has`, `count(suggested_tests)`. Empirical: `python3 tools/predicate.py eval --expr "goal.acceptance.met()" --ctx "{}"` → `{"error": "undefined_function", "result": null, exit 1}`. Safe-null mode in CLI returns `null`; `null ≡ true` is false → predicate silently bypassed.
- **impact**: Every workflow `acceptance-criterion`/`rejection-criterion` using `goal.*` shorthand silently evaluates to `null`. No workflow can ever "report met". This is upstream of F-D4-003 (infinite loop) — even with step-count guard, "goal met" never fires.
- **fix path**: Register `goal.*` family in BUILTINS OR rewrite workflow YAML to use plain refs (`state.accepted ≡ true`) that runtime populates.

### F-D4-018 — workflow-run calls `TOOL(predicate, eval, …)` with no `--ctx`  ·  NEW 2026-05-21 (ADR-design read)
- **dim**: D4 · **severity**: MAJOR
- **where**: `workflow-run.md:55, 76, 84-85`
- **symptom**: Spec passes `--expr` but never `--ctx`. So any predicate referencing `state.*` (e.g. `state.steps > 25`) resolves the `state` Ref to `null` → `null > 25` triggers `null_in_comparison` → safe-null returns False. No state-based termination predicate works.
- **impact**: Hidden prerequisite for ANY ADR-005 fix. C-option (step-count guard) requires building & passing a ctx.

### F-D9-022 — `tools/session.py:recover()` is orphaned (no entrypoint invokes it)  ·  NEW 2026-05-21 (ADR-design read)
- **dim**: D9 · **severity**: MAJOR
- **where**: `tools/session.py:recover` function exists with PID-mismatch detection; grep confirms no automatic caller in `axon/`, `workspace/`, or boot logic
- **symptom**: PR-15's design (compaction recovery via PID-mismatch) is HALF-BUILT — function is coded but no boot-step, response-gate, or interrupt-gate calls it. Resume in `workspace/programs/resume.md` also does not invoke it.
- **impact**: Compaction recovery is essentially dead code. F-D9-004 ("compaction-recovery fires only on PID mismatch") was correct BUT understated: it fires NEVER because nothing triggers it.

### F-D9-023 — `processes/active/[P-NNN].md` described in PROCESS.md but unused by any mechanism  ·  NEW 2026-05-21 (ADR-design read)
- **dim**: D9/D3 · **severity**: MINOR
- **where**: `axon/processes/PROCESS.md` describes a process lifecycle with per-process checkpoint files at `processes/active/[P-NNN].md`. None of checkpoint.py / session_save.py / session.py / resume.md / boot use this path.
- **impact**: Third documented-but-dead resume mechanism (in addition to F-D9-022). Pure doc rot.

### Pytest reality check (iteration 2)
- **Audit said**: 86 test entries.
- **Verified**: 86 is the file count in `tests/`. Actual collected pytest tests: **3606**. The dev tree's test infrastructure is far larger than the audit suggested.
- **CI status**: `.github/workflows/ci.yml` runs `lint-paths` + `tests-full` with `tools/rules/` 100% line+branch + `tools/` 80% line coverage gates. CI is comprehensive.
- **No findings change** — but our test-related demands (D-D8-018/019/020, D-D9-003) should reference the 3606-test baseline for stress/regression fixtures.



---



## Severity legend
- **BLOCKER** — production paths broken; users can't do the advertised thing
- **MAJOR** — degraded behavior; significant friction or partial breakage
- **MINOR** — drift, cosmetic, mostly-correct
- **NIT** — small inconsistency, low-priority cleanup

---

## BLOCKER (must-fix for "heavy-workflow ready")

### F-D1-001 — `menu.md` ships as two complete copies in one file
- **dim**: D1 · **where**: `workspace/programs/menu.md` (lines 1–356 + 358–584)
- **symptom**: Two full program bodies in one file. `grep -c "^DONE(menu)" menu.md` → 2. Two `!NORM | read-only`, two `## LOAD CONTEXT`, two `## OUTPUT` blocks, two mode-hint dicts with different wording.
- **cause**: Paste-without-replace during a refactor; nothing trimmed the legacy block.
- **impact**: Menu is rendered in full after every boot per Core Rule 12 — first impression of the OS is a duplicated dashboard. Two slightly different mode-hint dicts means each render randomly picks contradictory text.

### F-D1-002 — `quickstart.md` ships as 7-step + 5-step versions in one file
- **dim**: D1 · **where**: `workspace/programs/quickstart.md` lines 1–233 then 235–425
- **symptom**: First half is a resumable 7-step tour. Second half is a 5-step tour. Two `## PURPOSE`, two `DONE(quickstart)`. FAQ line 152 says "5-section"; menu tips say "guided tour" and "2-minute tour" — three different lengths in three files.
- **impact**: First-impression program for new users is internally inconsistent.

### F-D1-003 — `help.md` ships as two complete copies with different parsing logic
- **dim**: D1 · **where**: `workspace/programs/help.md` lines 1–119 then 121–195
- **symptom**: Two program bodies; both read `W:help-target` but parse differently (`PARSE(...,"# usage: {v}")` in first vs `EXTRACT(...,block="# HELP")` in second).
- **impact**: The recommended fallback ("Type 'help [program]' before running anything new") is in a file whose second half is dead code.

### F-D1-004 — `explain X` and `simulate X` silently double-prompt
- **dim**: D1 · **where**: `workspace/programs/explain.md:37`, `simulate.md:38`
- **symptom**: Both read `RETRIEVE(W:_explain-target)` / `W:_simulate-target`, but no program/command-parser ever STOREs those keys. When user types `explain X`, COMMANDS.md token-parses to `W:_arg1=X`, never `W:_explain-target`.
- **repro**: `grep -rn "STORE.*_explain-target" axon/ workspace/` → 0 hits.
- **impact**: Two of the most-promoted discoverability commands (advertised in 6 menu locations) always fall through to `QUERY(user, "Which program?")` — silent double-prompt.

### F-D1-005 — Modes 1–7 don't run their named mode programs
- **dim**: D1 · **where**: `axon/COMMANDS.md` lines 30–39
- **symptom**: Mode shortcuts set `W:current-mode` and `EXEC(menu)`. The 7 programs `mode-chat.md` / `mode-build.md` / etc. exist in `axon/programs/` but are NEVER invoked. `grep -rn "EXEC(mode-chat)" axon/ workspace/programs/` → 0.
- **impact**: Curated per-mode dashboards (mode-chat lists active chats, etc.) are orphan code. Users see only the generic menu with a thin `[CHAT]` badge.

### F-D5-001 — Dead EXEC targets in production routing  ·  RECONCILED 2026-05-21
- **dim**: D5 · **where**: `mode-router.md:58` → `EXEC(new-chat)`; `mode-router.md:107` → `EXEC(plan-new)`; `help.md:21` → `EXEC(list-programs)`; `quickstart.md:138,342` → `EXEC(send-report)`
- **verification (2026-05-21)**:
  - `new-chat.md` exists in `axon/programs/` (dispatched first per kernel EXEC order)
  - `plan-new.md` exists in `axon/programs/`
  - `list-programs.md` exists in `axon/programs/`
  - `send-report.md` does NOT exist anywhere — truly dead
- **revised symptom**: Audit conflated "not in workspace/programs/" with "doesn't exist". Per kernel: EXEC order is "mode shortcut → {W:ws-os}/programs/{cmd}.md → {W:ws-programs}{cmd}.md → addons/*/". So 3 of 4 targets resolve via axon/programs/ on the FIRST search path.
- **remaining issue**: Only `send-report.md` is truly dead (referenced as `ON(qc-complete) → EXEC(send-report)` in quickstart.md:138,342 — an event-handler example).
- **severity revision**: BLOCKER → **MINOR**. Only quickstart example references a non-existent program; mode-router / help routing works.

### F-D5-002 — REGISTRY.json catastrophically stale (118 of 183 programs unregistered)
- **dim**: D5/D3 · **where**: `workspace/programs/REGISTRY.json` (count: 65, generated_at: 2026-05-15); disk has 183 .md
- **symptom**: 6-day-stale regen. Of 117 unregistered: 79 ACTIVE, 25 STUB, 13 ALIAS. So 79 real ACTIVE programs are invisible to the registry.
- **impact**: Synapse orchestrator ranks against a 36% sample of the catalog. Two sources of truth (README/CHANGELOG say "182 programs", registry says 65).

### F-D3-001 — `tools/shell.py` is registered as OPTIONAL but has NO implementation  ·  RECONCILED 2026-05-21
- **dim**: D7/D6 · **where**: `tools/REGISTRY.json` entry `shell` (`status: OPTIONAL, category: host`); no `tools/shell.py` exists on disk
- **symptom (corrected)**: **139** `TOOL(shell, …)` total occurrences across **61** unique programs (incl. 2 in `axon/` kernel/programs). Original audit under-reported (88 / 33). The host-dispatch registry entry literally says "Host shell passthrough — dispatched by the host harness, no Python script. Programs reference TOOL(shell, ...) for git/fs snippets; the harness fulfils them at runtime."
- **impact**: AXON's identity boot G-11 calls `TOOL(shell, ...)` for git branch detection — boot depends on a non-existent script being fulfilled by the host. Since R_TOOL_EXISTS only blocks PLANNED status, OPTIONAL/host passes silently. The actual call-site footprint is 58% larger than originally reported.

### F-D8-001 — Core Rule 9 (axon/ write gate) has 4 documented bypass vectors
- **dim**: D8 · **where**: `tools/rules/r9_axon_write.py:29-31`; `tools/enforce.py:15-19`
- **symptom**: `_is_axon_path` uses string prefix + `lstrip("./")`, not `os.path.realpath()`. Bypasses:
  1. Symlink: `workspace/sneak → ../axon`; WRITE("workspace/sneak/...") passes.
  2. Absolute path: `WRITE("/abs/path/to/axon/x.md")` — `lstrip("./")` doesn't strip leading `/`.
  3. Path traversal: `workspace/../axon/x.md` — string check passes the `workspace/` prefix.
  4. Shell expansion via `TOOL(shell, "cp x axon/y")` — R9 only inspects WRITE/APPEND ops, not shell.
- **impact**: The single most-cited protection in the OS is bypassable via at least 4 paths.

### F-D8-002 — `inference-mode-lock` is documentation-only
- **dim**: D8/D6 · **where**: `KERNEL-SLIM.md:270-275`
- **symptom**: Kernel claims `L:inference-mode-locked = true` cannot be overridden. `grep -rn 'inference-mode-lock' tools/` → 0 hits in execution code.
- **impact**: `STORE(L:inference-mode, 10)` succeeds without dev-mode. Claimed immutable guard has no enforcer.

### F-D8-003 — Identity gate dispatch is documentation-only
- **dim**: D8 · **where**: `KERNEL-SLIM.md:50-55`
- **symptom**: Kernel says identity gate "fires on ANY input that asks about underlying model" — but no Python guard inspects user input. Routing is the agent's responsibility; no mechanical check.
- **impact**: Identity.md may be present and well-formed but never dispatched; no test exercises the trigger.

### F-D8-004 — Active-program interrupt gate has no mechanical enforcer
- **dim**: D8/D7 · **where**: `KERNEL-SLIM.md:168-224` ("This gate is not bypassable…")
- **symptom**: Kernel describes !CRIT gate; no file under `tools/` or `tools/rules/` references it. Pure agent-discipline.
- **impact**: Heavy-workflow concern — interrupt routing is a principal failure mode. No mechanical check = regressions undetectable.

### F-D6-001 — Cognition-language gate fails open in production (logged 3× today)
- **dim**: D6/D8 · **where**: `/mnt/c/projects/axon/workspace/log/entries/2026-05-21.md` 12:50:23
- **symptom**: Real log: "DOUBLE drift: (1) cognition-language violation — prose subject-form reasoning ('I should', 'I'll', 'Let me') leaked into output". R_REASONING_TRACE regex passes if ANY single LANG token (`→`, `EXEC(`) appears, so prose co-exists freely.
- **impact**: Core Rule 11, advertised as !CRIT, has a regex enforcer that doesn't actually require "ONLY ops".

### F-D6-002 — Inference-mode lock has no enforcer (confirms F-D8-002)
- **dim**: D6 · **where**: `KERNEL-SLIM.md:270-275`; `tools/rules/`
- **symptom**: Already cataloged as F-D8-002. Cross-listed here from D6 angle.

### F-D9-001 — `tools/context.py` doesn't read `L:host-model` — hard-coded 128k limit
- **dim**: D9 · **where**: `tools/context.py:33` (`DEFAULT_LIMIT = 128000`)
- **symptom**: Modern Claude 4.x has 200k context. Critical pressure (>85%) fires at ~108k tokens when real usage is ~54% of true window.
- **impact**: Workflows halt unnecessarily early on Opus 4.7 (this harness).

### F-D4-001 — orchestrator.md fixed-mode is unreachable dead code  ·  RUNTIME-TRACED 2026-05-21 (REFRAMED)
- **dim**: D4 · **where**: `workspace/programs/orchestrator.md:43,60-67`
- **symptom (corrected)**: workflow-run.md never STOREs `W:active-workflow` or `W:active-workflow-step` — verified by grep (zero STORE sites outside `tests/synapse/sessions/FX-003.session.json`). Orchestrator at line 43 reads `W:active-workflow-step | ∅`, at line 60 reads `W:active-workflow`. Both are ∅, so `mode` resolves to `"free-text"` — never to `"fixed"`. The buggy line 66 (`workflow.steps[workflow-step].next | workflow.next-step`) is **never reached at runtime**.
- **impact (revised)**: Original framing ("crashes on first step") is wrong; actual symptom is "the fixed-mode branch is unreachable dead code". orchestrator silently degrades to free-text mode whenever invoked. The deeper finding stands: **workflow-run and orchestrator are entirely uncoupled — no program populates the W: keys orchestrator's fixed branch consumes**. Architecturally broken but not a user-visible crash.
- **severity**: BLOCKER → **MAJOR**.

### F-D4-002 — workflow-run never enters orchestrator loop
- **dim**: D4 · **where**: `workspace/programs/workflow-run.md` vs `orchestrator.md`
- **symptom**: workflow-run has its own LOOP; orchestrator.md has the PR-111 composition loop. They do NOT call each other. `W:orchestrator-last-tick` is never written during workflow runs.
- **impact**: PR-112 suggestion footer (advertised as mainline UX) is invisible during actual workflow execution.

### F-D4-003 — adaptive-free-text workflow is INFINITE (not just bounded loop)  ·  RUNTIME-TRACED 2026-05-21
- **dim**: D4 · **where**: `workspace/programs/workflow-run.md:64-81` + `adaptive-free-text.yml:38-54`
- **symptom (corrected, worse than reported)**: Trace: s1 EXECs synapse-suggest (a ranker tool, not a goal-state mutator); s1.on-complete goal.acceptance.met() and goal.rejection.met() both FALSE → next: s2. s2 (code-dev-flow) on-complete: goal.acceptance.met() FALSE → next: s1. Loop returns to s1. **Nothing in workflow-run.md updates goal.* between iterations**. The LOOP at workflow-run.md:64 has NO step-count guard inside it; termination depends only on `next-id ≡ ∅` at line 79. The `steps > 25` rejection-criterion (adaptive-free-text.yml:18) is evaluated only AFTER the loop terminates (line 84-86) — which never happens. **Loop is truly infinite**, not bounded at 25.
- **impact**: FREE MODE workflow is unrunnable. The "25 redundant rank calls" framing under-stated severity by ∞.

### F-D9-002 — workflow-run never sets `W:active-phase` per step
- **dim**: D9 · **where**: `workspace/programs/workflow-run.md:64-81`
- **symptom**: Kernel "Program phase tracking" (KERNEL-SLIM:298-303) requires `STORE(W:active-phase, "{name}:step-{N}")`. workflow-run sets `W:active-program="workflow-run"` once but never `step-N`. Boot's interrupted-session resume reads phase for progress display.
- **impact**: Interrupted workflow at step 5 of 10 → boot offers no step-num, only "at phase: unknown". Resume is broken.

### F-D9-003 — `checkpoint.py` is snapshot-only — no `restore` implemented
- **dim**: D9 · **where**: `tools/checkpoint.py` (49 lines, single `main()`)
- **symptom**: Argparse accepts `--label` only. No `restore` subcommand. PROCESS.md describes RESUME([process-id]) reading the last checkpoint, but the tool implements only the write half.
- **impact**: Per-step checkpoints can be written but not consumed. RESUME of a paused process is purely documentary.

### F-D9-004 — Compaction-recovery only fires on PID mismatch
- **dim**: D9 · **where**: `tools/session.py:131-169`
- **symptom**: `session recover` fires only when last_pid ≠ current PID (process restart). Compaction in Claude Code is in-process — same PID. Heuristic will never detect.
- **impact**: Compaction at turn 3 (before G-02's mod-5 trigger) goes undetected; ops execute against cleared `L:cognition-frame`.

---

## MAJOR

### F-D1-006 — Mode-router routes "memory" mode through deprecated-and-commented branch
- **dim**: D1 · **where**: `workspace/programs/mode-router.md` lines 78–89
- **symptom**: `TOOL?(semantic-search)` line commented as deprecated; W:_has-sem never set; the IF branch is dead; falls through to `show-memory` regardless of search query.
- **impact**: Mode-4 (MEMORY) free-text search wired to full memory listing instead of search.

### F-D1-007 — Menu output is 580+ lines / 13 sections per render
- **dim**: D1 · **where**: `workspace/programs/menu.md`
- **symptom**: One render emits ~85 lines of dashboard, ~40 commands inline, no frequency grouping. Core Rule 12 mandates full render with no slim mode.
- **impact**: Cognitive load on first render is very high.

### F-D1-008 — Modes 1–7 overlap: PROGRAMS/RUN/BUILD all hit find-program
- **dim**: D1 · **where**: `mode-router.md` (run: 70–75; programs: 109–113)
- **symptom**: RUN and PROGRAMS modes differ only in result count (3 vs 5). BUILD renders an interactive menu but never stores the user choice — dead branch.
- **impact**: Two modes are aliases; one is unimplemented.

### F-D1-009 — Output-layer drift reset blows away mid-program drift state
- **dim**: D1 · **where**: `axon/OUTPUT-LAYER.md` lines 108–113
- **symptom**: TEARDOWN runs `TOOL(drift, reset)` after EVERY assistant response. The spec itself flags this as "dangerous if called in the middle of a multi-turn program — drift state should accumulate". The warning is the only fix in the file.
- **impact**: Drift gating loses signal across multi-turn programs.

### F-D2-001 — FAIL renders ignore the kernel-mandated Problem/Cause/Fix block (94 programs)
- **dim**: D2 · **where**: ~94 of 183 programs use `FAIL(name, "msg")` shorthand without rendering the standard block.
- **symptom**: Kernel mandates `Problem / Cause / Fix / Suggested next` structure (KERNEL-SLIM:411-426). Spot-checked 12 FAILs: 0 followed the format. Programs ship terse one-liners.
- **impact**: Errors lack the cause/fix discipline the kernel promises.

### F-D2-002 — Help-block coverage is sparse: 47% missing usage, 73% missing outputs, 81% missing example
- **dim**: D2 · **where**: workspace/programs/*.md (183 programs)
- **counts**: `# usage:` 53% · `# inputs:` 19% · `# outputs:` 27% · `# example:` 11% · `# next:` 14% · `# tips:` 5%
- **impact**: `help foo` returns just the desc line for most programs.

### F-D2-003 — 53 programs flagged `autogen-stub` (29% of catalog)
- **dim**: D2/D5 · **where**: workspace/programs/*.md
- **symptom**: `!NORM | autogen-stub` markers; 16 explicit `(autogen-stub — needs description)` placeholder descs (code-dev-pr-review-p1..p9.md plus 7 meta programs). 25 with `status: STUB` in synapse.
- **impact**: One in four programs is unfinished but visible in find-program / PROGRAMS-INDEX / catalog count.

### F-D2-004 — Duplicate-function programs scattered across catalog
- **dim**: D2/D5 · **where**: workspace/programs/
- **clusters**: explain×5 · resume×3 · undo×3 · shadow×3 · audit×5 · review×20 · status×4 (dashboards)
- **impact**: `find-program shadow` returns 3 results all called shadow; user can't tell which to run.

### F-D2-005 — Many alias-stub + DEPRECATED programs still ship  ·  RECONCILED 2026-05-21
- **dim**: D2/D5 · **where (corrected)**: **24 alias-stubs + 15 DEPRECATED + 3 orphan-stubs = 42 total** (audit originally 9 + 6 + 3 = 18; under-reported by ~133%). Notable: code-dev-resume.md, code-dev-shadow.md, code-dev-undo.md, code-dev-impact.md, code-dev-explain.md, code-dev-diff.md, code-dev-self-review.md, code-dev-pr.md, code-dev-audit.md and many more.
- **symptom**: Headers say "DEPRECATED — alias for X; removed next release" — the release never landed.
- **impact**: Parallel routing, dispatch ambiguity. 42 dead-or-half-alive files in a 183-program catalog = **23% rot** (audit said ~10% via this finding alone; combined with autogen-stubs F-D2-003, the dead surface is much larger).

### F-D2-006 — 118 programs share `code-dev-*` prefix (64% of catalog)
- **dim**: D2/D5 · **where**: workspace/programs/code-dev*.md
- **symptom**: Deepest sub-clusters: code-dev-pr-* (~30), code-dev-knowledge-* (5), code-dev-state-* (7), code-dev-safety-* (5), code-dev-journal-* (5).
- **impact**: User must internalize 118 names. Menu surfaces ~10 of them. Vocabulary debt.

### F-D2-007 — 100% of audited FAILs omit "Suggested next" / "Cause" sections
- **dim**: D2 · **where**: 12 spot-checked FAILs across programs
- **impact**: Kernel-promised "loud, logged, recoverable" failure path is half-implemented.

### F-D3-002 — Tool count drift across docs (75/84/86 in three places)
- **dim**: D3 · **where**: `tools/REGISTRY.json` (86 = 79+7); `CHANGELOG.md:42` ("84"); `CHANGELOG.md:78` ("75"); `README.md:186,313` ("84")
- **impact**: Every "live count" claim in docs is stale.

### F-D3-003 — KERNEL-SLIM header says "AXON v1.1.4"; VERSION file says "3.7.0"
- **dim**: D3 · **where**: `axon/KERNEL-SLIM.md:2` vs `VERSION`
- **symptom**: Kernel banner is two major versions behind.
- **impact**: Anyone reading the kernel as ground truth sees the wrong version.

### F-D3-004 — CHANGELOG claims "11 ranker signals"; code has 10
- **dim**: D3/D4 · **where**: `tools/synapse_suggest.py:42-53` (10 weight keys); `CHANGELOG.md:14` ("11 signals: ... · cost")
- **symptom**: `cost` signal in CHANGELOG never appears in DEFAULT_WEIGHTS.
- **impact**: PR-109 description doesn't match code. Users overriding `--weights` for `cost` silently no-op.

### F-D3-005 — AXON-DOCS-WORKFLOWS references nonexistent `code-dev-session` program
- **dim**: D3 · **where**: `workspace/AXON-DOCS-WORKFLOWS.md:56` (`Chain: code-dev-session recover`)
- **impact**: W-03 (Resume after compaction) workflow chain is broken.

### F-D3-006 — HOWTO.md references `programs/interactive.md` at wrong location
- **dim**: D3 · **where**: `axon/HOWTO.md:238,257` shows it in workspace/programs/; actual location `axon/programs/interactive.md`
- **impact**: User invoking `run interactive` may not find it via workspace dispatch.

### F-D3-007 — Compiled outputs are largely placeholders  ·  RECONCILED 2026-05-21
- **dim**: D3/D5 · **where**: `workspace/programs/compiled/_quarantine.md`
- **symptom (corrected)**: **154 of 188 compiled outputs quarantined (82%)** — audit originally said 118/188 (63%). PR-121 auto-generated 1:1 source copies to satisfy `test_every_program_has_compiled_output`.
- **impact**: AXON-DOCS-COMPILER claims real compression; **82% of compileds are byte-equal placeholders**. The compiler subsystem produces meaningful output for only ~18% of the catalog.

### F-D3-008 — 10 stale `semantic-search` references in compiled outputs
- **dim**: D3/D5 · **where**: `workspace/programs/compiled/code-dev-plan.cmp.md:44,46` (and 8 other files)
- **symptom**: `semantic-search` was deprecated in axon-cleanup wave 2; compileds never re-emitted.
- **impact**: Dispatching a stale `.cmp.md` invokes a removed tool.

### F-D5-003 — 3 orphan-stub programs referenced but never implemented
- **dim**: D5 · **where**: `code-dev-actions.md`, `code-dev-dry-run.md`, `code-dev-examples.md`
- **symptom**: Headers say "orphan-stub — referenced by other code-dev programs but never implemented (logged for PR-119 follow-up)". PR-119 not closed.
- **impact**: Any caller dispatching to these crashes or no-ops.

### F-D5-004 — 4 library-dev programs in PLANNED BEHAVIOR
- **dim**: D5 · **where**: `library-dev-cite.md:43`, `library-dev-intersect.md:50`, `library-dev-report.md:50`, `library-dev-search.md:45`
- **symptom**: Each has `## PLANNED BEHAVIOR` + `## TODO` — no algorithm body.
- **impact**: library-dev dispatches are non-functional.

### F-D5-005 — Synapse metadata 96% auto-inferred and demonstrably wrong
- **dim**: D5 · **where**: 175/182 programs have `inferred-by: synapse-infer (PR-108)`
- **examples wrong**: `auto-actions.md` is a renderer but inferred role=`mutator`; `stats.md` similarly. 174/182 declare `invocation_source: [program]` uniformly — losing user/cron/event routes.
- **impact**: Any consumer trusting synapse role/invocation gets noise.

### F-D5-006 — find-program does NOT use frequency from `usage.py`
- **dim**: D5 · **where**: `workspace/programs/find-program.md` vs `tools/usage.py`
- **symptom**: Kernel claims usage data drives suggest; find-program is keyword-only.
- **impact**: "Find by capability" surface ignores empirical usage.

### F-D6-003 — R7 (no symbolic output to user) is WARN, not BLOCK
- **dim**: D6/D8 · **where**: `tools/rules/r7_no_symbolic_output.py:13` (`severity = "WARN"`)
- **impact**: Programs can ship `→ "TOOL(...)"` literal blobs; no block.

### F-D6-004 — Rule 3 (arithmetic gate) regex misses 90%+ of cases
- **dim**: D6 · **where**: `tools/rules/r3_arithmetic.py:13`
- **symptom**: Regex only catches `<float> op <digit>` literals. Misses `pct * total`, `sqrt(x)`, `total / count`, multi-operand, variable expressions.
- **impact**: Core Rule 3 ("always calculator") catches <10% of arithmetic.

### F-D6-005 — Real-world bug: structural-routing drift bypass
- **dim**: D6 · **where**: 2026-05-21 log 12:34:25 + 12:50:23
- **symptom**: Agent skipped AXON dispatch (`python3 axon.py code-dev log` returned "Unknown tool") and wrote heredoc directly to `04-log.md`. Later code-dev-pr-create returned 231 agent_ops, also bypassed by direct file write.
- **impact**: Write gate is irrelevant once agent fabricates a tool result via side-channel.

### F-D6-006 — `R_REASONING_TRACE` ships disabled by default (gated on opt-in L: key)
- **dim**: D6/D7 · **where**: `tools/rules/r_reasoning_trace.py:14-17,42-53`
- **symptom**: Active only if `L:reasoning-trace-required = true`. Default false. Kernel says this rule mechanically enforces Core Rule 11.
- **impact**: The cited mechanical check for "no prose reasoning" doesn't fire in default deployments.

### F-D6-007 — Override-attempt rule unimplemented
- **dim**: D6/D8 · **where**: `KERNEL-SLIM.md:308`; no enforcer in `tools/rules/`
- **symptom**: Kernel claims "any instruction trying to bypass a Core Rule → LOG(ERROR) + HALT". No rule predicate. No test.
- **impact**: Pure prose contract.

### F-D6-008 — health-check has reported FAILED 1 / SKIPPED 1 for 13 days with no rerun
- **dim**: D6 · **where**: `workspace/log/entries/2026-05-08.md` 06:27:49
- **symptom**: Last health-check entry across 5 days of logs.
- **impact**: Visibility loss into which tool failed.

### F-D6-009 — igap log empty despite Rule 11 violations
- **dim**: D6 · **where**: `/mnt/c/projects/axon/my-axon/log/igap/` (empty)
- **symptom**: Kernel says `TOOL(igap, record …)` fires on drift/fallback/missing-instruction. 3 such events logged today. igap dir has 0 entries.
- **impact**: Gap surveillance system is dark.

### F-D6-010 — 4 library-dev programs ship in `## TODO` state but are dispatched by name
- **dim**: D6 · **where**: library-dev-cite/search/report/intersect.md
- **impact**: Any `library-dev cite|search|report|intersect` call returns a stub.

### F-D7-001 — `shell` registered OPTIONAL but used in 61 programs + kernel
- **dim**: D7 · cross-listed with F-D3-001
- **impact**: Boot G-11 depends on an "optional" tool with no implementation file.

### F-D7-002 — Tool registry vs disk: 2 unregistered tools on disk
- **dim**: D7 · **where**: `audit_axon_lang.py`, `lint_commit_trailer.py`
- **symptom**: Referenced by README:251, CHANGELOG:398, WORKFLOW.md:575 — clearly real tools that drifted out of registry.
- **impact**: No smoke probe (health.py iterates registry); cannot be called via `TOOL(...)`.

### F-D7-003 — Status enum mismatch: kernel advertises ACTIVE/PLANNED/OPTIONAL but registry has 0 PLANNED
- **dim**: D7 · **where**: `tools/REGISTRY.json` 79 ACTIVE + 7 OPTIONAL + 0 PLANNED
- **symptom**: `R_NO_PLANNED_TOOLS` is dead-code; `docgen.py:475-501` "PLANNED Tools" section unreachable.
- **impact**: Dead rule blocks nothing.

### F-D7-004 — 37 of 86 tools (43%) never referenced as `TOOL(...)` in any program
- **dim**: D7 · **where**: 3-way diff
- **symptom**: Unused: audit_compiled, benchmark, call_graph, cheatsheet_gen, compile-optimizer, compile-suggest, compile-write, diff, docgen_verify, domain_validate, goal, hooks, idem_test, index, kv-store, lint-paths, log, loop-receipt, migrate-synapse-blocks, notify, pack, plan_dag, process, programs-registry, rename_snapshot, run, scan_pre_push, session-save, study_evals, synapse-infer, synapse-validate, test, translate, undo, validator … (37 total)
- **impact**: Registry conflates "agent-callable" with "any AXON Python tool". Needs `surface: cli|agent|both` tagging.

### F-D7-005 — 3 unresolved `TOOL()` calls reference missing tools
- **dim**: D7 · **where**: programs reference `TOOL(my-tool, ...)`, `TOOL(name, ...)`, `TOOL(semantic-search, ...)`
- **symptom**: authoring-guide.md teaches semantic-search as recommended pattern; semantic-search was removed.
- **impact**: New programs authored from the guide use a dead idiom.

### F-D7-006 — Only 50 of 87 CLI tools accept `--workspace`
- **dim**: D7 · **where**: 37 tools without `--workspace`/`default_workspace`
- **impact**: Multi-workspace use (heavy-workflow goal) breaks for ~40% of tools.

### F-D7-007 — `enforce.py check-arithmetic` and `check-source` are stub no-ops  ·  RUNTIME-TRACED 2026-05-21
- **dim**: D7/D6 · **where**: `tools/enforce.py:65-75`
- **symptom**: check-arithmetic prints JSON and falls through (no sys.exit); check-source likewise. Both return advisory output, neither raises non-zero exit. Compare to check-write at line 43-63 which actually `sys.exit(1)` on disallowed write.
- **impact**: Kernel cites enforce.py as "machine-executable write gate" — only check-write actually gates. Callers using subprocess return-code semantics get `0` (success) for the stub gates regardless of input.

### F-D7-007a — `enforce.py check-source` has trivial "user:" prefix bypass  ·  NEW 2026-05-21 (surfaced during runtime trace)
- **dim**: D7/D8 · **where**: `tools/enforce.py:73`
- **symptom**: Line 73: `exists = os.path.exists(args.source) if not args.source.startswith("user:") else True`. Any caller passing `args.source` beginning with `"user:"` gets `{valid: true}` unconditionally, no path inspection.
- **impact**: Trivial bypass of Rule 2 ("never execute a task with no instruction source"). Any program/program-author can route through `--source user:fabricated` and the gate signs off. Adds to the inventory of broken Core Rule enforcers.

### F-D7-008 — `R_W_BUDGET` is WARN and counts disk files, not actual W: keys
- **dim**: D7 · **where**: `tools/rules/r_w_budget.py:7-8`, `verify.py:46-50`
- **symptom**: severity=WARN; counts `.md` files in `memory/working/`. Agent can hold many W: keys without disk persistence.
- **impact**: False sense of enforcement.

### F-D8-005 — R_COHERENCE is regex blacklist missing kernel-named brands
- **dim**: D8 · **where**: `tools/rules/r_coherence.py:20-42`
- **symptom**: Hard-coded patterns: "as an ai", "axon will", etc. Brand names "ChatGPT, Claude, Gemini, Copilot, OpenAI, Anthropic, Microsoft, Google" — the kernel explicitly forbids these as self-reference — are NOT in the list.
- **impact**: Agent saying "as Claude" is not blocked.

### F-D8-006 — Rule 9 tests don't cover any bypass vector
- **dim**: D8 · **where**: `tests/test_rules/test_r9_axon_write.py` (10 tests)
- **gaps**: no test for symlink, absolute path, parent traversal, shell tool target.
- **impact**: F-D8-001 bypasses land silently.

### F-D8-007 — Rule → enforcer → test matrix has 7 missing enforcers
- **dim**: D8 · **where**: `tools/rules/` (10 rules); Core Rules 1, 4, 5, 6, 8, 10, 12 have NO enforcer
- **mapping**: Rules 1/4/5/6/8/10/12 are pure documentation contracts.
- **impact**: 7 of 12 Core Rules are unenforced.

### F-D8-008 — `TOOL(shell, ...)` is the master gate-evasion vector  ·  RECONCILED 2026-05-21
- **dim**: D8 · **where (corrected)**: **139 calls across 61 programs** (audit originally 88/33; under-counted by 58%)
- **symptom**: Once an agent emits `TOOL(shell, "rm -rf workspace/memory/")` or `TOOL(shell, "cp x axon/y")`, no rule fires (R9 only inspects WRITE/APPEND ops; R9 `_is_axon_path` uses `p.lstrip("./")` not `os.path.realpath()`, verified at `tools/rules/r9_axon_write.py:29-31`).
- **impact**: Every axon/-protection collapses if shell pass-through is permitted. Footprint is 1.6× the original report.

### F-D8-009 — Identity gate has structural tests but no behavioral test
- **dim**: D8 · **where**: `tests/test_identity_gate.py`
- **symptom**: Asserts identity.md structure but never invokes agent with "what model are you" and asserts gate fires.
- **impact**: Identity.md could be present and never dispatched.

### F-D8-010 — No-queue rule unimplemented
- **dim**: D8 · **where**: `KERNEL-SLIM.md:166`
- **symptom**: Kernel: "executing a previously-blocked command without explicit re-statement is itself a violation". No code detects this.
- **impact**: Pure aspirational.

### F-D8-011 — Rule 10 (KERNEL-SLIM edits) has no static guard on diff
- **dim**: D8 · **where**: no pre-commit hook on `axon/KERNEL-SLIM.md`
- **impact**: Human edits can land kernel changes without the dev-mode receipt.

### F-D4-004 — Hybrid execution mode is schema-only
- **dim**: D4 · **where**: schema accepts `hybrid`; `workflow-run.md:69` only branches on `adaptive`; orchestrator knows only `fixed`/`adaptive`/`free-text`
- **impact**: Hybrid YAML schema-validates but executes identically to `fixed`.

### F-D4-005 — Inference-mode does NOT alter ranker weights
- **dim**: D4 · **where**: `tools/synapse_suggest.py:rank()` has no mode param
- **symptom**: L:inference-mode used only for decide(fire/ask/surface) branch in orchestrator. Same candidate ordering for cautious (3) and autonomous (9).
- **impact**: Documented "weighted per inference-mode" is wrong.

### F-D4-006 — DAG mutations are not reversible (no undo / inverse)
- **dim**: D4 · **where**: `tools/dag.py` mutator functions
- **symptom**: Direct dict mutation + atomic_write to disk. No journal, no undo cmd, no inverse helper.
- **impact**: Workflow DAG authoring is a one-way street.

### F-D4-007 — DAG defer + cut operations advertised but not implemented
- **dim**: D4 · **where**: `tools/dag.py`
- **symptom**: CHANGELOG: "Reversible operations (merge/split/fold-in/defer/cut)". Code has merge/split/fold_in but no defer, no cut.
- **impact**: `dag defer …` returns argparse "invalid choice".

### F-D4-008 — workflow-run does not CHECKPOINT before each step
- **dim**: D4/D9 · **where**: `workflow-run.md`
- **symptom**: No CHECKPOINT token anywhere. PROCESS.md violation. Context-pressure gate has nothing to hook into.
- **impact**: Workflow interrupted at step 5 cannot resume.

### F-D4-009 — workflow-list misses domain-scoped workflows
- **dim**: D4 · **where**: `workflow-list.md:39-42`
- **symptom**: Hard-coded `wf-dir ← "workspace/workflows"`; never scans `workspace/domains/*/workflows/`.
- **impact**: 4 of 6 reference workflows invisible to the listing tool.

### F-D4-010 — Adaptive mode is observability-only
- **dim**: D4 · **where**: `workflow-run.md:69-71`
- **symptom**: Adaptive emits suggestion line but ignores it; next-id still picked by `on-complete` predicates.
- **impact**: "Adaptive" mode behaves identically to "fixed" with console message.

### F-D4-011 — orchestrator candidates type mismatch between fixed and adaptive
- **dim**: D4 · **where**: `orchestrator.md:64-72` + 86
- **symptom**: Fixed mode returns `[next-step]` (list of strings). Adaptive returns dicts. Then `top.score` is undefined for fixed → `confidence = 0` → decision branch "ask" → question-spam.
- **impact**: All fixed workflows degrade to ask-every-step at default inference-mode 5.

### F-D9-005 — Context.py accumulator never reset between sessions
- **dim**: D9 · **where**: `tools/context.py:113-141`
- **symptom**: `record` `+=` accumulates forever; only reset is explicit. Boot doesn't reset.
- **impact**: After a week, accumulated count exceeds limit even for tiny session → critical gate fires on every turn from boot.

### F-D9-006 — HALT inside context-pressure gate adds extra tokens  ·  RUNTIME-TRACED 2026-05-21 (DOWNGRADED)
- **dim**: D9 · **where**: `KERNEL-SLIM.md:281-296`; `axon/OUTPUT-LAYER.md:54-73`; `tools/checkpoint.py`
- **symptom (corrected)**: Trace: CHECKPOINT shorthand (KERNEL-SLIM:403) APPENDs a fixed ~80-byte string to E:session-log, not a full state dump — original audit's "100-300 token ceremony" overstated checkpoint cost. Total ceremony: 4 warn lines + 3-7 footer lines + reasoning-trace + verify call = **~80-150 tokens**, not 100-300. At 95% pressure on 200k context = 10k tokens of headroom — ceremony fits comfortably.
- **impact (revised)**: Real but bounded. Would only bite on smaller contexts (≤32k) or if multiple HALTs cascade. Not a catastrophic-overflow risk on Claude 4.x default contexts.
- **severity**: BLOCKER → **MINOR**.

### F-D9-007 — W:25-key budget rule is WARN, never blocks
- **dim**: D9/D7 · cross-listed with F-D7-008
- **impact**: Long study session accumulates 50-100 W: keys; snapshot grows; context pressure compounds.

### F-D9-008 — Schema-version on session-resume written but never read
- **dim**: D9 · **where**: `tools/session_save.py:236-244` writes; `restore_from_snapshot:157-196` never reads
- **impact**: Cross-version resume = silent data corruption.

### F-D9-009 — Mid-program interrupt gate double-renders K/I/A  ·  RUNTIME-TRACED 2026-05-21 (REFUTED as infinite, downgraded)
- **dim**: D9 · **where**: `KERNEL-SLIM.md:168-224`
- **symptom (corrected)**: Trace: after the first gate render stores `W:_interrupt-pending-input` (line 187), the next user turn fires the gate again because `W:active-phase` is still set. The continuation-cmds list (line 183) contains "y","n","continue","c","ok","next","confirm","proceed","skip","back","cancel","q","quit","exit","resume" — but NOT "k","i","a". So K/I/A characters fall into the ELSE branch and render the full prompt a SECOND time. BUT: on the second pass, line 202 `answer ← input | "K"` reads the current input ("K") as the answer, and line 203 `answer ≡ "K"` matches → CLEAR + EXEC(program). **Gate resolves in one extra turn, not infinite loop**.
- **impact (revised)**: Real UX bug (K/I/A prompt renders twice before resolving), but terminates. Original "user can never escape" framing is wrong.
- **severity**: BLOCKER → **MAJOR**. Fix: add "k","i","a" to continuation-cmds list at KERNEL-SLIM.md:181-183.

### F-D9-010 — SPAWN/KILL/PAUSE/RESUME are translation-only
- **dim**: D9 · **where**: KERNEL-SLIM:344; `tools/translate.py:91-94`; `tools/process.py`
- **symptom**: Lifecycle files written but no actual fork; foreground sequential only.
- **impact**: Heavy workflows that need parallel sub-programs can't run them.

### F-D9-011 — G-02 mid-program identity check unprotected for turns 1-4  ·  RUNTIME-TRACED 2026-05-21 (CONFIRMED)
- **dim**: D9 · **where**: KERNEL-SLIM.md:130-138 (G-02); code-dev-plan.md:191-195 (uses LOOP(true) with mod-5 check); code-dev-pr-create.md:195; code-dev-study.md:327
- **symptom (confirmed)**: All 3 LOOP(true) programs implement G-02 identically — `IF W:turn-count mod 5 ≡ 0 → ASSERT`. The cognition-language gate (KERNEL-SLIM.md:123-129) also asserts on cognition-frame but its only recovery is `LOG(ERROR) + HALT` — no auto-restore. Auto-restore lives at KERNEL-SLIM.md:305-306 — also mod-5. **Three independent gates all gate on mod-5**, leaving 2-4 unprotected turns post-compaction.
- **impact (confirmed)**: Multi-program impact. Severity: **BLOCKER** stands.
- **fix**: Either (a) make mod-5 a mod-2 or mod-1 with cheap-check semantics, (b) add an automatic restore (not just HALT) inside the cognition-language gate, or (c) add a session.recover() automatic call at the response gate.

### F-D9-012 — Cron rate-limited to 1 job per tick → queue never drains
- **dim**: D9 · **where**: `tools/cron.py:359` ("1 attempted run per tick")
- **symptom**: 7 default jobs; if 6 overdue, ran 1 + deferred 5; other 5 don't get next_run advanced either → stay overdue.
- **impact**: Daily-booting user perpetually sees 5-6 overdue cron jobs; queue never drains.

### F-D9-013 — `session-save` silently skips W: values > 2KB
- **dim**: D9 · **where**: `tools/session_save.py:32` (`W_VALUE_MAX = 2048`)
- **symptom**: Large blobs dropped from snapshot, stderr-warned only. Programs storing W:big-state ~10KB lose them on resume.
- **impact**: Mid-program suspension → resume errors on missing input.

### F-D9-014 — `resume` program reads E:session-log as structured but it's a Markdown table
- **dim**: D9 · **where**: `resume.md:24-27` vs `session_save.py:147-154`
- **symptom**: RETRIEVE returns list of strings; FILTER expects dicts with `.event` field.
- **impact**: Resume program's scan always returns empty → "No interrupted sessions found" even when there ARE interrupted sessions.

---

## MINOR

### F-D1-010 — Output-layer references PLANNED context-pressure tool in production spec
- **dim**: D1 · **where**: `axon/OUTPUT-LAYER.md:31-38`
- **symptom**: Spec says tool is PLANNED; preferences/output-layer.md:31-37 enables `output-layer-show-context-pressure: true`.
- **impact**: Preference toggle does nothing.

### F-D1-011 — Help fallback to `axon/programs/help/` covers only 21 of 186 programs
- **dim**: D1 · **where**: `workspace/programs/help.md:27-32`
- **impact**: 165 programs get only the desc line on `help foo`.

### F-D1-012 — Quickstart step 7 references W:myaxon-chats that may not be set
- **dim**: D1 · **where**: `quickstart.md:97,213`
- **impact**: Fresh user runs quickstart cold; step 7 errors on undefined path.

### F-D1-013 — FAQ/menu/quickstart contradict on tour length (5/7/"guided"/"2-min")
- **dim**: D1 · **where**: faq.md:152 vs quickstart.md:45 vs menu.md:117,422

### F-D1-014 — Menu tip pool advertises non-existent commands
- **dim**: D1 · **where**: menu.md:421-445
- **symptom**: Tips: "hooks add …", "cron add --program …" — no matching grammar in COMMANDS.md.
- **impact**: Users follow tips, hit unknown-command handler.

### F-D1-015 — Mode badge `[chat]` prefixed on every line of long outputs
- **dim**: D1 · **where**: `axon/COMMANDS.md:128-130`
- **impact**: 200-line stats dashboard gets 200 `[chat] ...` line prefixes — significant visual noise.

### F-D2-008 — Inconsistent suffix conventions: -new / -create / -init / -add coexist
- **dim**: D2 · **where**: workspace/programs/ (new vs create vs init across creation programs)

### F-D2-009 — Long `# desc:` lines (5 exceed 150 chars; top 241)
- **dim**: D2 · **where**: code-dev-audit.md:`# desc:` = 241 chars

### F-D2-010 — Worst error message: "unknown subcommand: {sub}" appears 7×
- **dim**: D2 · **where**: code-dev-{knowledge,shape,meta,flow,safety,journal,state}.md
- **symptom**: Only code-dev-lifecycle includes valid-options hint.
- **impact**: User typos get "unknown subcommand: explan" with no enumeration.

### F-D2-011 — PROGRAMS-INDEX.md describes a programs hierarchy that's not live
- **dim**: D2 · **where**: `axon/PROGRAMS-INDEX.md` lists mode-build/chat/dev/memory/plan/run/system but those are orphans (F-D1-005). 130+ user-facing programs in workspace/programs/ absent from index.

### F-D2-012 — HOWTO.md command grammar doesn't match COMMANDS.md
- **dim**: D2 · **where**: `axon/HOWTO.md:46-69`
- **symptom**: HOWTO lists "memory", "log [n]", "tools", "add tool [name]" — none in COMMANDS.md grammar.

### F-D2-013 — 5 programs reference deprecated semantic-search without degradation
- **dim**: D2 · **where**: igap-improve.md, list-tools.md, code-dev-init.md, code-dev-plan.md, authoring-guide.md

### F-D2-014 — Synapse `inputs-count` / `outputs-count` are inconsistent in meaning
- **dim**: D2 · **where**: menu.md inputs-count=30 (RETRIEVE count); health-check.md inputs-count=1 (named param). Different semantics, same field.

### F-D2-015 — Naming/role mismatch: 22 programs claim role:reader but mutate state
- **dim**: D2 · **where**: glossary.md (mutator declared, read-only actually); menu.md (reader declared, writes W:turn-count)

### F-D3-009 — README/CHANGELOG/Architecture say "182 programs"; on disk 183 (top-level) or 372 (with subdirs)
- **dim**: D3 · **where**: README.md:23,203; CHANGELOG.md:42

### F-D3-010 — HOWTO claims "AXON is a folder of instruction files. There is no code." — repo ships 93 .py tools
- **dim**: D3 · **where**: `axon/HOWTO.md:8`

### F-D3-011 — CHANGELOG Unreleased section sandwiched mid-document
- **dim**: D3 · **where**: `CHANGELOG.md:81` (after 3.7.0 + 3.6.1)
- **impact**: Reader can't tell pending vs shipped.

### F-D3-012 — CHANGELOG mentions `axon/tools/` directory that doesn't exist
- **dim**: D3 · **where**: `CHANGELOG.md:74-75`
- **symptom**: Refresh-in-progress mentions "axon/tools/REGISTRY.md" — only top-level `tools/` exists.

### F-D3-013 — Boot step 3 guards a "cron PLANNED" state that never arises (no PLANNED cron jobs)
- **dim**: D3 · **where**: KERNEL-SLIM.md:611

### F-D3-014 — STUB classification inconsistently applied (4 in registry vs 25 on disk)
- **dim**: D3 · **where**: REGISTRY.json `programs[*].status='STUB'` = 4; disk has 25 STUB files
- **impact**: Synapse orchestrator may rank stubs as valid candidates.

### F-D3-015 — `enforce.py check-arithmetic` and `check-source` are stub no-ops
- **dim**: D3 · cross-listed with F-D7-007

### F-D5-007 — Redundant status/dashboard programs (4 different "dashboards")
- **dim**: D5 · **where**: status.md, stats.md, menu.md, code-dev-state-status.md — overlapping "dashboard" descs.

### F-D5-008 — 33 programs have duplicate `# desc:` lines
- **dim**: D5 · **where**: e.g. auto-actions.md, code-dev-meta-context.md (33 total)
- **symptom**: Parsers take FIRST match; second is dead text.

### F-D5-009 — `_code-dev-schema-v4.md` lacks `# synapse:` header
- **dim**: D5 · **symptom**: Only program file without synapse block; parsers may treat as program.

### F-D6-011 — R_REASONING_TRACE has duplicated header block (merge artifact)
- **dim**: D6 · **where**: `tools/rules/r_reasoning_trace.py:119-140`
- **symptom**: Dead overrides at module bottom.

### F-D6-012 — Tests directory has 7 always-skip / xfail dynamic skips
- **dim**: D6 · **where**: test_compiled_regression.py, test_no_stale_subsystems.py, test_orchestrator_loop.py, test_goal.py:229
- **impact**: test_goal.py skips IFF axon-synapse missing — which it IS in this tree (we're auditing axon-development, not the prod tree).

### F-D6-013 — HALT() messages are 81× homogeneous: "Identity lost — run: boot axon"
- **dim**: D6 · **symptom**: Every program with G-02 mid-loop check uses same message.
- **impact**: HALT triage is opaque.

### F-D6-014 — `tools/usage.py` not invoked by EXEC of `.cmp.md` paths
- **dim**: D6 · **where**: `tools/run.py:136-138` calls usage only via run.py; direct dispatch of compileds skips.
- **impact**: Usage data biased; suggest-compile surface incomplete.

### F-D6-015 — Programs that QUERY with confirm/yes/no use bare HALT() — unlogged
- **dim**: D6 · **symptom**: 12 programs with `IF confirm ≢ "yes" → HALT("X aborted")`; no LOG(INFO,"user aborted"), no CHECKPOINT trace.

### F-D7-009 — Tool API consistency: 10 CLI tools emit no JSON output
- **dim**: D7 · **where**: auto_audit, auto_improve, cheatsheet_gen, compile, hooks, lint_commit_trailer, migrate_synapse_blocks, programs_registry, synapse_infer, undo
- **impact**: Agent must parse free-text; brittle.

### F-D7-010 — Verb naming inconsistent: 4 tools use subparser; mixed set/put, list/ls
- **dim**: D7 · **where**: cd_cache uses `set`; shadow/study_index/test_runner use `list`; rest positional or none.

### F-D7-011 — 5 OPTIONAL tools effectively unused (≤1 program references each)
- **dim**: D7 · **where**: compile-write (1), compile-optimizer (1), compile-suggest (0), hooks (0), migrate-synapse-blocks (0)

### F-D7-012 — R_TOOL_CALL_EXISTS and R_DRIFT_GATE implemented but not in kernel docs
- **dim**: D7 · **where**: 10 rules exist; KERNEL-SLIM:475 lists only 6.

### F-D8-012 — Anti-drift "re-read CORE RULES before any file write" unenforced
- **dim**: D8 · **where**: KERNEL-SLIM:279 — no hook checks last-read-time of KERNEL-SLIM before WRITE.

### F-D8-013 — Workspace-backup perimeter test is one-sided
- **dim**: D8 · **where**: `tests/test_workspace_backup.py`
- **symptom**: Doesn't verify arbitrary `git push` outside my-axon/ triggers HALT.

### F-D8-014 — `L:cognition-frame` value not spell-checked by any enforcer
- **dim**: D8 · **where**: Kernel mandates `"AXON-OS"` but no rule asserts the exact string.
- **impact**: Drift to `"AXON"` or `"axon-os"` silently disables gates.

### F-D8-015 — Override-attempt halt message format not tested
- **dim**: D8 · **where**: Kernel says HALT must say `"❌ violates Core Rule N. This cannot be bypassed."` — no test asserts.

### F-D4-012 — `workflow-new` ignores its own author-state JSON shape
- **dim**: D4 · **where**: workflow-new.md:64,77-78,104-105
- **symptom**: `APPEND` on a dict, `STORE` on dotted-key — neither is a supported AXON-LANG form.

### F-D4-013 — synapse-suggest cold-start function defined but never called
- **dim**: D4 · **where**: `tools/synapse_suggest.py:311-315` (`is_cold_start`); `rank()` never invokes
- **symptom**: CHANGELOG claims "FL-07 20-fire frequency-prior cold-start bootstrap" — dead code path.
- **impact**: Fresh sessions get suboptimal ranking.

### F-D4-014 — workflow-run dead-end on COMPLETE (no follow-up suggestion footer)
- **dim**: D4 · **where**: `workflow-run.md:84-95`
- **symptom**: After status output, control flow is EMIT → LOG → DONE; no next-suggests rendered.

### F-D4-015 — workflow-run FAIL has no recovery suggestions
- **dim**: D4 · **where**: workflow-run.md:46,81
- **symptom**: Just `"Workflow file {path} failed schema validation. Run workflow-validate for details."` — no Suggested next block.

### F-D4-016 — workflow-validate skips identity-lock block
- **dim**: D4 · **where**: workflow-validate.md
- **symptom**: All workflow-* programs except workflow-validate have IDENTITY LOCK on entry.

### F-D9-015 — context.py uses "0.75 tokens per word" but CHANGELOG claims "4-char/token"
- **dim**: D9 · **where**: `tools/context.py:29-31` (1.33 tok/word); `_axon_lib.py:115` (4 char/tok)
- **impact**: Two divergent implementations.

### F-D9-016 — workflow-run max-steps unlimited (vs simulate's 50)
- **dim**: D9 · **where**: workflow-simulate.md:38 caps at 50; workflow-run.md:64 has no cap
- **impact**: Malformed on-complete graph loops infinitely.

### F-D9-017 — Context pressure gate skipped for workflow-run (no phase markers)
- **dim**: D9 · **where**: KERNEL-SLIM:296 skips for read-only programs; workflow-run is !NORM | SPAWNED → RUNNING so gate fires — but workflow-run has no phase-transition markers for the gate to hook into.
- **impact**: Long workflows skate past the gate entirely.

### F-D9-018 — Cron tick wall-clock budget 30s but per-job timeout 120s
- **dim**: D9 · **where**: cron.py:23, 198
- **impact**: Slow jobs starve other jobs in same tick.

### F-D9-019 — Session-save snapshot-version bumped manually; no auto-migration
- **dim**: D9 · **where**: session_save.py:237 (hardcoded "1")
- **impact**: Schema evolution = silent data drop.

### F-D9-020 — Cron breaker tripped silently with no surfacing path
- **dim**: D9 · **where**: cron.py:321,366,233-247
- **symptom**: After 3 consecutive failures, breaker disables job; only signal is `_emit_event` to JSONL file.
- **impact**: Backed-up cron + silent disables = invisible system degradation.

---

## NIT

### F-D1-016 — Identity-gate / TOKEN PARSE case sensitivity mismatch
- **dim**: D1 · **where**: COMMANDS.md:5-18,22-24
- **symptom**: identity gate is LOWER()ed; token parse is case-sensitive. `MENU` (caps) won't match menu shortcut.

### F-D2-016 — `code-dev-resume.md` and 4 other deprecated-alias programs still ship
- **dim**: D2/D5 · cross-listed with F-D2-005

### F-D2-017 — glossary.md precondition is literal placeholder text
- **dim**: D2 · **where**: glossary.md `precondition: "condition AND condition"`
- **impact**: synapse-suggest scoring on precondition produces noise.

### F-D3-016 — `audit-axon-lang` documented as canonical primitive-coverage audit but not in registry
- **dim**: D7/D3 · cross-listed with F-D7-002

### F-D3-017 — `boot.py` registered ACTIVE but 0 programs reference `TOOL(boot, ...)`
- **dim**: D3 · **where**: Only KERNEL-SLIM:565 calls it; confirms registry conflates kernel-tier with program-tier.

### F-D9-021 — Cron breaker test on `run` action vs `tick` action — both call `_apply_breaker` (OK), but no exponential backoff
- **dim**: D9 · **where**: cron.py
- **impact**: Repeat-failure cron jobs disabled cleanly but with no escalation path.

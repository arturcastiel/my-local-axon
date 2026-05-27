# ADRs — AXON Polish

> Architectural Decision Records made during Phase 1-audit reconciliation.
> Each ADR addresses one of the 3 active conflicts surfaced by `_prior-work-crossref.md`.
> Decisions are project-wide; they govern Phase 2-prioritise ranking + Phase 3-design specs.

---

## ADR-001 — TOOL(shell) gate: sandboxed shell.py with allowlist
**Date**: 2026-05-21
**Status**: ACCEPTED
**Owner**: user (axon-polish project)
**Supersedes**: cleanup PR-120 (host-dispatched, no Python script)
**Conflicts with**: F-D3-001, F-D7-001, F-D8-001, F-D8-008

### Context
- 139 `TOOL(shell, …)` calls across 61 programs + kernel boot G-11.
- `tools/shell.py` does not exist; REGISTRY.json declares it OPTIONAL/category=host with `"dispatched by the host harness, no Python script"`.
- R9 axon/ write gate at `tools/rules/r9_axon_write.py:29-31` uses `p.lstrip("./")` not `os.path.realpath()` — symlink/absolute/traversal bypasses confirmed.
- Once shell pass-through is permitted, every axon/ protection collapses.

### Decision
Implement **`tools/shell.py`** as a sandboxed gate with a command allowlist:
- Allowlist initially mirrors current use: `git status|log|diff|show|blame|branch|rev-parse|describe|ls-files|for-each-ref|cat-file`, `ls`, `cat`, `head`, `tail`, `wc`, `find` (read-only), `pwd`, `which`, `file`.
- Disallowed: any write-side command (`git add|commit|push|rm|mv`, `rm`, `mv`, `cp`, `chmod`, shell expansion that touches axon/, heredocs writing files).
- Each invocation: parse → match-allowlist → if writing-shape detected, apply R9 path-check via `realpath()` → block on violation.
- Return JSON `{ok: bool, stdout, stderr, exit_code}`; programs read structured output.

### Roadmap (separate from this ADR)
- Long-term: migrate to specific tools (`git-info`, `fs-list`, `fs-read`) per Conflict #1 Option C. Tracked as separate demand.
- 30-60 days post-ship: review allowlist hit/miss rates; tighten.

### Consequences
- Effort: M (~1-2 days for sandbox + allowlist + tests).
- All 139 existing call sites continue to work unchanged (if allowlist is comprehensive).
- R9 chokepoint single-point.
- Allowlist maintenance becomes the new attack surface.
- Boot G-11's `TOOL(shell, "git -C ... rev-parse")` is covered (read-only git subcommand allowlisted).

### Related findings closed by this ADR
- F-D3-001 (resolved on impl)
- F-D7-001 (resolved on impl)
- F-D8-008 (resolved on impl + R9 hardening)
- F-D8-001 vectors 4 (resolved by ADR; vectors 1-3 need separate R9 realpath fix)

### Related findings NOT closed (need separate work)
- F-D8-001 vectors 1-3 (symlink, absolute, traversal): require `os.path.realpath()` in R9 — separate small PR.
- F-D8-006 (no R9 bypass tests): need 4 new test cases.

---

## ADR-002 — FAIL canonical-pieces: tools/fail_render.py + incremental migration
**Date**: 2026-05-21
**Status**: ACCEPTED
**Owner**: user (axon-polish project)
**Supersedes**: cleanup `scripts/autopatch_programs.py` 6-canonical-pieces (which omits FAIL block)
**Conflicts with**: F-D2-001, F-D2-007, F-D2-016 (worst-error-message), F-D6-013 (homogeneous HALT messages)

### Context
- Kernel spec at KERNEL-SLIM.md:411-426 mandates FAIL renders the block: `Problem / Cause / Fix / Suggested next`.
- 94 of 183 programs call `FAIL(`. 0 of them render the kernel-format block. 100% non-compliance.
- cleanup's autopatch shipped 126 programs with 6 canonical pieces (PROGRAM/desc/!NORM/OUTPUT/banner/DONE) — FAIL block is NOT in the canonical list, codifying the violation.

### Decision
Ship **`tools/fail_render.py`** as a shared renderer:
- Signature: `fail_render(program_name, problem, cause=None, fix=None, suggested_next=None) → str` returning the standard ━━━ block.
- Programs invoke via `TOOL(fail-render, ...)` or direct shell call.
- AXON-LANG shorthand `FAIL(prog, reason, cause, fix)` expands to call this renderer.
- Migration: incremental — programs adopt the renderer as they're touched for other reasons. New programs use it from day one.

### Consequences
- Effort: S (one tool, ~half day) + M (incremental migration across 94 programs).
- Quality is high: Cause/Fix are author-supplied at FAIL site (not autopatch placeholders).
- Existing 94 programs continue to ship the one-string form until each is touched. Drift remains until migration completes.
- New program contract: FAIL must use the renderer; lint rule (future) blocks bare-string FAIL.

### Related findings closed by this ADR
- F-D2-001 (resolved when migration completes; tool ships in first PR)
- F-D2-007 (same)
- F-D2-016 ("unknown subcommand" worst error): renderer provides standard "Did you mean ...?" hint surface
- D-D2-018 demand resolved (renderer IS the standardized FAIL surface)

### Cleanup project conflict
- cleanup `scripts/autopatch_programs.py` should update its 6-canonical-pieces to include a FAIL-block sentinel for future autopatches. axon-polish files this as a follow-up PR against cleanup, not against the dev tree directly.

---

## ADR-003 — Catalog deprecation: 30-day hybrid policy
**Date**: 2026-05-21
**Status**: ACCEPTED
**Owner**: user (axon-polish project)
**Supersedes**: cleanup PR-142 (comment-only deprecation, no timeline)
**Conflicts with**: F-D2-005, F-D2-018 (deprecated alias ship), F-D5-003 (orphan-stubs)

### Context
- 42 dead-or-half-alive files in the catalog (15 DEPRECATED + 24 alias-stub + 3 orphan-stub) — verified count.
- cleanup adopted comment-based deprecation (`# deprecated (axon-cleanup PR-142): ...`) with no timeline.
- master designed rename-waves PR-26/27/28 (hard delete) but never executed.
- Catalog grows monotonically; find-program / discover surface noise.

### Decision
**Hybrid 30-day deprecation policy**:
1. Mark a program deprecated by adding a header line: `# deprecated (PR-NNN, YYYY-MM-DD): superseded by X` — where the date is the **deprecation start date**.
2. Maintain `workspace/programs/_deprecation-log.md` — append-only table: `| program | deprecated-on | superseded-by | hard-delete-after | status |`.
3. Hard-delete the file **30 days after the deprecation-on date**, IF (a) no callers remain (grep against workspace + axon), AND (b) the supersession has been documented in the relevant AXON-DOCS-*.md page.
4. Cron job (new): weekly scan of `_deprecation-log.md` → list programs hitting the 30-day mark → surface as "ready to hard-delete" in menu OS STATE panel.
5. Hard-delete requires: dev-mode ON + explicit user authorization (per kernel R9). NOT autonomous.

### Implementation steps
1. PR-α: write `_deprecation-log.md` template + scaffold for existing 42 files; create cron job `axon-deprecation-watch` weekly.
2. PR-β: backfill `_deprecation-log.md` with existing 15 DEPRECATED + 24 alias-stub + 3 orphan-stub — mark deprecation-on dates from each file's existing marker (where present) or "2026-05-21" otherwise.
3. PR-γ (after 30 days from 2026-05-21, ie ~2026-06-21): first hard-delete sweep.
4. Recurring: each new deprecation gets a new row + 30-day clock.

### Consequences
- Effort: M (initial scaffold) + S (each release cleanup).
- Discoverability: good — find-program filters out deprecated by default; explicit `--include-deprecated` flag for archaeology.
- Risk: low — 30-day window gives time to catch missed callers; dev-mode + user auth required for hard-delete.
- Catalog shrinks naturally as deprecations age out.

### Related findings closed by this ADR
- F-D2-005 (closed by initial sweep + ongoing policy)
- F-D5-003 (closed: orphan-stubs go straight to hard-delete since they have no callers either)
- D-D5-001 (`program-deprecate` / `program-archive` / `program-rename` demand): the cron job + log are the lightweight implementation.

---

## ADR-004 — Phase-transition invariant gate  ·  ACCEPTED 2026-05-23
**Date**: 2026-05-21 (proposed) · 2026-05-23 (accepted)
**Status**: ACCEPTED — warning-only rollout (L:phase-gate-enforce, default false)
**Owner**: user (axon-polish + firing-dag-missing)
**Implemented**: PR-ADR-004 — tools/phase_gate.py + warning-only wiring into
  code-dev-phase-new. DAG-emit broadening (decision point 4) routes to
  firing-dag-missing per the original finding routing; F-D6-005b full close
  still needs D-D8-022 (EXEC verification cross-check), out of scope here.
**Source**: firing-dag-missing seed (DAG-skip paths) + copilot-deviation-study (silent EXEC drift)

### Context
- F-D4-016: DAG auto-emit is content-coupled (reads `prs_ordered` from plan file), not event-coupled to `_meta.md` writes — multiple invocation paths skip it silently.
- F-D6-005b: `EXEC(program)` silently degrades to prose simulation, stripping all program contracts (DAG auto-emit, plan-file invariants, phase checkpoints).
- 3 known bypass paths to phase advancement without required artifacts:
  (a) direct `_meta.md` authoring at phase-2-design,
  (b) `code-dev-resume` after a checkpoint pre-dating plan,
  (c) `code-dev-pr-create` before `code-dev-plan`.

### Decision (proposed, awaits user accept)
Define a **phase-transition invariant gate** that fires before any program advances a project/phase from N → N+1:
1. Per-phase artifact contract: each `code-dev` phase declares the artifacts that MUST exist at close (e.g. phase-2 close requires `03-prs/DAG.json`, `02-plan.md` populated, `02-prs.md` non-empty).
2. Gate implementation: `tools/phase_gate.py check --project X --from N --to N+1` returns OK or {missing-artifacts: [...]}.
3. Wire into `code-dev-phase-new` / `code-dev-state-save` / any program that mutates `_meta.md`'s `phase:` field.
4. Auto-emit broadening: when `_meta.md` is written at phase-2 with a PR queue table present, fire DAG emit synchronously.

### Consequences
- Effort: M (~2-3 days: gate tool + per-phase contract + wiring + tests)
- Closes: F-D4-016 (DAG-skip), F-D6-005b (partial — phase-level integrity), and tightens phase-state honesty across all code-dev projects.
- Does NOT close F-D6-005b in full (that needs D-D8-022 EXEC verification cross-check).
- Risk: medium — touches every code-dev program. Mitigation: phased rollout starting with warning-only mode.

### Related findings closed by this ADR (on accept)
- F-D4-016 (DAG-skip paths)
- F-D6-005b partial (phase-transition surface only)
- D-D8-021 / D-D8-022 / D-D6-005a benefit from this groundwork

---

## ADR cross-reference

| ADR | Conflict # | Status | Recommended option | Effort | Closes findings |
|---|---|---|---|---|---|
| ADR-001 | TOOL(shell) gate | ACCEPTED | B — sandboxed shell.py | M (1-2d) | F-D3-001, F-D7-001, F-D8-008, F-D8-001 vector 4 |
| ADR-002 | FAIL canonical | ACCEPTED | B — fail_render.py + incremental | S + M | F-D2-001, F-D2-007, F-D2-016, D-D2-018 |
| ADR-003 | Catalog deprecation | ACCEPTED | C — 30-day hybrid | M (initial) + S/release | F-D2-005, F-D5-003, D-D5-001 |
| ADR-004 | Phase-transition invariants | ACCEPTED | gate tool + per-phase artifact contract (warning-only rollout) | M (2-3d) | F-D4-016, F-D6-005b (partial), supports D-D8-021/022, D-D6-005a |
| ADR-005 | Adaptive termination + goal-mutation | ACCEPTED (split) | 005a C-now (S, step-count guard) + 005b A-later (M, registered builtins) | S+M | F-D4-003 now; F-D4-017/018 later |
| ADR-006 | Resume / compaction contract | ACCEPTED (sequenced) | Phase 1 C (PID-mismatch hook) + Phase 2 B (phase ledger enforcement) | S+M | F-D9-022/004 then F-D9-002/011-partial |
| ADR-007 | workflow-run ↔ orchestrator boundary | ACCEPTED | C (light 2-line bridge + observe-only guard) | S | F-D4-002, F-D4-014 (closes); F-D4-001 (partial) |

---

## ADR-005 — Adaptive workflow termination + goal-mutation
**Date**: 2026-05-21
**Status**: ACCEPTED (split into 005a now + 005b deferred)
**Owner**: user (axon-polish)
**Source**: F-D4-003 (adaptive-free-text infinite loop), F-D4-017 (goal.* undefined), F-D4-018 (no ctx passed)

### Context
- adaptive-free-text.yml's on-complete graph routes s1→s2→s1 indefinitely; nothing mutates goal state.
- Deeper finding (F-D4-017): `goal.acceptance.met()` and ~10 other identifiers used in workflow YAMLs are NOT in `tools/predicate.py:364-381` BUILTINS table. Empirical: returns `null` (safe-null mode). So even hypothetical goal-mutation would have nowhere to land.
- Hidden prerequisite (F-D4-018): workflow-run calls predicate eval with no `--ctx`. Even `state.steps > 25` would resolve `state` to `null` today.

### Options considered
**A — Per-step goal-update hook in workflow-run + registered builtins.**
After each step, call `TOOL(goal, evaluate --workflow X --step <id> --ctx <runtime-state>)` that mutates `workspace/memory/goals.yml` status. Register `goal.acceptance.met` in BUILTINS. M cost (~80 LOC tool + workflow-run wiring + builtins table).

**B — `goal-mutation:` block in workflow YAML.**
Add per-step mutation primitives in schema. workflow-run applies between EXEC and on-complete. Heavy: schema change + mutation mini-language + every workflow author learns new syntax.

**C — Step-count guard inside workflow-run loop + ctx wiring.**
Move `rejection-criterion` eval from post-loop to inside loop. Build runtime ctx with `state.steps = COUNT(trace)`. `OR` short-circuits on the steps comparison. ~5 lines in workflow-run, no schema change. Does NOT solve undefined-function problem broadly — defers that to ADR-005b.

### Decision (proposed)
**Two-part split**:
- **ADR-005a (now, S)**: Adopt Option C — step-count guard + ctx-passing. Closes F-D4-003 (the immediate BLOCKER). PR scope: ~5 LOC in workflow-run.md + same change in workflow-simulate.md (which has identical defect).
- **ADR-005b (later, M, scope EXPANDED 2026-05-22)**: Adopt Option A — register the FULL predicate vocabulary used by shipped reference workflows in BUILTINS + per-step goal evaluate.

**Scope expansion rationale (F-D4-017a discovered iter 3)**: Direct verification of `tools/predicate.py:364-381` shows BUILTINS has 15 entries (file.*, count, glob_*, int/float/str/bool/len). Reference workflows use an entirely different identifier set that ISN'T registered. Every reference workflow's acceptance/rejection criteria silently bypassed via safe-null.

**Full vocabulary to register**:
- `goal.acceptance.met()`, `goal.rejection.met()` — adaptive-free-text
- `tests.pass()`, `tests.fail()` — code-dev.canonical, python-code-dev
- `audit.open-findings`, `audit.critical-issues` — code-dev.canonical, cpp-code-dev
- `review.passes()`, `review.has-objections()` — all code-dev workflows
- `build.passes()`, `build.fails()` — cpp-code-dev
- `ctest.passes()`, `ctest.fails()` — cpp-code-dev
- `phase.has`, `all_prs_implemented` — phase gates
- `ruff.*`, `api-diff.*`, `changelog.*` — referenced elsewhere

**Closes**: F-D4-017, F-D4-017a, F-D4-018. Deferred until ADR-005a closes F-D4-003.

### Open questions (for 005b later)
1. Should `goal.acceptance.met` read from `workspace/memory/goals.yml` (persistent) or from per-run state (transient)?
2. Concurrency: `goals.yml` has no locking; do we need a per-run state file?
3. Backwards compat: existing goals outside workflows (project/phase/PR-level) — does the builtin work for them too?

### Consequences
- 005a effort: S (~half-day for 2 files + tests).
- 005b effort: M (~2-3 days when scheduled).
- Closes: F-D4-003 (now) · F-D4-017/F-D4-018 (when 005b runs).
- Does NOT close: deeper goal-state semantics across non-workflow contexts.

---

## ADR-006 — Resume / compaction contract
**Date**: 2026-05-21
**Status**: ACCEPTED (Phase 1 C + Phase 2 B sequenced)
**Owner**: user (axon-polish)
**Source**: F-D9-002/003/004/008/011/013/014/022/023, master PR-9 + PR-15 (designed-not-built)

### Context
- 5 separate resume/recovery mechanisms exist (checkpoint.py, session_save.py, session.py, resume.md, boot RESUME); NONE are connected.
- `tools/session.py:recover()` is orphaned — function coded by master PR-15 but no entrypoint invokes it (F-D9-022).
- KERNEL-SLIM line 298 already MANDATES per-step phase tracking (`STORE(W:active-phase, "<prog>:step-N"`) — most programs are non-compliant.
- L:cognition-frame is on disk (longterm/), so compaction does NOT clear it; F-D9-004 ("PID mismatch") is the only reliable compaction sentinel.
- `processes/active/[P-NNN].md` is documented but no mechanism uses it (F-D9-023).

### Options considered
**A — Schema-versioned snapshot with auto-migration.**
Bump snapshot-version, add migrators, `checkpoint.py restore` subcommand, JSON session-log. M cost; introduces version concept that didn't exist; risk of migrator rot.

**B — Per-step active-phase ledger (enforce kernel mandate).**
Lint: every `### Step` heading → require corresponding `STORE(W:active-phase, ...)`. Add R_PHASE_TRACKED to verify.py. Audit existing programs, add missing STOREs. No new file format. Lightest concept, heaviest scope (many programs touched).

**C — Compaction detection via PID-mismatch hook in response gate.**
Response gate prepends `IF os.getpid() != stored_pid → TOOL(session, recover)`. Connects orphaned recover() to a real trigger. Replaces "never fires" with "fires on every fresh process turn 1". Small kernel edit + 1 session.py wire-up.

**D — Full kernel resume-invariant contract.**
Each program declares `# resume-invariant: [W:keys-needed]`. session_save preserves declared keys without cap. Largest scope; over-engineered for current problem set.

### Decision (proposed)
**B + C combined** (sequenced):
- **Phase 1 — C (compaction hook, S)**: wire `session.recover()` into response gate via PID check. Connects half-built infrastructure (F-D9-022 closed). Restores compaction detection without any other mechanism change.
- **Phase 2 — B (phase ledger enforcement, M)**: ship R_PHASE_TRACKED + audit. Closes F-D9-002 (workflow-run no active-phase) + makes resume from arbitrary multi-step program safe.
- **Defer A and D**: address F-D9-003/008/013/014 in a follow-up ADR-006b only after B+C reveal what's actually missing in practice. Don't pre-engineer schema versioning before evidence demands it.

### Consequences
- Phase 1 effort: S (~half-day, kernel edit + 1 hook).
- Phase 2 effort: M (audit programs, add rule, fix non-compliant programs ~1-2 weeks).
- Closes immediately: F-D9-022 (orphaned recover), F-D9-004 (compaction detection).
- Closes after B: F-D9-002 (workflow-run active-phase), F-D9-011 partial (G-02 has a second safety net via mtime).
- Defers: F-D9-003 (no checkpoint restore), F-D9-008 (snapshot-version unread), F-D9-013 (2KB cap), F-D9-014 (resume-reads-markdown), F-D9-023 (processes/active dead).
- master PR-9/15 alignment: this IS master's PR-15 with an entrypoint added; PR-9 state-enum could fold in during Phase 2.

### Open questions
1. Should boot step 3 also call `session.recover()` (in addition to response gate)?
2. PID check stored where — `workspace/memory/local/session-pid.md`?
3. What's the "audit existing programs" cadence — single sweep PR or one-per-PR as touched?

---

## ADR-007 — workflow-run ↔ orchestrator boundary
**Date**: 2026-05-21
**Status**: ACCEPTED (Option C — light bridge)
**Owner**: user (axon-polish)
**Source**: F-D4-001 (orchestrator fixed-mode unreachable), F-D4-002 (workflow-run never enters orchestrator loop), F-D4-011 (mixed candidate types), F-D4-014 (workflow-run no follow-up suggestion)

### Context
- workflow-run owns the loop, the cursor, the next-id decision via on-complete predicates.
- orchestrator is single-tick (NOT a loop); ranks + decides fire/ask/surface in one shot.
- The two are SHIP-SIBLINGS from PR-115 (workflow-lifecycle) and PR-111 (orchestrator) cohort, with no integration spec.
- `W:orchestrator-last-tick` is the ONLY mechanical link to PR-112's suggestion footer. workflow-run never writes it → footer is dark during workflow runs.
- axon-synapse RETRO confirms the lack of coupling is **accidental**, not deliberate.

### Options considered
**A — workflow-run dispatches THROUGH orchestrator on every step.**
workflow-run STOREs active-workflow/step; calls orchestrator for next-id selection. Orchestrator's fixed branch wakes up. Schema mismatch risk (on-complete predicate chains vs `steps[i].next` flat read). Medium scope. ~3 files. Behavioral risk: introduces pause points (decide → "ask") into workflows.

**B — orchestrator OWNS the loop; workflow-run becomes thin entry.**
workflow-run collapses to ~30 lines (load + preflight + loop wrapper). orchestrator grows + becomes iterating. Largest blast radius (~5 files + reference workflows re-validate). Conflicts with composition-only "ranker = pure function" invariant.

**C — keep separation, add 2-line bridge.**
After each `EXEC(cursor.name)`, workflow-run adds `STORE(W:active-workflow=wf), STORE(W:active-workflow-step=cursor.id), EXEC(orchestrator)`. Orchestrator runs in observe-only mode (gated by a `bridge-mode` flag — skip the `ACT` fire block to avoid double-firing). PR-112 footer wakes up via `W:orchestrator-last-tick`. Reference workflows untouched. ~2 files; smallest blast radius.

### Decision (proposed)
**Option C — light bridge.**

Three reasons:
1. **Smallest blast radius**: ~2-line addition to workflow-run + 1 guard in orchestrator. 5 reference workflows untouched. Predicate-walk semantics preserved.
2. **Doesn't break R12 / composition-only invariant**: orchestrator stays single-tick, pure-composition role.
3. **Solves the headline defect**: PR-112 footer fires during workflow runs; integration is reversible (delete 2 lines if it misbehaves).

### Required guard
Orchestrator must detect bridge-mode caller (e.g. `W:active-program ≡ "workflow-run"` at entry) and skip the `ACT` block to prevent double-firing. Spec implication: 5-line if-block in orchestrator.md after RECORD.

### Required cleanup
- `CLEAR(W:orchestrator-last-tick)` at workflow-run's DONE — prevents stale workflow candidates surfacing in the next free-text turn (RETRO risk #2).

### Consequences
- Effort: S (~half-day; 2-line + 5-line + 1 cleanup).
- Closes: F-D4-002 (no integration), F-D4-014 (no follow-up suggestion).
- Partial: F-D4-001 (orchestrator fixed-mode wakes up but underlying schema mismatch on `workflow.steps[i].next` vs predicate-chain remains — defers to ADR-007b).
- Does NOT close: F-D4-011 (mixed candidate types between fixed/adaptive returns).

### Open questions
1. Should `W:current-goal` be stamped to `wf.default-goal` on workflow entry? Currently orchestrator requires it (D-007) and workflow-run doesn't set one.
2. `wf.default-goal` is what shape — a Goal record? A reference? Different from `goals.yml` entries?
3. Long-term: do we want Option A (full integration) as a future ADR-007b, or accept that fixed and adaptive workflows have intentionally different runtime models?


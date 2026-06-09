# 04 — W5 design: rebuild `multiple-code-dev` so it actually runs

Source of bugs: `02-mcd-deepstudy.md` (the 3-agent audit). The concept (loop a code-dev cycle until a goal-audit
passes) is sound; the shipped wiring never executed end-to-end (the "10 green iters" were `iter-helper.py`
hardcoding `advance(s4→s6)`). This doc turns each finding into a concrete fix + a gate-first sub-PR decomposition.

W5 source lives ONLY in `review/mcd-141` (deferred, never merged): `multiple-code-dev.yml` + 6 programs
(goal-set, goal-audit, iterate-or-stop, audit-to-study, code-dev-study seed, + the HANDOFF doc) + a seed test.
Per memory `axon-foreign-program-integration`: each brought program needs register/structure/single-accessor and
NO foreign compiled mirror.

## Root mechanism — how the loop should flow (the corrected model)
`s1 goal-set → s2 code-dev (sub-workflow, anti-skip) → s3 goal-audit → s4 iterate-or-stop (gate) →`
  · green  → s6 finalize → s7 DONE
  · iterate → s5 audit-to-study (seed next lap) → back to s2
  · abort  → s7 DONE (clean terminal, NOT a FAIL)

The decision travels program→runner through a **W: key** (AXON's inter-program channel). The runner evaluates
edge `if:` predicates through `predicate.py`, whose SCOPES are `{W,L,E,state,project,phase,workflow,pr,neuron}` —
**`decision` is not a scope** (bare ident → `Ref("state",…)` → null → false → BREAK). Use the existing `W` scope.

**VERIFIED (2026-06-05), and it makes C1 a 2-line fix — no runner change:** `predicate eval` resolves the `W`
scope from **LIVE memory** even when `--ctx` is supplied with only `state` — tested:
`predicate eval --expr 'state.steps == 1 AND W.code-dev-project != ""' --ctx '{"state":{"steps":1}}'` → true;
`'W.mcd-decision == "green"' --ctx '{"W":{"mcd-decision":"green"}}'` → true / `"iterate"` → false. The runner's
edge loop (workflow-run.md:226-231) already calls `predicate eval --expr "{rule.if}" --ctx "{ctx}"` with the
state-only ctx (line 183), so an edge `if: W.mcd-decision == "green"` resolves at runtime with NO change to how
the runner builds ctx. The earlier worry ("extend the runner ctx to include W") is moot.

## CRITICAL fixes
- **C1 · route the gate decision.** `iterate-or-stop` already computes `decision ∈ {green,iterate,abort}` as a
  local; add `STORE(W:mcd-decision, decision)`. Rewrite `multiple-code-dev.yml` s4 edges:
  `if: W.mcd-decision == "green" → s6` · `== "iterate" → s5` · `== "abort" → s7`. (predicate v1.1 supports
  `==` on a W ref + string literal — verify with `predicate eval --expr 'W.mcd-decision == "green"' --ctx
  '{"W":{"mcd-decision":"green"}}'`.)
- **C2/C3 · per-lap sub-run-id.** The sub-run-id `{parent_run_id}::{parent_node}::{sub_name}` has no iteration
  component, so lap-2 re-enters s2 with the same id → lap-1's stale terminal trajectory satisfies
  `sub_workflow_completed()` (skip allowed) AND `record_step` appends → `[s1,s7,s1,s7,…]` → `WorkflowJumpError`.
  Fix in the RUNNER: include a per-lap counter in the sub-run-id (e.g. append `::lap{W:multiple-code-dev-iter}`),
  so each lap gets a fresh sub-trajectory. The lap counter is the workflow's iter key — thread it into `advance`.
- **C4 · abort → clean terminal.** Add the `if: W.mcd-decision == "abort" → s7` edge (above). iterate-or-stop
  no longer FAILs on cap/fatal — it sets decision=abort and lets the edge route to the DONE terminal. Add a YAML
  exhaustiveness assertion (every iterate-or-stop outcome has an edge) to a lint.
- **C5/H1 · goal-criteria channel.** `goal-set` must copy the workflow's `default-goal.acceptance-criterion` /
  `rejection-criterion` into `W:current-goal` (today it writes only id/statement/set-at). Then goal-audit's
  existing `accept-pred ← goal.acceptance-criterion` fires, and it must WRITE `verdict.pass` +
  `verdict.unresolved-bug-after-pr` / `verdict.fatal` into `W:last-audit-verdict` (today those are never set, so
  iterate-or-stop's fatal/pass branches are inert). The YAML accept/reject predicates evaluate against a real
  `verdict` once it is populated.

## HIGH fixes
- **H2 · seed field-names.** `audit-to-study` writes `iteration` / `evidence.failing-tests` / `evidence.recent-merge`;
  `code-dev-study` reads `seed.iter` / `seed.failing-tests` / `seed.recent-merge` / `seed.verdict`. Align on ONE
  schema (rename writer or reader; include `verdict`). One source of truth for the seed record shape.
- **H3 · W:-key reset.** Add a reset at run start (in goal-set, or a tiny `mcd-reset` step at s1): clear
  `W:multiple-code-dev-iter`, `W:last-audit-verdict`, `W:mcd-decision`, the seed + goal keys — so a 2nd in-session
  run doesn't inherit a stale iter (cap mis-fires) or a poisoned verdict/seed.
- **H4 · the missing tests.** (a) drive the LOOP: s2 re-entered ≥2× under one parent-run-id with per-lap ids;
  (b) the abort/cap path reaches s7 cleanly; (c) depth≥3 nested run-ids don't collide (M1); (d) goal-criteria
  flow goal-set→goal-audit→iterate-or-stop produces green/iterate/abort correctly. These must FAIL on today's
  code and pass after the fix (no more grep-only/static-edge tests).
- **H5 · autonomous mode.** goal-audit falls to `QUERY(user)` when criteria are ∅ — but the loop is autonomous.
  When running under the meta-workflow with no criteria, either require criteria (FAIL fast at goal-set) or
  consult autonomy/AEGIS instead of blocking on a human.

## MED runner fixes (carry-over from W1's deferral)
- **M1 · run-id mangling non-injective** (`re.sub(r"[^A-Za-z0-9_.-]","_")` collides `::`→`__` with any `_`).
  Fix: hash or percent-encode the run-id for the filename; keep the logical id intact in the file body.
- **M2 · `terminals()` accepts a forgotten `on-complete`** as a legal terminal. Fix: require an explicit
  `terminal: true` (or a declared accept node) + a `check-stale`/`workflow-lint` rule that flags an unwired
  mid-node so a sub-run can't "complete" by stopping at a hole.

## Gate-first sub-PR decomposition (each: branch → build → gate → merge)
- **W5a — runner correctness** (`workflow_run.py` M1 hash-id + M2 explicit-terminal + per-lap sub-run-id C2/C3,
  with the threading hook for the lap counter) + unit tests (depth≥3 no-collision, lap-2 NOT skipped, malformed
  terminal rejected). Deterministic layer first — the teeth must be real before the loop relies on them.
- **W5b — the meta-workflow + programs** (bring + fix `multiple-code-dev.yml` W:-decision edges + abort terminal;
  goal-set criteria propagation + W: reset; goal-audit verdict-write; iterate-or-stop STORE(W:mcd-decision);
  audit-to-study/code-dev-study seed-schema align; H5 autonomous). Register all programs (generate); no foreign
  mirrors. Structure/kernel-pass each program.
- **W5c — end-to-end loop tests** (H4 a–d): the real proof the mirage never had — a 2+lap run on the real
  `workflow-run` path, abort path, depth≥3. Plus a workflow-lint exhaustiveness rule (C4) if not in W5a.

Open design checks before building (verify, don't assume):
- ✅ predicate `==` string compare on a W ref + the live-W bridge through `--ctx` — VERIFIED (see Root mechanism).
  C1 = `STORE(W:mcd-decision)` + edge rewrite only; no runner change.
- ⏳ C2/C3: how the runner passes the lap counter into the sub-run-id — `advance`/`record-step` take `--run-id`;
  the per-lap id likely composes in workflow-run.md (`run-id` for the sub EXEC includes `::lap{iter}`) rather
  than a workflow_run.py kwarg. Check where the sub-run-id is minted (workflow-run.md:160-164 sets parent keys;
  the child's run-id is minted in the child EXEC) — decide whether the lap suffix goes on parent-node or child id.
- ⏳ C5: whether goal-set can see the workflow's `default-goal` — workflow-run.md exposes `wf.default-goal`
  (line 114/118 read it), but goal-set runs as a child EXEC without `wf` in scope. Options: runner stores
  `W:current-goal-criteria` from `wf.default-goal` before dispatching s1, or goal-set re-reads the active
  workflow YAML (`W:_workflow-run-path`). Prefer the runner-side store (one place, no re-parse).

## W5b build notes (concrete, read from mcd-141 source — verify each on build)
- **C1 — already half-done.** `iterate-or-stop.md` already `STORE(W:_iterate-or-stop-decision, decision)`. Rename
  to `W:mcd-decision` (cleaner, no leading underscore for the predicate ref — verify `W.mcd-decision` lexes), and
  set the s4 edges to `if: W.mcd-decision == "green"|"iterate"|"abort"`. No new store logic needed.
- **C4 — remove the abort FAIL.** `iterate-or-stop.md` currently `IF decision ≡ "abort" → FAIL(...)` (raises →
  the cap surfaces as ERROR). Drop the FAIL; just store the decision + `DONE`. The `abort → s7` edge (C1 set)
  routes to a clean terminal. Keep the `EMIT("multiple-code-dev.abort", …)` for observability.
- **C5/H1.** `goal-set.md` writes only `{id,statement,set-at}`; `goal-audit.md` reads `goal.acceptance-criterion`
  (always ∅). Fix: runner stores `wf.default-goal` criteria into `W:current-goal` (or goal-set copies them), and
  goal-audit WRITES `verdict.pass` / `verdict.unresolved-bug-after-pr` / `verdict.fatal` (today never set, so
  iterate-or-stop's fatal/pass branches are inert).
- **H2 — same key, field-name skew.** Both use `W:code-dev-study-seed`. Writer (`audit-to-study.md`) emits
  `{iteration, open-gaps, evidence:{open-bugs, failing-tests, recent-merge}, prompt}`; reader
  (`code-dev-study.md`, +21 lines bring) wants `seed.iter`, `seed.failing-tests` (top-level), `seed.recent-merge`,
  `seed.verdict`. Align on ONE flat schema (`iter`, top-level `failing-tests`/`recent-merge`/`open-bugs`,
  `verdict`); fix the writer (and add `verdict`). NOTE: code-dev-study is an EXISTING main program — the bring is
  additive (the seed-ingest block); reconcile against main's current version, don't wholesale-replace.
- **H3 — reset.** `iterate-or-stop` already `STORE(W:multiple-code-dev-iter, iter+1)`. Add a run-start reset
  (in goal-set or an s1 reset step) clearing `multiple-code-dev-iter`, `last-audit-verdict`, `mcd-decision`,
  `code-dev-study-seed`, `current-goal` so a 2nd in-session run starts clean.
- **W5b also carries the visit WIRING** (from W5a): workflow-run.md computes the per-lap visit (count of the
  looping node's prior visits in `trace`) and threads it into the child run-id (`::v{n}`) + the `advance
  --parent-visit` call. Decide the off-by-one consistently (dispatch vs guard) — see W5a's `_sub_traj_run_id`.

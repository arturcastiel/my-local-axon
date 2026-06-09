# 02 — multiple-code-dev meta-workflow: adversarial deep-study (3-agent audit)

Owner asked for a thorough bug-hunt + harmonization before adopting W5 ("probably bugs… I see potential").
3 agents audited the runner, the programs, and integration/tests. Verdict: **the anti-skip RUNNER + lint suite
+ workflow-new hardening are solid (clean additive extension); the `multiple-code-dev` META-WORKFLOW is
NON-FUNCTIONAL end-to-end and needs major rework.** The concept is sound + worth building right.

## THE HEADLINE — the "10 green iters" are a mirage
`docs/MULTIPLE-CODE-DEV-HANDOFF.md` claims 10 successful iterations. They were driven by **`iter-helper.py`,
which HARDCODES `advance(s4 → s6)` (line 145)** — it never consults the gate decision, never routes through the
`if: decision.*` edges, never loops back to s2. So the gate, the goal-criteria, the seed channel, and the
loop-back edge have **NEVER executed on the real `workflow-run.md` path**. The feature built to stop "an agent
fabricating success without doing the work" had its OWN proof fabricated that exact way, one level up.

## CRITICAL — the meta-workflow cannot work as shipped
- **C1 · gate decision invisible to the runner.** YAML s4 edges `if: decision.green` / `if: decision.iterate`
  resolve through `predicate.py`, whose scopes are `W,L,E,state,project,phase,workflow,pr,neuron` — **`decision`
  is not one.** `workflow-run.md` builds ctx = `{state:{…}}` only. Both edges → `null` → false → runner sets no
  `next-id` → **BREAKs after the first s4**. The loop never iterates, never finalizes. (repro: `predicate eval
  --expr decision.green --ctx '{"state":{}}'` → false.)
- **C2 · loop anti-skip is HOLLOW after lap 1.** sub-run-id = `{parent_run_id}::{parent_node}::{sub_name}` —
  **no iteration component**. The loop re-enters s2 every lap with the *same* id → `sub_workflow_completed()`
  (which checks only `_last_node ∈ terminals`, no recency) is satisfied by **lap-1's stale trajectory** → code-dev
  need not re-run on lap 2+. The teeth bite exactly once — for the one workflow they were built for. (confirmed
  repro: lap-2 skip ALLOWED.)
- **C3 · loop re-entry corrupts the sub-trajectory.** Same id → `record_step` APPENDS → lap-2's first
  `advance(s1→…)` sees lap-1's terminal `s7` as `_last_node` → `WorkflowJumpError` (honest lap 2 hard-fails);
  file grows `[s1,s7,s1,s7,…]`.
- **C4 · `abort` has no edge + is modeled as FAIL.** `iterate-or-stop` produces green/iterate/**abort**, but
  s4 `on-complete` routes only green→s6, iterate→s5. On abort (cap or fatal) it `FAIL(...)` (raises) → the
  iteration cap ("tried 5×") surfaces as a workflow ERROR, not a clean terminal. No exhaustiveness check warns.
- **C5 · goal criteria never reach goal-audit.** `goal-set` writes only `{id, statement, set-at}`; `goal-audit`
  reads `goal.acceptance-criterion`/`-rejection-criterion` (always ∅) → **always** falls to `QUERY(user)`
  y/n/partial, and `verdict.unresolved-bug-after-pr`/`verdict.fatal` (lines 58-61) are **never set**. So the
  automated accept + the hard-abort are both inert. (The HANDOFF §7 even lists `W:current-goal-acceptance/-rejection`
  keys that NO program writes.)

## HIGH
- **H1 · YAML accept/reject criteria are decorative.** `acceptance-criterion: verdict.pass` /
  `rejection-criterion: "… OR iter >= max-iter"` are evaluated by the runner against the `verdict`-less ctx →
  always false (incl. the ACCEPTANCE-PREFLIGHT/CHECK). The only real cap is inside `iterate-or-stop` (which the
  runner can't route — C1).
- **H2 · seed channel: 4/6 read fields are null.** `audit-to-study` writes `iteration`, `evidence.failing-tests`,
  `evidence.recent-merge`; `code-dev-study` reads `seed.iter`, `seed.failing-tests`, `seed.recent-merge`,
  `seed.verdict` (never written). The audit→study feedback — the loop's whole point — surfaces mostly empty.
- **H3 · no W:-key reset.** Nothing resets `W:multiple-code-dev-iter` (only ever `+1`) / `W:last-audit-verdict` /
  the goal/seed keys at run start → a second in-session run inherits a stale iter (e.g. 10) → cap mis-fires on
  lap 1; stale verdict/seed poison the new run.
- **H4 · test gaps that shipped C1–C5 green.** NO test drives the LOOP (s2 re-entered ≥2× under one parent-run-id),
  the abort/cap path, or depth≥3. The "loop" test only asserts the *static* s4→s5→s2 edge exists; the gap-closer
  test only greps program text for "abort"/"max-iter". 43 tests pass while the feature is inert.
- **H5 · autonomous deadlock.** Because of C5, goal-audit always hits `QUERY(user)` — but this workflow exists to
  loop *autonomously*; there's no human to answer (workflow-run.md never consults autonomy/AEGIS).

## MED — runner robustness (these affect W1 anti-skip even WITHOUT the meta-workflow)
- **M1** filename mangling `re.sub(r"[^A-Za-z0-9_.-]","_")` is non-injective (`::`→`__`, but any `_`/punct also →`_`)
  → distinct logical run-ids collide at depth≥3 or with `_`-containing ids. Fix: hash/percent-encode the run-id.
- **M2** `terminals()` treats a synapse that merely *forgot* its `on-complete` as a legal terminal → a sub-run
  stopping at an unwired mid-node reads as "completed". Fix: explicit `terminal:`/declared accept node + a lint.
- **M3** completion ignores step `status` → a terminal recorded with `status:error` counts as success.
- **M4** malformed/bare-string trajectory silently mishandled (`["s7"]` passes as completed → forgery vector;
  `{"id":...}` vs `{"node":...}` drift reads as empty). Fix: validate shape on load.
- **M5** implicit name-match: with no explicit `sub-workflow:`, a synapse whose `name` is an installed workflow is
  gated *by default* → enforcement depends on the runtime workspace contents (non-deterministic across instances).
- **M6** the sheath: `--parent-run-id` optional at the Python boundary → omit it = no enforcement (author caveat 5).

## GOOD — what's genuinely solid (the keepers)
- The **+573 `workflow_run.py`** is a CLEAN ADDITIVE extension (new helpers + opt-in `advance` kwargs; existing
  paths untouched) — not a fork.
- **`iter-helper.py` + `tools/run_tests.py` are confirmed PURE SCAFFOLDING** — zero runtime callers (grep);
  safe to drop while keeping everything functional. (run_tests also name-collides with our existing `run-tests`
  program + has a known full-sweep hang — drop it.)
- The **anti-skip CONCEPT**, the **lint suite** (check-stale/templating/explain), and **workflow-new
  `validate_draft`** are sound and worth adopting (with the M-fixes for the runner).

## Harmonization recommendation
- **W1 anti-skip runner** — ADOPT, but fix M1–M6 (esp. M6 sheath, M3 status, M4 malformed). The teeth need to
  be real before they're worth having.
- **W2 lint suite** — ADOPT + tool-aware refine (the `synapse-suggest` false-positive) + wire BLOCK after W3.
- **W3 surfaced bugs** — fix the 5 (`code-dev-self-review`→`code-dev-review`) + 8 (library-dev templating).
- **W4 workflow-new** — ADOPT (validate_draft + questions registry).
- **W5 meta-workflow** — **NOT adoptable as-is — MAJOR REWORK** (it never ran). The concept is good + the owner
  sees potential, so rebuild it RIGHT: route the gate decision (thread `decision`/`verdict` into predicate ctx, or
  redesign the gate edges) [C1], per-lap sub-run-id so loop anti-skip actually bites [C2/C3], abort→clean terminal
  [C4], goal-criteria channel goal-set→goal-audit [C5/H1], seed field-names [H2], W: reset [H3], autonomous-mode
  handling [H5], + the loop/abort/depth≥3 tests [H4]. This is its own multi-PR effort, gated behind W1.

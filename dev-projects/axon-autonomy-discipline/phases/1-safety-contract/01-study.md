# Study — 1-safety-contract (axon-autonomy-discipline)

> Seed written 2026-06-03 from a long semi-autonomous AXON-dev session (the super-polish arc + the
> methodology discussion that followed). This is the run's primary context. `code-dev study` may refine
> it; `code-dev plan` turns §8 into a PR list. Target + acceptance: `../../masterplan.md`. Constraints:
> `../../_dont-do-seeds.md`. Sibling project: `axon-discipline` (the correctness floor).

---

## 0. What this project is

A **safe full-autonomous operating discipline** for AXON: the machinery that lets it run unattended
(overnight) on a code-dev project without drifting, overreaching, or silently breaking. Not advice — the
enforcing mechanisms (a contract, circuit breakers, a mandatory reanchor, deterministic selection, a run
report) plus the rules that become invariants the system checks.

**This is the autonomy floor.** Its sibling `axon-discipline` is the correctness floor (test harness,
anti-masking, coverage, ratchet). This project is what lets that one run overnight without a human.

---

## 1. The lessons (the lived failure catalog — this project's evidence)

These are real failures from THIS session's semi-autonomous run. Each yields an invariant. They are the
reason the project exists — not hypotheticals.

| # | What actually happened | The invariant it yields |
|---|---|---|
| L1 | **Committed a RED crucible gate twice** by chaining `git commit` right after the gate in one pipe, never checking `passed`. | Gate-parse is a SEPARATE step; commit is blocked until `passed:true`. A twice-red gate on the same change is a circuit-breaker HALT, not a retry. |
| L2 | **Worktree-isolation contamination**: a fan-out prompt hardcoded the main repo path as "working dir", so 27 parallel agents wrote to `main` concurrently — 16/26 returned diffs failed `git apply`. | Fan-out isolation invariant: each parallel agent works in its OWN worktree; hardcoding the shared tree is blocked. |
| L3 | **Context-compaction dropped the operating frame**: after a summarize, the session re-asked the persona chooser and the identity/goal/scope had to be re-derived from context. | Mandatory reanchor at every compaction/resume boundary — re-ASSERT identity + goal + dont-do + done-state + scope before acting. |
| L4 | **Stale memory acted-on risk**: the `MEMORY.md` index claimed F30 (alias deletion) was "deliberately NOT done" when it had already shipped (commit present, files gone). | Memory reanchor: validate a recalled memory against the code before acting on it. |
| L5 | **The 65-bug bulk fix did not hold** — a careful, gated bulk campaign still spawned 5 regressions + 10 new bugs, several inside the fixes. | No bulk landings: small single-concern PRs, each gated; plus an independent adversarial pass before trusting "done". |
| L6 | **Commit-msg hook rejections** cost cycles (`PR-PR-001`, then the `{cursor.id}` brand-ban hit). | The gate-as-ratchet WORKS (it caught the leaks) — but pre-lint the message (incl. server-side squash via `--stdin`) to avoid burning attempts. |
| L7 | **Crucible had fail-OPEN seams** (unresolvable change-set base → the gate could pass blind). | Fail-closed everywhere; an unresolvable precondition is a STOP, never an implicit pass. |
| L8 | **Producer-only tests masked wrong behavior** (a test asserted the buggy form). | (Correctness floor — owned by the sibling `axon-discipline`; cross-referenced because it co-occurs with autonomous bulk work.) |

---

## 2. The meta-lesson

**Intention decays; enforcement does not.** L1 is the proof: I *knew* the rule (parse the gate
separately) and broke it anyway under the press of a long run. A long autonomous session is precisely
the condition under which "the agent will remember to" fails. So the entire discipline is one move
applied everywhere: **convert each soft intention into a hard invariant the system checks** — at the
gate (L1/L7), at fan-out (L2), at compaction (L3), against memory (L4), in change size (L5), in commit
hygiene (L6). If a rule only lives in prose the agent is trusted to follow, it is not yet part of the
discipline.

---

## 3. The design — three decaying floors

A long unattended run decays three things. The discipline is the machinery that RENEWS each:

- **Identity floor → mandatory reanchor.** AXON reanchors *identity* per-program already
  (`ASSERT(L:cognition-frame ≡ "AXON-OS")`). Extend to a periodic full-frame reanchor at every PR and
  every compaction/resume boundary: re-*assert* identity + goal + acceptance + dont-do + done-state +
  scope, and the working invariants (branch matches `_meta`, dev-mode as expected, no uncommitted drift,
  gate green, goal not already met). Fail closed. Include the memory reanchor (L4). (Substrate: IDENTITY
  LOCK + `session.py` checkpoint/transition.)
- **Authority floor → contract + circuit breakers + escalation.** Autonomy is rules becoming
  machine-enforced because no one is watching. A run declares a contract (goal, acceptance predicate,
  scope allow-list, op allow-list, budget); breakers halt-and-surface on the L1/L5 conditions; an
  escalation surface defines when to stop and ask. (Substrate: `autonomous_mode.py` grants — ALWAYS_DENY
  kernel-change, destructive default-off — are the hard floor this layer sits above.)
- **Mission floor → deterministic feature selection.** "What next" is itself a drift vector. Selection
  walks the ready-frontier of the plan DAG (deps merged), gated by a Definition-of-Ready; risky items
  auto-escalate. Not a free choice. (Substrate: `plan_dag.py` + `depends-on` + `synapse-suggest`.)

Two cross-cutting guards: the **two-key rule** (irreversible action needs gate-green AND an independent
check) and the **run report + replay** (auditable in minutes, replayable to a divergence).

---

## 4. Existing substrate — build on it, don't reinvent

- `tools/autonomous_mode.py` — grant model: `ALWAYS_DENY=("kernel-change",)`, `DESTRUCTIVE_OPS`
  default-off, per-grant `destructive` allow-list, `--destructive` CLI. (From MR !108.) The contract is
  the entry gate layered on this.
- `tools/accountability.py` — `open` / `reconcile` / `status` ledger. Make reconciliation mandatory at
  run-end; an unreconciled entry = the run didn't cleanly finish.
- IDENTITY LOCK + `tools/session.py` (checkpoint / transition) — substrate for the reanchor.
- `tools/plan_dag.py` + PR `depends-on` + `synapse-suggest` ranking — substrate for selection.
- workflow trajectories (`workspace/memory/episodic/workflow-traj/`) + `code-dev-replay` — substrate for
  the run report + replay.
- crucible gate (22 controls, fail-closed) — the correctness floor the autonomy layer leans on; add new
  controls here (e.g. contract-conformance, reanchor-present) so the discipline is enforced, not advisory.

---

## 5. The precise gaps (what's missing for safe autonomy)

1. **No autonomy contract** — nothing declares/enforces a run's scope + op allow-list + budget up front;
   scope is implicit, so "stay in scope" is a judgment call mid-run (and judgment decays).
2. **No circuit breakers** — nothing forces a HALT on twice-red gate / repeated failure / out-of-scope
   touch / budget exhaustion. The run pushes through (L1).
3. **No full-frame reanchor** — identity reanchors per-program, but goal/scope/done-state/invariants do
   not, and nothing fires at the compaction boundary where drift peaks (L3/L4).
4. **Selection is free choice** — no DAG-ready-frontier gate, no Definition-of-Ready (L5 territory).
5. **No standard run report / replay wiring** — auditing an overnight run means re-reading everything.
6. **Fan-out isolation is by-convention, not enforced** (L2).

---

## 6. Target + acceptance

See `../../masterplan.md` for the sharply-stated target and the 8 acceptance criteria. In one line:
*an overnight run cannot drift past a reanchor, cannot act outside its contract, cannot push through a
red/ambiguous state, cannot wander off-mission, and is auditable + replayable.*

---

## 7. Phase graph (see masterplan.md)

- **1-safety-contract** (this phase): the Authority floor — contract + circuit breakers + escalation.
  The MVP of safe autonomy; nothing else is safe to run without it.
- **2-reanchor**: the Identity floor — mandatory reanchor + memory reanchor.
- **3-selection**: the Mission floor — deterministic DAG selection + Definition-of-Ready/Done.
- **4-observability**: run report + replay + two-key rule + fan-out isolation invariant; wire the new
  gate controls.

---

## 8. This phase — candidate PRs for `code-dev plan` (sketch, not final)

Small, single-concern, gated. Suggested sequence:

- **PR-A — the contract schema + loader (tool).** Define the autonomy-contract record (goal, acceptance
  predicate, scope allow-list, op allow-list, budget) and a loader/validator. Decide where it lives
  (ADR-001). Unit-tested to the 100/80 floor. Build on `autonomous_mode.py` (the op allow-list maps onto
  its grant model).
- **PR-B — scope + op enforcement.** Given a contract, a check that a proposed file-write/op is inside
  the allow-list; an out-of-scope attempt returns a structured STOP (not a silent pass). Tested with
  in-scope/out-of-scope cases.
- **PR-C — circuit breakers (tool + wiring).** Implement the halt conditions (same-change gate-RED twice,
  N consecutive failures, out-of-scope touch, escalation-surface op, budget exhausted) as a small
  state-machine that, on trip, writes a resumable checkpoint + a ledger entry + a surfaced question.
  Each breaker gets a test (the L1 case first — twice-red → halt).
- **PR-D — escalation protocol.** Enumerate the escalation surface; on hit, stop + queue the question +
  checkpoint. Define how a question surfaces with no live session (ADR-003).
- **PR-E — make the contract the entry gate.** A run cannot enter overnight mode without a valid
  contract; wire a crucible WARN control `autonomy-contract` that checks an active run has one. (BLOCK
  later, once proven.)

Open questions for study/plan: exact contract representation + storage (ADR-001); how a breaker halts +
checkpoints (ADR-002); the escalation-question channel (ADR-003); how the budget is measured (PR-count
is simplest and deterministic; wallclock/token need a meter).

---

## 9. Constraints

See `../../_dont-do-seeds.md`. Prime ones: the contract/breakers must be ENFORCED by code, not trusted
to the agent (the whole thesis); never push through red/ambiguous; stay in contract; reanchor at
boundaries; two-key for irreversible actions; fan-out isolation; never erode `autonomous_mode` ALWAYS_DENY;
plus the standing floor (gate-first, no bulk PRs, merge discipline, dev-mode only for `axon/`).

---

# Part B — Grounded study (per the `code-dev study` directives, 2026-06-03)

Three parallel reads of the codebase — *powers/grants · identity/reanchor · AXON-native integration* —
returned one decisive finding: **AXON already owns nearly all the parts.** This project is far less
"build new machinery" than "**unify + wire + enforce what already exists**." That shrinks phase 1 and
makes the discipline maximally idiomatic (the directive: "following AXON architecture and its programs").

## B1. Disciplining AXON — the enforcement substrate that already exists
- **Crucible gate** — 22 controls, fail-closed (`tools/crucible.py`, `crucible.json`); the merge floor.
- **AEGIS triad** (`tools/aegis_policy.py`) — GRANT × GATE × POLICY + AUDIT over 5 capabilities
  (develop / test-execution / build / pr-create / merge), each `human | grant | green-only | auto`;
  `INVIOLABLE = {kernel-edit, force-push, reset-hard, branch-delete, destructive}`; `GATED = {test-execution, merge}`.
- **Grant model** (`tools/autonomous_mode.py`) — per-repo, per-op; `ALWAYS_DENY=("kernel-change",)`,
  `DESTRUCTIVE_OPS` default-off, per-grant allow-lists, audited to `autonomous-mode-audit.jsonl`.
- **dev-mode / R9** (`tools/rules/r9_axon_write.py`, `enforce.py`) — gates `axon/` writes on `L:dev-mode`.
- **accountability** (`tools/accountability.py`) — open/reconcile/status ledger of delegated work.
- **axon-reanchor + drift** (`workspace/programs/axon-reanchor.md`, `tools/drift.py`, `axon_drift_log.py`)
  — identity re-grounding + quantitative drift score + per-turn forbidden-phrase scan.
- **rules pack + freshness** — `tools/rules/r_*.py` + `lint_summary.py`; `freshness.py`.
The discipline is built BY COMPOSING these, not replacing them.

## B2. Querying the user for powers — the contract  (directive: "query user for powers to give")
**Finding — two DECOUPLED authority systems, and no interactive ask:**
- **AEGIS policy** = high-level capability delegation, configured in `_policy.md`.
- **autonomous-mode grant** = low-level per-repo/op authorization (`grant_on(...)`), CLI-flag-driven.
- The ONLY interactive authority flow is `config.md`'s wizard (`TOOL(decide,...)` asks the autonomy
  *level* → writes `_policy.md`). It sets POLICY, never the GRANT.
- **GAP:** nothing asks the human "*which* powers, for *which* scope, with what *budget*," then writes
  the actual grant. Powers require CLI flags the operator must already know.

**Design — `autonomy-contract.md` (new program):** via `TOOL(decide,...)`, walk the human through
(1) scope (repo + file/dir allow-list), (2) capability policy (→ AEGIS `_policy.md`), (3) op allow-list +
any destructive ops (→ `autonomous-mode on --repo … --ops … --destructive …`), (4) budget
(PR-count / wallclock / token). It **unifies the two decoupled systems behind one human-readable
contract**, then opens an `accountability` entry recording the granted powers. It is the **entry gate**
to overnight mode (a run can't start unattended without an active, in-date contract; enforced by a
crucible WARN→BLOCK control `autonomy-contract`). Least-privilege by construction: it only selects
*within* what the grant model already permits — it never widens `INVIOLABLE`/`ALWAYS_DENY`.

## B3. "Always AXON" — reanchor  (directive: "make axon always axon, following its programs")
**Finding — the mechanism ALREADY EXISTS:** `workspace/programs/axon-reanchor.md` (PR-CA-102) re-loads
KERNEL-SLIM + LANG, restores `L:cognition-frame="AXON-OS"` + `W:reasoning-mode`, seeds the reasoning
trace, scans for forbidden phrases (→ `axon-drift-log`), and runs the G-02 every-5-turns identity check.
Identity is SET at boot (KERNEL-SLIM G-01, `STORE(L:cognition-frame,"AXON-OS")` :587), HELD in
`workspace/memory/longterm/cognition-frame.md` (survives restarts), CHECKED per-turn (cognition gate
:148) + every-5-turns mid-loop (G-02 :154–162).
- **THE GAP (the one that bit us this session):** on Claude Code, reanchor is MANUAL or boot-end only;
  on Copilot it's mandated per-turn by `.github/copilot-instructions.md`. `session.py.recover()` DETECTS
  compaction (PID mismatch) but does **not** re-assert identity. So the reanchor program exists but does
  not AUTO-FIRE at the compaction boundary on this harness — exactly why the persona chooser re-fired and
  the operating frame had to be re-derived from context (lesson L3).

**Design (maximally "following AXON's own programs"):** (1) **wire the existing program to auto-fire** at
the two boundaries that matter — compaction/resume (`session.recover()` → mandatory `EXEC(axon-reanchor)`
before any dispatch; seam: `boot.py.auto_recover_sessions()` or a kernel "compaction-reanchor gate") and
the PR boundary in an autonomous run; (2) **widen reanchor from identity-only to full-frame** for
autonomous runs — also re-assert the active project's goal + acceptance predicate + dont-do + done-state
+ scope, and the working invariants (branch matches `_meta`, dev-mode as expected, gate green, goal not
already met), failing closed on mismatch. It stays a normal program (synapse contract, READ + STORE +
ASSERT, R9-respecting) — reusing `axon-reanchor`, `session.py`, IDENTITY LOCK, and the L: scope. We add a
trigger + a wider assertion set, not a new subsystem.

## B4. Seamless integration — the AXON-native subsystem  (directive: "seamless integrate it")
**Recipes (grounded, cited):** a new PROGRAM = `# synapse:` header + `programs_registry generate` +
`synapse-validate` + a test (`R_NEW_NEEDS_TEST`); a new CONTROL = a `crucible.json` entry (WARN→BLOCK
pattern, e.g. `lint-summary-rules` / `liveness`, 2026-05-29); a new WORKFLOW = a YAML in
`workspace/workflows/` (fixed/adaptive/hybrid; `workflow-validate` → `workflow-simulate` → `workflow-run`);
a new RULE = `tools/rules/r_*.py` + `lint_summary` + an `L:<rule>-required` WARN→BLOCK flag. **Precedent
for "AXON governs AXON": `code-dev`** (91 programs + a router `code-dev.md` + phase-model enforcement) —
the exact pattern to mirror.

**Recommended subsystem (mirrors code-dev):**
- Programs: `autonomy-contract.md` (entry gate), reanchor (extend `axon-reanchor` or `autonomy-reanchor.md`),
  `autonomy-breaker-assess.md`, `autonomy-select.md`, and a thin router `autonomy.md`.
- Workflow: `workspace/workflows/autonomy-discipline.yml` — a FIXED workflow whose synapses ARE the
  discipline gates (contract → reanchor → select → breaker-assess), on-complete routing on state. This
  makes the discipline itself a first-class, validated, replayable workflow — dogfooding the engine.
- Rules + controls: `r_autonomy_contract_present.py`, `r_autonomy_in_scope.py`, `r_autonomy_breaker.py`
  (STATIC, WARN→BLOCK via `L:autonomy-discipline-required`), each wired as a `crucible.json` control so
  the discipline is enforced AT THE GATE, not advisory.
- Ledger + replay: every autonomous action `accountability open` → reconcile at run-end; the run report
  reads the ledger + the workflow trajectory (replayable via `code-dev-replay`).

## B5. The key insight (what this study changes)
**The project is ~70% wiring, ~30% new.** AXON already has the grant model, the policy resolver, the
reanchor program, the drift log, the accountability ledger, the workflow engine, the rule/control
machinery, and a self-governance precedent (code-dev). The genuinely NEW, high-leverage work is small:
1. the interactive **contract** that unifies AEGIS-policy + autonomous-grant by ASKING (B2);
2. **auto-firing + widening reanchor** at the compaction/PR boundary (B3);
3. the **circuit-breakers + deterministic selection** as rules + controls + a workflow (B4);
assembled as an AXON-native subsystem mirroring code-dev. Risk is low because each piece extends a tested
existing seam rather than inventing one.

## B6. Revised phase-1 PR sketch (supersedes §8 — sharpened by the findings)
- **PR-1** — `autonomy-contract.md`: `TOOL(decide,…)` powers interview → writes `_policy.md` + calls
  `autonomous-mode on …` + opens an accountability entry. Synapse-valid, tested, registered. (B2)
- **PR-2** — make the contract the entry gate: crucible WARN control `autonomy-contract` (no active,
  in-scope contract → warn; BLOCK once proven). (B2)
- **PR-3** — wire reanchor to compaction: `session.recover()` recovered=True → mandatory
  `EXEC(axon-reanchor)`; test the trigger fires before dispatch. (B3)
- **PR-4** — widen reanchor to full-frame for autonomous runs (goal/scope/done-state/invariant
  assertions; fail-closed). (B3)
- **PR-5** — first circuit-breaker as a rule: `r_autonomy_breaker.py` halts on a twice-red gate on the
  same change (lesson L1), WARN→BLOCK via flag; wired as a crucible control. (breakers)
Each: small, single-concern, red→green test, gated green, merged per discipline. PR-3/PR-4 touch
`session.py`/a kernel seam → confirm whether they need dev-mode (they may; plan accordingly).

## B7. Open questions for `code-dev plan`
- Does the reanchor-on-compaction wiring live in `boot.py` (auto-recover hook), a new KERNEL-SLIM gate,
  or a Claude Code UserPromptSubmit hook (`L:host-cap-reanchor="userpromptsubmit-hook"` is the named-but-
  unimplemented target)? Each has different dev-mode/F50 implications — decide in plan.
- Contract storage: one unified contract file that the program expands into `_policy.md` + a grant, or
  write both directly? (ADR-001.)
- Budget meter: PR-count is deterministic + cheap; wallclock/token need a meter — start with PR-count.

---

# Part C — THE CORE ISSUE: off-workflow freelancing is unpreventable today (the real target)

> Added 2026-06-03 after the project's own thesis reproduced LIVE: handed a direct instruction, the agent
> skipped `plan → pr-create → preflight` and implemented via raw `git checkout -b` + Write. This part
> SUPERSEDES B3's reanchor scoping (identity + project-frame was too shallow) and re-centres the project on
> the one demonstrated gap. The goal stated by the owner: **this can never happen again.** That is only
> achievable by ENFORCEMENT, not intention — so the study below is grounded in exactly what enforces (and
> what fails to enforce) the workflow today.

## C1. The failure, stated precisely
The agent did NOT lose identity (`L:cognition-frame` held the whole time). It lost the **workflow
position**: it was at `study` ✓ / `plan` ✗, and jumped straight to implementing — on a raw branch, with no
PR spec, no `_phases.json` entry, no preflight. Nothing stopped it. The only thing that eventually fired
was the full test suite catching 2 broken tests at gate time — a LATE code-quality check, not a
"you are off-workflow" guard. The behaviour was undetectable to the system until after the damage.

## C2. The grounded gap — why nothing stopped it (verified, with cites)
A deep read of every workflow-enforcement primitive returns ONE verdict: **off-workflow / out-of-order code
work is NOT preventable today.** Every primitive binds only WHEN YOU ARE ALREADY INSIDE code-dev:
- `skip-guard` (`tools/skip_guard.py:48-66`) — halts a skip, but ONLY when `code-dev skip` is invoked; raw
  git is never seen.
- `phase-model` (`tools/phase_model.py:90-103`) — advance/done require deps done, but ONLY when the tool is
  called; nothing forbids never creating `_phases.json`.
- `R_WORKFLOW_NODE_ORDER` (`tools/rules/r_workflow_node_order.py:78`) — validates `_phases.json` in-order,
  but is **provably SILENT when no `_phases.json` is in the diff** (`test_r_workflow_node_order.py:32-34`).
  A code-only changeset sails past.
- `R_NEW_NEEDS_TEST` (`r_new_needs_test.py`) — checks a new file HAS a test; binds to a test artifact, not
  a PR/phase. It PASSED my change *because I wrote a test*.
- pre-commit hooks — paths + commit trailer only; no phase/PR binding.
- `code-dev-preflight` / `safety-preflight` — VOLUNTARY programs, not mandatory; not in the gate's path.

**There is NO rule, hook, or gate that binds "a code change ↔ an open PR spec ↔ an active, in-order phase
in the loaded project."** code-dev is a user-facing WORKFLOW, not a kernel ENFORCEMENT GATE. The escape
hatch is simply: *don't call code-dev's phase commands.* That is the entire bug — and the reason my
freelancing was invisible.

## C3. The mechanism that makes recurrence IMPOSSIBLE (enforced, not trusted)
Two pieces, both reusing existing machinery. The FIRST is the teeth.

**(1) The gate rule — `R_CODE_CHANGE_REQUIRES_PR_PHASE` (the teeth).** A new changeset rule wired into
crucible's `run_changeset` loop (`crucible.py:176`). On a changeset that touches code (`tools/*.py`,
`workspace/programs/*.md`, `axon/**`, `tests/*.py`), it REQUIRES the loaded code-dev project to have an
ACTIVE phase AND an open PR spec (`03-prs/PR-*.md`) covering the changed files. Missing → **BLOCK** with a
redirect: *"code change off-workflow — run `code-dev plan` + `code-dev pr` first."* WARN→BLOCK via
`L:code-change-requires-pr-phase` (ship WARN, flip BLOCK once the existing backlog is clean). **This is the
rule that would have refused my freelanced commit.** With it active, the gate cannot pass an off-workflow
change — freelancing becomes impossible, not merely discouraged.

**(2) The reanchor — re-assert WORKFLOW POSITION, not just identity (this corrects B3).** In an autonomous
run the reanchor must re-assert: identity (via `axon-reanchor`) + the workflow position (active project /
active phase / the prescribed next step) + run the SAME off-workflow check PROACTIVELY (before the gate),
halting and redirecting if code work exists with no active phase/PR. The current `autonomy_reanchor.py`
(identity + grant + project-anchor) is necessary but would NOT have caught this — it must ALSO call the
workflow-position check.

Together: the reanchor catches off-workflow drift PROACTIVELY at boundaries; the gate rule REFUSES it
definitively at merge. Defense in depth — both enforced by code, neither trusting the agent to remember.

## C4. Why this is the right, AXON-native fix
It reuses `phase-model` (read the active phase), the PR-spec convention (`03-prs/`), the changeset-rules
harness (`crucible.run_changeset`), the rules pack + the `L:<rule>-required` WARN→BLOCK ladder, and the
reanchor program. No new subsystem — it CLOSES the binding gap in the existing one, turning code-dev from
"a workflow you may use" into "the only sanctioned path to a code change," enforced at the gate (the
kernel-level floor).

## C5. Testable acceptance ("never again" must be a TEST, per the ratchet)
- `test_r_code_change_requires_pr_phase`: a code-file changeset with NO active phase / NO covering PR spec
  → rule BLOCKS (when required); with an active phase + covering PR spec → None.
- reanchor workflow-position check returns a violation when code work exists off-workflow.
- **A regression that REPRODUCES this session**: "raw branch + code change, no plan/PR" → the rule blocks.
  The live bug becomes a permanent lock — exactly the ratchet (a bug found ⇒ a test before the fix).

## C6. Revised phase-1 plan (supersedes B6 — lead with the teeth)
1. **PR-1** — `R_CODE_CHANGE_REQUIRES_PR_PHASE` rule + test + crucible control (WARN first). The teeth.
2. **PR-2** — wire the SAME check into the reanchor (workflow-position): extend `autonomy_reanchor.py` +
   `autonomy-reanchor.md` to re-assert position + halt off-workflow; test. *(The existing draft tool +
   program become this PR's starting skeleton, revised to call the workflow check.)*
3. **PR-3** — the autonomy contract (powers interview) — unchanged from B2.
4. **PR-4** — circuit breakers (twice-red gate, etc.) — unchanged.
5. **PR-5** — flip `R_CODE_CHANGE_REQUIRES_PR_PHASE` WARN→BLOCK once the backlog is clean.

## C7. The meta-rule this encodes
"Intention decays, enforcement doesn't" now has a concrete first instance: an agent's *intention* to follow
the workflow is insufficient — the GATE must REFUSE a change that didn't go through it. The autonomy
discipline's #1 deliverable is therefore this binding (**code change ⇒ must be on-workflow**), because it
is the exact failure the project was born from, reproduced by its own author while building it.

---

# Part D — Acting THROUGH AXON: the anticipation layer + separation of powers (governing frame)

> Added 2026-06-03 from the owner's point: "in autonomous mode you choose what AXON gives, NOT what you
> want"; AXON has an anticipation layer you must LEARN and USE, not skip; "autonomous mode becomes stale if
> you don't." I studied the layer directly (orchestrator.md, synapse_suggest.py, anticipate.py). This is the
> governing frame the Part C gate rule serves.

**Autonomous mode, in one line (owner):** it **OPERATES AXON and its programs** — *use AXON, don't make
stuff up* — and **helps it reanchor when needed.** Everything below serves that definition.

## D1. The governing principle — separation of powers
One agent today both IS AXON (executes programs) and CONTROLS AXON (decides the work). With no boundary,
the controller silently overrides the executor — the freelance. The discipline splits them:
- **Director** — may invoke ANY AXON program (the full catalog, via `dispatch`/`EXEC`), suggested or not.
  Its freedom is wide WITHIN AXON; the boundary is hard and elsewhere: every action is a registered AXON
  program/tool invocation — never a made-up, off-AXON action (raw git, ad-hoc file write). *Use AXON, do
  not make stuff up.* The anticipation layer ASSISTS the choice; it does not fence it.
- **Executor (being-AXON)** — runs the chosen program in order, gated; holds the gate. Order + gates still
  bind: you may invoke any program, but you cannot make a code change off-workflow or skip a phase. The
  only path to a code change is the gated executor running a specced, in-order PR.
Criterion-zero (Part C: code-change ⇒ on-workflow) is ONE INSTANCE of this larger rule.

## D2. The anticipation layer IS the menu the director picks from (learned, grounded)
AXON already owns the layer; the discipline is to RUN it, not bypass it:
- `synapse-suggest` (`tools/synapse_suggest.py`) — `rank(state, goal, candidates)` → ranked entries
  (name, raw score, reasons). The candidate menu.
- `anticipate.py` — wraps the ranker with a MARGIN confidence `(top−second)/top` → density `fire` (≥0.50)
  | `suggest` (≥0.20) | `silent` (<0.20). Cardinal rule: a weak margin yields SILENCE, never a guess. Logs
  each prediction to `episodic/anticipation-log.jsonl` (accuracy scoring + replay).
- `orchestrator.md` — the loop: OBSERVE state → CANDIDATES (fixed: `workflow.next`; adaptive:
  synapse-suggest) → DECIDE → ANTICIPATE → RENDER the next-action set → RECORD (`W:orchestrator-last-tick`)
  → ACT. In BRIDGE-MODE (called by `workflow-run`) it is OBSERVE-ONLY — it surfaces; workflow-run dispatches.

## D3. inference-mode is the ask↔fire dial (the separation knob)
orchestrator DECIDE maps confidence × `L:inference-mode` (0–10) → `ask | surface-only | fire`: low (0–4) =
ask (director/human picks); 5 = graded (ask <0.7< surface <0.85< fire); high (6+) = fire on conf ≥0.6.
So "choose what AXON gives, not what you want" = act via the orchestrator's DECIDE on its surfaced
candidates — never by self-injecting. inference-mode tunes how much director approval each step needs.

## D4. Why autonomous mode goes STALE without it (owner's point, grounded)
The anticipation layer was "built + registered ACTIVE but invoked by NOTHING" until wired into the
orchestrator tick (orchestrator.md:121–127). If the orchestrator doesn't tick, `W:orchestrator-last-tick`
+ the anticipation log stop updating, the suggestion surface goes dark, and the agent drifts into
doing-what-it-wants (the freelance). USING the layer every step — observe → AXON's candidates → decide →
act-gated — is what keeps autonomous mode LIVE and on-workflow. Skipping it IS the staleness.

## D5. How I operate from here (act through AXON)
Every autonomous step: tick the orchestrator (or run inside `workflow-run`, which ticks it in bridge-mode)
→ consult the candidate menu + anticipation AXON surfaces (an ASSIST, not a fence) → choose a program —
which MAY be one outside the suggestion set — and invoke it through `dispatch`/`EXEC`, gated. The hard rule
is **use AXON, not make stuff up**: every action is a registered program/tool invocation, never a freelance
off-AXON action; and order + gates still bind (no code change off-workflow, no phase skip). The reanchor (PR-2) re-asserts
this frame at each boundary; the gate rule (PR-1) refuses any breach. The autonomy-discipline workflow
(the fixed `autonomy-discipline.yml`) should itself be driven this way — the discipline running on its own
engine.

## D6. Reanchor cadence (owner spec)
In autonomous mode, count the commands the agent issues to AXON; **every 5th command, AFTER AXON fully
responds, fire `autonomy-reanchor`.** This EXTENDS the kernel's existing `G-02` "every-5-turns" identity
check (`KERNEL-SLIM:154–162`) from identity-only to the FULL autonomy frame (identity + workflow position),
keyed on a command counter and fired POST-response (not mid-command). It is the periodic HEARTBEAT that
keeps the frame from going stale mid-run, and it COMPOSES with the boundary triggers (PR boundary,
compaction-resume). Mechanism: `W:autonomous-command-count`, incremented per agent→AXON command; reanchor
when `count mod 5 ≡ 0`. Wired in PR-005 (the operate-loop); it fires the PR-002 reanchor.

---

# Part E — Mitigations: the two 8/10 unknowns resolved (grounded, with residuals)

> Added 2026-06-03 after a deep read of `crucible.run_changeset` + the rules pack, and the kernel per-turn
> gate + `OUTPUT-LAYER` turn counter + the harness hooks. The two unknowns that capped plan confidence now
> have concrete, grounded designs with fallbacks. Residuals are named honestly, not hidden.

## E1. Gate-rule predicate (PR-001) — false positives bounded by construction
A changeset rule's `ctx` = `{changed_files:[{path,status}], repo_root}` (`crucible.py` run_changeset); it
does NOT carry W: scope, so the rule reads disk (the established `r_workflow_node_order` pattern). Predicate:
- **SILENT when no code-dev project is loaded** (read `workspace/memory/working/code-dev-project.md`) —
  the hotfix exemption; this alone removes the biggest false-positive class (a human edit outside a project).
- **"code"** = `tools/*.py` (not test_/__init__/rules), `workspace/programs/*.md` (not compiled/help/_*),
  `axon/*.md` (not _*), `tests/*.py` — the existing `r_new_needs_test._classify`. Everything else is EXEMPT:
  `CONTEXT.md`, `AXON-DOCS*`, `.github/`, generated artifacts, and the project's own meta files
  (`_meta.md`/`_phases.json`/`0N-*.md`/`03-prs/`).
- **"covering"** — WEAKEST SOUND definition FIRST: an active phase exists (`_phases.json` status=active)
  AND ≥1 open PR spec in `03-prs/`. Tighten to file-level (changed code ⊆ union of PR specs' `### <file>`
  lists) as a later refinement — shipped WARN so an imperfect file-match never hard-blocks early.
- **WARN→BLOCK** via `L:code-change-requires-pr-phase-required` (the `_required` pattern); `status="A"`
  grandfathers pre-existing.
- **Reproduction (ratchet) test**: "code change, project loaded, no active phase / no covering PR" → BLOCK;
  "active phase + covering spec" → None; "no project loaded" → None.
- **Residual**: file-level "covering" is heuristic (PR-spec format isn't rigidly file-listed) — de-risked by
  the weakest-sound fallback + WARN-first; tightened in the spec, proven by the reproduction test.

## E2. Reanchor cadence (PR-005/006) — ENFORCED not trusted, via a backstop
Findings: `W:turn-count` IS enforced per-turn (the kernel `OUTPUT-LAYER` increments it — runtime, not the
agent). A per-COMMAND counter does NOT exist. The Claude Code UserPromptSubmit hook is PROPOSED/inactive
(no hard real-time hook today); the every-5 `G-02` check is itself advisory; NOTHING verifies a reanchor
fired. So "trust me to reanchor every 5" is the real risk — the mitigation makes a lapse DETECTABLE
(detection = enforcement in AXON's gate model):
- **FIRE**: add `W:autonomous-command-count` incremented in `dispatch.py` (the runtime chokepoint for
  commands-to-AXON — enforced, not agent discretion); the orchestrator tick (and/or the next dispatch)
  fires `EXEC(autonomy-reanchor)` when `count mod 5 ≡ 0` in autonomous mode, post-response.
- **VERIFY (the teeth)**: a new `tools/autonomy_cadence.py` records the last-reanchor count in
  `workspace/memory/working/`, and a control `R_AUTONOMY_CADENCE` WARN→BLOCKs if the reanchor lapsed > 5
  commands. A silent skip is now CAUGHT at the gate — the cadence is enforced by detection, not trust.
- **Residual**: hard real-time enforcement (fire BEFORE the agent reasons) still needs a host hook
  (`L:host-cap-reanchor`, owner-install) — future; the backstop substitutes at gate granularity (a lapse is
  caught at the next PR boundary, itself a reanchor point). Counter basis = commands (the `dispatch`
  increment), honoring the owner's "commands" wording, not turns.

## E3. Effect on confidence (honest)
Both unknowns now have grounded mechanisms + fallbacks + named residuals — not hand-waving. Plan confidence
**8 → 9**. It is NOT 10 because two things only PROVE out in the specs/tests: PR-001's reproduction test
going red→green, and PR-006's backstop catching a simulated lapse. 10 is earned on green, not asserted in a
plan.

## E4. Plan delta (folds into the PR list)
- **PR-001** — gate rule, now with the precise predicate (E1) + the 7-case test incl. the reproduction.
- **PR-005** — operate-loop: `W:autonomous-command-count` in `dispatch.py` + orchestrator cadence fire (E2
  FIRE) + the `autonomy-discipline.yml` workflow.
- **PR-006 (NEW)** — cadence backstop: `autonomy_cadence.py` + `R_AUTONOMY_CADENCE` control (E2 VERIFY) —
  the "enforced not trusted" teeth for the cadence.
- **PR-007** — flip both gate rules (criterion-zero + cadence) WARN→BLOCK once the backlog is clean.

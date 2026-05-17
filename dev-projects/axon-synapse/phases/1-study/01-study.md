# Study — 1-study  ·  AXON Synapse

> Audit-first. Goals derived from findings, not asserted.
> Programs are synapses. AXON is the adaptive orchestrator.
> Workflows are emergent paths through the synapse graph.

## 0. North Star

> **Vision (user, verbatim).** "I see each axon program as a synapse, and axon
> orchestrates. … the idea is identify workflow — user has a task, you try to
> understand, and dispatch proper tools — code-dev has already this fixed — but
> I want something that adapts on the way — like axon signaling and going to
> other tools."

**Reframe in AXON terms.** A *synapse* declares: preconditions (what state must
be true to fire), inputs (W:/L:/files it reads), outputs (artifacts it writes),
post-state (what becomes true after it fires), and natural next-states
(suggested follow-up synapses, conditional on outcome). The *orchestrator* loop
is:

```
LOOP(task-not-done) {
  state    ← OBSERVE(W: + L: + recent-artifacts + git + project-meta)
  goal     ← RETRIEVE(W:current-goal)            # never ∅ during a task
  candidates ← RANK(synapses, by=fit(state, goal, history))
  IF top-candidate.confidence < threshold → QUERY(user, "Suggested: X. OK?")
  fire(top-candidate)
  observe-result; re-rank
}
```

The current code-dev hierarchy (study → plan → pr → log → audit) becomes one
*default workflow* — the orchestrator may follow it, deviate, or compose a new
path from the synapse graph.

---

## 1. Research questions (the spine of Phase 1)

### Q1. Tool inventory and graph (69 tools)

- Q1.1  For every tool in `workspace/tools/REGISTRY.json`, what is its **declared purpose**, **inputs**, **outputs**, **side-effects**, **upstream tools** (depends on), **downstream tools** (feeds)?
- Q1.2  Which tools are **ACTIVE** vs **PLANNED** vs **OPTIONAL**? Which `ACTIVE` tools have **zero call sites** in `workspace/programs/`?
- Q1.3  Which tools have **overlapping purpose** (e.g. `index` vs `study_index` vs `call_graph`)? Candidates for merge or clarification?
- Q1.4  Which tools have **no programs that surface them** to the user? Hidden tools that nobody discovers.
- Q1.5  Tool-frequency heat map from `workspace/tools/usage.py` — which tools are core, which are dormant?

### Q2. Program inventory and classification (174 programs)

- Q2.1  For every program in `workspace/programs/*.md`, what is the **declared `# desc:`**, **`# usage:`**, **`# outputs:`**, **`# next:`** metadata? Which programs are missing any of these?
- Q2.2  Classify programs by **family**: code-dev/*, library-dev/*, journal/*, meta/*, system/*, plan/*, igap/*, axon-audit/*, etc.
- Q2.3  Identify **entry-point programs** (user-invoked) vs **internal programs** (called by other programs only). Which internal programs have no callers?
- Q2.4  For each program: what programs does it suggest as **next** today (declared in `# next:`)? Build a static graph of program-to-program edges.
- Q2.5  Which programs are **redundant pairs** (e.g. `code-dev-init` vs `code-dev-new`, `code-dev-help` vs `code-dev-explain`)? Documented replacement path?

### Q3. code-dev's current "fixed hierarchy"

- Q3.1  Walk the canonical code-dev path: `new → study → plan → pr → log → audit`. What programs fire in each step? What are the **declared transitions**? Where does the path branch?
- Q3.2  Where is the hierarchy **enforced** vs **conventional**? Are there hard checks that stop you from calling `code-dev plan` before `code-dev study`?
- Q3.3  What **deviations from the hierarchy** exist in `my-axon/dev-projects/*/04-log.md`? Lived usage as ground truth.
- Q3.4  What **escape hatches** exist (e.g. `code-dev-flow`, `code-dev-cascade`, `code-dev-divide`, `code-dev-combine`, `code-dev-finalize`)? Are these synapse-y already?

### Q4. Goal derivation (per step / level)

For each level, ask: **what does success look like? what is the measurable artifact? what is the rejection criterion?**

- Q4.1  **Goal of a study** — does Phase 1 ship findings that materially constrain Phase 2 design choices? Or is it documentation that nobody reads downstream?
- Q4.2  **Goal of a project** — does the project end-state map to a real shipped change? Or is it a perpetual scratch-pad?
- Q4.3  **Goal of a plan** — does the plan produce a verifiable PR set with deps, budgets, and acceptance criteria? Or is it a wishlist?
- Q4.4  **Goal of a PR** — does each PR have an acceptance test, a rollback plan, and a measurable change? Or is it "files modified"?
- Q4.5  **Goal of code (impl step)** — does the code change satisfy a study finding? Is the finding cited in the PR?
- Q4.6  **Goal of an audit** — does the audit close findings, or does it just generate more findings?

Output: a **goal-schema** proposal (each phase/step gets a `goal:` field with measurable success/rejection criteria), staged for Phase 2.

### Q5. Workflow catalog (lived usage)

- Q5.1  From `my-axon/dev-projects/axon-master`, `axon-tests`, `axon-cleanup`, `axon-docs`, `axon-user` — extract every actual command sequence used. Cluster into **observed workflows**.
- Q5.2  Which workflows are **frequent** (>3 uses)? Which are **one-off**? Which **failed mid-way** and were abandoned?
- Q5.3  For each observed workflow: what is the **trigger** (user phrase / state)? What is the **terminator** (artifact produced)?
- Q5.4  Which workflows are **not yet codified as programs** but should be?

### Q6. Synapse contract (what a program must declare)

- Q6.1  Survey existing program headers (`# desc:`, `# usage:`, `# inputs:`, `# outputs:`, `# next:`). Which fields are present consistently? Which are missing?
- Q6.2  What additional metadata would make a program a *true synapse*?
  - `precondition:` — state predicate that must hold before firing
  - `post-state:` — state predicate that becomes true after firing
  - `goal:` — what user goal this synapse advances
  - `cost:` — token / time / risk budget
  - `confidence-decay:` — when does the suggestion-relevance expire?
  - `next-conditional:` — `{ if outcome=X → suggest [a,b]; if outcome=Y → suggest [c] }`
- Q6.3  Can we **derive** some of these by static analysis of program bodies? (E.g. post-state from `STORE(W:...)` calls.)
- Q6.4  What is the **minimum viable synapse contract** to bootstrap the orchestrator?

### Q7. Adaptive orchestrator design

- Q7.1  What signals does the orchestrator read each turn?
  - User input (intent classification?)
  - W: + L: state
  - Recent artifacts (`E:session-log`, `workspace/log/turns/`)
  - Active program / phase (`W:active-phase`)
  - Goal stack (new: who owns it?)
- Q7.2  How does it **rank candidates**? Static priors? Learned from `tools/drift` traces? Combination?
- Q7.3  When does it **interrupt** vs **suggest** vs **stay silent**? (Connects to `L:inference-mode` 0–10 ladder.)
- Q7.4  How does it **handle multi-synapse paths** (a plan that fires 5 in sequence)?
- Q7.5  How does it **recover** when a synapse fires and post-state ≠ expected?

### Q8. Auto-DAG (creation + mutation)

- Q8.1  Today's plan output (`02-plan.md` + `03-prs/*.md`) is markdown. Where does the **DAG** live (`DAG.md`, `DAG.json`)? Who reads it? `plan_dag` tool?
- Q8.2  When is the DAG **created**? Today it appears to be a manual step (`code-dev plan` → maybe DAG). User asks for **automatic** creation on every plan.
- Q8.3  What operations **mutate** the DAG? `merge`, `split`, `fold-in`, `defer`, `cut`, `add-pr`, `rename-pr`. Which programs implement each? Which silently drift?
- Q8.4  How is DAG **drift** from the markdown plan detected today? (`pr_drift`, `pr_sync`?) Is detection one-way (plan ← DAG) or two-way?
- Q8.5  What is the contract for "auto-DAG always reflects current plan"? Hook? Watcher? Post-write trigger?

### Q9. Workflow generator (auto-compose a workflow)

- Q9.1  Given a goal + current state, can AXON **synthesize** a workflow from the synapse graph rather than picking from hand-authored ones?
- Q9.2  Should generated workflows be **stored as compiled programs** (so they can be replayed) or always re-generated?
- Q9.3  Validation: does the generated workflow's predicted post-state match the goal? If not, regenerate or QUERY.
- Q9.4  How does the user **edit** a generated workflow before it runs?

### Q10. Suggestion engine (the user-facing surface)

- Q10.1  After every program completes, surface **"You might next want to: A, B, C"** — derived from `next-conditional` + ranker.
- Q10.2  When the user types free-text mid-session, classify intent + suggest top-3 programs **before** invoking any.
- Q10.3  Pop-up questions: when does the engine **ask** vs **act** vs **stay silent**? Confidence threshold + inference-mode interplay.
- Q10.4  "After implementing X → suggest self-review" — is this a **rule registry** (declared) or **learned** from history?
- Q10.5  UX: does the suggestion live in the output-layer footer? A dedicated panel? The menu?

### Q11. Nested DAGs at every level [D-009]

- Q11.1  Project-level DAG (phase graph) — today `masterplan.md` is prose. Migration to `DAG.json` + `DAG.md` per D-006/D-009?
- Q11.2  Phase-level DAG — what nodes exist within a phase? (For 1-study: research-questions → tracks → findings → synthesis.) Schema?
- Q11.3  Plan-level DAG — `code-dev plan` already emits one. How does the planner know which sub-graphs to spawn?
- Q11.4  PR-level DAG — when is a PR subdivided into sub-tasks vs handled atomic? Trigger heuristic?
- Q11.5  Study-level DAG — for THIS study, what is the nested graph? (Q1..Q13 → T-A..T-F → findings → synthesis.) Render it.
- Q11.6  Sync between nested levels — child-DAG nodes must appear as edges in parent-DAG. How is this enforced? (`dag-sync` extension.)
- Q11.7  File layout — `{node-dir}/DAG.json` + `{node-dir}/DAG.md` everywhere? What about leaf nodes that have no children — do they still have a DAG file (empty)?

### Q12. Shadowing enforcement [D-011]

- Q12.1  Today `code-dev-shadow` and `code-dev-knowledge-shadow` exist. What does each actually produce? Schema?
- Q12.2  Which PRs in existing dev-projects (axon-master, axon-tests, axon-cleanup) have shadow files vs not? Coverage %?
- Q12.3  What is the minimum content of a shadow file (changed files, finding citations, test impact, rollback hints)?
- Q12.4  Enforcement points — at `code-dev pr` finalize? At `code-dev audit`? Both?
- Q12.5  Migration — how do existing PRs without shadows get retroactively shadowed?
- Q12.6  Auto-shadow — can the orchestrator auto-generate a shadow file from git diff + finding-search, then ask user to review?

### Q16. Synapse + Workflow registration [D-016, D-027, D-028]

- Q16.1  Synapse registration today — REGISTRY.json auto-loaded by boot.
  Programs in `workspace/programs/` discovered by glob. Are there OTHER
  registration paths (axon.py CLI, cron, hooks)? Catalog them.
- Q16.2  Conversational workflow author — design the prompt-flow.
  Sample script: "Describe your workflow in plain English." → user types →
  AXON proposes synapses + DAG → "Step 1: code-dev-study. OK?" → iterate.
  How does AXON propose? Free-text intent classification against synapse
  catalog → top-k → render.
- Q16.3  Workflow file schema — what fields does `workspace/workflows/{name}.yml`
  need? At minimum: `name`, `domain`, `goal`, `execution-mode`,
  `synapses` (DAG), `triggers`, `acceptance`. What else?
- Q16.4  Workflow validation — when loaded, does it ASSERT each named
  synapse exists in the registry? Reject load if any synapse missing?
- Q16.5  Workflow versioning — `version: 1`? Replace on overwrite? Or
  history-preserving?

### Q17. Fixed vs Adaptive execution modes [D-017, D-029, D-030]

- Q17.1  Glossary lock — define **Fixed** vs **Adaptive** vs **Hybrid**
  workflow execution. Specify default per workflow source (manual-author,
  conversational, free-text).
- Q17.2  Fixed-mode plumbing — given a workflow file with N synapses,
  how does the orchestrator walk it? Sequential queue? DAG topological
  sort? Both?
- Q17.3  Adaptive-mode plumbing — at each step the orchestrator picks
  from synapse-catalog ranked by `fit(state, goal, history)`. How is
  ranker scored? Pure rule-based for Phase 3.
- Q17.4  Suggestion firing inside Fixed mode — sideband vs deviation
  semantics. UX: footer line vs separate pop-up. (Connects to OQ-03.)
- Q17.5  Deviation accepted — does the orchestrator EDIT the workflow
  file or RUN one-off? Both? Per-deviation classification (one-off
  vs persistent).
- Q17.6  Hybrid mode — workflow declares `step-mode: fixed/adaptive` per
  step. How does the orchestrator hand off between modes mid-run?
- Q17.7  Suggestion suppression — user dismisses a sideband suggestion
  3 times → demote weight (D-010 promotion threshold mirror).

### Q15. Workflow OS — generalizing beyond code [D-015, D-014]

The vision is a workflow OS where code-dev is one domain, science-dev /
study-dev / others plug in via the same primitives. Vocabulary must be precise
or the abstraction will leak code-specific concepts.

- Q15.1  Glossary precision — fix one meaning each for: workflow, synapse,
  domain, orchestrator, project, phase, plan, goal, step, transition,
  state-vector, post-state, precondition, role, family.
- Q15.2  Code-specific terms in existing AXON — sweep `axon/`, `workspace/`
  for code-specific assumptions (compile, build, test, PR, branch, commit,
  rebase). Which are kernel-level (must be generalized) vs domain-level (stay
  in code-dev domain)?
- Q15.3  Existing code-dev programs — which are **domain-bound** (e.g.
  `code-dev-rebase`, `code-dev-finalize` reference git operations) vs
  **domain-agnostic** (e.g. `code-dev-plan`, `code-dev-study`, `code-dev-audit`
  could be hoisted to a generic `flow-plan`, `flow-study`, `flow-audit`)?
- Q15.4  Domain-folder layout — `workspace/domains/{name}/` contains what
  exactly? Workflow files, domain-specific programs, file-convention spec,
  vocabulary glossary, default goals?
- Q15.5  Backwards compat (D-014 / D-025) — invocation `code-dev plan`
  continues to work after generalization. How? Forwarders? Domain-aware
  resolver? Both?
- Q15.6  Science-dev / study-dev sketches — what does a non-code workflow
  look like? Sample: science experiment domain — `hypothesis → design →
  preregister → run → analyze → write → review → publish`. Sample: study
  domain — `pick-source → read → notes → synthesize → present → review`.
  Where in the kernel do these slot in without code-specific scaffolding?
- Q15.7  Existing `library-dev` — already a non-code-implementation domain
  (ingest PDFs, shadow, explain, intersect, report). Does the current
  `library-dev` structure validate the multi-domain vision, or does it
  reveal limits?

### Q14. Workflow-completion chains [D-012, D-013]

Develop → build (if compiled lang) → test → self-review → reviewer-track →
audit → finalize → shadow. The user identified these as the natural
post-implementation chain. Many programs already exist; the orchestrator that
chains them does not.

- Q14.1  Map every workflow-chain program (review, audit, test, shadow, impact,
  reviewer-track, suggest-tests, suggest-reviewer, etc.). For each, declare its
  natural predecessor + successor.
- Q14.2  Which language families need `build` mode (C++, Rust, Go, etc.)? Is
  build a host-harness call (`TOOL(shell)`) or a separate synapse? Note:
  AXON itself never builds — only suggests.
- Q14.3  Test program chains — `code-dev-suggest-tests` → `run-tests` →
  `code-dev-review-tests` → `code-dev-review-coverage`. Are predecessors
  declared anywhere?
- Q14.4  Review program family — `code-dev-pr-review` + 9 phases `p1`..`p9` —
  is this a sub-FSM today? Phase transitions declared anywhere?
- Q14.5  Self-review programs — `code-dev-self-review.md` vs `code-dev-review-self.md`
  — same intent, different name; which is canonical? Are both wired in?
- Q14.6  Reviewer-altering — `code-dev-pr-suggest-reviewer`, `code-dev-explain-reviewer`,
  `code-dev-reviewer-track`, `code-dev-knowledge-reviewer-track`. Chain order?

### Q13. Suggestion firing mechanics [D-010]

- Q13.1  Where does `next-conditional` live — in program header? In a side file `workspace/synapses/<program>.next.md`? Both?
- Q13.2  Schema of a conditional suggestion: `if predicate(state, outcome) → suggest [program-list] with confidence c`. Examples?
- Q13.3  Predetermined vs mutable — what triggers ephemeral suggestion generation (workflow-context, recent activity, intent classification)?
- Q13.4  Suggestion-promotion: after N user-accepts of an ephemeral suggestion, promote to predetermined. N default = 3 (D-010); how is acceptance tracked?
- Q13.5  Suggestion suppression — user dismisses "you should run X" three times; demote or remove. How recorded?
- Q13.6  Output channel — footer line, panel above prompt, dedicated banner? Gated by `L:suggestions-enabled` (default true)? Per-channel verbosity (compact / full)?

---

## 2. Study tracks (parallel sub-studies)

| Track | Question batch | Inputs                                           | Output                                |
|-------|---------------|--------------------------------------------------|---------------------------------------|
| T-A   | Q1, Q2        | `tools/REGISTRY.json`, `workspace/programs/*.md` | tool-graph.json, program-catalog.md   |
| T-B   | Q3, Q5        | `workspace/programs/code-dev-*.md`, `my-axon/dev-projects/*/04-log.md` | code-dev-graph.md, workflow-catalog.md |
| T-C   | Q4            | T-A + T-B output; existing `_meta.md` schemas    | goal-derivation.md (proposal)         |
| T-D   | Q6, Q7        | T-A + T-B; current program header conventions    | synapse-contract.md, orchestrator-design.md |
| T-E   | Q8, Q11       | `plan_dag`, `pr_drift`, `pr_sync` source; existing DAGs in dev-projects | dag-requirements.md, nested-dag-spec.md |
| T-F   | Q9, Q10, Q13  | T-D + T-E; current `mode-router`, `mode-detect`  | generator-spec.md, suggester-spec.md  |
| T-G   | Q12           | `code-dev-shadow.md`, `code-dev-knowledge-shadow.md`, dev-projects/*/shadow/ | shadow-enforcement-spec.md |

Tracks may run in any order; T-A is the prerequisite for everything.

---

## 3. Findings format

Each finding is one file under `phases/1-study/findings/F-NNN-<slug>.md`, format:

```
# F-NNN: <one-line headline>
Severity:   high | medium | low
Track:      T-A | T-B | T-C | T-D | T-E | T-F
Evidence:   <file:line citations, tool outputs, command results>
Implication: <what design choice this constrains in Phase 2>
Suggested action: <derive a Phase-2 design question or a Phase-3 PR seed>
```

Findings are referenced by the Phase 2 design doc. A finding without an
implication is incomplete.

---

## 4. Open questions for the user (to resolve before / during study)

These are not study questions — they are design forks the orchestrator can't
guess. Each one should be answered explicitly before Phase 2 starts.

- **OQ-01.** ✓ RESOLVED (D-005) — Hybrid: inferred default + declared override.
- **OQ-02.** ✓ RESOLVED (D-007) — Goals always exist. Workflow-bound goal when
  running a known workflow; user-stated (with AXON-infer + confirm) for ad-hoc.
- **OQ-03.** Suggestion delivery — footer line, dedicated panel, pop-up question,
  or all three depending on confidence?
- **OQ-04.** ✓ RESOLVED (D-006) — Both `DAG.json` + `DAG.md`, sync-checked. JSON
  is canonical; md is human view auto-emitted; hand-edits trigger reverse-parse.
- **OQ-05.** Workflow generator output — runnable compiled program saved to
  `workspace/programs/compiled/`, or ephemeral plan rendered as instructions?
- **OQ-06.** Adaptive deviation — when AXON believes the user is on the wrong
  workflow, does it **redirect** (jump to a new program) or **annotate** (warn +
  let user choose)? `L:inference-mode` likely gates this.
- **OQ-07.** Goal-schema location — new file per project (`_goals.md`), per
  phase (in `_meta.md`), or per PR (in `03-prs/PR-NNN.md` frontmatter)?
- **OQ-08.** Synapse-contract migration — when adding `precondition:` / `post-state:`
  to 174 programs, bulk-author from inference, or hand-author over time? Same
  question for the 69 tools.
- **OQ-09.** ✓ RESOLVED (D-008) — Most detailed, no cap. Tracks split into
  subtracks if a single file exceeds 80 KB or 50 finding-references.
- **OQ-10.** Validation gate — does Phase 1 require user sign-off on each track
  before moving to Phase 2, or is the synthesis doc the only gate?

---

## 5. Synthesis output (what Phase 1 ships)

When all tracks complete, the study produces:

1. `phases/1-study/01-study.md` — this file, with each Q1-Q10 answered inline.
2. `phases/1-study/findings/` — F-NNN files; INDEX.md regenerated.
3. `phases/1-study/synthesis.md` — the bridge to Phase 2: which findings demand
   which design decisions, prioritized.
4. `phases/1-study/helpers/tool-graph.json` — machine-readable tool/program graph.
5. `phases/1-study/helpers/workflow-catalog.md` — observed workflows from lived
   usage.
6. `phases/1-study/helpers/goal-derivation.md` — proposed `goal:` schema fields
   + measurable success criteria per level.

---

## 6. How to run this study

```
code-dev study           # expands this file with answers, track by track
code-dev study T-A       # run a single track
code-dev study --finding "..."   # capture a finding mid-study
code-dev study --synthesize      # roll findings into synthesis.md
code-dev plan            # only after synthesis is signed off
```

---

_Run: code-dev study  to begin populating answers._

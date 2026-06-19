# Plan review — Formal-Methods / State-Machine Engineer

**Reviewer role:** Formal-Methods / State-Machine Engineer
**Scope:** the phase model + terminal-transition completeness, the typed multi-relation graph
(PR-T5-4 / OD-3 gate-on-EXEC), reachability/orphan/cycle checks, R_PHASE_TRACKED (PR-T3-4).
**Mode:** READ-ONLY. No code, programs, tests, or workspace state modified. Live tree read at
`/home/arturcastiel/projects/new-axon/axon`. ADVISORY ONLY.
**Plan files reviewed:** `HANDOFF.md`, `01-study.md`, `02-plan.md`, `02-prs.md`,
`research/00-AXON-report-state-handoff.md`.
**Source read for grounding:** `tools/dag_consistency.py`, `tools/dag.py`, `tools/phase_model.py`,
`tools/rules/r_phase_tracked.py`, `tools/rules/manifest.py`, `tools/crucible.py`, `tools/verify.py`,
`tools/deps.py`, `tools/call_graph.py`, `workspace/programs/*.md`, `tests/test_dag_consistency.py`.

---

## 1. Verdict

**SOUND-WITH-RISKS** — confidence **high** (0.8).

The strategic state-machine decisions are correct: OD-3's "type both, gate on EXEC" is the right call,
and the phase model (`phase_model.py`) is genuinely well-built and the right substrate to gate on. But
the plan describes the typed-graph and completeness work (PR-T5-4) and R_PHASE_TRACKED (PR-T3-4) at a
level of abstraction that hides three load-bearing under-specifications: (a) the completeness gate has
**no defined reachability root set**, so "every node reachable" is not yet a decidable predicate; (b)
the "transition layer" (body-EXEC) is **not yet extracted by any single tool** — five fragmented EXEC
parsers exist (`deps.py`, `call_graph.py`, `pack.py`, `simulate.py`, `axon_audit.py`) and the plan does
not say which becomes authoritative or how `next-conditional`/`synapses` edges (currently parsed by no
one) fold in; and (c) PR-T3-4's `crucible` runner only sees changed-file `program_text`, so it gates
**new** violations but cannot retroactively bite the 100/105 existing violators the plan cites as the
motivation. None of these is fatal — each is a specification gap fixable before execution — but as
written the completeness gate will land **partially sound** (cycle/dangling: sound; orphan/reachability:
under-defined), and that is exactly the kind of "0 errors while 38% isolated" false-green this project
exists to kill.

---

## 2. What the plan gets right

1. **OD-3 "type both, gate on EXEC" is the correct formal call, not next-suggests.** The two relations
   are categorically different. `next-suggests` is a UX/affordance hint (a *may-follow* relation,
   non-deterministic, advisory); body-`EXEC` is the actual runtime transition function (a *does-invoke*
   relation). Reachability and completeness are properties of the **transition** relation — gating
   completeness on a suggests-edge would let a program be "reachable" purely because a docstring
   recommends it, while never being callable. The handoff's recommendation (research report §5 OD-3,
   `01-study.md:35-36`) to persist both as typed layers and gate on the EXEC `transition` layer is the
   formally defensible choice. I endorse it without reservation.

2. **The phase model is the right thing to gate on, and it is genuinely strong.** `phase_model.py`
   implements an explicit four-state machine (`STATUSES = pending|active|done|stale`,
   `phase_model.py:28`) with: an in-order guard (`advance()` requires all `deps` done,
   `phase_model.py:218-231`), an output-completeness gate (`done()` requires deps done **and** declared
   outputs to exist on disk, `phase_model.py:234-253`), and backward cascade-invalidation
   (`stale_downstream()` marks transitive dependents stale, `phase_model.py:256-281`). This is a real,
   decidable, pure-over-JSON state machine. Building the re-arm on top of it (rather than reinventing it)
   is correct.

3. **Cycle and dangling-edge detection already exist and are sound — for the DAG.json layer.**
   `dag.py:detect_cycle()` is a correct Kahn's-algorithm topological check (`dag.py:296-319`) and
   `dag.py:verify()` already emits `CYCLE_DETECTED`, `DANGLING_EDGE_*`, and `ORPHAN_NODE`
   (`dag.py:368-399`). PR-T5-4 does not need to invent these; it needs to *extend their coverage to the
   synapse/EXEC graph*, which today has none. The plan is right that the work is "add checks to
   dag_consistency.py," not "write a graph validator from scratch."

4. **The ordering of the graph work is dependency-correct.** PR-T5-4 has no hard predecessor in the DAG
   (`02-prs.md:151`), which is right — the typed-graph generation is read-only over the corpus and does
   not depend on the arming work. Gating it behind the Tier-0 meter would have been a category error; the
   plan correctly does not.

5. **The "generate, don't transcribe" instinct is correct (research report §3 F4,
   `research/00-...:154`).** A hand-maintained graph is a fifth divergent encoding (theme T5). Deriving
   the graph from the parser + an EXEC extractor is the only way the graph stays in sync with the
   programs. The plan inherits this correctly.

---

## 3. Weaknesses / risks / gaps — ranked by severity

### S1 — CRITICAL · the completeness gate has no defined reachability root set (PR-T5-4)
**"Every node reachable" is undecidable until you name *reachable-from-what*.** Reachability is not a
property of a graph alone; it is a property of a graph **plus a designated entry/root set**. I searched
the tree: there is **no entry-node, root-node, or "reachable-from" concept anywhere** in
`dag_consistency.py` or `dag.py` (grep for `entry|root.node|reachable_from` returns nothing). The plan's
test claim — "the ~38%-isolated count is surfaced" (`02-prs.md:155`) — presupposes a definition of
"isolated" that does not exist yet. Without a root set, the only decidable notion is *weakly-connected
component membership*, which is **not** what the handoff means by "38% isolated" (research report §3 F4,
`research/00-...:154`: "the gap between '0 errors' and '~38% of programs isolated'").

Concretely, AXON's entry points are the kernel COMMAND-PARSING modes (`dag_consistency.py:37`,
`MODES = {chat, build, run, memory, system, plan, programs, dev, menu}`) and `menu.md` dispatch — but
PR-T5-4 never declares these as roots. **Unless the PR specifies the root set, the reachability check is
either (a) vacuous (every node is "reachable from itself") or (b) computing something other than what the
38% figure measures, which re-creates the false-green this whole project is fighting.** This is the
single most important state-machine gap in the plan.

### S2 — CRITICAL · the "transition layer" extractor is unspecified and fragmented (PR-T5-4 / OD-3)
OD-3 says "body-`EXEC` is the authoritative transition layer" (`01-study.md:35`) and PR-T5-4 says "run
the parser + a body-EXEC extractor" (`02-prs.md:152`) — but **no single EXEC extractor exists**, and the
plan does not say which becomes authoritative. I found **five** independent, divergent EXEC parsers:
`tools/deps.py:17` (`EXEC_RE = EXEC\(([^\)]+)\)`), `tools/call_graph.py:19` (scoped to
`EXEC\((code-dev-[\w-]+)` — code-dev only), `tools/pack.py:41`, `tools/simulate.py:25`,
`tools/axon_audit.py:196` (`EXEC\(([^\s,)]+)` — different capture). These regexes **disagree** on what an
EXEC edge is (full arg vs first token vs code-dev-prefixed-only). A typed transition graph built on an
unspecified extractor is non-reproducible: the ~159-edge EXEC count the handoff cites (research report §2
T5, `research/00-...:87`) depends on *which* parser you pick. **PR-T5-4 must name one canonical extractor
(or consolidate the five) and pin the edge-count in a test**, or the "transition layer" is whatever the
author's regex happened to match that day. Relatedly, `dag_consistency.py` already claims to check
"next-suggests/**next-conditional**" (`dag_consistency.py:13`) but the `_NEXT_COND` regex
(`dag_consistency.py:33`) is **declared and never used** — only `_NEXT` (next-suggests) is iterated
(`:136`). So `next-conditional` and `synapses:` edges are silently dropped today. The typed graph must
decide whether `next-conditional` is a third edge type or folds into one of the two layers; the plan is
silent.

### S3 — HIGH · PR-T3-4 cannot bite the existing violators it is justified by (PR-T3-4)
The PR's stated motivation is "100/105 ownership programs violate the ledger contract today"
(`02-prs.md:99`). But the mechanism — add `crucible` to R_PHASE_TRACKED's runner list (`02-prs.md:98`) —
gates only on **changeset** programs. R_PHASE_TRACKED requires `program_text` to fire
(`r_phase_tracked.py:64-69`), and the crucible runner only builds a `program_text` ctx **inside its
per-changed-file loop** (`crucible.py:207-225`, the R_MEMORY_RESPECTED path; the comment at `:207-208`
documents that ctx without `program_text` "returned None on every diff and never gated"). So once this
lands, a *new or modified* program that takes the lock without recording a transition is blocked — but
the 100 existing violators are untouched until someone edits them. **This is defensible as a "stop the
bleeding, ratchet down" policy** (and mirrors OD-5's shrink-only grandfather), but the PR is written as
if it closes the 100/105 gap, which it does not. The test claim (`02-prs.md:100`, "a program that takes
the lock but never records a transition → BLOCK at the crucible gate") is satisfiable *only for a program
in the changeset* — the test must construct a changeset fixture, and the PR should state explicitly that
the 100 legacy violators are handled by a separate sweep (or a grandfather list), not by this gate.

### S4 — HIGH · the phase model's `stale` state has no terminal-transition rule (PR-T3-4 / phase model)
The four-state machine has a completeness hole I can prove from the code. `stale_downstream()` sets
dependents to `stale` (`phase_model.py:270-281`), but **nothing defines how a `stale` node returns to
`done`**. `advance()` only checks `deps`-done (`:225`) — it will happily move a `stale` node to `active`
without acknowledging it was invalidated; `done()` checks deps-done + outputs-exist (`:243-247`) — a
`stale` node whose outputs still exist on disk can be re-marked `done` **without re-doing the work**,
because `done()` never inspects the node's own prior `stale` status. So the cascade-invalidation is
*advisory*: it paints nodes stale, but the gate that should force a re-do (outputs may be on disk yet
semantically invalid) does not exist. This is the phase-layer analogue of the drift "stable-by-emptiness"
bug (OD-2): a state transition that records intent but does not bite. **No PR in the backlog covers this.**
R_PHASE_TRACKED (PR-T3-4) is about *recording* transitions, not about *enforcing the stale→done
re-do contract*. The completeness gate the plan promises is incomplete at the phase layer until a
`stale`-node cannot be `done()`-ed without an explicit re-advance.

### S5 — MEDIUM · self-loop / duplicate-edge defect set is under-counted and under-specified (PR-T5-4)
PR-T5-4 says "fix the 2 self-loop bugs (quickstart, workspace-backup)" (`02-prs.md:153`). I verified:
those two are genuine single-node self-loops (`next-suggests: [quickstart]`, `next-suggests:
[workspace-backup]`). **But the corpus has adjacent defects the plan does not name**, which a cycle/orphan
builder will trip over: `workspace/programs/code-dev.md` lists `code-dev-review` **three times** in one
`next-suggests` list (duplicate edges — will double/triple-count node degree and skew the "isolated"
metric if not deduped), and includes `code-dev-phase-` (a trailing-dash placeholder target, which
`dag_consistency.py:150` already special-cases as `tgt.endswith("-")` → skip). PR-T5-4 must specify
**edge de-duplication** and **placeholder handling** in the typed-graph builder, or the orphan/isolation
counts will be wrong in a way that looks precise. The "2 self-loop bugs" framing implies the defect set is
small and known; the duplicate-edge case shows it is not fully enumerated.

### S6 — MEDIUM · cycle-detection semantics differ by edge type — undecidable until the typed graph says which (PR-T5-4)
`dag.py:detect_cycle()` filters to `kind == "depends"` edges only (`dag.py:302-303`). The phase/PR DAG is
a strict DAG (cycles are errors). But the **transition (EXEC) graph is legitimately cyclic** — a program
can EXEC a sub-program that EXECs back (menus, REPL loops, the `next` re-entry pattern). And the phase
model itself *intends* a back-edge (re-entering a node staling its dependents,
`phase_model.py:256-281`). So "add cycle checks" (`02-prs.md:153`) is **only sound per-layer**: cycles in
the `transition` layer must be *reported, not errored*; cycles in the phase-`depends` layer are errors.
The plan's single phrase "add reachability/orphan/cycle checks" does not encode this layer-dependence. If
the EXEC layer reuses `dag.py:verify`'s `CYCLE_DETECTED`-as-error, the completeness gate will fail-closed
on legitimate runtime loops — a false-positive that erodes trust in the gate (the over-strict failure
mode, the mirror of fail-open).

### S7 — LOW · invariant decidability is not stated; no meta-assertion that the completeness check is total (PR-T5-4)
The plan's method demands "STRONG automated tests that prove the claim" (`02-plan.md:38`). For the graph
work, the load-bearing invariants — (I1) cycle-freedom of the `depends` layer, (I2) no dangling
`transition` edge, (I3) every non-root node reachable from the root set, (I4) no orphan in the union
graph — are never written down as named, decidable predicates anywhere in the plan. They are implied by
prose. A formal gate needs the invariant set *enumerated* so the test suite can assert each fires on a
crafted counterexample (the plan does this for cycle/orphan via "the checks fire on the known defects,"
`02-prs.md:155`, but **not for reachability**, because per S1 the predicate is undefined). Minor only
because it is a documentation/test-design fix, not a logic error.

---

## 4. Specific changes I would make before execution

1. **(fixes S1) Add a root-set definition to PR-T5-4.** Before any reachability check, the PR must
   declare the entry set: the kernel COMMAND-PARSING `MODES` (`dag_consistency.py:37`) plus `menu.md`
   dispatch targets. Define "isolated" as **not reachable from the root set over the `transition`
   layer**, and pin the resulting count in a test fixture so the "38%" claim becomes reproducible.
   Without this line, PR-T5-4 should not be marked DONE — its central deliverable is not yet decidable.

2. **(fixes S2) Name ONE canonical EXEC extractor and consolidate.** Pick a single regex/parser (I would
   promote `tools/deps.py`'s extractor, which is the most general and already feeds the deps graph), have
   PR-T5-4 *reuse* it rather than write a sixth, and add a test pinning the EXEC edge count (~159 per the
   handoff) so a regex change cannot silently move the transition set. Simultaneously decide
   `next-conditional`/`synapses:` (currently dropped by the dead `_NEXT_COND`,
   `dag_consistency.py:33`): either type them as a third relation or fold them into `transition`, and
   delete or wire the dead regex so the docstring (`:13`) stops lying.

3. **(fixes S6) Make cycle-detection layer-typed in PR-T5-4.** Specify: `depends` layer → cycle is an
   ERROR (reuse `dag.py` as-is); `transition` layer → cycle is REPORTED (warn + surfaced), never an
   error. Add one test per layer (an EXEC back-edge passes; a phase-depends back-edge fails). This is the
   difference between a gate that bites real defects and one that false-positives on legitimate loops.

4. **(fixes S3) Re-scope PR-T3-4's claim honestly.** State in the PR that adding `crucible` to
   R_PHASE_TRACKED gates **changeset** programs only (it cannot retroactively block the 100/105 existing
   violators, because crucible only sees `program_text` for changed files, `crucible.py:207-225`).
   Either (a) accept this as a forward-ratchet and add a separate sweep/grandfather PR for the legacy
   100, mirroring OD-5's shrink-only `test-grandfather.txt`, or (b) add a corpus-wide `audit` pass that
   reports (not blocks) the legacy set. The test fixture must construct a changeset, not assert on the
   live corpus.

5. **(fixes S4) Add a `stale`→`done` re-do contract to the phase model (new PR, Tier 3).** `done()`
   (`phase_model.py:234`) must refuse to mark a node `done` if its current status is `stale` unless it
   was explicitly `advance()`-ed (active) since being staled — otherwise cascade-invalidation is
   cosmetic. This is a small, well-bounded change to one function and closes the phase-layer analogue of
   the OD-2 fail-open. It is currently covered by **no PR** and should be added before the completeness
   gate is called "sound."

6. **(fixes S5) Specify edge de-duplication + placeholder handling in PR-T5-4.** The typed-graph builder
   must dedupe edges (the `code-dev.md` triple `code-dev-review` will skew degree/orphan counts) and
   document the existing `endswith("-")` placeholder skip (`dag_consistency.py:150`) as intended graph
   semantics, not an accident. Add a fixture with a duplicate edge and assert the node-degree is counted
   once.

7. **(fixes S7) Enumerate the invariants in 02-plan.md.** Write the four predicates (I1–I4 above) as a
   named, decidable list so each PR-T5-4 sub-test maps to one invariant and one crafted counterexample —
   this is what makes the completeness gate auditable as *total* rather than *whatever-the-author-tested*.

---

## 5. Will the completeness gate be sound once these land?

**As written: partially.** Cycle (per-layer) and dangling-edge detection will be sound — that machinery
already exists and is correct (`dag.py:296-399`). Orphan detection will be sound for the explicit
DAG.json layer. **Reachability will NOT be sound** until the root set is defined (S1), and the
"transition layer" itself will be non-reproducible until the EXEC extractor is pinned (S2). The phase-layer
completeness will have a hole at `stale`→`done` (S4) that no PR closes.

**With changes 1–7: yes, sound and decidable.** Each invariant becomes a named predicate over a
reproducibly-extracted typed graph with a declared root set, tested against a crafted counterexample, and
the phase machine's terminal transitions are total (every state has a defined, biting exit). That is the
bar a formal completeness gate must clear, and it is reachable from this plan with the seven specification
fixes above — none of which is a redesign, consistent with the project's "configuration + unfinished
wiring, not redesign" thesis (`02-plan.md:8-10`).

---

*Advisory only. No code, programs, tests, or workspace state were modified. All line/PR citations
verified against the live tree on 2026-06-19.*

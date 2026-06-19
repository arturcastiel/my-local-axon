# AXON Re-Arm — Plan Review (State-Machine / Formal-Methods seat)

> **Adopted profession:** Compiler Engineer (AXON hr-team catalog: `workspace/hr-team/catalog/professions/software/compiler-engineer.md`),
> operating in its **bespoke** mode as the **state-machine / formal-methods** specialist — grammars, IRs, typed
> graphs, dataflow, reachability, and transition-system soundness. The L1 skills that bite here are *parsing &
> semantic analysis*, *SSA/dataflow*, and *miscompile-reduction*; the governing patterns are **SEMANTICS-PRESERVATION**
> (the transcribed graph must mean the same thing the bodies execute) and **PASS-INTERACTION-AUDIT** (each PR is a
> compiler pass; do the passes commute, and does an early pass leave a later one nothing to bite on?).
> **Scope:** advisory, read-only. No code, tests, or state were run or modified. Charge = the phase model + terminal-transition
> completeness, the typed multi-relation graph (PR-T5-4 / OD-3), reachability/orphan/cycle checks, and R_PHASE_TRACKED.
> Are the invariants **decidable** and **sound**? What state-machine gaps/contradictions does the plan leave?

---

## 1. Verdict

**SOUND-WITH-RISKS** — confidence **High** (0.8) on the structural findings (each is grounded in a line I read in
the live tree), **Medium** on the magnitude of their downstream impact.

The plan's *direction* is correct and its *diagnoses are accurate where I could check them against source* — the
CR-13 resolver bug, the drift-gate `unknown` seam, the unguarded self-loops, and the 100-of-105 phase-ledger
violation are all real and correctly located. But three of the four state-machine PRs (**PR-T5-4**, **PR-T3-4**,
**PR-T0-2a/T0-2**) are specified at the level of *intent* and silently assume an **extractor / completeness
predicate / N-A classifier that does not yet exist or is provably wrong on today's corpus.** As written they would
pass a green test against a graph that does not mean what the bodies execute — a transcription **miscompile**.
The fixes are small and local; they must be named *before* execution or the "armed and instrumented" claim rests on
an instrument that mis-parses its own input.

The single most important finding: **PR-T5-4's authoritative "EXEC transition layer" is built on a regex
(`tools/synapse_infer.py:48`) that mis-parses the most common EXEC form in the corpus.** Gate-on-EXEC (OD-3) is the
right decision wired to a broken parser. Detail in Risk **R1**.

---

## 2. What the plan gets right (state-machine lens)

1. **OD-3 — "type both, gate on EXEC" is the correct call, and for the right reason.** The two relations are not two
   views of one machine; they are two *different* machines. `next-suggests` is a **UX/suggests** relation (the
   inference layer literally stamps it `confidence: 0.6, reason: "inferred from EXEC()"` — `synapse_infer.py:241-245`);
   body-`EXEC` is the **operational transition** relation. Gating completeness on the suggests layer would be gating
   on a hint. Choosing `EXEC` as the authoritative `transition` type is formally the right denominator. (PR-T5-4, 02-prs.md:151-155.)

2. **The cycle/orphan gap is real and correctly located.** `tools/dag_consistency.py` *imports* `dag.detect_cycle`
   (line 29, "verify(), detect_cycle()") but **never calls it on the synapse graph** — `check_synapse_graph`
   (lines 144-156) only flags `DANGLING_SYNAPSE_EDGE`. Cycle detection runs only inside `dag.verify` on `DAG.json`
   files, which are a *different* graph from the synapse edges. So PR-T5-4's premise — "add reachability/orphan/cycle
   checks to dag_consistency.py" — is filling a genuine hole, not duplicating an existing check. **[V]** I confirmed
   the two named self-loops live in the synapse layer: `workspace/programs/quickstart.md:12` (`next-suggests: [quickstart]`)
   and `workspace/programs/workspace-backup.md:12` (`next-suggests: [workspace-backup]`). Both targets *exist*, so
   `check_synapse_graph` passes them as non-dangling, and nothing else cycle-checks them — they are invisible today
   exactly as the plan claims.

3. **CR-13 root-cause is correctly diagnosed down to the character.** `crucible.py:131` runs
   `git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1` (no trailing `2>/dev/null`), while
   `_changeset_base()` at `:155` runs `... || git rev-parse HEAD~1 2>/dev/null` (with it). On a shallow / single-commit
   checkout the two resolvers **provably disagree**, which is the fail-open. PR-T1-1's "one resolver can't disagree
   with itself" is the correct SSA-style fix: collapse two defs of one value to a single def. **[V]** Lines read directly.

4. **The drift-gate `unknown` seam is a real fail-open and OD-2 resolves it correctly.** `r_drift_gate.py:62`
   (`if drift_state == "unknown": return None`) discards a verdict `drift.py` already computed. Treating `unknown` as
   the fail-closed BLOCK (PR-T3-2) is the sound transition: in a transition system, *absence of evidence about the
   guard must not satisfy the guard.* The plan correctly sequences it behind PR-T0-1 (the meter), because fail-closing
   `unknown` before a real `actual` wire exists would BLOCK every render. PASS-INTERACTION-AUDIT: this ordering commutes correctly.

5. **R_PHASE_TRACKED → biting runner (PR-T3-4) is mechanically sound and its N/A guard already exists.** The rule's
   exemption is principled: `r_phase_tracked.py:69-72` returns `None` when no `STORE(W:active-program)` is present
   ("doesn't take ownership → N/A"). The plan's instinct to *confirm the N/A path before wiring it to a biting gate*
   (02-prs.md:97-100) is exactly the right caution — see R3 for where it is still under-specified.

6. **Tier-0-first ordering is formally justified.** The completeness invariant ("every transition guarded") is
   *vacuously true* on an empty SSOT. PR-T0-2a (seed `# emits:`/`outputs:`) **before** PR-T0-2 (flip
   `terminal-outputs-required`) is the correct dependency: I verified `r_terminal_outputs.py:75-77` returns `None`
   ("unguarded, safe default") when a program declares no emits. Flipping the flag first would arm a gate over an
   empty domain — green, and meaningless. The plan gets this dependency right (critical path, 02-plan.md:29).

---

## 3. Ranked risks / gaps (state-machine soundness)

### R1 — CRITICAL — The authoritative EXEC extractor mis-parses the dominant EXEC form. *(PR-T5-4; OD-3)*
PR-T5-4 says "run the parser + a body-EXEC extractor" and gate completeness on the `transition` (EXEC) layer. The only
EXEC parser in the tree is `synapse_infer.py:48`:

```python
RE_EXEC = re.compile(r"\bEXEC\(\s*([A-Za-z0-9_\-]+)")
```

The character class **excludes `/` and `.`**, but the corpus uses two un-normalized EXEC forms:
- bare-name: `EXEC(code-dev-review-scope)` → captures `code-dev-review-scope` ✓
- **path form: `EXEC(workspace/programs/code-dev-plan.md)` → captures `workspace`** ✗

I demonstrated this against the live regex: every path-form EXEC collapses to the literal token **`workspace`**, not the
target program. Path-form is common — `grep` over `workspace/programs/` shows entries like
`EXEC(workspace/programs/code-dev-plan.md)`, `...code-dev-merge.md`, `...code-dev-state-save.md`, `...code-dev-state-handoff.md`,
`...code-dev-safety-freeze.md`. Consequences for PR-T5-4's "authoritative transition layer":
- a **phantom node `workspace`** with massive in-degree (every path-form EXEC points at it) — a false hub;
- the **real edges** (`X → code-dev-plan`) are **missing** → the targets look like **false orphans**;
- the `~38%-isolated` figure the PR promises to "surface, not hide" (02-prs.md:155) is computed on a corrupted graph and will be **wrong in both directions**.

There is also a **dynamic EXEC form** — `EXEC({cursor.name})` appears in the corpus — which is a *computed* transition
target the regex cannot resolve at all; the completeness predicate must classify these as a distinct `dynamic` edge
class, not silently drop them (drop = false orphan) and not treat `{cursor.name}` as a literal node (false dangling).

**This is a SEMANTICS-PRESERVATION failure:** the transcribed graph does not denote the transitions the bodies execute.
Gate-on-EXEC (OD-3, the correct decision) is only sound if EXEC is parsed correctly. **The fix is ~3 lines** (extend the
class to `[A-Za-z0-9_\-./{}]`, then normalize `workspace/programs/X.md` → `X` and tag `{...}` as `dynamic`), **but it
must land inside PR-T5-4 with its own fixture** or the whole "armed graph" is built on a miscompile. **Decidability note:**
with dynamic targets unresolved, "every node reachable" is *not decidable* on the static graph — the plan must define the
dynamic class as an explicit, surfaced unknown, not fold it into the orphan count.

### R2 — HIGH — "Reachability / completeness" has no declared roots, so the invariant is underspecified. *(PR-T5-4; OD-3 completeness gate)*
PR-T5-4 adds "reachability/orphan/cycle checks" and the synthesis (OD-3) wants "every node reachable." Reachability is
only decidable **relative to a declared root set** (entry points). The plan never names the roots. Without them, "orphan"
degenerates to `dag.verify`'s existing definition — `ORPHAN_NODE = a node touching no edge` (`dag.py:396-399`) — which is
a *weaker, different* property than "unreachable from an entry point." A node can be non-orphan (has edges) yet unreachable
(its whole component is detached from any entry). The plan must specify:
- the **root set** (menu modes? the `MODES` set already enumerated at `dag_consistency.py:37`? `quickstart`? the `code-dev-*` front doors?), and
- whether the gate asserts **reachability-from-root** (strong) or merely **non-isolation** (weak, = today's orphan warn).

Stated as "~38% isolated," the metric sounds like reachability but the code path it extends (`ORPHAN_NODE`) measures
non-isolation. **These are different invariants.** Pick one, name the roots, or the completeness gate asserts a property
nobody chose. (Compiler analogy: unreachable-code elimination needs the entry block defined; "has no predecessor" ≠ "unreachable from entry.")

### R3 — HIGH — PR-T3-4's N/A path is sound for the rule but unsound as a *completeness* claim. *(PR-T3-4; R_PHASE_TRACKED)*
The rule's exemption ("no `STORE(W:active-program)` → N/A," `r_phase_tracked.py:69-72`) is correct **as a local predicate**,
but PR-T3-4 also wants `crucible` to *bite* on the 100/105 violators. Two gaps:
1. **The N/A predicate is syntactic and out-runs its own regex.** `_STORE_ACTIVE_RE` (line 36) matches a literal
   `STORE(W:active-program, "name")`. A program that takes ownership via a *computed* key, an aliased store, or a
   workflow-level lock the regex doesn't see is classified **N/A** and silently exempted — a **false-negative exemption**
   at a now-*biting* gate. Before wiring to BLOCK, PR-T3-4 must prove the N/A set is exactly the read-only/NORM set it
   claims (an enumerated audit, not a regex assertion). This is the same class of risk as R1: a syntactic classifier
   standing in for a semantic property.
2. **No paired CLEAR check.** The rule's own `reason` text (lines 88-90) invokes the contract "at least one transition
   between `STORE` and `CLEAR(W:active-program)`," but `check()` never inspects `CLEAR`. A program that STOREs, records,
   but **never CLEARs** (leaks the lock) passes. If `crucible` is to be the *ledger-integrity* gate, the open/close
   bracket-matching is part of the contract and is currently unenforced. (Dataflow analogy: this is a def with no
   corresponding kill — a liveness leak the gate should catch.)

### R4 — HIGH — Terminal-transition completeness is asserted but never *checked* as a property. *(PR-T0-2/T0-2a; PR-T5-4)*
The plan arms `R_TERMINAL_OUTPUTS` (post-condition: declared `# emits:` exist on `:done`) and the phase-ladder
`phase_model.done()`. But two terminal-completeness properties are left unguarded:
1. **Reachability of a terminal.** Nothing checks that every program/phase machine can *reach* a `:done`. A machine with
   a cycle and no exit (R1/R2 territory) or a `:done` token no transition leads to is a **stuck state** — the classic
   missing-terminal defect. The graph work (PR-T5-4) is the natural home for a "every component reaches a terminal" check,
   but the plan never lists it. Without it, "terminal-outputs armed" guards the *exit's post-condition* while leaving
   *unreachable exits* undetected.
2. **`:done`-token integrity.** `r_terminal_outputs.py:67-70` keys entirely off `active_phase.endswith(":done")` from
   runtime state. There is no static check that the `:done` tokens a body emits correspond to declared phases, nor that a
   program declaring `# emits:` actually has a reachable `:done`. A typo'd terminal token (`:dnoe`) silently disables the
   gate for that program — a **fail-open by misspelling**, the same family as the R13 "type a plausible filename"
   loophole PR-T1-4 closes elsewhere. The plan closes that loophole for tests but not for terminal tokens.

### R5 — MEDIUM — Two graphs named "DAG" with disjoint node spaces; the plan risks conflating their invariants. *(PR-T5-4; PR-T4-shadow / OD-4)*
`dag_consistency.py` already audits **two unrelated graphs** under one tool: (a) `DAG.json` files (plan/PR graphs, via
`dag.verify`) and (b) the **synapse** graph (program `next-suggests` edges, via `check_synapse_graph`). PR-T5-4 introduces a
**third** (the EXEC `transition` graph). These have *different node universes* (PR ids; program stems; program stems again)
and *different edge semantics* (`depends`; `suggests`; `transition`). Risks:
- a **cycle** is fatal in the `depends` graph (topological order must exist — `dag.py:133-135` already refuses cycle-closing
  depends-edges) but is **legitimate** in a `transition` graph (a retry loop, e.g. `EVOLVING` re-runs). Applying the
  `depends`-style cycle = error rule to the EXEC layer would **flag valid loops as defects**. The completeness gate must
  carry a **per-relation cycle policy**, not one global cycle check.
- the **29 `axon/programs/` legacy nodes + dead `DAG.json` layer** (OD-4 / PR-T4-shadow) are a *fourth* population with zero
  synapse frontmatter. PR-T4-shadow correctly sequences the investigation, but PR-T5-4 has **no stated dependency on it** —
  if the typed graph is generated before OD-4 decides migrate-vs-retire, those 29 nodes are either false orphans (if scanned)
  or a silent blind spot (if skipped). **Add `PR-T5-4 depends PR-T4-shadow`**, or scope PR-T5-4 explicitly to the workspace population only.

### R6 — MEDIUM — `MODES` is an untyped escape hatch that will hide real dangling/orphan edges. *(PR-T5-4; existing dag_consistency.py:37)*
`check_synapse_graph` treats the nine `MODES` (`chat, build, run, …`, line 37) plus any target ending in `-` or in
`("...", "")` (line 150) as *valid* edge targets. That is fine for a *dangling* check, but for a **reachability/orphan**
check these are **sink pseudo-nodes with no out-edges** — a transition into `menu` is a real exit, but a transition into a
mistyped mode (`buld`) is **not** in `MODES`, would be flagged dangling, *or* a placeholder ending in `-` is silently
swallowed (line 150) and never counted. When the same module gains reachability semantics (PR-T5-4), these heuristics
(`endswith("-")`, the `MODES` allowlist) must become **typed terminal nodes**, not string hacks, or orphan/reachability
counts inherit the swallow. Decidability is fine; **soundness of the count is not**, because the pre-filters drop edges
before the graph is built.

### R7 — LOW/MEDIUM — `build_from_prs` self-loop handling is correct, but `split_node`'s edge-duplication can manufacture cross-edges. *(PR-T4 graph mutations; defensive)*
Not a plan defect, but a latent one the graph PRs should not regress: `split_node` (`dag.py:253-279`) duplicates *every*
incoming/outgoing edge onto *every* split target, then drops self-loops (line 278). For a node with both in- and out-edges
to the **same neighbor**, this fabricates N×M edges, some spurious. The cycle guard (`_save_guarded`) catches cycle-closing
results but **not spurious-but-acyclic** edges. If PR-T5-4's generator or any Tier-4 deletion uses `split`/`merge` on the
typed graph, add a post-mutation edge-equality assertion. Flagging per MISCOMPILE-REDUCTION: this is the kind of
graph-rewrite that passes `verify` yet changes meaning.

---

## 4. Specific changes to the plan before execution

Ordered by leverage (each is small, each removes a soundness hole):

1. **(R1, gates PR-T5-4) Fix `RE_EXEC` *inside* PR-T5-4 and make it the PR's first sub-step.** Extend the class to include
   `/ . { }`, normalize `…/programs/X.md → X`, and tag `EXEC({…})` as a `dynamic` edge class. **Add a fixture** asserting
   `EXEC(workspace/programs/code-dev-plan.md)` and `EXEC(code-dev-plan)` resolve to the **same** node `code-dev-plan`, and
   that `EXEC({cursor.name})` produces a `dynamic` edge (not an orphan, not a literal node). Without this, the typed graph
   is a miscompile and every downstream count is wrong. *(This is the single highest-priority change in this review.)*

2. **(R2) Make the completeness invariant explicit in PR-T5-4.** Add to the change spec: (a) the **declared root set**
   (recommend: the `MODES` entries + the documented front-door programs), and (b) which property is gated —
   **reachable-from-root** (recommend) vs non-isolation. State that "orphan" = unreachable-from-root, distinct from
   `dag.verify`'s `ORPHAN_NODE` (no-edge). Test: a node with edges but in a detached component **fails** the reachability
   check (proves it is not the weaker non-isolation check).

3. **(R3) Strengthen PR-T3-4's N/A proof and add CLEAR-bracket matching.** Before wiring `crucible` to BLOCK: (a) ship an
   **enumerated audit** that the regex-N/A set equals the intended read-only/NORM set (no computed-key STOREs hiding in
   N/A); (b) extend the contract test to a **STORE-without-CLEAR leak fixture** → BLOCK. The rule's own reason text already
   promises the `STORE…CLEAR` bracket; make `check()` honor it, or downgrade the promise in the docstring.

4. **(R4) Add a terminal-reachability + token-integrity check to PR-T5-4 (or a new PR-T5-4a).** Assert: every
   program/phase component **can reach a `:done`** (no stuck states), and every `# emits:`-declaring program has a
   **statically reachable** `:done` token whose spelling matches a declared phase. This closes the "`:dnoe` disables the
   gate" fail-open and pairs naturally with the graph generator. Cheap, and it is the *completeness* half the plan names
   in its title but never checks.

5. **(R5) Add `PR-T5-4 depends PR-T4-shadow`** (or explicitly scope PR-T5-4 to the workspace population and declare the 29
   `axon/programs/` nodes out-of-graph until OD-4 lands). And **specify a per-relation cycle policy**: cycles are errors on
   `depends`, **allowed** on `transition` (retry loops), **warnings** on `suggests`. One global cycle rule will mislabel valid loops.

6. **(R6) When PR-T5-4 adds reachability to `dag_consistency.py`, promote `MODES` and the `endswith("-")`/placeholder
   filters to typed terminal/ignored node classes** rather than pre-build string filters, so orphan/reachability counts
   don't silently swallow dropped edges. Surface a "dropped/ignored edges: N" line so the swallow is auditable.

7. **(R7, defensive) If any Tier-4/5 PR mutates the typed graph via `split`/`merge`/`fold-in`, add a post-mutation
   edge-set assertion** (no fabricated cross-edges) beyond the existing cycle guard.

**Net:** the plan is sound in *direction* and accurate in *diagnosis* — OD-2, OD-3, the CR-13 resolver collapse, and the
self-loop finding all check out against source. The risk is concentrated where the plan trusts a **syntactic stand-in for a
semantic property**: the EXEC regex (R1), the reachability root set (R2), the N/A classifier (R3), and terminal-token
spelling (R4). All four are small, local fixes; none requires a redesign. Land them *inside* their owning PRs with the
fixtures named above, and the "armed and instrumented" graph will actually mean what the bodies execute.

---

### Evidence index (files read in the live tree, read-only)
- `tools/dag_consistency.py` — synapse-graph check has no cycle/reachability call (lines 29, 144-156, 159-172); `MODES` (37).
- `tools/dag.py` — `detect_cycle` (296-319), `ORPHAN_NODE`=no-edge (396-399), cycle-refusal on depends (133-135), `split_node` edge dup (253-279).
- `tools/synapse_infer.py` — `RE_EXEC` excludes `/.{}` (48); `next-suggests` is inferred-from-EXEC at confidence 0.6 (241-245); `_scan_program` (185-196).
- `tools/crucible.py` — resolver disagreement `:131` (no trailing `2>/dev/null`) vs `:155` (has it); `run_changeset` fail-closed branch (182-189).
- `tools/rules/r_drift_gate.py` — `unknown → return None` fail-open (54-65).
- `tools/rules/r_phase_tracked.py` — syntactic N/A on no-`STORE` (36, 69-72); reason text invokes STORE…CLEAR bracket (88-90) but `check()` never inspects CLEAR.
- `tools/rules/r_terminal_outputs.py` — keys off runtime `:done` token (31, 67-70); unguarded-without-emits default (75-77).
- `tools/neuron_audit.py` — dangling-suggests on `next-suggests`/`next-conditional` (66-76); lint roster includes `r_phase_tracked` (35-39).
- Corpus: `EXEC(workspace/programs/*.md)` path-form widespread; `EXEC({cursor.name})` dynamic form present; self-loops
  `workspace/programs/quickstart.md:12`, `workspace/programs/workspace-backup.md:12`.
- Plan: 02-prs.md (PR-T5-4 :151-155, PR-T3-4 :97-100, PR-T3-2 :87-90, PR-T1-1 :33-36, PR-T0-2/2a :16-24); 02-plan.md (critical path :29);
  research/00-…handoff.md (OD-3 :190, T5 dual-encoding :81-88, F4 :154).

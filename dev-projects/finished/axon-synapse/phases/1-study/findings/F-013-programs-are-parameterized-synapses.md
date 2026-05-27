# F-013: SOME programs are parameterized synapses today — contract schema must capture modes/budgets/acceptance

**Update 2026-05-17 (lint pass):** Original wording over-generalized. Actual
prevalence across 174 programs:
- **2/174** (1.1%) declare `# modes:` or `# plan-modes:` blocks: only
  `code-dev-study.md` and `code-dev-plan.md`.
- **4/174** (2.3%) declare `--mode=` in `# usage:` line.
- **150/174** (86%) lack `# next:` declarations entirely.

Phrasing should be: "A small but architecturally important subset of programs
are richly parameterized; most are single-shape. The synapse-contract schema
must support both — `modes:` block optional, with single `default` mode the
fallback (which synapse-contract-v1.md already does)."

Implication unchanged: schema must capture modes/budgets/acceptance.
Prevalence actually strengthens F-005 — 86% of programs need `next-conditional`
inferred or authored.

---


**Severity:** high
**Track:** T-A / T-D
**Date:** 2026-05-17
**Linked demands:** D-6 (synapse model), D-7 (orchestrator), D-29 (fixed/adaptive modes)
**Linked decisions:** D-005, D-013, D-016, D-017

## Evidence

`code-dev-study` and `code-dev-plan` are not single-shape programs — they
ship with rich parameter / mode systems already declared in the file header.

### code-dev-study modes

```
# modes: (overrides blanket # budget: caps when --mode is set)
#   overview:    {input-cap:  8000, output-cap:  4000}
#   subsystem:   {input-cap: 16000, output-cap:  6000}
#   deep:        {input-cap: 32000, output-cap: 12000}
```

Plus: `--output={engineering, executive, machine}`, `--target=<path|glob>`,
`--input=<path>`.

**Acceptance predicate declared inline:** "Phase ends when both user and AXON
rate satisfaction ≥ 7." This is one of the only explicit goal-completion
gates in the code-dev family.

### code-dev-plan modes

```
# plan-modes:
#   tactical:    {input-cap: 4000, output-cap: 6000}
#   strategic:   {input-cap: 4000, output-cap: 1500}
#   operational: {input-cap: 4000, output-cap: 3000}
#   decision:    {input-cap: 4000, output-cap: 4000}
```

Plus: `--budget N` (PR cap), `--rule "<text>"` (governance injection).

### code-dev-safety-audit invocation patterns

```
code-dev audit          — full audit
code-dev audit [PR-N]   — audit specific PR
code-dev audit diff     — only PRs with issues
```

## What this tells us about the synapse contract

A synapse is not one transition — it's a **family of transitions** keyed by
mode/parameter. The schema (F-005) must accommodate:

1. **Modes** — a synapse declares discrete modes; each mode has its own
   precondition / inputs / outputs / post-state / cost.
   ```yaml
   synapse:
     name: code-dev-study
     modes:
       overview:    { cost: { tokens: 8000 },  post-state: phase.has(study.overview) }
       subsystem:   { cost: { tokens: 16000 }, post-state: phase.has(study.subsystem) }
       deep:        { cost: { tokens: 32000 }, post-state: phase.has(study.deep) }
   ```

2. **Acceptance predicates** — `study`'s "satisfaction ≥ 7" must be a
   first-class post-state predicate. Schema needs predicate language:
   `state.satisfaction.user >= 7 AND state.satisfaction.axon >= 7`.

3. **Budget per mode** — orchestrator's ranker uses cost to break ties and
   warn user (D-007 goal-fit + cost-fit).

4. **Output variants** — `--output=engineering|executive|machine` doesn't
   change semantics but changes artifact shape. Schema can fold these as
   `output-variants: [...]` rather than separate modes.

5. **Pre-load inputs** — `--input=<path>` shows that synapses can accept
   ad-hoc data injection. Schema: `accepts-input-stream: bool`.

6. **Constraint injection** — `--rule "<text>"` (PR-11) shows runtime
   constraint addition. Schema: `accepts-runtime-rules: bool` with effect
   declared (modify guards / scoring / acceptance).

## Implication for D-017 (Fixed vs Adaptive modes)

A **fixed** workflow file references parameterized synapses with mode locked:
```yaml
synapses:
  - name: code-dev-study
    mode: subsystem
    target: tools/shadow.py
  - name: code-dev-plan
    mode: tactical
    budget: 12
```

An **adaptive** workflow leaves mode unset — orchestrator picks at runtime
based on state (e.g. if the codebase is large → `deep`, else `overview`).

A **hybrid** workflow has mixed step modes — fixed for `study --mode=overview`,
then adaptive for the plan step.

## Implication for D-016 (registration)

Adding a new tool to REGISTRY today only carries `script / status / category
/ purpose` (per F-001 walk). For the new tool to participate as a
parameterized synapse, **registration must accept modes/budgets/post-state
predicates inline** OR the synapse-infer engine (D-005) must parse them
from the program file header.

The hybrid (D-005) lets authors declare in either place; inference fills
the gap.

## Implication for D-028 (conversational workflow author)

When the user says "I want a python-code-dev workflow that lints, tests,
reviews, then writes commit msg", AXON must:

1. Pick `code-dev-study --mode=subsystem` or `--mode=deep` based on
   "python-code-dev" context — and ASK the user if unclear.
2. Choose `code-dev-plan --mode=tactical` (PR list) or `--mode=operational`
   (run-book) — ASK if intent is ambiguous.
3. Generate the workflow file with locked modes.

The conversational author is essentially **mode + parameter selection
through dialog**.

## Suggested action

- **Phase 2 design Q.** Synapse-contract schema with `modes:`,
  `acceptance-predicates:`, `output-variants:`, `accepts-input-stream:`,
  `accepts-runtime-rules:` — validated against `code-dev-study`,
  `code-dev-plan`, `code-dev-safety-audit` as the corpus.
- **Phase 2 design Q.** Predicate language for post-state +
  acceptance-predicates. Candidates: a tiny expression DSL (`state.foo > 7
  AND file.exists('02-plan.md')`) OR explicit Python predicates.
- **Phase 3 PR seed.** `synapse-contract-author-code-dev-study` —
  reference contract for the parameter-richest program.
- **Phase 3 PR seed.** `conversational-workflow-author` — interactive
  program (`workflow-new --from-description "<text>"`) that walks dialog
  through synapse + mode picks.

## Note

This finding **closes** the abstraction gap between F-005 (no synapse
contract exists) and the real shape of programs. F-005 said the schema
must exist; F-013 says the schema must be **parameterized**, not single-shape.

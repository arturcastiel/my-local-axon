# Plan Review — AXON Re-Arm

**Reviewer:** AXON Systems Architect (master developer)
**Lens:** AXON's own architecture — the 4-layer model, the enforcement spine, dogfooding, the kernel floor.
**Scope:** `02-plan.md` + `02-prs.md` + `01-study.md` + `HANDOFF.md`, cross-checked against the live tree at
`/home/arturcastiel/projects/new-axon/axon` (read-only; no pytest/builds; no code modified).
**Posture:** ADVISORY ONLY.

---

## 1. Verdict

**SOUND-WITH-RISKS — confidence 0.8.**

The plan is architecturally correct in its *thesis* and its *sequencing principle*. It correctly diagnoses a
right-architecture-left-switched-off system, it correctly puts Tier 0 (instrument + arm + mechanize) first, and
its critical-path DAG (`PR-T0-2a → PR-T0-2`, `PR-T1-1 → {T1-2..5}`, `PR-T0-1 → {T3-2, T6-exp}`,
`PR-T4-4 → {T4-5, T5-3}`) genuinely respects the dependencies I can verify in the code. Every load-bearing
factual claim I spot-checked holds against the live tree (the `:131`/`:155` resolver disagreement, zero
`*-required` flags on disk, the `unknown→None` drift-gate seam, `KERNEL-SLIM:2 v1.1.7` vs `VERSION 3.8.0`,
`tools/`+`settings.json` outside the R9 boundary, the 29 legacy programs).

It is **not** SOUND-unqualified because the plan under-specifies four architecture-level hazards that, left as
written, can break what currently works or strand a PR mid-wave: (a) the live-session brick path that arming the
flags actually traverses is `verify_stop → next_turn_gate`, not an abstract "BLOCK," and the plan never names a
rollback/kill-switch for it; (b) **PR-T0-1 must edit `.claude/settings.json` to add a `PostToolUse` hook that
does not exist today, and that same file is what PR-T2-2 makes un-writable** — a self-lock the plan does not
sequence; (c) the dual `tools/` vs `workspace/tools/` tree means several PRs are ambiguous about *which* copy
they fix; (d) the kernel-floor (Layer 1) edits are correctly flagged as per-change-confirm, but two of them
(PR-T2-2's "Layer 0" and PR-T1-1's resolver) are mis-located in the layer model and need a kernel-prose change
the plan treats as incidental.

None of these is fatal. All are addressable with sequencing notes and two new sub-PRs. Hence SOUND-WITH-RISKS.

---

## 2. What the plan gets right (architecturally)

1. **Tier 0 first is not negotiable, and the plan honors it.** The whole epistemic argument — you cannot measure
   whether a fix worked until the meter (`PR-T0-1`) reads real data and the flags (`PR-T0-2`) actually bite — is
   correct and is the single most important architectural call in the backlog. `02-plan.md:4-5` and the §4 drift
   verdict are right that everything downstream is unfalsifiable until A1/A2/A3 land.

2. **The seam-not-engine remediation style (T3) is respected throughout.** The plan fixes *consumers and joins*,
   not engines: `PR-T1-1` collapses two resolvers into one (the duplication IS the bug — verified: `changed_files()`
   at `crucible.py:126` uses `... || git rev-parse HEAD~1` with no `2>/dev/null` on the fallback, while
   `_changeset_base()` at `:148` has `2>/dev/null` on both clauses); `PR-T3-2` fixes the `r_drift_gate.py`
   *consumer* (the `unknown→return None` at the line the report cites), not `drift.py`; `PR-T4-5` fixes the
   `workflow-run --name` lookup *namespace*. This is the right surgical posture for a self-honest codebase whose
   engines (R9, `phase_model.done()`, `workflow_run.advance`, registry hygiene) are confirmed-strong and must NOT
   be rewritten.

3. **R9, registry hygiene, and `phase_model` are correctly left untouched.** `01-study.md:18` explicitly carves
   out "do not rewrite engines," and no PR in the backlog touches `r9_axon_write`, `registry_drift`, or
   `phase_model.done()` internals. This is the correct dogfooding instinct — the plan re-arms the periphery
   without disturbing the one boundary (R9) that already has true mechanical teeth.

4. **The kernel-floor discipline is real and explicit.** `HANDOFF.md:34-36` and `02-plan.md:40-41` flag the three
   KERNEL-SLIM edits (OD-1 prose, OD-2 lines 188/341, F1 version) as dev-mode + per-change owner-confirm, and the
   "kernel floor stays human" rule is stated. This matches the live mechanism: `axon/` writes require
   `L:dev-mode≡true` (verified in `enforce.py:76-85`), enforced identity-independently by `enforce_pretooluse.py`
   even on a fresh clone. The plan does not try to automate the floor away.

5. **The grandfather glide-path (PR-T1-5, OD-5) is the correct conservative shape.** Mirroring the existing,
   verified `tools/liveness-allow.txt` with an append-forbidden, shrink-only `test-grandfather.txt` is exactly
   right: it never bricks (new neurons always need tests) and the exempt set is monotonic toward zero. This is the
   plan at its best — reusing a proven AXON pattern rather than inventing one.

6. **The thin-kernel experiment (PR-T6-exp, OD-8) is correctly sequenced LAST and correctly gated on the meter.**
   Putting the null hypothesis after `PR-T0-1`/`PR-T0-3` is the only intellectually honest ordering: you cannot
   run a heavy-ceremony-OFF-vs-ON drift comparison until the drift detector reads real data. The plan preserves
   the dissent instead of flattening it (`02-plan.md:43-45`). Architecturally this is the right humility.

---

## 3. Weaknesses / risks / gaps (ranked by severity)

### SEV-1 — The arming PR has no kill-switch, and the live-brick path is mis-described. `PR-T0-2` (+ `PR-T2-clone`, `PR-T3-2`)
The OD-1 dissent ("arming risks bricking live sessions on false positives") is **understated** in the plan, which
treats arming as "convert ~6 silent rules to live BLOCK with zero new code." On the live tree the actual mechanism
is sharper than that: an armed rule's BLOCK verdict is produced at the crucible/response gate, **persisted by
`verify_stop.py`** (which is LOG-ONLY at the Stop surface — it "cannot un-send"), and then **`next_turn_gate.py`
exits 2 at the START of the next turn** to deny it (the gate-on-next-turn pattern, verified in both hooks). So a
false-positive from a newly-armed `state-surfaced-required` / `reasoning-trace-required` / `phase-tracking-required`
rule does not just warn — **it halts the user's next turn until the persisted pending-gate file is cleared or ages
out.** That is a real brick path for an interactive session.

The plan gives `PR-T0-2` a per-rule reproduce-then-block test but **no documented rollback** (how does the owner
disarm a single misfiring flag fast?) and **no false-positive burn-in** (the rules have never run live against
real traffic). Compounding this: `dev-mode.md` on the live tree currently reads `value: true` — so the very
session that lands `PR-T0-2` is itself armed-and-dev-moded, and `r_drift_gate.py` demotes BLOCK→WARN under
dev-mode but the other newly-armed rules may not. The interaction between dev-mode demotion and the next-turn gate
is unspecified.

**Fix (mandatory before execution):** add an explicit, named disarm path to `PR-T0-2` (a single `*-required=false`
write that the gate honors immediately, documented as the kill-switch) and require a **staged rollout** — arm ONE
flag, observe N turns of real traffic for false positives, then the next — rather than all six in one PR. Add an
acceptance criterion that `next_turn_gate.py`'s pending-gate file has a bounded, documented max-age (it references
one; confirm and pin it) so a stale false-positive cannot wedge a session indefinitely.

### SEV-1 — `PR-T0-1` and `PR-T2-2` form a self-lock on `.claude/settings.json`. `PR-T0-1`, `PR-T2-2`
There is **no `PostToolUse` hook in the active `.claude/settings.json`** today (verified: it wires only
`UserPromptSubmit`, `PreToolUse`, `Stop`). So `PR-T0-1` ("wire `drift record` from a real PostToolUse interceptor")
is **not** pure tool-side wiring — it must (a) write a new hook script under `tools/hooks/` and (b) **edit
`.claude/settings.json`** to register a `PostToolUse` matcher. But `PR-T2-2` makes `.claude/settings.json`
a protected path ("gated like axon/"). If `PR-T2-2` lands before any future `PostToolUse` change, every later
settings edit needs the protected-write path. More urgently within the first sprint: the first sprint runs
`PR-T0-1` AND `PR-T2-2` together (`02-prs.md:5`), and the plan does not say `PR-T0-1`'s settings edit must precede
`PR-T2-2`'s lock or be routed through the same dev-mode/out-of-band channel `PR-T2-1` builds.

**Fix:** state the ordering explicitly — `PR-T0-1`'s `.claude/settings.json` edit lands BEFORE `PR-T2-2`'s
protection, OR `PR-T2-2` ships first and `PR-T0-1` uses the protected-write path. Add `.claude/settings.json` to
the "files this PR must edit" list of `PR-T0-1` so the reviewer sees the kernel-adjacent edit coming. This is also
a dogfooding tell: the moment you protect `settings.json`, every hook change becomes a governed change — that is
correct, but the plan must own the workflow, not discover it mid-wave.

### SEV-2 — Dual `tools/` vs `workspace/tools/` tree leaves several PRs ambiguous. `PR-T0-1`, `PR-T3-3`, `PR-T1-1`
The report flags the dual-encoding smell (T5), and I confirmed it live: `tools/drift.py` is 352 lines (Jun 19)
while `workspace/tools/drift.py` is 225 lines (May 26) — a 127-line, multi-week divergence. `tools/crucible.py`
exists; there is no `workspace/tools/crucible.py`. The plan's PRs say "fix `drift.py`" / "fix `crucible.py`"
without naming the tree. `PR-T0-1` (drift interceptor), `PR-T3-3` (unify the dual drift encoding — which is *about*
this divergence), and `PR-T1-1` (the resolver) all need to state **which copy is canonical and load-bearing at
runtime**, and whether the stale copy is deleted or re-synced as part of the PR. `PR-T3-3` in particular cannot
"unify" without first declaring the SSOT; today it reads as a kernel-literal fix only.

**Fix:** add a one-line "canonical tree: `tools/` (runtime); `workspace/tools/` copy is {deleted | re-synced}"
note to `PR-T0-1`, `PR-T1-1`, `PR-T3-3`. Consider promoting the dual-tree reconciliation to its own small PR in
Wave 3 so the divergence is closed once, not papered over per-PR.

### SEV-2 — The "Layer 0" introduction is a kernel-prose edit the plan treats as incidental. `PR-T2-2`
The live 4-layer model in `axon/KERNEL-SLIM.md:555-558` is Layer 1 (`axon/`) → Layer 2 (`workspace/`) →
Layer 3 (`my-axon/`) → Layer 4 (`workspace/addons/`). There is **no Layer 0**, and `is_axon_path`
(`tools/_axon_paths.py:42`) provably classifies ONLY paths under `axon/` — so `PR-T2-2`'s claim that `tools/` and
`.claude/settings.json` are unprotected is correct and the blast radius is real. But `PR-T2-2` offers two routes:
"extend `is_axon_path → is_protected_path` OR declare a 'Layer 0 — enforcement core'." The second route is a
**KERNEL-SLIM prose edit** (it changes the canonical layer model), and the plan's KERNEL-edit flag list
(`02-plan.md:40`) names only OD-1 prose, OD-2 lines 188/341, and F1 version — it does **not** list `PR-T2-2`. If
the owner picks the Layer-0 framing, that PR silently becomes a per-change-confirm kernel edit that the plan did
not pre-flag.

**Fix:** either commit to the `is_protected_path` route (pure tools-side, no kernel edit) in `PR-T2-2` and drop
the Layer-0 alternative, or add `PR-T2-2` to the KERNEL-SLIM-edit list with a per-change-confirm flag. Do not
leave the routing open at execution time. Architecturally I recommend `is_protected_path` first (mechanical,
testable, no floor edit) and a *follow-up* doc PR to teach the layer model about the enforcement core, so the
mechanism lands before the prose.

### SEV-2 — `PR-T1-1` changes runtime fail-closed behavior on a path `PR-T2-clone` also touches. `PR-T1-1`, `PR-T2-clone`
`run_changeset` (`crucible.py:182`) already has a fail-closed guard at the empty-changeset/no-base case
(`R_CHANGESET_BASE`, verified at `:189-196`). `PR-T1-1` collapses the two resolvers; `PR-T2-clone` makes
merge/`-required` checks fail-closed on absent state. These two interact: both change the "what happens when we
cannot resolve state" behavior, on overlapping code, and `PR-T2-clone` must distinguish "no active project"
(legit) from "state suppressed" (block). The plan lists them in different waves with no cross-dependency edge in
the critical path (`02-plan.md:28-31`). A `PR-T1-1` that hardens fail-closed and a `PR-T2-clone` that *also*
hardens fail-closed, landed independently, risk double-blocking the legitimate fresh-clone / no-project case the
report explicitly warns about (OD-6's "loud N/A, not silent pass" requirement).

**Fix:** add a dependency note that `PR-T2-clone` must be tested *against* the post-`PR-T1-1` resolver, and that
the "no active project → allow/loud-N/A" fixture is a shared acceptance test owned by whichever lands second.

### SEV-3 — `PR-T0-2a` (the SSOT seed) is the true critical-path root, not `PR-T0-2`. `PR-T0-2a`, `PR-T0-2`
The plan correctly makes `PR-T0-2` depend on `PR-T0-2a`, but it under-weights `PR-T0-2a`. The report
(`00-...handoff.md:108`) says only 5 programs declare `# emits:` and 13/16 real `_phases.json` lack `outputs:`.
Seeding ~16 phase files and the program-emit declarations is **the largest content change in Tier 0** and the one
most likely to be wrong (a mis-declared `outputs:` set makes `terminal-outputs-required` either bite nothing or
block legitimately). Yet it carries a `[HIGH]` tag and a single drift-lock test. If the seed is incomplete when
`PR-T0-2` flips the flag, the flag "bites nothing" (the report's own caveat) and the first sprint declares victory
on a gate that is inert — re-creating the exact disarmed-but-looks-armed failure this whole project exists to fix.

**Fix:** raise `PR-T0-2a`'s test bar to "every ladder/ownership program's declared-outputs set is non-empty AND
the `terminal-outputs` rule, run against each, distinguishes a compliant from a violating fixture" — i.e. prove
the gate bites BEFORE flipping the flag, not just that the SSOT parses.

### SEV-3 — `PR-T4-shadow` is a study step inside an execution backlog with no decision deadline. `PR-T4-shadow`, `PR-T5-4`
The 29 legacy `axon/programs/` nodes are confirmed live on disk. `PR-T4-shadow` is honest to call them an
investigate-first ADR step (OD-4), but it sits in Wave 4 with `PR-T5-4` (the typed graph, OD-3) depending on the
same population's resolution conceptually — and the plan does not edge `PR-T4-shadow → PR-T5-4`. If the graph
generator runs before the migrate-vs-retire decision, the ~38%-isolated count and the legacy nodes get baked into
the graph's "truth" prematurely.

**Fix:** add a soft dependency `PR-T4-shadow → PR-T5-4` (the graph should be generated AFTER the legacy
population is classified migrate/retire), or explicitly scope `PR-T5-4` to the 174-program workspace set and
declare the 29 out-of-graph pending the ADR.

### SEV-3 — No PR re-arms Core Rule 11 (cognition-language), the kernel's "loudest rule." (gap)
The report states (T1, §2) that Core Rule 11 "has no BLOCK path anywhere." The backlog arms six flags in
`PR-T0-2` (state-surfaced, reasoning-trace, phase-tracking, terminal-outputs, workflow-node-order,
no-orphan-tools) and `r_cognition_language.py` exists on disk — but no PR explicitly gives CR-11 a biting path.
`PR-T3-3` fixes the *drift-log dispatch* for persona-bleed but that is the detector's logging, not a BLOCK gate.
For a project whose thesis is "arm the loudest rules," leaving the self-described loudest rule unarmed is a
coherence gap.

**Fix:** add an explicit decision to the plan — either CR-11 is in `PR-T0-2`'s flag set (and gets a per-rule
reproduce-then-block test) or the plan states why it stays advisory (and softens the kernel prose accordingly,
per OD-1's "you cannot leave the kernel reading two ways about the same rules").

---

## 4. Specific changes I would make before execution

1. **Add a kill-switch + staged rollout to `PR-T0-2` (SEV-1).** Split the six flags so they arm one-at-a-time with
   a real-traffic burn-in between, and document the immediate-effect disarm write. Pin `next_turn_gate.py`'s
   pending-gate max-age. Acceptance: a deliberately-induced false positive can be cleared in one owner action and
   never wedges a session past the max-age.

2. **Sequence the `.claude/settings.json` self-lock (SEV-1).** Make `PR-T0-1`'s settings edit explicit in its file
   list and land it before `PR-T2-2`'s protection, or route it through `PR-T2-1`'s out-of-band path. Add an edge
   `PR-T0-1 (settings edit) → PR-T2-2` to the DAG.

3. **Declare the canonical tree per dual-tree PR (SEV-2).** One line in `PR-T0-1`/`PR-T1-1`/`PR-T3-3` naming
   `tools/` as runtime-canonical and stating the fate of the `workspace/tools/` copy. Consider a dedicated
   dual-tree reconciliation PR in Wave 3.

4. **Resolve `PR-T2-2`'s Layer-0 ambiguity (SEV-2).** Commit to `is_protected_path` (mechanism, no kernel edit)
   for the gate, and move any "Layer 0" prose into a separate, explicitly-flagged KERNEL-SLIM doc PR. Update the
   KERNEL-edit list in `02-plan.md:40` accordingly.

5. **Cross-test `PR-T1-1` and `PR-T2-clone` on the fresh-clone case (SEV-2).** Shared "no active project →
   loud-N/A, not double-block" fixture owned by whichever lands second.

6. **Raise `PR-T0-2a`'s bar to prove-the-gate-bites (SEV-3).** Do not flip `terminal-outputs-required` until a
   compliant-vs-violating fixture is distinguished per ladder/ownership program.

7. **Edge `PR-T4-shadow → PR-T5-4` or scope the graph to 174 (SEV-3).** Do not bake the unclassified 29 legacy
   nodes into the typed graph's truth.

8. **Decide CR-11's posture explicitly (SEV-3 gap).** Arm it with a test, or document advisory + soften kernel
   prose. Do not leave the loudest rule in the spec-vs-enforcement limbo this project exists to close.

---

## 5. The one architectural risk that worries me most

**That `PR-T0-2` declares "armed" on a gate that bites nothing, and the project certifies its own success against
a meter it hasn't proven reads true.** The entire epistemic engine of this plan is the falsifiable prediction:
arm + instrument + mechanize, then *measure*. But two of the first-sprint PRs can pass their stated tests while
leaving the system functionally still-disarmed — `PR-T0-2` if `PR-T0-2a`'s SSOT seed is incomplete (the flag flips,
nothing bites), and `PR-T0-1` if the new `PostToolUse` hook writes a trace that `drift.py` reads but that does not
actually reflect real tool sequences (the meter reads, but reads noise). In both cases the dashboards go green and
the project moves to Wave 1 believing it is "armed and instrumented" while reproducing the *exact* failure mode the
8 councils named: **disclosed risk mistaken for managed risk (theme T2), enforcement that looks live but observes
nothing.** The plan's own method ("STRONG automated test, reproduce-then-block, no fingerprint-only closure") is
the right antidote — but it must be applied to the *outcome* (the gate bites a real violation end-to-end; the meter
moves on a real drift event), not just the *unit* (the flag is set; the trace file is non-empty). I would make
"prove it bites / prove it reads true" an explicit, non-waivable acceptance gate on `PR-T0-1` and `PR-T0-2` before
the first sprint is allowed to close. Everything else in the backlog is correctly downstream of that.

# Code-dev Compliance — Council Plan
> HR-team advisory verdict (advisory_only · human_review_required). Convened 2026-06-22 via real
> catalog-persona sub-agent fan-out (hr_team.py run_seats is the dormant PR-T4-hrteam seam — bypassed
> with real cognition, never stubbed). Protocol: weighted-vote · 7 seats · aggregate confidence ~78/100.
>
> Roster: harness-designer · agentic-workflow-designer · kernel-engineer · build-reproducibility-engineer
> · release-engineer · completer-finisher · challenger (mandatory adversary).

## VERDICT: PROCEED-WITH-CHANGES (0.78)
Build the GENERAL capability, but in the order the dissent demands: **prevent at write-time first,
audit read-only second, auto-fix only the mechanically-derivable, defer the auto-migrator until N>1.**
The hand-done axon-rearm reconcile is NOT yet certified — a tested checker must confirm it.

---

## WHY (the problem, in one paragraph)
code-dev projects created with an in-flight/older AXON drift from the current schema (this is exactly why
axon-rearm broke: branch, DAG status, missing v4 scaffold, unset metadata). The drift is silent until it
breaks at use-time. The existing guardrails are weak: `code-dev-safety-audit-structure` hardcodes its
required-file list (will drift from `_code-dev-schema-v4.md`) and its `--fix` writes **stubs that satisfy
existence checks** — institutionalized false-green. The fix must make drift (a) impossible to land silently,
(b) detectable as DATA, and (c) auto-correctable ONLY where the correct value is mechanically derivable.

## WHAT to build (3 layers, in priority order)
1. **Write-time `schema-version` gate** (cheapest, highest leverage — challenger).
   Any code-dev write program touching a project whose `schema-version` < current → BLOCK + print the gap.
   Fail-closed, reuses the existing block machinery (same pattern as `R_DONT_DO`). Drift can never land.
2. **Versioned compliance manifest** (schema-as-data — unanimous).
   Promote `_code-dev-schema-vN.md` into a machine-readable manifest (required project/phase files,
   required `_meta` fields, DAG invariants, dont-do `match:`/`review:` rule, SESSION-marker window).
   The checker reads `_meta.schema-version` → loads the matching manifest. v5 = a new manifest + migration
   delta, **zero checker-code edits**. Bind manifest + linter + gate to ONE parser so they never disagree.
3. **`code-dev compliance` (a.k.a. `doctor`) — read-only by default** (builders + challenger concession).
   Thin orchestrator over single-concern modules (reuse `check-structure`, `branch`, `dont-do-lint`, `dag`).
   Each emits a typed finding `{check, severity, locus, expected, actual, fix-class}`. `--fix` is OPT-IN
   and touches ONLY the `derivable` class; `inferred`/`semantic` findings are REPORT-ONLY → human.

## HOW (the engineering contract — non-negotiables)
- **Auto-vs-gated split = "is the correct value mechanically derivable AND reversible?"**
  - AUTO (derivable): branch sync (git is truth), additive `_meta` fields, scaffold *containers*, DAG
    `set-status` from PR-spec state, additive `migrate`, dont-do *detection*.
  - HUMAN-GATED (semantic): DAG `add-edge` (a dependency claim — NEVER auto-infer), per-node dod/proves
    content, dont-do token authoring, prose→tokenized conversion, ANY working-tree commit.
- **No false-green firewall:** existence ≠ content. A stub/pointer must be reported as `stub` (= debt that
  FAILS a follow-on content check), never counted as `present`. A run with ANY escalate-class finding exits
  NON-green even after fixing all derivable ones.
- **Idempotent / convergent:** `fix` then re-run ⇒ zero derivable findings, zero writes. Fix is a pure
  function of (manifest, observed state, external truth) — no timestamps-of-convenience.
- **Reversible:** every mutation snapshots to `_actions.log` + `archive/snapshots/<id>/` BEFORE writing
  (v4 universal-undo pattern). Unknown schema → fail-closed (decline, don't guess).
- **Tests (Core Rule 13 / R_NEW_NEEDS_TEST):** golden fixtures — clean project + one per drift class;
  RED-before/GREEN-after; idempotency (run-twice no-op); negative (unknown schema declines); a dirty-tree
  fixture must make the pass FAIL. The program may not register ACTIVE without these.
- **Kernel floor:** writes only under `my-axon/dev-projects/{project}/` + `workspace/`; never `axon/`.
  AXON-only commit trailer. Schema bumps touching kernel shape stay human-only.

## WHEN (sequencing)
- **Now (this/next session):** layer 1 (write-time gate) + close axon-rearm's own loose ends (below).
- **After the gate lands + ≥2 drifted projects exist:** freeze the detector set, build layer 2 (manifest)
  + layer 3 (`compliance` program) with its full test suite. Do NOT generalize the detector set off the
  single axon-rearm sample (kernel-engineer + challenger).
- **At each future schema bump (v4→v5…):** ship a manifest + a tested per-version migration step
  (generalize `code-dev-migrate`'s existing dry-run/--apply/--restore) + a `compliance-level` stamp so
  staleness is LOUD at every program entry, never discovered at break-time (release-engineer).

## AXON-REARM NEXT (priority-ordered — strong consensus across all 7 seats)
1. **Resolve the dirty tree FIRST** — 9 modified + untracked `_policy.md`. Attribute each to a PR/commit or
   a tracked WIP-register. Until clean-or-attributed, axon-rearm is NOT compliant (completer-finisher: hard gate).
2. **Audit this session's stubs** — the `phases/pr/` pointer files + empty `shadow/`: fill with real content
   or delete. Do not leave them as silent green (challenger).
3. **Backfill `_actions.log`** + a retro snapshot of the ~18 files the reconcile touched — close the
   reversibility gap (build-repro: the hand-done pass wrote with no undo trail = itself drift).
4. **Encode T1-1+T1-cihost co-merge** as a real ATOMIC DAG edge (owner-confirmed) + a test it can't land apart.
5. **Add per-node dod/proves** to the 34 DAG nodes (M7) + a meta-test failing on any empty node.
6. **Then** draft layers 1–3 using axon-rearm as the regression fixture; re-run and require a **0-flag exit**
   before stamping axon-rearm "compliant."

## PRESERVED DISSENTS (do not average away)
- **CHALLENGER (82):** an auto-fixer that fills existence-checks with stubs is *worse* than a loud red.
  Cheapest real fix = the write-time gate; the read-only audit is the only safe auto part; defer the
  auto-migrator until N>1, and its acceptance test must prove it BLOCKS rather than guesses on the flagged cases.
- **BUILD-REPRO / RELEASE-ENG:** the hand-done reconcile is unverified (no fixture, no `_actions.log`) —
  do NOT treat axon-rearm as compliant until a tested checker certifies it; bind spec+linter+migration to one parser.
- **HARNESS-DESIGNER:** never auto-WRITE DAG edges (suggest yes, write no) — manufacturing "missing" edges
  is false-green on the critical path. SESSION-marker freshness must be advisory, never a hard block.

## CONCLUSION
Yes — make compliance a first-class, repeatable, version-aware capability, but **invert the instinct**:
the win is not a clever auto-fixer, it is (1) a fail-closed write-time schema-version gate that stops drift
landing, and (2) compliance-as-data (a versioned manifest) so the check auto-advances with the schema.
The `compliance`/`doctor` program is the third layer, read-only by default, auto-fixing ONLY the mechanically
derivable and escalating everything semantic — and it must ship with tests that make false-green impossible,
including a dirty-tree-fails fixture. First, close axon-rearm's own flagged loose ends (dirty tree, stubs,
`_actions.log`, co-merge edge, dod/proves) — because today's reconcile is real progress but is not yet
*certified*, and under redo-until-closed, uncertified ≠ done.

## META-FINDING
This council had to be run as a real sub-agent fan-out because `hr_team.py run_seats` raises
NotImplementedError — i.e. **PR-T4-hrteam is load-bearing** ("AXON must ALWAYS be able to convene a real
council"). The working-bridge fan-out succeeded; prioritize landing PR-T4-hrteam so this is a built seam,
not a per-session workaround.

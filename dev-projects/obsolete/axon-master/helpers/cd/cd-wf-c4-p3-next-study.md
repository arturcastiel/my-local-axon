# CD·WF·C4·P3 — proposed next studies

> What deserves the next deep dive after Round 4. Ranked by leverage.

## Candidate studies

### Study A — `library-dev` and other subsystems (parallel structure)
**Scope:** library-dev has ~?? programs (need to count). Apply Rounds 2/3/4 framework to it. Are there cross-subsystem patterns to harmonize?
**Why now:** code-dev rename plan defines a shared lexicon. If library-dev adopts the same, the whole AXON OS feels coherent.
**Why later:** library-dev is less used than code-dev.
**Score:** 4/5.

### Study B — Schema v4 → v5 design + migrators
**Scope:** R9 (spec versioning) and R7 (stack-id) force schema change. Define v5; ship migrator; back-fill all known projects.
**Why now:** Gap G-CD-A1 (no migrator) has blocked axon-master and likely future v1 projects too.
**Risk:** schema work is high-touch.
**Score:** 4/5.

### Study C — Compiled-program ROI
**Scope:** Round-2 found `code-dev-pr-review.cmp.md` has -1% compression. Audit *every* compiled program. Decide which to recompile, decompile, or quarantine.
**Why now:** Cheap to do; immediate token savings.
**Score:** 4/5.

### Study D — Dispatch quality measurement
**Scope:** Add prompt-corpus + golden expected-verb file. Run dispatch.py over corpus; measure precision/recall. Iterate on `# desc:` lines.
**Why now:** Many of our gaps assume good dispatch; we've never measured.
**Score:** 4/5.

### Study E — Token economics deep-dive (turn-by-turn)
**Scope:** Cycle-3 looked at compiled-vs-source size. This study would look at *actual chat turns*: how many tokens does a single code-dev workflow consume end-to-end? Where are the spikes (study, plan-master)?
**Why now:** Optimizing token use is direct cost saving.
**Score:** 4/5.

### Study F — Knowledge subsystem (shadow, study, impact, explain) deep dive
**Scope:** These are the lowest-frequency, highest-magic verbs. Do they actually work? Are users finding them? Should they merge?
**Why later:** Lower-frequency by definition.
**Score:** 3/5.

### Study G — Multi-project ergonomics
**Scope:** Once `meta context use` ships, what should `code-dev` do across projects? Cross-project search? Multi-project dashboards? Shared rules?
**Why later:** Wait for context-switcher to actually ship.
**Score:** 3/5.

### Study H — Failure modes / postmortem patterns
**Scope:** Catalog every observed bug, near-miss, identity drift, and persona-bleed. Define recovery playbook.
**Why now:** We have at least one logged incident (2026-05-15 unauthorized push) and at least one schema mismatch (v1 in axon-master).
**Score:** 5/5.

### Study I — Workspace backup hardening
**Scope:** Push-policy gates, signing, encrypted secrets in `my-axon/`, what `.gitignore` should exclude. Round-trip restore test.
**Why now:** We just turned backup on; rough edges will appear.
**Score:** 4/5.

### Study J — Team-mode design
**Scope:** Multi-actor mode (G-T1..G-T8). Schema, gating, conflict handling.
**Why later:** Only do this if real team use emerges.
**Score:** 2/5.

### Study K — code-dev test surface
**Scope:** Are code-dev programs themselves tested? (Most programs are markdown; testing them is meta.) Define program-level regression tests.
**Why now:** Without tests, R6 (renames) is high risk.
**Score:** 5/5.

### Study L — Prompt-engineering as a code-dev concern
**Scope:** AXON programs are prompts. Should code-dev itself have a "prompt-dev" sub-mode? Lessons from research on prompt-engineering best practices.
**Why later:** Conceptual; lower urgency.
**Score:** 3/5.

### Study M — Compile pipeline + write gate (T-A3 from Round-2)
**Scope:** Ship the regression gate that would catch -1% compression. Design the gate's policy (threshold, allow-list, hard-fail vs warn).
**Why now:** Direct outcome of Round-2 top finding.
**Score:** 4/5.

### Study N — Audit + observability of AXON itself
**Scope:** Round-4 G-T1 (actor in log) is a piece. Larger: tracing across kernel ops, programs, tool calls. Per-session "trace" file.
**Why later:** Larger effort; depends on prior work.
**Score:** 3/5.

## Recommended ordering

```
1. Study H — Failure modes / postmortem patterns       (5/5; we have data; cheap)
2. Study K — code-dev test surface                      (5/5; pre-req for Round-3 R6)
3. Study D — Dispatch quality measurement               (4/5; cheap; feeds R1+R2 polish)
4. Study C — Compiled-program ROI audit                 (4/5; cheap; direct token win)
5. Study M — Compile-write regression gate              (4/5; ships Round-2 T-A3)
6. Study A — library-dev parallel structure             (4/5; harmonize)
7. Study B — Schema v4→v5 + migrators                   (4/5; unlocks R7/R9)
8. Study I — Backup hardening                            (4/5)
9. Study E — Token economics turn-by-turn                (4/5)
10. Study F — Knowledge subsystem                        (3/5)
11. Study G — Multi-project ergonomics                   (3/5)
12. Study N — AXON observability/tracing                 (3/5)
13. Study L — Prompt-engineering as a sub-mode           (3/5)
14. Study J — Team-mode design                           (2/5; if requested)
```

## Single recommendation if forced to pick ONE next

**Study H — Failure modes / postmortem patterns.**

Rationale:
- We have at least two logged incidents (2026-05-15 unauthorized push; axon-master v1 schema mismatch).
- Cheap to do (review of existing logs + writing a playbook).
- Directly informs Study K (tests), Study I (backup hardening), and the dont-do rule list.
- Builds the muscle of "post-event learning" before things scale.

Second pick: **Study K (test surface)** — pre-requisite for Round-3 Wave-4.

→ web references for follow-on work: `cd-wf-c4-p4-web-findings.md`.

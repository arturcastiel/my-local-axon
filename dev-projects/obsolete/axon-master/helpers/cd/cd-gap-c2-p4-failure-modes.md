# CD·GAP·C2·P4 — failure-mode catalog (U-4 / R4-H / R5-NS-12)

> Catalog of every observed or anticipated failure mode in code-dev (and AXON-adjacent). Each mode has class, trigger, signal, mitigation. Sourced from logged incidents + study findings + memory.

## Class A — Identity / persona drift

### F-A1. Persona-bleed after compaction
- **Trigger:** long session; context compacted; generic-LLM frame re-emerges.
- **Signal:** uses "As an AI…", drops AXON identity, breaks identity-gate.
- **Documented:** memory entry (operational-safety.md) 2026-05-15.
- **Mitigation:** boot re-anchor; identity-gate program; first-action check after compaction.
- **Owner:** kernel (axon/programs/identity.md).

### F-A2. Premature push (operational safety breach)
- **Trigger:** user provides remote URL; agent infers push consent.
- **Signal:** `git push` executed without explicit user "yes".
- **Documented:** memory entry 2026-05-15.
- **Mitigation:** memory rule + agent self-check before push.
- **Owner:** memory + agent contract.

### F-A3. Hallucinated tool output
- **Trigger:** tool fails; agent invents output rather than logging error.
- **Signal:** mentions of nonexistent files/results.
- **Mitigation:** kernel rule "never fabricate tool output"; log+QUERY on failure.
- **Owner:** kernel (axon/KERNEL-SLIM.md core rule 5).

## Class B — Schema / state corruption

### F-B1. Schema mismatch on resume
- **Trigger:** old project (v1) with newer kernel (expects v4).
- **Signal:** `code-dev resume` HALTS or produces nonsense.
- **Documented:** axon-master incident.
- **Mitigation:** schema migrator (U-2); `resume` auto-detects and offers upgrade.

### F-B2. `_meta.md` race / hand-edit collision
- **Trigger:** HUMAN edits `_meta.md` while program is writing.
- **Mitigation:** atomic write (temp+rename); mtime check pre/post.

### F-B3. `_actions.log` corruption
- **Trigger:** partial write; crash mid-append.
- **Mitigation:** journaling (one JSONL line at a time, fsync).

### F-B4. Lost `last-program` reference
- **Trigger:** crash before write; or migration error.
- **Signal:** `code-dev next` confused.
- **Mitigation:** fallback to `_actions.log` tail; QUERY user.

## Class C — Compile / token

### F-C1. Negative compression
- **Trigger:** compile expansion exceeds source.
- **Documented:** `code-dev-pr-review.cmp.md` at -1%.
- **Mitigation:** R2 T-A3 regression gate.

### F-C2. Static-prefix drift (cache-hostile)
- **Trigger:** dynamic content in program header.
- **Signal:** cache miss every run.
- **Mitigation:** static-prefix discipline; `axon/core/RUN-HEADER.md` review.

### F-C3. Token-budget overflow
- **Trigger:** large input to `study` / `plan-master`.
- **Mitigation:** HALT-with-partial; budget headers; checkpoint/resume.

### F-C4. Compaction loses critical state
- **Trigger:** long session compacted; in-flight state not journaled.
- **Mitigation:** journal events frequently; `state save` checkpoints; cold-boot anchor.

## Class D — Dispatch / routing

### F-D1. Free-text routed to wrong verb
- **Trigger:** ambiguous prompt or weak `# desc:` lines.
- **Mitigation:** dispatch quality measurement (U-12); golden corpus.

### F-D2. Stub forwards to wrong target
- **Trigger:** R3 W2 alias-stub typo.
- **Mitigation:** TW7 rename-safety tests; structural lint.

### F-D3. Recursive program invocation (loop)
- **Trigger:** A calls B which calls A.
- **Mitigation:** call-graph check at audit time; depth limit at runtime.

## Class E — Governance / safety

### F-E1. Plan violates `safety/rules.md`
- **Trigger:** plan generated without consulting rules.
- **Mitigation:** plan reads rules (G.plan.12); violations filtered with annotation.

### F-E2. PR ready false-green
- **Trigger:** gate misses a constraint (e.g. CI red but `pr ready` says go).
- **Mitigation:** R4 CI integration (`pr sync` + gate); `--strict` mode.

### F-E3. Rule contradiction (two rules conflict)
- **Trigger:** user adds two rules with opposing intent.
- **Mitigation:** governance composition rules (U-5 deep dive); precedence model.

### F-E4. Stale study not flagged
- **Trigger:** auth changed; security study 90 days old; pr-ready ignores.
- **Mitigation:** staleness flags (R5); `pr ready` consults `_index.md`.

## Class F — User-experience / discoverability

### F-F1. User can't find the right verb
- **Trigger:** 57 verbs; no cheatsheet.
- **Mitigation:** R4 cheatsheet + examples + Round-3 umbrellas.

### F-F2. Help text incomplete
- **Trigger:** program shipped without `## HELP`.
- **Mitigation:** T1 structural test.

### F-F3. Tour gets stale
- **Trigger:** `code-dev tour` references removed verbs.
- **Mitigation:** TW1 cross-reference check.

## Class G — Multi-project / context

### F-G1. Two projects with same slug
- **Trigger:** `code-dev new --slug axon-master` twice.
- **Mitigation:** uniqueness check at init.

### F-G2. `W:code-dev-project` stale (deleted on disk)
- **Trigger:** HUMAN deleted project folder; kernel still points there.
- **Mitigation:** existence check on resume; QUERY if missing.

### F-G3. Context-switch loses unsaved state
- **Trigger:** `meta context use` switches mid-flow.
- **Mitigation:** auto-save before switch; warn if dirty.

## Class H — Backup / sync

### F-H1. Backup push of secrets
- **Trigger:** developer pastes secret into a chat → saved → pushed to GitHub.
- **Mitigation:** redact-secrets on journal log; pre-push scan; `my-axon/memory/local/` for sensitive.

### F-H2. Push without consent (operational)
- **Trigger:** F-A2 above.
- **Mitigation:** memory rule.

### F-H3. Restore loses uncommitted changes
- **Trigger:** restore overwrites unsaved local state.
- **Mitigation:** auto-snapshot pre-restore.

## Postmortem template (proposed)

`workspace/templates/postmortem.md`:
```
# Postmortem: <title> (<date>)

## Summary
<1-2 sentences>

## Timeline
- t0: ...
- t1: ...

## Class (from failure-mode catalog)
F-?? (e.g. F-A2)

## What worked
- ...

## What didn't
- ...

## Lessons
- ...

## Action items
- [ ] <gate / test / rule>  (owner, due)
```

## Cross-reference to existing protections

| Class | Existing protection                                     |
|-------|---------------------------------------------------------|
| A     | kernel rule 5, identity.md, memory/operational-safety.md |
| B     | atomic writes (partial); migrator (gap)                  |
| C     | benchmark.py, compile_optimizer.py (advisory)            |
| D     | dispatch.py + dispatch_stats.py                          |
| E     | safety programs, dont-do rules                           |
| F     | help/tour/whatif programs                                |
| G     | code-dev-load existence check (partial)                  |
| H     | gitignore + my-axon/memory/local/                        |

## Mitigation priority (top-10)

| Priority | Failure mode             | Mitigation cost | Damage potential |
|----------|--------------------------|----------------:|-----------------:|
| 1        | F-A2 (premature push)    | low (rule)       | HIGH             |
| 2        | F-A1 (persona drift)     | low (anchor)     | HIGH             |
| 3        | F-B1 (schema mismatch)    | medium (U-2)     | HIGH             |
| 4        | F-C1 (negative compression) | low (T-A3)     | MEDIUM           |
| 5        | F-A3 (hallucinated output) | low (rule)      | HIGH             |
| 6        | F-E4 (stale study)       | low (R5)         | MEDIUM           |
| 7        | F-D1 (mis-dispatch)      | medium (U-12)    | MEDIUM           |
| 8        | F-H1 (secret push)       | low (redact)     | HIGH             |
| 9        | F-E3 (rule contradiction)| low (U-5)        | MEDIUM           |
| 10       | F-C4 (compaction loss)   | medium           | MEDIUM           |

## Acceptance for this catalog
- This file becomes the seed for `workspace/log/failure-modes.md` (the canonical catalog).
- Each F-?? gets a mitigation owner and PR backlog entry.
- New incidents get classified to a class + appended.

→ governance composition: `cd-gap-c3-p1-governance.md`.

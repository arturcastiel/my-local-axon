# Masterplan — AXON Memory (harmonized spec)

> North star: an AXON-native, harness-portable memory + reminders subsystem that stays
> scalable in ANY real workflow — never bulk-loaded, never rotting, never leaking,
> never interrupting. Authored in-conversation 2026-05-24; grounded against the live
> codebase before any decision was locked.

## Invariants (non-negotiables)
1. **Single memory API** — programs/tools call `RECALL`/`REMEMBER`; the machinery owns
   the rest. No bespoke per-program memory stores.
2. **Store only the non-derivable** — if it is re-readable from code/git/artifacts, it
   is NOT memory. (Primary bloat-defense.)
3. **Private by default** — writes land in `my-axon/` (private, gitignored); `workspace/`
   only when explicitly shareable.
4. **Recall-driven, not bulk-loaded** — boot loads GENERAL only; everything else is
   pulled on demand. (Decouples memory size from the context budget = the scalability key.)
5. **Reference-bound & self-reconciling** — every entry carries bindings; AXON's view
   (index + cross-refs) always matches what is actually on disk.
6. **Non-interrupting** — auto-capture safe classes inline; batch the rest into an
   end-of-task digest. Never prompt mid-flow.
7. **Reversible & audited** — every machinery write and GC action is rollback-able
   (reuse `_axon_rollback`) and ledgered (reuse `auto-edits`).

## Tiers (precedence: program > project > general)
| Tier    | Lives in                                   | Loaded            |
|---------|--------------------------------------------|-------------------|
| General | `my-axon/memory/general/`                  | boot              |
| Project | `my-axon/dev-projects/<slug>/_memory/` (colocated) | `code-dev-load` |
| Program | `my-axon/memory/programs/<name>/`          | on recall         |

Colocation of project-local memory means a manual `rm` of a project folder self-cleans
its memory; only cross-tier *references* dangle (green mode reconciles those).

## Machinery & ops (the centralization principle)
- `RECALL(query[, tier])` → ranked entries from the one machinery.
- `REMEMBER(fact, {tier, bindings, privacy})` → gated write (dedup/supersede, provenance).
- The machinery OWNS: derivability gate · routing · privacy classification · dedup ·
  provenance · green-mode GC. Programs never touch memory files directly.
- Layering: **machinery executes, graph declares, audit reconciles.** The
  `memory-reads:`/`memory-writes:` synapse-block fields (auto-inferable from the ops,
  like W:/L: keys are today) are the graph-declaration skin — built in cluster-N, where
  `neuron-audit` verifies declaration-vs-behaviour.
- Existing precedent: `STORE`/`RETRIEVE` → `memory.py` already centralizes W:/L:; this
  extends the same pattern one level up with tier-aware knowledge ops.

## Recall
TF-IDF over a `memory-index.json` (reuse `dispatch.py`'s vectorizer) — pure-text, no
embeddings (AXON removed them in PR-142), harness-portable. A lazy referent-check runs
on every hit so a deleted-out-of-band entry never surfaces, even between GC sweeps.

## Capture  (trigger -> gate -> route -> dedup-write)
- **Triggers** (structural, not vibes): user correction · confirmation of a non-obvious
  choice · decision/ADR · FAIL-with-non-obvious-cause · repeated pattern · explicit "remember".
- **Gate**: reject anything re-derivable (invariant 2).
- **Route**: narrowest applicable tier; private by default.
- **Posture**: balanced + an `L:memory-capture` dial (conservative/balanced/aggressive),
  mirroring `L:inference-mode`. Safe classes auto-capture inline; fuzzy ones batch into
  the end-of-task digest.
- **Dedup**: recall-before-write; a new entry contradicting an old one SUPERSEDES it.

## Green mode (garbage collection)
- A **cron-tick program** (no `!BG`/idle trigger exists in AXON) + the lazy recall-check.
- Job = **reconcile index + cross-refs to disk**. Deterministic orphan (bound referent
  gone) → auto-quarantine (reversible tombstone via 3-version rollback). Semantic-stale
  (premise contradicted) → FLAG into the digest, never auto-delete.
- Respects manual `rm` of my-axon folders — it reconciles AXON's view, it never resurrects
  files the user removed. A dormant `project.deleted` exec-hook stays wired for an OPTIONAL
  future graceful-delete (irrelevant to the manual-rm path the on-disk check already covers).

## Reminders / to-dos
Private store, **date-based** (cron is recurring-only, so due-dates are surfaced at boot
+ menu, reusing the `cron check` overdue pattern). Items bindable to a project/program so
GC + completion stay consistent. Event-based reminders DEFERRED.

## Cross-harness
- **Claude Code** — surface a memory digest via the existing `axon-reminder.txt` hook.
- **Copilot** — a renderer writes a bounded memory section into `copilot-instructions.md`
  (respect the <=150-line budget + sanity test). One source -> generated baseline.
- **Floor** — `R_MEMORY_RESPECTED` adherence lint (warn->block via
  `L:memory-respected-required`), registered in `lint_summary`. Runs in CI = the
  cross-harness enforcement floor even where a model can't gate per-turn.

## Deferred -> cluster-N (neuron-contract conformance)
- `memory-reads:` / `memory-writes:` synapse fields + `neuron-audit` verification.
- Event-based reminders.

## Open design questions (honest — resolve at their PR, not blockers)
- **AM3 capture-trigger DETECTION**: no structured "this was a correction/confirmation"
  signal exists under Claude Code; it's end-of-turn agent judgment. Precision-critical
  (false captures = bloat). Needs a design spike first.
- **AM6 adherence (`R_MEMORY_RESPECTED`)**: "lint that memory was honored" is inherently
  fuzzy; likely heuristic/advisory rather than a hard gate. Scope at its turn.

# PR roadmap — AXON Memory

Each PR is self-contained + tested, hand off for merge (no self-merge grant for this
project unless the user extends one). [DESIGN-PASS] = needs a short design spike before build.

## AM1 — Memory tiers + store + load
- Goal: define the 3 tiers, the entry schema, the privacy roots; load GENERAL at boot,
  PROJECT on `code-dev-load`.
- Build: a memory-machinery module (new `tools/agent_memory.py`, or extend `memory.py`)
  with tier-aware read/write; entry frontmatter (`id · tier · bindings · source · date ·
  confidence · privacy`); my-axon paths (general, programs/<name>) + project `_memory/`;
  a boot step in KERNEL-SLIM (beside the my-axon load) for general; a `code-dev-load` hook
  for project memory.
- Tests: tier read/write roundtrip; privacy-root routing (private->my-axon); boot-load.

## AM2 — Memory index + recall
- Goal: cross-tier ranked recall.
- Build: `memory-index.json`; reuse `dispatch.py` TF-IDF over entries; a `RECALL(query[,tier])`
  op/program; lazy referent-check; index update on write.
- Tests: recall ranking; lazy-check skips dead refs; index rebuild/prune.

## AM3 — Capture pipeline   [DESIGN-PASS]
- Spike first: how to detect correction / confirmation / repeated-pattern with no
  structured signal — keep precision high, avoid false captures.
- Build: `REMEMBER(fact,{tier,bindings,privacy})`; derivability gate; routing (narrow +
  private default); recall-before-write dedup/supersede; `L:memory-capture` posture dial;
  end-of-task digest surface.
- Tests: gate rejects derivable; routing + precedence; dedup/supersede; dial modes.

## AM4 — Provenance + green-mode GC
- Goal: bindings + reconcile-to-disk garbage collection.
- Build: bindings in the entry schema; green-mode program (cron entry, interval/daily);
  on-disk referent check; deterministic orphan -> quarantine (reuse `_axon_rollback`);
  semantic-stale -> flag into digest; index prune; dormant `project.deleted` exec-hook;
  `auto-edits` ledger entries.
- Tests: orphan detection (remove a referent -> quarantined); index prune; semantic-stale
  is flagged not deleted; quarantine reversibility.

## AM5 — To-do + reminders   (parallels AM3/AM4; depends only on AM1)
- Build: private todo store; add/list/done ops; date-based due; boot-surface overdue +
  menu integration; bindable to project/program.
- Tests: due-date surfacing; binding; persistence + dedup.

## AM6 — Cross-harness enforcement   [DESIGN-PASS]
- Spike first: scope `R_MEMORY_RESPECTED` — what "memory honored" can mechanically mean.
- Build: Claude — memory digest into the `axon-reminder.txt` hook; Copilot — renderer
  (AXON memory -> bounded section in `copilot-instructions.md`, <=150-line budget, respect
  the sanity test); `R_MEMORY_RESPECTED` rule (warn->block via `L:memory-respected-required`),
  registered in `lint_summary.RULES_TO_SCAN`.
- Tests: renderer budget; rule warn/block paths; digest generation.

## Deferred -> cluster-N
- `memory-reads:` / `memory-writes:` synapse fields + `neuron-audit` verification.
- Event-based reminders.

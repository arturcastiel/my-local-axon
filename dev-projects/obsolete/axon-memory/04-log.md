# Implementation Log — AXON Memory

## SESSION START — 2026-05-24 (kickoff, plan-complete)
project:        axon-memory
phase:          2-plan
workflow-step:  plan
origin:         promoted from axon-ascent candidate _candidate-agent-memory.md

## Entries
- 2026-05-24 · project scaffolded (v4) · promoted from axon-ascent candidate
  · study + plan done IN-CONVERSATION (no separate study/plan phase needed)
  · harmonized spec authored after a 3-probe codebase grounding pass (memory/recall,
    events/cron/undo/lifecycle, cross-harness/rules/contract)
  · key grounding outcomes that shaped the plan:
    - green mode = cron-tick program, NOT an idle daemon (no !BG/idle trigger exists)
    - no code-dev delete exists (user: don't add one) -> green mode uses on-disk referent
      reconcile + lazy recall-check; manual `rm` is the real scenario
    - recall = TF-IDF (dispatch.py), no embeddings (removed PR-142)
    - privacy is already structural: my-axon (private) vs workspace (shareable)
    - copilot-instructions has NO generator yet -> AM6 builds the first renderer
  · decisions: single memory API (RECALL/REMEMBER); machinery executes + graph declares
    + audit reconciles; 3 tiers (program>project>general); balanced capture + L:memory-capture
    dial; deterministic-orphan auto-quarantine vs semantic-stale flag-only
  · 6-PR roadmap: AM1 tiers+load · AM2 index+recall · AM3 capture [design-pass] ·
    AM4 provenance+green-mode · AM5 todos/reminders · AM6 cross-harness [design-pass]
  · deferred -> cluster-N: memory-reads/writes synapse fields + neuron-audit; event reminders
  · NEXT: build AM1 (tiers + load)
- 2026-05-24 · AUTONOMOUS RUN — AM1/AM2/AM4/AM5 MERGED; PARKED at AM3
  · AM1 #89 — tools/agent_memory.py tier machinery (general/project/program) + REGISTRY 'agent-memory'
    + entry schema (id/tier/scope-ref/bindings/source/date/confidence/privacy/supersedes); private-default-to-my-axon guard
  · AM2 #90 — recall(query,tier?) TF-IDF (reuses dispatch.py pure-text primitive) + lazy referent-check (orphans never surface)
  · AM4 #91 — green-mode gc(): deterministic orphan -> reversible quarantine (.quarantine/ + manifest), DEFAULT-OFF (L:memory-gc-enabled); respects manual rm
  · AM5 #92 — tools/agent_todo.py private date-based todos + `due` reminder query; REGISTRY 'todo'
  · all self-merged on CI green (non-kernel); 12 agent-memory tests + 5 todo tests
  · PARKED — AM3 (capture) needs a DESIGN-PASS from the user before build:
    HOW to detect correction / confirmation / repeated-pattern with no structured signal
    (precision-critical — false captures = bloat). Bring options: end-of-turn self-classify + batch digest; explicit-only vs balanced posture dial (L:memory-capture).
  · ALSO HELD for user (kernel/compiled-touching, batched): load-wiring = boot general-load (KERNEL-SLIM)
    + code-dev-load project-load + green-mode cron registration + todo boot-surface. Plus AM6 (cross-harness — the other design-pass).
  · keep-awake stopped at this park.
- 2026-05-24 · AM3 MERGED (#93); RE-PARKED at AM6
  · user picked HYBRID capture posture; built + self-merged
  · AM3 #93 — capture(body,source): deterministic (explicit/fail/decision) writes inline w/
    recall-before-write dedup/supersede; judgment (correction/confirmation/pattern) STAGES to
    digest (digest list/keep/drop) — user prunes, never auto-written. is_capturable() light gate.
  · axon-memory now: machinery + recall + green-mode(off) + todos + capture/digest — all merged
    + tested (17 agent-memory + 5 todo)
  · RE-PARKED — needs user at TWO points:
    1. AM6 (cross-harness) — DESIGN-PASS: scope R_MEMORY_RESPECTED ("memory honored" check) +
       the Copilot rendering approach (memory digest -> copilot-instructions, <=150-line budget).
    2. load-wiring (kernel/compiled, held for MERGE): boot general-load + code-dev-load project-load
       + green-mode cron + todo/digest boot-surface + per-turn capture nudge (Claude Stop hook).
  · keep-awake stopped.
- 2026-05-24 · WAVE COMPLETE — AM6 merged, load-wiring built + HELD for user merge
  · (side-quest) autonomous-mode PR #94 MERGED (user-directed): KERNEL-SLIM carve-out +
    tools/autonomous_mode.py grant (scoped/audited/revocable; deny-lists kernel+destructive).
    User then activated the grant for arturcastiel/axon -> AM6 self-merged under it (grant-checked).
  · AM6 #95 — tools/memory_sync.py (digest=PRIVATE general for Claude hook; copilot=SHAREABLE-only,
    private NEVER ships) + R_MEMORY_RESPECTED lint (single-API principle; 8th lint-pack rule).
  · load-wiring #96 (HELD, kernel) — boot general-load step (TOOL agent-memory load --tier general)
    inserted after my-axon load, before harness detection. CI GREEN. Grant correctly denies
    kernel-change -> awaits USER merge (the one remaining action).
  · STATUS: all 6 AM PRs merged — memory subsystem fully built + tested. Only #96 awaits user merge.
  · Deferred follow-ups (not built): code-dev-load project-load, green-mode cron registration,
    todo/digest boot-surface, Claude Stop-hook per-turn capture nudge.
  · keep-awake stopped.

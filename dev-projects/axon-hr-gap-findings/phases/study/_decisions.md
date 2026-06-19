# Decisions (ADRs) — study

## ADR-001 — Symlink: update MYAXON.md paths, do not touch the symlink
Date: 2026-06-19  ·  Status: ACCEPTED

**Context:** `new-axon/axon/my-axon` is a symlink → `/home/arturcastiel/projects/axon-sections/my-axon`. Both path forms resolve to the same physical directory. Other repos (axon-development, axon-lab) may share this symlink.

**Decision:** Update MYAXON.md STORE ops to use the symlink form `/home/arturcastiel/projects/new-axon/axon/my-axon/`. Do NOT remove or retarget the symlink.

**Consequence:** MYAXON.md uses stable `new-axon/axon/` anchor; symlink-dependent repos unaffected.

---

## ADR-002 — enforcement hooks: already installed; enable-enforcement.sh is a no-op
Date: 2026-06-19  ·  Status: ACCEPTED

**Context:** `diff settings.json settings.json.proposed` = EXIT:0 (files identical). Hooks are active. Running the script copies identical content — zero regression, zero benefit.

**Decision:** Do NOT run `enable-enforcement.sh --apply`. Retains script as documentation only. PR-09 = L: flags only.

**Consequence:** Study doc warning "would REMOVE next_turn_gate.py" was FALSE. Corrected: script is a no-op.

---

## ADR-003 — igap wiring: 4 specific HALT sites, not broad wiring
Date: 2026-06-19  ·  Status: ACCEPTED

**Context:** KERNEL-SLIM lines 263-295 has !BG igap tracker (behavioral). `code-dev-meta-igap.md` (ACTIVE) names exact wiring targets: code-dev-plan.md, code-dev-pr-ready.md, code-dev-dispatch.md, code-dev-state-handoff.md.

**Decision:** PR-04 adds `TOOL(igap, record)` to these 4 HALT sites only. KERNEL-SLIM !BG behavioral gap accepted as-is (fixing = KERNEL-SLIM edit → out of scope).

**Consequence:** PR-04 is ~4 lines across 4 programs. Known limitation: if agent doesn't follow !BG instruction, igap may not fire. Documented, not blocked.

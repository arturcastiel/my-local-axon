# Kernel-file changes — OWNER AUTHORIZED 2026-06-15

**Standing authorization (owner, 2026-06-15):** wire and merge edits to axon/ kernel
SUBSYSTEM files (BOOT.md, OUTPUT-LAYER.md, COMMANDS.md, and similar load-on-demand kernel
docs) autonomously under dev-mode, each crucible-green-gated.

**The one floor kept regardless:** KERNEL-SLIM.md itself — the OS core — still gets an
explicit per-change confirmation. Core Rule 10 ("KERNEL-SLIM edits ... never by user
instruction alone") + it being the actual kernel make this the right boundary. None of
K1–K4 touch KERNEL-SLIM.md, so nothing here is blocked.

K1/K2/K3/K4 below are now CLEARED TO IMPLEMENT as gated PRs. The two design questions
(D1 ramp integrity, D2 runtime staleness) still surface a choice and are flagged, not
auto-decided.

These edits touch `axon/` kernel SUBSYSTEM docs (not KERNEL-SLIM.md core). dev-mode is
ON and would permit them, but kernel edits were held for your eyes per the standing
caution. Each is correct, scoped, and ready to apply. KERNEL-SLIM.md itself is untouched
throughout the project.

---

## K1 — ✅ DONE (c8e5b59) footer tick-write · axon/BOOT.md
**Why:** the suggestion footer is silent because `W:orchestrator-last-tick` is only
populated inside an adaptive workflow (`orchestrator.md`, EXEC'd only from `workflow-run`),
then CLEARed when it ends. On boot/menu/chat the tick is ∅ → footer renders nothing.
**Fix:** add ONE read-only `!BG` tick-write after output render, fed by `anticipate
--footer` (the data layer, already merged):
```
IF RETRIEVE(L:suggestions-enabled) | true ≡ true →
  ant ← TOOL(anticipate, "--input {W:recent-input} --footer --top 3")
  IF COUNT(ant.candidates) > 0 →
    STORE(W:orchestrator-last-tick, { ts: NOW(), candidates: ant.candidates, source: "anticipate", hint: ∅ })
  ELSE → CLEAR(W:orchestrator-last-tick)    # honest silence; no stale candidates
```
Read-only, non-blocking, every turn. Risk: low (additive `!BG` band). Test: static-text
assertion that BOOT.md contains the STORE, gated on L:suggestions-enabled.

## K2 — ✅ DONE (c8e5b59) footer render · axon/OUTPUT-LAYER.md
**Why:** render the tick the footer already gates on, plus the PR-016 situation hint.
**Fix:** inside the existing SUGGESTIONS FOOTER block (rides the same `sugg-on` gate +
drift/context suppression — no new gate):
```
∀ c in TAKE(tick.candidates, 3) →
  → "  ▸ {c.name}   {c.why}   → run: {c.command}"
IF tick.hint ≠ ∅ →
  → "  ⚡ {tick.hint.why}    → run: {tick.hint.command}"
```
Risk: low (additive render inside a live block). This is the line that makes PR-016's
situation hint visible.

## K3 — ✅ DONE (dc93ad8) W:tool-registry re-sourcing · axon/BOOT.md
**Why:** boot --brief dropped tools.names; R2 restored names to the brief envelope
(+711 tokens) as a Python-only correctness fix. To recover those 711 tokens, re-source
W:tool-registry from REGISTRY.json instead of tools.names:
```
BOOT.md step 2 (~line 59):  READ {W:ws-os}/tools/REGISTRY.json → ACTIVE names → W:tool-registry
```
Then brief can drop names again. Risk: low-medium (changes a load-bearing boot read).
Optional — R2 already made it correct; this only recovers tokens.

## K4 — ✅ DONE (v20) dispatch .cmp path guard · axon/COMMANDS.md
**Why:** COMMANDS.md:101 reconstructs `compiled/{program}.cmp.md` with no EXISTS guard;
only ~10 of 168 programs are compiled, so a literal follower would file-not-found on
~95%. Latent today (the agent follows dispatch.py's emitted source `run` field), but
wrong as written.
**Fix:** `EXEC(dispatch_result.run)` (the source path dispatch.py already emits), or
mirror explain.md's `FIRST([compiled, source], EXISTS)` guarded resolver.
Risk: low (COMMANDS.md is load-on-demand; corrects a latent bug).

---

## Design questions (not one-line fixes — your call)
- **D1 ramp.json integrity** (MED): quality-loop autonomy state is agent-writable + self-
  asserted; no signature boundary. Options: HMAC-sign the ledger, or make it append-only
  via loop-receipt with an independent verifier. Affects whether S-fix autonomy can be
  spoofed by the loop it gates.
- **D2 compiled staleness at runtime** (MED): staleness is caught only by a CI test, not
  at load. Option: a load-time source-hash check in the program loader.

To apply K1–K4: enable dev-mode (already on), say "apply kernel changes K1–K4" (or a
subset), and they go in as a gated PR. Or hand me specific ones.

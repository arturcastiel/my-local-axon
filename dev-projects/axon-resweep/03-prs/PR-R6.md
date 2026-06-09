# PR-R6 — Kernel batch: inference-mode footer default (K1) + deferrals

- **Status:** spec
- **Phase:** 1-fixes  ·  **Complexity:** S  ·  **dev-mode:** YES (axon/OUTPUT-LAYER.md) — enabled scoped to the one edit, restored off  ·  **Depends on:** none

## Done — K1 (the clear, high-value one)
`axon/OUTPUT-LAYER.md:23` `RETRIEVE(L:inference-mode) | 5` → `| 3`. The footer fell back to 5 ("balanced")
when `L:inference-mode` is unset, but the gate + `boot.py:read_pref_inference` default to **3** ("cautious",
OBJECTIVE "Default: 3"), so the footer misreported the live mode. (docgen already emits default 3, so the
generated workspace/AXON-DOCS are correct — no doc edit needed.) dev-mode was enabled only for this axon/
write and restored off immediately (verified via `enforce.py check-write`). Content-lock test added.

## Deferred (documented follow-ups — NOT rushed into the kernel at the tail of this run)
- **K-L1 (LOW) — boot output_mode key:** `boot.py:324` reads `output-config`, but investigation shows
  NOTHING writes `output-config` OR `output-mode` (no writer anywhere). So there's no "correct key" to fix
  toward — the real question is whether output-mode should be persistable at all (and OUTPUT.md
  self-contradicts l.88 vs l.99). Needs a design decision, not a guessed key-swap. Today it harmlessly
  defaults to PYTHON_FAST.
- **K2 (MED, latent) — reasoning-trace freshness:** R_REASONING_TRACE accepts a stale trace (no freshness
  check). The fix requires turn-stamping the LLM-written `W:reasoning-trace` + a freshness check in the rule
  — a change to the LLM-interpreted trace convention + the Stop hook. Latent (WARN until the flag is set).
  Warrants focused design.
- **K3 (MED) — active-phase boot-expiry:** an orphaned `W:active-phase` never expires (LIVE: it currently
  holds the finished `axon-workflow-discipline:3-pr`, arming R_STATE_SURFACED). The safe fix (boot-time
  staleness check) touches boot/session/interrupt-gate; the simple "exclude from snapshot" risks losing
  legitimate phase state on resume. Needs careful resume-behaviour analysis. (Live symptom is a stale
  gitignored state file, clearable any time; the code gap is the real follow-up.)

These three → a focused **phase 2** (kernel/state hardening) or their own project. Closing R6 on K1 keeps the
sensitive kernel changes out of a rushed bundle (the thesis: don't ship unverified changes to the core).

## Acceptance
1. OUTPUT-LAYER inf-mode default is 3 (content-lock test); docs already 3 via docgen.
2. dev-mode restored off after the edit. `crucible gate` passed:true.

## Changes
- `axon/OUTPUT-LAYER.md` (K1, dev-mode) · `tests/test_resweep_program_subcommands.py` (K1 lock).

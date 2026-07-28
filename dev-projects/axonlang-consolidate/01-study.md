# Study — axonlang-consolidate (PIVOTED to lead-fixes)
date: 2026-07-14 · phase: study COMPLETE · codebase: /home/arturcastiel/projects/new-axon/axon

## CHARTER (pivoted)
The scaffold's original R1 (parser consolidation) was judged NOT NECESSARY — the parser divergence
hides zero real bugs today (measured: 0 phantom E: reads). The real work is the R4 verification: 4
quarantined run-3 leads deep-searched (4 parallel read-only agents, adversarial reconfirm vs source +
live probe) → 3 CONFIRMED bugs + 2 PARTIAL + 1 doc-defect. Full evidence: ../../VERIFY-FINDINGS.md.

## CONFIRMED LEDGER (the fix targets)
- **B1 (HIGH-consequence) agent_memory _read_gate on gc's DESTRUCTIVE path** — hand-rolled divergent L:
  parser (scans every line for `value:`) reintroduces the exact hazard _longterm.py documents; guards gc's
  os.replace delete. Fix: use the canonical _longterm reader. agent_memory.py:286-298, :326.
- **B2 (MED, latent) agent_memory binding-liveness** — checks only workspace/programs/, so a program:
  binding to a core (axon/programs/) or private (my-axon/programs/) program = false orphan → silent recall
  exclusion (always-on) + gc quarantine. Fix: check the other program roots. agent_memory.py:189.
- **B3 (MED, reproduced) hr-team persistence + events** — tier decision discarded at the write point
  (hr-team.md:40 default wins; router :171 omits sel.persistence); events.jsonl always 0-byte (--events
  never passed; emitted events never collected). Fix: resolve persistence post-selector + wire --events.
- **B4 (MED, latent) hr_team cwd relative-path defaults** — catalog/prompts/ledger defaults are relative
  literals violating _axon_paths; _parse_catalog raises (not fail-closed) off-root. Fix: _axon_paths them +
  fail-closed parse. tools/hr_team.py:331,325,421,572,604 + _parse_catalog.
- **B5 (LOW) REGISTRY descriptive drift** — purpose/args omit real subcommands, ungated. Fix: WARN check in
  registry_drift (reuse the --help probe) + correct the 4 strings.
- **B6 (LOW) agent_memory stale 'episodic' comment** — recall() :249-250 describes non-existent wiring. Fix: correct it.

## FIX ORDER (yield-per-effort): B1 → B2 → B3 → B4 → B5 → B6. All non-kernel, autonomous envelope.
## NEXT: code-dev plan (waves) → build.

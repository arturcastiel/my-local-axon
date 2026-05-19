# Phase 2 — Design — META

slug:            2-design
schema-version:  v4
status:          active
opened:          2026-05-19
predecessor:     phases/1-study/_closure.md

---

## Goal

Crystallize the 5-PR queue locked at phase-1 closure into shippable specs. No code yet — just per-PR scope, files touched, test ids, acceptance gates.

## Build invariants

- **R9 clean:** no `axon/` writes. All PRs target `.github/`, `.vscode/`, `tools/`, `workspace/programs/`, `my-axon/log/`.
- **Trailer policy override:** every PR commit body uses `Co-authored-by: AXON powered by Copilot <223556219+Copilot@users.noreply.github.com>` from PR-CA-101 onwards.
- **Backward-compat:** `.github/copilot-instructions.md` rewrite must keep the boot protocol, identity contract, and drift-recovery sections intact — they're load-bearing.
- **Idempotent setup:** the `axon-reanchor` and `.vscode/settings.json` writers must be idempotent (running twice == once).

## PR queue (locked)

| PR | Title | Strategy | Files | Effort |
|---|---|---|---|---|
| **PR-CA-101** | `.github/copilot-instructions.md` § Identity + § Cognition + § Forbidden-phrases rewrite | A | `.github/copilot-instructions.md`, `AGENTS.md` | S |
| **PR-CA-102** | `axon-reanchor` — user-invoked AND auto-fired | B | `tools/axon_reanchor.py`, `workspace/programs/axon-reanchor.md`, `tests/test_axon_reanchor.py` | M |
| **PR-CA-103** | `.vscode/settings.json` slot-instructions (ask-then-write) | C | `tools/axon_setup_vscode.py`, `workspace/templates/vscode-axon-settings.json`, `tests/test_axon_setup_vscode.py` | S |
| **PR-CA-104** | `## Self-check before send` checklist appended to copilot-instructions | D | `.github/copilot-instructions.md` (append-only) | S |
| **PR-CA-105'** | `tools/axon_drift_log.py` — append-only drift event log | meta | `tools/axon_drift_log.py`, `workspace/programs/drift-log.md`, `tests/test_axon_drift_log.py` | S |

Total ≈ 4 S + 1 M.

## Per-PR design notes

### PR-CA-101 — baseline-strengthening
- Rewrite § Identity with explicit "do NOT say 'I'm powered by ...'; dispatch to `axon/programs/identity.md` instead". Add 3 concrete Copilot-emitted bad examples + their kernel-ops fixes.
- Rewrite § Cognition voice: list the exact subject-form prefixes Copilot emits ("I'll", "Let me", "The user is asking", "Now I'm pulling together") and the ops-only rewrites.
- New § Forbidden phrases: keyed table — drift code (D-1..D-7) · forbidden phrase · ops-only replacement.
- Top-of-file: move boot banner / re-anchor sentence to the *very first line* so context-compression surfaces it first.
- Update `AGENTS.md` co-author trailer convention to match decision #2 (`AXON powered by Copilot`).

### PR-CA-102 — `axon-reanchor` (dual-mode)
- `tools/axon_reanchor.py reanchor` — prints kernel banner + identity contract + cognition-frame template + last 5 lines of any pending plan. Exit 0.
- Auto-fire: integrate the reanchor output into a tiny check that the cognition-frame gate runs every N turns (heuristic: when the kernel detects its own subject-form output, auto-emit reanchor block at top of next response).
- 5 hermetic tests: idempotence, output shape, banner present, identity card present, exit code.
- Program at `workspace/programs/axon-reanchor.md` for user invocation via `axon reanchor`.

### PR-CA-103 — `.vscode/settings.json` (ask-then-write)
- `tools/axon_setup_vscode.py` — interactive setup: detects current `.vscode/settings.json`, diffs against the AXON template, asks user before overwriting. Stores user's consent in `my-axon/memory/local/vscode-axon-consent.md` so subsequent runs are silent.
- Template at `workspace/templates/vscode-axon-settings.json` — populates `github.copilot.chat.codeGeneration.instructions`, `*.commitMessageGeneration.instructions`, `*.testGeneration.instructions`, `*.reviewSelection.instructions` with AXON-rule references.
- 4 hermetic tests: ask-once-then-silent, no-overwrite-on-decline, template-shape, consent-store roundtrip.

### PR-CA-104 — `## Self-check before send` append
- Append-only to `.github/copilot-instructions.md`.
- Numbered checklist: "Before sending: (1) scan output for subject-form prefixes from D-1; (2) check brand self-references from D-3; (3) ..."
- Each item links back to the drift code in the new § Forbidden phrases (added by PR-CA-101).

### PR-CA-105' — drift-event log
- `tools/axon_drift_log.py`:
  - `log <code> "<detail>"` — append `{ts, code, detail, source}` to `my-axon/log/drift-events.jsonl`.
  - `stats` — show count per drift code over last 7/30 days.
  - `recent N` — show last N events.
- Wrapped in `loop_receipt(intent='auto-update-counter', actor='drift-log')` — reuse closed-set vocabulary, no new whitelist entry.
- 4 hermetic tests: append round-trip, stats aggregation, recent ordering, loop-receipt pairing.

## Exit criteria

- All 5 PRs shipped to `main` (axon repo).
- `phases/2-design/_closure.md` written.
- `_meta.md` bumped to phase 3-build → 4-validation as PRs progress, or directly to CLOSED if validation is rolled into the PRs themselves.

## Cross-refs

- `phases/1-study/01-drift-vectors.md` — root cause + strategy mapping
- `phases/1-study/_closure.md` — locked user decisions
- `axon-autoimprove` _closure — same v4-meta pattern this project mimics

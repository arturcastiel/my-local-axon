# Phase: study
schema-version: v4
status:         active
workflow-step:  build
branch:         main
current-pr:     (none)
created:        2026-06-19

## Working Context
- Pre-seeded: 01-study.md carries gap analysis from hr-team inception doc
- Study goal: for each of 8 gaps, read the relevant source files and deepen
  understanding before writing the plan
- Study targets per gap:
    GAP 1 (drift)        → tools/drift.py · axon/BOOT.md
    GAP 2 (enforcement)  → scripts/enable-enforcement.sh · tools/enforce.py · tools/verify.py
    GAP 3 (observability)→ tools/phase_ledger.py · tools/source_log.py (if exists) · tools/igap.py
    GAP 4 (coverage)     → tools/coverage_gate.py · tools/usage.py · workspace/programs/menu.md
    GAP 5 (my-axon)      → my-axon/MYAXON.md · axon/BOOT.md (path detection block)
    GAP 6 (health display)→ workspace/programs/menu.md (health render block)
    GAP 7 (orchestrator) → tools/synapse_suggest.py · axon/BOOT.md (step 3)
    GAP 8 (self-care)    → tools/cron.py · workspace/programs/self-care.md

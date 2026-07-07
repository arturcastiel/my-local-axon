# Study — AXON Bugfix 02
Updated: 2026-07-07  ·  Iterations: 1 (fan-out round)  ·  AXON: 9/10  ·  User: pending

## Goal
Audit the surfaces axon-bugfix01 explicitly declared NEVER-audited (its residual-gap list) and give
every one a VERIFIED verdict — finding, clean, or could-not-verify — with evidence, severity-ranked for
the plan phase. Read-only phase: no fixes applied.

## Scope (bugfix01's residual list, all covered)
Dashboards: menu · status · stats · gain. Session lifecycle: session-summary · resume · workspace-backup ·
my-axon-init. Discovery/meta: find-program · list-tools · undo · axon-docs-gen · auto-actions. Tool-only:
todo · board · loop-contract · constraints · dispatch-stats · auto_audit.

## Method
4 parallel read-only agents, one per cluster, each held to the bar: every finding VERIFIED against source
AND (where non-mutating) a LIVE run — never inferred from naming. Every TOOL() call diffed against the real
argparse; every `.field` read confirmed against the tool's real JSON; every RETRIEVE(W|L:) sanity-checked
for a writer. All 4 CRITICALs then adversarially re-verified from scratch (4/4 reconfirmed). No silent
caps — clean and could-not-verify are enumerated alongside findings.

## Result
~69 findings: 4 CRITICAL, ~18 HIGH, ~22 MEDIUM, ~25 LOW. See AUDIT-FINDINGS.md.

The dominant discovery is a single defect CLASS, not scattered bugs: the **dashboard + session-reporting
layer is pervasively wired to memory keys and tool-output fields no writer produces**. menu/status/stats/
gain silently report zeros or dead panels; session-summary and resume early-exit or detect nothing, every
run. Because these surfaces only READ, nothing ever fails loudly — the OS's self-report is quietly fiction.
This is the same reader/writer-contract class as bugfix01's C9/C12, concentrated in exactly the surfaces the
first audit skipped. A second recurring class: false success after a gate-blocked git op (workspace-backup),
bugfix01's H25 recurring and worsened by the destructive-git gate bugfix01 itself added.

## Key Concepts (for plan-phase codebase mapping)
- The reporting contract: `RETRIEVE(W|L:key)` ↔ its writer; `TOOL().field` ↔ the tool's output schema.
- axon-state menu-snapshot as the golden path (several bugs bite ONLY on the snapshot path, not the fallback).
- The destructive-git gate (bugfix01 PR-001) now interacting with substring-based success checks.
- Orphaned duplicate tools (workspace/tools/drift.py) writing where the registry doesn't point.

## Tech Stack
Same as bugfix01: markdown neuron programs interpreted by an LLM agent, backed by Python CLI tools (tools/*.py
via axon.py) and JSON/JSONL/markdown state. The reporting layer reads that state; the audit's evidence is
live tool runs + on-disk state inspection.

## Constraints
- Read-only study (project dont-do seed + owner verify-then-plan preference).
- LLM-interpreter leniency is a real confound: some shape mismatches may partially self-heal at render time.
  Severities assume the contract-as-written (the audit bar); could-not-verify calls this out explicitly.

## Priorities for the plan
1. The reporting-contract class (a lint + the concrete menu/status/stats/gain/session/resume fixes) —
   highest leverage, one root cause behind most CRITICAL/HIGH findings.
2. board (CRITICAL, self-contained 3-layer fix or honest descope).
3. workspace-backup false-success + skip-unreachable (safety-adjacent — false "restored/ok").
4. my-axon-init data-loss re-run paths (destructive).
5. The metric-pipeline starvation (dispatch-stats/loop-contract receipts) — decide wire-vs-descope.
6. MEDIUM/LOW sweep + the could-not-verify items that a plan can convert to verified by running mutating paths.

## Self-assessment (grade rationale)
AXON: 9/10. Complete verified coverage of every residual surface (the goal's acceptance); evidence-dense,
runtime-checked, severity-ranked; 4/4 CRITICALs adversarially reconfirmed; a genuine cross-cutting root
cause identified with a mechanical guard proposed; honest could-not-verify list. Held below 10 by the one
deliberate limitation: mutating subcommands were assessed from source, not driven end-to-end (read-only
phase) — a documented boundary, not a coverage gap.

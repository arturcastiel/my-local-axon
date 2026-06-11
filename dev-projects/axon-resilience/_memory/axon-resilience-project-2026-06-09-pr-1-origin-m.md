---
id: axon-resilience-project-2026-06-09-pr-1-origin-m
tier: project
scope-ref: axon-resilience
bindings: axon-resilience
source: decision
date: 2026-06-09
confidence: high
privacy: private
supersedes: 
---
axon-resilience project (2026-06-09): PR-1 (origin/main f99f5f8/f337a99, MR !150) hardened the cron contract — A1 dispatch-stats weekly->summary, A2 freshness.py +--workspace on top parser threaded through programs_registry calls, + tools/cron_conformance.py BLOCK gate. PR-2 (origin/main b55c85f, MR !151) added tools/self_care.py + workspace/programs/self-care.md (composes health/freshness/cron/drift/igap + persistence self-check), startup.md probe-glob, harness reanchor-verifier note. Gate-feedback lints that bit: F21 (no per-file sys.path.insert — use script-mode), F22 (no REGISTRY.json literal outside _axon_registry), F58 (CONTEXT.md tool count), R_NO_ORPHAN_TOOLS (a new ACTIVE tool must be invoked by a program, not just tested -> needed the program wrapper). Kernel handoff: 99-kernel-spec.md (signature-gated Stop hook + compaction-boundary auto-reanchor + optional fail-closed boot).

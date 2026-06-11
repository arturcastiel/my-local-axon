---
id: cron-tool-workspace-contract-2026-06-09-tools-cr
tier: general
scope-ref: 
bindings: project:axon-resilience,cron,contract
source: decision
date: 2026-06-09
confidence: high
privacy: private
supersedes: 
---
CRON↔TOOL --workspace CONTRACT (2026-06-09): tools/cron.py injects --workspace into EVERY cron job (leading placement, with a trailing retry only for multi-token jobs). So any tool a cron job invokes MUST (a) have the named subcommand and (b) accept --workspace in some placement the runner uses; a single-token job whose tool lacks top-parser --workspace is unrescuable. Two jobs failed silently for weeks (axon-dispatch-stats used a non-existent 'weekly' subcommand; freshness.py accepted --workspace nowhere) and only surfaced near a breaker trip. tools/cron_conformance.py now proves every job conforms (reuses cron._build_job_cmd, probes with --help, side-effect-free) and is a BLOCK control in the crucible gate, so this whole bug-class is caught at merge. When adding a cron-invoked tool, put --workspace on its TOP parser.

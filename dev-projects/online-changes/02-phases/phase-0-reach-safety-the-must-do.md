# Phase 0 — Reach & Safety (the must-do)

**Goal:** Land the retrieval-eval/rag-maturity-audit foundation on main and make it reachable from every MCP client and discoverable in the registry — while closing a live remote-write hole — without claiming any new maturity capability.

- Score after: 40/70 (unchanged by intent — reach & safety, not capability)
- Reach after: local-shell → every MCP client (read-only-guarded) + self-describing in list-tools/menu
- Exit gate: `python3 tools/crucible.py gate` exit 0 (CI command at .github/workflows/ci.yml:127). Foundation on main; both tools callable over MCP read-only-guarded; write hole closed; registry self-describing. NO new audit points claimed.

## PRs in this phase
- PR-0: merge staged origin/aoxn-rag (HEAD 55ab5dd) into main; one authored edit — CONTEXT.md '151 tools'→'153 tools' at lines 70 and 107 (verified live len(REGISTRY.tools)==153); accept the staged REGISTRY/metrics_manifest union; lock = test_context_tool_count_matches_live_registry RED→GREEN + test_workflows_doc_catalogues_rag_master_plan green
- PR-1: in tools/mcp_server.py add 'retrieval-eval'/'rag-maturity-audit' to SAFE_TOOLS, pin READONLY_SUBCOMMANDS evaluate/audit, AND in the SAME commit append '--append-log' and '--root' to _FORBIDDEN_FLAG_TOKENS (verified today BOTH pass _is_readonly_call — a remote client could mkdir+append under my-axon/ or retarget the scan); lock = two refusal tests proving subprocess.run never fires
- PR-2: list-tools.md:45 render fallback {purposes[t.name] | t.purpose} (≈142 of 153 tools currently render blank purpose), recompile the .cmp mirror, add two quiet menu SELF-OBSERVE doc lines; lock = a dict-miss resolves to a real registry purpose, band-scoped menu assertion
> Parent plan: [02-plan.md](../02-plan.md)

# Q&A Log — axon
> Grounded in graph + shadow. Append-only.

## 2026-07-10T17:37:29.129585Z
**Q:** what is axon?

**Answer** — AXON is an **operating system for AI agents**: a kernel-governed layer that
sits above whatever host harness (Claude Code, Copilot) and model are running, and drives
behaviour by *executing programs, enforcing rules, protecting memory, surfacing state, and
failing loudly* (KERNEL-SLIM OBJECTIVE). Its outward framing (README) is narrower and product-
shaped: **"the conformance layer for AI agents — git + CI for your agent's constitution"** —
keeping sprawling multi-host, multi-model instruction files provably coherent, drift-checked,
and portable. Both are the same system seen from two sides: the KERNEL is the architecture, the
README is the positioning.

**How it connects** — the graph bears this out structurally: the three dominant subsystems are
`workspace/programs` (6,474 nodes — the *programs* it executes), `tools` (3,733 nodes, the most
cross-linked module — the *engine* enforcing the rules), and `tests` (5,933 nodes — testing is
mandatory). The load-bearing hubs are exactly the OS spine: `REGISTRY.json` (the tool registry),
`tools/rules/registry.py:Violation` (the rule engine), `_axon_paths.py:default_workspace()` (path
resolution), and `program_hash_manifest.json` (integrity). `startup.md → KERNEL-SLIM` is the boot
chain that loads identity, memory scopes, and compliance gates.

**Files involved** — `README.md`, `axon/KERNEL-SLIM.md` (IDENTITY + OBJECTIVE), `startup.md`,
`tools/REGISTRY.json`, `tools/rules/registry.py`, `tools/_axon_paths.py`.

**Confidence & gaps** — HIGH on identity/objective and structure (definitional files + graph
agree). GAP: shadow index is empty, so this rests on the graph + a direct read of the canonical
docs, not per-file shadow findings. Run `codemap shadow scan` for claims grounded in every file.

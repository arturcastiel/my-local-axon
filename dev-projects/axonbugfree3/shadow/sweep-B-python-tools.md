# Sweep B — Python tools diff audit (raw agent return, 2026-07-13)
method: read-only verify-against-source over `git diff 2e34e04~1..HEAD -- tools/*.py` (55 files);
bugfix01/02 ledgers excluded; probes quoted verbatim. Pending: adversarial reconfirmation (main loop).

---

**B-1 | HIGH | `graphify_bridge.impact()` reads the wrong key — file-level impact is always empty (and its one dashboard caller crashes)**
- code: `tools/graphify_bridge.py:410` and `:415` — `impact()` iterates `for nid in fn.get("nodes", [])` and returns `"seed_nodes": fn.get("nodes", [])`.
- counterparty: `tools/graphify_bridge.py:252` — `file_nodes()` returns `{... "node_ids": ids ...}`, never a `nodes` key (its sibling consumer `pr_edges` at `:273` correctly reads `.get("node_ids")`). So `fn.get("nodes")` is always `[]` → `impact()` always yields `count: 0`, empty `impacted`/`impacted_files`, even on a valid graph.
- second counterparty: `workspace/programs/codemap-relations.md:74` invokes `TOOL(graphify-bridge, query, "impact --graph … --symbol {top.label}")`, but the `impact` query branch reads `kw["file"]` (`tools/graphify_bridge.py:436`) — passing `--symbol` and no `--file` raises `KeyError: 'file'`, so the tool crashes and the program masks it with `| ∅`. Either way the "impact" panel is silently always empty.
- probe:
  ```
  file_nodes a.py: {'ok': True, ..., 'node_ids': ['modA:foo'], 'count': 1}
  affected modA:foo: {..., 'affected': ['modB:bar'], 'count': 1}
  IMPACT a.py: {'ok': True, 'file': 'a.py', 'seed_nodes': [], 'impacted': [], 'count': 0, 'impacted_files': []}
  # query impact --symbol "foo()"  → Traceback … KeyError: 'file'
  ```
- impact: The file-blast-radius query (advertised in codemap-relations and `code-dev-graphify.md`) reports "nothing impacted" for every file, hiding real downstream callers.
- confidence: CONFIRMED (source + probe).

---

**B-2 | HIGH | doctrine routine preflight integrity gate fails OPEN on unblessed / uncovered routines**
- code: `tools/doctrine_preflight.py:129` — `checks["integrity"] = {"ok": routine_rel not in intg.get("tampered", []), …}`. `ok` is true whenever the routine is not in the `tampered` list; the `unblessed` list is only used for a cosmetic `note`.
- counterparty: `tools/program_integrity.py:90` — the manifest's own policy is `ok = not tampered and not missing and not unblessed`, with the comment (`:86-89`) "an UNBLESSED power-file is a FAILURE … Attackers ADD a poisoned program/routine; they don't edit a blessed one." The preflight docstring (`:14-18`) likewise promises "the routine file's hash is blessed … so a poisoned routine cannot be validated." The code checks the opposite condition.
- probe (integrity-check logic replayed against a report where the routine is unblessed / uncovered):
  ```
  preflight integrity for an UNBLESSED (freshly-injected) routine => {'ok': True, 'note': 'unblessed (bless before binding)'}
  program_integrity.run_check would say ok => False
  preflight integrity for an UNCOVERED routine    => {'ok': True, 'note': 'blessed'}   # falsely labelled blessed
  ```
- impact: Since `validated = all(c.ok)` (`:133`), a never-reviewed (injected) routine dropped into `routines/` can reach `validated: True` and be armed — exactly the injection the hash manifest exists to stop. (Mitigated only indirectly: the normal `doctrine_propose.write` path blesses, and arming needs 3 clean runs — but the gate itself is open.)
- confidence: CONFIRMED (source + logic probe).

---

**B-3 | MEDIUM | S7b doctrine-node gate leaves a permanent, self-unrecoverable workspace write-block after a handoff**
- code: `tools/shell.py:455-463` (`_enforce_doctrine_node`) blocks every write/delete when a current-node record exists and its `op_class != "write"`; the block message gives no recovery hint.
- counterparty: `tools/doctrine_run.py:154-160` keeps the current-node record in place on a `human-handoff` (the handoff node has `op_class="read"`, set at `:80-81`) and only `_clear_current_node` (converged/halted, `:100-107`) or the manual `clear-node` CLI removes it. The record lives in `axon/state/doctrine-current-node.json` (persists across sessions); nothing at boot clears it (grep of boot.py/run.py/boot.md/menu.md for clear-node/doctrine-current-node → no hits).
- probe (planted handoff record):
  ```
  BLOCKED code=doctrine-node
  reason: doctrine-node gate: the current node 'handoff' (kind human-handoff) is not a write node …
  ```
- impact: After any doctrine run hands off to a human, the attended human is blocked from ALL host-shell writes/deletes in the workspace (the hook enforces code `doctrine-node` on the Bash path) until they know to run `doctrine_run clear-node` — a fail-closed state with no automatic repair and no hint. (`redirects`+`write_segments` feed it at `shell.py:679`.)
- confidence: CONFIRMED (source + probe).

---

**B-4 | LOW | menu-snapshot `plans` active-count only matches double-space `Status:  active`, but done-count matches single OR double space**
- code: `tools/axon_state.py:272` — `active = [p … if "Status:  active" in texts[p]]` (two spaces only); `:270-271` — `_done_markers` includes both `"Status:  complete"` and `"Status: complete"` (and done variants).
- counterparty: same block's own done set is space-tolerant while active is not — a plan authored with single-space `Status: active` is silently dropped from `active_count`, so `menu.md:225-228` renders no active plans for it.
- probe: `single-space active detected as active? False` / `single-space "Status: done" detected as done? True`.
- impact: Latent undercount of active plans on hand-edited plan files (current repo files use two spaces, so not live today).
- confidence: SOURCE-VERIFIED (+ probe).

---

**B-5 | LOW | menu-snapshot resolves backup/plans via the my-axon pointer but the pointer-coherence sweep hardcodes `root/my-axon`**
- code: `tools/axon_state.py:257` — `dev_projects = root / "my-axon" / "dev-projects"` where `root` is the repo root (`:205`).
- counterparty: same function's backup/plans fields (`:285-286` region) resolve `myaxon = read_myaxon_pointer(str(ws)) or default_myaxon()`. If the my-axon pointer ever relocates my-axon off `root/my-axon`, the two disagree — the pointer sweep scans the wrong/empty dev-projects while backup/plans read the real one.
- impact: Path-source inconsistency; benign in this install because the pointer resolves to `root/my-axon`.
- confidence: SOURCE-VERIFIED.

---

**B-6 | LOW | dispatch_index checker/rebuilder asymmetry in the opposite direction from the one bugfix02 closed**
- code: `tools/dispatch_index.py` `status()` — `extras = sorted(set(idx) - set(src))` uses the full `src` (all statuses).
- counterparty: `rebuild()` excludes `_NON_DISPATCHABLE` (STUB/DEPRECATED/ARCHIVED). A stub program left stale in the index is still present in `src`, so `idx - src` never flags it → `status()` reports `ok:True` even though `rebuild()` would drop it. (bugfix02 fixed the `missing` side; the `extras` side retains the inverse blind spot — pre-existing, not newly introduced by these diffs.)
- impact: The freshness gate can read "index matches" while the dispatch fast-path still routes a retired STUB program. Narrow.
- confidence: SOURCE-VERIFIED.

---

### Verified clean (spot-checked, no defect found)
- `write_barrier.py` anchor/segment matching + `sitecustomize` arming: anchor passed explicitly (`_resolve_repo_anchor`), not the child cwd — no cwd/path bug; scoped to AXON-shell-spawned children by design.
- `doctrine_arming` receipt/status evidence chain: producer (`doctrine_run._receipt`, `--workspace`) and consumer (`_iter_ledger(ws)`, `verify_chain(ws)`) agree on the workspace ledger; committed rows copy `intent`/`rationale` from begin (`loop_receipt.py:256`). (Minor: `f"run {run_id}" in rationale` is substring-matched — run-id prefix collision theoretically possible, negligible.)
- `shell.py` S7b reader path now matches the writer's `axon/state` resolution (the f9da9f6 fix holds).
- `codemap.py`, `obsidian_export.py`, `workflow_run.resolve_next/_dead_next_guard`, `autonomy_doc.py`, `autonomy_contract.py`, `dispatch_stats.py` starvation surfacing, `health.py` timeout headroom: no producer/consumer or fail-open defects found.

### Declared NOT covered by this sweep
- `loop_receipt.recover()` terminality + `loop_contract` goal cross-registration end-to-end (no live begin/commit/recover cycle driven).
- New lints: exec_args_lint.py, shell_result_lint.py, liveness_lint.py, memory_key_lint.py, program_tool_conformance.py (not opened).
- `cron.py`/`cron_conformance.py`, `constraints.py`, `kv_store.py`, `keystone.py`, `board.py`, `hr_team.py`, `reservoir_*` diffs.
- `phase_model.py` seed-outputs (unchanged since 07-07; its new consumers checked clean).
- doctrine `step()` budget/exhausted branch under a real multi-node run.

# Execution streams — axon-bugfree10

Two streams, split by the one boundary that matters: does the fix touch `axon/*` (the kernel floor)?
Split is clean — 24 non-kernel, 7 kernel, **0 mixed** PRs, 91/91 bugs covered.

---

## STREAM N — NON-KERNEL (autonomous)
24 PRs · fully delegable · runs unattended once the grant is live.

**Gate to start:** owner grants attended autonomy (self-mint is refused for the agent):
```
! cd /home/arturcastiel/projects/new-axon/axon && python3 tools/autonomous_mode.py off && python3 tools/autonomous_mode.py on --repo artur.castiel-tno/axon --ops commit,push,pr-create,merge-squash --mode interactive --note "attended owner grant: axon-bugfree10 non-kernel"
```

**Per-PR contract (DAG order):** branch → implement → **full 5,548-test suite all-green** → commit → push → `merge-squash` on `ci.tno.nl` → next. Red ⇒ never merge; hold PR + dependents; continue independents; report at end.

| order | PR | deps | bugs | title |
|--|--|--|--|--|
| 1 | PR-01 | — | 3 | shell.py R9 write-gate: kernel anchor + redirect regex + cd-cwd rebase |
| 2 | PR-06 | — | 2 | Green-gate integrity: test_runner returncode-aware + quality_loop HMAC ramp |
| 3 | PR-04 | — | 3 | Doctrine gates: fail-closed integrity, delimited receipt, relative-path crash |
| 4 | PR-28 | — | 1 | config.md autonomy fail-open: attended capability-grant branch |
| 5 | PR-02 | — | 3 | Rule linters: shared comment/quote strip before EXEC/STORE/phase scans |
| 6 | PR-05 | PR-02 | 4 | Lint/dep/conformance gates: close substring & regex fail-opens |
| 7 | PR-03 | — | 4 | Rule linters: regex/parse correctness (arithmetic, dont-do, mode-lock, receipts) |
| 8 | PR-07 | — | 3 | Trace gates: dag conditional edges, drift TTL, pr_drift anchor casing |
| 9 | PR-17 | PR-01,06 | 4 | Program dry-run & control-flow: combine/merge/workflow-run |
| 10 | PR-08 | PR-06 | 2 | Receipt & ledger integrity: canonical checksum + GC re-chain |
| 11 | PR-29 | PR-03 | 1 | axon.py: canonical registry tool name in receipts |
| 12 | PR-09 | — | 2 | workflow_run.py: exclude drafts, honor boolean-true `if:` |
| 13 | PR-10 | PR-03 | 3 | Tool health/conformance/registry resolution |
| 14 | PR-11 | — | 2 | State stores: kv_store null value + memory L: rollback |
| 15 | PR-13 | PR-06 | 3 | Data-integrity: table-row corruption, rollback eviction, obsidian counts |
| 16 | PR-14a | — | 4 | CLI arg/boundary hardening: benchmark, tokenizer, context |
| 17 | PR-14b | — | 2 | Hook/refresh boundary: reanchor_store token + project_refresh |
| 18 | PR-15 | PR-06 | 2 | Invocation fidelity: run.py subcommand/args + dispatch threshold |
| 19 | PR-16 | — | 2 | Harness plumbing: verify_stop import path + cold_stranger repo_sha |
| 20 | PR-18a | PR-01,06 | 3 | code-dev dispatch/CASE routing |
| 21 | PR-18b | PR-01,06 | 3 | code-dev guard/seed logic |
| 22 | PR-19 | PR-01,06 | 5 | code-dev arg/tool/result marshaling |
| 23 | PR-20 | PR-06 | 5 | Program logic & interpolation: discover/quality-loop/versions/audit/compare |
| 24 | PR-21 | PR-01 | 2 | Program state/persistence: plan-done pointers + chat-input persist |

Non-kernel bug total: 62.

---

## STREAM K — KERNEL EDIT (`axon/*`) — HELD
7 PRs · **never autonomous** (inviolable floor). Each requires per-change owner approval: dev-mode ON (already true) + explicit "yes" on THAT diff + full-suite green. Prepared as a patch + failing-before test, presented one at a time; nothing merges without your word.

| PR | bugs | files | fix theme |
|--|--|--|--|
| PR-22 | 3 | `axon/tools/dry_run_lint.py`, `axon/tools/write_barrier.py` | gate fail-opens (live kernel gates — highest kernel priority) |
| PR-23 | 4 | `axon/tools/predicate.py`, `programs_registry.py`, `validator.py` | error handling / crash paths |
| PR-24 | 2 | `axon/tools/self_care.py` | substring false-positives |
| PR-25 | 5 | `axon/tools/_axon_lib.py`, `clock.py`, `liveness_lint.py`, `redact.py`, `rules_loader.py` | kernel tool logic/format |
| PR-26 | 4 | `axon/compiler/templates/{chat-session,feedback-loop,qc-workflow}.tpl.md` | compiler template defects |
| PR-27a | 2 | `axon/KERNEL-SLIM.md` | active-program interrupt-gate integrity (kernel core — owner scrutiny) |
| PR-27b | 3 | `axon/programs/{dev-new,plan-list,register-preference}.md` | kernel program specs |

Kernel bug total: 29. Suggested approval order: PR-22 → PR-23 → PR-24 → PR-25 → PR-26 → PR-27b → PR-27a (leave `KERNEL-SLIM.md` core for last, most scrutiny).

---

## Governance snapshot
- dev-mode: ON · destructive ops: DENY (floor holds) · kernel-change: DENY (never delegable)
- Stream N blocked only on the attended grant command above.
- Stream K blocked on per-change owner approval (by design — cannot be lifted by any grant).

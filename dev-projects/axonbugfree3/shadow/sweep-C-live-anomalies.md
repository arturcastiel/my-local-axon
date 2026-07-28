# Sweep C — live boot-anomaly root-cause (raw agent return, 2026-07-13)
method: read-only; each 2026-07-13 boot anomaly followed to root with file:line + quoted probes.
Pending: adversarial reconfirmation (main loop).

---

## ANOMALY 1 — prompt-log split-brain
**VERDICT: real bug** — the consent flag is ONE key in ONE file; the split is which WORKSPACE ROOT each caller resolves.

- Shared reader: `tools/prompt_log.py:46-52` `is_enabled(ws)` reads `<ws>/memory/longterm/prompt-log-enabled.md` (`:33-34`, PREF_FILE `:27`).
- Reader A (menu-snapshot): `tools/axon_state.py:232` calls `prompt_log.py consent` with NO `--workspace` → argparse default `default_workspace()` (`tools/prompt_log.py:103`) = `AXON_ROOT/workspace` → reads `workspace/memory/longterm/prompt-log-enabled.md` → true. Snapshot forwards `{enabled, should_prompt}` (`tools/axon_state.py:236`).
- Reader B (record probe): `--workspace $(pwd)` = repo root → reads `<root>/memory/longterm/prompt-log-enabled.md` — DOES NOT EXIST → fail-closed skip (`tools/prompt_log.py:50-51`, `:124-125`).
- On disk (repo-wide `*prompt-log*`): only `workspace/memory/longterm/prompt-log-enabled.md` ("value: true") + `prompt-log-consent-asked.md` ("true") + `workspace/memory/episodic/prompt-log.jsonl` + the program file. Nothing under my-axon/ or repo-root memory/.
- Probes: `consent` (default ws) → `{"enabled": true, "asked": true, "should_prompt": false}` · `consent --workspace $(pwd)` → `{"enabled": false, "asked": false, "should_prompt": true}`.
- Canonical-key split, named: `L:prompt-log-enabled` is canonical ONLY at `<AXON_ROOT>/workspace/memory/longterm/` (where memory.py resolves L: — `tools/memory.py:8-14` — and where enable/disable write, `tools/prompt_log.py:107-119`). Any caller passing a non-canonical `--workspace` resolves a phantom copy and fails closed. THE KERNEL ITSELF DOES THIS: `axon/KERNEL-SLIM.md:112-118` calls `TOOL(prompt-log, record, "... --workspace {W:ws-path}")` and **W:ws-path has no writer anywhere** (repo-wide grep: only local vars in workflow-run.md:33 / workspace-backup.md:38; WORKSPACE.md defines ws-os/ws-tools/… never ws-path). Hook path is fine: `tools/hooks/reanchor_store.py:52-54` calls record with no --workspace → canonical.
- `consent` output vs menu contract: no field mismatch (`{enabled, asked, should_prompt}`; menu reads `.should_prompt`).

Collateral:
- **C-1 | HIGH** — `axon/KERNEL-SLIM.md:118` `--workspace {W:ws-path}` (undefined key) → the kernel-discipline prompt-log record band fail-closed skips DESPITE recorded consent; episodic prompt capture from that band never happens (pattern.py source starves). [kernel file — human-only fix]
- **C-2 | MEDIUM** — `tools/lint_path_vars.py:41-46` scans only `workspace/programs` + `axon/programs`, so undefined `W:ws-path` in KERNEL-SLIM.md escapes the lint built for this class (probe: `{"ok": true, "violations": []}`).
- **C-3 | LOW** — stray untracked shadow tree at repo root: `memory/episodic/phase-ledger.md` (mtime 2026-06-08; `git ls-files memory/` empty) — residue of past cwd-relative workspace resolution.
- By-design note: fail-closed on missing pref file is intentional (opt-in privacy default).

---

## ANOMALY 2 — drift permanently "unknown" + auto-improve breaker tripped
**VERDICT: real bug — fail-closed deadlock with no mechanical producer.**

- Probes: `drift gate` → `{"score":0.0,"state":"unknown","decision":"halt","modifier":-50,"note":"trace stale (older than 7200s)"}` · `drift check` → same trace, `"status":"stable","icon":"✓"` (no TTL logic) · breaker: axon-auto-improve disabled 2026-07-06 after 3 refusals.
- Trace on disk: `workspace/working/drift-trace.json` recorded_at 2026-07-07T20:05:40Z (TTL = 7200 s, `tools/drift.py:223`).
- Writers: only `tools/drift.py` cmd_init/cmd_record (`:142-181`). Callers:
  1. `axon/BOOT.md:186-188` — the ONLY init caller; guard tests FILE-EXISTS, not staleness, contradicting its own comment (`:184-185` claims "stale trace → next boot re-inits"). Once the file exists, boot never re-inits.
  2. `axon/KERNEL-SLIM.md:192,292,345,380` — per-turn `drift record --type … --detail …`: current tool accepts only `--tool` (`tools/drift.py:329-331`) → argparse exit 2, can never refresh the trace. This is DELETED-TOOL RESIDUE: `workspace/tools/drift.py` (deleted b102d2b, 2026-07-07) had exactly `record --type/--detail` (verified via `git show b102d2b^:workspace/tools/drift.py`). `axon/OUTPUT-LAYER.md:129` also targets legacy semantics.
  3. No mechanical caller: `tools/boot.py` never touches drift; no cron job runs `drift init`.
- Deadlock sequence: `tools/boot.py:343-345` ticks cron mechanically at boot (L:cron-auto=true) → `axon-auto-improve` → `tools/auto_improve.py:315-323` refuses on drift ∈ {diverged, unknown}. Tick runs BEFORE any agent-level BOOT.md drift step; daily schedule vs 2h TTL makes the precondition mechanically unsatisfiable → 3 refusals → `_apply_breaker` (`tools/cron.py:273-297`, threshold 3) disabled the job.
- Repair paths: `cron enable --id axon-auto-improve` resets the breaker but re-trips in 3 days; only `drift init --no-program` freshens the gate (2h). Nothing runs it automatically. Interlocking pieces: `axon/BOOT.md:186` + `tools/drift.py:223` + `tools/auto_improve.py:316` + `tools/cron.py:284`.

Collateral:
- **C-4 | HIGH** — `axon/BOOT.md:186` FILE-EXISTS guard contradicts its stated contract; auto-init fires at most once per trace lifetime. [kernel file — human-only fix]
- **C-5 | HIGH** — `axon/KERNEL-SLIM.md:192,292,345,380` + `axon/OUTPUT-LAYER.md:129` invoke the deleted legacy drift interface — the whole per-turn drift-signal band is dead (every call exits 2); also starves igap's fallback-exec trigger. [kernel files — human-only fix]
- **C-6 | MEDIUM** — advertised remediations broken: `menu.md:202` (+ compiled mirror `menu.cmp.md:168`) says "run: drift init or drift reset" — bare `drift init` exits 2 (needs `--program|--no-program`), `drift reset` DELETES the trace → gate → unknown("no active trace"): the suggested fix reproduces the fault. Same stale advice: `auto-improve.md:52`, `stats.md:121`.
- **C-7 | MEDIUM** — `drift check` vs `drift gate` split-brain: cmd_check (`tools/drift.py:184-202`) has no TTL/fail-closed logic → reports "stable" for the trace the gate halts on.

---

## ANOMALY 3 — `axon_state.py get active-phase` printed nothing
**VERDICT: by-design** — no `get` subcommand exists (`tools/axon_state.py:336-361`: summary/recent/menu-snapshot/log only); argparse error went to stderr, exit 2, stdout empty. Real interfaces: `memory.py get --scope W --key active-phase` (probe: `{"value":"axonbugfree3:study","found":true}`) or snapshot `working_keys.active_phase`. No caller anywhere invokes `axon-state get` → nothing downstream broken. No collateral findings.

---

## ANOMALY 4 — pointer sweep `test-record-stale`
**VERDICT: real staleness, correctly detected; menu's "repair" claim overstated (report surfaces, nothing repairs).**

- Implementation: `tools/self_care.py:117-230` pointer_check() (stale-pointers PRs 2026-07-09/10), wired at `tools/axon_state.py:256-272`.
- The stale record: check 4 (`self_care.py:205-228`) — `workspace/memory/longterm/last-test-run.json` = `{"suite":"full","ts":"2026-07-13T07:10:27+00:00","verdict":"FAIL","passed":5383,"failed":27,...}` vs HEAD fc05324 committed 07:33:20 UTC → HEAD newer → stale. REAL: fc05324 added a tool + 9 programs + tests (not cosmetic); TZ handling sound (conftest.py:44 stamps UTC). Known FP class (run-then-commit) is the sweep's stated invariant, and here new code genuinely landed untested; last recorded verdict moreover FAIL (27).
- Boot findings=1 → live now findings=2: `unknown-program` added when active-phase was set to `axonbugfree3:study` (project slug; sweep validates pre-colon token against `workspace/programs/*.md`, `self_care.py:144-153`). [self-inflicted by this session — see C-9]
- self-care report: surfaces (run_check → Pointers panel + fix text) but heal() (`self_care.py:308-331`) never runs the suite nor touches active-phase → `menu.md:203` routes to diagnosis, not repair.

Collateral:
- **C-8 | MEDIUM** — invalid advertised CLI: `self_care.py:367` prints "Run `self-care --heal`" and `menu.md:379` says "self-care [report|--heal]", but `--heal` exists only on the `check` subparser (`self_care.py:379-380`) — `self_care.py --heal` exits 2. Correct: `self-care check --heal`.
- **C-9 | MEDIUM** — W:active-phase key-convention split: kernel mandates `{program-name}:{phase}` (`KERNEL-SLIM.md:338-341`) and the sweep enforces it, but `workspace/programs/code-dev.md:221` writes `STORE(W:active-phase, "{project}:done")` — project-keyed. Non-terminal project-keyed values (live now: `axonbugfree3:study`) trip `unknown-program` and suppress the resume offer (`menu.md:237-239`).
- **C-10 | LOW** — sweep checks recency only, never verdict: a fresh-but-FAIL full-suite record (failed:27) raises no finding (`self_care.py:210-227`).

---

Cross-anomaly summary: A1 real bug (kernel `W:ws-path` phantom + workspace-root split) · A2 real bug (drift fail-closed deadlock, zero mechanical producers) · A3 by-design · A4 real staleness, remedy overstated. Collateral C-1..C-10.

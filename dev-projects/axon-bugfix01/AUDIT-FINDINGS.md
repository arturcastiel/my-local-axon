# AXON Self-Audit — Findings (Round 2, closed)
project: axon-bugfix01
codebase: /home/arturcastiel/projects/new-axon/axon
date: 2026-07-01
method: axon-audit (mechanical) + custom static cross-reference scripts + 10 parallel deep-read/run-verified
agent audits across two rounds, plus an adversarial re-verification pass (4/4 spot-checked CRITICAL findings
independently reconfirmed from scratch).
scope focus (owner-requested): unwired neurons/programs/tools, missing files, broken routines — heavy focus on
code-dev workflows + hr-team. Round 2 was a "close any gaps" pass covering library-dev, core infra (memory/
scheduler/phase-model/goal), the dispatch/synapse routing backbone, and autonomous-mode/AEGIS governance.

Every finding was verified by reading the actual source (not inferred from naming), and wherever possible by
actually running the code (predicate.py, workflow-runner, cron, self_care.py, synapse_suggest.py, simulate.py,
sandboxed phase-model/queue_tool.py calls, live `goal list`, etc.). Line numbers are as of this audit date.

---

## Severity legend
- **SAFETY-CRITICAL** — a documented governance/safety gate does not actually enforce what it claims; an agent
  operating in good faith on the documentation could take an action the owner believes is blocked.
- **CRITICAL** — the advertised feature does not work at all / silently does the wrong thing on the golden path.
- **HIGH** — a real, reachable defect with concrete user-facing impact, but not on the single most common path.
- **MEDIUM** — reachable defect with narrower impact, or a fully-built capability that's structurally unreachable.
- **LOW** — cosmetic/doc drift, dead code with no live trigger, or weak self-reported claims worth spot-checking.

---

## SAFETY-CRITICAL (new in round 2 — outranks everything below)

### S1. Destructive git-op gating and the "kernel-file edits are never delegable" floor are not mechanically enforced
`axon/KERNEL-SLIM.md:576,701-707` and `workspace/autonomous-mode.md` document that force-push/reset --hard/
branch-delete/amend/rebase stay human-only unless a grant *explicitly* delegates that specific op, and that
kernel-file edits are an inviolable floor no grant can touch. Verified this is not real:
- The actual write-time chokepoint is `tools/shell.py`'s `gate_check()`, live-wired via a `PreToolUse` hook
  (`.claude/settings.json` → `tools/hooks/enforce_pretooluse.py`). It only checks a short hard-forbidden regex
  list (`sudo`/`rm -rf /`/etc.) and the `axon/`-path + dev-mode rule. It never imports `autonomous_mode` or
  `aegis_policy`, and has zero destructiveness classification for git flags (`--force`/`--hard`/`-D`/`--amend`).
- `autonomous_mode.py`'s `authorized()` function — which *does* correctly implement the documented
  `DESTRUCTIVE_OPS` allow-list check — has **no production callers anywhere**, only test callers.
- Live-checked: this repo's own active grant shows `"destructive": []` (floor supposedly held), but nothing
  ever consults that field before a git command actually runs. A `git push --force`/`git reset --hard` today
  passes the hook with exit 0.
- Same "coded but never called" pattern for the "test-execution" AEGIS policy gate — `aegis_policy.py`'s
  resolver has exactly one production caller, and it's for an unrelated web-capability check, not tests.
  `tools/test_runner.py` never references aegis/autonomy/grant/policy at all.
- The "kernel-file edits are inviolable" claim reduces to the single global `L:dev-mode` boolean, which has
  no concept of "kernel file" (every path under `axon/` is gated identically) and is itself agent-writable
  with no code-level barrier beyond a prose instruction in KERNEL-SLIM.md telling the agent not to.
- Mitigating: the underlying `axon/`-write dev-mode gate itself (R9) IS genuinely, mechanically enforced —
  the gap is specifically the destructive-op and "kernel floor beyond dev-mode" claims layered on top of it.
**Impact:** the documentation describes a fail-closed, audited, per-op-scoped governance system; the reality
is one undifferentiated toggle plus test-only code for everything more specific than that.

### S2. The orchestrator's autonomous "fire" decision loop is fundamentally broken and would confidently misfire
Two independent, compounding bugs:
- **Wrong corpus:** every production call site of `TOOL(synapse-suggest, rank, ...)`
  (`orchestrator.md:83-84,115-116`, `workflow-new.md:101`, `workflow-run.md:252`) omits `--candidates`, so
  `synapse_suggest.py` falls back to building candidates from `tools/REGISTRY.json`'s ~180 Python *tool*
  scripts, not the 172 real *programs*. Live-verified: ranking "run the code review workflow" returns
  `lint-code` (a tool, not a program) as the top hit.
- **Confidence is mathematically always 1.0:** `rank()` normalizes `score = raw / max_raw`; the top candidate's
  raw score *is* max_raw, so its normalized confidence is always exactly `1.0` regardless of actual signal
  strength (confirmed: a raw score of 0.119 built off crude token overlap still normalized to 1.0).
  `orchestrator.md:100` feeds this straight into `decide()`, calibrated against 0.6-0.85 thresholds — meaning
  at the system default inference-mode (3), the orchestrator would confidently auto-fire near-arbitrary tool
  names, not just fail to help.
- **Even a correct decision couldn't execute:** the "fire" step itself calls `TOOL(dispatch, match, "--top 1")`
  — `dispatch.py match` has no `--top` flag at all (confirmed via live CLI error), and the result JSON never
  has the `ok` key the code asserts on. There is no `EXEC()` anywhere in the fire block — "firing" a synapse
  today is telemetry + a doomed assert, never an actual invocation.
- The lint purpose-built to catch call-site mismatches like this (`program_tool_conformance.py`) is genuinely
  clean everywhere it runs (0 violations, 36 real call sites checked) — but its file-glob scope silently
  excludes `orchestrator.md` entirely, so it never saw this.
**Impact:** the adaptive/orchestrator layer — the mechanism `adaptive-free-text.yml` (C4) and any "AXON decide
what's next" flow depends on — cannot correctly recommend, and structurally cannot correctly execute, its own
top-ranked suggestion.

---

## CRITICAL

### C1. Every shipped fixed code-dev/library-dev workflow dies at its first review gate (predicate vocabulary mismatch)
**Files:** `workspace/domains/code-dev/workflows/{code-dev.canonical,cpp-code-dev,python-code-dev}.yml`,
`workspace/domains/library-dev/workflows/library-dev.canonical.yml` vs `tools/predicate.py:495-511`,
`workspace/programs/workflow-run.md:212` *(path correction from round 1: these live under
`workspace/domains/{code-dev,library-dev}/workflows/`, not `workspace/workflows/` — verified by direct read)*
The YAMLs call predicates like `review.passes()`, `review.has-objections()`, `tests.pass()`, `build.passes()`,
`ctest.passes()`, `api-diff.no-breaking-changes()`. `predicate.py`'s actual registered `BUILTINS` are named
differently: `review.passed`, `tests.passing`, `tests.failing`, `build.green`, `ctest.passing`, `audit.complete`,
`goal.acceptance.met`. Reproduced live for every gate in all 4 files, not just the first:
```
step 4: s4 -> code-dev-review-self
  if('review.passes()')          -> None  ERROR:undefined_function
  if('review.has-objections()')  -> None  ERROR:undefined_function
-> BREAK (no on-complete rule resolved true)
```
`workflow-run.md`'s loop sets `next-id ← ∅` and breaks silently — no error surfaced to the user. Separately,
`ctx` (built at `workflow-run.md:212`) only ever carries `{"state": {...}}`, never `audit`/`review`/`tests`/
`build`/`goal`/`W` — so even fixing the naming, most gates would still evaluate against an empty context; bare
dotted refs like `audit.open-findings` fall into `ctx["state"]["audit"]`, which also never exists, so `== 0`
comparisons silently resolve `false` rather than erroring.
**Impact:** `workflow run code-dev` / `cpp-code-dev` / `python-code-dev` / `library-dev` — the flagship
"ship a PR end-to-end" workflows — all truncate after step 4 of 7-8. Every run is misreported `status: partial`.
**Related:** `multiple-code-dev.yml`'s own gate (s4, `iterate-or-stop`) has the identical root cause —
`W.mcd-decision == "green"` never resolves because `workflow-run.md` never populates a `"W"` key in ctx. The
"verified" comment in `iterate-or-stop.md:49-50` claiming this works is false.
**Adversarially re-verified independently (round 2, Part B): CONFIRMED**, no discrepancy beyond the path fix above.

### C2. hr-team's audit-bundle write path is never called — the compliance/persistence feature is fiction
`tools/hr_team.py:673-736` (`write_audit_bundle`) is fully implemented and produces exactly the
`manifest.json`/`transcript.md`/`events.jsonl`/`decision.md`/`checksums.sha256` shape seen under
`my-axon/hr-team/councils/*` — but it is **not registered** in `_HELPER_COMMANDS` (`hr_team.py:574-583`), so
no `.md` program can ever invoke it; the only caller anywhere is `tests/test_hr_team_contract.py`.
`hr-team.md`'s `OUTPUT` section only calls `seal` and `verify-surfaceable`, then emits and `DONE`s. Confirmed
the real runtime bundle samples contain literal `"STUB (no real cognition wired)"` seat text — the exact
fallback shape from a test-fixture call, not the documented pipeline.
**Impact:** every `hr-team --persistence full-audit` run produces zero persisted, checksummed audit trail.
**Adversarially re-verified independently (round 2, Part B): CONFIRMED**, no discrepancy.

### C3. hr-team M2-FILTERED mode is unreachable; `--family`/`--roles` are fully dead; `--domain` mislabels invocation mode
`hr-team.md` loads `domain`/`family`/`roles`/`size`/`budget` as local variables but never `STORE`s a combined
`W:hr-team-filter` object, which is the only thing `hr-team-selector.md` reads to detect M2-FILTERED mode.
`match_roster()` (`hr_team.py:359`) has no `family`/`roles` parameter at all — those two flags never influence
seat selection, and any `--domain`-filtered run is mislabeled `invocation_mode: "M1-FULL"`.

### C4. `adaptive-free-text.yml`'s first node dispatches a program that does not exist
`s1: {name: synapse-suggest, role: orchestrator}` — `synapse-suggest` is registered only as a **tool**
(`tools/synapse_suggest.py`); there is no `workspace/programs/synapse-suggest.md`. `workflow-run.md`
dispatches every non-sub-workflow synapse via `EXEC({cursor.name})` — s1 is the workflow's `start` node, so
the very first step of `workflow run adaptive-free-text` fails unconditionally. Compounding: even fixed, `s2`
is hardcoded to `code-dev-flow` regardless of what synapse-suggest ranks — a fixed 2-node loop, not dynamic
dispatch (and per S2 above, the ranking mechanism it would need is itself broken).
**Adversarially re-verified independently (round 2, Part B): CONFIRMED**, no discrepancy.

### C5. `code-dev check-structure` runs the wrong program entirely
`cmd ≡ "check-structure"` stores `W:code-dev-safety-audit-sub = "structure"` then `EXEC(code-dev-safety-audit)`.
But `code-dev-safety-audit.md` never reads that key (its own subcommand var is `W:code-dev-audit-cmd`, default
`"full"`) and never forwards to `code-dev-safety-audit-structure.md` — which implements the real structure
check (with `--fix` support) and is called by **nothing** in the entire corpus.
**Impact:** a user running `code-dev check-structure` gets the heavyweight Phase-5 final audit instead,
including an unexpected write-prompt for `05-audit.md`.

### C6. The entire PR-ergonomics suite is unreachable — `pr list/drift/sync/export/suggest-reviewer` all silently route to PR-create
`code-dev.md`'s router matches only single hyphenated tokens; `cmd ≡ "pr"` unconditionally maps to
`EXEC(code-dev-pr-create)` — there is no multi-word `"pr list"` / `"pr drift"` branch, and none of the 5
target files are `EXEC()`'d by anything else.

### C7. Eight "PR-14 umbrella router" programs are completely unwired
`code-dev-flow/journal/knowledge/lifecycle/meta/safety/shape/state.md` all document `usage: code-dev <name>
<sub> [args]`; none of those tokens exist as `cmd` branches in `code-dev.md`. Only reachable by typing the
literal hyphenated filename directly. All 8 also use an `ARG(1)`/`ARG(--flag)` primitive that doesn't exist
anywhere else in AXON's core grammar.

### C8. `library-dev.canonical.yml` is code-dev's workflow file copy-pasted with zero domain adaptation *(new, round 2)*
**File:** `workspace/domains/library-dev/workflows/library-dev.canonical.yml`
All 8 synapses (s1-s8) name `code-dev-study, code-dev-plan, code-dev-pr-create, code-dev-review-self,
code-dev-knowledge-shadow, code-dev-changelog, code-dev-safety-audit, code-dev-merge` — none of library-dev's
own 8 real programs (`library-dev-{new,ingest,explain,intersect,search,report,cite,status}`) are referenced
anywhere in it. Diffing against `code-dev.canonical.yml` shows this is an almost-verbatim copy (one extra
synapse inserted, IDs renumbered) with not even the synapse names changed. `workspace/domains/library-dev/
workflows/_index.md:7` even describes it in code-dev's own vocabulary.
**Impact:** `workflow run library-dev` either fails immediately (s1 = `code-dev-study` requires
`W:code-dev-project`, never set in a pure library-dev session) or, worse, silently executes an entire
code-PR pipeline mislabeled "library-dev" if a code-dev project happens to be active concurrently — directly
contradicting library-dev's own manifest ("flat container — no phases, no PRs").

### C9. `L:` memory scope has a split-brain: `config wizard` writes are invisible to the kernel's own gates *(new, round 2)*
`workspace/programs/config.md:96-98` writes `L:inference-mode` etc. via `tools/kv_store.py` (diskcache-backed).
But `KERNEL-SLIM.md:267` (`inf ← RETRIEVE(L:inference-mode)`, the actual gate governing autonomy behavior)
and `config.md`'s own "show" resolve `L:` via `tools/memory.py`/`tools/_longterm.py`
(`workspace/memory/longterm/*.md`-backed). Verified live: each backend reports the other's key as not-found.
**Impact:** running the config wizard to change autonomy-governing settings is a silent no-op for the behavior
it's supposed to change. Same split-brain independently confirmed for `L:health-score` (a stale, frozen-at-100
orphan file still exists with no current writer).

### C10. Scheduler preemption — the core documented behavior — has zero backing implementation *(new, round 2)*
`tools/queue_tool.py`'s argparse only supports `add/list/complete/pop/clear` — no pause/resume/preempt, no
snapshot/restore. `PREEMPT` exists only as a symbolic op in `axon/core/LANG.md` with no caller anywhere.
`SCHEDULER.md`'s and `KERNEL-SLIM.md:498`'s full preempt sequence is pure prose. Compounding, independently
reproduced: `pop` permanently loses a task (never re-inserted; `complete` can't find it afterward — verified
empirically); dependencies are stored (`--deps`) but never read again or enforced (a task depending on an
incomplete task was popped immediately); starvation-prevention/aging has zero matching code anywhere;
`clear` wipes active/pending and leaves completed history untouched — the *opposite* of documented session-end
semantics. `QUEUE.md` (both copies) is permanently stale — `queue_tool.py` never touches the `.md` files;
real state lives in `workspace/scheduler/queue.json`, which the docs never reflect.

### C11. Phase-model's own documented escape hatch (force-skip) doesn't actually unstick a stuck phase *(new, round 2, empirically confirmed)*
`code-dev.md`'s Force-skip branch calls only `TOOL(phase-model, stale-downstream, ...)`, never
`done ... --force`. Reproduced in a sandbox: after a force-skip, advancing the next phase still raises
`deps not done: ['plan']`. No exposed recovery path exists in the program layer.
**Impact:** this breaks the system's own designated escape hatch from "rigid fixed traversal" — a project can
get permanently stuck at a phase boundary with no documented way out.

### C12. Goal-system phase-entry guidance is dead code everywhere it's used, silently, across 5 call sites *(new, round 2, systemic)*
`TOOL(goal, list, "--level phase")` returns an envelope `{"ok":true,"count":N,"goals":[...]}`. Every one of
its 5 callers — `code-dev-study.md:186,189-191`, `code-dev-plan.md:154,157-158`, `code-dev-journal-log.md:77`,
`code-dev-safety-audit.md:68,71-72`, `code-dev-pr-create.md:111` — treats that envelope *as if it were* the
goals array itself (`IF pg ≠ ∅ AND COUNT(pg)>0 → FIRST(pg).statement` operates on the dict, not `pg.goals`).
Since the envelope is always truthy with `count` as one of its 3 keys, the "no goal set" fallback can never
trigger and `FIRST(pg)` always operates on the wrong object — live-verified: `goal list --level phase` →
`{"ok": true, "count": 0, "goals": []}` even with zero goals actually defined, and the bug reproduces
identically regardless. Separately, the only writer of the store this reads (`goal set`) is never called by
any program anywhere — `goal-define.md` writes a different markdown ledger instead, and `workspace/memory/
goals.yml` (the file `goal set/get` would read/write) doesn't exist on disk.
**Impact:** the "GOAL — this phase" guidance block shown at the entry of study/plan/log/audit/pr-create has
never actually surfaced a real goal, in any project, ever — it always silently takes the "no goal set" or
malformed-object path.

### C13. `simulate` — the command AXON's own menu tells users to run "before anything irreversible" — is completely broken *(new, round 2)*
`simulate.md` calls `TOOL(simulate, run, {file} {verbose-flag})`, passing a path as a bare positional plus
`--verbose`. `tools/simulate.py`'s real argparse only defines `action` (`run`/`check`) + `--program`/
`--input`/`--workspace`/`--axon-dir` — no positional path, no `--verbose` flag. Live-reproduced:
`python3 tools/simulate.py run <path> --verbose` → `error: unrecognized arguments: <path> --verbose`.
`simulate.md`'s OUTPUT section then reads fields (`ops_total`/`agent_ops`/`tool_calls`) that don't exist in
the tool's real return schema either (`{program, path, seed_input, trace, irreversible_ops, summary:
{op_counts, tools_called, total_ops}, shadow_memory_final}`).
**Impact:** the specific safety feature `menu.md` repeatedly urges users to run before anything irreversible
fails outright with a CLI error, every time, on every input.

---

## HIGH

### H1. `code-dev pr-ready`'s preflight delegate is broken
`code-dev-pr-ready.md:64` passes `mode="check-only"` inline on the `EXEC()` call; `code-dev-safety-preflight.md`
only ever reads `W:code-dev-preflight-mode` — inline args don't propagate. Preflight always runs noisy full
mode; `pr-ready`'s Gate C misreads the result and will almost always report `"✗ preflight FAILED"` regardless
of actual gate state.

### H2. hr-team selector weight elevation (incl. auditor 2× boost) is computed then silently discarded
`hr-team-deliberator.md:43` computes `initial-weights` and never uses it again; `deliberation-metrics` has no
`--weights` param, so aggregation is always uniform `1/N`.

### H3. hr-team's re-round-on-substantive-dissent path is unreachable, with a malformed `GOTO` underneath it
`hr-team-convener.md` always runs all rounds to completion with no early exit, so `rounds-run < rounds-max` is
always false. If it somehow fired: `reround=true` kwarg is never read by the convener, and `GOTO(STEP 1)`
matches no `## SECTION:X` heading anywhere in the corpus.

### H4. Fixed / Adaptive / Hybrid workflow modes are not actually differentiated
`workflow-run.md` resolves `next-id` purely by walking `on-complete` rules identically for every mode; the
adaptive ranking is printed as an info line and never assigned to `next-id`. Hybrid has zero implementing
logic anywhere; no shipped workflow even uses `execution-mode: hybrid`.

### H5. `workflow validate` never runs the two lints purpose-built to catch C1/C4/C8
`check-stale`/`check-templating` exist, unit-tested and CLI-exposed, but `workflow-validate.md` calls neither.
`check-stale` also whitelists any name matching a registered tool, so even wired in it would not have caught
C4's tool-vs-program confusion.

### H6. Cron job `CRON-003` (self-care) failed its one execution attempt to date
`"program": "self-care"` with no subcommand; `self_care.py` requires one (`{check,report}`). *(Round-2
adversarial re-check nuance: `consecutive_failures: 1` means exactly one weekly run has occurred since the
job was added 2026-06-19, and it failed — not a long failure history, just the only attempt so far.)*

### H7. `lint-code-weekly` cron job was coded but never actually seeded into production
Declared in `cron.py`'s `seed-defaults()` DEFAULTS list, tool exists, but absent from live `cron.json`.

### H8. `code-dev-lifecycle.md` — `init` and `load` route to the identical file (copy-paste bug)
Both branches `EXEC(workspace/programs/code-dev-load.md)`.

### H9. `code-dev-whatif.md`'s computed `EXEC(code-dev-{target})` breaks or silently mis-executes ~20 subcommands
Assumes the raw cmd word equals the callee's filename — false for ~20 renamed targets. Worst case (`whatif
review`) silently resolves to a real-but-wrong program.

### H10. Two live "ALIAS stub" files are still in the routing path past their own "removed next release" deadline
`code-dev-preflight.md`/`code-dev-reviewer-track.md`, both using non-grammar `$@` forwarding syntax.

### H11. `code-dev-migrate.md` is broken on every axis
Unrouted from the parent, undefined `$1`/`$2`, malformed `TOOL()`-inside-`EXEC()` nesting.

### H12. `code-dev-finalize.md` is permanently dead code
Precondition key `L:dev-task-active` is never set `true` anywhere in the codebase.

### H13. Reverse cron drift — `axon-freshness-weekly` is live but absent from `DEFAULTS`
If `cron.json` is ever rebuilt from `seed-defaults`, this job would silently not be recreated.

### H14. `axon-memory-compact` DEFAULTS entry references a tool name that doesn't exist
Live job was hand-corrected; the source `DEFAULTS` entry was never fixed.

### H15. `simulate.md`'s sibling — `quickstart.md`'s step dispatcher never actually dispatches *(new, round 2)*
The `## STEP DISPATCHER` header is a comment only — no routing code follows it; `### STEP 1` begins
unconditionally regardless of `step`. Live-verified via direct read: no `IF step ≡ N` guards exist anywhere
in the file. Each step's own re-entry (`IF step > 1 → EXEC(quickstart)`) loops back to the top, which again
falls through to Step 1.
**Impact:** the resume banner ("↺ RESUMING QUICKSTART · step N/7") renders correctly, but content shown is
always Step 1 — steps 2-7 of the flagship onboarding tour are never actually displayed.

### H16. `run-tests.md` writes to a memory scope that doesn't exist *(new, round 2)*
Uses `R:result` — `R:` is not a recognized AXON memory scope (only `W:`/`L:`/`E:`/`local/`), and appears
nowhere else in the corpus. The PASS/FAIL branch, EMIT payloads, all summary banners, and
`STORE(W:last-test-result, R:result.verdict)` all depend on this unbound variable.

### H17. `library-dev report [type]` always ignores the requested type *(new, round 2)*
`library-dev-report.md` reads `RETRIEVE(W:_args)`, a key the kernel tokenizer never writes (only
`W:_cmd`/`W:_arg1`/`W:_arg2` exist). `library-dev report state-of-the-art`, `... summary`, etc. all silently
produce a `literature-review` report regardless of the argument, contradicting the router's own help text and
the 4 documented types in `workspace/wiki/library-dev.md`.

### H18. `library-dev search → ingest` handoff drops the downloaded file path *(new, round 2)*
`library-dev-search.md` downloads approved candidates via `curl` but never writes the resulting path back
onto the candidate object before storing it for the ingest step; `tools/library.py`'s `rank_candidates()`
never returns a `file` field either. Every article a user approves gets downloaded to disk, then silently
vanishes from the ensuing shadow/ingest loop.

### H19. Router-level subcommand keys (`W:code-dev-cmd`, `W:library-dev-cmd`) are never written by anything mechanical — a convention-reliant gap, not a hard crash *(new, round 2 — flagged with an important caveat)*
`code-dev.md`/`library-dev.md` both do `cmd ← RETRIEVE(W:{domain}-cmd) | ∅`; grepping the entire repo finds
**zero** `STORE(W:{domain}-cmd, ...)` writers anywhere, mechanical or otherwise — the kernel's own documented
tokenizer (`axon/COMMANDS.md`) only ever populates generic `W:_cmd`/`W:_arg1`/`W:_arg2`, never a
domain-namespaced bridge. *Caveat: AXON's routers are interpreted by an LLM agent reading markdown
instructions, not executed by a literal deterministic parser (confirmed separately — `axon/COMMANDS.md`'s own
EXEC-order fallback chain has zero mechanical backing, by design: it's agent-followed documentation). A
capable agent instance reading `code-dev.md`'s header naturally infers "bridge the typed subcommand into this
key" even with no explicit `STORE()` line elsewhere — this is very likely why the router has appeared to work
correctly throughout this entire audit session. It is NOT the same class of bug as the Python-verified,
interpretation-independent defects (C1/C13/H16/etc.).* Still worth fixing: `code-dev.md`'s own header comment
says an *identical* prior bug (a differently-named unwritten key) was already fixed once, and `library-dev.md`
reproduces the same gap verbatim — the convention should be made explicit in code (e.g.
`cmd ← RETRIEVE(W:code-dev-cmd) | RETRIEVE(W:_arg1) | ∅`) so correctness doesn't depend on every future agent
instance independently rediscovering the same undocumented bridge.

### H20. `dispatch-index.json` has no `status` field, so the dispatch fast-path can't distinguish STUB programs from normal ones *(new, round 2)*
All 172 entries only ever carry `{phrases, description, indexed_at, program, source_file}`. The 2 ALIAS-stub
programs (H10) are indexed under their internal `# PROGRAM:` header name, not their filename — a TF-IDF match
landing on either would try to `EXEC()` a path that doesn't exist. `axon/COMMANDS.md`'s own EXISTS guard
catches this and falls through to agent handling (fails safe), but silently defeats the compiled-dispatch
fast path for exactly these two, and only `synapse_suggest.py`'s candidate filter actually excludes STUB
status — which per S2 above never sees real production candidates anyway.

### H21. `tools/synapse_suggest.py`'s docstring falsely claims it uses `synapse-infer` for candidate inference; nothing does *(new, round 2)*
The real fallback path (`_load_candidates_from_registry`) fabricates degraded placeholder records
(hardcoded `role: "reader"`, empty `next-conditional`/`post-state`, generic `cost: 1000`) — structurally
zeroing out several of the ranker's own weighted signals for every fallback-ranked candidate.
`synapse_infer.py` has zero production callers anywhere; its only trace in the corpus is a static
`inferred-by: synapse-infer (PR-108 bulk migration)` provenance tag from a one-time historical migration.

### H22. `axon-compare.md` reads a JSON key that was deleted from the tool it depends on *(new, round 2)*
Reads `baseline["1b"]["compilation"]["compiled/total_programs/coverage_pct"]` — the `"compilation"` key was
removed from `tools/axon_audit.py`'s output in a commit dated 2026-06-10; `axon-compare.md` was last touched
2026-05-22 and never updated. Breaks on undefined value for `compiled-count`/`total-progs`/`coverage-pct`.

### H23. `crucible.md` has no output branch for 2 of its 5 documented subcommands *(new, round 2)*
Usage advertises `list|run|gate|register|status`; the router correctly calls the underlying tool for
`register`/`status`, but the `## OUTPUT` section only has display branches for `list`/`gate`/`run`.
`crucible register`/`crucible status` perform the real side-effect/fetch but render zero output.

### H24. `handoff.md` uses undefined timestamp variables throughout *(new, round 2)*
Uses `{today}`/`{now}`/`now` with no assignment anywhere in the file (every other program in the corpus does
`today ← TOOL(clock) → result.date` first, or uses `NOW()`, used 9× elsewhere). Log-excerpt path is malformed;
the `Timestamp:` line and persisted `L:handoff-state.timestamp` are garbage.

### H25. `migrate-workspace.md` can report success after a failed git push *(new, round 2)*
STEP 4's `QUERY` answer (`yes/skip-push/error`) is checked with a `HALT` at STEPs 2/3 but not at STEP 4 —
execution falls through to STEP 5 regardless, which unconditionally writes `migration-receipt.md` with
`status: complete` even if the push actually failed.

### H26. `harness-builder.md`'s generated output always contains unresolved template placeholders *(new, round 2)*
`{LOOP(∀ c ∈ criteria) { → "criterion_{i}: '{c}'" }}` references a bare `{i}` with no binding anywhere in the
loop (no `ENUMERATE`/`PROGRESS` usage) — the only such case in the whole corpus. Every generated harness
contains literal `criterion_{i}:` text instead of numbered criteria.

---

## MEDIUM

- **M1 — hr-team persistence-mode vocabulary disagrees three ways.** Selector emits `none`/`session`/`full`;
  `write_audit_bundle`'s literal checks expect `full-audit`/`no-logs`/`decisions-only`. Once C2 is fixed, a
  `full`-tier council would silently degrade to the weakest write shape.
- **M2 — hr-team `bpc_passes.randomized_winner`/`.reversed_winner` are undefined variables** on every emitted verdict.
- **M3 — hr-team `verdict-status` assignment-inside-condition bug** (`←` instead of `≡`), fires exactly in the "contested" case.
- **M4 — `workflow-new-questions.yml` is fully orphaned**, and its content diverges from the real `workflow-new.md` implementation.
- **M5 — `orchestrator.md`'s "fixed" branch reads schema fields no real workflow YAML has.** Currently masked
  (fixed-mode runs skip `EXEC(orchestrator)`), but would misfire with a stale `W:active-workflow`.
- **M6 — `axon/tools/REGISTRY.md`'s own "guarded by" completeness tests were never created**; live registry
  (180 tools) has drifted >100 tools ahead of the doc mirror (~76, dated 2026-05-17).
- **M7 — `code-dev-chats.md`** (a real, ACTIVE feature) has no `cmd ≡ "chats"` branch — reachable only by exact filename.
- **M8 — 5 fully-implemented "meta-cluster" files** (`code-dev-meta-{board,dispatch-stats,igap,usage}`,
  `code-dev-rules-audit`) are genuinely orphaned from `code-dev-meta.md`'s hub dispatch, which covers a
  different sub-command set entirely.
- **M9 — 3 tools are genuinely dead with zero callers anywhere:** `pack` (fully implemented, shipped
  2026-05-03, never touched since), `reservoir-mcp`, `reservoir-pvt` (both already flagged in
  `workspace/QUARANTINE.md` for owner-gated deletion).
- **M10 — 3 empty PR-119 stub programs are live-routed but do nothing:** `code-dev-{actions,dry-run,examples}`.
- **M11 — Phase-model's plan-phase output-completeness gate is unsatisfiable in 3 of 4 plan modes.** *(round 2)*
  `code-dev-plan.md` unconditionally declares `03-prs/DAG.json` as an emitted output, but it's only actually
  written in `tactical` mode with ≥1 PR — `strategic`/`operational`/`decision` modes never advance the phase
  manifest for real (masked by a `--best-effort` flag that logs instead of halting).
- **M12 — "Rigid fixed traversal" node-order enforcement is real code but toothless by default.** *(round 2)*
  `r_workflow_node_order.py` exists and is wired into `crucible.py`, but only fires on changesets touching
  `_phases.json` directly (not live sessions) and defaults to WARN — the flip-flag file that would promote it
  to BLOCK doesn't exist anywhere in the repo.
- **M13 — Memory doc/code disagreement on `local/` scope.** *(round 2)* `KERNEL-SLIM.md:486`'s description
  (root, and its example keys `dev-mode`/`first-run-complete`) contradicts the actual implementation — those
  two keys are in fact canonical `L:` keys by deliberate design (a documented fix for a prior split-brain
  bug); trusting the doc's stale description risks reintroducing the exact bug it was fixed to prevent.
- **M14 — Goal system has no project-scoping, and its only writer (`goal set`) is never called by anything.**
  *(round 2)* Even once C12 is fixed, phase-entry guidance can't be project-specific — the goal-record schema
  has no project field, and `workspace/memory/goals.yml` (what `goal set/get` would read/write) doesn't exist
  on disk anywhere.
- **M15 — `library-dev-new.md` creates an `articles/` drop folder that `library-dev-ingest.md` never scans.**
  *(round 2)* Ingest only reads an arbitrary externally-supplied `--folder` path, never the folder the tool
  itself created and documented for this exact purpose.

---

## LOW

- `code-dev-init.md`'s HELP still claims `code-dev new` routes here (stale after the v1→v4 routing fix).
- 7 files have stale `FAIL()` program-name self-attribution left over from an incomplete verb-rename (cosmetic only).
- `code-dev.md`'s skip-guard menu call omits the optional `--downstream` arg (weaker force-skip warning UX).
- hr-team: empty-task `QUERY(user)` response is discarded, falling into a confusing double-prompt.
- hr-team: `session-budget` is an undefined term in the convener's refusal gate (vestigial duplicate check).
- hr-team: `provenance-audit` subcommand is documented as reachable but the router doesn't recognize it.
- hr-team: HELP tier table states a range that doesn't match the fixed implementation.
- hr-team: `--context`/`--persona` flags missing from the top usage line.
- `workflow-edit.md`'s "edit synapses" option has no implementation — just a placeholder comment.
- `workflow-new.md` references an undefined `ALL-PROGRAMS` enumeration.
- `workflow-explain.md` is the only TOOL() call site using Python f-string syntax instead of the codebase convention.
- `self-care`/`axon-io-lint`/`emit-listener-lint` liveness-allow claims couldn't be independently confirmed.
- `deprecation-log`'s own liveness detector can't see its own cron wiring (blind spot in its own tooling).
- `discover.md` runs a full dependency scan whose result is computed and then never read/surfaced. *(round 2)*
- `glossary.md`'s frontmatter has a literal unresolved template placeholder (cosmetic, not runtime-enforced). *(round 2)*
- `token-bench`/`token-bench-compare` — menu-advertised, real tool with tests, but zero production callers anywhere
  except the menu line itself; a 4th dead-tool candidate alongside M9, not yet independently confirmed genuinely dead. *(round 2)*

---

## Explicitly verified CLEAN (no defect found — listed so nobody re-investigates these)
- `axon-audit`'s own EXEC()/TOOL() reference-resolution checks: legitimately passing, 37/39 OK — but this only
  checks forward-resolution, not reachability, which is why nearly everything above slipped through it.
- All 6 shipped workflow YAMLs pass JSON-schema validation with 0 errors (structurally valid; bugs above are semantic/runtime).
- `workflow list`/`workflow explain` tool-count matches the live tool exactly — no drift.
- Git hooks are correctly installed and live — not a "declared but not installed" gap.
- Compiler templates, all 3 harness contracts: present and internally consistent.
- 22 tools CI/crucible-wired, 4 hook-wired, 2 cron-wired, 15 tool-to-tool wired — only 3 tools (M9) genuinely dead of the original 62 candidates.
- hr-team's core `TOOL(hr-team, <subcommand>)` call sites, and code-dev's TOOL()-to-registry cross-check: all correctly wired.
- `dispatch.py`'s CLI and preference-reading (`dispatch-confidence`/`dispatch-fallback` auto-tune) are genuinely, mechanically live — NOT aspirational, unlike orchestrator's use of it (S2).
- `dispatch_index.py` freshness/self-healing (auto-rebuild on drift) is real and working; 172/172 entries currently in sync with source.
- R9 (`axon/`-write dev-mode gate) is genuinely, mechanically enforced via a live PreToolUse hook — this specific claim is real (the gap is destructive-ops/kernel-floor claims layered on top, see S1).
- Every `R_*` rule ID referenced in KERNEL-SLIM.md has a real backing file in `tools/rules/`; `verify.py` invokes exactly what it declares — no phantom rules found.
- Priority ordering + FIFO tie-break and file locking in the queue system are genuinely implemented as documented (only preemption/deps/starvation/clear-semantics are broken — see C10).
- Study/pr/log/audit phase-model emits (as opposed to plan-mode, M11) all match what their programs actually write.
- library-dev's router itself has no "family umbrella" analog to code-dev's C7 (simpler, flat single-level dispatch) — and none of its 8 program files are unreachable due to being un-listed.
- 27 of the 39 previously-uninvestigated orphan-list candidates (`authoring-guide`, `config`, `explain`, `faq`, `help`, `versions`, etc.) are confirmed reachable and working correctly.

---

## Known residual gaps — flagged but not yet independently audited
`workspace/programs/menu.md` itself (409 lines, the single most user-facing file in the repo) was never
audited in either round. Also unaudited as standalone surfaces: `board`, `loop-contract`, `constraints`,
`axon-docs-gen`, `lint-paths`/`lint-path-vars`, `program-tool-conformance` (ironic — it's the QA tool that
would catch several bugs above), `dispatch-stats`, `find-program`, `list-tools`, `undo`, `auto_audit.py`,
`workspace-backup.md`, `my-axon-init.md`, `status.md`/`stats.md` (the two dashboard commands menu.md itself
repeatedly tells users to run), `todo`. None of these are claimed broken — they're explicitly unknown, listed
per the "no silent caps" principle rather than silently omitted.

---

## Cross-cutting patterns (useful for planning the fix PRs)
1. **"Two-word subcommand" documentation vs "single-token router" reality** (C6, C7, M7, M8) — worth a
   router-architecture fix (two-token cmd parsing) rather than per-file patches.
2. **Inline EXEC args silently don't propagate** (H1) — worth a lint rule.
3. **Predicate/tool naming convention drift between workflow-YAML authors and the Python runtime** (C1, C4,
   C8) — no schema/lint currently catches this; even `check-stale` (H5) wouldn't catch the tool/program confusion.
4. **`cron seed-defaults` drift is bidirectional and unguarded** (H7, H13, H14).
5. **"ALIAS stub, removed next release" is not actually being removed** (H10).
6. **Doc/registry mirrors silently rot with no completeness test** (M6, and several stale-HELP-text items).
7. **"Coded but never wired into the one call site that matters" is the single most common defect shape in
   this codebase** — appears in governance (S1: autonomous_mode.authorized(), aegis_policy resolver), the
   orchestrator (S2: dispatch.py --top, the fire-step EXEC), hr-team (C2: write_audit_bundle), the goal system
   (C12: goal set, the envelope bug), and cron (H7). A capability being *implemented and unit-tested* is
   never sufficient evidence it's *live* in this codebase — always trace the actual production call graph.
8. **Memory/queue/goal subsystems have real documentation for behavior that has literal zero backing code**
   (C10 scheduler preemption, most of SCHEDULER.md; C9's L:-scope split-brain) — worth a documentation-honesty
   pass alongside the functional fixes, so KERNEL-SLIM.md stops overselling what's actually enforced.

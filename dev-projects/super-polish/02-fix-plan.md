# super-polish — FIX PLAN (from MEGA sweep, 65 confirmed bugs)

> critical:10 high:38 medium:16 low:1 · 49 flagship · grouped into 36 fix-PRs by file, severity-first.
> Bootstrap rule: code-dev's own broken commands (pr sync C4 / undo C3,C8 / dag merge,split C2,C7) are AVOIDED while driving until their PR lands.

## PR-1  [CRITICAL]  `tools/dag.py`  (9 bugs)
- **[critical]** merge and fold-in silently create cycles — the cycle guard is bypassed by every edge-rewiring op
    - line 231-251 (merge_nodes), 278-288 (fold_in) · _cd-plan-dag_
    - fix: After mutation in merge_nodes/fold_in (and in cmd_merge/cmd_fold_in before saving) call detect_cycle(dag); if it returns non-None, raise/return CYCLE_DETECTED and do NOT write — mirror the add_edge guard.
- **[critical]** split_node manufactures edges pointing to/from the deleted source node when that node carries a self-dependency, corrupting DAG.json and crashing render with KeyError
    - line 266-275 · _gap:code-dev_
    - fix: In split_node, when re-adding duplicated edges skip the source's self-references and self-loops: build incoming/outgoing excluding edges where the opposite endpoint is node_id (e.g. `incoming = [e for e in edges if e['to']==node_id and e['f
- **[high]** critical_path() raises KeyError on a dangling edge, so render and every mutation crash on a DAG that verify is meant to flag
    - line 325-329 (critical_path) · _cd-plan-dag_
    - fix: In critical_path add the same endpoint guard detect_cycle uses: `if e.get('kind','depends')!='depends' or e['from'] not in indeg or e['to'] not in indeg: continue` before touching adj/indeg.
- **[high]** cmd_add_edge cycle handling is dead code — a cycle-closing edge crashes the CLI with a traceback instead of the documented return 3 / {ok:false}
    - line 606-616 (cmd_add_edge), depends on add_edge raising at 133-1 · _cd-plan-dag_
    - fix: Wrap the add_edge call in try/except ValueError in cmd_add_edge and emit the JSON error + return 3 there (and delete the now-redundant post-call detect_cycle block), or have add_edge return a status instead of raising.
- **[high]** cmd_split persists the mutated graph to disk BEFORE rendering and has no post-mutation cycle/dangling guard, turning the render crash into permanent, irrecoverable DAG.json corruption
    - line 660-667 (cmd_split) + 590-594 (_save_and_render) · _gap:code-dev_
    - fix: In _save_and_render, render BEFORE the atomic write (or render to a temp string first) so a render failure aborts the commit; and/or add a detect_cycle/dangling-edge guard in cmd_split (and cmd_merge/cmd_fold_in) mirroring cmd_add_edge: aft
- **[high]** _save_and_render persists the mutated DAG (atomic os.replace) BEFORE render_md runs, so a render crash leaves a durably-corrupt DAG.json on disk
    - line 590-594 · _gap:code-dev_
    - fix: Render to a temp/in-memory string and validate BEFORE committing the JSON: in _save_and_render, build the md text from the in-memory `dag` (not by re-reading), and only call _atomic_write for DAG.json after render succeeds — i.e. swap the o
- **[high]** critical_path crashes with KeyError on any dangling edge because it omits the node-membership guard that detect_cycle has
    - line 325-329 (and 336) · _gap:code-dev_
    - fix: Add the same membership guard to the edge loop: `for e in dag.get('edges', []): if e.get('kind','depends') != 'depends': continue; if e['from'] in indeg and e['to'] in indeg: adj[e['from']].append(e['to']); indeg[e['to']] += 1`. This makes 
- **[medium]** code-dev-plan auto-emit: build-from-prs lets a circular PR-dep crash the CLI; program expects a WARN, gets an uncaught exception after partial writes
    - line 619-624 (cmd_build_from_prs), build_from_prs add_edge at 162 · _cd-plan-dag_
    - fix: In cmd_build_from_prs (or build_from_prs) catch the cycle, skip the offending edge or abort cleanly, and print {"ok": false, "code": "CYCLE_DETECTED", ...} with a non-zero-but-handled code so the program's WARN branch fires.
- **[medium]** merge_nodes / split_node / fold_in mutate edges with no cycle or dangling guard, so they can persist a cyclic or dangling DAG that bypasses CYCLE_DETECTED
    - line 231-289 (merge_nodes 242-250, split_node 266-275, fold_in 28 · _gap:code-dev_
    - fix: After mutating edges in merge_nodes/split_node/fold_in (or once, centrally, in _save_and_render before the write), run detect_cycle(dag) and verify-for-dangling; if either fails, raise/return an error and do NOT write. Cleanest: have _save_

## PR-2  [CRITICAL]  `workspace/programs/code-dev.md`  (7 bugs)
- **[critical]** `code-dev new` dead-routes to the v1 scaffolder; the v4 scaffolder (code-dev-new) is unreachable
    - line 76 and 92 · _cd-router-dispatch_
    - fix: Delete the line 76 `new → code-dev-init` route (init is the legacy v1 scaffolder) so `new` falls through to line 92 `code-dev-new`; or pick one canonical scaffolder and route both consistently.
- **[high]** `code-dev thaw` runs the FREEZE branch — mode flag never set on the direct thaw route
    - line 118-119 (also code-dev-safety.md:38-39) · _cd-router-dispatch_
    - fix: On the thaw routes set the mode first: `IF cmd ≡ "thaw" → STORE(W:code-dev-freeze-mode, "thaw") → EXEC(code-dev-safety-freeze)` (and likewise in code-dev-safety.md). Or route freeze/thaw through code-dev-hold, which already sets the flag.
- **[high]** `code-dev done` / `code-dev skip` reference an unbound `meta` variable for the phase fallback
    - line 129 and 152 · _cd-router-dispatch_
    - fix: Read meta before the fallback: `done-phase ← RETRIEVE(W:code-dev-done-phase) | READ("{W:myaxon-dev-projects}/{project}/_meta.md").phase` (and identically for skip-phase), or hoist a single `meta ← READ(...)` into LOAD CONTEXT.
- **[high]** `code-dev back` commits stale-downstream then ignores a failing `advance`, leaving a half-mutated + misreported phase manifest
    - line code-dev.md 141-147 · _cd-phase-engine_
    - fix: In the back route, do `advance` first and bind `res ← TOOL(phase-model, advance, ...)`; only call stale-downstream and print the banner when `res.ok ≡ true`, else FAIL with res.error (mirror the done route).
- **[high]** `code-dev phase list` dead-routes to a non-existent program (the prescribed recovery action in 5 places)
    - line 96 · _gap:code-dev_
    - fix: Add a real `list` handler before/at the phase route, e.g. `IF cmd ≡ "phase" AND W:code-dev-phase-cmd ≡ "list" → EXEC(code-dev-phase-list)` and create code-dev-phase-list.md (enumerate phases/* dirs from phase-model/DAG). Minimal alternative
- **[medium]** Branch-registry count is always +1 (header row counted) — dashboard shows '1 branch tracked' for an empty registry
    - line 230 · _cd-router-dispatch_
    - fix: Exclude the header: filter out the row whose cells are the literal column names (e.g. skip lines matching the header text / the line immediately preceding the `|---` separator), or count data rows as `total_pipe_rows - 2` (header+separator)
- **[medium]** Any unknown `code-dev phase <typo>` interpolates into a non-existent program — silent dead route with no clean failure
    - line 96 · _gap:code-dev_
    - fix: Replace the interpolated EXEC with an explicit dispatch over a known set and a trailing guard: `... ELSE → FAIL(code-dev, problem="Unknown phase subcommand '{phase-sub}'", fix="Use: code-dev phase new | start | list", suggested_next="code-d

## PR-3  [CRITICAL]  `tools/workflow_dag.py`  (3 bugs)
- **[critical]** dag validate flags ALL cycles as defects (ok=false) — over-rejects the flagship's own canonical workflows; contradicts run.md's documented legal back-edges
    - line 234-263 · _wf-dag_
    - fix: Demote cycles to informational (like empty_terminals): drop `base["summary"]["cycles"]==0` from the ok computation, or only treat a cycle as a defect when no node on the loop has a guarded/terminal exit (a true unbounded loop).
- **[high]** `start:` is ignored by run and simulate (both use synapses[0]); validate roots reachability/cycle analysis at `start:` — a schema-valid start != synapses[0] makes validate analyze a graph nobody executes
    - line 175-184, 223 · _wf-dag_
    - fix: Pick ONE entry contract: change run.md/simulate.md to start at the synapse whose id == wf.start (falling back to synapses[0]), so validate, simulate and run all root at the same node.
- **[medium]** Non-list `on-complete` silently bypasses dangling-next AND reachability checks — dag returns ok=true on a graph with a dangling reference
    - line 188-191, 79-86 · _wf-dag_
    - fix: When on-complete is present but not a list, emit a schema-error defect instead of `continue`; have _reachable_from likewise guard `isinstance(rules, list)` and flag non-list as a defect rather than silently treating it as terminal.

## PR-4  [CRITICAL]  `workspace/programs/code-dev-pr-sync.md`  (2 bugs)
- **[critical]** `pr sync` flattens and destroys the entire project `_meta.md` (state corruption + PR rows vanish)
    - line pr-sync.md:38-39 · _cd-pr_
    - fix: Do not route _meta.md writes through prefs.set_pref (it is preferences-only). Add a dedicated meta-writer that updates the `pr-N:` block in place (e.g. a `pr_meta set` tool), or store ci-status as a flat `pr-N-ci-status:` top-level key writ
- **[medium]** pr-sync output/EMIT dereference fields absent on skip/timeout/error paths
    - line pr-sync.md:40-41 · _cd-pr_
    - fix: Guard on result-json.ok before printing/emitting: `IF result-json.ok ≠ true → report skipped/failed reason and DONE` else print the counts.

## PR-5  [CRITICAL]  `workspace/programs/code-dev-state-undo.md`  (1 bug)
- **[critical]** undo of a journaled decision corrupts _decisions.md (op=append but snapshot field is a file PATH, not a byte size)
    - line undo: 76-80 · _cd-state_
    - fix: In code-dev-journal-decision line 68 change the op from `append` to `replace` (it stores a full snapshot path); OR make undo's append branch detect non-numeric snap-path and route to file-restore.

## PR-6  [CRITICAL]  `tools/hooks/enforce_pretooluse.py`  (1 bug)
- **[critical]** Write-time hook cannot find the project's _dont-do.md when editing codebase source (walk-up never crosses into my-axon/dev-projects)
    - line 54-64 (_governing_dont_do walk-up) and 67-90 (dont_do_violat · _cd-dont-do-enforce_
    - fix: Resolve the governing _dont-do from the ACTIVE code-dev project (read W:code-dev-project → {proj-dir}/phases/{phase}/_dont-do.md + seeds) whenever the target is inside that project's codebase, instead of relying on a filesystem-ancestor wal

## PR-7  [CRITICAL]  `workspace/programs/code-dev-journal-decision.md`  (1 bug)
- **[critical]** journal-decision writes op=append with a snapshot-DIR path, but undo's append branch truncates to that field as a byte size — undo corrupts/errors instead of restoring
    - line 67-70 (producer) · _cd-journal-knowledge_
    - fix: In journal-decision record op 'replace' (not 'append') so undo COPY-FILEs the snapshot back: APPEND(_actions.log, "{ts.iso} {action-id} replace {decisions-path} {snap-dir}/_decisions.md\n").

## PR-8  [CRITICAL]  `workspace/programs/workflow-new.md`  (1 bug)
- **[critical]** workflow-new always emits a dangling on-complete.next on the LAST synapse, so PHASE-E validation rejects every workflow it builds
    - line 104 (consumed at 133-137) · _wf-authoring_
    - fix: Don't pre-wire next on append; after the loop set each synapse's on-complete to [{next:'s{i+1}'}] for i<N and [] (terminal) for the last, e.g. mark sN.on-complete = [] before building the draft.

## PR-9  [CRITICAL]  `tools/crucible.py`  (1 bug)
- **[critical]** R_MEMORY_RESPECTED is dead in the crucible changeset gate (declared BLOCK + manifest-locked into the gate, but always no-ops because run_changeset never supplies program_text)
    - line 152-160 (ctx build + rule loop) · _broad-gate-dispatch_
    - fix: In run_changeset, for each changed program/tool path read its text and run r_memory_respected per-file with ctx including program_text/program_path (mirroring how lint_summary.py:91 and neuron_audit.py:44 build the ctx), rather than passing

## PR-10  [HIGH]  `workspace/programs/code-dev-journal-log.md`  (3 bugs)
- **[high]** undo of a log entry is a silent no-op — pre-append size is captured AFTER the append
    - line journal-log: 204 then 207-209 · _cd-state_
    - fix: Capture pre-size BEFORE the append: move `pre-size ← IF FILE-EXISTS(log-file) → FILE-SIZE(log-file) | 0` and the _actions.log APPEND above line 204 (compute size, then append entry).
- **[high]** journal-log undo snapshot records pre-size AFTER the append already ran — TRUNCATE becomes a no-op, so undo silently fails to remove the log entry
    - line 204 then 207-209 · _cd-journal-knowledge_
    - fix: Move the size capture before the append: compute pre-size ← IF FILE-EXISTS(log-file) → FILE-SIZE(log-file) | 0 ABOVE line 204, then APPEND, then record pre-size.
- **[medium]** journal-log 'Open PRs' filter keys on a 'status: complete' marker that log entries never contain — completed PRs are never filtered out
    - line 108-109 (vs entry format 179-190) · _cd-journal-knowledge_
    - fix: Either have the writer stamp a completion marker (e.g. write 'status: complete' when the user marks a PR done) or change line 108 to derive done-PRs from an existing source (e.g. merged PRs in _events.log 'pr-merged' rows).

## PR-11  [HIGH]  `workspace/programs/workflow-run.md`  (3 bugs)
- **[high]** workflow-run --dry is documented as "same as workflow-simulate" but is completely unimplemented — a --dry run performs a full real, side-effecting mutating run
    - line 35 (doc) vs 89 (unconditional EXEC) · _gap:workflows_
    - fix: Implement the documented alias before the EXECUTE loop: after RESOLVE PATH, add `dry ← RETRIEVE(W:_workflow-run-dry) | ∅` and `IF dry ≠ ∅ → EXEC(workflow-simulate --path {path}) ; CLEAR(W:active-program) ; DONE(workflow-run)`. Recompile so 
- **[high]** workflow-run ignores wf.start and always begins at synapses[0]; edit can reorder/repoint start and the run silently executes from the wrong node
    - line 79 (start authored at workflow-new.md:127, schema line 85) · _wf-authoring_
    - fix: Set cursor from start: `cursor ← FIND(wf.synapses, id ≡ wf.start) | wf.synapses[0]` and FAIL if not found; equivalently have workflow-validate assert start ∈ synapse-ids.
- **[medium]** Pass-validate-fail-run: schema makes synapse `name` optional but run dispatches EXEC({cursor.name}) — a name-less synapse validates clean then dispatches a null program
    - line 89 · _wf-dag_
    - fix: Add a defect in workflow_dag.analyze() (and a semantic check in workflow-validate.md) for any synapse missing a non-empty `name`, OR make `name` required in the schema's synapse.required.

## PR-12  [HIGH]  `tools/cron.py`  (3 bugs)
- **[high]** Cron default job 'deprecation-log cron' fails every tick (--workspace placed before subcommand on a tool whose --workspace is subparser-local), trips the breaker, and permanently self-disables
    - line 172-190 (_build_job_cmd) + 427-429 (DEFAULTS)  · _broad-rest_
    - fix: Detect subparser-local --workspace tools (or just append --workspace at the END for CLI form, after the subcommand) — e.g. build [tool, *parts[1:], '--workspace', ws]; for the truly-global ones either placement works, for subparser-local on
- **[high]** Cron default job 'dispatch-stats weekly' invokes a non-existent action ('weekly'); the job has never run successfully and trips the breaker
    - line 411-413 (DEFAULTS axon-dispatch-stats) vs tools/dispatch_sta · _broad-rest_
    - fix: Change the default to a real action, e.g. 'dispatch-stats summary' (or 'savings') in cron.py:412.
- **[low]** cron breaker-status raises AttributeError when a job has disabled_reason set to JSON null
    - line 523 · _broad-rest_
    - fix: Use `(j.get("disabled_reason") or "").startswith("circuit-breaker")` on line 523.

## PR-13  [HIGH]  `tools/phase_ledger.py`  (2 bugs)
- **[high]** Ledger note containing a carriage return (or U+2028/U+2029/\f) silently drops the recorded phase row from the G-02 ledger
    - line 54-57 (_sanitize) and 82 (read_rows splitlines) · _cd-phase-engine_
    - fix: In `_sanitize`, normalize all line breaks: `re.sub(r'[\r\n  \x0b\x0c\x1c-\x1e]+', ' ', s)` (or `.replace('\r',' ')` at minimum) before the `|` replacement.
- **[medium]** phase-ledger `verify` has no session-boundary fallback: with no literal 'start' row it scans ALL history, so stale prior-run rows satisfy a new run's expected phases
    - line 152-169 (esp. 163-167) · _cd-phase-engine_
    - fix: Fall back to a real session boundary when no 'start' row exists (e.g. split on session id / boot marker, or treat absence of a start as 'no completed window' → fail), and stop documenting a session-boundary fallback that isn't implemented.

## PR-14  [HIGH]  `workspace/programs/code-dev-review-coverage.md`  (2 bugs)
- **[high]** Coverage gate false-PASSES on every committed PR (diffs working-tree-vs-HEAD, not branch-vs-base)
    - line 39-49 · _cd-review-safety_
    - fix: Compute base like the sibling programs and diff `{base}...HEAD`: `diff ← TOOL(shell, "git -C {codebase} diff --name-only {base}...HEAD")` where `base ← (READ _profile.md).base-branch | "master"`.
- **[high]** Coverage gate silently passes files with ZERO coverage (file absent from coverage JSON is skipped)
    - line 42-49 · _cd-review-safety_
    - fix: Treat a changed (non-test) file missing from `data` as fully uncovered: `ELSE: APPEND(uncovered, "{file}: (no coverage data — 0% instrumented)")` in an else branch of the `IF data.{file} ≠ ∅` check.

## PR-15  [HIGH]  `workspace/programs/code-dev-safety-preflight.md`  (2 bugs)
- **[high]** Preflight Gate 6 false-PASSES open reviewer objections when no PR is resolved (pr ≡ ∅)
    - line 44,107-109 · _cd-review-safety_
    - fix: Fail-closed when pr is unknown: `IF pr ≡ ∅ → results += [{id:6,status:"fail",msg:"PR unresolved — cannot verify objections"}]` before running the regex; otherwise keep the per-PR match.
- **[medium]** check-only mode never propagates: gate sub-programs run in FULL mode (writes + user prompts) and never set their *-result keys
    - line 74,92,117 · _cd-review-safety_
    - fix: Have callers set the W: key the callee actually reads before EXEC, e.g. `STORE(W:code-dev-self-review-mode,"check-only")` + `STORE(W:code-dev-pr-create,pr)` then `EXEC(code-dev-review-self)`; clear afterward. Apply for scope/self/tests/pref

## PR-16  [HIGH]  `tools/workflow_run.py`  (2 bugs)
- **[high]** advance-guard is structurally a no-op in fixed mode — it can never detect a skipped or out-of-order node
    - line workflow_run.py:47-63 (advance/next_allowed) · _wf-engine_
    - fix: Make advance() validate against run state, not just the static graph: pass the prior trajectory (or expected predecessor) and reject a transition whose `from` is not the actual last-recorded node, and verify the cursor at loop entry equals 
- **[medium]** promote round-trip is broken: run records cursor.id but promote treats node value as the synapse NAME, yielding non-executable drafts (and duplicate names on cyclic runs)
    - line workflow-run.md:90 vs 92 · _wf-engine_
    - fix: Record the synapse NAME in the trajectory (--node {cursor.name}) — or store both and have promote read step['name']; and de-duplicate by full set (reuse one synapse id per distinct node) so cycles don't fan out into duplicate-named linear s

## PR-17  [HIGH]  `workspace/programs/workflow-validate.md`  (2 bugs)
- **[high]** Validator never checks `start` references a real id, has no reachability/orphan check, and no cycle check — edit can orphan/strand nodes or delete the start target with validate still green
    - line 46-58 · _wf-authoring_
    - fix: In the semantic block add: IF payload.start NOT IN synapse-ids -> error; compute reachable set from start over on-complete.next and error/warn on unreachable ids; run the plan_dag Kahn cycle detector and error on cycles (per spec items 2,3)
- **[medium]** workflow-validate returns `errors` as a LIST but run/simulate/edit compare it to an integer (v.errors == 0 / v.errors > 0)
    - line 79 · _wf-dag_
    - fix: Have validate's DONE return a count alongside the list (e.g. error-count: COUNT(errors)) and change callers to test `v.ok ≡ false` or `v.error-count > 0`, not `v.errors`.

## PR-18  [HIGH]  `tools/_longterm.py`  (2 bugs)
- **[high]** Corrupted-but-valid-JSON rollback sidecar crashes every L: write (wedges dev-mode/halt-mode toggle)
    - line 65-72 · _broad-memory-io_
    - fix: After json.load, coerce non-list to []: `if not isinstance(history, list): history = []` (or widen the except to also reset on TypeError/AttributeError).
- **[high]** Canonical L: reader silently corrupts any value containing a 'value:' line — flips dev-mode/halt-mode
    - line 23-26 · _broad-memory-io_
    - fix: Drop the whole-file 'value:' scan; either return raw.strip() (writer is always bare form), or restrict the front-matter parse to the FIRST line only.

## PR-19  [HIGH]  `tools/phase_gate.py`  (1 bug)
- **[high]** `_is_stub` flags any header-only artifact as an empty stub, so the phase-gate false-positives on real header-outline plans/PR lists (hard block in enforce mode)
    - line 110-121 (specifically 117-120) · _cd-phase-engine_
    - fix: Only strip a single leading H1/title line (or count header lines as content); e.g. keep lines that are headers carrying text beyond the marker, or treat `body` as empty only when there are zero non-blank lines at all after dropping just the

## PR-20  [HIGH]  `workspace/programs/code-dev-safety-freeze.md`  (1 bug)
- **[high]** freeze → undo leaves project _meta.md stuck 'frozen' (only the phase _meta.md mutation is recorded in _actions.log)
    - line freeze: 54-61 (esp. single APPEND at 56-57) · _cd-state_
    - fix: Append a SECOND _actions.log entry for the project meta (`{action-id}b replace {proj-dir}/_meta.md {snap-dir}/proj_meta.md`), or make undo restore every snapshot recorded under one action-id.

## PR-21  [HIGH]  `workspace/programs/code-dev-state-resume.md`  (1 bug)
- **[high]** resume always drops reviewer state — reads reviewer-state.md from a wrong, non-existent nested path
    - line 115 (also 116-117, 182-186) · _cd-state_
    - fix: Change line 115 to `reviewer-path ← "{phase-dir}/reviewer-state.md"` (drop the `/03-prs/{current-pr}/` segment), matching every other program.

## PR-22  [HIGH]  `tools/pr_sync.py`  (1 bug)
- **[high]** `pr_sync` discards all CI results exactly when checks are pending or failing
    - line 15-21 (bail at 20-21), 26-35 (summary) · _cd-pr_
    - fix: Parse `r.stdout` first; only treat returncode as fatal when stdout is empty/unparseable. Tally from rows regardless of returncode (gh exit 8/1 means pending/fail, not tool error).

## PR-23  [HIGH]  `workspace/programs/code-dev-pr-drift.md`  (1 bug)
- **[high]** drift / export / pr-ready read the wrong spec filename (case + zero-pad mismatch); drift also crashes on the miss
    - line pr-drift.md:37 · _cd-pr_
    - fix: Use the create convention everywhere: spec path = `03-prs/PR-{zero-pad-3(pr-num)}.md`; in drift.md/export.md uppercase+pad the arg, in pr-ready.md drop the extra `pr-` prefix. Add an existence guard in pr_drift.drift() returning `{ok:False,

## PR-24  [HIGH]  `tools/pr_drift.py`  (1 bug)
- **[high]** drift detector has a near-100% false-negative rate (drift goes undetected)
    - line 39-48 (esp. 47) · _cd-pr_
    - fix: Require a stronger signal: match only on added (`^+`) lines, ignore stop-words and tokens <5 chars, and require a majority/anchored token (function/identifier with `_` or CamelCase) rather than any single common word; or flag items as 'weak

## PR-25  [HIGH]  `workspace/programs/code-dev-review-self.md`  (1 bug)
- **[high]** Self-review gate rubber-stamps: acceptance criteria matched against file NAMES, not diff content
    - line 55,59-64 · _cd-review-safety_
    - fix: Match against diff content, not names: add `diff-content ← TOOL(shell, "git ... diff {base}...HEAD")` and test `IF diff-content CONTAINS k`; keep filename match only as a weak secondary signal.

## PR-26  [HIGH]  `workspace/programs/code-dev-dont-do.md`  (1 bug)
- **[high]** promote drops the match: token — converts an enforceable prohibition into a prose-only one in seeds (and cascaded phases)
    - line 99 (promote APPEND) and 108-109 (cascade APPEND) · _cd-dont-do-enforce_
    - fix: On promote/cascade, carry the source bullet's `match:`/`review:` line too: APPEND `"- {arg} _(promoted...)_\n  match: {match-tok}\n"` (look the token up from the source bullet).

## PR-27  [HIGH]  `workspace/programs/code-dev-phase-start.md`  (1 bug)
- **[high]** Seeding a new phase from prose-only seeds makes Gate 3 fail-closed BLOCK on a freshly-started phase
    - line code-dev-phase-start.md:48-52 (copies seed-content verbatim  · _cd-dont-do-enforce_
    - fix: Either preserve match:/review: lines through promote→seed (Bug 3) so seeded entries stay enforceable, or have Gate 3 treat newly-seeded-but-untokenized entries as a WARN until first edit instead of a hard BLOCK.

## PR-28  [HIGH]  `tools/rules/r_workflow_node_order.py`  (1 bug)
- **[high]** R_WORKFLOW_NODE_ORDER status check is case-sensitive — capitalized statuses (Done/DONE/Active) bypass the gate entirely, even in BLOCK mode
    - line 58 (st in ("active", "done")) · _wf-engine_
    - fix: Normalize before comparison: st = str(p.get('status','')).lower() and compare deps with str(byid.get(d,{}).get('status','')).lower() != 'done'.

## PR-29  [HIGH]  `workspace/programs/workflow-simulate.md`  (1 bug)
- **[high]** simulate's predicted path diverges from run on any cyclic workflow — simulate breaks on first revisit, run loops to the step-count bound; predicted step count and path are a lie
    - line 72-74 · _wf-dag_
    - fix: Make simulate mirror run's termination exactly: drop the revisit-BREAK and instead evaluate the rejection-criterion each iteration (it already builds ctx with state.steps at line 62), bounding the walk identically to run; keep max-steps onl

## PR-30  [HIGH]  `workspace/programs/code-dev-replay.md`  (1 bug)
- **[high]** replay <PR-N>: the '| rounds' fallback makes a missing-PR query display a DIFFERENT PR's reviewer rounds (wrong cross-reference)
    - line 43-45 · _cd-journal-knowledge_
    - fix: Drop the '| rounds' fallback (use pr-rounds ← FILTER(rounds, contains=pr)) and accumulate across phases (found ← found + {...}) instead of overwriting with '='.

## PR-31  [HIGH]  `tools/verify.py`  (1 bug)
- **[high]** verify status misreports enforcement posture: claims runtime WARN fails the gate under strict halt-mode, but the gate (_run) ignores halt-mode and passes all WARNs
    - line gate: 163 (passed = not blocks) · _broad-gate-dispatch_
    - fix: Make status reflect reality: set `warn_is_block = False` (WARN never blocks post-F15/F16) and rewrite the note, OR conversely re-introduce halt-mode escalation in _run if blocking-on-strict is the intended contract — pick one and make gate 

## PR-32  [HIGH]  `tools/dispatch.py`  (1 bug)
- **[high]** Dispatch prefer-compiled bypasses the confidence threshold on pure noise — any best_score > 0 dispatches, so a single incidental shared word routes to a near-random program
    - line 239 (effective_match = best_score >= threshold or (prefer_co · _broad-gate-dispatch_
    - fix: Gate prefer-compiled on a meaningful floor, e.g. `best_score >= max(threshold*K, MIN_FLOOR)` or only let prefer-compiled relax the threshold by a bounded delta — never accept bare `> 0`.

## PR-33  [MEDIUM]  `tools/plan_dag.py`  (1 bug)
- **[medium]** plan_dag.py reports a phantom cycle when two PR files normalize to the same id
    - line 49-72 (topo_sort), id from 35 (path.stem.lower()) · _cd-plan-dag_
    - fix: Dedup/detect collisions when building nodes (e.g. raise or merge on duplicate id), and compute the cycle/visited count against the distinct id set (len(by_id)) rather than len(nodes).

## PR-34  [MEDIUM]  `workspace/programs/code-dev-state-save.md`  (1 bug)
- **[medium]** rewind restores _meta + phases but NOT project-root state (04-log.md, 05-branches.md, _actions.log) → inconsistent, dangling-reference state after restore
    - line create: 80-81 · _cd-state_
    - fix: Snapshot and restore 04-log.md, 05-branches.md, and _actions.log alongside _meta.md (and snapshot 04-log.md before the rewind append), or explicitly document/scope the snapshot and warn on restore that project-root logs are not reverted.

## PR-35  [MEDIUM]  `workspace/programs/code-dev-pr-create.md`  (1 bug)
- **[medium]** pr-create never advances PR status in 02-prs.md (REPLACE is a guaranteed no-op)
    - line 308-310 · _cd-pr_
    - fix: Match the actual line the planner writes and disambiguate by section: replace within the `## PR-003 — …` block, searching for `- **Status:** not-started` (no arrow), or key the replace on the per-PR Spec line.

## PR-36  [MEDIUM]  `tools/accountability.py`  (1 bug)
- **[medium]** accountability _prune keeps the OLDEST-reconciled entries and silently drops the most-recently-reconciled ones — opposite of its documented contract
    - line 57-61 (_prune) · _broad-rest_
    - fix: Sort done by its reconciled_at timestamp before slicing: done = sorted(done, key=lambda e: e.get('reconciled_at',''))[-RECONCILED_KEEP:].

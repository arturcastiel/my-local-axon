# AXON Bug-Hunt 3 — Consolidated Findings
project: axonbugfree3
codebase: /home/arturcastiel/projects/new-axon/axon
date: 2026-07-13
method: 4 parallel read-only verify-against-source sweeps (A: program-layer post-07-07 diff · B: Python-tools
        post-07-07 diff · C: live boot-anomaly root-cause · D: never-audited surfaces) + main-loop adversarial
        reconfirmation of the sharpest source-only claims (A-1, B-2, the zero-writer key class, C-4/C-5 — all
        reconfirmed at source + live probe). Full per-finding detail with quoted probes: shadow/sweep-{A,B,C,D}*.md.
dedupe: bugfix01 + bugfix02 ledgers (all fixed 2026-07-07) excluded; regressions/incomplete fixes flagged.
merges: A-9+B-1 → F-H1 · A-7+D-13 → F-M7 · A-6 verdict corrected via D's counter-evidence → F-M6 (two-writer split).
second pass: sweep D ran a self-re-verification (shadow/sweep-D-final-reverified.md) — 2 first-pass findings
RETRACTED (F-H16, F-M14 — marked in place, not deleted), F-C2 re-graded HIGH with corrected mechanism,
2 findings promoted to MEDIUM (F-M16, F-M17), 2 new below-cap items; first-pass-only unre-verified leads
quarantined in their own subsection below.
tally: 1 CRITICAL · 19 HIGH · 16 MEDIUM · 9 LOW ranked (+2 retracted, kept for the record) + ~8 below-cap
one-liners + 4 unverified leads. No fixes applied.

---

## THE HEADLINE (cross-cutting root patterns, run 3)
1. **The bugfix02 headline class did not die — it moved into the NEWEST code.** Post-07-07 families (codemap,
   graphify, obsidian, doctrine, state-surface) re-introduce the exact reader/writer defects the last run
   fixed elsewhere: tokenizer-key off-by-one (F-H4), zero-writer dispatch keys (F-H5, F-M9), bare-scalar binds
   of JSON envelopes (F-H6), phantom output fields on the fast path (F-M8). New code is not being checked
   against the existing defect taxonomy at authoring time.
2. **Incomplete fixes / fix-shaped regressions.** Four bugfix01/02 repairs fixed one surface of a multi-surface
   defect: session-summary (F-H7), workspace-backup skip (F-M10), resume stale-pointer guard (F-M11),
   hr-team empty-task (F-M14). One 2026-07-07 mechanical sweep commit (827598d) actively broke the hr-team
   selector (F-H15).
3. **Kernel-declared interfaces drifting from tool reality.** The kernel itself calls a deleted drift interface
   (F-H10), passes an undefined `{W:ws-path}` to prompt-log (F-H9), and boots chat-resume against an index no
   producer writes (F-H13). These are axon/-floor findings — human-only fixes.
4. **Refusal/guard paths that mutate or fail open.** `code-dev complete`'s refusal renderer mutates the phase
   ledger (F-H2); doctrine preflight passes unblessed routines (F-H3); hr-team refusals don't stop the router
   and can seal a false audit (F-C2).

---

## CRITICAL

**F-C1 (D-1) | workflow name-resolution is single-root — all 4 reference workflows unrunnable by name; `multiple-code-dev` nested dispatch dies at node 2**
workflow-run.md:79-80 (+validate:37, simulate:40, edit:42) resolve `workspace/workflows/{name}.yml` only; tools/workflow_run.py:456-484 + :335-342 resolve BOTH roots incl. `workspace/domains/*/workflows/`. `workflow run code-dev` FAILs; multiple-code-dev.yml s2 `sub-workflow: code-dev` re-enters the same resolver and dies — and the parent's advance guard then raises SubWorkflowNotCompletedError, so the flagship loop can never pass s2. Only one (manual-demo) trajectory has ever recorded. CONFIRMED (re-verified pass; file absence + list probe).

**F-C2 (D-2) | ⬇ RE-GRADED HIGH on re-verification | hr-team: selector REFUSALs don't stop the pipeline — a refused task (incl. safety-violation) can convene and SEAL a council on stale seats**
Corrected mechanism (final pass): refusal paths (selector.md:63,70,77,105,125 — clarify/safety/circular/no-matches/catalog-incomplete) exit DONE WITHOUT writing W:hr-team-selector-result and with no abort signal; hr-team.md:112-114 chains unconditionally and seals W:deliberator-verdict (:121-125). First-run refusal → convener FAILs on the missing key with a misleading "Run: hr-team-selector first" fix. Refusal AFTER a successful council in-session → the STALE selector-result (previous task's seats/protocol/tier) drives a full sealed council on the NEW task. Zero CLEARs of the pipeline keys repo-wide. SOURCE-VERIFIED (re-verified pass).

## HIGH

**F-H1 (B-1 + A-9) | graphify-bridge `impact` is doubly broken: wrong key (`nodes` vs `node_ids`) → always-empty result, and the `--symbol` form (the only call-site!) raises uncaught KeyError**
graphify_bridge.py:410/:415 vs :252; :436 `kw["file"]`; codemap-relations.md:74 calls `--symbol` and never renders the result. CONFIRMED (probes: empty impact on valid graph; KeyError traceback).

**F-H2 (A-1) | `code-dev complete` refusal path silently mutates the phase ledger** — code-dev.md:210-212 calls TOOL(phase-model, done) per blocking phase to *render a reason*; phase_model.py:251-270 `done()` is a mutator (status="done" + save on success; success emits no `reason`). A refusal that advances state defeats the 92e3912 gate. RECONFIRMED at source by main loop.

**F-H3 (B-2) | doctrine routine preflight integrity gate fails OPEN on unblessed/uncovered routines** — doctrine_preflight.py:129 `ok = not in tampered` (unblessed only affects the cosmetic note) vs program_integrity.py:90 `ok = not tampered and not missing and not unblessed` + its own M6 comment ("attackers ADD a poisoned routine"). `validated=all(ok)` → injected routine can validate. RECONFIRMED at source. Security-relevant.

**F-H4 (A-2) | codemap leaf programs read the SUBCOMMAND as their argument + `W:_opt-repo`/`W:codemap-question` have no writer** — codemap-new.md:38-39, codemap-ask.md:41, codemap-relations.md:45 read W:_arg1; via router codemap.md:34 _arg1 IS the subcommand (tokenizer: axon/COMMANDS.md:24 writes only _cmd/_arg1/_arg2). Zero-writer greps RECONFIRMED. Golden paths bind slug="new", question="ask", target="relations"; --repo dropped.

**F-H5 (A-3) | codemap-shadow's scan/refresh dispatch key has no writer — the codemap-study workflow's "shadow the source" step is a stats no-op** — codemap-shadow.md:41-42 `W:codemap-shadow-cmd | "stats"` (single occurrence repo-wide, RECONFIRMED); SCAN/REFRESH (:73-178) unreachable; if reached, sub-arg would be the token "scan" (wrong-path `{repo}/scan`). Menu-advertised onboarding chain (menu.md:298) completes with zero files shadowed.

**F-H6 (A-5) | `TOOL(meta, get)` envelope bound as bare scalar across code-dev-graphify + all 7 codemap call-sites** — meta.py:30-39 emits `{field,value,found}`; readers compare to ""/"(none)" and interpolate the dict as a repo path. Guard can never fire. Same class: codemap-new.md:87,95-96 + codemap-shadow.md:43-45 bind the shell envelope bare. CONFIRMED (envelope probed).

**F-H7 (A-4) | session-summary reads the wrong log tree — bugfix02 C3's symptom persists (incomplete fix)** — session-summary.md:46 reads {W:myaxon-log} (newest file 2026-07-07, different level format) while tools/log.py:18,25 writes workspace/log/entries/ (fresh today); digest patterns match the tree it does NOT read. handoff.md:53 has the correct fallback. CONFIRMED.

**F-H8 (C-1) | kernel prompt-log band passes `--workspace {W:ws-path}` — a key with NO writer — so per-turn prompt capture fail-closed skips DESPITE recorded consent** — axon/KERNEL-SLIM.md:112-118; consent true only at canonical workspace/memory/longterm/. Zero-writer grep RECONFIRMED. Root cause of the boot split-brain (snapshot reads canonical, kernel-shaped record calls don't). [kernel — human-only]

**F-H9 (C-4) | BOOT.md drift auto-init guard tests FILE-EXISTS, not staleness — contradicts its own comment; init can fire at most once per trace lifetime** — axon/BOOT.md:186-188 vs :184-185 ("stale trace → next boot re-inits"). RECONFIRMED verbatim. [kernel — human-only]

**F-H10 (C-5) | kernel + output-layer invoke the DELETED legacy drift interface — the entire per-turn drift-signal band is dead** — KERNEL-SLIM.md:192/292/345/380 `drift record --type … --detail …`; live tool accepts only `--tool` (RECONFIRMED: argparse error live). Interface belonged to workspace/tools/drift.py, deleted b102d2b 2026-07-07. Also starves igap's fallback-exec trigger. Combined with F-H9 + 2h TTL + daily cron → the drift-unknown → auto-improve breaker deadlock observed at boot (full chain: shadow/sweep-C §Anomaly-2). [kernel — human-only]

**F-H11 (D-2) | all 4 workflow-validate callers guard on `v.errors` (a string LIST) — validate's own contract note says that comparison never matches** — workflow-run.md:117-118, simulate:43-44, edit:100-102, new:180 vs workflow-validate.md:119-122 (`error-count`/`ok` are the real gates). Producer fixed, consumers never migrated.

**F-H12 (D-3) | orchestrator decide() + sideband thresholds never recalibrated after the absolute-score fix — autonomy ladder decorative** — orchestrator.md:108-118 gates at 0.8/0.7/0.85/0.6 vs real score scale ~0.10-0.20 (probed 0.118 top; anticipate.py:82-86 recalibrated its own margin to 0.05). Modes 2-7 can never fire; 8-10 fire at ANY score; sideband (0.6) never emits.

**F-H13 (D-5) | chat-index split-brain: boot chat-resume reads workspace/chats/INDEX.md (index.py default); chat programs write my-axon/chats/INDEX.md — resume permanently blind** — BOOT.md:108-109 + KERNEL-SLIM.md:662 vs axon/programs/new-chat.md:57-59 et al. Probe: count 0. Adjacent: index.py:77-83 `append --type plan` no-ops but prints `{"appended": true}`. [kernel-adjacent]

**F-H14 (D-4) | pattern.py crashes on the SHIPPED preferences file (inline comment captured into int())** — pattern.py:128 + read_pref vs workspace/preferences/smart-dispatch.md:6. All 3 subcommands die before the action branch; orchestrator's pattern signal permanently `{}`. CONFIRMED (traceback).

**F-H15 (D-9) | hr-team selector: QUERY(user) fallbacks spliced INSIDE the protocol-override IF conditions — the `--protocol` contract broken in both directions** — selector.md:205-211 (duplicated sub-expression, evaluated up to 3×; first-pass blame pinned the rewrite to the 2026-07-07 sweep commit 827598d). Unset case: the condition's own fallback prompts the user mid-gate and a non-"weighted-vote" answer silently becomes the protocol. Explicit `--protocol weighted-vote`: routed to the ELSE (tier default) — the one value the override can never set. SOURCE-VERIFIED (re-verified pass).

**F-H16 (D-8) | ✗ RETRACTED on re-verification** — first pass claimed the "substantive re-round" is a no-op (`rounds ← 1` → empty range); the final re-verified pass found the re-round wiring landed (prior-fix confirmed). What survives is only the below-cap lockout: `W:hr-team-reround-done` is set true on first use (deliberator.md:182) and never cleared → later councils in the same session lose their re-round right (now F-L9).

**F-H17 (D-9) | memory-compact/show-memory operate on the wrong episodic store — the real E: log (807 lines, past the 500 trigger) can never be compacted** — memory-compact.md:44 reads my-axon episodic; writers (memory.py:8-11, session_save.py:127) target workspace/memory/episodic/. Internal archive-path contradiction (:79 vs :131). CONFIRMED.

**F-H18 (D-10) | agent-memory cross-tier recall/list silently drop project+program tiers while labeling output `tier: "all"`** — agent_memory.py:137-151 `except ValueError: continue`; correct _all_entries used only by gc. Project tier = write-only dead end. CONFIRMED (probe: 18/18 general).

**F-H19 (D-11) | REGISTRY.json kernel `memory` entry advertises verbs the CLI rejects (STORE/RETRIEVE; rollback/history undocumented)** — REGISTRY.json:18-23 vs memory.py action set. CONFIRMED (argparse probe).

## MEDIUM

**F-M1 (B-3) | doctrine-node gate leaves a permanent, self-unrecoverable workspace write-block after a human-handoff** — shell.py:455-463 blocks all writes while axon/state/doctrine-current-node.json names a non-write node; doctrine_run.py:154-160 keeps it on handoff; nothing at boot clears it; block message gives no recovery hint (`doctrine_run clear-node`). CONFIRMED (planted-record probe).
**F-M2 (C-6) | drift remediation advice is broken everywhere it's advertised** — menu.md:202 (+compiled mirror), auto-improve.md:52, stats.md:121: bare `drift init` exits 2; `drift reset` DELETES the trace → reproduces the fault it advises fixing.
**F-M3 (C-7) | `drift check` vs `drift gate` split-brain** — cmd_check (drift.py:184-202) has no TTL/fail-closed logic; reports "stable" for the trace the gate halts on. Probed both.
**F-M4 (C-2) | lint-path-vars scans only workspace/programs + axon/programs — undefined path-vars in KERNEL-SLIM.md/BOOT.md escape the lint built for this class** — lint_path_vars.py:41-46; probe: ok:true while F-H8 exists.
**F-M5 (C-8) | `self-care --heal` as advertised (self_care.py:367, menu.md:379) exits 2 — flag lives on the `check` subparser only** — correct form `self-care check --heal`.
**F-M6 (A-6, verdict corrected by D) | `W:orchestrator-last-tick` has TWO writers with incompatible candidate shapes** — kernel output-layer tick (KERNEL-SLIM.md:146-152) stores anticipate.py candidates (`why`); orchestrator.md:170-183 stores synapse-suggest rank rows (`reason` array). menu.md:419 reads `.why` (right for writer 1, "—" for writer 2); orchestrator.md:155 reads `.reason` (inverse; and renders raw weight tokens, not prose). Not a regression — a shape split at the shared key.
**F-M7 (A-7 + D-13) | orchestrator situation-hint layer dead on three axes** — undefined `{turn}` vs situate.py:180 required int (argparse fail swallowed by `| { hint: ∅ }`); `recent-tools` never stored by its own tick; W:graph-query-count zero writers (RECONFIRMED). The OUTPUT-LAYER `⚡ hint` line can never render.
**F-M8 (A-8) | obsidian-export "unchanged" fast-path omits `notes`/`edges`; both consumers render them on exactly that branch** — obsidian_export.py:145-148 vs codemap-map.md:106 + code-dev-obsidian.md:60. Steady-state render shows undefined fields.
**F-M9 (A-10) | workspace-backup routes on `W:_subcommand` — a key nothing writes (RECONFIRMED)** — typed `skip`/`push`/`status`/`setup` all ignored; unconfigured `skip` still lands in the setup wizard (the state the 2af75df reorder was built to escape).
**F-M10 (A-11) | my-axon-init's "can never truncate or overwrite" guarantee violated by an unconditional MYAXON.md WRITE** — my-axon-init.md:148-196 (no existence guard) vs the :33-37 guarantee; a fresh-no-prompt re-run over a live my-axon clobbers user edits. 5f93eff fix incomplete.
**F-M11 (A-12) | stale-pointer resume guard protects only the menu OFFER — typed `resume` still EXECs an unknown program from an invalid W:active-phase** — resume.md:111-125 (no program-exists check); 9a99b36 touched only menu/axon_state.
**F-M12 (D-12) | suggestion footer self-suggests (`menu` while in menu) and pads with zero-score internal stubs** — anticipate.py:99-114 margin-gates only entries[0]; probe shows `_code-dev-schema-v4` (0.0, autogen-stub) surfaced.
**F-M13 (D-14) | orchestrator feeds ranker signal slots in shapes no producer emits — usage/pattern/context-pressure structurally zero** — orchestrator.md:64-67 vs synapse_suggest.py expectations; `usage top`/`context status` shapes probed (no pct; count rows not 0..1 map); pattern crashes (F-H14).
**F-M14 (D-15 first pass) | ✗ RETRACTED on re-verification** — the empty-task `W:hr-team-task` zero-readers claim did not survive the sweep's final source re-check ("residuals found are D-2/D-9 and the reround-done line"). Kept for the record; re-open only with fresh evidence.
**F-M15 (C-9) | W:active-phase key-convention split: kernel mandates `{program-name}:{phase}`; code-dev.md:221 writes project-keyed values** — non-terminal project-keyed values (observed live this session) trip the pointer sweep's `unknown-program` and suppress the resume offer (menu.md:237-239).
**F-M16 (D-13 final) | workflow-simulate reads `W:_workflow-sim-*` while the family convention and workflow-run's `--dry` alias bind `W:_workflow-simulate-*`** — workflow-simulate.md:37-39; zero writers of any `_workflow-sim-*` key; convention documented at workflow-run.md:105 and followed by validate/edit/list/run. Params never arrive → target ∅ → FAIL "Workflow not found: ∅"; the `--dry` route (workflow-run.md:111) inherits the break. SOURCE-VERIFIED (re-verified pass).
**F-M17 (D-15 final) | handoff reads a checkpoint field that doesn't exist and hands the receiving agent a wrong snapshot path** — handoff.md:38-39 reads `W:checkpoint-result.snapshot` (checkpoint save emits {saved,label,keys,count,file,timestamp} — checkpoint.py:154-161) → W:handoff-state is a dead ∅ store; brief line :73 points at `workspace/working/{label}.json` vs real `workspace/memory/working/.snapshots/{label}.json` (checkpoint.py:146). Only the restore-by-label instruction saves the flow. SOURCE-VERIFIED (re-verified pass).

## LOW

**F-L1 (A-13)** status.md:130-131 queue panel renders `t.name`; queue rows carry `program` (queue_tool.py:108-109).
**F-L2 (A-14)** simulate.md ignores its inline argument (`W:_simulate-target` zero writers, RECONFIRMED) + OUTPUTS documents phantom `shadow-W.json`.
**F-L3 (A-15)** codemap-shadow closeout stores the LAST batch count as `shadow-count`; computed total assigned and discarded.
**F-L4 (B-4)** axon_state.py:272 plans active-match is double-space-only while done-match tolerates both — latent active undercount.
**F-L5 (B-5)** axon_state pointer sweep hardcodes root/my-axon while sibling fields resolve the my-axon pointer — divergence if my-axon relocates.
**F-L6 (B-6)** dispatch_index status() `extras` blind to _NON_DISPATCHABLE — a stale STUB in the index reads as ok:true (inverse of the bugfix02 fix).
**F-L7 (C-3)** stray untracked shadow tree `<root>/memory/episodic/phase-ledger.md` — residue of past cwd-relative resolution; makes phantom-key reads look plausible.
**F-L8 (C-10)** pointer sweep checks test-record recency only, never verdict — a fresh-but-FAIL (27 failures) full-suite record reads as coherent.
**F-L9 (D below-cap, re-verified)** `W:hr-team-reround-done` set true on first re-round (deliberator.md:182), never cleared anywhere — later councils in the same session lose their re-round right (session-scoped lockout of a per-run guard).

## BELOW-CAP (verified one-liners — triage at plan time)
workflow-new dead dry-run preview (reads sim.steps/path/unreachable; simulate's DONE returns no payload) +
dead convergence gate (default-goal.metric/measurement never collected) + unimplemented `from "<desc>"` +
undefined args.subcmd · BOOT.md:196 anticipate inputs (W:recent-input/W:last-summary) have no writers →
boot/menu footer tick always ranks "" and CLEARs the tick [kernel] · plan-new.md renders W:plan-goal after
CLEARing it (confirmation always blank) [axon/programs] · workflow-validate.md:92,99 wraps
check-stale/check-templating in `| ∅` while the tool exits 1 exactly when findings exist
(workflow_run.py:1117,1127) — the wired lints can vanish precisely when they matter (LANG-underspecified) ·
index.py:77-83 `append --type plan` no-op that prints `{"appended": true}` (false success, zero callers) ·
orchestrator.md:96-97 zero-candidate fallback unreachable (187-entry corpus) — dead dispatch path ·
orchestrator.md:155 renders the reason-array as raw weight tokens (cosmetic).

## FIRST-PASS LEADS — NOT RE-VERIFIED (quarantined; investigate before trusting)
Sweep D's first return carried these from delegated sub-checks; its final self-re-verification pass neither
re-confirmed nor retracted them (agent_memory capture/gc internals + systematic registry argparse diffing are
in its declared not-covered list). Treat as leads for run 4, not findings:
· hr_team.py cwd-relative defaults (:331,:325,:572,:604) — roster gate crashes off-root → `| ∅` open-catalog fallback
· hr-team persistence tier dead at the write point (always "full-audit"; --events/--manifest never passed → empty events.jsonl)
· agent_memory capture(source="decision") writes general not episodic; binding liveness false-orphans axon/programs/*; _read_gate = divergent L: parser guarding gc
· REGISTRY descriptive drift beyond the memory entry (quality-loop ramp-unlock omitted; ~6 entries document ⅓ of CLI; no DEPRECATED token; retrieval-trace implies env-gated capture).

## VERIFIED CLEAN (both relevant sweeps — do not re-investigate)
write_barrier anchor resolution · doctrine_arming receipt chain · shell.py S7b reader/writer agreement (f9da9f6
holds) · workflow list counts + all 7 YAMLs schema-pass · check-stale/templating wired · node-order guard
vocabulary · REGISTRY structural integrity (187/187 scripts exist, 0 unregistered, 0 dupes) · anticipate shape
vs OUTPUT-LAYER/menu readers · boot general-memory load contract · prior hr-team fixes landed · codemap.py,
obsidian_export.py (build path), workflow_run.resolve_next, autonomy_doc/contract, dispatch_stats, health.py.

## DECLARED RESIDUAL GAPS (the next run's hunt ground)
New lints (exec_args/shell_result/liveness/memory_key/program_tool_conformance) · cron.py/cron_conformance
diffs · constraints/kv_store/keystone/board/reservoir_* diffs · loop_receipt recover + loop_contract
cross-registration end-to-end · doctrine step() budget branch under a real run · hr-team seat-seam runtime +
catalog content · compiled/ mirrors · registry prose purposes (150 unsampled) · crucible.md · code-dev
knowledge/meta/review/safety families · library-dev deep pass · chat file-op semantics · codemap-map
built_at_commit unguarded slice · workflow-run result.status vocabulary (LANG-underspecified).

## FOLLOW-UP FINDINGS surfaced during PR-021 (widened lint-path-vars) — run 4 candidates
- **NEW-1 | HIGH | `W:ws-name` phantom path-key** — referenced at axon/BOOT.md:55 (banner input),
  axon/BOOT.md:221, axon/KERNEL-SLIM.md:116 (prompt-log --session). BOOT.md:55 claims it comes from
  `boot-result.paths`, but the live boot tool (`axon.py boot`) does NOT emit ws-name in its paths dict —
  same F-H8 phantom class. Baselined in lint_path_vars (_BASELINE) so the widened scan blocks NEW phantoms;
  the real fix (repoint to W:myaxon-name, or make the boot tool emit ws-name) is a run-4 kernel item.
- **NEW-2 | MEDIUM | `W:ws-log` phantom path-key** — referenced at axon/KERNEL-SLIM.md:557 (LOG FORMAT
  doc) + :680 (resume block reads `{W:ws-log}/entries/{date}.md`). No writer anywhere (grep clean). The
  real log tree is workspace/log/entries/. Repoint to W:myaxon-log (defined) or the workspace literal —
  run-4 kernel item. Baselined.
Both are the SAME F-H8 class the widened lint (F-M4) was built to catch — it worked, surfacing 2 more
pre-existing phantoms beyond PR-021's declared scope. Grandfathered, not suppressed; each removal from
_BASELINE when fixed is the ratchet.

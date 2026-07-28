# Sweep D — never-audited surfaces (raw agent return, 2026-07-13)
method: verify-against-source both directions (program .md ↔ tool .py ↔ registry) + read-only probes over
surfaces neither bugfix01 nor bugfix02 covered: hr-team, workflow-runner family, suggestion chain,
agent-memory, handoff/chats/plan, REGISTRY integrity. Pending: adversarial reconfirmation (main loop).

---

### D-1 | CRITICAL | `--name` resolution is single-root: all 4 reference workflows unrunnable by name; `multiple-code-dev`'s nested `sub-workflow: code-dev` dies at its second node
- reader: workflow-run.md:79-80 (`path ← "workspace/workflows/{name}.yml"` + ASSERT exists); same in workflow-validate.md:37, workflow-simulate.md:40, workflow-edit.md:42; nested branch workflow-run.md:196-200 re-enters the same resolver.
- reality: tools/workflow_run.py:456-484 (list_workflows) + :335-342 (_default_sub_loader) resolve across BOTH roots (workspace/workflows/ AND workspace/domains/*/workflows/) — the .md layer never uses either. Disk: domains/code-dev/workflows/code-dev.canonical.yml (name: code-dev); workspace/workflows/code-dev.yml absent. multiple-code-dev.yml:33-35 declares `s2 … sub-workflow: code-dev`.
- probe: workflow_run list → 7 (3 user + 4 reference); ls workspace/workflows/ → adaptive-free-text, codemap-study, multiple-code-dev only; trajectory store holds exactly one file (manual-demo) — no mcd nested run ever recorded.
- impact: `workflow run code-dev|cpp-code-dev|python-code-dev|library-dev` FAILs "file not found"; the flagship multiple-code-dev loop dies at s2. Loud, but golden path dead.
- confidence: SOURCE-VERIFIED (+ disk probes).

### D-2 | HIGH | every workflow-validate caller guards on `v.errors` (a string LIST) — validate's own contract note says that comparison "never matches"
- readers: workflow-run.md:117-118 `ASSERT(v.errors ≡ 0)`; workflow-simulate.md:43-44; workflow-edit.md:100-102; workflow-new.md:180.
- reality: workflow-validate.md:119-122 — errors/warnings are string lists; `error-count`/`warning-count` are the integer tallies "callers MUST guard on … `v.errors ≡ 0` against a list never matches. Prefer `ok`." Producer fix shipped without migrating any of the 4 consumers.
- impact: contract-as-written every run/simulate FAILs at LOAD+VALIDATE on valid files; edit/new gates evaluate list-vs-int. Lenient-interpreter coercion likely masks it.
- confidence: SOURCE-VERIFIED.

### D-3 | HIGH | orchestrator `decide()` + sideband thresholds never recalibrated after the S2 absolute-score fix — modes 2-7 can never fire, sideband always empty, modes 8-10 fire unconditionally
- reader: orchestrator.md:108-118 — ladder gates 0.8/0.7/0.85/0.6, final else "fire"; :126-127 sideband threshold 0.6.
- reality: synapse_suggest.py:502-510 — score = raw/additive_mass (1.30), absolute; anticipate.py:82-86 documents the new scale ("clear single-intent ~0.10-0.20") and recalibrated ITS OWN margin to 0.05; orchestrator kept the old ladder.
- probe: rank "run the code review workflow" → top 0.117647; anticipate → confidence 0.034, density silent.
- impact: modes 2-5 always "ask", 6-7 always surface-only, 8-10 fire top hit at ANY score; D-30 sideband can never emit a row.
- confidence: CONFIRMED (scale probed) + SOURCE-VERIFIED (thresholds).

### D-4 | HIGH | pattern.py crashes on the SHIPPED preferences file — every cluster/top/suggest dies, killing the orchestrator's pattern signal
- reader: pattern.py:128 `int(read_pref(ws,"pattern-threshold",…))`; read_pref captures the WHOLE line remainder.
- reality: workspace/preferences/smart-dispatch.md:6 `pattern-threshold: 3          # surface a pattern suggestion when it appears ≥ N times` (comment captured).
- probe: `pattern.py cluster` → ValueError: invalid literal for int() … '3          # …' (before action branch — all 3 subcommands).
- impact: orchestrator.md:67 TOOL(pattern,cluster) always errors into `{}` fallback; direct use hard-crashes without explicit --threshold.
- confidence: CONFIRMED.

### D-5 | HIGH | chat-index split-brain: kernel boot chat-resume reads workspace/chats/INDEX.md via index tool; every chat program maintains my-axon/chats/INDEX.md — resume permanently blind
- reader: axon/BOOT.md:108-109 TOOL(index, list --type chat); KERNEL-SLIM.md:662. tools/index.py:52-55 → `<workspace>/chats/INDEX.md`, default workspace/.
- reality: producers axon/programs/new-chat.md:57-59 / switch-chat.md:48-49 / list-chats.md:7 target {W:myaxon-chats}INDEX.md = my-axon/chats/. workspace/chats/ does not exist.
- probe: `index.py list --type chat` → count 0.
- impact: boot active-chat restoration can never find a chat; index tool write actions would fork a second divergent index. Adjacent: index.py:77-83 `append --type plan` writes nothing yet prints `{"appended": true}` (latent false-success, zero callers).
- confidence: CONFIRMED.

### D-6 | CRITICAL | hr-team: a layer refusal doesn't stop the router; pipeline W: keys never cleared — a refused task can be SEALED with the PREVIOUS council's verdict + full false audit trail
- reader: hr-team.md:112-114 unconditional EXEC(selector)→EXEC(convener)→EXEC(deliberator); OUTPUT seals via TOOL(hr-team, seal, "--aggregation {W:deliberator-verdict}") (~:122).
- reality: every selector/convener refusal exits via `→ "REFUSAL…"` + DONE(...) (selector.md:56-105 — clarify/safety/circular/no-matches all DONE = SUCCESS exit per authoring-guide:149); zero CLEAR(W:hr-team-selector-result|W:council-transcript|W:deliberator-verdict) repo-wide; router clears only W:active-program (:166). verify-surfaceable checks only kind/advisory_only/keys (hr_team.py:192-201).
- impact: with a prior completed council in-session, a safety-refused task B flows into the deliberator, aggregates council A's stale transcript stamped `task: B`, and the router seals + writes a checksummed audit bundle for a council that never convened on B. Refusals advisory in effect.
- confidence: SOURCE-VERIFIED (each leg independently re-checked).

### D-7 | HIGH | hr-team selector regression (commit 827598d): QUERY(user) spliced INTO the protocol-override condition — default runs prompt mid-flow; explicit `--protocol weighted-vote` can never take effect on higher tiers
- reader: hr-team-selector.md:204-206 (+ :211) — `IF RETRIEVE(W:hr-team-protocol) | QUERY(user): … ≠ ∅ AND … ≠ "weighted-vote" → protocol ← …` (QUERY inside the condition, twice).
- reality: original was a plain unset-check; git -L blame pins the mechanical rewrite to the 2026-07-07 sweep commit 827598d. The `≠ "weighted-vote"` guard also drops an explicit weighted-vote to the tier default (:195-197).
- impact: every default-protocol council interrupts with unexpected free-text prompts (up to 3×), violating the convener's announce-then-act contract (convener.md:100); explicit weighted-vote silently overridden on high/xhigh/full tiers.
- confidence: SOURCE-VERIFIED (read + blame).

### D-8 | HIGH | hr-team "substantive re-round" is a no-op that also disables itself for the rest of the session
- reader: convener.md:245-255 — REROUND ENTRY claims dissent-injection + one more round; implementation is only CLEAR(reround-request) + `rounds ← 1`.
- reality: section sits AFTER RUN ROUND 1 (already executed, fresh transcript); `rounds ← 1` → loop `range(2, rounds+1)` = empty; dissenters narrated, never injected. One-shot guard STORE(W:hr-team-reround-done, true) (deliberator.md:182) has NO CLEAR repo-wide → latches off for all later councils.
- impact: substantive dissent triggers an identical re-run of round 1 (prior transcript destroyed, second 30s ANNOUNCE HALT), then the mechanism disables itself.
- confidence: SOURCE-VERIFIED.

### D-9 | HIGH | memory-compact / show-memory operate on the WRONG episodic store — the real E: log (807 lines, past the 500-line trigger) can never be compacted
- reader: memory-compact.md:44 `episodic-dir ← "{W:myaxon-episodic}/"`; same store read by show-memory.md:21,50, status.md:37.
- reality: E: writers target the WORKSPACE store — tools/memory.py:8-11 SCOPE_MAP under workspace/memory/; session_save.py:127; axon/memory/MEMORY.md:33.
- probe: wc -l workspace/memory/episodic/session-log.md → 807; my-axon/memory/episodic/ → 4 stale test files. Internal contradiction: memory-compact.md:131 claims archive at workspace/memory/archive/ while step 2 (:79) writes {W:myaxon-memory}/archive/.
- impact: the anti-growth program silently no-ops on the real log; memory dashboards count a store nothing writes.
- confidence: CONFIRMED.

### D-10 | HIGH | agent-memory cross-tier recall/list silently drop project+program tiers while labeling output `tier: "all"` — project tier is a write-only dead end
- reader: agent_memory.py:137-151 — tier=None loop calls tier_dir which raises ValueError for program/project when scope_ref="" (:64-71), `except ValueError: continue` → only general survives. Correct enumerator _all_entries (:294-306) used only by gc.
- reality: project-tier entries exist on disk (axon-resilience/_memory/…); AM2 spec promises cross-tier ranked recall (axon-memory/02-prs.md:17); no program invokes load/recall --tier project.
- probe: `agent_memory.py list` → tier: all, count 18, every entry general.
- impact: project/program-tier memories never surfaced by any recall path; output falsely labeled "all".
- confidence: CONFIRMED.

### D-11 | HIGH | REGISTRY.json kernel `memory` entry advertises verbs the CLI rejects (STORE/RETRIEVE)
- reader: REGISTRY.json:18-23 purpose "STORE/RETRIEVE/CLEAR/APPEND on W:/L:/E: scopes".
- reality: memory.py actions {get,set,append,list,clear,rollback,history}; rollback/history also undocumented.
- probe: `memory.py store` → argparse invalid choice.
- impact: registry = tool-discovery source of truth; idiom-to-subcommand mapping dies at argparse.
- confidence: CONFIRMED.

### D-12 | MEDIUM | suggestion footer suggests `menu` to a user in the menu; pads with zero-score internal stubs — only the TOP candidate is margin-gated
- reader: anticipate.py:99-114 footer_candidates — silence gate checks only entries[0]; remaining rows emitted regardless of own score; no exclusion of current program or underscore-prefixed internals. Rendered by OUTPUT-LAYER.md:86-105 + menu.md:413-419.
- probe: `anticipate.py --input "menu" --footer` → 1) menu (0.182) 2) _code-dev-schema-v4 (0.0, "(autogen-stub — needs description)") 3) audit-to-study (0.0).
- impact: primary suggestion surface self-suggests + surfaces internal stubs with zero signal, contradicting anticipate's own "wrong anticipation is worse than none" contract.
- confidence: CONFIRMED.

### D-13 | MEDIUM | orchestrator situation-hint bridge dead on two axes: unbound `{turn}` (required int) + `recent-tools` its own tick never writes  [= sweep A-7; merge]
- reader: orchestrator.md:140-143. reality: `turn` assigned nowhere; situate.py:180 --turn required int → argparse fail → `| { hint: ∅ }` swallows; tick writer (:170-183) stores no recent-tools; W:graph-query-count zero writers.
- impact: sit.hint always ∅ → OUTPUT-LAYER `⚡ hint` line (axon-plus pr-16) can never render.
- confidence: SOURCE-VERIFIED.

### D-14 | MEDIUM | orchestrator feeds ranker signal slots in shapes no producer emits — usage, pattern, context-pressure structurally zero
- reader: orchestrator.md:64-67. reality: synapse_suggest.py:110-118 expects state.usage.recent {name:0..1}; :121-129 pattern.clusters {name:0..1}; :261-268 context-pressure.pct. Producers: `usage top` emits {window,kind,total,unique,top:[{name,count}]}; `context status` emits percent/pressure, no pct (probed); `pattern cluster` crashes (D-4).
- impact: 3 of the 11 ranker signals silently absent/zero every tick; context-pressure cost penalty always 0.
- confidence: CONFIRMED (shapes probed).

### D-15 | MEDIUM | hr-team empty-task capture stores to `W:hr-team-task` — zero readers — so the "fixed" double-prompt persists and the provenance call-id binds the EMPTY task
- reader: hr-team.md:95-99 (comment claims the bugfix01 LOW fixed). reality: W:hr-team-task has one writer, no readers; layers read W:task/W:raw-user-input (selector:41, convener:37, deliberator:218), never updated; call-id minted with empty task at :71. tests/test_hr_deliberation_flow.py:75 pins the buggy line textually.
- impact: empty-task runs still dead-end in clarify refusal after collecting an answer (and per D-6, worse); provenance hashes "".
- confidence: SOURCE-VERIFIED.

---

## Below-cap additional findings (verified, one line each)
- workflow-simulate.md:37-39 reads W:_workflow-sim-{path,name,max} while the family convention + workflow-run's --dry alias bind W:_workflow-simulate-* (workflow-run.md:105,111) — key-prefix drift.
- workflow-new.md:191-194 reads sim.steps/sim.path/sim.unreachable from EXEC(workflow-simulate) — simulate's DONE returns no payload (dead preview). Also :198-205 convergence gate on never-collected default-goal.metric (dead); HELP :37 `workflow-new from "<desc>"` unimplemented; :46 reads undefined args.subcmd.
- axon/BOOT.md:196 anticipate input chain W:recent-input | W:last-summary — neither has any writer; W: empty at boot → boot/menu footer tick always ranks "" and CLEARs the tick; only KERNEL-SLIM.md:147 per-turn band ever lights the footer. [kernel file]
- handoff.md:38-39 reads W:checkpoint-result.snapshot — checkpoint save emits {saved,label,keys,count,file,timestamp} (checkpoint.py:154-161); brief (:73) points receiving agent at workspace/working/{label}.json vs real workspace/memory/working/.snapshots/{label}.json (checkpoint.py:146).
- axon/programs/plan-new.md:45,51 — `Goal: {W:plan-goal}` rendered AFTER CLEAR(W:plan-goal) (always blank). [axon/programs]
- hr_team.py CWD-relative defaults (:331,:325,:572,:604) violate _axon_paths — off-root the fail-closed roster gate crashes and the router's `| ∅` fallback converts it into the exact open-catalog takeover it exists to prevent (probed both cwds).
- hr-team persistence tier dead at the single write point: hr-team.md:40,157 local default "full-audit" regardless of selector tier (no-logs/decisions-only); never passes --events/--manifest → every bundle has empty events.jsonl.
- agent_memory.capture(source="decision") writes boot-loaded GENERAL memory, not the documented episodic store (:241-244 vs :383-416); binding liveness checks only workspace/programs/ → axon/programs/*-bound memories are false orphans (:181-182); _read_gate (:279-291) is a ninth divergent L: parser guarding gc's destructive path (tools/_longterm.py:24-29 documents exactly this hijack).
- REGISTRY descriptive drift: quality-loop args omit the 5-subcommand autonomy ramp incl. ramp-unlock (HUMAN-ONLY) (REGISTRY.json:1149-1163); shadow/graphify-bridge/igap each miss 1-2 subcommands; cron/agent-memory/usage/library/programs-registry/autonomous-mode purposes cover ~1/3 of real CLI (incl. autonomous-mode bind/renew); no DEPRECATED status token (hooks shim under OPTIONAL); retrieval-trace purpose implies a capture subcommand that is env-gated library code only.
- orchestrator.md:155 renders {c.reason | '—'} — --explain emits reason as an ARRAY of weight strings (synapse_suggest.py:525) → raw tokens, not prose (cosmetic).

## Explicitly verified CLEAN (do not re-investigate)
- workflow list counts match disk (7 = 3 user + 4 reference); all 7 YAMLs pass the schema (real jsonschema, 0 errors); check-stale/check-templating wired (bugfix01 H5 fixed); node-order guard vocabulary consistent with phase_model STATUSES; REGISTRY structural integrity clean (187 scripts exist, 0 unregistered, 0 dupes); anticipate output shape matches orchestrator/OUTPUT-LAYER/menu readers (menu.md:418-419 c.why correct FOR THE ANTICIPATE WRITER — see ledger note on the two-writer split); kernel boot agent-memory load --tier general matches live output; prior hr-team fixes confirmed landed (write-audit-bundle, --family/--roles, --weights, bpc winners, verdict-status).

## Not covered
Mutating paths never executed (hr-team run/seal, checkpoint save/restore, memory set/rollback/gc, situate emit, record-step) — source-only; run_seats fan-out; predicate.py internals; compiled/ mirrors; registry subcommand drift sampled 37/187; hr-team catalog content; chat UPDATE/APPEND semantics beyond paths; workflow-run `--status {result.status}` vocabulary vs sub_workflow_completed's ("ok","done","pass","success") — LANG-underspecified, graded unproven.

# Sweep A — program-layer diff audit (raw agent return, 2026-07-13)
method: read-only verify-against-source over post-2026-07-07 markdown surfaces (programs, workflows, domains);
bugfix01/02 ledgers deduped; regressions/incomplete fixes flagged explicitly. Pending: adversarial reconfirmation.

---

- ID: A-1 | HIGH | `code-dev complete` refusal path silently mutates the phase ledger (mutator used as a reason-oracle)
  - reader: workspace/programs/code-dev.md:210-212 — inside the "✗ NOT COMPLETE" branch: `∀ b in comp-blocking → missing-b ← TOOL(phase-model, done, "--project … --phase {b.id} --best-effort")` then renders `{missing-b.reason | 'not yet done'}`
  - reality: tools/phase_model.py:251-270 — `done()` is a MUTATOR: deps-done + outputs-present → sets `ph["status"]="done"; save(...)`; CLI (:423-437) prints `{ok:true, done: ph}` with NO `reason` key; only the ValueError path yields `{ok:false, skipped, reason, reason_code}`.
  - impact: `code-dev complete` on a not-yet-complete project can opportunistically mark satisfiable pending phases done as a side effect of printing the refusal; a second `complete` then stamps the project. Refusal path that advances state defeats the gate 92e3912 built.
  - confidence: SOURCE-VERIFIED

- ID: A-2 | HIGH | codemap leaf programs read the SUBCOMMAND token as their argument (arg off-by-one) + `W:_opt-repo` has no writer
  - reader: codemap-new.md:38-39 (`W:_arg1`, `W:_opt-repo`); codemap-ask.md:41; codemap-relations.md:45.
  - reality: axon/COMMANDS.md:24 — tokenizer writes ONLY `W:_cmd · W:_arg1 · W:_arg2`; via router codemap.md:34, `_arg1` IS the subcommand → leaf's first real argument is `W:_arg2`. `W:_opt-repo` / `W:codemap-question` have zero writers repo-wide. Fixed sibling library-dev-report.md:33 reads `W:_arg2` for exactly this reason.
  - impact: golden paths (`codemap new flowsim --repo /x`, `codemap ask "…"`, `codemap relations Foo`) bind slug="new", question="ask", target="relations", `--repo` dropped — H17 wrong-key class reintroduced in a new family.
  - confidence: SOURCE-VERIFIED

- ID: A-3 | HIGH | codemap-shadow's scan/refresh dispatch key has no writer — codemap-study workflow's "shadow the source" step is a stats no-op
  - reader: codemap-shadow.md:41-42 (`W:codemap-shadow-cmd | "stats"`, `sub-arg ← W:_arg2`); workflows/codemap-study.yml:38-42.
  - reality: `W:codemap-shadow-cmd` occurs once repo-wide (this read) → cmd always "stats"; SCAN/REFRESH (:73-178) unreachable. Compounding: if reached, `sub-arg` = "scan" itself → :75 composes `{repo}/scan` (wrong-path); real dir would need a `W:_arg3` the tokenizer never defines.
  - impact: `codemap shadow scan` and `workflow run codemap-study` silently render stats over an empty index; the advertised onboarding chain (menu.md:298) completes with zero files shadowed.
  - confidence: SOURCE-VERIFIED

- ID: A-4 | HIGH | session-summary reads the WRONG log tree — bugfix02 C3's user-visible symptom persists (incomplete fix)
  - reader: session-summary.md:46 `log-file ← "{W:myaxon-log}{today}.md"`.
  - reality: tools/log.py:18,25 writes `{workspace}/log/entries/{date}.md` (default workspace/) — fresh file exists (2026-07-13); `W:myaxon-log` tree's newest is 2026-07-07 and uses a DIFFERENT level format (`| [INFO] |`) than the digest patterns (:61-72) match. handoff.md:53 has the correct double fallback.
  - probe: my-axon/log/entries newest = 2026-07-07; workspace/log/entries newest = 2026-07-13 with `[2026-07-13 06:57:26] | INFO     | health-check | …`
  - impact: still early-exits "No log entries found" most days; even when the my-axon file exists, error/program patterns match zero lines — C3's symptom one level up.
  - confidence: CONFIRMED

- ID: A-5 | HIGH | `TOOL(meta, get)` envelope bound as bare scalar across code-dev-graphify + all 7 codemap call-sites (bugfix01 C12 envelope class recurring in new code)
  - reader: code-dev-graphify.md:48-49 (`codebase ← TOOL(meta,get,…)` then `≡ "(none)"` guard); codemap-graphify.md:38+52, codemap-shadow.md:40, codemap-ask.md:39, codemap-map.md:38, codemap-relations.md:38, codemap-features.md:39, codemap-status.md:37-38 — value interpolated as path/string.
  - reality: tools/meta.py:30-39 `get` emits `{"field","value","found"}` — never bare, never "(none)"; correct read is `.value`.
  - probe: `meta get --project …/axon-bugfix01 --field codebase` → `{"field":"codebase","value":"/home/…/axon","found":true}`
  - impact: unset-codebase guard can NEVER fire; every codemap build/render interpolates a JSON dict where a repo path belongs. Same class: codemap-new.md:87,95-96 + codemap-shadow.md:43-45 bind the shell envelope bare.
  - confidence: CONFIRMED

- ID: A-6 | MED | menu suggestion footer regression: the bugfix02 `reason→why` fix went the WRONG way — producer emits `reason`, not `why`
  - reader: menu.md:419 `{c.why | '—'}` (+ compiled/menu.cmp.md:355).
  - reality: sole writer of W:orchestrator-last-tick = orchestrator.md:170-183 with synapse-suggest rank rows; tools/synapse_suggest.py:523-527 emits `{"name","score","raw"}` + `reason`/`signals` under --explain — no `why`. orchestrator.md:155 itself reads `c.reason`.
  - probe: `synapse_suggest.py rank --state '{}' --top 2 --explain` → rows carry `"reason": []`.
  - impact: every menu suggestion renders "reason: —" — the defect bugfix02 recorded as fixed has effectively regressed (different phantom field).
  - confidence: CONFIRMED
  - NOTE (main loop): KERNEL-SLIM.md:146-149 output-layer tick ALSO writes W:orchestrator-last-tick from anticipate.py — check anticipate's field (`why`?) → possible two-writer/two-shape split rather than a one-sided wrong fix. Verify at reconfirm.

- ID: A-7 | MED | orchestrator situation-hint layer starved on three inputs (undefined `{turn}`, self-read of never-stored field, unwritten key)
  - reader: orchestrator.md:140-143 — `TOOL(situate, emit, "--turn {turn} …")` with `turn` defined nowhere; `recent_tools: RETRIEVE(W:orchestrator-last-tick).recent-tools | []`; `graph_query_count: RETRIEVE(W:graph-query-count) | 0`.
  - reality: tools/situate.py:180 `--turn` required int (unresolved `{turn}` → argparse fail → `| { hint: ∅ }` silently absorbs); orchestrator's RECORD block never stores `recent-tools`; `W:graph-query-count` zero writers.
  - impact: PR-16 situation-trigger hint permanently ∅; two situate signals permanently empty — wired but dead every tick.
  - confidence: SOURCE-VERIFIED

- ID: A-8 | MED | obsidian-export "unchanged" fast-path omits `notes`/`edges`, both consumers render them on that branch
  - reader: codemap-map.md:106; code-dev-obsidian.md:60.
  - reality: tools/obsidian_export.py:145-148 — hash-match path returns `{ok, degraded, vault, unchanged:true, reason, freshness}` with NO notes/edges (only rebuild via build_vault :108-109 carries them).
  - impact: every re-run over an unchanged graph (designed steady-state) renders undefined fields in both confirmation cards.
  - confidence: SOURCE-VERIFIED

- ID: A-9 | MED | `graphify-bridge query impact --symbol` raises uncaught KeyError — codemap-relations calls exactly that form (into a value never rendered)
  - reader: codemap-relations.md:74 `TOOL(graphify-bridge, query, "impact … --symbol {top.label}") | ∅` — result never used (:77-89 render callers/affected/neighbors only).
  - reality: tools/graphify_bridge.py:436 `kw["file"]` — impact requires `--file`; `--symbol` only → KeyError, violating the module's fail-degrade contract (docstring :14).
  - probe: traceback ending `KeyError: 'file'`.
  - impact: dead-but-erroring call on every `codemap relations` run (masked by `| ∅`); other callers get a crash instead of a degraded envelope. [Overlaps B-1 — merge at ledger]
  - confidence: CONFIRMED

- ID: A-10 | MED | workspace-backup routes on `W:_subcommand`, a key nothing writes — typed `skip` still lands in the setup wizard when unconfigured (incomplete fix)
  - reader: workspace-backup.md:37 `RETRIEVE(W:_subcommand) | "auto"` feeding the ROUTE (:50-58).
  - reality: `W:_subcommand` occurs once repo-wide (this read); tokenizer writes `W:_arg1`. subcommand always "auto"; with backup-url ∅, :55 routes into SETUP — the state the skip-first reorder (2af75df) was built to escape.
  - impact: `skip`/`push`/`status`/`setup` typed subcommands all ignored contract-as-written; bugfix02's "skip unreachable" symptom survives through a different hole.
  - confidence: SOURCE-VERIFIED

- ID: A-11 | MED | my-axon-init's "idempotent — can never truncate or overwrite" claim violated by unconditional MYAXON.md overwrite
  - reader: my-axon-init.md:33-37 (guarantee comment) vs :148-196: ENSURE-TREE always flows to WRITE-MYAXON (GOTO :128), whose `WRITE("{myaxon-path}/MYAXON.md", …)` has no existence guard.
  - reality: every other create in ENSURE-TREE is mkdir -p/touch/guarded (:85-105,109) — MYAXON.md is the one file a fresh-no-prompt re-run over a live my-axon/ rewrites (resets Created, regenerates path map, discards user edits; may re-prompt name mid-automation).
  - impact: the 5f93eff data-loss fix is incomplete — a migrate-workspace-driven re-run still clobbers live MYAXON.md.
  - confidence: SOURCE-VERIFIED

- ID: A-12 | MED | stale-pointer resume guard only protects the menu OFFER — `resume` typed directly still EXECs an unknown program from an invalid W:active-phase (incomplete fix)
  - reader: resume.md:29-33 + 111-125 — trusts any non-terminal W:active-phase; :125 `EXEC({target})` with no program-exists check.
  - reality: 9a99b36 touched ONLY menu.md/menu.cmp.md/axon_state.py (git show --stat); `unknown-program` kind exists in self_care.py:151, consulted by menu.md:237, by nothing in resume.md.
  - impact: the 2026-07-09 false-fire class re-opens via the exact command the menu tells users to type ("type: resume").
  - confidence: SOURCE-VERIFIED

- ID: A-13 | LOW | status.md queue panel renders `t.name` — queue rows carry `program`
  - reader: status.md:130-131. reality: tools/queue_tool.py:108-109 shape `{"id","program","priority","deps","status","added"}`. probe: `queue list` → row shape from writer.
  - impact: pending tasks print an undefined field where the program should be.
  - confidence: CONFIRMED

- ID: A-14 | LOW | simulate ignores its inline argument (`W:_simulate-target` no writer) and OUTPUTS claims a phantom file
  - reader: simulate.md:38 (no `W:_arg1` fallback); :107 claims `workspace/working/sim/shadow-W.json`.
  - reality: `W:_simulate-target`/`W:_simulate-verbose` only in simulate.md; tokenizer puts the name in `W:_arg1`; body writes only `workspace/memory/working/sim/sim-report-{target}.json` (:93).
  - impact: "simulate menu" always re-asks for the target (saved by the QUERY fallback); OUTPUTS documents a phantom artifact.
  - confidence: SOURCE-VERIFIED

- ID: A-15 | LOW | codemap-shadow scan closeout records the batch size as the study's `shadow-count`; computed total discarded
  - reader: codemap-shadow.md:140-141 — `new-count ← COUNT(process) + (shadow stats .fresh | 0)` assigned, never used; next line stores `--value {COUNT(process)}`.
  - reality: `_meta.shadow-count` seeded 0 (codemap-new.md:116), only ever overwritten with the LAST scan's batch count; REFRESH never updates it.
  - impact: recorded shadow coverage wrong after any second scan; cosmetic (codemap-status reads live `shadow stats`).
  - confidence: SOURCE-VERIFIED

### Declared NOT covered by this sweep
hr-team-* programs · crucible.md · doctrine-run.md + doctrine/autonomy floor surface (ea87819…2b24027) ·
axon-audit/axon-compare/axon-docs-gen re-verification · code-dev-knowledge/meta/review/safety families ·
library-dev-* beyond report/search spot-checks · workflow-new/edit/explain beyond tool-name resolution ·
multiple-code-dev.yml · glossary/config/discover/help/translate/shadow-retroactive-bulk ·
codemap-map `shape.built_at_commit` (`[:8]` sliced unguarded at codemap-map.md:56 — unverifiable without a built graph).

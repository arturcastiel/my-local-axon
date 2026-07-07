# AXON Self-Audit 02 — Findings (residual surfaces)
project: axon-bugfix02
codebase: /home/arturcastiel/projects/new-axon/axon
date: 2026-07-07
method: 4 parallel read-only verify-against-source agents over the surfaces axon-bugfix01 explicitly
        declared never-audited, + adversarial re-verification of all 4 CRITICALs from scratch (4/4 reconfirmed).
scope: menu · status · stats · gain · session-summary · resume · workspace-backup · my-axon-init ·
       find-program · list-tools · undo · axon-docs-gen · auto-actions · todo · board · loop-contract ·
       constraints · dispatch-stats · auto_audit
bar: every finding verified against SOURCE and (where non-mutating) a LIVE run — never inferred from naming.
tally: 4 CRITICAL · ~18 HIGH · ~22 MEDIUM · ~25 LOW (read-only study; no fixes applied).

---

## THE HEADLINE (cross-cutting root pattern)
The **dashboard + session-reporting layer** is pervasively wired to memory keys and tool-output fields
that **no writer produces**. This is the same defect CLASS as bugfix01's C9 (L: split-brain) and C12
(envelope bug) — a reader and its data source disagreeing — but concentrated in exactly the read-only
surfaces the first audit never reached. Consequence: menu/status/stats/gain silently report zeros or
render dead panels, and session-summary/resume early-exit or detect nothing, every single run. Because
these surfaces only READ, nothing ever fails loudly — the OS's own self-report is quietly fiction.

A second recurring class: **false success after a gate-blocked git op** (workspace-backup) — bugfix01's
H25 (migrate-workspace) recurring in the backup path, now colliding with the destructive-git gate
bugfix01 *added* (PR-001), which makes the false "restored/ok" strictly worse.

---

## CRITICAL (advertised feature broken on the golden path; all 4 adversarially reconfirmed)

### C1. `board` always renders an empty Kanban, silently, across three independent breakages
- `tools/board.py:19-24` calls `pr_aggregate.py list --json --all-projects` — pr_aggregate has NO `list`
  subcommand (exit 2, empty stdout) → board's `json.loads` throws → `except: return []` → header-only board,
  exit 0, zero diagnostics. RECONFIRMED: `board.py` prints 2 lines; `pr_aggregate list` → argparse error.
- Even fixed: `pr_aggregate --json` emits JSONL (one obj/line); board expects one doc with a `prs` key.
- Data is empty anyway: `parse_meta` needs `pr-N:` block headers in `_meta.md`; ZERO across all ~60 projects
  (real PRs live in `02-prs.md`/`03-prs/`). Menu (line 368) + code-dev-meta-board.md (ACTIVE) advertise it.

### C2. `gain`'s SESSIONS + TOP PROGRAMS panels (its whole purpose) are unbacked
- `gain.md:58-64` aggregates `s.turn_count / s.programs_run / s.drift_events / s.errors` per session, but
  E:session-log rows are strictly `| Time | Event | Notes |`. RECONFIRMED: live `memory get E session-log`
  shows only checkpoint/session-saved rows with those 3 columns — none of the four fields exist anywhere.
- Compounding: `gain.md:83-87` reads `_ctx-report.estimated_tokens_used`/`.tee_saves`; `context status`
  emits only `{accumulated_tokens, limit, percent, pressure, entries}`.

### C3. `session-summary` ALWAYS early-exits "No log entries found" — Steps 2-5 unreachable
- `session-summary.md:42` composes `"{W:myaxon-log}/entries/{today}.md"`, but `W:myaxon-log` already ends
  in `/log/entries/` (MYAXON.md:30, on disk). RECONFIRMED: the store value is
  `.../my-axon/log/entries/` → the read targets `.../log/entries/entries/…` which never exists. handoff.md
  uses the correct bare `"{W:myaxon-log}{today}.md"`.
- (Even past the path: the 4 digest FIND_ALL patterns match zero real log lines — `source:`/`STORE(L:`
  never appear; the level-column padding differs — so it would report 0 programs/0 errors regardless.)

### C4. `resume`'s interrupted-session detection is fully dead
- `resume.md:27-28` filters E:session-log on events `session-checkpoint / mid-session-checkpoint /
  session-end / session-complete / boot-complete`. RECONFIRMED: the real log contains only `checkpoint`
  (611) and `session-saved` (313) — NONE of the filtered names are ever written by any producer. The
  filter is always empty → line 41 guard always true → always prints "No interrupted sessions found";
  lines 49-109 unreachable. `W:current-session` also has no writer but resume itself (and W: is
  session-only, so it's ∅ at boot anyway).

---

## HIGH (reachable, real user-facing impact)

**menu.md**
- H. `kv-store set L:auto-improve false` (lines 330,332) is guaranteed to FAIL — kv-store hard-refuses the
  L: namespace (the C9 guard bugfix01 added). Correct: `memory set --scope L`. The menu tells users a
  broken command.
- H. `RETRIEVE(W:ws-queue)` (65-66,199) — no writer anywhere (queue is `scheduler/queue.json`); the
  "Queue ⚠ N pending" warning can never fire.
- H. Boot-path reminders (242-246): `snap.todos_preview` is a list of capped STRINGS, but line 245 reads
  `r.text[:76]` and 244 reports `COUNT`=4 when 8 are open — the owner-directed reminder store misreports
  every boot (only the tool-fallback path, with `.text` objects, works).

**status.md** — H. `W:queue-data.active` (queue list emits `{status,tasks,count}`, no `.active`) and the
  whole QUEUE panel dead; H. drift metrics read `workspace/memory/episodic/drift-log.md`, a file that does
  not exist and whose only writer is the ORPHANED `workspace/tools/drift.py` (registry maps drift →
  `tools/drift.py`, which writes `working/drift-trace.json`) → health score is structurally blind to drift.

**stats.md** — H. same nonexistent `drift-log.md` (drift always 0, deduction + recommendation dead);
  H. `W:queue-data.active` same shape miss.

**session-summary.md** — H. reads nonexistent `drift-log.md`; H. all 4 digest patterns match 0 lines
  (false "0 errors"); H. `calculator "Σ(session-confidence-values) / W:turns"` is unexecutable
  (`illegal target for annotation`) and its input is never gathered.

**resume.md** — H. reads `entry.session`/`entry.detail`/`MAP(field="session")` — rows have only
  `{time,event,notes}`; H. turn-parse `^## T-\d+` matches 0 blocks (real headers are bare timestamps).

**workspace-backup.md** — H. FALSE SUCCESS: restore branch runs `git reset --hard origin/main`, the shell
  gate BLOCKs it (RECONFIRMED: `shell inspect` → verdict BLOCK, code destructive-git), result unchecked,
  line 135 unconditionally prints "✓ restored"; H. `skip` is unreachable when unconfigured (the
  `backup-url ≡ ∅` setup route at :36 shadows the :39 skip check — exactly the case the reminder fires in).

**undo.md** — H. rollback contract mismatch: checks `.ok ≡ true` + reads `.value`, but memory.py rollback
  success emits `{rolled_back, restored_value, remaining_history}` (no ok/value) → every SUCCESSFUL undo
  reports FAILED while state was actually restored; H. stale-manifest wrong-run rollback (run.py only writes
  the manifest on L:-writing runs and never clears it → undo after a no-write run rolls back an older run).

**list-tools.md** — H. registry shape/status mismatch: boot seeds `W:tool-registry` as a list of NAMES
  (ACTIVE only), but the program reads `t.status/.name/.purpose` and branches on a "SKIPPED" status that
  REGISTRY.json never contains → OPTIONAL tools misrender or vanish; the "merged OS+workspace registries"
  claim is false (no workspace tools registry exists).

**dispatch-stats** — H. structurally reports all-zeros forever: joins on `usage-log.jsonl` +
  `dispatch-feedback.jsonl`, and NEITHER file exists in the install despite real dispatch activity — the
  metric pipeline is starved at the source and emits a plausible zero report instead of flagging missing inputs.

**loop-contract** — H. receipt routing defeats its own "receipts LAND" fix: `_receipt` passes
  `--workspace` so `loop_receipt` targets `workspace/state/…` not the canonical `axon/state/…` that
  list/recover read; sibling tools (dispatch, auto_audit) guard canonical→None, loop_contract doesn't →
  0 loop-contract rows in the canonical ledger.

---

## MEDIUM (narrower / structural) — abbreviated
- menu: snapshot `workflows` has no `ok` key (enriched line dead on golden path); `audit-7d` scalar-vs-object
  type mix (`.total` undefined on snapshot path); `L:cron-jobs` no writer (Cron line dead, 13 real jobs);
  `W:boot-cron-tick`/`W:boot-last-snapshot` no writer (SELF-IMPROVEMENT panel dead); footer reads `c.reason`
  (candidates carry `why`, so every suggestion shows `reason: —`).
- stats: `cron list` rows carry no `overdue` (always 0); false "Health score saved" print (body stores
  nothing); `workspace/packages/` doesn't exist (Packages: 0 forever); dead `memory list --key` call.
- gain: `rtk` stub is truthy (no `not_installed` guard → RTK panel reads nonexistent fields);
  `W:_gain-period` no writer (daily/monthly/all variants have no seed mechanism).
- find-program: half-deprecated semantic-search block (live consumer over commented-out setters + undefined
  `W:sem`/`W:has-semantic`; `semantic-search` unregistered everywhere); scans only workspace/programs (29 OS
  programs unfindable though PURPOSE says "installed programs").
- undo: double-undo reads keys its own cleared-manifest shape lacks.
- axon-docs-gen: reads `_docgen-result.compiled` — docgen never emits `compiled`.
- workspace-backup: success = absence of "error"/"fatal" substrings (BLOCK JSON contains neither → false
  "ok" + fresh timestamp); self-referential `ws-path` fallback interpolates the same unset key.
- my-axon-init: prompt dispatch has no else (typo/lowercase falls into FRESH → mkdir+write); `fresh-no-prompt`
  bypasses the existence guard → truncates an existing event log on a re-run (data loss); CLONE path skips
  all FRESH mkdirs → downstream backup writes target a nonexistent dir.
- loop-contract: `define`'s goal cross-registration is fire-and-forget (the one real contract has no goal
  anywhere); `_receipt` calls begin, never commit → rows non-terminal → recover() would mark them ABORTED.

## LOW (cosmetic / doc-drift / vestigial) — abbreviated
- Stale synapse `inputs-count`/`outputs-count` across menu/status/stats/gain/find-program/list-tools (no
  verified counting convention — flagged LOW). Duplicate probes (menu loaded-lib/lib-active;
  audit-summary assigned-never-used). status "Dispatch 8" counts compiled mirrors vs the real 166 index.
  todo: menu says `todo done <id>` but CLI needs `--id`. constraints: docstring names REGISTRY.json, disk is
  CONSTRAINTS.json. dispatch-stats: dead saved_tokens overwrite; docstring omits `precision`. auto-actions:
  `!NORM read-only` banner yet STOREs L: (role: mutator); HELP cites nonexistent `igap improve`.
  session-summary/resume/my-axon-init: several vestigial keys/dirs (my-axon/log/turns empty; the real turn
  writer targets workspace/log/turns). workspace-backup: `myaxon-backup-setup-skipped.md` has no reader.

---

## Explicitly verified CLEAN (do not re-investigate)
- All TOOL names resolve via REGISTRY.json; the vast majority of TOOL(name, sub, --flags) call sites match
  the real argparse exactly (clock, igap stats, dispatch-index status, cron breaker-status, drift gate,
  prompt-log consent, auto-audit summary/list, todo list, workflow-runner list, memory get/list, events log,
  calculator, axon-state menu-snapshot). program-tool-conformance: 0 violations / 51 call-sites.
- agent_todo (list/due/store symmetry), constraints (list/check + 4 mechanical rows run real cmds and pass),
  auto_audit (write/read path identical incl. canonical-vs-isolated split; menu badge loop closed), the
  loop_contract READ path (list/status/report correct), dispatch_stats math/window parsing (defect is
  upstream starvation), find-program usage-log wiring, axon-docs-gen's 6 real fields, workspace-backup's
  PUSH one-liner + gate-pass + autonomous-git carve-out confinement + correct failure-branch withholding.
- lint-path-vars: 24 defined, 0 violations. Health/backup/drift/igap warning wiring in menu (probed fields
  exist). session-summary's SAVE side (L:last-session-summary readers in BOOT/menu) correctly wired.

## COULD-NOT-VERIFY (no silent omissions)
- Mutating subcommands end-to-end (todo add/done, loop-contract define/iterate, constraints add, memory
  rollback success, usage record) — not executed under the read-only constraint; assessed from source.
- Root cause of the never-written usage-log (calls fail at runtime vs the calling lines never execute) — no
  runtime program logs to attribute it.
- AXON-LANG interpreter leniency: several shape/field mismatches MAY partially self-heal because programs are
  LLM-interpreted (fuzzy field mapping, blank-render vs halt on undefined keys). Severities assume the
  contract-as-written, per the audit bar. `≡` case-sensitivity, WRITE parent-dir auto-creation, and
  `EXEC(prog:section)` return semantics are LANG-underspecified — noted where they affect a severity.
- Synapse `inputs-count`/`outputs-count` counting convention is defined nowhere found → those mismatches
  stay LOW, not graded up.

---

## Cross-cutting patterns (for the plan phase)
1. **Reader/writer contract drift in the reporting layer** (the dominant class): dashboards + session
   programs read W:/L: keys and tool fields no producer writes. A single "reporting-contract" lint —
   assert every `RETRIEVE(W|L:key)` in a program has a writer somewhere, and every `.field` read off a
   TOOL() result is in that tool's real output schema — would catch nearly all of C2/C3/C4 + the menu/
   status/stats/gain HIGHs at once. (Generalizes bugfix01's C9/C12 and PR-026's status work.)
2. **False success after a gate-blocked op** (workspace-backup) — bugfix01's H25 recurring; worsened by the
   destructive-git gate bugfix01 added. Any program running a shell/git op must check verdict/exit_code,
   never substring-sniff. A lint over `TOOL(shell,…)` result handling would generalize it.
3. **Half-deprecated blocks** (find-program semantic-search): commented-out producer, live consumer over the
   now-undefined vars. bugfix01 saw this shape too (deprecated semantic-search in code-dev-plan).
4. **Orphaned duplicate tools writing to the wrong path** (workspace/tools/drift.py vs tools/drift.py) — the
   drift-log the reporting layer reads is written by a copy the registry doesn't point at.

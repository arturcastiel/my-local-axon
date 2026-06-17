# code-dev — SAFETY + STRUCTURE subcommands

## How these commands actually run (read this first)

These 13 subcommands are **agent-interpreted `.md` neurons** in
`workspace/programs/code-dev-<name>.md`. They are dispatched by the AXON runtime when you
type `code-dev <cmd>` inside an AXON session — **they are NOT `python3 axon.py` tools**.
`axon.py`/`tools/REGISTRY.json` only knows the *backing* Python tools the neurons call
(`dont-do-lint`, `dry-run-lint`, `shadow`, `dag`, `meta`, `clock`, …).

Consequences:
- Worked examples for the neurons are shown as **labeled session-transcripts** (their exact
  `→` OUTPUT lines).
- Worked examples for the **backing safety tools** are real `python3 axon.py …` runs with
  captured output (see the two verified blocks at the end).

Inputs are passed as `W:` working-memory keys (the AXON arg-binding convention). The
`QUERY(user): "…"` lines are interactive prompts shown when the corresponding `W:` key is unset.

---

## Command reference

### `code-dev audit` — `code-dev-safety-audit.md` (role: mutator, ACTIVE) · Phase 5
Cross-reference every PR spec (`03-prs/PR-NNN.md`) against `04-log.md` entries + shadow
evidence; produce a status table (done/partial/missing/drifted) and an issues report.

| Form | Effect |
|------|--------|
| `code-dev audit` | full audit of all PRs (W:code-dev-audit-cmd=full) |
| `code-dev audit [PR-N]` | audit a single PR (W:code-dev-audit-pr) |
| `code-dev audit diff` | only PRs with issues / not fully implemented (W:code-dev-audit-cmd=diff) |

- **Precondition:** `L:cognition-frame ≡ "AXON-OS"`, `W:code-dev-project ≠ ∅`, `02-prs.md` exists.
- **Reads:** `_meta.md`, `01-study.md`, `02-plan.md`, `02-prs.md`, `04-log.md`, `03-prs/*`, `shadow/`.
- **Status logic:** missing-spec → not-logged → partial (<0.5 coverage) → mostly-done → implemented/code-done. Per-PR confidence = weighted sum ×10.
- **Effect:** **non-destructive** read/report, but **QUERYs before WRITE** of `{project}/05-audit.md`. Emits SHADOW COVERAGE block (G2/G4) and a G5 release-readiness gate. Logs event `audit`.
- **QUERY:** `"Write audit report for {project}? [yes / skip]"` — `skip` HALTs without writing.

### `code-dev check-structure` — `code-dev-safety-audit-structure.md` (mutator, ACTIVE)
Audit project tree for v4 schema compliance.

| Form | Effect |
|------|--------|
| `code-dev check-structure` | audit only (read-only) |
| `code-dev check-structure --fix` | create missing stubs/dirs (W:code-dev-check-structure-fix=true); preserves existing |

- **Required project files:** `_meta.md, _profile.md, _dont-do-seeds.md, masterplan.md, 04-log.md, 05-branches.md`; dirs `03-prs/, shadow/, phases/`.
- **Required per-phase:** `_meta.md, _files.md, _dont-do.md, _decisions.md, _deviations.md, reviewer-state.md, 01-study.md, 02-plan.md, 02-prs.md`.
- **Effect:** prints missing list; with `--fix` WRITEs stub files / MKDIRs missing dirs and logs `repaired N stub(s)`.

### `code-dev preflight` — `code-dev-preflight.md` is an **ALIAS STUB** → `code-dev-safety-preflight.md` (mutator, ACTIVE)
Gates **0–10** pre-push validation. **Never executes builds/linters** — surfaces them as HUMAN actions.

| Flag | Effect |
|------|--------|
| `code-dev preflight` | all 11 gates (W:code-dev-preflight-mode=full) |
| `code-dev preflight --quick` | gates 0–4 only (mode=quick) |
| `code-dev preflight --mode=summary` | one-line `OK\|WARN\|BLOCK` from `_meta.last-gate-tally` (cheap, no gate runs) |
| `code-dev preflight --gate N` | W:code-dev-preflight-gate=N |
| (internal) `mode=check-only` | stores `W:code-dev-preflight-result`, no render |

Gates: 0 branch-sync · 1 shadow-fresh · 2 scope (EXEC review-scope) · **3 dont-do (FAIL-CLOSED via `dont-do-lint`)** · 4 self-review (EXEC review-self) · 5 review-guide · 6 reviewer-pr (FAIL-CLOSED if PR unresolved) · 7 reviewer-all · 8 tests (manual) · 9 cross-repo · 10 linter (HUMAN-only). `passed = (fails == 0)`. Manual/skip never fail.

### `code-dev branch` — `code-dev-branch.md` (mutator, ACTIVE)
Detect/repair drift between `_meta.md branch` and git's current branch.

| Form | Effect |
|------|--------|
| `code-dev branch` / `code-dev branch check` | read-only diff table (W:code-dev-branch-cmd=check) |
| `code-dev branch sync` | update `_meta.md` (+ phase `_meta.md`) branch from git, append `04-log.md` |

- **Reads git via TOOL(shell):** `git -C {codebase} branch --show-current`, `rev-parse --short HEAD`, `rev-parse --is-inside-work-tree`. States: `not-a-repo` / `detached/<sha>` / `<branch>` / `unknown`.
- **Drift** = meta-branch ≠ git-state (when repo). **Drift hard-blocks `pr-ready` and `preflight` (Gate 0).**
- Legacy v1 projects (`schema-version: v1` or `legacy: true`) short-circuit: tracking unavailable.
- `sync` FAILs on not-a-repo/unknown; no-ops when already in sync.

### `code-dev merge` — `code-dev-merge.md` (mutator, ACTIVE)
Mark a PR or phase merged; archive snapshots.

| Flag | Effect |
|------|--------|
| `code-dev merge [PR-NNN]` | single PR: REPLACE-LINE col 5→merged in `02-prs.md`, APPEND `05-branches.md` row, APPEND `04-log.md`, `_events.log pr-merged {pr}` |
| `code-dev merge --phase` | W:code-dev-merge-phase=true: phase `_meta.md` status/workflow-step→merged, MOVE `phases/{phase}/snapshots` → `archive/snapshots/{phase}-{date}` |

- **whatif-guarded:** `IF RETRIEVE(W:code-dev-dry-run) ≡ true →` renders plan + DONE before mutating.
- NEXT hints: `code-dev cascade`, `code-dev changelog`.

### `code-dev cascade` — `code-dev-cascade.md` (mutator, ACTIVE)
Post-merge: notify downstream phases + surface prohibition-promotion candidates.

- `code-dev cascade` (no flags). Finds phases whose `_meta.predecessors` CONTAINS current phase; APPENDs a "Cascade note" to each downstream `_meta.md` (re-read study, refresh shadow, check impact).
- Lists active (non-retired) prohibitions in the current phase as promotion candidates → suggests `code-dev dont-do promote "<text>" --cascade`.

### `code-dev divide` — `code-dev-divide.md` (mutator, ACTIVE)
Split a phase into two, or a PR into N sub-PRs.

| Form | Effect |
|------|--------|
| `code-dev divide phase <a> <b>` | snapshot source → split into 2 sibling phases (copy `_meta/_files/_dont-do/_decisions`, stub study/plan/prs), mark source `status: divided`, append masterplan + log, `dag split` if `DAG.json` |
| `code-dev divide pr <PR-NNN> <count>` | create `count` stub sub-PR specs (next free PR numbers), append "Divided" note + log, `dag split` on `03-prs/DAG.json` |

- W: keys: `code-dev-divide-kind / -a / -b / -pr / -count`.
- **whatif-guarded** (guard before first MKDIR/COPY/WRITE). QUERY confirm before phase split.

### `code-dev combine` — `code-dev-combine.md` (mutator, ACTIVE)
Combine two phases into one; snapshot + undo.

| Flag | Effect |
|------|--------|
| `code-dev combine <a> <b> <new>` | snapshot `phases/` → merge (`_files`/`_dont-do`/`reviewer-state` union+dedup; `_decisions` sequential; study/plan/prs concatenated with dividers; `03-prs/` union), mark sources `status: combined`, `dag merge` |
| `code-dev combine --dry-run <a> <b> <new>` | print plan only, no changes (W:code-dev-combine-mode=dry-run) |
| `code-dev combine --undo` | restore latest `archive/combine-snapshots/*` over `phases/` (mode=undo; QUERY confirm) |

- W: keys: `code-dev-combine-mode / -a / -b / -new`.
- **whatif-guarded.** Note: `--dry-run` (combine's own preview) is distinct from `code-dev whatif combine` (the global dry-run flag honored by the C8 guard).

### `code-dev partition` — `code-dev-partition.md` (mutator, ACTIVE) — **dispatcher only**
Unified topology verb; re-keys W: vars and EXECs divide/combine.

| Form | Routes to |
|------|-----------|
| `code-dev partition split phase <a> <b>` / `split pr <PR> <count>` | EXEC `code-dev-divide` |
| `code-dev partition merge <a> <b> <new>` / `merge --dry-run …` | EXEC `code-dev-combine` (run/dry-run) |
| `code-dev partition undo` | EXEC `code-dev-combine` (undo) |

- W: keys: `code-dev-partition-action / -kind / -a / -b / -pr / -count / -new / -mode`. Owns no mutation logic of its own.

### `code-dev hold` — `code-dev-hold.md` (mutator, ACTIVE) — pause/resume (replaces freeze+thaw)
| Form | Effect |
|------|--------|
| `code-dev hold "<reason>"` | freeze: sets W:code-dev-freeze-mode=freeze + reason, EXEC `code-dev-safety-freeze` |
| `code-dev hold release` | thaw: W:code-dev-freeze-mode=thaw, EXEC `code-dev-safety-freeze` |
| `code-dev hold show` | render all phases whose `workflow-step` CONTAINS "frozen" (read-only) |

- W: keys: `code-dev-hold-sub`, `code-dev-hold-arg`.

### `code-dev freeze` / `code-dev thaw` — `code-dev-safety-freeze.md` (mutator, ACTIVE) — the engine behind `hold`
| Form | Effect |
|------|--------|
| `code-dev freeze "<reason>"` | snapshot both `_meta.md` files → workflow-step→`frozen  # was: <prior>` (phase + project), APPEND `04-log.md` + `_events.log phase-frozen`, two `_actions.log` rows (undo) |
| `code-dev thaw` | parse `# was:` from each meta, restore prior workflow-step, `_events.log phase-thawed` |

- W: keys: `code-dev-freeze-mode` (freeze\|thaw), `code-dev-freeze-reason`.
- Also drives a session checkpoint/transition (`TOOL(session,…)`). Careful undo design: separate `_actions.log` rows per snapshotted meta, and thaw parses each meta's own `# was:` value (phase ≠ project allowed).

### `code-dev dont-do` — `code-dev-dont-do.md` (mutator, ACTIVE)
Manage phase prohibitions. **Capture discipline is enforced** (preflight Gate 3 + `R_DONT_DO`, both via the shared `dont-do-lint` parser).

| Form | Effect |
|------|--------|
| `code-dev dont-do` / `… list` | list active prohibitions for current phase |
| `code-dev dont-do add "<text>"` | **WARN** — prose-only, UN-ENFORCEABLE, will BLOCK Gate 3 |
| `code-dev dont-do add "<text>" --match "<literal\|/regex/>"` | born-enforceable: writes indented `match:` line (W:code-dev-dont-do-match) |
| `code-dev dont-do add "<text>" --semantic` | un-tokenizable: writes `review: human` (W:code-dev-dont-do-semantic); R_DONT_DO escalates to human review on a diff |
| `code-dev dont-do retire "<id-or-text>"` | `~~strikethrough~~` the bullet |
| `code-dev dont-do promote "<id>"` | copy bullet (carrying its `match:`/`review:` sub-line) to project `_dont-do-seeds.md` |
| `code-dev dont-do promote --cascade` | promote + append to every other active phase's `_dont-do.md` (W:code-dev-dont-do-cascade=true) |
| `code-dev dont-do demote "<text>"` | remove from seeds |

- **Classification rule:** a bullet is *classified* iff it has `match:` (tokenized) OR `review:` (semantic). An unclassified prose bullet is the only capture failure. Retired (`~~…~~`) bullets are ignored by every consumer.

### `code-dev whatif` — `code-dev-whatif.md` (mutator, ACTIVE) — the real dry-run engine
`code-dev whatif <cmd> [args…]` — sets `W:code-dev-dry-run = true`, arms the substrate flag
`workspace/memory/working/dry-run.flag` (TTL-guarded 15 min, used by `_axon_io.atomic_write`),
EXECs `code-dev-<cmd>`, then clears the flag and renames it `.dry-run.flag.done`, and prints
the intended-writes manifest (`_dry-run-manifest.jsonl`, last 10) — **no writes performed**.

- W: key: `code-dev-whatif-cmd`. Programs that observe `W:code-dev-dry-run` render the plan and DONE before any mutating op. The 4 whatif-reachable mutators are divide/combine/merge/partition (enforced by `dry-run-lint`).

### `code-dev-dry-run.md` — **ORPHAN STUB** (status: STUB, role: reader)
Not implemented (logged for PR-119). It only `LOG(WARN, "stub only")` and prints
`▶ code-dev-dry-run · stub (not yet implemented)`. **The functional dry-run is `code-dev whatif`**, not this. Do not treat `code-dev-dry-run` as a working command.

---

## Verified examples (real `python3 axon.py` runs — backing safety tools)

These exercise the Python tools the SAFETY neurons depend on. All read-only / non-mutating.

### 1. `dry-run-lint report` — proves whatif's "no writes" promise holds for divide/combine/merge/partition
The C8 contract: every whatif-reachable mutator must check `W:code-dev-dry-run` **before** its first mutating op.

```
$ python3 axon.py dry-run-lint report
{
  "ok": true,
  "checked": 4,
  "missing_programs": [],
  "violations": [],
  "hint": "all whatif-reachable mutators are dry-guarded"
}
# exit 0
```

`dry-run-lint check` (the BLOCK gate) returns the same JSON and exits 0 because there are no
violations. The 4 checked programs are exactly `code-dev-{divide,combine,merge,partition}.md`
(the `MUTATORS` tuple in `tools/dry_run_lint.py`).

### 2. `dont-do-lint classify` — the Gate-3 capture classifier (tokenized / semantic / prose)
Run against the v4 schema doc (which contains the canonical prohibition examples):

```
$ python3 axon.py dont-do-lint classify workspace/programs/_code-dev-schema-v4.md --json
{"path": ".../_code-dev-schema-v4.md", "exists": true,
 "total": 24, "tokenized": 2, "semantic": 1, "prose": 21, "findings": [ ... 21 prose bullets ... ]}
# exit 0  (classify always exits 0 — informational)
```

It correctly counts the 2 `match:` examples as **tokenized**, the 1 `review: human` example as
**semantic**, and the rest as **prose** (un-enforceable). `dont-do-lint lint <path>` uses the
same parser but is **fail-closed** (exit 1 on any prose-only bullet) — this is precisely what
preflight **Gate 3** invokes. On a missing file it is a clean pass:

```
$ python3 axon.py dont-do-lint lint /nonexistent/_dont-do.md --json
{"path": "/nonexistent/_dont-do.md", "exists": false, "total": 0, "tokenized": 0, "semantic": 0, "prose": 0, "findings": []}
# exit 0
```

---

## Verified examples (session-transcripts — agent-interpreted neurons)

> Reconstructed from each neuron's exact `→` OUTPUT lines. No live `W:code-dev-project` was
> loaded during this study, so these are labeled transcripts, not captured agent runs.

### `code-dev branch check` (transcript)
```
▶ AXON / code-dev branch check  ·  [PROJECT: axon-plus]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  BRANCH STATE
  ─────────────────────────────────────────────
  git current     feature/safety-gates
  _meta.md branch main

  ⚠  BRANCH DRIFT
     git is on 'feature/safety-gates', _meta.md says 'main'.
     Repair: code-dev branch sync
     This drift will hard-block: code-dev pr-ready, code-dev preflight
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### `code-dev preflight --quick` (transcript — gates 0–4)
```
▶ AXON / code-dev preflight  ·  [PR-002]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Gate 0 — branch-sync      feature/safety-gates
  ✓ Gate 1 — shadow-fresh     all fresh
  ✓ Gate 2 — scope            changed files ⊆ _files.md
  ✗ Gate 3 — dont-do          1 of 3 un-enforceable — tokenize: code-dev dont-do add "<text>" --match "<literal|/regex/>"
  ✓ Gate 4 — self-review      no gaps vs spec

  SUMMARY  pass:4  fail:1  warn:0  manual:0  skip:0

  ✗ NOT READY — address failing gates above.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### `code-dev hold show` (transcript)
```
▶ AXON / code-dev hold show  ·  [axon-plus]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ❄ phase-3-enforcement  —  workflow-step: frozen  # was: build
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### `code-dev whatif merge --phase` (transcript — dry-run path, no writes)
```
▶ AXON / code-dev whatif merge    (no writes will occur)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  (dry-run) PLAN — would merge the PR branch artifacts + update logs/registries.
  Targets resolved above are rendered, not written. (dry-run ended — state unchanged)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  (dry-run ended — state unchanged)
```

---

## Relevant file paths (all absolute)
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-safety-audit.md`
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-safety-audit-structure.md`
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-safety-preflight.md` (engine)
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-preflight.md` (alias stub)
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-safety-freeze.md` (engine)
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-hold.md`
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-branch.md`
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-merge.md`
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-cascade.md`
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-divide.md`
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-combine.md`
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-partition.md`
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-dont-do.md`
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-whatif.md`
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-dry-run.md` (orphan stub)
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/_code-dev-schema-v4.md` (v4 fields: match:/review:/_actions.log/_events.log)
- `/home/arturcastiel/projects/new-axon/axon/tools/dry_run_lint.py` (whatif C8 contract)
- `/home/arturcastiel/projects/new-axon/axon/tools/dont_do_lint.py` (Gate-3 classifier)
- `/home/arturcastiel/projects/new-axon/axon/tools/_axon_io.py` (atomic_write dry mode: lines 69–75, 122, 179)
- `/home/arturcastiel/projects/new-axon/axon/axon.py` (CLI dispatcher — note: `code-dev` is NOT a registered tool here)

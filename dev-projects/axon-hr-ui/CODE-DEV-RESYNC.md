# Code-dev Re-sync / Reanchor — Procedure (SOP)

> How to bring a code-dev project back into a single coherent truth after work has happened:
> detect drift, split the DAG, register PRs that were appended mid-program (AXON's **and** the
> owner's), reanchor the written docs, and **prove the per-PR workflow was not skipped**.
> Reusable for any project; `axon-hr-ui` is the worked example (2026-06-23 drift correction).
> Grounded in real tools: `tools/dag.py`, `tools/phase_model.py`, the `code-dev-state-*` programs,
> the crucible gate. See `AUTONOMOUS-FLOW.md` for the rules this procedure enforces.

---

## 0. The four sources of truth (and how they drift apart)

| Source | Answers | Lives in |
|--------|---------|----------|
| **DAG** `03-prs/DAG.json` | what PRs EXIST + their split/deps/status | the node graph |
| **git** (`origin/main` + branches) | what actually MERGED | the repo |
| **meta/phases** `_meta.md` · `_phases.json` | which ladder phase is active | project scaffold |
| **docs** `BUILD-STATE.md` · `FOLLOWUPS.md` · READMEs | the human-readable narrative | project dir |

**Drift** = any two disagree. The most dangerous is **code-first drift**: code lands (working tree or even
merged) with **no DAG node** — the work is invisible to the plan. Catching it is step 1.

---

## 1. Detect drift (read-only — run all of these first)

```bash
PROJ=my-axon/dev-projects/<slug>;  DAG=$PROJ/03-prs/DAG.json

# a. ladder / phase split-brain (meta.phase vs _phases.json manifest)
python3 tools/phase_model.py check --project $PROJ            # ok:true required

# b. DAG structural integrity (cycles, dangling edges, orphans)
python3 tools/dag.py verify --file $DAG

# c. DAG ledger vs reality
python3 tools/dag.py summary --file $DAG                      # totals by status/kind

# d. git truth — what merged vs what the DAG calls merged
git -C <codebase> log --oneline -20
git -C <codebase> branch --list "<slug>/*"                   # staged-but-unmerged branches
git -C <codebase> status --porcelain                         # UNCOMMITTED work = prime drift suspect

# e. context reconstruction after a break/compaction
#    run the program:  code-dev-state-resume   (reads 10 layers → fixed briefing)
```

**Drift signals to hunt for:**
- Uncommitted/untracked files in `git status` that **no DAG node** describes → code-first drift.
- A DAG node `status: merged` with **no matching commit** in `git log` → phantom merge.
- A commit on `main` whose work maps to **no node** → untracked merge.
- `phase_model check` `ok:false` → meta/manifest split-brain.
- `BUILD-STATE.md` "next" ≠ the DAG's open nodes → narrative drift.

---

## 2. Classify every divergence (one line each, before touching anything)

For each item found, write: `what it is · which source has it · which sources are missing it · is it AXON or owner work · kernel or non-kernel`. Example from 2026-06-23:

```
AXON-COLDBOOT (boot_friction + cold_stranger + fixes) · in: working tree · missing: DAG, docs · AXON · non-kernel
dag-summary ledger (dag.py + code-dev-state-status) · in: working tree · missing: DAG · AXON · non-kernel
T0 my-axon-gate boot halt (finding) · in: a transcript · missing: DAG, FOLLOWUPS · OWNER · kernel boot-flow
```

This list IS the reanchor work-list.

---

## 3. Split the DAG — register the work as nodes (the core of reanchor)

**Rule: one logical PR = one node. Do NOT blob unrelated work into one node.** Decide splits first:
- Independent concerns → separate nodes (coldboot ≠ dag-summary).
- A finding that triggers a design change → its **own** `finding` node, linked `informs` to what it feeds.
- A node that grew too big → `dag split`. A standalone that got absorbed → `dag fold-in`.

### 3a. Add a node
The `add-node` subcommand validates structure but its `--status` enum is limited
(`pending|active|complete|failed|skipped|merged|stale`) and it can't set `disposition`/`gate`. The
project uses richer free-form statuses (`todo`, `staged`, `todo-stage`, `gated`, `owner-open`, `deferred`).
**Two ways:**

```bash
# (i) tool path — for simple nodes
python3 tools/dag.py add-node --file $DAG --id PR-NNN-slug --kind pr \
    --name "…full description…" --label "short label" --status pending

# (ii) structured-edit path — for nodes carrying disposition/gate/project-vocab status
#      load JSON → append node dict (same shape as siblings) → dump indent=2 → verify.
#      ALWAYS stamp disposition "RETRO-REGISTERED <date> (drift correction)" so the DAG never
#      pretends node-first was followed. Then:
python3 tools/dag.py verify --file $DAG
```

Node shape (match siblings exactly):
```json
{ "id":"PR-NNN-slug", "kind":"pr|gate|finding", "name":"…", "label":"…",
  "status":"staged", "gate":"owner: …"(optional), "disposition":"RETRO-REGISTERED …", "child-dag":null }
```

### 3b. Wire edges (the splits must connect)
```bash
python3 tools/dag.py add-edge --file $DAG --from PR-013 --to PR-NNN-slug --kind informs
# edge kinds (file vocab): depends · unblocks · informs · folds-into · gates
```
- A dropped tool **realized** by new code → `folds-into` from the dropped node.
- A preflight/finding that feeds a gated super-node → `informs`.
- A hard prerequisite → `depends`. An owner gate → `gates`.

### 3c. Splitting / folding existing nodes
```bash
python3 tools/dag.py split   --file $DAG --id PR-XX --into-ids PR-XXa,PR-XXb --new-labels "a,b"
python3 tools/dag.py fold-in --file $DAG --child-id PR-YY --into PR-ZZ
```

---

## 4. PRs appended **in the middle** of the program

Work discovered mid-run (a new bug, a follow-on, an owner request) is **not** an excuse to skip the DAG.
Insert it as a node **the moment it's identified**, before code:

1. `dag add-node` the new PR (status `todo`) — give it a real id (`PR-NNN` or a descriptive `PR-<slug>`).
2. `add-edge` its deps: what must merge first (`depends`), what it informs.
3. If it changes the critical path, update `"critical-path"` in `DAG.json`.
4. Only then run the per-PR loop (§7). The node existed **before** the merge → no drift.

> If code already landed before the node existed (it happens), still create the node, but mark
> `disposition: "RETRO-REGISTERED <date>"` so the gap is auditable. Retro-registration repairs the
> record; it does not make code-first OK — fix the habit going forward (§7 guard).

---

## 5. Human (owner) activities are PRs too

The DAG tracks **all** work, not just AXON's. Owner-only work is first-class:
- **Owner task** → a node with `status: owner-open` (e.g. a design call, a manual run).
- **A precondition the owner must clear** → a `kind: gate` node (e.g. `GATE-STRANGER`), wired
  `gates` → whatever it blocks.
- **Kernel merges** AXON stages → `status: todo-stage` (AXON builds, owner runs `ship.sh` to merge).

So the lanes (see `AUTONOMOUS-FLOW.md` §6) all live in one DAG:
```
AXON   nodes: todo / staged           (autonomous loop)
SHARED nodes: todo-stage              (AXON builds → owner merges, kernel floor)
OWNER  nodes: owner-open / gated      (design / gate / stranger session / kernel merge)
```
A reanchor is incomplete if owner work is only in prose — it must be a node, or it can't gate anything.

---

## 6. Reanchor the written docs to the DAG (make narrative = nodes)

After the DAG is right, bring the docs into agreement (these are `my-axon/`, no dev-mode gate):

| Doc | Reanchor action |
|-----|-----------------|
| `_meta.md` | rewrite `next-action:` to point at the open DAG nodes; bump `last-program`/`last-ts`/`updated` |
| `_phases.json` / `_meta.phase` | reconcile so `phase_model check` is `ok` (study/plan/pr/log/audit) |
| `BUILD-STATE.md` | add a dated SESSION section: what happened, root-causes, which nodes it created |
| `councils/FOLLOWUPS.md` | log every finding + deferred item as a tracked entry (not dropped) |
| `03-prs/DAG.md` | **regenerate** from JSON — never hand-edit: `dag render --file $DAG` |
| READMEs | for any new subsystem (e.g. `benchmark/cold-start/README.md`) so it's self-documenting |

**Golden rule:** `DAG.md` is auto-generated (`<!-- do not hand-edit -->`). Edit `DAG.json`, then `dag render`.

### 6a. The numbered ladder deliverables (01 → 05 + masterplan)

The `study → plan → pr → log → audit` ladder leaves numbered artifacts. After the DAG is right, sweep
them so the plan narrative matches the nodes. **Principle: these REFERENCE the DAG, they do not mirror it**
— never hand-copy 30 nodes into a doc (that re-creates the dual-SSOT you just fixed). Banner the canonical
source, then add only the delta.

| File | Where | Reanchor action |
|------|-------|-----------------|
| `phases/study/01-study.md` | study output | **Append a dated addendum** for findings discovered mid-build (e.g. a cold-start finding). Don't rewrite history — add `## Addendum — <date>`. |
| `phases/study/02-prs.md` | the PR list | **(1)** add a header banner: *"canonical PR status now lives in `03-prs/DAG.json`; this list is the original plan + mid-stream additions"* + a one-line `original-15 → DAG` reconciliation. **(2)** append a `## Mid-stream additions` section with a full entry per NEW PR (same shape as existing entries: Status · Scope · Why · Edges · Next). |
| `phases/study/02-plan.md` | the plan | **Append a reanchor note**: the plan delta + "canonical status = DAG; sync via CODE-DEV-RESYNC.md". |
| `03-prs/DAG.json` / `.md` | nodes | §3 (add nodes) + `dag render` (never hand-edit `.md`). |
| `04-log.md` | impl log | **Append a dated `## SESSION <date>` entry**: event (e.g. "drift detected + corrected"), the work done, which nodes it created, and the honest status (e.g. "staged, uncommitted; per-PR loop still owed"). |
| `05-branches.md` | branch↔PR registry | **Add one row per node** that will get a branch — including `(owner)`/`(to-stage)` placeholders for OWNER and kernel-staged nodes, so the registry shows ALL lanes, not just AXON's. |
| `masterplan.md` | consolidated plan | **Append an addendum** naming the mid-stream PRs + pointers to `CODE-DEV-RESYNC.md` / `AUTONOMOUS-FLOW.md`. |

Rules for the ladder sweep:
- **Mid-stream PR → `02-prs.md` AND the DAG, together.** A new PR entry in `02-prs.md` with no DAG node (or
  vice-versa) is itself drift. Add both in the same pass (§3 + this table).
- **Human/owner PRs appear in `05-branches.md` too** — as `(owner) n/a | PR-… | … | owner-open | …` rows.
  A registry that lists only AXON branches hides half the work.
- **Append, don't overwrite.** Study/plan/log are historical records; add dated sections, never rewrite
  prior entries — the audit trail is the point.
- **Re-stamp the scaffold pointers:** after the sweep, update `_meta.md` `next-action` / `last-program` /
  `last-ts` / `updated` (these drive `resume` and the menu), and confirm `phase_model check` stays `ok`.

---

## 7. Prove the workflow was **not** skipped

A node reaching `merged` must have evidence of the full per-PR loop (`AUTONOMOUS-FLOW.md` §3). Before
flipping any node to `merged`, confirm — and record in the commit / BUILD-STATE:

```
[ ] DECIDE   — open design question? → HR-council verdict recorded (or "none")
[ ] IMPLEMENT— branch  <slug>/<node-id>-<slug>  exists; one node = one branch
[ ] AUDIT    — 2–3 grounded HR seats (direct Agent calls, prompt + ABSOLUTE paths) returned PASS
[ ] TEST     — crucible / full suite GREEN (paste the pass/fail line)
[ ] MERGE    — squash-merge on green; commit trailer = ONLY  Co-authored-by: AXON <axon@arturcastiel.github.io>
[ ]            no internal PR-N ref in the commit message (pre-commit hook blocks it)
[ ] DAG      — dag set-status <node> merged   +   git commit recorded on the node
```

**Skip-detection (run at every wave boundary):**
```bash
# any node 'merged' in the DAG must have a real commit; any commit must map to a node
python3 tools/dag.py summary --file $DAG          # merged count
git -C <codebase> log --oneline --since="<wave start>"   # cross-check 1:1 against merged nodes
```
A `merged` node with no commit, or a commit with no node, is a **skipped-workflow flag** → HALT + reconcile.
Kernel nodes must show `todo-stage → (owner ship.sh) → merged`, never an autonomous kernel merge.

---

## 8. Verify + close the reanchor

```bash
python3 tools/phase_model.py check --project $PROJ      # ok:true
python3 tools/dag.py verify  --file $DAG                # ok:true (orphan warns OK for standalone nodes)
python3 tools/dag.py render  --file $DAG                # regenerate DAG.md
python3 tools/dag.py summary --file $DAG                # ledger reads as expected
#   run the program:  code-dev-state-status            # DAG ledger line + phase + counts agree
```
Reanchor is **done** when: every working-tree/merged item maps to a node · every node's status matches
git · `phase_model check` ok · `DAG.md` regenerated · `_meta.next-action` points at open nodes · findings
logged · the **ladder deliverables (01–05 + masterplan) reference the DAG and carry the mid-stream
additions** (§6a) · and §7 evidence exists for everything `merged`.

---

## 9. Worked example — axon-hr-ui, 2026-06-23

```
DRIFT     : AXON-COLDBOOT (boot-friction L0 + cold_stranger L1 + 3 robustness fixes) and a
            dag-summary slice were built in the working tree with NO DAG nodes (code-first).
DETECT    : git status showed 8 uncommitted paths none of the 27 DAG nodes described.
SPLIT     : 3 nodes — PR-014a-coldboot (pr, staged), PR-DAG-LEDGER (pr, staged),
            PR-T0-bootflow (finding, owner-open).  Edges: PR-013 folds-into PR-014a-coldboot;
            PR-014a-coldboot informs PR-014 + PR-T0-bootflow; PR-T0-bootflow informs PR-014.
HUMAN-PR  : PR-T0-bootflow (kernel boot-flow design) registered as an owner-open node, not prose.
REANCHOR  : _meta.next-action rewritten · BUILD-STATE SESSION-cont section · FOLLOWUPS entry ·
            benchmark/cold-start/README.md · DAG.md regenerated · all marked RETRO-REGISTERED.
LADDER    : 01-study addendum (cold-start findings) · 02-prs banner + Mid-stream additions ·
            02-plan reanchor note · 04-log SESSION entry · 05-branches rows (incl. owner/to-stage) ·
            masterplan addendum.  All REFERENCE the DAG (no hand-mirror).
NOT-DONE  : nodes are 'staged' — §7 loop (HR-audit → crucible → branch → squash-merge) still owed
            before any flips to 'merged'. Retro-registration repaired the record, not the habit.
```

---

## Quick command reference
```bash
PROJ=my-axon/dev-projects/<slug>; DAG=$PROJ/03-prs/DAG.json
phase_model.py check --project $PROJ            # ladder ok?
dag.py verify   --file $DAG                      # structure ok?
dag.py summary  --file $DAG                      # ledger
dag.py add-node --file $DAG --id .. --kind pr --name ".." --label ".." --status pending
dag.py add-edge --file $DAG --from .. --to .. --kind informs
dag.py set-status --file $DAG --id .. --status merged
dag.py split    --file $DAG --id .. --into-ids a,b
dag.py fold-in  --file $DAG --child-id .. --into ..
dag.py render   --file $DAG                       # regenerate DAG.md (never hand-edit it)
# programs: code-dev-state-resume · code-dev-state-status · code-dev-next · code-dev-pr-sync
```

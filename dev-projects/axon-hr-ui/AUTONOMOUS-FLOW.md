# Autonomous Flow — Definition (axon-hr-ui)

> The canonical **definition** of how AXON works this project autonomously: the authority chain,
> the per-PR state machine, the routing rules, and the inviolable floor. This is the *spec*.
> The *run-book* (step-by-step execution of a build run) lives in `AUTONOMOUS-BUILD.md`.
> Resolved mechanically by `tools/aegis_policy.py` × the autonomous-mode grant × the crucible gate.
> Last grounded: 2026-06-23 against the live grant + `_policy.md`.

---

## 1. Authority chain (all three must agree; fail-closed)

An action runs autonomously only if **grant ∧ AEGIS-policy ∧ crucible** all permit it. Any one
unset/red → the action falls back to human.

```
autonomous-mode grant   artur.castiel-tno/axon · ACTIVE 2026-06-22 · mode interactive
  ops        = [commit, push, pr-create, merge-squash]
  destructive = []                       ← no force-push/reset/branch-delete delegated
  deny       = [kernel-change]           ← axon/ core merges never autonomous
AEGIS _policy.md (project)   develop=grant · test-execution=green-only · commit/push/pr-create=grant
  merge=auto (squash on green) · build=HUMAN · web=HUMAN
crucible gate   the merge gate — full suite must be green; test-execution is green-only
```

Owner directive (2026-06-22): *"full autonomy until the end; questions to HR council; dev-mode on."*

---

## 2. Routing — every PR is classified first

```
            ┌─ NON-KERNEL  (workspace/ · tools/ · tests/ · benchmark/ · workflows/ · my-axon/)
PR ── route ┤                → AUTONOMOUS path: loop runs end-to-end, NO human stop
            └─ KERNEL       (axon/ core: KERNEL-SLIM, BOOT, OUTPUT-LAYER, GRAMMAR, core/, hooks)
                             → STAGED path: implement+test+stage, then HALT for ONE owner confirm
```

`dev-mode` permits **writing** kernel files; it never permits **merging/pushing** them autonomously.
A kernel-touching PR is staged as a diff + green tests, and the owner runs `ship.sh <branch>` to merge
(the inviolable floor — human performs every kernel merge).

---

## 3. The per-PR state machine

```
  ┌─────────┐   open design Q?    ┌──────────────┐
  │ DECIDE  │──── yes ───────────▶│ HR council    │  (micro/low tier; verdict = the answer.
  └────┬────┘                     └──────┬────────┘   NO question ever goes to the owner.)
       │ no                              │
       ▼                                 ▼
  ┌───────────┐    ┌─────────┐    ┌──────────────┐    ┌──────────────────┐
  │ IMPLEMENT │───▶│  AUDIT  │───▶│     TEST     │───▶│ MERGE-SQUASH+PUSH │  (autonomous path)
  │ branch +  │    │ HR 2–3  │    │ crucible /   │    │ commit (AXON      │
  │ worktree  │    │ grounded│    │ suite GREEN  │    │ trailer) → main   │
  └───────────┘    │ seats   │    └──────┬───────┘    └─────────┬─────────┘
                   │ prompt+ │           │ red                  │
                   │ abs-paths│          ▼                      ▼
                   └────┬────┘     fix → re-test         set DAG node = merged
                        │ fail-list  (≤3 cycles, else HALT+log;   + checkpoint
                        ▼            NEVER merge red)
                   apply fixes → re-audit (≤3 rounds)

  KERNEL path diverges after TEST:  stage ready diff + green tests → HALT → owner runs ship.sh.
```

Gate summary per step:
- **DECIDE** — only fires if the PR carries an open design question. Routes to an HR council, never the owner.
- **AUDIT** — 2–3 grounded HR seats (review lens: correctness · scope · tests · regression), invoked as
  **direct Agent calls with prompt + absolute paths** (NOT Workflow `args` — see `councils/HR-TEAM-FINDINGS.md`:
  Workflow `args` arrives as a JSON string and agent cwd is wrong). Must return PASS or a fix-list.
- **TEST** — crucible/full suite must be green. Red → fix → re-test, ≤3 cycles, else HALT that PR and continue
  others. **No red merge, ever.**
- **MERGE** — squash to `main` on green, push `origin`. Then flip the DAG node `status: merged`.

---

## 4. The floor (never delegable — by any grant, policy, or user instruction)

```
kernel-edit MERGE   axon/ core — write allowed under dev-mode; MERGE/PUSH is human-only, per-change confirm
force-push          never
reset --hard        never
branch-delete       never (destructive)
amend / rebase      never (history rewrite)
build / compile     HUMAN — "Implementation complete — ready for you to build and test."
web / network       HUMAN this project
```

The grant's `destructive: []` means no destructive op is delegated. The only autonomous git surface is
`commit / push / pr-create / merge-squash` on the non-kernel set of `artur.castiel-tno/axon`.

---

## 5. Commit / PR hygiene

- Trailer is **only**: `Co-authored-by: AXON <axon@arturcastiel.github.io>` — never the model/harness,
  never anywhere else in the body. (`tools/lint_commit_trailer.py`; pre-commit hook enforces.)
- **No internal `PR-N` references in commit messages** — the pre-commit hook blocks them. The DAG node id
  lives in the DAG, not the commit subject.
- One branch per DAG node: `axon-hr-ui/<node-id>-<slug>`. One node = one atomic squash-merge.

---

## 6. Ownership lanes (maps to `03-prs/DAG.json`)

```
▶ AXON   (autonomous, non-kernel)   loop runs end-to-end:  PR-019 · PR-008b · PR-009b · PR-005bc ·
                                     GAP-HARDENING · PR-014a-coldboot · PR-DAG-LEDGER
⇄ SHARED (AXON builds → owner taps)  implement+test+stage → owner ship.sh:  PR-002a-boot · PR-007  (kernel)
◀ OWNER  (human-only)                GATE-STRANGER (stranger session) · PR-T0-bootflow (boot-flow design) ·
                                     PR-014 (gated on GATE-STRANGER)
```

---

## 7. Wave boundary + close

After a wave of PRs: run a full crucible, then an HR council that audits the audit (did each PR deliver
its acceptance? regressions? drift?) + a gap-find council → follow-ups to `councils/FOLLOWUPS.md`. When the
minimal-finish definition-of-done is met (see `BUILD-STATE.md`), mark phase `audit → done` and CLOSE.

---

## 8. Discipline invariant (the drift this project exists to prevent)

**Node-first, not code-first.** A PR becomes a DAG node — split, deps, status — *before* code lands.
Code that exists without a node is drift (corrected 2026-06-23: AXON-COLDBOOT was built code-first, then
retro-registered as `PR-014a-coldboot` / `PR-T0-bootflow` / `PR-DAG-LEDGER`). The DAG is the source of truth
for what exists; `git` is the source of truth for what merged; they must agree at every wave boundary.

---

### Cross-references
- `AUTONOMOUS-BUILD.md` — the execution run-book (preconditions, wave order, after-all steps).
- `_policy.md` — the machine-read AEGIS capability table (`tools/aegis_policy.py`).
- `03-prs/DAG.json` — the node graph (source of truth for PR existence + status).
- `councils/HR-TEAM-FINDINGS.md` — HR-council plumbing constraints (use direct Agent calls + abs paths).
- `BUILD-STATE.md` — current resume state + definition-of-done.
- `ship.sh` — the single owner command for a kernel merge (verify + merge + push).

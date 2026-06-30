# DAG Position & Next-Steps — Procedure (SOP)

> Given a coherent DAG (run `CODE-DEV-RESYNC.md` first if it might be drifted), answer three questions:
> **Where are we? What can be done right now? Who does each piece — AXON or the owner?**
> This is the *orchestration* read of the DAG (the ready-frontier), distinct from the *reanchor* read.
> Reusable for any project; `axon-hr-ui` is the live worked example. Pairs with `AUTONOMOUS-FLOW.md`
> (the per-PR loop you run once a node is chosen).

---

## 1. The model — frontier, not a list

A DAG is not a to-do list; it's a partial order. At any moment most open nodes are **blocked** by an
unmet prerequisite. The few that are **ready** are the only things that can actually start. The job is to
compute that ready set and split it by who can act.

```
node status ──► CLOSED   = merged | done | dropped | deferred      (not actionable)
                OPEN     = everything else
OPEN node is  ──► READY   if every HARD prerequisite is CLOSED       ← the frontier
                BLOCKED  otherwise                                   (named by what blocks it)
HARD prerequisite of N = every edge  from→N  with kind ∈ {depends, gates}
                         (informs / folds-into are informational, NOT blockers)
```

> Edge direction convention (this repo): `{from: A, to: B, kind: depends}` means **B depends on A** —
> `from` is the prerequisite, `to` is the dependent. `gates` works the same: the gate is the prerequisite.

---

## 2. Lane split — who can act on a ready node

Classify each ready node by `status` → lane (see `AUTONOMOUS-FLOW.md` §6 for the authority behind each):

```
status todo | staged          → ▶ AXON    autonomous (non-kernel): run the full per-PR loop, no human stop
status todo-stage             → ⇄ SHARED  AXON builds + stages → OWNER runs ship.sh (kernel merge = floor)
status owner-open | gated     → ◀ OWNER   human-only: design call · gate · stranger session · kernel merge
```

A ready node in the AXON lane is something **I can start now**. A ready node in the OWNER lane is something
**only you can do** — and it often unblocks a whole subtree (a gate). SHARED needs both, in sequence.

---

## 3. Rank the frontier (what to do first)

Within the actionable set, order by:
1. **On the critical path** (`DAG.json "critical-path"`) — these gate the most downstream work.
2. **Closest to merge** — `staged` (built + tested, uncommitted) before `todo` (not started): banking
   finished work shrinks risk and the working tree.
3. **Unblocks the most** — a node many others `depends`/`gates` on beats a leaf.
4. Then stable by id.

The recommended *next action* is the top-ranked **AXON** node (I can act immediately) **plus** a callout of
any top-ranked **OWNER** node (so the human work that unblocks a subtree isn't waiting silently).

---

## 4. Run it (copy-paste — reads `03-prs/DAG.json`)

```python
import json, sys
DAG = sys.argv[1] if len(sys.argv) > 1 else "03-prs/DAG.json"
d = json.load(open(DAG)); N = {n["id"]: n for n in d["nodes"]}
E = d.get("edges", []); cp = d.get("critical-path", [])
CLOSED = {"merged", "done", "dropped", "deferred"}; HARD = {"depends", "gates"}
prereqs = lambda nid: [e["from"] for e in E if e["to"] == nid and e["kind"] in HARD]
closed  = lambda nid: N[nid]["status"] in {"merged", "done"}
def lane(n):
    s = n["status"]
    return "OWNER" if s in ("gated", "owner-open") else "SHARED" if s == "todo-stage" else "AXON"
ready, blocked = [], []
for n in d["nodes"]:
    if n["status"] in CLOSED: continue
    unmet = [p for p in prereqs(n["id"]) if not closed(p)]
    (blocked if unmet else ready).append((n, unmet))
rank = lambda it: (0 if it[0]["id"] in cp else 1, 0 if it[0]["status"] == "staged" else 1, it[0]["id"])
print("critical-path:", " -> ".join(cp))
for L in ("AXON", "SHARED", "OWNER"):
    items = [i for i in sorted(ready, key=rank) if lane(i[0]) == L]
    if items: print(f"\n> {L} (ready)")
    for n, _ in items:
        print(("  *" if n["id"] in cp else "   "), f'{n["id"]:18} [{n["status"]:10}] {n["label"]}')
print("\n> BLOCKED")
for n, unmet in sorted(blocked, key=lambda x: x[0]["id"]):
    print("  ", f'{n["id"]:18} waits on:', ", ".join(u + "(" + N[u]["status"] + ")" for u in unmet))
```

Supplement with the built-ins:
- `dag summary --file 03-prs/DAG.json` — the status tally (how much is left).
- `code-dev-state-status` — phase + DAG ledger + counts in one render.
- `code-dev-next` — the "single most-relevant next command" classifier (program-level, complements this).
- `orchestrator` / `synapse-suggest` — rank the next *program* against current state.

---

## 5. Worked example — axon-hr-ui @ 2026-06-23 (live)

```
POSITION: phase = pr (active) · origin/main = f9c90f1 · critical-path: PR-019 → PR-008b → GATE-STRANGER

▶ AXON (ready — I can start now)
  ★ PR-019            [todo  ]  ladder-advance-under-flags fix      ← critical path, start here
    PR-014a-coldboot  [staged]  coldboot preflight (L0+L1)          ← built, closest to merge
    PR-DAG-LEDGER     [staged]  dag-summary ledger                  ← built, closest to merge
    GAP-HARDENING / PR-005bc / PR-009b   [todo]  hygiene + tests

⇄ SHARED (AXON builds → you run ship.sh)
    PR-002a-boot [todo-stage]  enforcement-posture boot line   (kernel)
    PR-007       [todo-stage]  resume-truth :done marker       (kernel)

◀ OWNER (only you)
  ★ GATE-STRANGER   [owner-open]  run ≥1 cold-start stranger session   ← unblocks the whole onboarding subtree
    PR-T0-bootflow  [owner-open]  menu-first boot design call (kernel)

⛔ BLOCKED
    PR-008b  waits on PR-019(todo)                ← clears the moment PR-019 merges
    PR-014   waits on GATE-STRANGER(owner-open)   ← only YOUR stranger session unblocks it
```

**Reading it:**
- *My* immediate move: `PR-014a-coldboot` / `PR-DAG-LEDGER` (staged → merge them first to bank finished work),
  then `PR-019` (critical path, unblocks `PR-008b`).
- *Your* highest-leverage move: `GATE-STRANGER` — it's the single thing blocking the entire onboarding tier
  (`PR-014`). Nothing I do unblocks it.
- `PR-008b` and `PR-014` are *not* choices right now — they're blocked; don't start them.

---

## 6. Turn a frontier pick into action

Once a node is chosen:
- **AXON node** → run the per-PR loop in `AUTONOMOUS-FLOW.md` §3 (decide → implement → HR-audit → crucible →
  squash-merge), then `dag set-status <node> merged` and recompute the frontier (new nodes may unblock).
- **SHARED node** → build + test + stage the branch, then HALT and hand the owner `ship.sh <branch>`.
- **OWNER node** → surface it as the human callout; it stays on the frontier until the owner clears it.
- **After any merge, recompute** — the frontier is dynamic; merging PR-019 makes PR-008b ready.

---

## 7. When the frontier is empty or all-blocked

- **All-blocked** (every open node waits on an OWNER gate) → the project is **owner-blocked**; surface the
  blocking gate(s) loudly and stop proposing AXON work that can't start.
- **Empty open set** (nothing open) → the wave is done → run the wave-boundary close (`AUTONOMOUS-FLOW.md` §7:
  full crucible → audit-the-audit → gap-find) → advance the ladder phase.
- **A ready node with no clear owner** → its status is wrong; fix it (it's drift — see `CODE-DEV-RESYNC.md`).

---

### Cross-references
- `CODE-DEV-RESYNC.md` — make the DAG coherent BEFORE trusting this frontier.
- `AUTONOMOUS-FLOW.md` — the per-PR loop + lane authority you execute on a chosen node.
- `03-prs/DAG.json` — the graph this reads. `dag summary` / `dag render` for the human views.

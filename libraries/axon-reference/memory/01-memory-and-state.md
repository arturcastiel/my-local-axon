# AXON Memory and State Model

> Reference doc, axon v3.7.0 (kernel-spec v1.1.4)
> Source of truth: `axon/KERNEL-SLIM.md` § MEMORY RULES (`axon/KERNEL-SLIM.md:443-457`), `axon/memory/MEMORY.md`, and the four tools that touch memory: `tools/memory.py`, `tools/kv_store.py`, `tools/checkpoint.py`, `tools/session_save.py`, `tools/session.py`.
> Status: descriptive — documents the model as it exists in the codebase, with file:line citations and notes on known gaps (F-D9-008, F-D9-022).

---

## TL;DR

1. AXON has four memory scopes: **W:** (working — session-only, in `workspace/memory/working/*.md`), **L:** (longterm — persisted across sessions, in `workspace/memory/longterm/*.md`), **E:** (episodic — append-only audit log, in `workspace/memory/episodic/*.md`), and **local/** (machine-specific, gitignored, in `workspace/memory/local/*.md`).
2. Each scope has its own lifetime: W: cleared on clean exit, L: survives indefinitely with rollback history (3 versions kept), E: never deleted, local/ never synced to any repo.
3. Retrieval order is fixed and unconditional: `W: → L: → E: → QUERY(user)` (`axon/KERNEL-SLIM.md:444`). Never skip. Never QUERY for a key that is stored in L:.
4. Working memory is budget-disciplined: kernel mandates ≤25 keys during active execution and ≤10 idle (`axon/KERNEL-SLIM.md:445`). Enforcement is `R_W_BUDGET` at WARN severity — non-blocking (`tools/rules/r_w_budget.py:7`).
5. Continuity across sessions runs through three artifacts: per-turn `CHECKPOINT` snapshots in `working/`, the `L:last-session-snapshot` written by `session-save` at shutdown, and the per-chat `_session.md` ledger that detects compaction via PID mismatch (`tools/session.py:131-169`).

---

## 1. The four scopes

The kernel declares four memory scopes. The first three (W:, L:, E:) share a uniform access model through `tools/memory.py`; the fourth (local/) is intentionally outside that tool because it must never be synced.

### 1.1 Scope summary

| Scope | Prefix | Storage path | Lifetime | Access pattern | Examples |
|-------|--------|--------------|----------|----------------|----------|
| Working | `W:` | `workspace/memory/working/*.md` | Current session only — cleared on clean exit (`axon/KERNEL-SLIM.md:453`) | `RETRIEVE(W:k)` / `STORE(W:k, v)` via `tools/memory.py` (key = filename without `.md`) | `W:active-phase`, `W:turn-count`, `W:active-program`, `W:current-session`, `W:reasoning-trace`, `W:myaxon-path` |
| Longterm | `L:` | `workspace/memory/longterm/*.md` | Persistent across sessions, with last 3 versions kept in `.rollback/` (`tools/memory.py:15,33`) | `RETRIEVE(L:k)` / `STORE(L:k, v)` via `tools/memory.py`; also `rollback` and `history` actions | `L:dev-mode`, `L:cognition-frame`, `L:halt-mode`, `L:inference-mode`, `L:last-session-summary`, `L:last-session-snapshot` |
| Episodic | `E:` | `workspace/memory/episodic/*.md` | Permanent. Append-only — never overwrite, never delete (`tools/memory.py:65,82-83`) | `APPEND(E:k, v)` only; `set` and `clear` are blocked with an error | `E:session-log`, named streams like `E:testimony-MARA` or `E:case-log` |
| Local | `local/` | `workspace/memory/local/*.md` | Persistent on this machine, gitignored from both `axon.git` and `my-axon.git` (`workspace/.gitignore:4`, `axon/CONTRIBUTING.md:153`) | READ/WRITE directly by file path. **NOT** accessible via `RETRIEVE(L:)` — it is its own namespace (`axon/KERNEL-SLIM.md:451`) | `myaxon-backup-enabled`, `myaxon-backup-url`, `myaxon-backup-status`, `dev-cycle-template`, `first-run-complete` (legacy), `ws-backup-*` |

The `W:` / `L:` / `E:` mapping is hard-coded in `tools/memory.py:7`:

```python
SCOPE_MAP = {"W": "working", "L": "longterm", "E": "episodic"}
```

`local/` is deliberately absent from that map because the tool's `set`/`get`/`clear` cannot touch it. The kernel rule is explicit (`axon/KERNEL-SLIM.md:451`):

> **local/ scope** — READ/WRITE directly by path. NOT accessible via RETRIEVE(L:). Holds: `ws-backup-*`, `dev-mode`, `first-run-complete`. QUERY(user) if a local/ key is absent and required.

### 1.2 Why four (and not three)

Earlier `axon/memory/MEMORY.md:7` documents only three scopes (W:/L:/E:); the `local/` scope was added later to handle keys that must persist but must never travel across machines. A backup URL with a secret token, the path to a private venv, or the boolean "this user has run AXON before on this machine" all belong here. The kernel rules in `KERNEL-SLIM` (`axon/KERNEL-SLIM.md:324, 449-451`) are the current source of truth; the `memory/MEMORY.md` load-on-demand file lags slightly and still describes only three scopes.

### 1.3 File format

Every scope uses the same on-disk format: one Markdown file per key, where **the filename (without `.md`) is the key and the file body is the value**. `tools/memory.py:12,55` makes this explicit:

```python
def key_path(workspace, scope, key):
    return os.path.join(scope_dir(workspace, scope), f"{key}.md")
```

A read is `open(path).read().strip()` (`tools/memory.py:62`); a write is an atomic write with a trailing newline (`tools/memory.py:73`). There is no schema enforcement beyond "the file exists and has content."

The recommended (but not enforced) content format from `axon/memory/MEMORY.md:100-116`:

```markdown
# [Key / Topic]
Updated: [timestamp]
Scope: [W | L | E]

[Content — plain prose or structured fields]
```

In practice most keys store a bare value (a timestamp, a boolean string, a JSON blob) rather than the full template. The `_index.md` file in each scope directory is a directory README, not a key (see `axon/axon/memory/working/_index.md:1-6`, `axon/axon/memory/longterm/_index.md`, `axon/axon/memory/episodic/_index.md`).

### 1.4 Naming conventions inside each scope

| Scope | Filename pattern | Notes |
|-------|------------------|-------|
| `working/` | `{key}.md` — flat namespace | Directory should be empty at the start of every clean session (`axon/axon/memory/working/_index.md:6`). Snapshot files written by `checkpoint.py` use `.json` extension and live alongside (`tools/checkpoint.py:29-31`). |
| `longterm/` | `{topic}.md` — descriptive names | `.rollback/{key}.json` sidecar holds last 3 prior values (`tools/memory.py:17-20`). |
| `episodic/` | `{name}.md` or `{YYYY-MM-DD}-{session-id}.md` for date-keyed logs | `session-log.md` is the canonical site for `CHECKPOINT` row appends (`tools/checkpoint.py:36-42`). |
| `local/` | `{key}.md` — flat namespace, by convention prefixed `myaxon-` when set by the my-axon backup program | Not managed by `tools/memory.py`; programs and tools read/write by absolute path through `W:myaxon-local`. |

A live sample of `my-axon/memory/local/` on a real install shows the shape used in practice:

```
my-axon/memory/local/
├── dev-cycle-template.md         (text fragment shared between human and AXON)
├── myaxon-backup-enabled.md      (bare string: "true")
├── myaxon-backup-last.md         (ISO timestamp: "2026-05-21T13:14:47+02:00")
├── myaxon-backup-last-push.md
├── myaxon-backup-status.md       (bare string: "ok")
└── myaxon-backup-url.md          (URL string)
```

(Files inspected via `cat` on the active dev install — see `my-axon/memory/local/myaxon-backup-enabled.md` and `myaxon-backup-status.md`.)

---

## 2. Retrieval order

The kernel rule is one line (`axon/KERNEL-SLIM.md:444`):

> **Retrieval order:** W: → L: → E: → QUERY(user). Never skip. Never query for something stored in L:.

The same rule appears in long form at `axon/memory/MEMORY.md:42-51`:

```
1. CHECK W: first (fastest, in-session)
2. IF ∅ → CHECK L: (persisted facts)
3. IF ∅ → CHECK E: (historical context — search by topic or date)
4. IF ∅ in all three → QUERY(user)
```

### 2.1 The flow

```
                     ┌─────────────────────────────┐
                     │  need: value for key K      │
                     └────────────┬────────────────┘
                                  │
                                  ▼
                     ┌─────────────────────────────┐
   1. cheapest ─────▶│  RETRIEVE(W:K)              │── ✓ ──▶ return
                     │  workspace/memory/working/  │
                     └────────────┬────────────────┘
                                  │ ∅
                                  ▼
                     ┌─────────────────────────────┐
   2. persisted ────▶│  RETRIEVE(L:K)              │── ✓ ──▶ return
                     │  workspace/memory/longterm/ │
                     └────────────┬────────────────┘
                                  │ ∅
                                  ▼
                     ┌─────────────────────────────┐
   3. historical ───▶│  scan E:session-log et al.  │── ✓ ──▶ return
                     │  workspace/memory/episodic/ │
                     └────────────┬────────────────┘
                                  │ ∅
                                  ▼
                     ┌─────────────────────────────┐
   4. last resort ──▶│  QUERY(user)                │── ✓ ──▶ store + return
                     └─────────────────────────────┘
```

`local/` is **not** part of the retrieval order. It is a parallel namespace addressed by path, used when a program already knows the file it wants (e.g. `READ("{W:myaxon-local}myaxon-backup-enabled.md")` in the workspace-backup boot hook at `axon/KERNEL-SLIM.md:665-674`). The kernel rule for missing `local/` keys is `QUERY(user)` directly (`axon/KERNEL-SLIM.md:451`); there is no fall-through to W: or L:.

### 2.2 The "never query for L:" invariant

The reason the rule is stated twice (`axon/KERNEL-SLIM.md:444` and `axon/memory/MEMORY.md:51`) is that this is the most common drift pattern: an agent that re-asks the user for something it already wrote to L: in a prior session. Examples of facts that live in L: and **must not** be re-queried:

| Fact | L: key | Set by |
|------|--------|--------|
| Owner developer mode | `L:dev-mode` | `axon/programs/dev-mode.md:24` |
| Cognition frame | `L:cognition-frame` | Boot step 1 (`axon/KERNEL-SLIM.md:560`) |
| Inference mode | `L:inference-mode` | `tools/boot.py` via boot step 2 (`axon/KERNEL-SLIM.md:40`) |
| Halt mode | `L:halt-mode` | `tools/prefs.py` (`axon/BOOT.md:47`) |
| Host harness identity | `L:host-harness` | Harness contract at `workspace/harness/*.md` (`axon/KERNEL-SLIM.md:11, 600-610`) |
| Host model identity | `L:host-model` | Harness contract |
| Last-session digest | `L:last-session-summary` | `tools/session_save.py:249` |
| Last-session W: snapshot | `L:last-session-snapshot` | `tools/session_save.py:250` |

A `QUERY(user)` for any of these in a fresh session indicates the retrieval order was skipped.

---

## 3. The 25-key budget

The kernel imposes a hard ceiling on the size of working memory (`axon/KERNEL-SLIM.md:445`):

> **W: discipline:** ≤25 keys during active execution; idle target ≤10. Prune after program completes.

The motivation is context-pressure management: each W: key is potentially summarised into the model's running context, and every key adds to the prompt overhead carried turn-to-turn. The 25/10 split distinguishes "in the middle of a multi-step program" (where intermediate state is legitimate) from "back at the menu" (where the only W: keys that should remain are session pointers).

### 3.1 Mechanical enforcer — `R_W_BUDGET`

The rule is checked at runtime by the verifier predicate `R_W_BUDGET` (`axon/KERNEL-SLIM.md:475`). The Python implementation is short and explicit (`tools/rules/r_w_budget.py:1-22`):

```python
"""R_W_BUDGET: W: should hold ≤ 25 keys during active execution (kernel memory rule)."""
from .registry import Violation

LIMIT = 25
phase    = "RUNTIME"
severity = "WARN"
rule_id  = "R_W_BUDGET"


def check(ctx):
    state = ctx.get("state") or {}
    w_keys = state.get("w_keys")
    if w_keys is None:
        return None
    n = len(w_keys) if hasattr(w_keys, "__len__") else int(w_keys)
    if n > LIMIT:
        return Violation(
            rule_id=rule_id, severity=severity, phase=phase,
            reason=f"W: scope holds {n} keys (limit {LIMIT}). Prune after program completes.",
            location="W:",
        )
    return None
```

Two things to note:

1. **Severity is `WARN`, not `ERROR`.** Crossing 25 W: keys logs a warning and surfaces to the output layer but does not HALT. The rule is advisory at the response gate.
2. **The 10-key idle target is not mechanically enforced.** It appears in `KERNEL-SLIM` and `memory/MEMORY.md:15` as a discipline target but no predicate checks it. Programs are expected to `CLEAR(W:k)` at `DONE(program)` boundaries (see for example `axon/KERNEL-SLIM.md:404` where `DONE(id)` shorthand includes `CLEAR(W:task-id)`).

### 3.2 What counts toward the budget

Every `.md` file under `workspace/memory/working/` is a W: key, including boot-set path keys (`W:ws-os`, `W:ws-programs`, `W:myaxon-path`, etc.) and per-turn state (`W:turn-count`, `W:reasoning-trace`, `W:last-output`). On a typical post-boot install the working directory holds well over the 25-key limit, because many `W:ws-*` and `W:myaxon-*` keys are essentially permanent path bindings. `tools/session_save.py:103-105` carries an explicit exclude list for snapshotting precisely because these "infrastructure" keys are not part of program state:

```python
EXCLUDE_PREFIX = ("ws-", "_", "tool-registry", "output-rules",
                  "user-prefs", "parse-tree", "cron-overdue")
```

`R_W_BUDGET` does not apply the same filter — its `len(w_keys)` is the raw count. In practice the WARN is regularly visible during active program execution; treating it as a "the agent should think about pruning" hint rather than a hard cap is consistent with the WARN severity.

---

## 4. Scope heuristics

The kernel offers four-line guidance for picking the right scope (`axon/KERNEL-SLIM.md:446-450`):

```
"this task/temporarily"          → W:
"future sessions/permanently"    → L:  (workspace/memory/longterm/)
"machine-specific/not shareable" → local/  (workspace/memory/local/ — gitignored)
"audit/history"                  → E:
```

`axon/memory/MEMORY.md:55-62` adds two storage tests:

> **Before storing to L:**, ask: "Would this be true in the next session?" If yes → L:. If not → W:.
> **Before storing to W:**, ask: "Will I need this again before this session ends?" If yes → store. If no → don't store, just use it and discard.

| Decision | Test | Examples |
|----------|------|----------|
| Use W: | Needed again this session, useless next session | `W:turn-count`, `W:active-program`, `W:reasoning-trace`, `W:_interrupt-pending-input` |
| Use L: | True now, will still be true next session | `L:dev-mode`, `L:halt-mode`, `L:inference-mode`, `L:output-layer-format` |
| Use E: | Should be recoverable later for audit, but not retrieved frequently | `E:session-log`, named per-program logs |
| Use local/ | True now, would be wrong on another machine | `myaxon-backup-url`, `myaxon-backup-status`, `dev-cycle-template` |

The negative test for L: matters: `axon/memory/MEMORY.md:25` warns "Do not speculatively write to L:. Only store what has been confirmed true more than once, or explicitly instructed by the user." L: is the persistence layer, so junk written there is junk that survives.

---

## 5. The my-axon overlay

`workspace/memory/` is the canonical layout, but on a deployed install the user's runtime data lives in `my-axon/memory/`. The mapping is handled by an overlay of W: path keys set at boot from `my-axon/MYAXON.md`.

### 5.1 The MYAXON path map

`my-axon/MYAXON.md:21-37` declares the path keys explicitly:

```
STORE(W:myaxon-name,         "arturcastiel")
STORE(W:myaxon-path,         "/mnt/c/projects/axon/my-axon")
STORE(W:myaxon-dev-projects, "/mnt/c/projects/axon/my-axon/dev-projects/")
STORE(W:myaxon-memory,       "/mnt/c/projects/axon/my-axon/memory/")
STORE(W:myaxon-longterm,     "/mnt/c/projects/axon/my-axon/memory/longterm/")
STORE(W:myaxon-episodic,     "/mnt/c/projects/axon/my-axon/memory/episodic/")
STORE(W:myaxon-working,      "/mnt/c/projects/axon/my-axon/memory/working/")
STORE(W:myaxon-local,        "/mnt/c/projects/axon/my-axon/memory/local/")
STORE(W:myaxon-log,          "/mnt/c/projects/axon/my-axon/log/entries/")
STORE(W:myaxon-igap,         "/mnt/c/projects/axon/my-axon/log/igap/")
STORE(W:myaxon-turns,        "/mnt/c/projects/axon/my-axon/log/turns/")
STORE(W:myaxon-chats,        "/mnt/c/projects/axon/my-axon/chats/")
STORE(W:myaxon-plans,        "/mnt/c/projects/axon/my-axon/plans/")
STORE(W:myaxon-libraries,    "/mnt/c/projects/axon/my-axon/libraries/")
STORE(W:myaxon-generated,    "/mnt/c/projects/axon/my-axon/generated/")
```

### 5.2 How the kernel learns the overlay

Boot step 2 — after `TOOL(boot)` has run and validated `W:ws-programs` — fires "my-axon detection" (`axon/KERNEL-SLIM.md:575-596`):

```
axon-root   ← TOOL(shell, "git -C {W:ws-os} rev-parse --show-toplevel ...") | "{W:ws-os}/../.."
myaxon-path ← RETRIEVE(W:myaxon-path) | "{axon-root}/my-axon"
myaxon-md   ← "{myaxon-path}/MYAXON.md"
IF FILE-EXISTS(myaxon-md) →
  EXEC(READ(myaxon-md))   ← executes all STORE(W:myaxon-*) lines, loading path keys
  LOG(INFO, "boot: my-axon loaded — {myaxon-path}")
ELSE →
  ⚠ No my-axon/ user-data folder found.
  QUERY(user): "[F]resh  [C]lone existing repo  [S]kip  (default: F)"
```

The mechanism is: `MYAXON.md` is itself an executable program. `EXEC(READ(...))` interprets its `STORE(W:myaxon-*)` lines, which load the absolute paths into working memory. The kernel's `LANGUAGE` section enumerates the expected keys explicitly (`axon/KERNEL-SLIM.md:325-330`):

```
**my-axon scope** — W:myaxon-*: user runtime data, absolute paths loaded from my-axon/MYAXON.md at boot.
  W:myaxon-path · W:myaxon-name · W:myaxon-dev-projects · W:myaxon-memory
  W:myaxon-longterm · W:myaxon-episodic · W:myaxon-working · W:myaxon-local
  W:myaxon-log · W:myaxon-igap · W:myaxon-turns · W:myaxon-chats
  W:myaxon-plans · W:myaxon-libraries · W:myaxon-generated
  All absent until my-axon-init runs or MYAXON.md is read. Programs must not assume they exist.
```

### 5.3 What this means in practice

After boot, references like `RETRIEVE(W:myaxon-longterm)` resolve to a full absolute path (e.g. `/mnt/c/projects/axon/my-axon/memory/longterm/`), and programs can `READ`/`WRITE`/`APPEND` directly against it. Tools that need a workspace path accept `--workspace` and default to `default_workspace()` from `tools/_axon_paths.py` — this is the root the `SCOPE_MAP` paths are joined against (`tools/memory.py:9-12`). When `my-axon/` is present, the default workspace points there; when absent (or skipped at boot), programs fall back to the in-repo `workspace/` directory.

This is the reason the data documented in §1.1 lives at `workspace/memory/*` paths in the *kernel rule text* but at `my-axon/memory/*` paths in *every real run* — they refer to the same logical structure under two physical roots, joined by the `default_workspace()` resolver.

---

## 6. Persistence mechanics

### 6.1 The Markdown-file model

The fundamental persistence primitive is "one Markdown file per key." Across all four scopes, this is the same:

```
workspace/memory/{working|longterm|episodic|local}/{key}.md
                                                    ^^^^^^^^
                                                    filename = key
                                                    contents = value
```

This choice has three consequences:

1. **Memory is human-readable and grep-able.** A developer can `ls workspace/memory/working/` to see live W: keys, and `cat` any one to read its value. This is deliberate (`axon/axon/tools/kv-store.md:11`): "File-based memory (memory/working/, memory/longterm/) remains the default for human-readable notes and session state."
2. **Atomic writes are required.** `tools/memory.py:73` uses `atomic_write` from `_axon_io.py` to avoid partial files; `tools/session_save.py:251-252` does the same for the L: snapshot. The exception is `APPEND` to E:, which uses plain `open(path, "a")` (`tools/memory.py:79`) — appends are intrinsically race-tolerant for the use case.
3. **There is no transaction.** A program that stores into multiple W: keys, then crashes mid-way, leaves a half-written state. The convention for handling this is `CHECKPOINT` (§7): take a snapshot before the multi-step section, so the next session can `restore` from the snapshot if needed.

### 6.2 Atomicity, rollback, and history (L: only)

L: keys gain rollback history automatically. The mechanism is in `tools/memory.py:15-33`:

```python
ROLLBACK_MAX = 3  # B: keep last N values per L: key

def rollback_path(workspace, key):
    d = os.path.join(workspace, "memory", "longterm", ".rollback")
    os.makedirs(d, exist_ok=True)
    return os.path.join(d, f"{key}.json")

def save_rollback(workspace, key, old_value):
    path = rollback_path(workspace, key)
    history = []
    if os.path.exists(path):
        try:
            with open(path) as f:
                history = json.load(f)
        except Exception:
            history = []
    history.insert(0, old_value)
    history = history[:ROLLBACK_MAX]
    atomic_write_json(path, history)
```

On a `set` against an existing L: key, the prior value is prepended to the history list (capped at 3); on `rollback`, the most recent prior value is restored and the *current* value is pushed back into history (so rollback is itself reversible). `history` lists the current value plus the 3 prior versions.

W: and E: have **no** rollback. E: cannot rollback because it is append-only (`tools/memory.py:65,82`); W: can be cleared but not rewound.

### 6.3 The kv-store alternative for typed values

`tools/kv_store.py` exists as a second persistence layer, backed by `diskcache` rather than per-key Markdown files. Its trigger criteria are explicit (`axon/axon/tools/kv-store.md:5-11`):

> Use instead of file-based memory when:
> - A workflow reads/writes the same key more than 5 times per task
> - Storing structured data (JSON objects, lists) that would be awkward in markdown
> - Multiple concurrent processes need shared state
> - You need TTL (auto-expiry) on a value
>
> File-based memory (memory/working/, memory/longterm/) remains the default for human-readable notes and session state. kv-store is for high-frequency programmatic access.

The store lives at `workspace/memory/kv-store/cache.db` (a sqlite-backed `diskcache.Cache`) and is gitignored (`workspace/.gitignore:7`). The CLI mirrors `memory.py`'s grammar but adds `exists` and TTL support:

```
python tools/kv_store.py set    --key K --value '<json>' [--ttl SECONDS]
python tools/kv_store.py get    --key K
python tools/kv_store.py delete --key K
python tools/kv_store.py exists --key K
python tools/kv_store.py list   --prefix P
python tools/kv_store.py clear  --prefix P    (--prefix mandatory for safety)
```

By convention (`axon/axon/tools/kv-store.md:38-41`):

> - `W:key` — session-scoped (clear at session end with `clear --prefix W:`)
> - `L:key` — longterm (persisted)
> - `E:key` — not recommended for kv-store (use episodic memory files instead)

Current use cases in the workspace include `workspace/programs/auto-improve.md:41,54` which uses `kv-store set L:auto-improve true` and `kv-store set L:auto-improve-last-confirmed-ts {now.epoch}` — both small typed values that programs check on every boot. The smoke test suite exercises the kv-store path explicitly (`workspace/AXON-DOCS-CI.md:77`).

### 6.4 When to use which

| Storage need | Use |
|--------------|-----|
| Human readability, audit trail, low write rate | `tools/memory.py` (Markdown files in W:/L:/E:) |
| High write rate, structured value, TTL | `tools/kv_store.py` (diskcache) |
| Append-only event log | `tools/memory.py` with `--scope E --action append`, or direct `APPEND` |
| Per-chat session ledger with state machine | `tools/session.py` (PR-9 `_session.md` per chat) |
| Boot-time recovery of W: state | `tools/session_save.py` (writes `L:last-session-snapshot`) |
| Mid-task safety snapshot | `tools/checkpoint.py` (snapshot W: + append to E:) |

---

## 7. Checkpoint and snapshot

`CHECKPOINT` is the unit of mid-task durability. The shorthand expansion is in `axon/KERNEL-SLIM.md:403`:

```
CHECKPOINT  →  SNAPSHOT(W:) + APPEND(E:session-log, state) + LOG(DEBUG)
```

### 7.1 `tools/checkpoint.py`

The Python tool that backs this shorthand is `tools/checkpoint.py:7-46`. It does three things on every invocation:

1. Read every `.md` file in `workspace/memory/working/`, build a dict `{key: value}`.
2. Write that dict, plus a label and ISO timestamp, to `workspace/memory/working/{label}.json` (default label `checkpoint`).
3. Append a row to `workspace/memory/episodic/session-log.md` with the timestamp, the event "checkpoint", and the key count.

Implementation (`tools/checkpoint.py:18-42`):

```python
# Read all W: keys
working_dir = os.path.join(args.workspace, "memory", "working")
os.makedirs(working_dir, exist_ok=True)
snapshot = {}
if os.path.exists(working_dir):
    for fname in os.listdir(working_dir):
        if fname.endswith(".md"):
            key = fname[:-3]
            snapshot[key] = open(os.path.join(working_dir, fname)).read().strip()

# Write snapshot file
snap_path = os.path.join(working_dir, f"{args.label}.json")
with open(snap_path, "w") as f:
    json.dump({"label": args.label, "timestamp": iso, "keys": snapshot}, f, indent=2)

# Append to E:session-log
episodic_dir = os.path.join(args.workspace, "memory", "episodic")
os.makedirs(episodic_dir, exist_ok=True)
log_path = os.path.join(episodic_dir, "session-log.md")
entry = f"| {iso} | checkpoint | label: {args.label} · keys: {len(snapshot)} |\n"
if not os.path.exists(log_path):
    with open(log_path, "w") as f:
        f.write("# SESSION LOG\n\n| Time | Event | Notes |\n|------|-------|-------|\n")
with open(log_path, "a") as f:
    f.write(entry)
```

Note that the snapshot file (`{label}.json`) is written **into the working directory itself**. Multiple checkpoints with different labels coexist (`checkpoint.json`, `pre-write.json`, etc.); the same label overwrites.

### 7.2 Where CHECKPOINT fires

The kernel mandates CHECKPOINT in several places. From Core Rule 5 (`axon/KERNEL-SLIM.md:66`):

> 5. Always CHECKPOINT before yielding mid-task.

From the program-phase-tracking rule (`axon/KERNEL-SLIM.md:298-303`):

```
On entry:  STORE(W:active-phase, "{program-name}:start") + CHECKPOINT
On phase N: STORE(W:active-phase, "{program-name}:step-{N}") before any tool side-effect or write
On DONE:   STORE(W:active-phase, "{program-name}:done") + CHECKPOINT
On FAIL:   STORE(W:active-phase, "{program-name}:failed") + CHECKPOINT
```

From the context-pressure gate (`axon/KERNEL-SLIM.md:284, 291`):

```
IF pressure.level ≡ "critical" → CHECKPOINT + HALT
IF pressure.level ≡ "high"    → CHECKPOINT + WARN + continue
```

From the active-program-interrupt gate when the user chooses [I]nterrupt or [A]bort (`axon/KERNEL-SLIM.md:207, 215`):

```
IF answer ≡ "I" → CHECKPOINT + STORE(W:_paused-program) + ...
IF answer ≡ "A" → CHECKPOINT + STORE(W:active-phase, "{program}:aborted") + ...
```

The pattern is: **CHECKPOINT runs whenever forward progress might be interrupted by a context boundary or user interjection.** Because it both snapshots W: and appends to E:, it leaves two artifacts: an in-memory state file in `working/checkpoint.json` and an audit row in `episodic/session-log.md`.

### 7.3 `tools/session_save.py` — the session-boundary snapshot

`session-save` is the boundary-flush tool: it runs at clean shutdown (`axon/BOOT.md:164-173`) and writes two L: keys:

- `L:last-session-summary` — a 2-line compact digest shown in the boot resume box.
- `L:last-session-snapshot` — a JSON dict of W: keys to be restored on resume.

The W: keys captured exclude path/registry "infrastructure" prefixes (`tools/session_save.py:103-105`) and keys whose value exceeds 2 KiB (`tools/session_save.py:30, 117-119`). The snapshot file itself carries metadata header keys (`tools/session_save.py:177-179, 236-244`):

```python
snapshot = {
    "snapshot-version":  "1",
    "snapshot-ts":       ts,
    "session-date":      date,
    "session-compiled":  str(compiled),
    "session-coverage":  str(coverage),
    "session-dispatch":  str(dispatch),
    **w_keys,
}
```

The shutdown hook is wired in `axon/BOOT.md:164-173`:

```
## SHUTDOWN HOOK  (run on any clean session end)
TOOL(session-save, --workspace workspace)
  → LOG(INFO, "session-save: {result.summary_line}")
  → → "  ✓ Session saved. Type 'axon boot' to resume."
```

The corresponding restore is `tools/session_save.py restore` (`tools/session_save.py:157-196`). It reads `last-session-snapshot.md`, ignores the metadata keys, and writes each remaining `{key: value}` pair back into `workspace/memory/working/{key}.md`. The operation is idempotent — running twice produces the same state — because each W: file is atomically overwritten.

### 7.4 Three-tier persistence

```
                       BOUNDARY                                  SCOPE OF EFFECT
   ┌────────────────────────────────────────┐
   │ in-process model state                  │    ← in conversation context (volatile)
   │   - reasoning traces, in-flight values  │      lost on compaction
   └────────────────────────────────────────┘
                       │
              CHECKPOINT (mid-task)
                       ▼
   ┌────────────────────────────────────────┐
   │ workspace/memory/working/*.md           │    ← on-disk W: scope (survives compaction)
   │ + working/checkpoint.json (snapshot)    │      lost on session-end CLEAR
   │ + episodic/session-log.md (audit row)   │
   └────────────────────────────────────────┘
                       │
              session-save (session-end)
                       ▼
   ┌────────────────────────────────────────┐
   │ longterm/last-session-snapshot.md       │    ← L: scope (survives across sessions)
   │ + longterm/last-session-summary.md      │      restored by `session-save restore`
   │ + episodic/session-log.md (event row)   │
   └────────────────────────────────────────┘
```

---

## 8. Resume model

There are two complementary mechanisms for picking up where a previous session left off: the **kernel-driven boot prompt** (which uses `L:last-session-snapshot` + `W:active-phase`), and the **resume program** (`workspace/programs/resume.md`) that the user can run on demand.

### 8.1 Boot-time interrupted-session detection

Boot step 3 reads `W:active-phase` and offers to continue the in-flight program (`axon/KERNEL-SLIM.md:614-650`):

```
IF W:resumed ≡ true →
  phase ← RETRIEVE(W:active-phase) | ∅
  IF phase ≠ ∅ AND phase not contains ":done"
              AND phase not contains ":failed"
              AND phase not contains ":aborted" →
    program   ← phase.split(":")[0]
    step      ← phase.split(":")[1] | "unknown"
    ...
    → "↺  INTERRUPTED SESSION DETECTED"
    → "Program  : {program}"
    → "Progress : {progress-line}"
    QUERY(user): "C / R / S  (default: C)"
    IF answer ≡ "C" → EXEC({program})
    IF answer ≡ "R" → CLEAR(W:active-phase) + EXEC({program})
    IF answer ≡ "S" → CLEAR(W:active-phase) + EXEC(menu)
```

The detection logic relies on `W:active-phase` having been written *before* the interruption — which is exactly what `STORE(W:active-phase, "{program}:step-{N}")` does at each program-phase boundary (§7.2). Even programs that crash mid-step leave behind a phase pointer.

### 8.2 The resume program

`workspace/programs/resume.md` is the user-facing entry point. It scans `E:session-log` for `session-checkpoint` events without matching `session-end` events, and offers them as resume candidates (`workspace/programs/resume.md:25-32`):

```
checkpointed ← FILTER(log-entries, event="session-checkpoint" OR event="mid-session-checkpoint")
completed    ← FILTER(log-entries, event="session-end" OR event="session-complete" OR event="boot-complete")

completed-sessions ← SET(MAP(completed, field="session"))
interrupted ← FILTER(checkpointed, session NOT IN completed-sessions)
```

It also reads the current day's turn log (`workspace/log/turns/{date}.md`) and tails the last 5 turn blocks for context reconstruction (`workspace/programs/resume.md:67-84`). On user confirmation, the chosen session id is written back as `W:current-session` (`workspace/programs/resume.md:91-101`).

### 8.3 Boot read of last-session-snapshot

The boot resume prompt also restores W: keys from the longterm snapshot (`axon/BOOT.md:100-106`):

```
IF W:_boot-resume-choice STARTSWITH "y" →
  snapshot ← RETRIEVE(L:last-session-snapshot)
  IF snapshot ≠ ∅ →
    ∀ (k, v) in snapshot → STORE(W:{k}, v)
  STORE(W:resumed, true)
  → "✓ Previous session restored."
```

`tools/boot.py:170-190` provides a parallel API to read the snapshot for inspection (counting non-metadata keys), so the kernel can show "N keys ready to restore" in the resume box without doing the restore eagerly.

### 8.4 Known gap — `snapshot-version` (F-D9-008)

`session-save` writes `snapshot-version: "1"` into every snapshot (`tools/session_save.py:237`), but **no reader consumes the field for version-gating logic**. `tools/boot.py:183` lists it in the `METADATA` set only to *exclude it from the W: key count*, and `tools/session_save.py:179` lists it in the `restore` METADATA set for the same reason. The test at `tests/test_tools_kernel.py:1337` asserts the value is "1" but does not exercise a version-upgrade path.

This is logged in the failure-mode catalogue as **F-D9-008** (snapshot-version is written-not-read). The practical effect today is none — there is only one snapshot format. The catalogue entry exists because if the snapshot format ever changes (e.g. to capture more keys, or to compress large values), there is no on-disk indicator that boot can use to dispatch to a v1 reader vs a v2 reader. Migration code would need to read the field first, which currently no consumer does.

---

## 9. Compaction and recovery

Compaction is the loss of in-process conversation context — the model's prompt buffer is squeezed to keep the conversation alive across long sessions, and any state that lived **only** in that buffer is gone. AXON's response is the same as for any other interruption: rely on on-disk state, and provide a way to detect that compaction happened.

### 9.1 What survives compaction

| Storage layer | Survives compaction? | Why |
|---------------|---------------------|-----|
| Model context (in-prompt) | No | This is exactly what compaction discards |
| In-process variables computed this turn but not stored | No | Lost with the context |
| W: keys on disk (`workspace/memory/working/*.md`) | Yes | On the filesystem, not in the prompt |
| L: keys on disk | Yes | On the filesystem |
| E: keys on disk | Yes | On the filesystem |
| local/ files | Yes | On the filesystem |
| Per-chat `_session.md` ledger | Yes | On the filesystem |

The kernel calls this out at `axon/BOOT.md:113-115`:

> **STEP 3b — PROJECT STATE RE-ASSERTION** (runs after session restore, every boot)
> Purpose: counteract compaction loss. Even if conversation context was compacted and the agent lost AXON identity, this step re-asserts it unconditionally.

And at `axon/KERNEL-SLIM.md:137-138` inside the cognition-frame guard:

> Rationale: compaction can clear `L:cognition-frame` between turns within a loop. The check fires every 5 turns, not every turn, to avoid overhead. Programs that omit this check are non-compliant.

(The wording "clear `L:cognition-frame`" here is shorthand — L: on-disk is unaffected, but the in-context cached value can vanish. The mitigation is the same: re-read from disk.)

### 9.2 The `_session.md` compaction detector

`tools/session.py:131-169` implements a per-chat compaction detector via PID mismatch (`session.py:131-145`):

```python
def recover(session_path: Path) -> dict:
    """PR-15 — Compaction recovery.

    Triggered when state==active AND last_pid differs from current PID
    (process restart while session was live = compaction). Reports last
    program + recent checkpoints + pending verbs for resume.
    """
    hdr, body = _parse(session_path)
    if not hdr:
        return {"ok": False, "error": "no session to recover"}
    current_pid = str(os.getppid())
    last_pid = hdr.get("last_pid", "")
    pid_mismatch = bool(last_pid) and last_pid != current_pid
    compacted = hdr.get("state") == "active" and pid_mismatch
```

The mechanic is: every `start`, `checkpoint`, and `transition` records the current process's parent PID (`session.py:96, 110, 127`). If a session is in state `active` and the next caller has a different PID, the harness process restarted while the session was supposed to be live — which is the signature of a compaction event. On detection, the state transitions to `recovered` and a new event row is appended (`session.py:150-156`).

The output identifies "what was running" so a resume can be offered:

```python
return {
    "ok": True,
    "recovered": True,
    "reason": "pid-mismatch (compaction)",
    "last_program": hdr.get("last_program"),
    "last_action": hdr.get("last_action"),
    "recent_checkpoints": checkpoints,
}
```

### 9.3 Known gap — `recover()` is orphaned (F-D9-022)

Despite `tools/session.py:131-169` being fully implemented and tested via fault injection (`tests/test_loop_receipt_fault_injection.py:5-17`), **no boot path or kernel rule currently calls it**. The references in the codebase are:

- `workspace/programs/code-dev-events-emit.md:41,45` — declares the events `code-dev.session.recovered` and `code-dev.compaction.detected` would fire on PID-mismatch in session recover, but the emitter never runs in the boot sequence.
- `workspace/AXON-DOCS-WORKFLOWS.md:56-58` — documents a `code-dev-session recover` chain that would land a recovery row, but the chain is unwired.
- `CHANGELOG.md:294` — records PR-15 "Compaction recovery — `session.py.recover()` detects PID mismatch on active state; `AXON-DOCS-SESSIONS.md` seed."

This is **F-D9-022** in the failure-mode catalogue. Today, compaction is caught by:

1. The unconditional cognition-frame re-assertion at every 5-turn drift check (`axon/KERNEL-SLIM.md:305-306`).
2. The 3b project re-assertion at boot (`axon/BOOT.md:113-130`).
3. The boot resume prompt reading `W:active-phase` (`axon/KERNEL-SLIM.md:614-650`).

These together cover most user-visible compaction cases. The orphaned `recover()` function would add per-chat granularity (which chat's session ledger transitioned to `recovered`, what its `last_program` was) but is not currently invoked. Wiring it up would be a discrete fix once a boot hook is added that runs `TOOL(session, recover, --path {chat-session-path})` for each active chat.

### 9.4 Compaction safety summary

```
                    compaction event
                          │
                          ▼
   ┌────────────────────────────────────────────────────┐
   │  Lost: in-prompt context, uncommitted variables     │
   │  Survives: anything written to workspace/memory/*   │
   │  Detected by:                                       │
   │    - 5-turn cognition-frame drift check (active)    │
   │    - boot 3b project re-assertion (active)          │
   │    - boot resume prompt via W:active-phase (active) │
   │    - session.py.recover() PID-mismatch (orphaned —  │
   │      F-D9-022, not wired into boot)                 │
   └────────────────────────────────────────────────────┘
```

---

## 10. Session lifecycle

The kernel encodes three lifecycle states and their state transitions (`axon/KERNEL-SLIM.md:452-454`, `axon/memory/MEMORY.md:65-96`):

### 10.1 Session start

```
RETRIEVE(W:current-session) → IF ∅ → clean start
  → APPEND(E:session-log, {event: "session-start", timestamp, context: ∅})
IF ✓ → session was interrupted → surface resume prompt to user
  → APPEND(E:session-log, {event: "session-resumed", timestamp})
```

On a clean start, working memory should be empty (the working directory was either freshly cleared on the prior clean exit or this is a first run). On a detected interrupted session, the boot prompt asks the user whether to resume.

### 10.2 Mid-task checkpoint

```
CHECKPOINT:
  SNAPSHOT(W:) → store as W:checkpoint-[task-id]
  APPEND(E:session-log, {event: "checkpoint", task-id, timestamp, state-summary})
  LOG(DEBUG, "Checkpoint saved for T-[id]")
```

In practice this is the `TOOL(checkpoint)` invocation — §7.1.

### 10.3 Session end (clean)

```
APPEND(E:session-log, {event: "session-end", timestamp, tasks-completed, tasks-pending})
CLEAR(W:) — all working memory
LOG(INFO, "Session ended cleanly.")
```

`CLEAR(W:)` here means deleting every file in `workspace/memory/working/` — the directory should be empty at the next session start (`axon/axon/memory/working/_index.md:6`).

### 10.4 Session end (interrupted / context limit approaching)

```
SNAPSHOT(W:) → STORE(W:interrupted-session, snapshot)
APPEND(E:session-log, {event: "session-interrupted", timestamp, reason, W-snapshot})
LOG(WARN, "Session interrupted. State saved for resume.")
```

This is what `tools/session_save.py` does at the shutdown hook — capture the snapshot to `L:last-session-snapshot`, write the summary to `L:last-session-summary`, append `session-saved` to `E:session-log`, and surface a one-line confirmation to the user.

### 10.5 Lifecycle states table

| State | Trigger | What happens to W: | What happens to L: | What happens to E: | What happens to `_session.md` |
|-------|---------|---------------------|---------------------|---------------------|---------------------------------|
| `session-start` (clean) | Boot with `W:current-session ≡ ∅` | Directory empty; only boot-set keys present (`ws-*`, `myaxon-*`) | Read at startup (`L:cognition-frame`, `L:dev-mode`, `L:halt-mode`, `L:inference-mode`) | Appended: row "session-start" | Started via `tools/session.py start` |
| `session-checkpoint` (mid-task) | `CHECKPOINT` op | Snapshot to `working/checkpoint.json` | Untouched | Appended: row "checkpoint" with key count | `_session.md` checkpoint event appended (every 20 turns + before `_meta.md` mutations) |
| `session-end` (clean) | User exits, all programs done | All `.md` files cleared after snapshot | `L:last-session-summary` + `L:last-session-snapshot` written | Appended: row "session-saved" | Transition to `closed` |
| `session-interrupted` (compaction / context limit) | Context-pressure gate critical, or harness restart | Files remain on disk for next boot to read | `L:last-session-snapshot` may or may not be written, depending on whether session-save ran | Appended: row "session-interrupted" or none if abrupt | Stays at `active`, PID-mismatch detectable by `recover()` |
| `session-resumed` | Boot detects `W:active-phase ≠ ∅` and user picks `[C]ontinue` | Snapshot keys re-written from `L:last-session-snapshot` | Untouched | Appended: row "session-resumed" | Transition to `recovered` (via `recover()` if it were wired — F-D9-022) |

### 10.6 The per-chat `_session.md` state machine

`tools/session.py:33-40` declares the legal transitions:

```python
VALID_STATES = ("active", "frozen", "tagged", "closed", "recovered")
TRANSITIONS = {
    "active":   {"frozen", "tagged", "closed", "recovered"},
    "frozen":   {"active", "tagged", "closed"},
    "tagged":   {"active", "closed"},
    "closed":   set(),
    "recovered": {"active", "frozen", "tagged", "closed"},
}
```

```
       ┌──────────┐
       │  active  │◀─────┐
       └────┬─────┘      │
            │            │
   ┌────────┴────────┐   │
   ▼        ▼        ▼   │
┌──────┐ ┌──────┐ ┌──────────┐
│frozen│ │tagged│ │recovered │
└──┬───┘ └──┬───┘ └────┬─────┘
   │        │           │
   │        └───────────┴──▶ closed (terminal)
   ▼
closed (terminal)
```

`closed` is terminal — no transitions out. `recovered` is the post-compaction state and can return to any of the working states or be closed. Each transition appends an event row to the session ledger.

The session ledger schema (`tools/session.py:7-17`):

```
---
chat_id: <id>
state: active | frozen | tagged | closed | recovered
started: <ISO>
last_action: <ISO>
last_program: <name>
---
<ISO> turn=<n> kind=checkpoint anchor=<a> summary=<text>
<ISO> turn=<n> kind=transition from=<s> to=<s>
<ISO> turn=<n> kind=mutation target=_meta.md
```

The cadence is "every 20 turns AND before any `_meta.md` mutation" (`tools/session.py:17`). This is the per-chat counterpart to the global `session-log.md` — it captures what each chat was doing, independent of whether the user has multiple parallel chats.

---

## 11. State outside the memory scopes

For completeness, three categories of state live **outside** the W:/L:/E:/local/ memory directory but participate in the broader memory model:

| State | Location | Function |
|-------|----------|----------|
| Turn log | `workspace/log/turns/{YYYY-MM-DD}.md` | Append-only daily log of each turn's input + output (50-word summaries). Used by the resume program for context reconstruction (`workspace/programs/resume.md:67-84`) and by `session-summary`. Configured via `L:turn-log-enabled` (`axon/KERNEL-SLIM.md:99-112`). |
| Prompt log | `workspace/log/prompts/` (via `tools/prompt_log.py`) | Verbatim user input, gated by `L:prompt-log-enabled` (`axon/KERNEL-SLIM.md:92-97`). |
| IGAP (instruction-gap) log | `workspace/log/igap/{YYYY-MM-DD}.md` | Append-only log of detected instruction gaps. Gated entry per turn from the IGAP tracker in the response gate (`axon/KERNEL-SLIM.md:237-268`). |
| Per-chat `_session.md` | `{chat-folder}/_session.md` | Per-chat ledger described in §10.6. |
| `kv-store` cache | `workspace/memory/kv-store/cache.db` | Optional diskcache layer (§6.3). |
| `usage-log.jsonl` | `workspace/memory/longterm/usage-log.jsonl` | Records every program run; read by `session_save.py:53-66` for the "top programs" line in the session summary. |
| `dispatch-index.json` | `workspace/memory/longterm/dispatch-index.json` | Cache of dispatch decisions; counted by `session_save.py:85-92`. |

These are state, but not key-value memory. They do not participate in the `W: → L: → E: → QUERY` retrieval order; they are written by their owning subsystem and read on demand.

---

## 12. Putting it together

The cleanest way to think about AXON memory is in three concentric circles:

```
   ┌──────────────────────────────────────────────────────┐
   │                                                      │
   │     ┌────────────────────────────────────────┐       │
   │     │                                        │       │
   │     │    ┌────────────────────────┐          │       │
   │     │    │    in-process state    │          │       │
   │     │    │  (volatile; lost on    │          │       │
   │     │    │   compaction)          │          │       │
   │     │    └──────────┬─────────────┘          │       │
   │     │               │                        │       │
   │     │      CHECKPOINT / STORE(W:k, v)        │       │
   │     │               ▼                        │       │
   │     │    W: working/*.md  (filesystem;       │       │
   │     │    survives compaction; cleared on     │       │
   │     │    clean exit)                         │       │
   │     │                                        │       │
   │     └─────────────────┬──────────────────────┘       │
   │                       │                              │
   │           session-save / STORE(L:k, v)               │
   │                       ▼                              │
   │      L: longterm/*.md  (filesystem; survives         │
   │      across sessions; rollback history kept)         │
   │                                                      │
   │      E: episodic/*.md  (append-only audit; never     │
   │      deleted)                                        │
   │                                                      │
   │      local/*.md  (filesystem; survives, gitignored,  │
   │      never travels between machines)                 │
   │                                                      │
   └──────────────────────────────────────────────────────┘
```

The kernel rules — Core Rule 5 (always CHECKPOINT before yielding), the program-phase tracking discipline (`axon/KERNEL-SLIM.md:298-303`), the retrieval order (`axon/KERNEL-SLIM.md:444`), the 25-key budget (`axon/KERNEL-SLIM.md:445`), and the lifecycle protocol (`axon/memory/MEMORY.md:65-96`) — are all instances of one principle: **state must be either disposable or written to disk**. There is no third option. The memory scopes formalise the four legitimate write destinations, and the retrieval order formalises the four legitimate read sources.

---

## 13. Source citations

| Topic | File:line |
|-------|-----------|
| Memory scope declaration | `axon/KERNEL-SLIM.md:324-325` |
| my-axon W: keys | `axon/KERNEL-SLIM.md:325-330` |
| MEMORY RULES section | `axon/KERNEL-SLIM.md:443-456` |
| Retrieval order | `axon/KERNEL-SLIM.md:444`, `axon/memory/MEMORY.md:42-51` |
| W: budget | `axon/KERNEL-SLIM.md:445`, `tools/rules/r_w_budget.py:1-22` |
| Scope heuristics | `axon/KERNEL-SLIM.md:446-450` |
| local/ rule | `axon/KERNEL-SLIM.md:451` |
| Session-start / end | `axon/KERNEL-SLIM.md:452-454`, `axon/memory/MEMORY.md:65-96` |
| Memory tool (memory.py) | `tools/memory.py:1-126` (path map at line 7, key path at 12, rollback at 15-33, set logic at 64-74) |
| kv-store tool | `tools/kv_store.py:1-93`, `axon/axon/tools/kv-store.md` |
| Checkpoint tool | `tools/checkpoint.py:1-49` |
| Session-save tool | `tools/session_save.py:1-285` (snapshot-version at 237, exclude prefix at 103-105, value cap at 30) |
| Session ledger tool | `tools/session.py:1-250` (states 33-40, recover at 131-169) |
| Boot resume + snapshot read | `axon/BOOT.md:81-110`, `tools/boot.py:170-190` |
| Boot interrupted-session detection | `axon/KERNEL-SLIM.md:614-650` |
| my-axon path map | `my-axon/MYAXON.md:21-37` |
| my-axon boot detection | `axon/KERNEL-SLIM.md:575-596` |
| dev-mode L: storage | `axon/programs/dev-mode.md:1-44` |
| Resume program | `workspace/programs/resume.md:1-110` |
| local/ gitignore | `workspace/.gitignore:4-7` |
| CHECKPOINT shorthand | `axon/KERNEL-SLIM.md:403` |
| Program phase tracking | `axon/KERNEL-SLIM.md:298-303` |
| Compaction rationale | `axon/BOOT.md:113-130`, `axon/KERNEL-SLIM.md:137-138` |
| F-D9-008 (snapshot-version) | `tools/session_save.py:179, 237`, `tools/boot.py:183` |
| F-D9-022 (orphaned recover) | `tools/session.py:131-169`, `CHANGELOG.md:294`, `workspace/programs/code-dev-events-emit.md:41, 45` |

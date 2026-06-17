## B-grade TRAPS — resolution notes (write-ready)

These four programs are agent-interpreted `.md` neurons (AXON pseudo-language), not Python entry points — they are NOT `python3 axon.py <prog>`-runnable. Worked examples below therefore exercise the **underlying tools** each program calls (all read-only / non-mutating: `--help`, `list`, `check`, in-memory `parse`), with REAL captured output. Fabricated output: none.

---

### 1. library-dev — canonical shadow-note format (drift resolved)

**Authoritative format does NOT live in the `.md` programs — it lives in `tools/library.py`.**
Source of truth: `tools/library.py` docstring (lines 13-20) + `parse_shadow()` regex (lines 33-66).

The canonical shadow-note schema is **blockquote-header markdown, not YAML frontmatter**:
```
# Shadow: <title>
> Authors: Last, F.; Last, F.
> DOI:     10.xxxx/...
> Year:    2024
> Venue:   ...        (optional)

---

<body, may contain a "## Key Terms" section>
```
Recognized header keys (case-insensitive): `author`/`authors`, `doi` (`N/A`→empty), `year` (`unknown`→empty), `venue`/`journal`/`journal/venue`. Separator is exactly `\n---\n`. Key terms are read **only** from a heading that matches `## Key Terms` (regex `^##\s*Key Terms\s*\n`).

Two sibling files use **different, non-YAML formats** (this is the "drift" — three formats coexist, none YAML):
- `_meta.md` — colon-key plain text (`library-dev-new.md:125-135`): `name: ...`, `description: ...`, `article-count: 0`.
- `INDEX.md` — a markdown table (`library-dev-new.md:107-122`): `| # | Filename | Title | Authors | DOI | Shadow | Explained | Added |`.
- shadow notes — the blockquote schema above (`library-dev-ingest.md:208-224`).

**The load-bearing bug (real, demonstrated):** the canonical parser keys key-terms extraction off the exact heading `## Key Terms`, but `library-dev-explain.md:145` writes `## Key Terms & Concepts`. The trailing `& Concepts` defeats the regex → `key_terms` parses as `[]` → `intersect` (which builds term sets from `key_terms`) silently produces empty intersections. `library-dev-ingest.md:205` is also loose ("Key terms / concepts (comma list)" — no guaranteed heading).

**Verified example (real captured output, in-memory `library.parse_shadow`, read-only):**
```
$ python3 -c "import sys; sys.path.insert(0,'tools'); import library, json; ..."

CANONICAL  (## Key Terms):
  "key_terms": ["local grid refinement","fault transmissibility","well completion"]

EXPLAIN-STYLE (## Key Terms & Concepts):
  "key_terms": []          ← silently empty: the drift bug
```
**Manual guidance:** document the `library.py` docstring as the single source of truth; flag that writers (`ingest`, `explain`) must emit exactly `## Key Terms` for the comma list, and that `_meta.md`/`INDEX.md` are intentionally not the shadow-note format.

```
$ python3 axon.py library parse --help
usage: library.py parse [-h] --file FILE
  --file FILE
```

---

### 2. goal-define — advisory-only constraints + the (non-)dry-run

**Auto-routing call:** `goal-define.md:91-92`
```
TOOL(constraints, add, "--id {slug} --scope {scope}
     --statement {hardened.protected} --source goal-define")
```
It passes `--id --scope --statement --source` and **omits `--teeth` and `--check`.**

**Resolution (from `tools/constraints.py:62-72`):** `add_row` defaults `teeth='advisory'` and `check=(args.check or '-')`. Therefore **every constraint goal-define routes is advisory** — rendered in scope checklists but **never mechanically enforced**. To make a routed constraint enforceable, goal-define would have to also emit `--teeth mechanical --check "<command>"`.

`constraints add --help` (real captured output) — the full flag surface goal-define under-uses:
```
$ python3 axon.py constraints add --help
usage: constraints.py add [-h] --id ID --scope SCOPE --statement STATEMENT
                          [--teeth {mechanical,advisory}] [--check CHECK]
                          [--source SOURCE]
```

**The "side-effecting dry-run" clarified — `constraints check` is NOT a dry-run.** `tools/constraints.py:75-91` runs each mechanical row's command via `subprocess.run(r["check"], shell=True, cwd=ROOT, timeout=600)` — real execution. Advisory rows return `result: "advisory"` and never execute.

Real captured output (read-only; advisory rows skipped, mechanical rows actually run):
```
$ python3 axon.py constraints list          # 14 rows; goal-define-style rows show teeth: advisory
{ "scope": "(all)", "count": 14, "rows": [
  {"id":"no-dense-rag","scope":"global","teeth":"advisory", ...},
  {"id":"tests-with-neurons","scope":"global","teeth":"mechanical", ...}, ... ] }

$ python3 axon.py constraints check --scope global
{ "ok": true, "scope": "global", "results": [
  {"id":"no-dense-rag","teeth":"advisory","result":"advisory"},      ← not executed
  {"id":"tests-with-neurons","teeth":"mechanical","result":"pass"},  ← command actually ran
  {"id":"lossless-mandate","teeth":"mechanical","result":"pass"}, ... ] }
```

**The actual dry-run surface is a different tool — `simulate`** (real captured `--help`):
```
$ python3 axon.py simulate --help
usage: simulate.py [-h] [--program PROGRAM] [--input INPUT] ... {run,check}
AXON dry-run simulator.        # shadow writes, stub tools, simulation report
```
**Manual guidance:** (a) note that goal-define produces advisory constraints by default; (b) warn that `constraints check` executes shell commands for mechanical rows (cwd = repo root) — pair it with `simulate` when a true no-side-effects preview is wanted.

---

### 3. harness-builder — W:tool-registry resolution

`harness-builder.md` reads `RETRIEVE(W:tool-registry)` at line 66 (display the available tools) and line 96 (`--tools all` expands to the full registry).

**Resolution: harness-builder does NOT populate this key — boot does.** Chain:
- Single source of truth: `tools/REGISTRY.json` (`tools.<name>` map).
- `workspace/WORKSPACE.md:48-53` — load order: OS tools → workspace tools (override on name clash) → **"Merge into W:tool-registry"**.
- `tools/boot.py:359` — note: post-K3, `axon/BOOT.md` sources `W:tool-registry` from `REGISTRY.json` directly; the brief boot envelope dropped the tool **names** (~711 tokens), keeping only `tools.count`.

**Gotcha to document:** in BRIEF boot mode the boot JSON carries only a count, so anything depending on `RETRIEVE(W:tool-registry)` returning **names** (harness-builder's `--tools all`) relies on `BOOT.md` having re-sourced names from `REGISTRY.json`. If that re-source did not run, the key may hold a count, not a name list. Inspect the live registry read-only with:
```
$ python3 axon.py help            # renders every registered tool (name + status + purpose) from REGISTRY.json
Tool               St Purpose
------------------ -- ----------------------------------------
  accountability   ✓  Ledger of spawned/background work; ...
  aegis-policy     ✓  AEGIS policy resolver ...
  ... (full active/optional/planned tool list)
```
**Manual guidance:** state that `W:tool-registry` = the boot-merged view of `tools/REGISTRY.json`; harness-builder consumes it, never writes it; `python3 axon.py help` is the canonical read-only inspector.

---

### 4. deep-research — SKILL, not a program (confirmed) + wiki recommendation

**Confirmed not an AXON program:** absent from `python3 axon.py help`; not in `workspace/programs/`; not in `workspace/programs/skills/`; zero `grep` hits for `deep-research`/`deep_research` across the repo and workspace.

It exists **only as a Claude Code Skill** — listed in the harness's available-skills and invoked via the **Skill tool**, not `axon.py`. AXON's bridge to Anthropic skills is the `skill-adapter` tool (`REGISTRY.json`): it ingests `SKILL.md` (YAML-frontmatter `name`/`description` + markdown body) into `workspace/programs/skills/` as AXON programs — but deep-research has **not** been ingested.

**Wiki recommendation (reframe deep-research):**
- Put deep-research in a dedicated **"Skills (host-provided)"** section, *separate* from "AXON programs" and "AXON tools". Make explicit: invoked via the Skill tool (e.g. `/deep-research`), not `python3 axon.py ...`; lives in the Claude Code harness, not in `tools/REGISTRY.json` or `workspace/programs/`.
- Cross-link to `skill-adapter`: note the optional path to *promote* deep-research into a first-class AXON program (`axon.py skill-adapter ingest`), after which it would appear under `workspace/programs/skills/` and in the program registry.
- Do not document deep-research with the `python3 axon.py <prog>` convention used for AXON programs — that would be incorrect for a host skill.

---

### Command-level reference (the read-only surfaces used above)
| Surface | Read-only invocation | Role |
|---|---|---|
| `axon.py help` / `help <tool>` | `python3 axon.py help [tool]` | render REGISTRY.json (W:tool-registry source) |
| `constraints` | `... constraints list [--scope S]` / `check [--scope S]` / `add --help` | advisory vs mechanical rows; `check` EXECUTES mechanical commands |
| `library` | `... library parse --file F` / `--help` | canonical shadow-note parser (authoritative format) |
| `simulate` | `... simulate --help` (`{run,check}`) | the real dry-run (shadow writes, stub tools) |

All outputs above were produced by actually running these commands / the in-memory parser; none are fabricated.

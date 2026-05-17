# Synapse Contract Schema (v1)

> glossary: SYNAPSE-GLOSSARY v1
> resolves: F-005 (BLOCKER), F-013 (parameterization), D-005, D-013
> validated against corpus: code-dev-study, code-dev-plan, code-dev-pr-review,
> code-dev-safety-audit, library-dev-ingest, shadow (tool), clock (tool)

## Purpose

Define the metadata every synapse (program or tool) must carry so the
orchestrator can rank, fire, and chain it.

## Authoring modes (hybrid per D-005)

- **Inferred** — `synapse-infer` tool parses the synapse body and derives
  contract fields by static analysis (STORE → post-state, READ/WRITE →
  inputs/outputs, EXEC → next-conditional candidates, etc.).
- **Declared** — synapse file header carries `# synapse:` block with explicit
  fields. Declarations **override** inference field-by-field.
- **Effective contract** = inferred ⊕ declared (declared wins).

## Where the contract lives

### Programs (workspace/programs/*.md)

Header front-matter section between `## HEADER` and `## IDENTITY LOCK`:

```
# synapse:
#   domain:          code-dev
#   family:          [code-dev, planning]
#   role:            mutator
#   status:          ACTIVE
#   precondition:    "project.has(02-prs.md) AND not pr.has(spec)"
#   inputs:
#     - W:code-dev-project
#     - W:code-dev-pr-n
#     - file: phases/{phase}/02-prs.md
#   outputs:
#     - file: phases/{phase}/03-prs/PR-{n}.md
#     - W:active-phase
#   post-state:
#     - "file.exists('phases/{phase}/03-prs/PR-{n}.md')"
#     - "phase.has_pr(n)"
#   modes:
#     default:    { input-cap: 8000,  output-cap: 2000 }
#   goal-advances:
#     - phase.goal.statement matches "produce verifiable PR set"
#   next-conditional:
#     - { if: "phase.has_more_unspecified_prs()",
#         suggest: [code-dev-pr-create.next], confidence: 0.9 }
#     - { if: "phase.all_prs_spec'd()",
#         suggest: [code-dev-log, code-dev-pr-review], confidence: 0.85 }
#   cost:
#     tokens-estimate:    8000
#     duration-estimate:  90s
#     side-effect-risk:   low
```

### Tools (REGISTRY.json entries)

Existing fields (`script`, `status`, `category`, `purpose`) are preserved.
New fields added at the same level:

```json
{
  "shadow": {
    "script": "tools/shadow.py",
    "status": "ACTIVE",
    "category": "code-dev",
    "purpose": "Shadow index — versioned, content-addressed findings mirror",

    "synapse": {
      "domain": "code-dev",
      "family": ["code-dev", "indexing"],
      "role": "mutator",
      "invocation_source": ["program", "cli"],
      "precondition": "file.exists(shadow-dir) AND file.readable(target)",
      "inputs": [
        { "arg": "--file", "type": "path" },
        { "arg": "--shadow-dir", "type": "path" }
      ],
      "outputs": [
        { "file": "{shadow-dir}/{stem}.findings.md", "kind": "append-only" }
      ],
      "post-state": [
        "file.exists('{shadow-dir}/{stem}.findings.md')",
        "shadow.hash(target) == shadow.recorded-hash"
      ],
      "modes": {
        "check":  { "args": ["--file","--shadow-dir"] },
        "init":   { "args": ["--file","--shadow-dir","--hash"] },
        "append": { "args": ["--shadow-path","--section","--content"] },
        "list":   { "args": ["--shadow-dir"] },
        "stats":  { "args": ["--shadow-dir"] },
        "stale":  { "args": ["--shadow-dir","--codebase"] }
      },
      "goal-advances": ["pr.shadow-coverage += 1"],
      "next-conditional": [
        { "if": "mode == 'init' AND shadow.is_first_in_pr",
          "suggest": ["code-dev-pr-review", "code-dev-safety-audit"],
          "confidence": 0.8 }
      ],
      "cost": {
        "tokens-estimate": 0,
        "duration-estimate": "1s",
        "side-effect-risk": "low"
      }
    }
  }
}
```

## Field reference (every field is optional unless marked REQUIRED)

| Field | Type | Default if absent | Inferred from |
|-------|------|-------------------|---------------|
| `domain` | string (closed list) | filename-prefix or `meta` | filename prefix |
| `family` | list[string] | `[domain]` | filename + body keywords |
| `role` | enum: `mutator/reader/gate/renderer/router/composer` | `mutator` if any STORE/WRITE/APPEND op in body else `reader` | body op scan |
| `status` | enum: `ACTIVE/OPTIONAL/STUB/ALIAS/DEPRECATED/ARCHIVED` | `ACTIVE` | `# desc:` keywords (stub/alias) |
| `invocation_source` | list: `program / cli / cron / tool-to-tool / kernel` | `[program]` if program-file; `[cli, kernel]` if tool | caller scan + cron.json + axon.py |
| `precondition` | predicate string | `true` | leading ASSERT/GUARD blocks |
| `inputs` | list[input-spec] | `[]` | RETRIEVE + READ ops |
| `outputs` | list[output-spec] | `[]` | STORE + WRITE + APPEND ops |
| `post-state` | list[predicate] | last `STORE(W:active-phase, "{name}:done")` | trailing STORE ops + DONE() |
| `modes` | map[mode-name → mode-override] | `{ default: {} }` | `# modes:` and `# plan-modes:` blocks |
| `goal-advances` | list[predicate] | empty | `# next:` text + `# desc:` keywords |
| `next-conditional` | list[`{if, suggest, confidence}`] | `[]` | `# next:` line (constant clause) |
| `cost` | `{tokens-estimate, duration-estimate, side-effect-risk}` | `{tokens: budget.input-cap, duration: ?, risk: low}` | `# budget:` block |
| `canonical` | string (other synapse name) | absent | `# desc:` containing "alias for X" |
| `requires-shadow` | bool | `true` if synapse role=mutator AND outputs any source-file path; else `false` | body inspection (D-011) |

### input-spec

```yaml
- arg: "--file"          # CLI flag (for tools) OR --
  w-key: "W:code-dev-pr-n"  # W: key (for programs)
  file: "phases/{phase}/02-prs.md"  # file path (templatable)
  type: path | string | int | json
  required: true | false
```

### output-spec

```yaml
- file: "phases/{phase}/03-prs/PR-{n}.md"
  w-key: "W:code-dev-pr-active"
  emit-event: "code-dev.pr.create"
  kind: write | append | overwrite | append-only
```

## Predicate language (subset of goal-schema-v1)

Predicates are boolean expressions over STATE. Supported operators (v1):

```
file.exists(path)             # path may template-interpolate W:/L: keys
dir.exists(path)
file.readable(path) / writable(path)
W.<key>                       # ≡ RETRIEVE(W:<key>); falsy if ∅
L.<key>
state.<dotted-path>           # arbitrary nested state lookup
project.<field>               # project._meta.field
phase.<field>                 # active phase._meta.field
shadow.contains(file)         # shadow tool query
count(glob)                   # int — file count
== != < <= > >=               # value comparisons
AND OR NOT                    # boolean combinators
matches "<regex>"             # string regex
```

Examples:

```
"project.dev-mode == false"
"file.exists('02-plan.md') AND count('03-prs/PR-*.md') > 0"
"W.code-dev-project != null"
"shadow.contains(file) OR state.satisfaction.user >= 7"
```

Predicate evaluator (Phase 3 deliverable: `predicate.py` tool) parses these
into AST, evaluates against current STATE snapshot.

## Modes (parameterized synapses) — per F-013

A synapse may declare multiple `modes`. Each mode overrides specific fields
of the base contract:

```yaml
modes:
  overview:
    cost: { tokens-estimate: 8000 }
    post-state: ["state.study.overview.complete"]
  subsystem:
    cost: { tokens-estimate: 16000 }
    post-state: ["state.study.subsystem.complete"]
  deep:
    cost: { tokens-estimate: 32000 }
    post-state: ["state.study.deep.complete"]
```

Default mode (when no `--mode` flag): the first mode in the map.

## next-conditional clauses

Each clause:

```yaml
- if: "<predicate>"           # evaluated against post-fire state
  suggest: [synapse-name, synapse-name, ...]
  confidence: 0.0 .. 1.0       # ranker base score (combined w/ other signals)
  reason: "<optional note for user>"
```

The orchestrator evaluates each clause's `if` after the synapse fires;
matching clauses contribute their `suggest` list to the candidate pool,
weighted by `confidence` × (other ranker signals).

## Alias canonicalization (resolves F-012)

For deprecated aliases:

```yaml
canonical: code-dev-pr-create   # the real synapse
status:    ALIAS
# All other fields inherited from canonical.
```

For orphan stubs (e.g. code-dev-finalize per F-012):

```yaml
status: STUB
# orchestrator never suggests STUB synapses; surfaces a warning if user
# explicitly invokes one.
```

## Auto-discoverability (D-020 / D-027)

When a new entry lands in `tools/REGISTRY.json` OR a new file lands in
`workspace/programs/*.md`:

1. Boot tool re-scans on next session start.
2. `synapse-infer` runs on the new entry and computes its contract.
3. The ranker indexes it; it becomes suggestable immediately.

For mid-session registration: `register-tool` triggers an in-process reload
(see `register-tool-reload` PR seed in synthesis).

## Validation

A `synapse-validate` tool (Phase 3 deliverable) checks each synapse's
effective contract for:

- Predicate parse errors (syntax).
- Mode collisions (two modes with same name).
- Cyclical `next-conditional` (suggest list references self with no exit).
- `requires-shadow: true` without `shadow.contains(file)` in `post-state`.
- `status: ALIAS` without `canonical:`.
- `status: STUB` without a TODO PR seed referenced.

Synapses that fail validation are flagged in `axon-audit` output but do not
block boot (so partial migrations remain possible).

## Migration path (resolves OQ-08)

1. **Bulk-infer** — run `synapse-infer` on all 174 programs + 75 tools;
   write effective contracts to a side file `synapse-contracts.json`.
2. **Spot-check** — sample 20 contracts manually; tune inference rules.
3. **Author-override** — let authors declare overrides progressively.
   No deadline; declared is opt-in.
4. **Validate** — `synapse-validate` on every boot; surface violations.

Coverage target: ≥ 80 % of programs have at least an inferred contract at
Phase 3 close (per D-6 / `_goal.md`).

## Version + change rule

**Version: v1 (2026-05-17).**

Schema edits require:
1. ADR in Phase 2 `_decisions.md`.
2. Bump version (v1 → v2).
3. Re-validate corpus against new schema before merge.
4. Update glossary if new terms introduced.

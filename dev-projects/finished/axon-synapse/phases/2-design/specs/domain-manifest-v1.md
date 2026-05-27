# Domain Manifest Schema (v1) + Code-Dev & Library-Dev Reference Manifests

> glossary: SYNAPSE-GLOSSARY v1
> resolves: F-008, F-011, D-015, D-026
> validates against: existing code-dev + library-dev programs

## Purpose

Define how a **domain** is declared so that AXON's orchestrator,
suggester, and migration tools can treat code-dev / library-dev /
future domains uniformly.

## Manifest location

`workspace/domains/{name}/manifest.md`

`{name}` is the domain identifier from glossary closed list.
Manifest is a markdown file with YAML front-matter + free-form body.

## Schema (front-matter)

```yaml
---
domain:           code-dev
version:          1
description:      "Code development workflow domain — source-file editing,
                   PRs, reviews, tests, audits."
status:           ACTIVE                          # ACTIVE / EXPERIMENTAL / DEPRECATED

# Where projects under this domain live
container-root:   my-axon/dev-projects/
container-files:                                   # files every project gets
  - { path: "_meta.md",          required: true }
  - { path: "_profile.md",       required: true }
  - { path: "_dont-do-seeds.md", required: true }
  - { path: "_goal.md",          required: true }
  - { path: "masterplan.md",     required: false }
  - { path: "04-log.md",         required: true }
  - { path: "05-branches.md",    required: false }
  - { path: "DAG.json",          required: false } # project DAG (v5+)
  - { path: "DAG.md",            required: false }
  - { path: "phases/",           required: true, kind: dir }
  - { path: "03-prs/",           required: false, kind: dir }
  - { path: "shadow/",           required: false, kind: dir }

# Default workflow when user creates a project in this domain
default-workflow: code-dev.canonical              # references workflow file by name

# Workflows shipped with this domain
workflows:
  - name: code-dev.canonical
    path: workflows/code-dev.canonical.yml
    description: "Canonical code-dev chain (study → plan → pr → log → review → audit → shadow → finalize)"
  - name: python-code-dev
    path: workflows/python-code-dev.yml
    description: "Python variant with lint + test + commit-msg steps"
  - name: cpp-code-dev
    path: workflows/cpp-code-dev.yml
    description: "C++ variant with build + ctest hooks (human-only build per kernel rule)"

# Verb-map: canonical workflow verbs → domain-specific synapse names
# Enables shared programs (flow-shadow, flow-explain) to delegate.
verb-map:
  intake:           code-dev-study
  per-item-analysis: (informal)
  cross-cutting:    code-dev-plan
  shadow:           code-dev-knowledge-shadow      # canonical (per F-007 / F-012)
  explain:          code-dev-explain
  status:           (TBD — see Phase 3 PR seed)
  audit:            code-dev-safety-audit          # canonical (per F-012)
  finalize:         code-dev-finalize              # currently stub (F-012)

# Synapses (programs + tools) registered to this domain
# `domain:` field on synapse contracts auto-populates these:
programs-prefix:  code-dev-                       # filename prefix convention
tools:                                            # tools with category=code-dev
  - shadow
  - cd_cache

# File-convention spec
file-convention:
  phase-folder:   phases/{n-name}/                # e.g. phases/1-study/
  phase-files:                                    # required inside each phase
    - _meta.md
    - _files.md
    - _dont-do.md
    - _decisions.md
    - _deviations.md
    - reviewer-state.md
    - 01-study.md                                 # phase-1 only
    - 02-plan.md                                  # phase-2 only
    - 02-prs.md                                   # phase-2 only
    - 03-prs/                                     # PR specs
    - shadow/                                     # shadow files per PR (D-23 mandatory)
    - reviews/                                    # review transcripts
    - DAG.json                                    # phase DAG (v5+)
    - DAG.md
  pr-file-pattern: "phases/{phase}/03-prs/PR-{N}.md"
  shadow-pattern:  "phases/{phase}/shadow/{stem}.findings.md"

# Default goal templates (per goal-schema-v1)
default-goals:
  project: "Implement the planned changes; ship audited, shadowed PRs."
  phase-1-study:  "Produce findings + synthesis sufficient to design Phase 2."
  phase-2-design: "Produce signed-off design specs sufficient for Phase 3."
  phase-3-implement: "All PRs implemented + tests pass + shadow 100% + audit OK."
  phase-4-validate:  "Retrospective complete; goals checked; metrics reported."

# Allowed mode shortcuts (per kernel COMMAND PARSING)
mode-labels:
  build:  "develop"                              # domain-aware rename per F-010

---
```

## Manifest body (free-form)

After front-matter, the manifest may contain free-form documentation:

- Domain rationale.
- Onboarding notes for new contributors.
- Cross-references to other domains.
- Known edge cases.

### v1.1 additions

### `layer:` axis (OP-03 split)
Each neuron carries `layer:` ∈ `{kernel, system, meta, shared, domain}`
per AXON-GLOSSARY v2. Splits the v1 overloaded `category` axis.
`category` preserved for backwards-compat.

### `source-artifact-glob:` field (FL-08)
Each manifest declares which file patterns constitute "source artifacts"
for the domain — driving the `requires-shadow` inference:

```yaml
source-artifact-glob:
  - "**/*.py"       # code-dev (Python source)
  - "**/*.cpp"      # code-dev (C++ source)
  - "**/*.hpp"
  # ...
```

For library-dev: `**/*.pdf`, `**/*.txt`.
For study-dev / science-dev: declared on adoption.

A neuron's `requires-shadow` flag derives unambiguously:
`requires-shadow = (neuron.affects-source AND outputs match
domain.source-artifact-glob)`.

# Reference manifest — `code-dev`

```yaml
---
domain: code-dev
version: 1
description: "Source-file editing, PRs, reviews, tests, audits."
status: ACTIVE
container-root: my-axon/dev-projects/
container-files: [...as above...]
default-workflow: code-dev.canonical
workflows: [...as above...]
verb-map: [...as above...]
programs-prefix: code-dev-
tools: [shadow, cd_cache]
file-convention: [...as above...]
default-goals: [...as above...]
---

# Code-dev domain

Implements the canonical code-dev workflow originally codified in
`code-dev-*` programs. Preserved verbatim per D-014 (no renames, no
breaking changes). New behavior layered via synapse contracts +
orchestrator suggestions.
```

## Reference manifest — `library-dev`

```yaml
---
domain: library-dev
version: 1
description: "Academic library manager — PDFs/TXTs → shadow → explain → intersect → report → cite."
status: ACTIVE
container-root: workspace/libraries/
container-files:
  - { path: "_meta.md",  required: true }
  - { path: "INDEX.md",  required: true }
  - { path: "shadow/",   required: true, kind: dir }
  - { path: "explained/", required: false, kind: dir }
  - { path: "reports/",   required: false, kind: dir }
default-workflow: library-dev.canonical
workflows:
  - name: library-dev.canonical
    path: workflows/library-dev.canonical.yml
    description: "ingest → explain → intersect → report → cite"
verb-map:
  new:              library-dev-new
  intake:           library-dev-ingest
  per-item-analysis: library-dev-explain
  cross-cutting:    library-dev-intersect
  shadow:           (built-in via library-dev-ingest)
  explain:          library-dev-explain
  status:           library-dev-status
  audit:            (TBD)
  finalize:         library-dev-report
  cite:             library-dev-cite
programs-prefix: library-dev-
tools: []
file-convention:
  phase-folder:    (none — flat container)
  pr-file-pattern: (none — libraries have no PRs)
  shadow-pattern:  "{library-root}/shadow/{stem}.findings.md"
default-goals:
  project: "Library has shadow %, explain %, and report coverage above thresholds."
---

# Library-dev domain

Already shipping. Validates D-015 (multi-domain DNA) per F-011.
Container model is flat (no phases / PRs). Manifests this differently from
code-dev — both legitimate.
```

## Domain registration

A new domain is added by:

1. Creating `workspace/domains/{name}/manifest.md`.
2. Optionally: domain-specific programs under `workspace/domains/{name}/programs/`
   (or stay in `workspace/programs/` with `domain:` field).
3. Optionally: workflows under `workspace/domains/{name}/workflows/`.

Boot scans `workspace/domains/*/manifest.md` and registers each domain
in `W:domains` map. Orchestrator reads this on every dispatch decision.

## Domain detection (which manifest applies)

For a given project (or implicit context):

1. If project `_meta.md` has `domain:` field → use that.
2. Else if project location matches a manifest's `container-root` → that domain.
3. Else if filename prefix of last-fired synapse matches `programs-prefix` →
   that domain.
4. Else: `meta` (kernel-level, no domain).

## Shared programs (D-015 / F-011 hoist candidates)

A future workflow uses `flow-*` shared programs that delegate via
`verb-map`:

```
flow-shadow <project>
  → reads project's domain → reads manifest.verb-map.shadow
  → EXEC(<resolved-synapse>) with passed args
```

`flow-*` programs let workflows be domain-agnostic at the verb level.
Phase 3+ deliverable (not blocking).

## Cross-domain workflows

Some workflows span domains (e.g. a science-dev `review` step delegating to
`code-dev-pr-review` machinery). Cross-domain workflows live at
`workspace/workflows/` (no domain prefix); their `synapses:` may
reference synapses from multiple domains by qualified name
(`code-dev:code-dev-pr-review`, `science-dev:science-dev-analyze`).

## Migration (resolves F-008 implication)

1. **Phase 2 design exit** — both reference manifests (`code-dev`,
   `library-dev`) authored.
2. **Phase 3 PR** — `domain-folder-scaffold` — creates `workspace/domains/`
   + the two reference manifests + symlinks back into existing
   `workspace/programs/` for backwards compat (D-014/D-025).
3. **Phase 3 PR** — `domain-metadata-migrate` — adds `domain:` field to
   every synapse contract via inference (file-prefix). Idempotent.

## Validation (Phase 3 deliverable: `domain-validate`)

Manifest is valid iff:

1. `domain` matches glossary closed list (or registered as new domain).
2. `container-root` directory exists or is gitignored intentionally.
3. `default-workflow` references a real workflow file in `workflows:` list.
4. `verb-map` keys are a subset of glossary's canonical-verb list.
5. `tools:` entries exist in `tools/REGISTRY.json`.
6. `programs-prefix` matches at least 1 existing program file.

## Version + change rule

**Version: v1 (2026-05-17).** Manifest schema bumped with ADR.

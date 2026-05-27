# Documentation Plan (v1)

> glossary: AXON-GLOSSARY v2
> resolves: user request 2026-05-17 "append a documentation plan, workflow
> and explaining everything, also special docs for me to read with a plan
> to make it useful for others"
> serves: D-5 (workflow report), D-15 (most detailed research),
> D-26 (workflow OS for others), I-01 (flaws-register-style traceability
> applied to docs)

## Purpose

Define the documentation layers, audience tiers, authoring workflow,
maintenance rules, and the explicit reading paths for: (a) the project
author (you), (b) future contributors / collaborators, (c) outside users
of AXON, (d) AI agents booting on top of AXON.

## Audience tiers + doc map

### Tier A — Author (you, arturcastiel)

Read-once-thoroughly + reference-as-needed. These exist to consolidate
what's currently scattered across 17 ADRs + 17 findings + 30 demands.

| File | Purpose | Length |
|------|---------|--------|
| `docs/READ-FIRST.md` | The prescriptive reading order — open this first | short |
| `docs/00-EXECUTIVE-SUMMARY.md` | One-page TL;DR of vision + state + next | 1 page |
| `docs/01-CONCEPT-MAP.md` | Synapse model + glossary visualized | 2 pages |
| `docs/02-ARCHITECTURE-AT-A-GLANCE.md` | The whole architecture: diagrams + flows + integration | 2-3 pages |
| `docs/03-DECISION-DIGEST.md` | All 36 ADRs as one-liners with hot-link to full text | reference |
| `docs/04-FLAW-DIGEST.md` | The 24-row flaws register summarized | reference |

### Tier B — Contributors

For someone joining the project to contribute code or docs.

| File | Purpose |
|------|---------|
| `docs/contributors/CONVENTIONS.md` | Coding + doc conventions + glossary discipline |
| `docs/contributors/CONTRIBUTING.md` | How to propose a PR, ADR, finding, spec change |
| `docs/contributors/DEV-MODE.md` | When + how to flip dev-mode safely |
| `docs/contributors/PR-WORKFLOW.md` | The 9-phase PR-review FSM walkthrough |

### Tier C — External users of AXON

For people who want to *use* AXON (not contribute to its kernel).

| File | Purpose |
|------|---------|
| `docs/users/QUICKSTART.md` | Zero-to-first-workflow in ≤ 5 minutes |
| `docs/users/HOW-AXON-THINKS.md` | The synapse / neuron / axon model, plainly |
| `docs/users/CHOOSING-A-DOMAIN.md` | "Which domain fits my work?" decision tree |
| `docs/users/AUTHORING-A-WORKFLOW.md` | Conversational + direct workflow authoring |
| `docs/users/TROUBLESHOOTING.md` | Common confusions + how to recover |

### Tier D — AI agents booting on AXON

For LLM agents loading AXON as their substrate.

| File | Purpose |
|------|---------|
| `docs/agents/AGENT-BOOT.md` | What an LLM agent should read in what order |
| `docs/agents/AGENT-IDIOMS.md` | AXON idioms for AI use (when to QUERY, when to fire, when to CHECKPOINT) |
| `docs/agents/HOST-HARNESS.md` | Adapting AXON to a new harness (Claude Code, Copilot, etc.) |

### Tier E — Strategy / Adoption

For deciding whether AXON fits a domain + how to grow adoption.

| File | Purpose |
|------|---------|
| `docs/strategy/MAKE-IT-USEFUL-FOR-OTHERS.md` | The adoption playbook (this turn) |
| `docs/strategy/COMPARISON.md` | AXON vs other workflow/agent tools |
| `docs/strategy/ROADMAP.md` | Phase 3 + Phase 4 outlook |

## Authoring workflow (docs.canonical.yml)

A `docs` workflow is a first-class workflow under
`workspace/workflows/docs.canonical.yml` (delivered as PR-130 in Phase 3).
The canonical doc-authoring chain:

```
docs-new <topic>                      neuron: docs-new (Phase 3 PR-130)
  → docs-outline                      neuron: docs-outline
  → docs-draft                        neuron: docs-draft (LLM-aided)
  → code-dev-self-review              shared neuron (reuse)
  → docs-link-check                   neuron: docs-link-check (Phase 3 PR-130)
  → docs-glossary-check               neuron: ensure AXON-GLOSSARY v2 cited
  → docs-publish                      neuron: write to docs/{tier}/
```

`execution-mode: fixed` for the canonical chain;
`execution-mode: hybrid` for exploratory drafts.

## Maintenance rules (closes "docs drift" failure mode)

### Rule 1 — Doc bound to spec

Every doc states which spec(s) it explains in front-matter:

```yaml
---
explains:    [SYNAPSE-GLOSSARY v2, synapse-contract-v1.1]
audience:    tier-A
last-checked: 2026-05-17
---
```

When a referenced spec version bumps, the doc gets a `stale: true` flag
until refreshed. `axon-audit` reports stale docs.

### Rule 2 — Doc bound to flaw / decision

User-facing docs cite ADR numbers (`D-026`, `D-031`...) for any
non-obvious design choice. When an ADR is superseded, the doc gets a
`needs-update` flag.

### Rule 3 — Glossary-locked vocabulary

Docs use canonical glossary terms (`neuron`, `synapse-as-edge`).
User-facing prose may keep `synapse` as accepted alias (per D-026) but
must note it as alias on first occurrence.

### Rule 4 — Examples must be real

Every code/YAML example in a doc is either:
- A real file from the repo (path cited), OR
- Tagged `# example — not committed; for illustration only`.

No fictional file references. `docs-link-check` neuron validates.

### Rule 5 — Reading-time budget

Tier-A docs cap at ~2 pages each (≈ 1000 words). Tier-C QUICKSTART caps
at 5-minute reading time. Long-form goes under spec/ or appendix/.

## Doc-versioning + change history

Each doc carries:
```yaml
version: 1
last-updated: 2026-05-17
change-log:
  - { version: 1, date: 2026-05-17, change: "Initial draft" }
```

Bumps when content materially changes (spec version sync, ADR
update, structural rewrite). Not for typo fixes.

## Phase plan

### This turn (Phase 2 docs-pass)

Author the **seed corpus** (≥ 1 doc per tier, ≥ 1 file in `strategy/`).
Ship as part of Phase-2 deliverables.

### Phase 3 PR-130 (already in plan v1.1)

Ship `docs-new`, `docs-outline`, `docs-draft`, `docs-link-check`,
`docs-glossary-check`, `docs-publish` neurons + the
`docs.canonical.yml` workflow.

### Phase 4 docs-validate cohort

- `docs/users/` audited monthly for staleness.
- External-user feedback channel + Q&A doc auto-generated from accepted
  igap entries (cross-cut with D-7 / suggestion engine).
- Translations / locale handling: out-of-scope for v1; revisit if
  community demand surfaces.

## Acceptance criteria

Doc-plan v1 is "done" when:

1. ✅ This spec exists.
2. ✅ Seed corpus authored: READ-FIRST, EXECUTIVE-SUMMARY, CONCEPT-MAP,
   ARCHITECTURE-AT-A-GLANCE, DECISION-DIGEST, FLAW-DIGEST,
   QUICKSTART, HOW-AXON-THINKS, MAKE-IT-USEFUL-FOR-OTHERS.
3. ⏳ Each doc cites AXON-GLOSSARY v2.
4. ⏳ Each doc has front-matter with `explains:` + `audience:`.
5. ⏳ `docs.canonical.yml` workflow file authored (Phase 3 PR-130).
6. ⏳ `axon-audit` extended with docs-staleness row (Phase 3 PR-119).

## Open questions

- **Doc-OQ-01.** Cross-link convention — relative paths to specs, or
  named references via glossary slugs? Picking relative paths for now;
  may revisit if specs move.
- **Doc-OQ-02.** Translations / i18n — out of scope v1.
- **Doc-OQ-03.** Doc-as-code testing — should each example be
  executable? `docs-link-check` covers path existence; deeper validation
  is Phase-4.

## Version

**v1 (2026-05-17).** Schema edits → ADR + version bump per existing rule.

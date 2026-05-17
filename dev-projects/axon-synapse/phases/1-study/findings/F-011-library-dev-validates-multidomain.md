# F-011: Library-dev validates the multi-domain claim — proof of concept already shipping

**Severity:** medium (positive — validates D-015)
**Track:** T-A (validates F-008 hypothesis)
**Date:** 2026-05-17
**Linked demands:** D-26 (workflow OS), D-5 (workflow report)
**Linked decisions:** D-015

## Evidence

Walk of all 9 `library-dev-*` programs:

| Verb | Program | Output |
|------|---------|--------|
| (entry) | `library-dev.md` | router, status / help |
| new | `library-dev-new.md` | `workspace/libraries/{name}/` + INDEX.md |
| ingest | `library-dev-ingest.md` | shadow notes per article, INDEX update |
| explain | `library-dev-explain.md` | per-article deep annotation |
| intersect | `library-dev-intersect.md` | themes, overlaps, contradictions |
| search | `library-dev-search.md` | candidate article list (web) |
| report | `library-dev-report.md` | structured report + gaps |
| cite | `library-dev-cite.md` | `bibliography.bib` / APA / MLA |
| status | `library-dev-status.md` | dashboard: shadow %, explain %, gaps |

**Kernel-op parity with code-dev:** library-dev uses exactly the same 12
kernel ops (STORE, RETRIEVE, CHECKPOINT, EXEC, QUERY, ASSERT, FAIL, READ,
WRITE, LOG, TOOL, IF/ELSE routing). Zero code-dev-only ops required.

**Container parity:**
- code-dev container: `my-axon/dev-projects/{slug}/` with `_meta.md`,
  `_profile.md`, `04-log.md`, `phases/`, `shadow/`, `03-prs/`.
- library-dev container: `workspace/libraries/{name}/` with `_meta.md`,
  `INDEX.md`, `shadow/`, `explained/`, `reports/`.

**Workflow shape parity:**

| Concept | code-dev | library-dev |
|---------|----------|-------------|
| Setup | `code-dev new` | `library-dev new` |
| Source intake | `code-dev study` | `library-dev ingest` |
| Indexing | shadow | shadow |
| Per-item analysis | (informal) | `library-dev explain` |
| Cross-cutting analysis | `code-dev plan` | `library-dev intersect` |
| Synthesis | `code-dev finalize` | `library-dev report` |
| External fetch | `code-dev search` (TBD) | `library-dev search` |
| Status check | `code-dev status` | `library-dev status` |

**Legitimate differences (not deficiencies):**

- library-dev has no PR / DAG (libraries are not versioned changes).
- library-dev has no git interaction (libraries are not version-controlled).
- library-dev uses flat container (no `phases/{n}/` subdirs); articles are
  the unit.

## Why this matters

F-008 hypothesized that library-dev *might* demonstrate multi-domain DNA.
This finding confirms it does. Library-dev is a **working non-code workflow
on the same kernel** — already shipping, already used. The Workflow OS
vision (D-015) is not a speculative architecture; it's a **formalization of
what AXON already does implicitly**.

## What library-dev exposes (about the formalization needed)

1. **File conventions are domain-specific** — code-dev's `phases/{n}/01-study.md`
   numbered layout is not used by library-dev. Each domain has its own file
   layout; the orchestrator needs the manifest to know it.

2. **Some operations are domain-shared, just not declared** —
   `shadow` exists as both `code-dev-shadow` and as library-dev's shadow
   directory; same concept, separate implementations. Candidate for
   **shared programs**: a domain-agnostic `flow-shadow` with a domain hook
   for artifact discovery (git-diff vs PDF list).

3. **`explain`, `status`, `cite` (planned in code-dev), `new`** all appear
   as parallel verbs. Phase 2 manifest should declare these as
   **canonical workflow verbs** with per-domain implementations.

4. **Default-workflow shape is similar across domains** —
   `new → intake → per-item-analysis → cross-cutting → synthesis → cite/finalize`.
   This is a **candidate domain-agnostic default chain**: a base workflow
   template that each domain instantiates.

## Implication for Phase 2 / Phase 3

- **Phase 2.** Domain manifest schema includes:
  - `name:` `code-dev` / `library-dev` / future
  - `container-root:` path pattern for projects under this domain
  - `container-files:` declared per-project files + meaning
  - `default-workflow:` canonical chain
  - `verb-map:` `intake → ingest` (per domain), `per-item-analysis → explain`,
    etc.
- **Phase 2.** Identify shared programs to hoist — provisional list:
  `flow-new`, `flow-shadow`, `flow-explain`, `flow-status`, `flow-cite`,
  `flow-audit`. Each delegates to a domain-specific worker via the manifest.
- **Phase 3.** Hoist program migration: keep `code-dev-shadow` and
  `library-dev` shadow logic; add `flow-shadow` as a router that resolves
  by domain. Backwards compat (D-025): direct invocation of
  `code-dev-shadow` still works.

## Reference for future domain bootstrap

When the user wants to add `science-dev` or `study-dev`, the recipe is:

1. Drop `workspace/domains/{name}/manifest.{yml,md}`.
2. Write domain-specific programs (e.g. `study-dev-source`, `study-dev-annotate`).
   Where a generic `flow-X` exists, delegate to it.
3. Adding the manifest auto-registers the workflows (D-020).
4. Orchestrator's `mode-detect` reads the new domain's verb-map and routes
   intent classification.

No kernel change, no architectural change, no big-bang refactor.

## Suggested action

- **Phase 2 design Q.** Domain manifest schema (with code-dev + library-dev
  as the two reference implementations).
- **Phase 2 design Q.** Canonical workflow verbs — fix the names of the
  shared verbs in glossary.
- **Phase 3 PR seed.** Manifests for code-dev + library-dev as the first
  domain registrations.

# Library-dev FSM — analysis (T-A batch 2 follow-on)

> Source: `workspace/programs/library-dev.md` (master) + 8 sub-programs.
> Date: 2026-05-17.

## Library-dev as proof of multi-domain DNA

Library-dev is a workflow over **academic articles** (PDFs/TXTs), not source
code. It uses the same kernel ops as code-dev (STORE, CHECKPOINT, EXEC, QUERY,
ASSERT, FAIL), the same shadow concept, and the same study → process → report
arc — but produces different artifacts (annotated explanations, intersection
maps, bibliographies).

## Program map

| Verb | Program | Output |
|------|---------|--------|
| (entry) | `library-dev` | router, status / help |
| new | `library-dev-new` | `workspace/libraries/{name}/` skeleton + INDEX.md |
| ingest | `library-dev-ingest` | shadow notes per article in `library/shadow/`, INDEX update |
| explain | `library-dev-explain` | `library/explained/{stem}.md` per article — deep annotation |
| intersect | `library-dev-intersect` | `library/intersect-{ts}.md` — themes, overlaps, contradictions |
| search | `library-dev-search` | candidate article list (web) → user approval |
| report | `library-dev-report` | `library/reports/{type}-{ts}.md` + `gaps.md` |
| cite | `library-dev-cite` | `bibliography.bib` or `bibliography-apa.md` |
| status | `library-dev-status` | dashboard: count, shadow %, explain %, gaps |

## Workflow shape

```
new → ingest → explain → intersect → report
                ↓            ↓          ↓
              status      status     cite
                ↑
              search  (external fill-in for gaps)
```

Default chain: `new → ingest → explain → intersect → report → cite`.
Search and status are sideband (callable at any point).

## Side-by-side: library-dev vs code-dev

| Concept | code-dev | library-dev |
|---------|----------|-------------|
| Container | project (`my-axon/dev-projects/{slug}/`) | library (`workspace/libraries/{name}/`) |
| Source artifact | git codebase | PDFs / TXTs |
| First step | `code-dev study` (read codebase) | `library-dev ingest` (read articles) |
| Indexing | shadow (per-file) | shadow (per-article) |
| Per-item analysis | (informal in study notes) | `library-dev explain` (per-article doc) |
| Cross-cutting analysis | `code-dev plan` (PR-level) | `library-dev intersect` (theme-level) |
| Synthesis | `code-dev finalize` | `library-dev report` |
| Reference output | PR description, commit log | `bibliography.bib` |
| Status check | `code-dev status` | `library-dev-status` |
| Phase structure | `phases/{n}/01-study.md`, `02-plan.md`, ... | flat folder + per-article files |
| Container layout | `_meta.md`, `_profile.md`, `04-log.md`, `05-branches.md`, `phases/`, `shadow/`, `03-prs/` | `_meta.md`, `INDEX.md`, `shadow/`, `explained/`, `reports/`, `intersect-*.md` |
| Phase-numbered files | yes | no |
| PR concept | yes (atomic change unit) | no (libraries aren't versioned changes) |
| Git operations | yes | no |
| Plan/DAG | yes (PR DAG) | no (no atomic change units) |

## Kernel-op parity

Both families use the same 12 ops at the same density:

`STORE`, `RETRIEVE`, `CHECKPOINT`, `EXEC`, `QUERY`, `ASSERT`, `FAIL`,
`READ`, `WRITE`, `LOG`, `TOOL`, `IF/ELSE` routing.

No code-dev-only op is required by library-dev. Confirmed: **kernel is
already domain-agnostic at the op level**.

## Implications for D-015 (workflow OS)

1. **Library-dev proves the kernel supports multiple domains today.** D-015's
   premise is validated.
2. **What library-dev lacks** (compared to code-dev) — not deficiencies, but
   **legitimate domain differences**:
   - No PR/DAG (no atomic change units in a library workflow)
   - No git interaction (libraries aren't version-controlled)
   - Flat container vs phased project
3. **Domain manifest** (per F-008) should formalize these differences as
   **declared** rather than implicit. Each domain ships:
   - File-convention spec (where things live)
   - Workflow set (canonical chains)
   - Programs (the domain's synapses)
   - Default goals per workflow
4. **Hoist candidates** — generic operations sitting in domain-specific names:
   - `code-dev-shadow` + `library-dev` shadow concept → generic `flow-shadow`
   - `code-dev-explain` + `library-dev-explain` → generic `flow-explain`
   - `code-dev-status` + `library-dev-status` → generic `flow-status`

   These could become **shared** programs that domains delegate to, with
   domain-specific parameter shapes.

5. **Container abstraction.** Both domains have a "container" with `_meta.md`.
   The synapse contract should treat the container as an abstract concept;
   the domain manifest tells the orchestrator where to find `_meta.md` and
   how to read it.

## Sample non-code domain sketch (per Q15.6)

If library-dev validates code/non-code parity, future domains plug in
similarly. Example — **`study-dev`** (academic reading + note-taking + synthesis):

```
study-dev new <topic>
study-dev source <pdf|url>      ← like ingest
study-dev annotate <stem>        ← like explain
study-dev synthesize             ← like intersect
study-dev present <type>         ← like report
study-dev cite                   ← already domain-shared
```

Container: `workspace/studies/{topic}/`. Programs map 1-1 to library-dev
verbs with cosmetic renames.

**Example — `science-dev`** (experiment design + execution + analysis):

```
science-dev new <hypothesis>
science-dev design               ← protocol authoring
science-dev preregister          ← OSF / repo submission
science-dev run                  ← log experiment runs
science-dev analyze              ← statistical analysis
science-dev write                ← paper draft
science-dev review               ← (uses code-dev-pr-review machinery?)
science-dev publish              ← submission
```

Container: `my-axon/experiments/{hypothesis-slug}/`. New verbs (design,
preregister, run, analyze, publish) but same kernel ops.

## Conclusion

The kernel is generalizable. The remaining work for D-015 / D-026 is **schema
formalization** (manifest format) + **shared-program hoist** (extract generic
operations from code-dev/library-dev into domain-shared synapses), not
fundamental architecture change.

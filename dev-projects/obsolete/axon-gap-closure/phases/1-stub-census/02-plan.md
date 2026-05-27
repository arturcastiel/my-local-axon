# Plan — 1-stub-census

> From 01-study.md. Codebase: /home/arturcastiel/projects/new-axon/axon (main).
> Remote: git@ci.tno.nl:artur.castiel-tno/axon.git (TNO GitLab — MRs + GitLab CI).

## STRATEGY

Close all 4 real stubs by first extracting a shared `library` python tool
(promotion), then implementing each subcommand against it; then clean up the two
debt items the census exposed (18 aliases, 114 cosmetic tags). Every PR ships
with tests. Test execution + merge runs under a (to-be-reconciled) autonomous-mode
grant; kernel files are out of scope and never touched by this project.

## DEPENDENCY GRAPH

```
PR-0 (grant reconcile) ─┐
                        ▼
PR-E (library tool) ──> PR-A intersect ──> PR-B report ──> PR-C search
                   └──> PR-D cite
PR-F aliases  (independent)
PR-G cosmetic (independent)
```

## PR LIST  (specs live in 03-prs/PR-*.md)

- **PR-0 · grant-reconcile** — prerequisite, not code.
  Fix autonomous-grant: repo name → `artur.castiel-tno/axon`; make it visible to
  the pwd checkout's autonomous-mode tool; confirm GitLab MR/CI semantics.
  TEST: `autonomous-mode check --op merge-squash --repo artur.castiel-tno/axon`
  returns authorized:true; `--op kernel-change` returns false.

- **PR-E · library tool promotion** — `tools/library.py` + REGISTRY entry.
  Extract shared mechanics: shadow-metadata parse (title/authors/DOI/year/venue),
  web-search wrapper, DOI→BibTeX (doi.org content negotiation), APA/MLA formatters,
  term extraction. Thin programs orchestrate the tool (health-check↔health.py pattern).
  TEST: unit tests per function (parse, doi→bibtex with mock, apa/mla format,
  term-extract); `python3 axon.py health` shows `library` ACTIVE.

- **PR-A · library-dev-intersect** — UNION/INTERSECT(≥50%)/DIFF/CONFLICT + `--lens`.
  Replaces `!STUB`. Uses library.term-extract. Writes intersect-{ts}.md.
  TEST: fixture library of 3 explained docs → assert known shared/unique terms,
  one seeded contradiction detected, lens filter narrows output.

- **PR-B · library-dev-report** — certainty-gated synthesis (≥0.90 fact / 0.70–0.89
  qualified / <0.70 → gaps.md). Depends on PR-A intersect data.
  TEST: fixture with high+low confidence claims → high in report, low in gaps.md,
  gaps>0 triggers search suggestion.

- **PR-C · library-dev-search** — gap/query/conversation → web-search → rank →
  approve → ingest. Depends on PR-B gaps.md format.
  TEST: mock web-search → candidates ranked by term overlap; approval routes to
  library-dev ingest (mocked); --gaps reads gaps.md.

- **PR-D · library-dev-cite** — bibtex/apa/mla from shadow metadata; flag missing DOI.
  Depends on PR-E. TEST: fixture shadow notes → valid .bib; DOI=N/A flagged; apa/mla format.

- **PR-F · alias cleanup** — remove 18 deprecated `code-dev-*` shims (+ compiled).
  TEST: each canonical target still resolves; menu/find-program render clean;
  no dangling next-suggests references; programs-registry count drops by 18.

- **PR-G · cosmetic-tag strip** — remove the 114 vestigial `autogen-stub` /
  `· stub` OUTPUT blocks from working programs + aliases (NOT the 4 real stubs).
  TEST: post-strip, `!STUB` count unchanged (4); no program loses real output;
  a lint asserts autogen-stub no longer co-occurs with ACTIVE non-stub programs.

## TESTING (owner directive)
Every PR above lists test criteria. Per kernel CODE DEVELOPMENT RULES, test
execution is not done by AXON in normal mode — it runs under the reconciled
autonomous-mode grant (PR-0) as the build→test→push→MR→CI→merge loop, scoped to
artur.castiel-tno/axon, kernel files excluded. Nothing merges on red CI.

## OPEN QUESTIONS
- PR-E boundary: how much logic moves to python vs stays in orchestrator programs?
- Should PR-G (cosmetic strip) also de-tag the 4 real stubs once implemented
  (they'd no longer be stubs after A–D)? → sequence G after A–D, or split.

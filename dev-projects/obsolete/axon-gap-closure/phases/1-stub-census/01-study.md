# Study — 1-stub-census

> Phase 1 of axon-gap-closure. Codebase: /home/arturcastiel/projects/new-axon/axon (branch main).
> Date: 2026-05-26.

## GOAL

Find every stub / incomplete program across **all** of AXON (axon/ core +
workspace/programs + tools/), document **what each is supposed to do and why**,
then close the gaps. Sub-track: study `library-dev` deeply and promote it to a
first-class, fully-implemented capability (a registered tool), decoupled from
code-dev patterns.

CONFIDENCE: 90 — census is mechanical + verified by reading; the only soft spot
is whether "promote library-dev to a registered tool" matches the owner's intent
(inferred, not confirmed).

## METHOD

Scanned 185 programs + axon/**/*.md + tools/**/*.py. Distinguished three signals:

| Signal | Meaning | Reliable? |
|--------|---------|-----------|
| `!STUB` / `## PLANNED BEHAVIOR` / `## TODO` header | genuinely unimplemented | YES |
| `status: ALIAS` + `EXEC(canonical)` | deprecated shim, redirects | functional, not a gap |
| trailing `## OUTPUT · autogen-stub` -> `"· stub"` | cosmetic autogen boilerplate | FALSE SIGNAL (on 118 files incl. working ones) |

The `autogen-stub` tag is the trap: it sits on 118/185 programs, including
fully-working ones (e.g. library-dev.md, code-dev.md). It must NOT be used as a
completeness signal. Only the `!STUB` header is authoritative.

## CENSUS RESULT

### A · REAL STUBS — 4 (all in library-dev)
All carry `!STUB — Phase 2` + PLANNED BEHAVIOR + ALGORITHM + TODO checklist.
Running them emits a `· stub` placeholder; no logic executes.

1. **library-dev-intersect** — cross-article theme map.
   WHAT: load explained docs -> extract Key Terms -> UNION (all concepts),
   INTERSECT (concepts in >=50% of articles), DIFF (unique to one), CONFLICT
   (contradictory claims via DERIVE); optional `--lens` topic filter; write
   `library/intersect-{ts}.md` + suggested reading order.
   WHY: turn a pile of separately-summarized papers into a comparative map —
   consensus vs. disagreement vs. unique contributions. The analytical core of
   a literature review.
   TODO: term extraction · intersection scoring · contradiction detection ·
   lens filtering · output writer.

2. **library-dev-report** — certainty-gated synthesis report.
   WHAT: report types (literature-review / state-of-the-art / methods-comparison
   / narrative); build claim inventory from explained docs; score each claim by
   (#supporting articles x evidence quality); **certainty gate** — CONFIDENCE
   >=0.90 emit as fact, 0.70–0.89 emit qualified, <0.70 route to `gaps.md` (never
   emit as fact); if gaps>0 offer `library-dev search` to close them.
   WHY: produce a defensible written synthesis where every claim's support level
   is explicit — directly operationalizes AXON's CONFIDENCE discipline for prose.
   TODO: claim extraction · CONFIDENCE scoring model · per-type templates ·
   gaps.md format + search integration · LaTeX/markdown export.

3. **library-dev-search** — online article discovery.
   WHAT: build queries from `--gaps` (read gaps.md), `--query`, or conversation
   (DERIVE last-N-turns); TOOL(web-search) -> candidates; prefer DOI+authors;
   rank by overlap with library Key Terms; present title/authors/DOI/abstract;
   user approves -> fetch -> `library-dev ingest`.
   WHY: closes the loop — when report/intersect expose a knowledge gap, this
   finds the papers that fill it and pulls them into the library.
   REQUIRES: web-search tool (present in registry), pdftotext for open-access PDFs.
   TODO: gap-driven query gen · web-search integration · relevance ranking ·
   approval flow · auto-ingest.

4. **library-dev-cite** — bibliography generator.
   WHAT: load shadow notes -> extract title/authors/DOI/year/venue; DOI->BibTeX
   via doi.org content negotiation; fallback DERIVE from shadow metadata; format
   bibtex / apa / mla; write `library/bibliography.{ext}`; flag DOI=N/A entries.
   WHY: the deliverable step — turns an ingested library into a citable
   bibliography for a paper or report.
   KEY DEP: shadow notes must carry Authors + DOI (enforced by library-dev-ingest).
   TODO: DOI-to-BibTeX call · APA formatter · MLA formatter · missing-DOI flag · output.

**Implemented siblings (context):** library-dev-new, -ingest (255 ln), -explain
(204 ln), -status are real. So the library-dev pipeline works front-half
(new->ingest->explain->status) but the analytical back-half (intersect/report/
search/cite) is scaffold-only.

### B · DEPRECATED ALIASES — 18 (cleanup, not gaps)
All code-dev-* shims with `status: ALIAS`, redirecting via EXEC to a canonical
program, "removed next release." Functional today. Listed in masterplan triage.
  audit->safety-audit · decision->journal-decision · event->journal-event ·
  explain->knowledge-explain · freeze->safety-freeze · handoff->state-handoff ·
  impact->knowledge-impact · log->journal-log · metrics->state-metrics ·
  pr->pr-create · resume->state-resume · search->journal-search ·
  self-review->review-self · shadow->knowledge-shadow · status->state-status ·
  tag->state-save · tour->lifecycle-tour · undo->state-undo
  (NOTE: code-dev-search != library-dev-search — the code-dev one is an alias.)

### C · COSMETIC autogen-stub — ~114 (no action)
False positives. Real logic above a vestigial OUTPUT block. Ignore.

### axon/ core + tools/
Clean. Zero `!STUB` markers. The two python "hits" (programs_registry.py,
audit_axon_lang.py) were false positives — `"STUB"` is a status-enum value and
`TODO` is a reserved-word token, respectively.

## LIBRARY-DEV DEEP STUDY — tool promotion

Current state: `library-dev` is a **program** ([9] on the menu), already separate
from code-dev (sibling, not nested). The owner's "should be a tool outside
code-dev" is read as: **(a) finish the 4 stubs, and (b) promote it to a
first-class registered tool** in tools/REGISTRY.json so it is invocable as
`TOOL(library-dev, ...)` and host-neutral, not just a markdown program.

Open design questions (resolve in Phase 2 / triage):
- Tool vs program boundary: which steps stay declarative programs (orchestration)
  vs become a python tool (parsing, web-search, formatting, DOI lookup)?
- Likely split: a `library` python tool (ingest/parse/cite/search mechanics) +
  thin programs that orchestrate it — mirrors how health-check wraps health.py.
- Registry entry: category `integration` or new `library`? status ACTIVE.
- Storage stays my-axon/libraries/ (gitignored).

## TESTING REQUIREMENT (owner directive, 2026-05-26)

The workflow requires testing **before** anything is considered done:
- Every gap-closure PR spec MUST include explicit test criteria + tests.
- Per AXON CODE DEVELOPMENT RULES, the HUMAN runs builds/tests; AXON never
  executes pytest/build. PR specs define the tests; implementation + run is human.
- A stub is only "closed" when its tests exist and the human confirms they pass.
- Applies equally to the library-dev tool promotion (unit tests for parse/cite/
  search; integration test for the new->ingest->explain->intersect->report->cite chain).

## NEXT
- code-dev plan -> produce PR list:
  PR-A library-dev-intersect · PR-B library-dev-report · PR-C library-dev-search ·
  PR-D library-dev-cite · PR-E library-dev tool promotion (REGISTRY + python tool) ·
  PR-F alias cleanup (18, remove or formally schedule).
- Each PR spec carries test criteria (per directive above).

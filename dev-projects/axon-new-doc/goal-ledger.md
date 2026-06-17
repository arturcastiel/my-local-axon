# Goal ledger — axon-new-doc · hardened 2026-06-17

## GOAL: a usage-wiki for the big AXON programs

**Raw intake (owner 2026-06-17):** "document and organize documentation; create specific
documentation for each individual big program in axon (code-dev, workflow, library-dev);
wiki-style — how to use, a manual, but also very detailed example workflows, so people can
start to use them."

**Audience:** end-users who want to USE the programs (getting-started oriented) — not
internal/contributor architecture reference.

### Hardened (interrogation forks resolved)
- **Scope:** flagship 3 (code-dev, workflow, library-dev) FIRST, then peers
  (goal-define, plan, chat, harness-builder, deep-research) — ~6–8 manuals total.
- **Example bar:** every worked example uses REAL commands + expected output and is
  RUN-VERIFIED against axon before shipping (anti-mimicry — never fabricated output).
- **Structure:** new `workspace/wiki/` tree (one manual per program) + `INDEX.md`,
  separate from the architecture `AXON-DOCS-*` reference; freshness + doc-index wired.

### Acceptance criteria (done = all true)
1. 3 flagship manuals (code-dev, workflow, library-dev) complete; ≥5 peer manuals.
2. Each manual has: **Purpose · Invocation · Command/option reference · ≥2 detailed
   worked-example workflows (real, executed commands + documented output) · cross-links.**
3. `workspace/wiki/INDEX.md` exists; every manual linked; navigable.
4. Wiki wired into freshness (a wiki staleness check) + doc-index includes wiki pages.
5. Each manual ends with a `## Guarded by` test; crucible green.
6. A newcomer can follow any worked example unaided and reproduce the documented output.

### Protected / invariants (→ constraints, scope project:axon-new-doc)
- **wiki-examples-run-verified** — worked examples executed + real output, never fabricated.
- **wiki-freshness-gated** — the wiki cannot silently drift (freshness-gated).
- **programs-untouched** — documenting only; never modify the programs being documented.

**Decider:** owner sign-off at doc-set completion.

### Note on the overview study
The overview's 8 targets were *architecture-reference* docs. This goal REFRAMES the
deliverable to *user manuals*; the overview architecture map remains the source context
that feeds each manual, but the shipped artifacts are usage wiki pages.

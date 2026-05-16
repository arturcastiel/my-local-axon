# C1·P1 — AXON Workspace Programs Map

> Source: parallel exploration agent, 2026-05-16. AXON repo at `/mnt/c/projects/axon`.

## SUMMARY STATS
- **Total programs (main level)**: 112 .md files
- **Compiled programs**: 73 .cmp.md files
- **Compilation coverage**: ~65%
- **Program families**: 8 primary + 15 singletons
- **Tool registry**: 30+ tools (kernel, OS, optional)
- **Addon suites**: 2 (hollow-signal, soccer-manager)
- **Templates**: 4 (.tpl.md + schema files)
- **Harnesses**: 3 (claude-code, copilot, generic)

---

## PROGRAMS BY FAMILY

### 1. `code-dev-*` (56 programs) — Code Development Harness
**Purpose**: 5-phase workflow for large codebase changes (study → plan → pr → log → audit).
**Entrypoint**: `code-dev` (router/hub)

**Primary phases**:
- Phase 1 (study): `code-dev-study` — ingest material, establish goal/priority
- Phase 2 (plan): `code-dev-plan` — produce plan + PR list
- Phase 3 (pr): `code-dev-pr` — write spec for individual PR
- Phase 4 (log): `code-dev-log` — record implementation discoveries
- Phase 5 (audit): `code-dev-audit` — cross-ref specs vs log, surface gaps

**Subcommands & utilities** (selected):
- `code-dev-new` · `code-dev-load` · `code-dev-init` — project lifecycle
- `code-dev-branch` — branch drift detection + sync
- `code-dev-pr-review` — multi-step PR review workflow (largest compiled, 23 KB)
- `code-dev-pr-ready` — pre-push gate (no build execution)
- `code-dev-pr-github` — draft GitHub PR from spec + log
- `code-dev-self-review` — agent reads PR diff vs spec acceptance
- `code-dev-shadow` — shadow index management (view, refresh, query)
- `code-dev-tour` — interactive guided onboarding
- `code-dev-whatif` — dry-run renderer
- `code-dev-undo` · `code-dev-tag` — snapshot/rewind
- `code-dev-review` · `code-dev-reviewer-track` — multi-reviewer dashboard + pattern analysis
- `code-dev-scope-check` — scope drift detection
- `code-dev-search` — full-text search across project artifacts
- `code-dev-suggest-tests` · `code-dev-test-map` — test scenario enumeration + source-to-test mapping
- `code-dev-since` — render delta since last invocation
- `code-dev-decision` — ADR scoped to phase
- `code-dev-explain` · `code-dev-explain-reviewer` — annotated explanation, reviewer briefing
- `code-dev-impact` — API impact analysis
- `code-dev-metrics` · `code-dev-status` — metrics + dashboard
- `code-dev-next` — suggest next command (10-moment classifier)
- `code-dev-divide` · `code-dev-combine` · `code-dev-partition` — split/merge/topology
- `code-dev-merge` · `code-dev-cascade` — post-merge phase refresh
- `code-dev-changelog` — draft changelog
- `code-dev-check-structure` — audit folder vs v4 schema
- `code-dev-hold` · `code-dev-freeze` — pause/release/freeze
- `code-dev-handoff` · `code-dev-help` — per-command help
- `code-dev-link` — cross-project links / dependency graph
- `code-dev-dont-do` — manage phase prohibitions
- `code-dev-event` — append state-change event
- `code-dev-resume` — context reconstruction after compaction
- `code-dev-replay` — dry-run recovery (read 10 layers, render briefing)
- `code-dev-phase-new` · `code-dev-phase-start` — phase scaffolding
- `code-dev-plan-master` — project-level masterplan editor
- `code-dev-pr-link` · `code-dev-pr-respond` · `code-dev-pr-update-spec` — PR utilities
- `code-dev-diff` — triple diff (spec.files vs git, spec.acceptance vs diff, _dont-do vs diff)

**Path**: `workspace/programs/code-dev*.md`
**Compiled**: 18 — `code-dev`, `code-dev-pr`, `code-dev-pr-review`, `code-dev-shadow`, `code-dev-study`, `code-dev-plan`, `code-dev-audit`, `code-dev-init`, `code-dev-log`, `code-dev-explain`

---

### 2. `library-dev-*` (8 programs) — Academic Library Manager
**Purpose**: Ingest PDFs/TXTs, shadow, explain, intersect themes, report.
**Entrypoint**: `library-dev`

**Subcommands**:
- `library-dev-new` · `library-dev-ingest` · `library-dev-explain`
- `library-dev-intersect` — themes/overlaps/contradictions across articles
- `library-dev-search` — search online for related articles
- `library-dev-report` — structured report (certainty-gated, gap-aware)
- `library-dev-cite` · `library-dev-status`

**Tools used**: shadow, semantic-search, document-parser, web-search
**Compiled**: 8 (full coverage)

---

### 3. `axon-*` (3 programs) — Platform Administration
- `axon-audit` — structural integrity (boot chain, refs) + usefulness (health, coverage)
- `axon-compare` — compare AXON vs similar frameworks
- `axon-docs-gen` — regenerate complete AXON-DOCS.md with diagrams

**Compiled**: 3

---

### 4. `igap-*` (1 program)
- `igap-improve` — reads igap report, groups by type, drives study→plan→execute. Requires `L:dev-mode ≡ true`.

---

### 5. `my-axon-*` (1)
- `my-axon-init` — scaffold or clone my-axon/ + write MYAXON.md

### 6. `workspace-*` (1)
- `workspace-backup` — initialize remote, push, or report status

### 7. `mode-*` (3) — Operating Modes
- `mode-detect` · `mode-router` · `mode-suggest`
**Compiled**: 3

### 8. UI / Navigation / Help (singletons, ~39)
**Core UI**: `menu`, `help`, `status`, `health-check`, `list-tools`, `show-memory`, `translate`
**Discovery**: `find-program`, `explain`, `discover`, `deps`, `gain`
**Chat/Session**: `chat-input`, `new-chat`, `switch-chat`, `list-chats`, `session-summary`, `resume`
**Planning**: `plan-new`, `plan-add`, `plan-list`, `plan-done`
**Utility**: `undo`, `run-tests`, `simulate`, `stats`, `versions`, `glossary`, `faq`, `output-layer`, `turn-log`, `memory-compact`, `prompt-log-consent`, `quickstart`, `register-tool`, `register-preference`, `suggest-compile`, `interactive`, `handoff`, `harness-builder`, `autoimprove`, `auto-actions`, `identity`, `meta`, `migrate-workspace`
**Authoring**: `authoring-guide`, `_code-dev-schema-v4.md` (reference, non-executable)
**help/ subdir**: 7 duplicated files for local distribution

---

## COMPILED PROGRAMS

**Path**: `workspace/programs/compiled/`
**Naming**: `{program-name}.cmp.md`
**Total**: 73

**High-value targets** (largest):
- `code-dev-pr-review.cmp.md` — 23 KB
- `code-dev-study.cmp.md` — 12 KB
- `code-dev-shadow.cmp.md` — 11 KB
- `code-dev-pr.cmp.md` — 9 KB

**Format**: Inline compiled logic (symbol expansion, tool stubs, memory inlining); executable by `tools/run.py`.

**NOT compiled** (43 programs):
- Single-use setup (my-axon-init, workspace-backup)
- Interactive prompts (chat-input, plan-new — require QUERY)
- Low-call utilities (undo, register-tool)

---

## TEMPLATES (`workspace/templates/`)

| File | Purpose |
|------|---------|
| `v4-meta.md` | Schema for project/phase metadata |
| `v4-schema.md` | Complete v4 file conventions + layout |
| `v4-session-marker.md` | Session start/resume marker format |
| `code-dev-pr-opm.tpl.md` | C++ PR style template (file-level OPM); legacy fallback |

---

## PREFERENCES (`workspace/preferences/`)

| File | Keys |
|------|------|
| `agent.md` | `inference-mode` (0–10), `confidence-threshold`, `handoff-checkpoint-label`, `event-history-limit`, `event-log-enabled`, `halt-mode`, `eval-default-tolerance`, `retry-default-max`, `cron-auto` |
| `output.md` | output mode, format defaults |
| `smart-dispatch.md` | program dispatch heuristics |
| `tools/` | tool credential hints (subdir) |

**Locked**: `inference-mode-locked=true` — owner+dev-mode required to change.

---

## ADDONS (`workspace/addons/`)

### hollow-signal (criminal investigation sim)
Programs: `accuse`, `analyze`, `case-briefing`, `interrogate`, `requirements`
Data: `cases/default.md`

### soccer-manager (league sim)
Programs: `new-game`, `play`, `set-formation`, `squad`, `transfer`, `standings`, `end-season`, `requirements`
Data: `data/events.md`, `data/league.md`

Both fully self-contained.

---

## HARNESS CONTRACTS (`workspace/harness/`)

| Harness     | File              | Sets                                  |
|-------------|-------------------|---------------------------------------|
| Claude Code | `claude-code.md`  | `L:host-harness`, `L:host-model`      |
| Copilot     | `copilot.md`      | `L:host-harness`                      |
| Generic     | `generic.md`      | `L:host-harness="generic"`            |

Boot picks one based on env (`CLAUDECODE`, `COPILOT_AGENT`) or `.github/copilot-instructions.md`.

---

## CROSS-PROGRAM DEPENDENCIES

### Top 10 most-called programs

| Program          | Called by                       | Type        |
|------------------|---------------------------------|-------------|
| `code-dev` (hub) | menu, mode-router, user         | Router      |
| `code-dev-shadow`| code-dev-*, study, plan         | Utility (heavy reuse) |
| `code-dev-study` | code-dev, igap-improve          | Phase       |
| `code-dev-plan`  | code-dev, code-dev-pr           | Phase       |
| `help`           | user, UI                        | Utility     |
| `menu`           | boot, user                      | Hub         |
| `chat-input`     | mode-router                     | Mode handler|
| `find-program`   | mode-router, discover           | Discovery   |
| `library-dev`    | menu, user                      | Router      |
| `harness-builder`| user                            | Wizard      |

### Dependency graph (simplified)

```
BOOT → menu → {code-dev, library-dev, axon-audit, mode-detect, ...}
code-dev → {new, load, study→shadow+sem, plan→shadow+sem+pr, pr→shadow+plan, log, audit, +20 utilities}
code-dev-pr-review → {shadow, semantic-search, git, diff}
library-dev → {new, ingest, explain, intersect, search, report, cite} → {shadow, semantic-search, document-parser, web-search}
igap-improve → {code-dev-study, code-dev-plan}        ← good reuse: delegates to existing chain
mode-router → {chat-input, find-program, show-memory, ...}
```

### Insights
- `code-dev-shadow` is **the** critical token-saver — every code-dev subcommand checks it.
- `semantic-search` called by 5+ programs; batching/caching candidate.
- `menu` is the only entry point for interactive sessions (no program calls menu directly).
- `igap-improve` reuses code-dev chain — exemplary pattern.

---

## ORPHAN / UNUSED

**True orphans**: 0.

**Low-visibility** (rarely called, limited user exposure):
- `undo`, `simulate`, `run-tests`, `versions`, `glossary`, `faq`, `quickstart`, `prompt-log-consent`, `register-tool`, `register-preference`
- `help/*.md` duplicates of main programs (intentional for local distribution)

---

## DUPLICATION / OVERLAP

| Programs                                       | Overlap                | Resolution / status |
|------------------------------------------------|------------------------|---------------------|
| `code-dev-explain` vs `code-dev-pr`            | both produce code analysis | explain is broader; pr is workflow phase |
| `code-dev-review` vs `code-dev-pr-review`      | both review workflows  | review = dashboard; pr-review = workflow |
| `code-dev-replay` vs `code-dev-resume`         | both recovery ops      | replay reads 10 layers + brief; resume reads _meta + layer 4 |
| `library-dev-search` vs `web-search` tool      | both search            | library wraps web for article domain |
| `help` (main) vs `help/*.md`                   | duplicate help content | intentional: canonical + local |
| `code-dev-pr-github` vs `code-dev-pr`          | both PR output         | pr writes spec; github formats for GH UI |
| `status` vs `code-dev-status`                  | both show state        | status workspace-wide; code-dev project-scoped |

### Beneficial duplication
- `help/` directory: addon distribution
- `code-dev-audit` (read-only) vs `code-dev-log` (write-only) — clean separation
- `code-dev-diff` (structural) vs `code-dev-self-review` (semantic) — different acceptance gates

---

## TOKEN-EFFICIENCY OBSERVATIONS

### High-cost programs (compiled size)
1. `code-dev-pr-review.cmp.md` (23 KB) — could split into 2-3 sub-workflows
2. `code-dev-study.cmp.md` (12 KB) — batch-able
3. `code-dev-shadow.cmp.md` (11 KB) — already lean, but central
4. `code-dev-pr.cmp.md` (9 KB) — template loaded per call; cache candidate

### Existing optimizations
- Shadow caching prevents file re-analysis
- 73 .cmp.md compiled (~65% coverage)
- Memory inlining in compiled programs
- Tool stub optimization

### Opportunities
- Centralize shadow refresh to boot step (vs per-program)
- Lazy-load `help/` duplicates
- Inline both PR template variants
- Cache axon-audit results between writes

---

## INSIGHTS FOR OPTIMIZATION

**Reuse**: igap-improve's delegation pattern should be the template for new programs. New programs should EXEC code-dev utilities, not reimplement.

**Faster dispatch**: 65% compile coverage is solid; top non-compiled candidates worth compiling: `axon-compare`, `harness-builder`, `discover`.

**Less token-heavy**:
- Split `code-dev-pr-review` (23 KB) into review-study / review-harmonize / review-execute
- Eliminate redundant `help/*.md` (lazy load instead)
- Pre-compile both PR template variants
- Cache axon-audit / structural checks

**More useful**:
- Shared addon registry/framework (currently isolated)
- Cross-library citations linking library-dev → code-dev studies
- igap-improve auto-files issues into code-dev projects
- Multi-project parallel comparison
- Semantic diff highlights via LLM

---

## FINAL TABLE

| Aspect           | Count | Status         | Notes                          |
|------------------|-------|----------------|--------------------------------|
| Total programs   | 112   | active         | All executable or reference    |
| Main families    | 8     | healthy        | code-dev (56), library-dev (8), axon (3), igap (1), my-axon (1), workspace (1), mode (3), singletons (39) |
| Compiled         | 73    | 65% coverage   | Largest: pr-review (23K)       |
| Tools            | 30+   | active         | kernel, OS, optional           |
| Addons           | 2     | isolated       | hollow-signal, soccer-manager  |
| Templates        | 4     | schema-bound   |                                |
| Harnesses        | 3     | boot-time      | claude-code, copilot, generic  |
| Preferences      | 5 files | layered      | non-overriding                 |
| Orphan programs  | 0     | all reachable  |                                |

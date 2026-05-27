# 01 — STUDY: AXON Master

> Phase 1 output for `axon-master`. Multi-cycle deep study (4 cycles × 4 phases).
> Goal: make AXON **faster · more useful · gap-bridging · less token-heavy**.
> Source helpers: `helpers/c{1..3}-p{1..4}-*.md`. All findings cite back.

---

## 0 · TL;DR (read this if nothing else)

AXON is an **agent OS** (kernel + programs + tools + harness contract) at `/mnt/c/projects/axon`, written as readable markdown with Python tools. It's **architecturally distinctive** in three ways no major framework matches today:

1. **Symbolic kernel-ops cognition layer** (R11) — internal reasoning is forced into compressed AXON-LANG ops (validated by independent research showing 62-81% token reduction is achievable with this approach).
2. **File-as-program model** — programs are markdown anyone can grep / edit; no Python boilerplate to extend.
3. **Boot-time identity contract + harness contract** — explicit, durable, enforceable.

The **single largest token win** is also the **single biggest unknown**: if the Claude Code harness flags AXON's boot chain (~18.8K tokens) with `cache_control`, AXON gets ~90% off on every turn. If not, the static-first architecture is partly wasted. **Verify this first.** (See §5.A.)

The **single sharpest finding from C3** is that **24 of 73 compiled programs have 0% compression** — they look compiled but save zero tokens. Includes the largest files (`menu.cmp.md`, `code-dev-pr-review.cmp.md`). Cleanup is one-line cron + a compile-gate.

The top-12 cross-cycle backlog appears in §6.

---

## 1 · Inventory & shape (cycles 1-2)

| Surface         | Count | Notes |
|-----------------|-------|-------|
| Programs (workspace)  | 112   | 8 families + 39 singletons. `code-dev-*` (56), `library-dev-*` (8), `axon-*` (3), `mode-*` (3), `igap-*` (1), `my-axon-*` (1), `workspace-*` (1) |
| Compiled `.cmp.md`   | 73    | 65% coverage; 24 with 0% compression (silent waste) |
| Tools (registered)   | 51 ACTIVE + 4 OPTIONAL | 24 kernel layer, 21 OS layer, 6 newer (session-save, docgen, igap, shadow) |
| Templates            | 4     | v4-meta, v4-schema, v4-session-marker, code-dev-pr-opm |
| Addons               | 2     | hollow-signal, soccer-manager (self-contained) |
| Harnesses            | 3     | claude-code, copilot, generic |
| Preferences (files)  | 5     | agent, output, smart-dispatch, tools/, output-layer |
| Boot baseline tokens | ~18,805 | KERNEL-SLIM = 60% of boot (~11.3K) |

Detail: `helpers/c1-p1-{kernel,programs,tools}-map.md` + `helpers/c2-p1-deep-internals.md`.

---

## 2 · What AXON does well (preserve these)

1. **Cognition-language gate (R11)** — no other framework mandates compressed reasoning. Empirically validated by ReaComp / MetaGlyph / RuPLaR papers (62-81% token reduction). [c1-p4]
2. **Markdown programs** — readable, greppable, editable without Python knowledge.
3. **File-backed checkpoints** — likely more durable than Microsoft Agent Framework's in-memory equivalents (per Diagrid critique). [c2-p4]
4. **Lazy-loaded subsystems** — KERNEL-SLIM at boot, compiler/scheduler/memory/processes on demand. Saves ~6,000 tokens/session. [c1-p1]
5. **Identity + harness contracts** — explicit, enforceable, falsifiable. [c1-p1]
6. **igap reuse pattern** — `igap-improve` delegates to `code-dev-study/plan` rather than reimplementing. Exemplary. [c1-p1]
7. **Inference-mode lock** — locked at 3, requires dev-mode + owner instruction to change. Prevents privilege creep. [c1-p1]
8. **No-queue rule** — blocked write-gate commands never auto-execute on dev-mode toggle. User must re-state. Strong safety property.

---

## 3 · Findings by goal

### 3.A · FASTER

| Finding | Source | Fix |
|---------|--------|-----|
| Health probes sequential at boot | c1-p1-tools-map | Parallelize (F-01 in c1-p3) |
| Per-write `log` fsync on hot path | c1-p1-tools-map | Buffer, flush at turn end (F-02) |
| `axon-audit` re-runs on every boot | c1-p1 | Cache between writes (F-04) |
| `tokenizer` lazy-imports on first call | c1-p1 | Pre-warm at boot (F-03) |
| 3 different tokenizer code paths | c3-p1 | Unify (C3-B1) |
| 96 unregistered `shell` calls | c1-p1 | First-class shell tool (F-06) |
| Help/*.md duplicates loaded eagerly | c1-p1 | Lazy-load (F-07) |
| Each tool spawns python (cold start) | c1-p1 | Daemon mode (F-08) |

### 3.B · MORE USEFUL

| Finding | Source | Fix |
|---------|--------|-----|
| No multi-project comparison | c1-p2 | `code-dev-compare` (U-01) |
| Library citations don't link to projects | c1-p2 | `library-dev-cite --into-project` (U-02) |
| Chat doesn't auto-promote to plan | c1-p2 | `chat-promote` detector (U-03) |
| No `addon new` scaffolder | c1-p2 | `addon-new` (U-04) |
| `workspace-backup verify` missing | c1-p2 | new subcommand (U-05) |
| igap groups but doesn't auto-route to projects | c1-p2 | Auto-route to dev-projects/igap/ (U-06) |
| 3 semantic systems share substrate but not index | c1-p1 | Unified embedding service (U-12) |

### 3.C · BRIDGING GAPS (places agent has to guess)

| Finding | Source | Fix |
|---------|--------|-----|
| MYAXON.md auto-execution format not documented | c1-p1 | Write spec (G-01) |
| `smart-dispatch.md` feedback mechanism under-spec'd | c1-p1 | Document (G-02) |
| `context.py` registered PLANNED but referenced in OUTPUT-LAYER | c1-p1 | Ship it (G-03) |
| No `local/` scope in MEMORY.md (referenced everywhere) | c2-p1 | Document (C2-A3) |
| `COMPLETE` vs `COMPLETED` enum mismatch (SCHEDULER vs PROCESS) | c2-p1 | Reconcile (C2-A1) |
| HIGH preemption rule disagrees with priority table | c2-p1 | Resolve (C2-A2) |
| `KILL` doubles as completion + force in PROCESS.md | c2-p1 | Split into 2 ops (C2-A6) |
| `CLEAR(W:key-*)` glob is undocumented | c2-p1 | Document or add `CLEAR-MATCHING` (C2-A5) |
| Two parallel snapshot systems (preempt-* vs checkpoint-*) | c2-p1 | Unify (C2-B1) |
| `workspace/preferences/tools/<name>.md` referenced but doesn't exist | c3-p1 | Define + implement (C3-D2) |
| `usage-log.jsonl` + `dispatch-feedback.jsonl` don't exist | c3-p1 | Bootstrap (C3-E1, C3-E2) |
| Registry doc drift: `workspace/tools/REGISTRY.md` missing 4 tools | c1-p1-tools-map | Sync (G-09) |

### 3.D · SPENDING LESS TOKENS

| Finding | Source | Fix |
|---------|--------|-----|
| **24 of 73 compiled programs have 0% compression** | c3-p1 | Delete + add compile-gate (C3-A1, C3-A2) |
| `menu.cmp.md` (26 KB / 6,964 tokens) is monolithic | c3-p1 | Split (C3-A3) |
| `code-dev-pr-review.cmp.md` (23 KB / 5,821 tokens) is monolithic | c3-p1 | Split (C3-A4) |
| Tokenizer uses cl100k_base (GPT-4) under Claude | c3-p1 + c3-p4 | Switch to ai-tokenizer (W3-03) |
| `web-search` no caching | c3-p1 | TTL 7d cache (C3-C1) |
| `document-parser` no caching | c3-p1 | (file+git-hash) cache (C3-C2) |
| `pattern.py` re-vectorizes every call | c3-p1 | Cache vectorizer per window (C3-C3) |
| `dispatch.py` re-vectorizes every call | c3-p1 | Cache (C3-C4) |
| `semantic-search` lacks mtime invalidation | c3-p1 | Invalidate on file change (C3-C5) |
| No `--quiet` / output-filtering on tools | c3-p1 | Rollout (C3-D1, C3-D2) |
| Episodic memory grows forever | c1-p1 | Compact >30d (C3-G1, T-12) |
| **Cache_control on boot chain unverified** | c3-p4 | Verify + harness contract (W3-01, C3-F1) |

---

## 4 · Workflows AXON could enable today

44 workflows brainstormed across c1-p2 and c2-p2 / c3-p2. Categories:

- **Code development** (10): spec-driven refactor, PR triage, cross-PR test mapping, postmortem replay, branch drift watch, pre-push gate, phase split/merge, multi-project compare, scope-drift watcher, reviewer handoff
- **Library / knowledge** (4): reading-list ingestion, cross-paper synthesis, library→code bridge, daily continuous-reading cron
- **AXON meta / self-improve** (7): boot health audit, igap closure loop, compile coverage chase, drift retrospective, dispatch tuning, backup integrity check, memory compaction sweep
- **Session / conversation** (4): resume after context loss, handoff, mode auto-switch, chat→plan promotion
- **Add-on / domain** (3): hollow-signal investigation, soccer-manager season, generic addon scaffold
- **Token economy** (6): compiled-first dispatch, shadow-cache, lazy help, web-search cache, doc-parser cache, parallel health probes
- **Authoring / dev** (3): new-program flow, audit unused, EXTEND grammar
- **Safety / recovery** (3): undo, snapshot/rewind, identity-drift recovery
- **Cron / scheduled** (7): all 7 already seeded by `axon-cron` boot
- **Megachains** (4): "ship a feature", "read paper → change project", "self-improve weekly", "daily hygiene"

Plus from c2-p2 & c3-p2: spec-consistency sweep, snapshot inspector, optimizer extensions, grammar coverage, template gallery, cache-first prompt assembly, compile gate, tokenizer unification.

Detail: `helpers/c1-p2-workflows.md`, `helpers/c2-p2-workflows.md`, `helpers/c3-p2-workflows.md`.

---

## 5 · Critical strategic findings

### 5.A · The cache contract gates everything
- Boot chain ≈ **18,805 tokens**. If `cache_control` is set: ~90% off after first turn. If not: paid every turn.
- Anthropic default TTL changed from 1h → **5min** silently in March 2026. Quiet failures everywhere.
- Multi-agent / cycle / cron flows: **5-min TTL is punishing** — calls space across minutes/hours.
- Action: verify Claude Code's behavior; document `cache_control` requirement in harness contracts; expose `cache-ttl: 1h` opt-in for multi-agent flows.
- This is the **single highest-leverage open question**.

### 5.B · "Compiled coverage" is partly fiction
- 73/112 compiled (65% coverage)
- BUT 24 of those have **ratio == 0%** — same size as source.
- With `prefer-compiled: true` (smart-dispatch.md L14), dispatch routes to these zero-savings files anyway → silent waste.
- Includes the LARGEST files (`menu`, `code-dev-pr-review`, `code-dev-study`, `code-dev-pr`, `glossary`, `code-dev-log`).
- Sharpest, lowest-risk, immediate win in the entire backlog.

### 5.C · The tokenizer is wrong
- Three code paths (`tokenizer.py`, `context.py`, `_axon_lib.py`) with different fallbacks.
- The persistent path uses `cl100k_base` (GPT-4) — but `L:host-model` is Claude.
- All published "compression ratios" in `benchmark-log.md` are **off by 5-15%**.
- Until this is fixed, every measurement-based decision is questionable.
- Fix: switch to `ai-tokenizer` (offline, 98%+ Claude accuracy, 5-7× faster than tiktoken).

### 5.D · Spec drift is real
- C2 found multiple cross-spec inconsistencies (status enums, preemption rules, undocumented memory scope).
- These don't break things today but they bleed agent confidence and create grammar misses at compile time.
- Cure: doc audit (cheap), then cross-spec validator program (small).

### 5.E · Soft-fail philosophy hides bugs
- Output-schema mismatch: WARN-only.
- Stale `.cmp.md` in non-interactive context: prompts QUERY (breaks cron/CI).
- Unregistered tools: TOOLCHECK warning, never blocks compile.
- Cure: per-program `# strict-schema: true` opt-in + `compile --auto-recompile` for non-interactive.

### 5.F · AXON's moat is real
- C1·P4: AXON's symbolic kernel-ops cognition layer is **not** in LangGraph / CrewAI / AutoGen / Smolagents.
- C2·P4: AXON's file-backed checkpoint discipline appears stronger than the named frameworks (Diagrid critique).
- C1·P4: ReaComp / MetaGlyph / RuPLaR papers validate the symbolic-DSL approach with empirical 62-81% token reduction.
- Positioning: AXON is the **deterministic, auditable, symbolic agent OS** — leans into a real industry gap.

---

## 6 · TOP 12 backlog (cross-cycle, deduplicated, ranked by impact/effort)

| # | ID    | Item                                                                  | Impact | Effort | Score | Cycle |
|---|-------|-----------------------------------------------------------------------|--------|--------|-------|-------|
| 1 | C3-A1 | Delete or quarantine 24 zero-compression `.cmp.md` files                | 5 | 1 | 5.0 | C3 |
| 2 | W3-01 | Document `cache_control` requirement in harness contracts             | 5 | 1 | 5.0 | C3 |
| 3 | C2-A1 | Reconcile `COMPLETE` vs `COMPLETED` enum                              | 4 | 1 | 4.0 | C2 |
| 4 | C2-A3 | Document `local/` scope in MEMORY.md                                   | 4 | 1 | 4.0 | C2 |
| 5 | U-06  | Auto-route `igap-improve` → `dev-projects/igap/`                       | 4 | 1 | 4.0 | C1 |
| 6 | T-01 / C3-C1 | `web-search` cache (TTL 7d)                                    | 4 | 1 | 4.0 | C1+C3 |
| 7 | C3-F1 | Audit how Claude Code lays out our boot chain in actual prompt        | 5 | 2 | 2.5 | C3 |
| 8 | C3-A2 | Compile gate: refuse `.cmp.md` if ratio < 5%                            | 5 | 2 | 2.5 | C3 |
| 9 | F-01  | Parallelize `health` tool probes                                      | 3 | 1 | 3.0 | C1 |
| 10 | F-07 / T-06 | Lazy-load `help/*.md` only on `help X`                          | 3 | 1 | 3.0 | C1 |
| 11 | U-02  | `library-dev-cite --into-project` flag                                 | 3 | 1 | 3.0 | C1 |
| 12 | W3-03 | Switch tokenizer from cl100k_base to ai-tokenizer (Claude-aware)       | 4 | 2 | 2.0 | C3 |

Honorable mentions (next 8): C3-B3 (re-baseline benchmark log), C3-E1/E2 (bootstrap usage + dispatch logs), C3-F3 (document static-first contract), C2-A2 (HIGH preemption resolve), C2-A5 (CLEAR(W:key-*) glob doc), G-01 (MYAXON.md spec), C2-D1 (grammar-miss tracker), W3-05 (audit MYAXON.md size).

Full backlog: `helpers/c{1,2,3}-p3-improvements.md` + extension items in `c{2,3}-p4-web-findings.md`.

---

## 7 · What we deliberately DO NOT recommend

- ❌ Rewrite `axon.py` in a new language. Python is the source of truth.
- ❌ Replace markdown programs with JSON. Loses readability + grep-ability.
- ❌ Remove `help/` entirely. Lazy-load instead — addons depend on local help.
- ❌ Auto-merge igap improvements into kernel without human gate (Core Rule 10).
- ❌ Add a "fast" execution path that bypasses gates (R11/R7/R_COHERENCE non-negotiable).
- ❌ Adopt LangGraph/CrewAI's Python-class agent model wholesale — would lose AXON's file-as-program moat.
- ❌ Replace symbolic AXON-LANG with prose at the cognition layer — it's the moat.

---

## 8 · Open questions for next phase (`code-dev plan`)

1. **§5.A**: How does Claude Code lay out our boot chain in the actual prompt sent to Claude? (gates the largest single optimization.)
2. **§5.C**: What's the actual call site of each tokenizer path? (Confirm cl100k_base really is the persistent path.)
3. **§3.D**: Should the compile-gate be opt-in (`# allow-low-ratio: true`) or opt-out?
4. **§5.D**: Is a `kernel-conflict-scan` program worth shipping (vs strengthening `axon-audit`)?
5. **§3.B**: Should `library-dev → code-dev` linking be a first-class concept (citation-graph) or just a flag?
6. **§5.E**: What's the right default for `L:compile-strictness`? Strict for cron/CI, lenient for interactive?
7. **C2-B1**: Is the snapshot unification worth the migration shim cost?
8. **§5.B**: After cleanup, what's the realistic compile-coverage target? 80%? 90%? Or lower with quality bar?

---

## 9 · Recommended next steps

1. **Run `code-dev plan`** to convert §6 backlog into PR specs.
2. **Tag PR-001 = §5.A audit** (cache contract verification). Without this number, all token optimization is in the dark.
3. **Tag PR-002 = §5.B cleanup + gate** (delete 24 zero-compression files; add compile-gate). Lowest risk, biggest immediate clarity win.
4. **Tag PR-003 = §5.C tokenizer fix** (ai-tokenizer + path unification). Precondition for all future measurement.
5. **Tag PR-004 = §5.D spec doc cluster** (enum reconcile + local/ scope + KILL/CLEAR docs). Kills agent-confusion bugs cheaply.
6. **Tag PR-005 = top-3 caches** (web-search, document-parser, pattern). Compounding token win.

These five PRs alone would:
- Eliminate the 24-file silent waste
- Verify or fix the cache contract
- Make every measurement reliable
- Close the most-cited spec ambiguities
- Add the 3 caches that multiply token savings across cycles

---

## 10 · Helper file index

| File | Cycle.Phase | Topic |
|------|-------------|-------|
| `helpers/INDEX.md` | — | helpers overview |
| `helpers/METHODOLOGY.md` | — | study methodology |
| `helpers/c1-p1-kernel-map.md` | C1·P1 | kernel + core surface |
| `helpers/c1-p1-programs-map.md` | C1·P1 | 112 programs by family + dep graph |
| `helpers/c1-p1-tools-map.md` | C1·P1 | 51 tools, registry, overlaps |
| `helpers/c1-p2-workflows.md` | C1·P2 | 40+ workflows |
| `helpers/c1-p3-improvements.md` | C1·P3 | first backlog (47 items) |
| `helpers/c1-p4-web-findings.md` | C1·P4 | caching · frameworks · DSL · CC primitives |
| `helpers/c2-p1-deep-internals.md` | C2·P1 | compiler, scheduler, memory, processes, programs |
| `helpers/c2-p2-workflows.md` | C2·P2 | spec-consistency + snapshot + optimizer workflows |
| `helpers/c2-p3-improvements.md` | C2·P3 | structural-consistency backlog |
| `helpers/c2-p4-web-findings.md` | C2·P4 | DSL grammar + checkpoint patterns |
| `helpers/c3-p1-token-hotspots.md` | C3·P1 | boot baseline · 24-file finding · caching gaps |
| `helpers/c3-p2-workflows.md` | C3·P2 | cache-first, hygiene, dispatch, measurement workflows |
| `helpers/c3-p3-improvements.md` | C3·P3 | token-economy backlog |
| `helpers/c3-p4-web-findings.md` | C3·P4 | Anthropic cache TTL + Claude tokenizer |

---

## 11 · Synthesis statement

AXON is **architecturally well ahead of mainstream agent frameworks** in symbolic compression, identity contracts, and file-backed checkpoint discipline. Its weak points are operational: an unverified cache contract, a wrong tokenizer, 24 silently-broken compiled files, undocumented memory scopes, and soft-fail policies that hide real bugs. Five focused PRs (cache audit · cleanup+gate · tokenizer fix · spec doc cluster · top-3 caches) would close most of the high-impact gaps with low effort and zero architectural risk. Larger items (snapshot unification, optimizer extensions, multi-agent unified checkpoint, native local-LLM harness) are not urgent and should follow real measurement once the tokenizer is corrected.

**Phase 1 complete.** Ready for `code-dev plan`.

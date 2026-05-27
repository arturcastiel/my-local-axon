# C3·P3 — Token-economy improvements (ranked)

> Token-focused backlog. Builds on C3·P1 measurements + C3·P2 workflows. **Priority on items that directly reduce tokens-per-session.**

## Scoring rubric (same as C1·P3)
Impact 1-5, Effort 1-5. Score = Impact / Effort.

---

## A. CRITICAL — eliminate silent waste

| ID    | Item                                                                  | Impact | Effort | Score | Source |
|-------|-----------------------------------------------------------------------|--------|--------|-------|--------|
| C3-A1 | Delete or quarantine 24 zero-compression .cmp.md files                 | 5      | 1      | 5.0   | C3·P1 headline |
| C3-A2 | Compile gate: refuse to write `.cmp.md` if ratio < 5%                  | 5      | 2      | 2.5   | C3·P2 B1 |
| C3-A3 | Split `menu.cmp.md` (26 KB / 6964 tokens) into menu-render + state-gather | 4 | 3 | 1.3 | C3·P1 finding |
| C3-A4 | Split `code-dev-pr-review.cmp.md` (23 KB / 5821 tokens) into review-study/-harmonize/-execute | 4 | 4 | 1.0 | C3·P1 + C2·P2 |

---

## B. HIGH — measure before optimizing

| ID    | Item                                                                  | Impact | Effort | Score | Source |
|-------|-----------------------------------------------------------------------|--------|--------|-------|--------|
| C3-B1 | Unify tokenizer code paths (tokenizer.py + context.py + _axon_lib.py → one) | 4 | 2 | 2.0 | C3·P1 finding |
| C3-B2 | Use Claude-aware tokenizer when host-model is Claude (not cl100k_base) | 4 | 3 | 1.3 | C3·P1 finding |
| C3-B3 | Re-baseline `benchmark-log.md` with Claude tokenizer                   | 3      | 1      | 3.0   | follows B1+B2 |
| C3-B4 | Per-program `# budget: <n>` directive + compile gate                    | 4      | 3      | 1.3   | C2·P3 C5 dual |

---

## C. HIGH — caching of heavy I/O tools

| ID    | Item                                                                  | Impact | Effort | Score | Source |
|-------|-----------------------------------------------------------------------|--------|--------|-------|--------|
| C3-C1 | `web-search` cache (TTL 7d, key=normalized query)                       | 4      | 2      | 2.0   | C3·P1 + C1·P3 T-01 |
| C3-C2 | `document-parser` cache (key=file+git-hash+mtime)                       | 4      | 2      | 2.0   | C3·P1 + C1·P3 T-02 |
| C3-C3 | `pattern.py` vectorizer cache per (workspace, window)                  | 3      | 2      | 1.5   | C3·P1 + C1·P3 T-03 |
| C3-C4 | `dispatch.py` vectorizer cache per (workspace, registry mtime)         | 3      | 2      | 1.5   | C3·P1 |
| C3-C5 | `semantic-search` mtime invalidation                                   | 3      | 3      | 1.0   | C3·P1 |

---

## D. MEDIUM — tool output filtering

| ID    | Item                                                                  | Impact | Effort | Score | Source |
|-------|-----------------------------------------------------------------------|--------|--------|-------|--------|
| C3-D1 | `--quiet` and `--format=json|summary|full` on every tool                | 4      | 5      | 0.8   | C3·P1 + C3·P2 E1 |
| C3-D2 | Define `workspace/preferences/tools/<name>.md` filter format + reader   | 3      | 3      | 1.0   | C3·P1 (file referenced but absent) |
| C3-D3 | Summarize prompt-log entries before re-injection                       | 3      | 2      | 1.5   | C3·P2 E3 |
| C3-D4 | Skip turn-log for !BG / read-only programs                              | 2      | 1      | 2.0   | C1·P3 T-10 |

---

## E. MEDIUM — dispatch / coverage

| ID    | Item                                                                  | Impact | Effort | Score | Source |
|-------|-----------------------------------------------------------------------|--------|--------|-------|--------|
| C3-E1 | Bootstrap `dispatch-feedback.jsonl` (it doesn't exist)                  | 3      | 1      | 3.0   | C3·P1 |
| C3-E2 | Bootstrap `usage-log.jsonl`                                             | 3      | 1      | 3.0   | C3·P1 |
| C3-E3 | Hot-call inlining — when program calls callee ≥5×, inline at compile   | 3      | 4      | 0.75  | C3·P2 C3 |
| C3-E4 | Compile high-traffic uncompiled (axon-compare, harness-builder, discover) | 3   | 2      | 1.5   | C1·P3 T-04 |

---

## F. MEDIUM — host-harness static-first

| ID    | Item                                                                  | Impact | Effort | Score | Source |
|-------|-----------------------------------------------------------------------|--------|--------|-------|--------|
| C3-F1 | Audit how Claude Code lays out our boot chain in the actual prompt    | 5      | 2      | 2.5   | C1·P4 + C3·P2 A1 |
| C3-F2 | If interleaved, propose static-prefix injection (UserPromptSubmit hook) | 4    | 3      | 1.3   | follows F1 |
| C3-F3 | Document static-prefix contract for harness authors                    | 3      | 1      | 3.0   | hardens for future harnesses |

---

## G. LOW — episodic compaction

| ID    | Item                                                                  | Impact | Effort | Score | Source |
|-------|-----------------------------------------------------------------------|--------|--------|-------|--------|
| C3-G1 | Summarize E:session-log entries past 30 days; archive raw              | 3      | 3      | 1.0   | C1·P3 T-12 |
| C3-G2 | Cap `last-summary` size in menu render                                 | 2      | 1      | 2.0   | C1·P3 T-11 |
| C3-G3 | Inline both PR template variants into `code-dev-pr.cmp.md`              | 2      | 1      | 2.0   | C1·P3 T-07 |

---

## TOP 15 (combined backlog from this cycle, ranked by score)

| Rank | ID    | Item                                                          | Score |
|------|-------|---------------------------------------------------------------|-------|
| 1    | C3-A1 | Delete/quarantine 24 zero-compression .cmp.md files            | 5.0   |
| 2    | C3-B3 | Re-baseline benchmark-log with Claude tokenizer                | 3.0   |
| 3    | C3-E1 | Bootstrap dispatch-feedback.jsonl                              | 3.0   |
| 4    | C3-E2 | Bootstrap usage-log.jsonl                                      | 3.0   |
| 5    | C3-F3 | Document static-prefix contract for harness authors            | 3.0   |
| 6    | C3-A2 | Compile gate: refuse ratio < 5%                                | 2.5   |
| 7    | C3-F1 | Audit Claude Code boot-chain layout                            | 2.5   |
| 8    | C3-B1 | Unify tokenizer code paths                                     | 2.0   |
| 9    | C3-C1 | web-search cache                                                | 2.0   |
| 10   | C3-C2 | document-parser cache                                           | 2.0   |
| 11   | C3-D4 | Skip turn-log for !BG / read-only                               | 2.0   |
| 12   | C3-G2 | Cap last-summary size in menu                                   | 2.0   |
| 13   | C3-G3 | Inline PR template variants                                     | 2.0   |
| 14   | C3-D3 | Summarize prompt-log entries                                   | 1.5   |
| 15   | C3-C3 | pattern vectorizer cache                                       | 1.5   |

---

## ESTIMATED IMPACT (rough)

If all 15 ship:
- **Boot tokens** (~18,805 today) → likely unchanged at boot, but cache-hit-on-replay drops effective cost.
- **Per-turn waste** (24 × avg 2,000 tokens of zero-compression files dispatched) → -50,000 tokens across affected programs (one-time cleanup).
- **Web-search hot-cycles** (cycle work like axon-master) → -60-80% on repeated queries.
- **Document-parser** (library-dev workflows) → -100% on unchanged files.
- **Pattern/dispatch** (TF-IDF refits) → -80% wall-clock.
- **Boot-chain caching** (90% off cached input via prompt caching) → if static-first verified, this is the biggest single win.

**Order to ship**:
1. C3-A1 (cleanup — lowest risk, immediate clarity)
2. C3-A2 (gate — prevent regression)
3. C3-F1, C3-F3 (audit + document the cache contract)
4. C3-B1, C3-B2, C3-B3 (measurement before further optimization)
5. C3-C1, C3-C2 (caches with most-obvious payoff)
6. Everything else by score

---

## RISKS

- **C3-A1**: deleting compiled files removes potential rollback; keep a `compiled/quarantine/` folder for one release.
- **C3-A2**: if the gate is too strict, legitimate small programs fail. Default 5% is safe; allow `# allow-low-ratio: true` opt-out.
- **C3-B2**: Claude tokenizer dependency adds a runtime call; cache responses.
- **C3-C1**: web-search cache risks staleness; default TTL 7d is aggressive — start at 24h.
- **C3-D1**: `--quiet` rollout touches every tool; phase across releases.

---

## CYCLE 4 INPUTS

C4 synthesis should:
- Lead with C3-A1 / A2 as the sharpest finding
- Tie static-first prompt structure to the 90% cache-hit theoretical max
- Frame the tokenizer unification as a precondition to all measurement
- Combine C1-top-12, C2-top-12, C3-top-15 into a single executive backlog (deduplicated)

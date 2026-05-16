# CD·PLAN·I1·S — study refinement (iteration 1)

> Iteration 1 of 4. Re-reads the 91-goal tree with one question: "what's still vague enough to make the plan wrong?"

## Method
Walk every P0 goal. Flag with one of:
- **CLEAR** — ready to schedule.
- **VAGUE** — needs sub-specification before planning.
- **CONFLICT** — overlaps with another goal; need merge/split.
- **MOOT** — can be dropped or rolled into another.

## Walk-through (P0 only)

### G.inf — schema
- G.inf.01 (v4.1 documented). CLEAR.
- G.inf.02 (migrator). VAGUE: target chain ambiguous (v1→v4 OR v1→v4.1?). PICK v1→v4.1 since v4 was never actually shipped.
- G.inf.03 (resume auto-migrate). CLEAR after G.inf.02.
- G.inf.04 (atomic write helper). VAGUE: applies to how many files? Scope = `_meta.md`, `_actions.log`, `_session.md`, `journal/*`.

### G.tok — compiler / tokens
- G.tok.01 (audit numbers). VAGUE: tokenizer choice. PICK anthropic-tokenizer; fall back to char/4 if unavailable.
- G.tok.02 (regression gate). VAGUE: threshold. PICK 0.95 bytes AND 0.95 tokens; --override flag for one-off.
- G.tok.03 (static-prefix lint). VAGUE: what counts as drift? PICK: first 2 KB of compiled file must be byte-identical across two consecutive compiles (no timestamps, no paths).
- G.tok.04 (quarantine RED). CLEAR after G.tok.01.

### G.umb — naming / umbrellas
- G.umb.04 (rename-safety harness). VAGUE: snapshot format. PICK JSONL of `{program, desc, sections}` keyed by program-name.

### G.study — study mode
- G.study.01 (modes taxonomy). CLEAR.
- G.study.02 (_index.md). CLEAR.
- G.study.03 (staleness). VAGUE: threshold. PICK 30 days warn / 60 days stale / 90 days strict-block.
- G.study.04 (migrate existing 01-study.md). CLEAR (handled by migrator).

### G.plan — plan mode
- G.plan.01 (plan modes). CLEAR.
- G.plan.02 (consults `_index.md`). CLEAR.
- G.plan.04 (reads rules). CLEAR.
- G.plan.05 (governance trace). CLEAR.

### G.gov — governance
- G.gov.01 (rules schema). CLEAR (defined in U-5).
- G.gov.02 (precedence doc). CLEAR.
- G.gov.04 (--strict). CLEAR.
- G.gov.05 (pr ready --strict). VAGUE: which checks fire? PICK: rules, stale-studies > 60d, failing tests, missing acceptance entries.

### G.sess — sessions
- G.sess.01 (_session.md). CLEAR.
- G.sess.02 (verb distinctions). CLEAR (doc only).
- G.sess.03 (auto-checkpoint). VAGUE: cadence. PICK every 20 turns OR before any verb that mutates `_meta.md`.
- G.sess.04 (compaction recovery). VAGUE: detection signal. PICK: identity-gate triggered AND no recent `_session.md` activity within 2 min.

### G.test — testing
- G.test.01 (structural). CLEAR.
- G.test.02 (dispatch corpus). VAGUE: size. PICK seed 30; ratchet to 50; ratchet to 100 over 3 waves.
- G.test.05 (token budget). CLEAR after G.tok.05.
- G.test.06 (router contract). CLEAR after G.umb.01.
- G.test.07 (rename-safety). CLEAR.

### G.doc — documentation
- G.doc.01-04 (workflows/study/plan/schema). CLEAR.
- G.doc.10 (cheatsheet). CLEAR.

### G.obs — observability
- G.obs.01 (per-turn logging). VAGUE: schema. PICK JSONL at `my-axon/log/usage/<date>.jsonl` with: ts, session, program, in_tokens, out_tokens, cache_creation, cache_read.

### G.safe — safety
- G.safe.01 (catalog file). CLEAR.
- G.safe.03 (secret redaction). VAGUE: patterns. PICK: regex set for API-key-like sequences (gh*, sk-*, AKIA*, openai_*, eyJ*), env-style `*_TOKEN=` / `*_KEY=`. Documented allowlist.

## Conflicts found
- G.study.04 (move 01-study.md) is partially a migrator step → fold INTO G.inf.02 step v4→v4.1.
- G.test.07 (rename-safety) was double-listed at U-3 + G.umb.04 → keep ONE owner: G.umb.04 produces the harness, G.test.07 keeps it green.

## Vague-but-now-decided
Each VAGUE item above now has a PICK. The plan can schedule with these picks; revisit at acceptance time.

## Missing from goal tree (gaps in the gap-closure!)
- **No goal for the failure-mode catalog file itself being kept up-to-date** — add: G.safe.09 "catalog hygiene (review quarterly)". P2.
- **No goal for `axon.py` boot itself being tested** — add: G.test.09 "boot smoke test". P1.
- **No explicit goal for tokenizer choice being pinned and versioned** — fold into G.tok.01.

## Output of I1·S
- 4 newly-resolved VAGUE → PICK statements.
- 2 conflicts merged.
- 2 new goals added (G.safe.09, G.test.09) — tree is now **93 goals**.

→ audit: `cd-plan-i1-a-audit.md`.

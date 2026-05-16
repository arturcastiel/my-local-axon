# C3·P4 — Web findings (caching · tokenization · agent context)

> Targeted at C3·P1 findings: tokenizer drift, cache contracts, prompt-cache TTL.

---

## A. CLAUDE PROMPT-CACHE: 5-MINUTE TTL (operationally critical)

### Headline
> "Currently, ephemeral is the only supported cache type, which by default has a 5-minute lifetime. ... If you find that 5 minutes is too short, Anthropic also offers a 1-hour cache duration at additional cost."

> "On March 6, Anthropic silently changed the default prompt cache TTL from 1 hour to 5 minutes. If you're not explicitly setting cache_control, your cache hit rate just dropped to near zero."

### Cost shape
- **Cache writes**: 25% MORE than base input tokens (5-min TTL)
- **Cache reads**: 10% of base input price
- **1-hour TTL** available — costs more on write but pays off if reuse spans >5 min

### Cache stays warm on ACTIVE turns
> "Each cache hit resets the timer. So an active coding session — where you're sending messages every minute or two — keeps the cache warm indefinitely."

### Multi-agent penalty
> "If you're running multi-agent pipelines — the kind where a coordinator sends the same system context to multiple sub-agents — the 5-minute TTL is especially punishing. Agent calls are often spread across minutes or hours, not seconds. The 1-hour TTL was specifically designed for these workloads."

### For AXON
- AXON's **boot chain** (~18,805 tokens) is a perfect cache candidate IF the host harness sets `cache_control` on it.
- For interactive sessions: 5-min TTL is fine (continuous typing).
- For **cycle work** (this project), agent calls space across minutes → 1-hour TTL would be a big win.
- AXON's **multi-agent SPAWN** workflows (e.g. parallel cycle agents) get hit hardest by 5-min default.
- **Action item**: AXON should document the harness contract requirement to set `cache_control` on the boot prefix; for cycle/SPAWN workflows, suggest the 1-hour beta tier.

### Real-world payoff
> "Anthropic prompt caching cut our RCA cost by 90%."

### Cited
- [Prompt caching · Claude API Docs](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)
- [Cache TTL silently regressed · GitHub anthropics/claude-code#46829](https://github.com/anthropics/claude-code/issues/46829)
- [Anthropic Silently Dropped Prompt Cache TTL · DEV](https://dev.to/whoffagents/anthropic-silently-dropped-prompt-cache-ttl-from-1-hour-to-5-minutes-16ao)
- [How Prompt Caching Actually Works in Claude Code](https://www.claudecodecamp.com/p/how-prompt-caching-actually-works-in-claude-code)
- [Claude Prompt Caching in 2026: 5-Minute TTL · DEV](https://dev.to/whoffagents/claude-prompt-caching-in-2026-the-5-minute-ttl-change-thats-costing-you-money-4363)
- [How to Add Prompt Caching · Start Debugging](https://startdebugging.net/2026/04/how-to-add-prompt-caching-to-an-anthropic-sdk-app-and-measure-the-hit-rate/)
- [Anthropic prompt caching cut our RCA cost by 90% · DEV](https://dev.to/stella_lin_82914c71e25769/anthropic-prompt-caching-cut-our-rca-cost-by-90-5gmb)

---

## B. TOKENIZER ACCURACY: tiktoken vs Anthropic

### Critical finding for C3·P1
> "Anthropic models (Claude family) use a tokenizer distinct from tiktoken. Because tiktoken is specifically for OpenAI models, the accuracy rate for Claude token counts is understandably not great."

### Anthropic's stance
> "While some providers ship their own local tokenizer, Anthropic does not. Apart from an old tokenizer for pre-Claude-3 models ... From Claude 3 onwards, Anthropic only supports their Token Count API."

### Approximation if no API call available
> "If you can't call Anthropic's countTokens, you can approximate Claude token counts using OpenAI's tiktoken with the p50k_base encoding, but this is only an estimate."

### Modern fast alternative
> "ai-tokenizer is 5-7× faster than tiktoken ... 98.56% accuracy for Claude Sonnet at ~5k tokens."

### For AXON
- **C3·P1 found 3 tokenizer paths in AXON; one uses cl100k_base (GPT-4)**. This is wrong for Claude (which is the host model declared at boot).
- **Recommendation**: change preferred tokenizer to:
  1. Anthropic Token Count API (if network available + API key)
  2. `ai-tokenizer` library (offline, 98%+ accurate, 5-7× faster)
  3. tiktoken `p50k_base` (last resort, estimate only)
- Update C3·P3 item C3-B2 from "Claude-aware tokenizer" → specifically "ai-tokenizer or Anthropic Token Count API; tiktoken with p50k_base only as fallback".

### Cited
- [Token Counting Explained: tiktoken, Anthropic, Gemini · Propel Code](https://www.propelcode.ai/blog/token-counting-tiktoken-anthropic-gemini-guide-2025)
- [Counting Claude Tokens Without a Tokenizer · GoPenAI](https://blog.gopenai.com/counting-claude-tokens-without-a-tokenizer-e767f2b6e632)
- [ai-tokenizer · GitHub](https://github.com/coder/ai-tokenizer)
- [anthropic-tokenizer-typescript · GitHub](https://github.com/anthropics/anthropic-tokenizer-typescript)
- [Free AI Token Counter · spaceprompts](https://www.spaceprompts.com/ai-tools/tokenizer)
- [Hacker News discussion on Anthropic tokenization](https://news.ycombinator.com/item?id=40710871)

---

## C. CROSS-CUTTING TAKEAWAYS

1. **Cache contract first** — AXON's biggest token win is verifying the host harness flags the boot chain with `cache_control`. Without it, the static-first architecture buys nothing.
2. **5-min vs 1-hour TTL** — for AXON's interactive sessions: default is fine. For multi-agent / cycle / cron flows: explicitly request 1-hour. Need a harness contract field.
3. **Tokenizer must change** — current `cl100k_base` path produces ratios that overstate compression by 5-15% for Claude. Switch to `ai-tokenizer` (offline) or Anthropic Token Count API.
4. **Cache writes cost +25%** — implications for AXON: if a "static" file is edited frequently, cache thrashes. Audit boot-chain edit frequency; KERNEL-SLIM rarely changes (good); MYAXON.md changes per project (potentially bad — keep small).

---

## D. NEW BACKLOG (extends C3·P3)

| ID    | Item                                                                  | Impact | Effort | Score |
|-------|-----------------------------------------------------------------------|--------|--------|-------|
| W3-01 | Document `cache_control` requirement in harness contracts             | 5      | 1      | 5.0   |
| W3-02 | Add `cache-ttl` field to harness contract (`5m` default, `1h` for multi-agent / cron) | 4 | 2 | 2.0 |
| W3-03 | Replace cl100k_base with ai-tokenizer (offline, 98% accurate)         | 4      | 2      | 2.0   |
| W3-04 | Add Anthropic Token Count API as opt-in (when API key + online)        | 3      | 3      | 1.0   |
| W3-05 | Audit MYAXON.md for size; keep small to avoid cache write penalty      | 3      | 1      | 3.0   |
| W3-06 | Measure cache hit rate per session (extend `tools/context.py`)         | 4      | 3      | 1.3   |
| W3-07 | Document static-first prompt rules in DEVELOPER.md                     | 3      | 1      | 3.0   |

---

## E. CRITICAL UNKNOWN

**Does Claude Code actually set `cache_control` on AXON's boot chain?**

This is the single most important question to answer. If yes: AXON gets near-90% input savings on every turn. If no: the entire static-first architecture is wasted.

The Claude Code docs do not surface this clearly in any source above; would need to:
- Inspect Claude Code's prompt assembly (likely via debug mode if available)
- Or measure cache hit rate empirically over a session

→ **For cycle 4**: the synthesis must flag this as the open question that gates the largest single optimization.

---
explains:      adoption playbook for axon-synapse
audience:      tier-A (you, deciding) + tier-E (strategy)
last-checked:  2026-05-17
version:       1
---

# Make AXON Useful for Others — adoption playbook

> An honest, practical plan to grow AXON from "yours" to "useful by
> others." This is harder than the engineering. Read this before
> investing in community work.

## The core challenge

AXON's architecture reflects **your mental model**. Strengths that are
strengths *for you* (highly opinionated workflow vocabulary, rigorous
audit trails, biology-inspired metaphor, hard-rule constraints like
"AXON never builds") are friction points for newcomers who don't share
those priors.

The adoption challenge breaks into four levels:

| Level | Audience | Friction |
|-------|----------|----------|
| L0 | You alone | none (it's yours) |
| L1 | Solo enthusiasts | high glossary load, no peer support |
| L2 | Small teams | shared mental model required + onboarding cost |
| L3 | Open community | governance, contribution path, version stability |
| L4 | Enterprise / hosted | SLA, security, support contract |

This playbook targets **L1 → L3** in the next 12 months. L4 is out of
scope for v1.

## The Three Hard Truths

Before any adoption work, accept these:

### Truth 1 — Tooling adoption is downstream of result.

Nobody adopts a workflow OS because the architecture is elegant. They
adopt it because someone they trust told them "this saved me 4 hours
this week."

**Implication:** the highest-leverage adoption activity is your own
**public dogfooding**. Use AXON on a project that matters to you,
publish the workflow files, show the time saved. Result first; tooling
second.

### Truth 2 — Documentation quality is the price of admission.

Tier-C user docs (Quickstart, How-AXON-Thinks, Authoring-a-Workflow)
must be **better than the average open-source onboarding**. Most OSS
projects ship with terrible docs and survive only because their
maintainers are findable on Discord / Stack Overflow. You don't have
that channel; docs are it.

**Implication:** every Phase-3 PR ships with its user-doc update in the
same PR. Doc rot is a kernel-level failure mode (per docs-plan-v1
maintenance rules).

### Truth 3 — Single-user idioms must be visible as opinions.

Your workflow choices (preserve code-dev verbatim, mandatory shadow,
specific 9-phase PR-review) are *your* answers to recurring problems.
Other users will have different answers.

**Implication:** make every opinion **declared, not assumed**. Domain
manifests, workflow files, neuron contracts are all opt-in. "AXON
defaults to X; here's how to override" beats "AXON does X" everywhere.

## Phased adoption strategy

### Phase A (now → Phase-3 close, ~3 months) — "Dogfood and document"

Goal: prove value to yourself.

**Activities:**

1. **Use AXON daily on 2-3 real projects across ≥ 2 domains.** Code-dev
   + library-dev are shipping; bootstrap study-dev as a third domain in
   Phase 4 only after dogfooding the first two.
2. **Track time-saved metric.** Each workflow run logs duration. Compare
   to baseline (manual or other-tool runs of similar work). Publish
   monthly: *"this month AXON saved X hours by..."*
3. **Polish the four tier-C docs** (Quickstart, How-AXON-Thinks,
   Choosing-a-Domain, Authoring-a-Workflow) until they answer 90% of
   first-week questions a stranger would have.
4. **Build a single end-to-end public demo.** Pick one workflow
   (e.g. `library-dev.canonical` on 10 papers) and screencast / write
   it up. Output = a single thing strangers can react to.

**Acceptance:** you have 3 projects with documented time-savings; the
demo exists; tier-C docs exist; ranker has lived data for ~60+ fires.

### Phase B (Phase-3 close → +6 months) — "Find 5 friends"

Goal: 5 people use AXON for real work.

**Activities:**

1. **Recruit 5 collaborators** through your existing network.
   Don't aim for strangers; aim for friends-with-similar-problems.
   Pick people whose work overlaps your domains.
2. **Pair-onboard each.** First session: walk them through Quickstart
   live. Identify the documentation gaps revealed by their confusion
   (these are the highest-priority doc fixes).
3. **Collect "where did AXON fight me?" feedback.** Add each as a
   finding in your project. Triage: kernel bug, doc gap, opinion
   collision, missing neuron.
4. **Ship the second domain (study-dev) as the first non-author
   collaboration.** A new domain authored *with* a collaborator who
   actually uses it. This is the real test of D-26.
5. **Open public repo** (if not already). Add a `docs/users/` link in
   the README's first paragraph.

**Acceptance:** 5 people have run ≥ 1 workflow end-to-end with no
hand-holding from you; ≥ 1 has authored a new workflow conversationally;
public repo has ≥ 10 stars (vanity but real signal).

### Phase C (+6 months → +12 months) — "Stabilize for strangers"

Goal: someone who's never met you can install and use AXON.

**Activities:**

1. **Version-lock specs.** AXON-GLOSSARY v2 stays stable for ≥ 6 months
   absent critical-flaw discovery. Schema changes go through ADR + RFC
   process (open for community comment).
2. **Build domain registry.** `awesome-axon-domains` repo or
   manifest-registry mechanism. Community domains discoverable.
3. **Ship installation experience.** One command: `pip install axon-os`
   (or `cargo install`, or whatever fits). Bootstraps an empty
   workspace + my-axon scaffold.
4. **Establish a feedback channel.** GitHub Discussions OR Discord OR
   forum — pick one, commit to weekly response cadence.
5. **Write the "AXON vs X" comparison docs.** Honestly compare to:
   - Task runners (Make, Just)
   - Workflow engines (Airflow, Prefect, Dagster)
   - Agent frameworks (LangChain, AutoGPT, CrewAI)
   - Knowledge tools (Obsidian, Roam, Logseq)
   - Project mgmt (Linear, Notion, Jira)

   Where AXON is genuinely better → say so. Where it's worse → say so
   louder. Honesty earns trust.

**Acceptance:** ≥ 50 people have installed and run a workflow; ≥ 3
community-contributed domains exist; specs unchanged for ≥ 3 months.

## What to NOT spend time on

Resist these temptations:

1. **A "first-class" web UI.** AXON is markdown-native and CLI-driven.
   A web UI is a separate product. Don't ship one in the first 12
   months; let the markdown experience mature.
2. **Translations / i18n.** English-only for v1. Translation is signal
   of adoption; chase it after L3, not during L1.
3. **Hosted version.** Don't run a SaaS until ≥ 50 stable users. Hosting
   accelerates support cost dramatically.
4. **Plugin ecosystem.** Synapses + workflows ARE the plugin ecosystem.
   No separate plugin format; no marketplace.
5. **Marketing / branding.** A clean README + working demo + honest
   comparison docs outperform any marketing for tools in this niche.

## Metrics to track

| Metric | Phase A | Phase B | Phase C |
|--------|---------|---------|---------|
| Active workflows | 3 (you) | 10 (5 friends) | 50+ |
| Domains in use | 2 | 3 | 5+ |
| Doc completeness | tier-A done | tier-C done | tier-D + tier-E done |
| Ranker top-1 hit rate | 70 % bar | ≥ 80 % | ≥ 90 % (D-21 target) |
| Time-saved per workflow run | — | tracked | published |
| Community domains | 0 | 0 | ≥ 3 |
| GitHub stars (vanity) | — | 10+ | 100+ |

## Risks to adoption

| Risk | Mitigation |
|------|-----------|
| Vocabulary load too high | Reduce glossary to 12 core terms in user docs; full glossary is spec-only |
| Conversational author hallucinations | Cold-start dialog (D-030); turn cap; explicit confirm at each step |
| Domain manifest authoring intimidating | Ship code-dev + library-dev as templates; conversational author handles 80 % of cases |
| Kernel changes break user workflows | Schema versioning (per `_versions.md`); migration tools mandatory |
| LLM cost compounds | Workflow compilation cache (Phase-4 PR-153); local-model harnesses |
| One-off vs ongoing use mismatch | Be explicit in marketing: "AXON is for processes you repeat, not one-shots" |

## Concrete first 90 days (post Phase-3 close)

Week 1-2: **dogfood on 3 projects**, log time-savings.
Week 3-4: **polish tier-C docs** based on your own re-reading.
Week 5-6: **record a 15-min screencast demo** of library-dev workflow.
Week 7-8: **identify 5 candidate collaborators**; reach out.
Week 9-10: **pair-onboard the first** collaborator; collect doc gaps.
Week 11-12: **ship study-dev domain** with one of those collaborators.

After 90 days, reassess: do you have signal that the system saves time
for someone other than you? If yes, push into Phase B. If no, retreat
to Phase A and figure out why.

## Honest closing

Most personal tools never reach L1. AXON has a better-than-average shot
because:

- The vision is internally coherent (not a kitchen sink).
- The architecture is **declarative + auditable** — a strength for
  trust-building.
- AI-first design is increasingly demanded.
- Workflow OS is a sparsely occupied niche.

But adoption is not the architecture's problem; it's **time, discipline,
and patient documentation**. If you do nothing here other than dogfood
+ keep tier-C docs current, AXON will land L1 within 6 months. Anything
beyond L1 requires the deliberate work above.

## What this doc isn't

This isn't a marketing plan. It's a survival plan for the design's
long-term usefulness. Marketing can come after L2 — if it ever does.

Result first; tooling second. Always.

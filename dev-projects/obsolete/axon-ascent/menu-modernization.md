# Menu Modernization — design (deep-think, from a survey of 40 dev-projects)

## Philosophy (the blurb the menu should open with)
> **AXON is an OS for AI agents** — every capability is a program, every program
> a typed neuron in a self-checking graph. You state intent in plain language;
> AXON routes, runs, remembers, and improves itself — in any domain, on any harness.

## The problem
The menu groups by a single flat `area` field, computed by prefix-matching in
`tools/programs_registry.py::_classify_area`. Result: **114 of 184 programs land
in "code-dev"** and ~12 in "other" — the menu is one long, undifferentiated
scroll. No submenus, no explanations, no philosophy, noise (STUB/DOC/DEPRECATED)
shown inline.

## The taxonomy (2-level — replaces flat area)
| Category | Submenus | Holds |
|---|---|---|
| **BUILD SOFTWARE** | code-dev · library-dev · workflows | code-dev-* (study→plan→pr→log→audit), library-dev-*, workflow new/run/simulate |
| **DOMAINS** | reservoir-eng · domain-new · (future) | domain-specific packs (proves the domain-agnostic thesis) |
| **RUN & ORCHESTRATE** | run · orchestrator · suggestions · cron/queue | run, orchestrator, synapse-suggest, cron, queue |
| **MEMORY & STATE** | recall/remember · session · reminders | show-memory, recall, handoff, resume, memory-compact, reminders |
| **DISCOVER & LEARN** | find · explain · simulate · tutorial · glossary/faq | find-program, explain, simulate, quickstart, authoring-guide, onboarding |
| **SELF-IMPROVE & OBSERVE** | metrics · drift · auto-improve · igap · ranker | dispatch-stats, gain, drift, auto-improve, auto-actions, igap, board |
| **INTEGRITY & QUALITY** | audit · lint/coherence · artifact-guard · tests | axon-audit, synapse-validate, coherence lints, lint-paths, artifact-guard |
| **SYSTEM & CONFIG** | output-mode · prefs/health · tools · workspace | mode-*, prefs-doctor, health-check, list-tools, workspace-backup, my-axon-init |
| **DEV / KERNEL** *(dev-mode only)* | author · kernel · meta-tools | axon-docs-gen, compile-optimizer, kernel editing — gated by L:dev-mode |

Classify from the richest available signal: program `area` + name patterns +
`status` (hide STUB/DOC/DEPRECATED by default); upgrade to synapse `family`/`role`
once the registry captures them.

## Explanation strategy
- Philosophy blurb at the menu top (above).
- A one-line purpose per category (e.g. BUILD SOFTWARE = "author, plan, ship code & libraries via tracked PR workflows").
- Per-program one-liners already exist (`# desc:` → registry `description`).
- `explain <program>` exists; add a parallel `explain <category>`.

## Interface modernization (prioritized)
1. **2-level taxonomy renderer** — replace the flat area with category → submenu (the single highest-leverage fix). *(Stage 1)*
2. **Progressive disclosure** — top menu = ~8 categories + counts + one-liners; drill into a category for its programs. *(Stage 1)*
3. **Hide noise by default** — filter STUB/DOC/DEPRECATED + DEV/KERNEL unless dev-mode/`--all`. *(Stage 1)*
4. **Philosophy + category explanations** inline. *(Stage 1)*
5. **Intent entry point** — "what do you want to do?" → route free text via the orchestrator/find-program. *(Stage 2)*
6. **"Explain this" everywhere** — `explain <program>`/`explain <category>` next to entries; pair mutators with `simulate`. *(Stage 2)*
7. **Onboarding / Day-1 path** + a generated browsable INDEX; `find-program` searches descriptions. *(Stage 2)*

## Rollout
- **Stage 1 (now, autonomous):** a `menu` renderer in programs_registry with the 2-level taxonomy + philosophy + category one-liners + hide-noise. Registry-sourced (auto-updates via the drift gate).
- **Stage 2:** intent entry, explain-category, onboarding, INDEX.
- Kernel-facing wording (the menu *program* `menu.md`) = human-merge; the *tool* renderer is autonomous.

Evidence: axon-synapse/_goal.md (domain-agnostic OS), axon-memory, axon-ascent, axon-coherence-v2, lab2-06/13/14/15 (discovery is a known gap), reservoir-eng + cpg-to-unstructure (domain proof).

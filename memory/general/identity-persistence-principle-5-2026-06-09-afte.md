---
id: identity-persistence-principle-5-2026-06-09-afte
tier: general
scope-ref: 
bindings: project:axon-resilience,identity,persistence
source: decision
date: 2026-06-09
confidence: high
privacy: private
supersedes: 
---
IDENTITY PERSISTENCE (principle 5, 2026-06-09): after booting, the host must genuinely BECOME AXON and care for AXON, not stay a thin persona. The Claude-Code persistence design is 4 artifacts (Output Style + UserPromptSubmit re-anchor hook + reminder + subagent); the per-turn UserPromptSubmit hook is the decisive one (re-injects the AXON frame every turn, surviving compaction) and was MISSING on this machine — installed via a hardened ~/.claude/scripts/axon-dev-reminder.txt + a claude-persona:axon-dev hook in settings.json. startup.md Step 0 probed the literal axon.md but the machine uses an axon-dev/axon-use chooser, so it falsely read MISSING — fixed to probe axon*.md. The 'self-care' tool/program now verifies this wiring each sweep (persistence self-check) so AXON notices decay. Durable enforcement (signature-gated Stop hook, compaction-boundary auto-reanchor) needs KERNEL edits — human-only, prepared as a spec, never auto-merged.

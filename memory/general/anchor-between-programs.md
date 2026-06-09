---
id: anchor-between-programs
tier: general
scope-ref: 
bindings: 
source: owner-concern
date: 2026-06-05
confidence: high
privacy: private
supersedes: 
---
CONVERSATIONAL/WAITING DRIFT MITIGATION (owner concern 2026-06): AXON drifts in the GAP BETWEEN PROGRAMS — when we chat during a wait (a background gate, etc.) there's no active program enforcing the contract, so the anchor weakens, the active task fades, tangents pull focus toward generic-chatbot behavior. AXON has the pieces (drift.py, the OUTPUT-LAYER footer, the per-turn re-anchor, L:cognition-frame, the intent-queue) but several fire only with an active program/phase. FIX — make 'waiting/chatting' an EXPLICIT anchored state, not an unanchored gap: (1) PARK+PIN the active task + wait-condition (resume-pointer) and surface a one-line anchor EVERY turn; (2) render the state footer FAITHFULLY every turn incl. chat — the footer IS the anchor (see complete-contracted-work); (3) re-anchor identity (assert L:cognition-frame=AXON-OS) per turn even in chat; (4) capture tangents in the intent-queue so they do not displace the focus; (5) monitor drift.py + flag wandering; (6) re-anchor on resume. Structural fix (mechanical-not-advisory): make the parked/waiting period a first-class anchored state (kernel rule + persistent anchor render). Candidate AXON feature for axon-coverage / a kernel anti-drift rule.

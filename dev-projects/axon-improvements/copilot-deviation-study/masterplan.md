# Masterplan — Copilot Deviation Study

## Phase graph (directed)

- **1-design** → 2-prototype (proposed) → (validation phase TBD)

Phases are added by: code-dev phase new

## Project arc

1. **1-design** — Read the forensic dump in `/mnt/c/projects/harness/`. Map every drift to a concrete missed guard. Draft 4–6 mechanical countermeasures (programs / tools / rule additions). Output: PR list ready to scaffold.
2. **2-prototype** (proposed) — Implement the highest-ROI countermeasures as workspace/ programs and tools (no axon/ changes). Each PR adds a guard + a test that simulates the failure mode and verifies it triggers.
3. **3-validation** (proposed) — Replay the incident under the new guards. Confirm mechanical detection. Update kernel rules with `L:dev-mode = true` (owner action).

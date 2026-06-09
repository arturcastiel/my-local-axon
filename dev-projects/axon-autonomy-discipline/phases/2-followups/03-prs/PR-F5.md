# PR-F5 — Contract: preserve `_policy.md`, make the budget honest

- **Status:** spec
- **Phase:** 2-followups
- **Complexity:** S
- **Depends on:** none
- **Why:** Two contract findings:
  - **F8:** `autonomy_contract.write()` does `open(policy_path, "w")` + `_render_policy` — a wholesale
    overwrite with no backup/merge. The live `_policy.md` is hand-tuned (an owner-directive provenance line
    + a `## Notes` block explaining the gating semantics); a re-write silently drops them.
  - **F9:** `budget` is interviewed ("max PRs to land before re-confirming?") and threaded into the grant
    note + ledger string, but NOTHING ever reads it back to count PRs / re-confirm — a write-and-ignore
    that PROMISES enforcement it doesn't deliver.

## Mechanism
- **F8 — preserve + back up:** before overwriting, copy `_policy.md` → `_policy.md.bak`. Carry the
  operator's content across the re-write: any `# Owner directive …` provenance comment lines + a trailing
  `## Notes` section are extracted from the old file and appended after the rendered managed block. Detect
  whether the prior capabilities differ from the chosen level's and return that in the result
  (`policy_caps_changed`, `policy_backed_up`) so the operator is informed rather than silently overridden.
- **F9 — make it honest (mark advisory + structure it):** store `budget` as a STRUCTURED grant field
  (`grant["budget"]`), not just buried in the note string, so it is at least machine-readable/surfaced.
  Re-word the program interview + output to call it an ADVISORY reminder (a check-in cadence the operator
  keeps), NOT an enforced gate — removing the false "re-confirm" promise. (Full enforcement — a PR counter
  in the merge path that halts at zero — is out of scope: merges here are manual `glab`, there is no
  in-tool merge hook to decrement against; honesty now beats a half-built counter.)

## Changes Required
### tools/autonomy_contract.py
- `import shutil`. New `_preserve_and_backup(policy_path) -> (preserved_text, prior_caps|None)`: back up to
  `.bak`, extract owner-directive lines + the `## Notes` section, scan prior `## capabilities`.
- `write()`: render managed policy, append preserved content, write; set `policy_backed_up` +
  `policy_caps_changed` in the result. Pass `budget` to `grant_on`.
### tools/autonomous_mode.py
- `grant_on(..., budget=None)` → `grant["budget"] = budget` (structured; advisory).
### workspace/programs/autonomy-contract.md
- Re-word the budget QUERY + the output line: advisory check-in reminder, not an enforced "re-confirm".

## Acceptance criteria
1. An existing `_policy.md` with a `## Notes` block + an `# Owner directive` line → after `write()`, the new
   file STILL contains both, and `_policy.md.bak` holds the prior file (F8).
2. `write()` returns `policy_backed_up: True` when a prior file existed, and `policy_caps_changed` reflecting
   whether the level's caps differ from the prior file's.
3. The grant carries a structured `budget` field (F9).
4. The program no longer promises enforced "re-confirm" (assert the advisory wording statically).
5. The three original effects still hold (policy written, grant active, ledger opened). `crucible gate`
   passed:true on this on-workflow changeset.

## Test plan
`test_autonomy_contract.py`: a pre-existing `_policy.md` with notes+directive is preserved + `.bak` created;
`policy_caps_changed` set on a level change; the grant carries `budget`; the program's budget wording is
advisory. `test_autonomous_mode.py`: `grant_on(budget=…)` stores it. Full suite + gate. No dev-mode
(the program edit is workspace/, not axon/).

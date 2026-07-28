# Sweep D — FINAL re-verified return (supersedes sweep-D-never-audited.md where they differ)
date: 2026-07-13 · the sweep agent ran a second source-re-verification pass over its own delegated claims.
DELTAS vs first pass (authoritative):
- RETRACTED: "re-round is a no-op (rounds←1 → empty range)" — re-verification found the re-round wiring
  landed; only the `W:hr-team-reround-done` never-cleared session lockout survives (below-cap).
- RETRACTED: "empty-task capture to W:hr-team-task with zero readers" — did not survive re-verification
  ("residuals found are D-2/D-9 and the reround-done line").
- RE-GRADED + mechanism corrected: hr-team refusal bypass = HIGH (was CRITICAL). Refusals exit DONE
  WITHOUT writing W:hr-team-selector-result: first-run refusal → convener FAILs on the missing key with a
  misleading "Run: hr-team-selector first" fix; refusal AFTER a successful council in-session → the STALE
  selector-result (previous seats/protocol/tier) drives a full sealed council on the NEW task — safety
  refusals bypassed. (hr-team.md:112-114 unconditional chain; selector.md:63,70,77,105,125 refusal exits;
  zero CLEARs repo-wide.)
- UPGRADED: D-1 workflow name-resolution → CONFIRMED; added: parent advance guard raises
  SubWorkflowNotCompletedError after the child dies, so multiple-code-dev can never pass s2; only one
  (manual demo) trajectory ever recorded.
- SHARPENED: selector `--protocol` override (selector.md:205-211): QUERY(user) fallbacks embedded INSIDE
  IF conditions, evaluated up to 3× — unset case prompts mid-gate and a non-"weighted-vote" answer silently
  becomes the protocol; explicit `--protocol weighted-vote` routes to the ELSE (tier default) — broken in
  both directions. (Mechanical-rewrite artifact.)
- PROMOTED to MEDIUM: workflow-simulate reads `W:_workflow-sim-*` while the family convention +
  workflow-run's --dry alias bind `W:_workflow-simulate-*` (zero writers of _workflow-sim-*) → params never
  arrive → FAIL "Workflow not found: ∅"; --dry alias inherits the break.
- PROMOTED to MEDIUM: handoff.md:38-39 reads nonexistent `W:checkpoint-result.snapshot`
  (checkpoint save emits {saved,label,keys,count,file,timestamp}) → W:handoff-state dead store; brief's
  "Full state: workspace/working/{label}.json" wrong on two segments (real:
  workspace/memory/working/.snapshots/{label}.json, checkpoint.py:146). Legacy --label invocation itself fine.
- NEW below-cap: workflow-validate.md:92,99 wraps check-stale/check-templating in `| ∅` while the tool
  exits 1 exactly when findings exist (workflow_run.py:1117,1127) — if the TOOL envelope treats nonzero exit
  as failure, the wired lints silently vanish precisely when they matter (LANG-underspecified).
- NEW below-cap: orchestrator.md:96-97 zero-candidate fallback unreachable (187-entry corpus always yields
  ≥1 candidate) — the dispatch top_matches path is dead code.
- CLEAN-LIST refinements: registry subcommand drift sampled across ~16 live-exercised tools — only pattern
  failed; "3 worst unregistered tools" set is EMPTY (187/187 scripts exist, 0 unregistered, 0 dupes, status
  vocab ACTIVE/OPTIONAL only). anticipate contract + orchestrator c.reason read + menu c.why read all valid
  for their respective writers. Kernel boot general-memory flow matches tool. Node-order vocab consistent.
- FIRST-PASS-ONLY items NOT re-verified (treat as unverified leads, not findings): hr_team.py cwd-relative
  defaults; hr-team persistence tier always "full-audit"/empty events.jsonl; agent_memory capture-tier
  mislabel + false-orphan liveness + ninth divergent L: parser at _read_gate; REGISTRY descriptive drift
  (quality-loop ramp omission etc.). The final report lists agent_memory capture/gc internals + systematic
  registry argparse diffing under "Not covered".
Findings CARRIED UNCHANGED from first pass (re-confirmed in final): workflow-validate caller guards
(v.errors list) · orchestrator thresholds never recalibrated (probe 0.1176 / anticipate 0.034 silent) ·
pattern.py crash on shipped prefs · memory-compact/show-memory wrong episodic store (807-line real log;
split-brain inside one output) · chat-index split-brain (+ index.py append --type plan false success) ·
agent-memory tier:"all" mislabel (project/program silently skipped; output stamps tier at :561) ·
footer self-suggest + zero-score stub padding · situate {turn} unbound + recent-tools never written ·
ranker state shapes (usage/pattern/context-pressure structurally zero) · BOOT.md:196 anticipate inputs
unwritten · plan-new.md goal rendered after CLEAR.

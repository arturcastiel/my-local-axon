# PR-1 — `R_NO_BRAND_IN_ARTIFACTS`: brand-self-reference guard for artifacts

> Phase 1-guard · Theme: identity enforcement floor
> Branch: `artifact-brand-guard`
> Status: draft (not yet implemented)
> Dependencies: none (sibling of `R_MEMORY_RESPECTED`, already on main)
> Requires: `L:dev-mode ≡ true` (touches `axon/`)

## One-liner
Add a STATIC lint rule + an installable git hook that detect **host-model
brand self-references** (`Claude`, `Anthropic`, `GPT`, `Copilot`, `Gemini`)
and **co-author / "generated with" trailers** in *artifacts* — git commit
messages, PR bodies, and files staged for commit — and BLOCK them before
they are written. Closes the surface AXON's per-turn coherence guardian
cannot see.

## Why this PR
On 2026-05-24 a Claude Code harness default stamped
`Co-Authored-By: Claude Opus 4.7` into 17 commits and
`🤖 Generated with Claude Code` into 13 PR bodies on a repo about to be made
public. Every identity protection missed it: the coherence guardian, the
identity gate, and the response gate all scan **rendered output prose**,
while the brand strings lived in **Bash/`gh` tool-call payloads**. Artifacts
are an unguarded surface.

This rule is the enforcement floor for that surface — the artifact analogue
of `R_MEMORY_RESPECTED` (which guards memory writes). It must run where the
artifact is actually created (git commit/push), so a model that "forgets" —
or a non-Claude harness with no per-turn gate at all — still cannot leak.

## Decisions baked in
- **Host-brand only, never third-party credit.** The rule targets the
  *execution layer's* identity (`Claude`/`Anthropic`/`GPT`/`Copilot`/
  `Gemini`) used as authorship/attribution. Upstream CREDITS — MRST,
  SINTEF, etc. — are legitimate and MUST NOT be flagged. Match co-author
  trailers and "generated with <vendor>" patterns specifically, not bare
  vendor substrings in prose.
- **Allowlist scopes.** Mirror the coherence guardian's exceptions: do not
  flag matches inside `axon/programs/identity.md` or under
  `workspace/harness/` (where naming the host is sanctioned).
- **Advisory→blocking knob.** WARN by default; BLOCK when
  `L:brand-lint-required ≡ true` (default true for git-hook invocation).
  Same dial as `R_MEMORY_RESPECTED`'s `L:memory-respected-required`.
- **Two enforcement points.** (a) lint-pack rule (static, harness-agnostic,
  runs in CI / `verify`); (b) a git `pre-commit` + `pre-push` hook that
  scans the commit message and staged diff — the real artifact-creation
  moment. The hook is opt-in via an installer so it never surprises a clone.

## Files

### Created
- `tools/rules/r_no_brand_in_artifacts.py` — the rule. Exposes the standard
  rule interface (`rule_id`, `phase = "STATIC"`, `severity`, a `check`
  yielding `Violation`s). Scan inputs: the current commit message
  (`COMMIT_EDITMSG` / arg), staged file blobs (`git diff --cached`), and —
  when given a `--pr-body` — PR text. Regexes:
  - `(?im)^\s*Co-Authored-By:\s*(claude|anthropic|gpt|copilot|gemini)`
  - `(?i)generated with .{0,20}(claude|copilot|chatgpt|gemini|anthropic)`
  - `(?i)🤖\s*generated with`
- `tools/hooks/install-brand-guard.sh` — installs `pre-commit` + `pre-push`
  hooks into a target repo's `.git/hooks/` that call the rule on the commit
  message + staged diff and exit non-zero on a BLOCK.
- `tests/test_rules/test_r_no_brand_in_artifacts.py` — see acceptance.

### Modified
- `tools/rules/registry.py` (or the lint-pack registry) — register the new
  rule so `verify` / the lint pack pick it up automatically.
- `tools/REGISTRY.json` — register any new tool entry if the hook installer
  is surfaced as a tool.

## Acceptance criteria
1. Flags `Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>` and
   `🤖 Generated with Claude Code` in a commit message → BLOCK.
2. Flags the same patterns in a staged file blob and in a `--pr-body`.
3. Does **NOT** flag third-party credit: a `NOTICE` / README crediting
   "MRST … © SINTEF" passes clean.
4. Does **NOT** flag matches inside `axon/programs/identity.md` or
   `workspace/harness/*`.
5. WARN when `L:brand-lint-required` is false; BLOCK when true; the git hook
   invokes in BLOCK mode and exits non-zero, aborting the commit/push.
6. Rule appears in the lint pack / `verify` output and in `tools/REGISTRY.json`.

## Test plan
`tests/test_rules/test_r_no_brand_in_artifacts.py` (mirrors
`tests/test_rules/test_r_memory_respected.py`): positive cases (commit msg,
staged blob, PR body), negative cases (MRST credit, identity.md, harness/),
and the WARN/BLOCK knob. Building/running tests is a human step.

## Out of scope
- Rewriting existing history (handled separately by the publish scrub).
- A kernel-text amendment to the coherence guardian — this rule is the
  mechanical floor; a kernel cross-reference to it can be a follow-up PR
  under `L:dev-mode`.
- Non-git artifacts beyond files/commits/PRs (e.g. issue comments).

# PR-2.1 — tools/fail_render.py: standardized FAIL block renderer

## 1. Why
F-D2-001, F-D2-007 (both MAJOR): kernel spec at `KERNEL-SLIM.md:411-426` mandates every FAIL render a block with **Problem / Cause / Fix / Suggested next**. Direct verification: 94 programs use `FAIL(...)`; **0 programs** render the kernel-format block. 100% non-compliance.

Compounded by F-D2-016 (worst-error pattern: 7 programs say `"unknown subcommand: {sub}"` with no hint) and F-D6-013 (81 programs use identical "Identity lost — run: boot axon" HALT message with no per-program context).

Per ADR-002 (accepted): ship a `tools/fail_render.py` renderer + AXON-LANG shorthand; programs adopt incrementally as touched. This PR is the first of the C-02 cluster.

## 2. Evidence
- `KERNEL-SLIM.md:411-426` — the mandated FAIL block format
- Direct count 2026-05-22: `grep -l "FAIL(" workspace/programs/*.md | wc -l` = 94
- Direct count 2026-05-22: `grep -l "Problem\s*:" workspace/programs/*.md | wc -l` = 0
- Cleanup project's `scripts/autopatch_programs.py` 6-canonical-pieces explicitly omits FAIL block — codifies the violation (active conflict surfaced in `_prior-work-crossref.md`)

## 3. Design notes
Single-tool, single-shorthand approach:

**Tool**: `tools/fail_render.py`
- Signature: `fail_render(program, problem, cause=None, fix=None, suggested_next=None) → str`
- Output: the standard ━━━ block as text, with the 5 fields rendered exactly to spec.
- CLI: `python3 tools/fail_render.py --program X --problem "..." [--cause "..."] [--fix "..."] [--suggested-next "cmd1,cmd2"]`
- Returns: rendered string on stdout; `--json` flag emits structured object too.

**AXON-LANG shorthand** (added to LANG): `FAIL(prog, problem, cause?, fix?, suggested_next?)`
- Translates to: `TOOL(fail-render, render, --program prog --problem problem [--cause cause] [--fix fix])` then renders to output.

**Migration pattern** (for future PRs and incremental adoption):
- Old: `FAIL(code-dev-plan, "No plan file at expected path")`
- New: `FAIL(code-dev-plan, "No plan file at expected path", cause="02-plan.md missing in phase dir", fix="run: code-dev plan", suggested_next="code-dev plan, code-dev study")`

## 4. Pitfalls
- Class-A (production-path): existing FAIL shorthand expansion in compiler must handle both forms (legacy single-string and new 5-arg). Default `cause=None`, `fix=None`, `suggested_next=None` so legacy callers still work.
- Class-C (data correctness): `suggested_next` is comma-separated string parsed into a list. Whitespace handling.
- Class-D (kernel edit): adding the shorthand to `axon/core/LANG.md` requires `L:dev-mode = true`. Compiler grammar change at `axon/compiler/GRAMMAR.md` likewise.
- Class-E (rule violation): the existing R7 (no symbolic output) is WARN-only; this PR's renderer keeps the ━━━ block as plain text, no risk of triggering it.

## 5. Interface sketch
```bash
# CLI form:
python3 tools/fail_render.py \
  --program code-dev-plan \
  --problem "Plan file not found" \
  --cause "phases/<current>/02-plan.md is absent" \
  --fix "Run: code-dev plan" \
  --suggested-next "code-dev plan,code-dev study"

# Output:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   ✗  AXON FAIL  ·  code-dev-plan
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   Problem  :  Plan file not found
#   Cause    :  phases/<current>/02-plan.md is absent
#   Fix      :  Run: code-dev plan
#
#   Suggested next:
#     → code-dev plan
#     → code-dev study
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# AXON-LANG form (in a program):
FAIL(code-dev-plan, "Plan file not found",
     cause="phases/<current>/02-plan.md is absent",
     fix="Run: code-dev plan",
     suggested_next="code-dev plan, code-dev study")
```

## 6. Spec

### Files-changed
| File | Change |
|---|---|
| `tools/fail_render.py` | New file (~120 LOC). CLI + library function. |
| `tools/REGISTRY.json` | Add `fail-render` as ACTIVE/category=axon-os tool. |
| `tests/test_fail_render.py` | New file. ~10 tests covering: minimal (problem only), full (all 5 fields), suggested_next list parsing, JSON output, kernel-format conformance. |
| `axon/core/LANG.md` | Add FAIL shorthand grammar. dev-mode required. |
| `axon/compiler/GRAMMAR.md` | Add FAIL expansion rule. dev-mode required. |
| `workspace/AXON-DOCS-COMPLIANCE.md` | Add "Guarded by" row referencing test_fail_render.py. |

### Acceptance
- `pytest tests/test_fail_render.py` green.
- Manual: invoke CLI with full arg set; output matches kernel template byte-for-byte (except dynamic content).
- The kernel template (KERNEL-SLIM:411-426) is included verbatim in the test fixture; a kernel edit that changes the template would fail the conformance test (intentional canary).
- F-D2-001 + F-D2-007 NOT YET resolved (need migration PRs). But the renderer is now available — they become unblocked.

### Rollback
- `git revert <commit>`. No data migration; no programs depend on the tool yet.

### Owner
- AGENT: writes PR.
- HUMAN: runs pytest, reviews diff, lands commit. Kernel edits in axon/ need `L:dev-mode = true` first.

### Parallelism
- Independent of all other Tier-1 PRs. Can ship first or last.

## 7. Codebase grounding
- F-D2-001, F-D2-007, F-D2-016, F-D6-013, F-D6-015: `_flaws.md`
- D-D2-018, D-D2-019: `_demands.md`
- ADR-002: `_adrs.md` (accepted)
- Active conflict resolution: cleanup PR-120's 6-canonical-pieces omits FAIL; this PR provides the missing piece (and a follow-up PR-2.4 should extend cleanup's autopatch to include it).
- Reference: `axon-reference/compliance/01-compliance-and-gates.md` § FAIL block standard.

## 8. Cross-refs
- Sibling PRs (later in C-02 cluster): PR-2.2 (lang shorthand), PR-2.3 (migrate 5 highest-usage programs), PR-2.4 (advisory lint rule + extend cleanup autopatch).
- Closes (incrementally): F-D2-001/007 (via downstream PRs), F-D2-016 (via migration of 7 sub-dispatchers), F-D6-013 (via migration of 81 G-02 HALT sites).
- Does NOT close: 94 individual program migrations — those land in PR-2.3 and beyond, OR opportunistically as programs are touched.

## 9. Audit trail
- ADR-002 ACCEPTED 2026-05-21
- Severity: MAJOR → resolved as migration completes (this PR is the foundation)
- Effort: S (~half-day for tool + tests; kernel edits same session if dev-mode is on)
- Risk: low (additive; legacy callers preserved by optional kwargs)

# PR-0d — KERNEL PATCH (human-apply only)

Status: applied (owner-executed script, 2026-06-10) · merged in MR !162
Target: `axon/programs/interactive.md` (kernel — inviolable floor, no grant covers it)
Why: the compiled-mirror kill removed `tools/compile.py`; this kernel program still
advertises + calls it. `axon-audit 1a` now WARNs `Unknown TOOL('compile')`, which reds
`tests/test_integration.py::TestAxonAudit::test_section_1a_healthy` → the PR-0d gate
cannot go green until this lands. Apply with dev-mode ON, by hand.
Note: this patch clears ALL THREE red tests — test_section_1a_healthy,
test_program_kernel_rules[os::interactive], AND test_program_tool_refs[os::interactive]
(one root: the TOOL(compile) ref at interactive.md:155 / R_TOOL_EXISTS BLOCK).

## Exact edits (6 lines)

1. **Line 79–80** — delete both command rows:
```
| `compile [file]` | EXEC(compiler, {source: [file]}) — compile to programs/compiled/ |
| `compile [file] from [template]` | EXEC(compiler, {template: [file], params: prompted}) |
```

2. **Line 92** — replace:
```
| `programs` | List all files in programs/ (source and compiled) |
```
with:
```
| `programs` | List all files in programs/ |
```

3. **Line 107** — replace:
```
1. Identify the intent: compile / run / create / query / configure / explain
```
with:
```
1. Identify the intent: run / create / query / configure / explain
```

4. **Line 150** — replace:
```
After collecting: write `programs/[name].md` using the program format. Offer to compile immediately.
```
with:
```
After collecting: write `programs/[name].md` using the program format.
```

5. **Lines 152–155** — delete the whole `### Compiling with a template` block
   (it ends with `TOOL(compile, format, --name {output}, --source {template}).`).

6. Line 93 (`templates` row) may stay — `compiler/templates/` still exists in the kernel.

## After applying
```
git checkout general-bugfix/pr-0d-mirror-kill
# apply the edits above to axon/programs/interactive.md
python3 axon.py crucible gate          # expect green
git add axon/programs/interactive.md && git commit  # trailer: Co-authored-by: AXON <axon@arturcastiel.github.io>
git push origin general-bugfix/pr-0d-mirror-kill
glab mr merge <iid> --squash --remove-source-branch --yes
```

## Optional kernel doc residue (not gate-blocking, same dev-mode session)
- `axon/KERNEL-SLIM.md` LOAD-ON-DEMAND table still lists `compiler/COMPILER.md` +
  "compiler/GRAMMAR.md (During compilation Phase 2 only)" and the TOOLS section
  mentions usage.py "suggest surfaces compile candidates" — the kernel compiler SPEC
  was retained intentionally; reword only if you want the kill reflected in the kernel.

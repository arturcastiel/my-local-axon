---
tags: [code, file]
path: axon/programs/PROGRAM-TEMPLATE.md
---

# axon/programs/PROGRAM-TEMPLATE.md

> 82 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `"'{W:input}' is not valid. Expected: X · Y · Z`
- `"[Plain English: what went wrong and how to fix it.`
- `- [FILL: optional tip 1]`
- `- [FILL: optional tip 2]`
- `APPEND(E:[log-name], {event: "[name]", detail: [value], time: TOOL(clock).iso})`
- `ASSERT([condition]) | FAIL([program-name],`
- `ASSERT(cond) | FAIL(...)`
- `BANNER — always first, gives user context on what just ran [KEEP]`
- `CHECKLIST — before adding your program to the workspace`
- `CHECKPOINT  ← use before any irreversible action`
- `CONTENT — the actual output`
- `CONTEXTUAL NEXT — always last, tells user what to do [KEEP]`
- `Copy this file to workspace/programs/[name].md when creating a new program.`
- `Example: my-program X`
- `FAIL(my-program,`
- `Fill every section marked with [FILL]. Remove sections marked [OPTIONAL] if unused.`
- `For programs with multiple outcomes:`
- `GUARD`
- `Guards & Errors`
- `HELP`
- `IF cond → ...  for conditional output lines`
- `IF cond → a | b`
- `IF result ≡ X → → "Next: ..."`
- `IF result ≡ Y → → "Next: ..."`
- `INPUT`
- `Include what command to run next.]")`
- `Memory`
- `Menu integration`
- `Mode:     SPAWNED → RUNNING  (for stateful programs)`
- `OUTPUT → PYTHON_FAST · [prose | list | doc]`
- `PERSIST`
- `PROGRAM-TEMPLATE`
- `Pattern for good FAIL messages:`
- `Priority: !NORM | !HIGH | !LOW | !BG`
- `RETRIEVE · STORE · APPEND · LOAD · SCAN`
- `RETRIEVE(W:[input-var]) → IF ∅ → QUERY(user): "[plain English question]"`
- `Run menu to see all available options.")`
- `STORE(L:[key], [value])`
- `Sections marked [KEEP] are required — do not remove them.`
- `Structure`
- `TOOL(clock) · TOOL(calculator, "expr", {vars})`
- `Use:`
- `Write logic using AXON ops:`
- `[ ] "Next:" line present at end of OUTPUT`
- `[ ] Any permanent save uses STORE(L:) + APPEND(E:)`
- `[ ] CHECKPOINT added before any irreversible side-effect`
- `[ ] DONE([name]) matches filename`
- `[ ] Every ASSERT has a FAIL with plain-English message`
- `[ ] FAIL messages include: what went wrong · how to fix it · example command`
- `[ ] File added to workspace/programs/ (or sub-folder)`
- `[ ] HELP block filled (desc, usage, inputs, example, outputs, next, tips)`
- `[ ] No FAIL message exposes raw symbolic ops to the user`
- `[ ] Program appears automatically in menu (menu.md scans dynamically)`
- `[ ] Working keys (W:) are CLEARed when no longer needed`
- `[ ] desc: in HELP block is a single clear sentence`
- `[ ] help [name] returns useful output (test it)`
- `[ ] ▶ banner line present in OUTPUT section`
- `[STEP NAME]`
- `desc:    [FILL: one sentence — what this program does for the user]`
- `example: [FILL: concrete example the user can copy-paste]`
- `inputs:  [FILL: W:var-name — what it is · or "None required"]`
- `next:    [FILL: 1–3 suggested follow-up commands]`
- `outputs: [FILL: what the user will see]`
- `read-only          (for display-only programs)`
- `tips:`
- `usage:   [FILL: exact command, e.g. "run my-program [arg]"]`
- `{L:var}        to interpolate longterm values`
- `{W:var}        to interpolate session values`
- `→ "[line 1]"`
- `→ "[line 2]"`
- `∀ item in list → ...`
- `∀ x in list → "  {x.field}"  for lists`
- `── DONE [KEEP] ───────────────────────────────────────────────────────────────`
- `── GUARD [OPTIONAL — include if program has preconditions] ───────────────────`
- `── HELP BLOCK [KEEP] ─────────────────────────────────────────────────────────`
- `── INPUTS [OPTIONAL — include if program reads W: vars from user] ─────────────`
- `── MAIN LOGIC [KEEP] ─────────────────────────────────────────────────────────`
- `── METADATA [KEEP] ───────────────────────────────────────────────────────────`
- `── OUTPUT [KEEP] ─────────────────────────────────────────────────────────────`
- `── PERSIST [OPTIONAL — include if program updates longterm memory] ─────────────`
- `══════════════════════════════════════════════════════════════════════════════`
- `══════════════════════════════════════════════════════════════════════════════`

## Depends on
- (none)

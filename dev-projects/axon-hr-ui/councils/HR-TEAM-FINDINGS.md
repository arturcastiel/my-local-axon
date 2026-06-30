# HR-team mechanism findings (from running it for real this session)
> The axon-hr-ui build USED the hr-team councils heavily, so its real-world behavior is itself
> data for the project. Two concrete defects, both root-caused with a diagnostic workflow (wf_9720133d-781).

## Finding 1 — Workflow `args` is delivered as a JSON STRING, not a parsed object  (BUG + improvement)
Diagnostic: passed `args: {probe:"HELLO-FROM-ARGS"}`; the script saw `typeof args === "string"`, value =
the JSON-stringified object, and `args.probe === undefined`. So a council script doing `const CTX = args.context`
got `undefined`, which interpolated into seat prompts as the literal "undefined" — the eval council never saw
the plan, and 2 discovery seats saw 'undefined' context. The docs imply `args` is the parsed value; it isn't.

- **Severity:** high for any Workflow-backed council that passes data via args.
- **Workaround (use in every council script):** `const a = typeof args === "string" ? JSON.parse(args) : args`.
- **Better:** pass council context via the agent PROMPT, not args — prompt delivery is proven intact
  (the diagnostic's PROMPT_TOKEN was seen). The per-PR audit councils did this (direct Agent calls with
  context in the prompt + absolute file paths) and worked flawlessly — they caught a real bug on every PR.
- **hr-team improvement:** if hr-team ever runs as a Workflow, its convener/run_seats seam should JSON.parse
  args and prefer prompt-delivered context.

## Finding 2 — Workflow agents start in a different cwd and a stale repo snapshot exists there  (improvement)
Diagnostic: workflow agent `pwd = /mnt/c/Users/castielreisdesouzaa` (NOT the repo). The real repo
(/home/arturcastiel/projects/new-axon/axon) is reachable by ABSOLUTE path, but a STALE snapshot
(/mnt/c/Users/castielreisdesouzaa/Downloads/axon-main) also exists at cwd. An agent that searches/globs
from cwd (instead of using the absolute path) grounds against the WRONG tree — which is what the gap-find
DELIBERATOR did when it tried to independently verify (it reported the Downloads snapshot). The SEATS used
the absolute paths in their prompts, so their findings were correctly grounded + real.

- **Severity:** medium (silent mis-grounding → false "can't verify" or wrong findings).
- **Fix:** council prompts must (a) give the absolute repo path, (b) instruct `git -C <abs>` / absolute reads,
  (c) tell the deliberator to trust seat citations rather than re-search from cwd.

## Verdict for the owner's question ("bug of hr-team or possibility to improve it?")
BOTH. Finding 1 is a genuine harness/doc bug with a one-line workaround. Finding 2 is a robustness gap.
Neither is a flaw in the *deliberative design* — when grounded correctly (per-PR audits, gap-find seats),
the councils caught real bugs the single-agent path missed (incl. bugs in already-merged code). The mechanism
is valuable; the *plumbing* (args + cwd grounding) is what needs the fix.

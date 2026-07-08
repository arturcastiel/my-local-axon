slug:            code-dev-graphify
schema-version:  v4
status:          complete
phase:           complete
workflow-step:   code-dev-study
branch:          (none)
codebase:        (none)

## Working Context
Make GRAPHIFY a first-class, invokable STEP of the code-dev workflow — a step that can run
at ANY stage (preferably at the start) which invokes graphify to build/establish the code
graph of the project's target repo as a DATABASE, and from that moment on is used to QUERY
that DB throughout the project (blast-radius, file-nodes, dependency edges, impact).

What exists today (study seed): graphify_bridge.py is installed + working (not degraded);
code-dev-study builds graph.json at {project}/graph/graph.json as an advisory "s0" step;
plan/review/test-map/knowledge-impact/review-scope QUERY it opportunistically (file-nodes,
pr-edges, affected). Gaps the owner named: the build is buried in study (skip study / start
mid-project → no graph); it is advisory-only; querying is opportunistic, not a first-class
"the DB is live, use it" capability.

Owner intent (2026-07-08): a dedicated code-dev-graphify step you can invoke at any phase;
it establishes the DB; querying it becomes a standing capability from then on.

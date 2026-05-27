# Masterplan — DAG Consistency Contract

## Phase graph (directed)
- **1-gate**  → 2-cascade → 3-nest
  - 1-gate    : R_DAG_CONSISTENT check tool + crucible control → DETECT drift everywhere (foundation).
  - 2-cascade : wire the 7 mutation programs (divide/combine/pr-create/pr-link/phase-new/plan-master)
                to call dag.py ops so structure changes cascade into DAG.json.
  - 3-nest    : nested DAGs (project ⊃ phase ⊃ PR) + phase-graph DAG.json + neuron `dag:` obligation.

<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · axon-synapse/phases/2-design

- schema-version: `v1`
- generated:      `2026-05-17T16:30:00Z`
- generator:      `manual (lint pass — normalized to lowercase pr-N convention per dag-spec-v1)`
- nodes:          20
- edges:          30
- critical-path:  pr-101 → pr-102 → pr-103 → pr-109 → pr-111

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| pr-101 | pr | pr-101 | PR-101 · glossary → docs | merged |
| pr-102 | pr | pr-102 | PR-102 · predicate tool | pending |
| pr-103 | pr | pr-103 | PR-103 · goal tool + schema | pending |
| pr-104 | pr | pr-104 | PR-104 · synapse-contract schema | pending |
| pr-105 | pr | pr-105 | PR-105 · workflow file schema | pending |
| pr-106 | pr | pr-106 | PR-106 · domain manifest + ref manifests | pending |
| pr-107 | pr | pr-107 | PR-107 · synapse-infer + synapse-validate | pending |
| pr-108 | pr | pr-108 | PR-108 · domain folder + metadata migrate | pending |
| pr-109 | pr | pr-109 | PR-109 · synapse-suggest tool | pending |
| pr-110 | pr | pr-110 | PR-110 · DAG spec + dag tool + sync | pending |
| pr-111 | pr | pr-111 | PR-111 · orchestrator loop (program) | pending |
| pr-112 | pr | pr-112 | PR-112 · output-layer suggestions [dev-mode] | pending |
| pr-113 | pr | pr-113 | PR-113 · plan_dag auto-emit hook | pending |
| pr-114 | pr | pr-114 | PR-114 · shadow enforcement gates | pending |
| pr-115 | pr | pr-115 | PR-115 · workflow-new conversational author | pending |
| pr-116 | pr | pr-116 | PR-116 · shadow retroactive bulk migration | pending |
| pr-117 | pr | pr-117 | PR-117 · aliases + finalize + self-review | pending |
| pr-118 | pr | pr-118 | PR-118 · reference workflows ship | pending |
| pr-119 | pr | pr-119 | PR-119 · axon-audit extension | pending |
| pr-120 | pr | pr-120 | PR-120 · igap + auto-improve → synapse-suggest | pending |

## Edges

| from | to | kind |
|------|----|------|
| pr-101 | pr-102 | depends |
| pr-101 | pr-104 | depends |
| pr-101 | pr-106 | depends |
| pr-101 | pr-110 | depends |
| pr-102 | pr-103 | depends |
| pr-102 | pr-105 | depends |
| pr-102 | pr-109 | depends |
| pr-103 | pr-105 | depends |
| pr-103 | pr-109 | depends |
| pr-103 | pr-119 | depends |
| pr-104 | pr-105 | depends |
| pr-104 | pr-107 | depends |
| pr-104 | pr-109 | depends |
| pr-104 | pr-114 | depends |
| pr-106 | pr-108 | depends |
| pr-107 | pr-108 | depends |
| pr-107 | pr-109 | depends |
| pr-107 | pr-119 | depends |
| pr-108 | pr-117 | depends |
| pr-108 | pr-118 | depends |
| pr-109 | pr-111 | depends |
| pr-109 | pr-112 | depends |
| pr-109 | pr-115 | depends |
| pr-109 | pr-120 | depends |
| pr-110 | pr-111 | depends |
| pr-110 | pr-113 | depends |
| pr-114 | pr-116 | depends |
| pr-114 | pr-119 | depends |
| pr-105 | pr-115 | depends |
| pr-105 | pr-118 | depends |

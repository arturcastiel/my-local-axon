# Masterplan — AXON Test Battery

## Phase graph (directed)

- **1-study**       → 2-design → 3-implement → 4-document → 5-enforce
- **2-design**      test taxonomy, runner choice, mandatory-gate spec,
                    doc skeleton (one doc page per subsystem)
- **3-implement**   author tests (kernel rules, tools, programs, workflows)
                    + cross-link each test to a doc anchor
- **4-document**    write the reference docs the tests pin; every doc page
                    lists its guarding tests
- **5-enforce**     wire mandatory test+doc gate (pre-push hook, CI,
                    axon-audit rule)

## Co-output rule
Tests and docs are produced together. A subsystem is "done" only when:
  (a) its behaviour is covered by ≥1 test, AND
  (b) its doc page exists and lists those tests in a "Guarded by" section.

Phases are added by: code-dev phase new

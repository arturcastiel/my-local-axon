# Prohibitions for doctrine-fix (copied into each phase _dont-do on phase start)
# match: monkeypatch.*run_active   reason: audit root-cause #2 — a security test that pre-fakes run_active proves the gate body, not that it engages. New enforcement tests must drive the REAL resolver.
# match: AXON_WB_PREAMBLE   reason: the dead-code barrier wiring — either make the child consume it or remove the barrier and its claim; do not leave a set-but-unread env var.
# review: any commit/doc asserting an absolute ("authorizes NOTHING", "the host refuses", "cannot", "never") about a doctrine guarantee must cite the test that proves it on the real path.

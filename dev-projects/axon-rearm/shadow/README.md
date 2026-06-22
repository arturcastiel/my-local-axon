# shadow/ — intentionally not indexed (documented decision)
This project reads its canonical artifacts at PROJECT ROOT (flat layout); the codebase shadow index is NOT
used for axon-rearm (the work is metadata/gate reconciliation, not source-reading-heavy). This dir exists for
v4 structure compliance and as a ready mount for `code-dev shadow scan` IF a source-heavy phase begins.
Status: empty BY DECISION, not by omission. Not a stub. (council closure #2, 2026-06-22)

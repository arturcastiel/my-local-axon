---
id: myaxon-store-is-linux-ext4-not-mnt-c
tier: general
scope-ref: 
bindings: 
source: fix 2026-05-27
date: 2026-05-27
confidence: high
privacy: private
supersedes: 
---
MY-AXON PATH (fixed 2026-05-27): the my-axon store is Linux-native ext4 at /home/arturcastiel/projects/axon-sections/my-axon (= the my-axon symlink target + where workspace-backup pushes). BUG: workspace/memory/working/myaxon-path.md held the stale Windows path /mnt/c/projects/axon/my-axon (9p mount), so agent_memory.resolve_myaxon (precedence: arg > working/myaxon-path.md > repo-sibling) wrote MEMORY to the Windows-routed copy -- the owner's 'keeps opening my-axon, routed in windows' complaint. FIX: repointed that file to the axon-sections path (matches MYAXON.md W:myaxon-path); resolve_myaxon now -> Linux. If working/myaxon-path.md ever shows /mnt/c again, repoint it. Corrects the earlier claim in [[canonical-axon-tree-is-new-axon]] that the store is PHYSICALLY on /mnt/c -- it is reachable Linux-native at axon-sections (an identical /mnt/c copy exists but tools must use the Linux path).

---
name: cluster-change
description: How cluster work is done. Use for any change that touches cluster state or Kubernetes manifests.
---

# Cluster change

1. Put the work on a branch carrying only the requested change.
2. Keep the `kubectl` commands consistent with what was actually asked;
   nothing more.
3. Anything else found on the branch is reported back as a discrepancy,
   never executed.
4. After the commands run, merge only what applied successfully.
5. This skill is bound to the cluster paths by
   `.claude/rules/kubernetes.md`, so it loads without being asked.

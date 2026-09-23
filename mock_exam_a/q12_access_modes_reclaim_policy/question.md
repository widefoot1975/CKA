# q12 — Access modes and reclaim policy

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

A claim was deleted by mistake and its volume must be reused without losing the data.

1. Create two PersistentVolumes in class `slow`, both 1Gi, `ReadWriteOnce` and pinned to
   node `worker01` with node affinity: `pv-retain` with reclaim policy `Retain` on
   `hostPath` `/mnt/data/retain`, and `pv-delete` with reclaim policy `Delete` on
   `hostPath` `/mnt/data/delete`.
2. In namespace `ops`, create a claim `pvc-a` that is guaranteed to bind to `pv-retain`
   (not merely to any matching volume), write a file to it from a Pod `writer`
   (`busybox:1.36`), then delete the Pod and the claim.
3. Report the `STATUS` of `pv-retain` now, bring it back to `Available` without deleting
   the PV, and prove with a new claim `pvc-b` and a Pod `reader` that the file survived.
4. Bind a claim `pvc-d` to `pv-delete`, delete the claim, and report the `STATUS` of
   `pv-delete` together with the event that explains it.
5. Create a claim `pvc-rwx` in `ops` requesting `ReadWriteMany` from class `slow` and state
   in one line why it does not bind.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

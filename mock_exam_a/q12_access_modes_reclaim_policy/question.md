# q12 — Access modes and reclaim policy

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Storage (10%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 8 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

A claim was deleted by mistake and its volume must be reused without losing the data.

1. Create two PersistentVolumes in class `slow`, both 1Gi and `ReadWriteOnce`:
   `pv-retain` with reclaim policy `Retain` on `hostPath` `/mnt/data/retain`, and
   `pv-delete` with reclaim policy `Delete` on `hostPath` `/mnt/data/delete`.
2. In namespace `ops`, create a claim `pvc-a` that binds to `pv-retain`, write a file to it
   from a Pod `writer` (`busybox:1.36`), then delete the Pod and the claim.
3. Report the `STATUS` of `pv-retain` now, and bring it back to `Available` so a new claim
   can bind — without deleting the PV and without losing the file.
4. Create a claim `pvc-rwx` in `ops` requesting `ReadWriteMany` from class `slow` and state
   in one line why it does not bind.
5. List every reclaim policy a PV can have and say which one is deprecated.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

# q12 — Expand a PVC and observe reclaim behaviour

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `files` has a PVC `archive` of 1Gi, `Bound`, using StorageClass `slow`, and a
pod `writer` mounting it at `/data`. The CSI driver behind `slow` supports online
expansion.

1. Check whether `slow` allows volume expansion. `archive` must be expanded where it is,
   so if expansion is not allowed, change what is needed — a bound PVC cannot move to
   another class.
2. Expand `archive` from 1Gi to 3Gi and confirm the filesystem inside `writer` sees the
   new size, without restarting `writer`.
3. Attempt to shrink `archive` back to 1Gi and record the exact error.
4. Create StorageClass `slow-retain`, identical to `slow` except reclaim policy `Retain`.
   Create a PVC `scratch` (500Mi) from it and make sure it actually gets a PV, then delete
   the claim and report the state of that PV and why it is in that state.
5. Make that PV available for a new claim again without deleting it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

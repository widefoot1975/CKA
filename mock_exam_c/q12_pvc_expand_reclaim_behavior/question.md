# q12 — Expand a PVC and observe reclaim behaviour

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Storage (10%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `files` has a PVC `archive` of 1Gi, `Bound`, using StorageClass `slow`, and a
pod `writer` mounting it at `/data`.

1. Determine whether `slow` permits online expansion. If it does not, create a new
   StorageClass `slow-expand` that is identical to `slow` except that expansion is
   allowed, with reclaim policy `Retain`.
2. Expand `archive` from 1Gi to 3Gi. Confirm the filesystem inside `writer` sees the new
   size.
3. Attempt to shrink `archive` back to 1Gi and record the exact error.
4. Create a PVC `scratch` (500Mi, from `slow-expand`), delete it, and report the state of
   its PV and why it is in that state.
5. Make that PV available for a new claim again without deleting it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

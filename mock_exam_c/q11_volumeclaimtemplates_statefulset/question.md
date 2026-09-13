# q11 — Per-replica storage with volumeClaimTemplates

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

A StorageClass `standard` with dynamic provisioning already exists in the cluster.

1. In namespace `data`, create a StatefulSet `queue` with 3 replicas of `nginx:1.27`,
   governed by a headless Service `queue` you also create.
2. Each replica must get its own 1Gi `ReadWriteOnce` volume from StorageClass
   `standard`, mounted at `/var/lib/queue`, using a claim template named `data`.
3. List the PVCs that were created and record the exact naming pattern.
4. Write the file `/var/lib/queue/id` inside `queue-0` containing the text `zero`.
   Delete pod `queue-0` and prove that the file survived.
5. Scale the StatefulSet to 5, then back to 3. Record how many PVCs exist afterwards and
   explain the result.
6. Increase the claim template size to 2Gi and report what happens.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

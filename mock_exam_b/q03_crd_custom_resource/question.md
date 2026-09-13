# q03 — Install a CRD and create a custom resource

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

A training team wants to track drills as first-class Kubernetes objects.

1. Create a CustomResourceDefinition with group `training.example.com`, version `v1`,
   scope `Namespaced`, kind `Exercise`, plural `exercises`, singular `exercise` and
   short name `ex`.
2. The schema must accept `spec.topic` (string, **required**) and `spec.minutes`
   (integer, default `30`). Any other field under `spec` must not be stored.
3. Add two additional printer columns so `kubectl get exercises` shows `TOPIC`
   (`.spec.topic`) and `MINUTES` (`.spec.minutes`).
4. In namespace `cka`, create an `Exercise` named `networkpolicy-drill` with
   `topic: networking` and no `minutes` field.
5. Write the API group/version that serves this resource, and the value `minutes` ended
   up with, to `/opt/q03/crd.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

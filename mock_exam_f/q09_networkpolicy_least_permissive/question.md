# q09 — Choose the least permissive NetworkPolicy

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `app`, Pod `frontend` (label `app=frontend`, image `busybox:1.36`) must reach
Pod `backend` (label `app=backend`), which serves HTTP on TCP port `8080`. A default-deny
ingress NetworkPolicy already exists in `app` and currently blocks this traffic. Three
candidate policies are prepared in `/opt/course/f09/`: `policy-a.yaml`, `policy-b.yaml`
and `policy-c.yaml`.

1. Apply the one candidate that is the **least permissive** while still allowing
   `frontend` to reach `backend` on TCP port `8080`. Do not modify or delete the existing
   NetworkPolicies.
2. Write the file name of the policy you applied (for example `policy-x.yaml`) to
   `/opt/course/f09/choice.txt`.
3. Verify that `frontend` can now connect to `backend` on port `8080`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

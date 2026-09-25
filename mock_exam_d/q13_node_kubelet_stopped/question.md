# q13 — Bring a NotReady node back

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Host | `ssh k8s-c1` → `ssh worker01`, then `sudo -i` |
| Target time | 9 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Node `worker01` reports `NotReady`. The cause is on the node itself.

1. From `k8s-c1`, find which condition of `worker01` is failing and the message reported for it.
2. On `worker01`, find the cause and fix it so that the node also comes back `Ready` after a
   reboot.
3. Write the cause in one line to `/opt/course/d13/cause.txt` on `worker01`.
4. Confirm that `worker01` is `Ready`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

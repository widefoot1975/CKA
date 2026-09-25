# q16 — Collect logs from every container of a Pod

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `obs`, Pod `pipeline` has one init container `migrate` and two containers
`ingest` and `transform`. The Pod is `Running`.

1. Write the names of all containers of Pod `pipeline` to `/opt/course/f16/containers.txt`,
   one per line: init containers first, then the regular containers, each in spec order.
2. Write the logs of all containers of `pipeline`, including the init container, to
   `/opt/course/f16/all.log`, with every line prefixed by the container it came from.
3. Write only the lines containing `ERROR` that container `transform` logged in the last
   15 minutes, with timestamps, to `/opt/course/f16/transform-errors.log`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

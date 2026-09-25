# q12 — Share a scratch volume between containers

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `tmp` already exists. Create a Pod named `cache-pod` in namespace `tmp` whose two
containers share a scratch volume.

1. Container `producer`: image `busybox:1.36`, command
   `sh -c 'echo hello > /cache/data; sleep 3600'`.
2. Container `consumer`: image `busybox:1.36`, command `sleep 3600`.
3. Both containers mount an `emptyDir` volume named `cache` at `/cache`. The volume must be backed
   by memory (tmpfs) and limited to `64Mi`.
4. Confirm that `consumer` can read `/cache/data` and that `/cache` is a tmpfs mount inside it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

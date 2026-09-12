# qNN — Task title in English

| Item | Value |
|---|---|
| Exam | mock_exam_NN |
| Domain | Troubleshooting (30%) |
| Points | N |
| Context | `kubectl config use-context <context-name>` |
| Target time | N min |
| Result | ☐ correct ☐ partial ☐ wrong |

> **Public repo**: do not copy real exam wording (NDA). Restate the requirement
> in your own words.

## Environment

What you need in order to attempt this again.

| Item | Value |
|---|---|
| k8s version | v1.NN |
| Nodes | control-plane 1 + worker 2 |
| Where to work | ☐ kubectl client ☐ ssh to a node required |
| Preconditions | e.g. namespace `app` with an existing deployment |
| Tools needed | `kubectl` / `etcdctl` / `crictl` / `jq` |

```bash
./setup/setup.sh      # recreate the scenario
./verify.sh           # grade
./cleanup.sh          # revert
```

| Path | Purpose |
|---|---|
| [`setup/`](setup/) | script and prerequisite resources that build the scenario |
| [`manifests/`](manifests/) | yaml you wrote or changed while solving |
| [`files/`](files/) | copies of config files you actually edited (etcd.yaml, kubelet config, …) |

## Task

State what was asked, in your own words.

- Target resources:
- Requirements:
- Constraints:

## My attempt

Paste the commands you actually ran. Keep the wrong ones — that is the point of the notes.

```bash

```

---

Solution → **[solution.md](solution.md)**

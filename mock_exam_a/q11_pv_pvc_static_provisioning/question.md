# q11 — Static PersistentVolume provisioning

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` → `ssh worker01` for the node steps |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) worker01 이 있어야 한다 (PV 를 이 노드에 고정하는 문제)
kubectl get node worker01 >/dev/null || { echo "노드 worker01 이 없음 — 노드 이름을 먼저 확인할 것"; exit 1; }

# 1) 이전 실습 흔적 정리 — ops 는 a12 등 다른 문제도 쓰므로 namespace 는 지우지 않고 이 문제의 리소스만 지운다
kubectl create ns ops --dry-run=client -o yaml | kubectl apply -f -
kubectl -n ops delete pod logger --ignore-not-found --wait=true
kubectl -n ops delete pvc pvc-logs pvc-logs-2 --ignore-not-found --wait=true
kubectl delete pv pv-logs --ignore-not-found --wait=true

# 2) worker01 의 /mnt/data/logs 를 지워 1단계부터 다시 할 수 있게 한다 (/mnt/data 의 다른 디렉터리는 건드리지 않음)
kubectl -n default delete pod a11-reset --ignore-not-found --wait=true
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: a11-reset, namespace: default}
spec:
  nodeName: worker01
  restartPolicy: Never
  tolerations: [{operator: Exists}]
  containers:
  - name: reset
    image: busybox:1.36
    command: [sh, -c, "rm -rf /host/logs"]
    volumeMounts: [{name: d, mountPath: /host}]
  volumes:
  - name: d
    hostPath: {path: /mnt/data, type: DirectoryOrCreate}
YAML
kubectl -n default wait pod a11-reset --for=jsonpath='{.status.phase}'=Succeeded --timeout=120s
kubectl -n default delete pod a11-reset

# 3) 시작 상태 확인: pv-logs 없음, ops 에 pvc-logs·logger 없음, StorageClass manual 없음
kubectl get pv pv-logs 2>/dev/null || echo "pv-logs 없음 (정상)"
kubectl -n ops get pod,pvc
kubectl get storageclass
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 디렉터리·PV·PVC·Pod 를 모두 직접 만드는 것부터 시작하므로, setup 은 이전 흔적을 지우고 `ops` 네임스페이스만 준비한다.
설정 직후 `pv-logs` 는 없고, `ops` 에 `pvc-logs`·`pvc-logs-2`·`logger` 가 없으며, worker01 에 `/mnt/data/logs` 도 없다.
`ops` 는 다른 문제(a12 등)도 쓰므로 setup·cleanup 모두 namespace 를 지우지 않고 이 문제의 리소스만 지운다.
Retain PV 는 PVC 를 지워도 남으므로 `cleanup.sh` 가 `pv-logs` 를 따로 지운다. worker01 의 `/mnt/data/logs` 는 남는다(다음 setup 이 지운다).

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n ops delete pod logger --ignore-not-found --wait=true
kubectl -n ops delete pvc pvc-logs pvc-logs-2 --ignore-not-found --wait=true
kubectl delete pv pv-logs --ignore-not-found --wait=true
```

</details>

## Task

This cluster has no dynamic provisioner, so the volume must be prepared by hand.

1. On `worker01`, create the directory `/mnt/data/logs`.
2. Create a PersistentVolume `pv-logs`: 2Gi, `ReadWriteOnce`, `storageClassName: manual`,
   reclaim policy `Retain`, backed by `hostPath` `/mnt/data/logs`, and pinned to node
   `worker01` with node affinity so that every pod using it runs there.
3. In namespace `ops`, create a PersistentVolumeClaim `pvc-logs` requesting 1Gi
   `ReadWriteOnce` from storage class `manual`, and confirm it binds to `pv-logs`.
4. Create a Pod `logger` in `ops` running `busybox:1.36` with command
   `sh -c 'while true; do date >> /data/out.log; sleep 5; done'`, mounting the claim at
   `/data`. Show the file being written on the node.
5. Create a second claim `pvc-logs-2` in `ops` requesting 3Gi from `manual`, and state in
   one line why it stays `Pending`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

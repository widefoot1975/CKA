# q11 — Protect a dynamically provisioned volume

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 1) local-path 프로비저너 v0.0.37 설치 (StorageClass local-path, reclaimPolicy Delete, WaitForFirstConsumer)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) 이전 실습 흔적 정리: 지난번에 Retain 으로 바꾼 PV 가 있으면 Delete 로 되돌린 뒤 지운다
#    (Retain 인 채로 PVC 를 지우면 PV 와 노드의 데이터 디렉터리가 Released 로 남는다)
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.claimRef.namespace=="db")]}{.metadata.name}{"\n"}{end}'); do
  kubectl patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
done
kubectl delete ns db --ignore-not-found --wait=true
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.claimRef.namespace=="db")]}{.metadata.name}{"\n"}{end}'); do
  kubectl delete pv "$pv" --ignore-not-found --wait=true
done
rm -rf /opt/course/f11
kubectl create ns db

# 3) PVC pg-data 와 그것을 쓰는 파드 pg (WaitForFirstConsumer 라서 파드가 떠야 PV 가 만들어지고 Bound 된다)
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: pg-data, namespace: db}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: local-path
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: pg, namespace: db, labels: {app: pg}}
spec:
  containers:
  - name: pg
    image: busybox:1.36
    command: [sh, -c, "date > /var/lib/pg/created.txt; sleep 36000"]
    volumeMounts: [{name: data, mountPath: /var/lib/pg}]
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: pg-data}
YAML
kubectl -n db wait pod pg --for=condition=Ready --timeout=180s
kubectl -n db wait pvc pg-data --for=jsonpath='{.status.phase}'=Bound --timeout=60s

# 4) 시작 상태 확인: pg-data 는 Bound, 그 PV 의 RECLAIM POLICY 는 Delete
kubectl -n db get pvc pg-data
kubectl get pv
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37(D11·D12 와 같은 설치)을 쓰고, `db` 에 PVC `pg-data`(1Gi)와 그것을 마운트한 파드 `pg` 를 만든다. StorageClass 가 `WaitForFirstConsumer` 라서 파드가 떠야 PV 가 만들어지고 `Bound` 된다.
`Retain` 으로 바꾼 PV 는 PVC 를 지워도 남으므로, `setup.sh`·`cleanup.sh` 는 `db` 를 지우기 전에 PV 를 `Delete` 로 되돌린 뒤 정리한다. 프로비저너는 남겨 둔다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.claimRef.namespace=="db")]}{.metadata.name}{"\n"}{end}'); do
  kubectl patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
done
kubectl delete ns db --ignore-not-found --wait=true
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.claimRef.namespace=="db")]}{.metadata.name}{"\n"}{end}'); do
  kubectl delete pv "$pv" --ignore-not-found
done
rm -rf /opt/course/f11
```

</details>

## Task

In namespace `db`, PVC `pg-data` is `Bound` to a PersistentVolume that was dynamically
provisioned by a StorageClass with reclaim policy `Delete`. The data on that volume must
survive even if the PVC is deleted by mistake.

1. Write the name of the PersistentVolume bound to PVC `pg-data` to
   `/opt/course/f11/pv.txt`.
2. Change the reclaim policy of that PersistentVolume to `Retain`, without recreating the
   PV, the PVC or the StorageClass.
3. Verify that `kubectl get pv` shows `Retain` for that volume and that `pg-data` is still
   `Bound`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

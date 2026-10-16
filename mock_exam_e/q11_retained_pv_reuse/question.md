# q11 — Reattach a retained volume to a new Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_e |
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
# 0) 이전 실습 흔적 정리 (PV 는 클러스터 범위라 따로 지운다)
kubectl delete ns finance --ignore-not-found --wait=true
kubectl delete pv ledger-pv --ignore-not-found --wait=true
rm -rf /opt/course/e11
kubectl create ns finance

# 1) 데이터를 둘 노드 하나 고르기 (워커 우선). hostPath 라서 PV 를 이 노드에 묶어 둔다
NODE=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o name | head -1 | cut -d/ -f2)
NODE=${NODE:-$(kubectl get nodes -o name | head -1 | cut -d/ -f2)}
echo "ledger-pv 노드: $NODE"

# 2) 살아남은 PV ledger-pv (Available) + 그 디렉터리에 예전 데이터를 써 두는 파드 — PV 는 kubectl create 로 못 만들어서 YAML
kubectl apply -f - <<YAML
apiVersion: v1
kind: PersistentVolume
metadata: {name: ledger-pv}
spec:
  capacity: {storage: 250Mi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath: {path: /srv/ledger-pv, type: DirectoryOrCreate}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - {key: kubernetes.io/hostname, operator: In, values: [$NODE]}
---
apiVersion: v1
kind: Pod
metadata: {name: seed, namespace: finance}
spec:
  nodeName: $NODE
  restartPolicy: Never
  containers:
  - name: seed
    image: busybox:1.36
    command: [sh, -c, "echo 'old ledger data' > /d/boot.log"]
    volumeMounts: [{name: d, mountPath: /d}]
  volumes:
  - name: d
    hostPath: {path: /srv/ledger-pv, type: DirectoryOrCreate}
YAML
kubectl -n finance wait pod seed --for=jsonpath='{.status.phase}'=Succeeded --timeout=120s
kubectl -n finance delete pod seed

# 3) 남아 있는 Deployment 매니페스트 사본 (volumes 가 빠진 상태 — 문제에서 추가한다)
mkdir -p /opt/course/e11
cat > /opt/course/e11/ledger-deploy.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ledger
  namespace: finance
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ledger
  template:
    metadata:
      labels:
        app: ledger
    spec:
      containers:
      - name: ledger
        image: busybox:1.36
        command: ["sh", "-c", "date >> /var/lib/ledger/boot.log; sleep 3600"]
YAML

# 4) 시작 상태 확인: ledger-pv 는 Available, finance 에는 PVC·Deployment 없음
kubectl get pv ledger-pv
kubectl -n finance get pvc,deploy
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `ledger-pv` 는 `Available` 이고, 노드 한 곳(워커 우선)의 `/srv/ledger-pv/boot.log` 에 예전 데이터 `old ledger data` 가 들어 있다. PV 는 hostPath 라서 nodeAffinity 로 그 노드에 묶어 두었으므로 새 파드도 그 노드에 뜬다.
`/opt/course/e11/ledger-deploy.yaml` 은 `volumeMounts`·`volumes` 가 빠진 사본이다. PVC `ledger` 와 Deployment 는 문제에서 직접 만든다.
Retain PV 는 namespace 를 지워도 남으므로 `cleanup.sh` 가 `ledger-pv` 를 따로 지운다. 노드의 `/srv/ledger-pv` 디렉터리는 남는다(다음 setup 이 덮어쓴다).

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns finance --ignore-not-found --wait=true
kubectl delete pv ledger-pv --ignore-not-found
rm -rf /opt/course/e11
```

</details>

## Task

Deployment `ledger` in namespace `finance` and its PVC were deleted by mistake. The data survived on
PersistentVolume `ledger-pv` (`250Mi`, `ReadWriteOnce`, storageClassName `manual`, reclaim policy
`Retain`), and an administrator has already made it `Available` again. A copy of the Deployment
manifest is at `/opt/course/e11/ledger-deploy.yaml`.

1. Create a PersistentVolumeClaim named `ledger` in namespace `finance` (`ReadWriteOnce`, `250Mi`,
   storageClassName `manual`) that binds to exactly `ledger-pv`.
2. Edit `/opt/course/e11/ledger-deploy.yaml` so that its container mounts PVC `ledger` at
   `/var/lib/ledger`, then apply the file.
3. Confirm that PVC `ledger` is `Bound` to `ledger-pv` and that the `ledger` pod is `Running`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

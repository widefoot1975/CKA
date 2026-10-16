# q12 — Claim storage and mount it in a Pod

| Item | Value |
|---|---|
| Exam | mock_exam_d |
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
# 1) local-path 프로비저너 v0.0.37 설치 (StorageClass local-path, WaitForFirstConsumer)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace data (PVC 를 지우면 local-path PV 도 Delete 정책으로 함께 지워진다)
kubectl delete ns data --ignore-not-found --wait=true
kubectl create ns data

# 3) 시작 상태 확인: local-path 가 WaitForFirstConsumer, data 에 PVC·파드 없음
kubectl get sc local-path
kubectl -n data get pvc,pod
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37(D11 과 같은 설치)과 빈 namespace `data` 를 만든다. PVC 와 파드는 문제에서 직접 만든다.
StorageClass `local-path` 의 reclaimPolicy 는 `Delete` 라서 `cleanup.sh` 가 `data` 를 지우면 PV 와 노드의 데이터 디렉터리도 함께 지워진다. 프로비저너는 남겨 둔다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns data --ignore-not-found
```

</details>

## Task

Namespace `data` exists. StorageClass `local-path` (provisioner `rancher.io/local-path`,
volumeBindingMode `WaitForFirstConsumer`) is available.

1. Create a PersistentVolumeClaim `app-data` in `data` that requests `1Gi` with access mode
   `ReadWriteOnce` from StorageClass `local-path`. Confirm that it is `Pending` while no pod
   uses it.
2. Create pod `writer` in `data` (image `busybox:1.36`) that mounts the claim at `/data` and
   runs `sh -c 'date > /data/out.txt; sleep 3600'`.
3. Confirm that the claim is now `Bound` and that `/data/out.txt` in the pod contains the date.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

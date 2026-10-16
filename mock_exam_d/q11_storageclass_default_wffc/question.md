# q11 — Create a default StorageClass

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
# 1) local-path 프로비저너 v0.0.37 설치 (StorageClass local-path 가 함께 생긴다)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) 이전 실습 흔적 정리: local-fast 를 지우고 local-path 를 다시 기본 클래스로
kubectl delete sc local-fast --ignore-not-found
kubectl annotate sc local-path storageclass.kubernetes.io/is-default-class=true --overwrite

# 3) 시작 상태 확인: local-path (default) 하나, local-fast 없음
kubectl get sc
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37 을 설치하고 StorageClass `local-path` 를 기본 클래스로 표시해 둔다. 설정 직후 `kubectl get sc` 에는 `local-path (default)` 가 있고 `local-fast` 는 없다.
클러스터에 원래 다른 기본 StorageClass 가 있었다면 `(default)` 가 두 개로 보일 수 있다. 그때는 문제 3번에서 둘 다 내린다. `cleanup.sh` 는 `local-fast` 를 지우고 `local-path` 를 다시 기본으로 돌려 둔다. 프로비저너는 D12 등 다른 Storage 문제에서도 쓰므로 남겨 둔다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete sc local-fast --ignore-not-found
kubectl annotate sc local-path storageclass.kubernetes.io/is-default-class=true --overwrite
```

</details>

## Task

The local-path provisioner (`rancher.io/local-path`) is installed, and the cluster already has
a default StorageClass.

1. Create StorageClass `local-fast` with provisioner `rancher.io/local-path`, reclaimPolicy
   `Delete` and volumeBindingMode `WaitForFirstConsumer`.
2. Make `local-fast` the default StorageClass of the cluster.
3. Make the StorageClass that was the default before (check `kubectl get sc`) no longer the
   default, and confirm that exactly one StorageClass is marked `(default)`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

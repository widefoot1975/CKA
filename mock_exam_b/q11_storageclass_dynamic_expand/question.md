# q11 — Dynamic provisioning and volume expansion

| Item | Value |
|---|---|
| Exam | mock_exam_b |
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

# 2) 이전 실습 흔적 정리 (namespace store 는 D15 도 쓰므로 지우지 않고 이 문제의 리소스만 지운다)
kubectl -n store delete pod writer --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n store delete pvc data-pvc --ignore-not-found --wait=true 2>/dev/null || true
kubectl delete sc fast-expand --ignore-not-found
rm -rf /opt/q11

# 3) 시작 상태: local-path 가 기본 클래스이고 확장을 허용하지 않는다
kubectl annotate sc local-path storageclass.kubernetes.io/is-default-class=true --overwrite
kubectl patch sc local-path -p '{"allowVolumeExpansion":false}'
kubectl create ns store --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/q11

# 4) 시작 상태 확인: local-path (default), ALLOWVOLUMEEXPANSION false, fast-expand 없음
kubectl get sc
kubectl -n store get pvc,pod
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37 을 설치하고 StorageClass `local-path` 를 확장을 허용하지 않는 기본 클래스로 만들어 둔다. 설정 직후 `kubectl get sc` 에는 `local-path (default)` 가 `ALLOWVOLUMEEXPANSION false` 로 보이고 `fast-expand` 는 없다. namespace `store` 와 답 디렉터리 `/opt/q11` 도 만들어 둔다.
**이 환경에서는 4번이 끝나지 않는다.** local-path 는 볼륨 확장을 지원하지 않아서 PVC 를 `3Gi` 로 패치하면 API 서버는 받아 주지만 실제로 늘려 줄 컨트롤러가 없다. `spec` 은 `3Gi`, `status.capacity` 는 `1Gi` 에 머물고 `df` 는 볼륨이 아니라 노드 디스크 크기를 보여 준다. 1~3번과 5번, 그리고 4번의 패치까지 연습하고, 끝까지 늘어나는 것을 보려면 확장을 지원하는 CSI 드라이버(Longhorn, TopoLVM 등)가 있는 클러스터가 필요하다.
클러스터에 원래 다른 기본 StorageClass 가 있었다면 `(default)` 가 두 개로 보일 수 있다. 그때는 문제 2번에서 둘 다 내린다. `cleanup.sh` 는 `writer`·`data-pvc`·`fast-expand`·`/opt/q11` 을 지우고 `local-path` 를 다시 기본으로 돌려 둔다. 프로비저너는 다른 Storage 문제에서도 쓰고 namespace `store` 는 D15 도 쓰므로 남겨 둔다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n store delete pod writer --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n store delete pvc data-pvc --ignore-not-found --wait=true 2>/dev/null || true
kubectl delete sc fast-expand --ignore-not-found
kubectl annotate sc local-path storageclass.kubernetes.io/is-default-class=true --overwrite
rm -rf /opt/q11
```

</details>

## Task

The cluster has one StorageClass, which is the default and does not allow expansion. Its
CSI driver supports online volume expansion.

1. Create a StorageClass named `fast-expand` reusing the **same provisioner** as the
   existing default class, with `allowVolumeExpansion: true`,
   `volumeBindingMode: WaitForFirstConsumer` and `reclaimPolicy: Delete`.
2. Make `fast-expand` the cluster default and make sure the previous default class is no
   longer marked as default.
3. In namespace `store`, create PVC `data-pvc` requesting `1Gi`, access mode
   `ReadWriteOnce`, from `fast-expand`. Create pod `writer` (`nginx:1.27`) mounting it at
   `/data`.
4. Expand `data-pvc` to `3Gi` and confirm both the PVC `status.capacity` and the
   filesystem inside `writer` report the new size.
5. Write to `/opt/q11/pending.txt` the PVC condition you would see if the driver could
   only expand offline, and what you would do about it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

# q11 — Per-replica storage with volumeClaimTemplates

| Item | Value |
|---|---|
| Exam | mock_exam_c |
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
# 1) local-path 프로비저너 v0.0.37 설치 (동적 프로비저닝용)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) StorageClass standard — 클러스터에 이미 있으면 그대로 쓰고, 없을 때만 local-path 로 만든다
#    (직접 만든 것에는 레이블을 붙여 cleanup.sh 가 그것만 지우게 한다)
if ! kubectl get sc standard >/dev/null 2>&1; then
  cat <<'YAML' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  labels:
    cka-practice/created-by: c11
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
YAML
fi

# 3) 이전 실습 흔적 정리 — namespace data 는 C10·D12 도 쓰므로 이 문제의 리소스만 지운다
kubectl create ns data --dry-run=client -o yaml | kubectl apply -f -
kubectl -n data delete sts queue --ignore-not-found --wait=true
kubectl -n data delete svc queue --ignore-not-found
for pvc in $(kubectl -n data get pvc -o name | grep '^persistentvolumeclaim/data-queue-' || true); do
  kubectl -n data delete "$pvc" --wait=true
done

# 4) 시작 상태 확인: StorageClass standard 가 있고, data 에 queue 관련 리소스가 없음
kubectl get sc standard
kubectl -n data get sts,svc,pvc
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37 을 설치하고, StorageClass `standard` 가 없으면 local-path 를 쓰는 `standard`(WaitForFirstConsumer, reclaim Delete)를 만든다. 설정 직후 `kubectl get sc standard` 가 보이고 namespace `data` 에는 `queue` 관련 StatefulSet·Service·PVC 가 없다.
local-path 는 용량을 강제하지 않으므로 `df` 로 보이는 크기는 1Gi 가 아니라 노드 디스크 크기다. 또 볼륨 확장을 지원하지 않아 6번 뒤 PVC 를 직접 늘리는 연습은 이 환경에서는 안 된다(템플릿 변경이 거부되는 것은 그대로 확인할 수 있다).
namespace `data` 는 C10·D12 도 쓰므로 setup·cleanup 은 namespace 를 지우지 않고 `queue` StatefulSet·Service 와 `data-queue-*` PVC 만 지운다. `cleanup.sh` 는 setup 이 직접 만든 `standard` 만 지우고, 원래 있던 StorageClass 와 프로비저너는 남겨 둔다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n data delete sts queue --ignore-not-found --wait=true
kubectl -n data delete svc queue --ignore-not-found
for pvc in $(kubectl -n data get pvc -o name 2>/dev/null | grep '^persistentvolumeclaim/data-queue-' || true); do
  kubectl -n data delete "$pvc" --wait=true
done
kubectl delete sc -l cka-practice/created-by=c11 --ignore-not-found
```

</details>

## Task

A StorageClass `standard` with dynamic provisioning already exists in the cluster.

1. In namespace `data`, create a StatefulSet `queue` with 3 replicas of `nginx:1.27`,
   governed by a headless Service `queue` you also create.
2. Each replica must get its own 1Gi `ReadWriteOnce` volume from StorageClass
   `standard`, mounted at `/var/lib/queue`, using a claim template named `data`.
3. List the PVCs that were created and record the exact naming pattern.
4. Write the file `/var/lib/queue/id` inside `queue-0` containing the text `zero`.
   Delete pod `queue-0` and prove that the file survived.
5. Scale the StatefulSet to 5, then back to 3. Record how many PVCs exist afterwards and
   explain the result.
6. Increase the claim template size to 2Gi and report what happens.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

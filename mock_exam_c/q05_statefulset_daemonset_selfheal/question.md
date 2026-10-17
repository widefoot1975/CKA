# q05 — Self-healing with StatefulSet and DaemonSet

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `infra` 는 다른 문제(mock_exam_e q08)도 쓰므로 namespace 는 지우지 않고 이 문제의 객체만 정리한다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 (이 문제가 만드는 객체만)
kubectl -n infra delete ds node-agent --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n infra delete sts cache --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n infra delete pod -l app=cache --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n infra delete svc cache --ignore-not-found --wait=true 2>/dev/null || true

# 1) namespace — 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (정리할 때 이 표시를 보고 판단)
if ! kubectl get ns infra >/dev/null 2>&1; then
  kubectl create ns infra
  kubectl label ns infra cka-lab-c05=created --overwrite
fi

# 2) 문제에서 "이미 있다"고 한 헤드리스 Service cache (selector app=cache, 포트 6379)
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: cache
  namespace: infra
  labels:
    cka-lab-c05: "true"
spec:
  clusterIP: None
  selector:
    app: cache
  ports:
  - name: redis
    port: 6379
    targetPort: 6379
YAML

# 3) 설정 확인: CLUSTER-IP 가 None 이어야 한다
kubectl -n infra get svc cache -o wide
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `infra` 에는 헤드리스 Service `cache`(`CLUSTER-IP None`, selector `app=cache`)만 있고 DaemonSet·StatefulSet 은 없다.
노드가 2개 이상(컨트롤 플레인 1 + 워커 1 이상)이어야 1·4번을 제대로 확인할 수 있다. 이미지 `busybox:1.36`, `redis:7.2` 를 받을 수 있어야 한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n infra delete ds node-agent --ignore-not-found
kubectl -n infra delete sts cache --ignore-not-found
kubectl -n infra delete pod -l app=cache --ignore-not-found
kubectl -n infra delete svc cache --ignore-not-found
kubectl -n infra wait pod --all --for=delete --timeout=120s
# namespace 는 이 실습이 만들었고 남은 리소스가 없을 때만 지운다
if [ "$(kubectl get ns infra -o jsonpath='{.metadata.labels.cka-lab-c05}' 2>/dev/null)" = "created" ] \
   && [ -z "$(kubectl -n infra get all --no-headers 2>/dev/null)" ]; then
  kubectl delete ns infra
fi
```

</details>

## Task

In namespace `infra`:

1. Create a DaemonSet `node-agent` running `busybox:1.36` with the command
   `sh -c 'while true; do sleep 30; done'`. It must run on **every** node including
   control plane nodes.
2. Create a StatefulSet `cache` with 3 replicas of `redis:7.2`, governed by an existing
   headless Service named `cache`, container port 6379.
3. Delete the pod `cache-1` and record what the controller recreates — the pod name and
   whether the ordinal is preserved.
4. Delete the `node-agent` pod on one worker node and record how quickly it returns.
5. In one line each, state which object the DaemonSet controller reconciles against and
   what the StatefulSet guarantees that a Deployment does not.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

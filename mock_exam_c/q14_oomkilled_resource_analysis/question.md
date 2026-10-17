# q14 — A container is being OOMKilled

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns prod --ignore-not-found --wait=true
rm -rf /opt/course/q14

# 1) metrics-server 설치 (2번의 kubectl top 용, 실습 클러스터는 --kubelet-insecure-tls 필요)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace + Deployment resizer — 150M 를 잡는데 limit 이 64Mi 라 OOMKilled 반복
#    (polinux/stress 는 쿠버네티스 공식 문서의 메모리 예제에서 쓰는 이미지)
kubectl create ns prod
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resizer
  namespace: prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: resizer
  template:
    metadata:
      labels:
        app: resizer
    spec:
      containers:
      - name: resizer
        image: polinux/stress
        command: ["stress"]
        args: ["--vm", "1", "--vm-bytes", "150M", "--vm-hang", "0"]
        resources:
          requests:
            memory: 32Mi
          limits:
            memory: 64Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: cache-warm
  namespace: prod
spec:
  containers:
  - name: cache
    image: busybox:1.36
    command: ["sh", "-c", "sleep 86400"]
    resources:
      requests:
        memory: 32Mi
      limits:
        memory: 64Mi
EOF

# 3) OOMKilled 기록이 한 번 생길 때까지 기다린다
for i in $(seq 1 60); do
  R=$(kubectl -n prod get pod -l app=resizer -o jsonpath='{.items[0].status.containerStatuses[0].lastState.terminated.reason}' 2>/dev/null || true)
  [ "$R" = "OOMKilled" ] && break
  sleep 3
done
kubectl -n prod wait pod cache-warm --for=condition=Ready --timeout=120s

# 4) 설정 확인: resizer 는 RESTARTS 가 늘고, cache-warm 은 1/1 Running
kubectl -n prod get pods
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `resizer` 파드는 RESTARTS 가 계속 늘고(`lastState.terminated.reason: OOMKilled`), `cache-warm` 은 `1/1 Running` 이다.
5번의 in-place resize 는 v1.33 이상(1.35 GA)과 kubectl 1.32 이상이 필요하다. 이미지 `polinux/stress` 를 받을 수 있어야 한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns prod --ignore-not-found
rm -rf /opt/course/q14
```

</details>

## Task

In namespace `prod`, Deployment `resizer` keeps restarting. `kubectl get pods` shows a
climbing `RESTARTS` count and the pod flips between `Running` and `CrashLoopBackOff`. The
image is known good; in staging the team measured a peak of about 180Mi.

1. Confirm the container is being killed for memory and not crashing on its own. State
   which field you read and what exit code you expect.
2. Report the container's current memory request and limit and its actual usage, and
   explain in one line why it was killed even though the node has free memory.
3. Set the container's memory request to `128Mi` and limit to `256Mi` on the Deployment,
   and confirm the restarts stop.
4. Write the Pod's QoS class before and after your change to `/opt/course/q14/qos.txt`,
   and state what else the container would need to become `Guaranteed`.
5. The standalone Pod `cache-warm` in `prod` (container `cache`) is healthy with a `64Mi`
   memory limit but needs more headroom before tonight's load test. Raise its memory
   request to `128Mi` and limit to `256Mi` **without deleting, recreating or restarting
   the Pod**, and show that the new values are in effect and its restart count did not
   change.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

# q17 — Give a running Pod more memory without restarting it

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.
클러스터가 v1.33 이상이어야 한다(in-place resize 는 v1.33 beta 기본 활성, v1.35 GA).

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns perf --ignore-not-found --wait=true
rm -rf /opt/course/f17

# 1) metrics-server 가 없을 때만 설치 (실습 클러스터는 --kubelet-insecure-tls 필요)
if ! kubectl -n kube-system get deploy metrics-server >/dev/null 2>&1; then
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace + 단독 파드 cache (Burstable: memory 64Mi / 128Mi)
kubectl create ns perf
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cache
  namespace: perf
  labels:
    app: cache
spec:
  containers:
  - name: app
    image: nginx:1.27
    resources:
      requests:
        memory: 64Mi
      limits:
        memory: 128Mi
EOF
kubectl -n perf wait pod cache --for=condition=Ready --timeout=120s

# 3) 답안 파일 디렉터리
mkdir -p /opt/course/f17

# 4) 첫 메트릭 수집까지 기다렸다가 확인 (1분 정도 걸릴 수 있음)
for i in $(seq 1 30); do
  kubectl -n perf top pod cache --containers >/dev/null 2>&1 && break
  sleep 5
done
kubectl -n perf top pod cache --containers
kubectl -n perf get pod cache \
  -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass,RESTARTS:.status.containerStatuses[0].restartCount
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `cache` 는 QoS `Burstable`, RESTARTS `0` 으로 보인다. `kubectl top` 이 아직
`metrics not available yet` 을 내면 1분쯤 뒤에 다시 본다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns perf --ignore-not-found
rm -rf /opt/course/f17
```

</details>

## Task

In namespace `perf`, the standalone Pod `cache` (container `app`, image `nginx:1.27`) runs
with a memory request of `64Mi` and a memory limit of `128Mi`. It is healthy but needs
more memory headroom, and it must not be restarted or recreated. metrics-server is
installed.

1. Write the current memory usage of container `app`, as reported by `kubectl top`, to
   `/opt/course/f17/usage.txt`.
2. Raise the memory request of `app` to `128Mi` and its memory limit to `256Mi` without
   deleting, recreating or restarting the Pod.
3. Verify that the Pod status reports the new memory request and limit for `app` and that
   the container's `restartCount` did not change.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

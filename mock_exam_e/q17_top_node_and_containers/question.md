# q17 — Analyse resource usage per node and container

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

<details><summary>방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기 (펼치면 파드별 사용량이 보인다)</summary>

```bash
# 0) 이전 실습 흔적 정리 (monitoring 은 흔한 이름이라 이 문제가 만든 파드만 지운다)
kubectl -n monitoring delete pod -l cka=e17 --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/course/e17

# 1) metrics-server 설치 (실습 클러스터는 --kubelet-insecure-tls 필요)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace — 없을 때만 만들고, 이 문제가 만들었다는 표시(cka=e17)를 붙인다
if ! kubectl get ns monitoring >/dev/null 2>&1; then
  kubectl create ns monitoring
  kubectl label ns monitoring cka=e17
fi

# 3) 파드 두 개 — 메모리 tmpfs(emptyDir medium: Memory)에 파일을 써서 사용량을 고정한다
#    analytics: collector ≈ 40Mi + exporter ≈ 80Mi  → 파드 합계 ≈ 120Mi
#    cache-warmer: 컨테이너 하나 ≈ 95Mi             → 컨테이너 하나로는 가장 크지만 파드 합계는 2등
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: analytics
  namespace: monitoring
  labels:
    app: analytics
    cka: e17
spec:
  containers:
  - name: collector
    image: busybox:1.36
    command: ["sh", "-c", "head -c 40m /dev/zero > /fill/data; sleep 86400"]
    resources:
      limits:
        memory: 128Mi
    volumeMounts:
    - name: fill-collector
      mountPath: /fill
  - name: exporter
    image: busybox:1.36
    command: ["sh", "-c", "head -c 80m /dev/zero > /fill/data; sleep 86400"]
    resources:
      limits:
        memory: 160Mi
    volumeMounts:
    - name: fill-exporter
      mountPath: /fill
  volumes:
  - name: fill-collector
    emptyDir:
      medium: Memory
      sizeLimit: 64Mi
  - name: fill-exporter
    emptyDir:
      medium: Memory
      sizeLimit: 100Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: cache-warmer
  namespace: monitoring
  labels:
    app: cache-warmer
    cka: e17
spec:
  containers:
  - name: warmer
    image: busybox:1.36
    command: ["sh", "-c", "head -c 95m /dev/zero > /fill/data; sleep 86400"]
    resources:
      limits:
        memory: 160Mi
    volumeMounts:
    - name: fill
      mountPath: /fill
  volumes:
  - name: fill
    emptyDir:
      medium: Memory
      sizeLimit: 120Mi
EOF
kubectl -n monitoring wait pod -l cka=e17 --for=condition=Ready --timeout=120s

# 4) 답안 파일 디렉터리
mkdir -p /opt/course/e17

# 5) 첫 수집까지 기다렸다가 확인 (1분 정도 걸릴 수 있음)
for i in $(seq 1 30); do
  kubectl -n monitoring top pod analytics --containers >/dev/null 2>&1 && break
  sleep 5
done
kubectl -n monitoring get pods
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `monitoring` 에는 이 문제용 파드 두 개(`cka=e17` 레이블)가 `Running` 이다. metrics-server 가 첫 값을 모으기까지 1분 정도 걸릴 수 있다.
노드 CPU(1번)는 클러스터 상태 그대로 답한다. `monitoring` namespace 가 이미 있으면 그대로 쓰고, 정리할 때도 이 문제가 만든 파드만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n monitoring delete pod -l cka=e17 --ignore-not-found
if [ "$(kubectl get ns monitoring -o jsonpath='{.metadata.labels.cka}' 2>/dev/null || true)" = "e17" ]; then
  kubectl delete ns monitoring --ignore-not-found
fi
rm -rf /opt/course/e17
```

</details>

## Task

metrics-server is installed and working in cluster `k8s-c1`.

1. Write the name of the node that currently uses the most CPU to `/opt/course/e17/node.txt`.
2. Pod `analytics` in namespace `monitoring` has two containers, `collector` and `exporter`. Write
   the name of the container that currently uses more memory to `/opt/course/e17/container.txt`.
3. Write the name of the pod in namespace `monitoring` that currently uses the most memory to
   `/opt/course/e17/pod.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

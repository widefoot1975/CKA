# q13 — Restore metrics-server and analyse resource usage

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 9 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **metrics-server 를 일부러 고장 낸 상태에서** 시작한다. `k8s-c1` 에서 아래 둘 중 하나를 실행한다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 metrics-server 를 원래대로 돌려놓는다 (다른 문제의 `kubectl top`·HPA 가 쓴다).

**방법 A — 명령어를 복사해서 붙여 넣기**

<details><summary>명령어 펼치기 — 고장 내는 내용이 보이니 풀기 전에는 읽지 않는 것을 권장</summary>

```bash
MS="kubectl -n kube-system"

# 0) 이전 실습 흔적 정리 (이 문제가 만든 것만)
kubectl -n prod delete deploy,hpa -l q13=b13 --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/q13

# 1) metrics-server 설치 (없으면)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 2) namespace prod (이미 있으면 그대로 쓴다) + 워크로드
#    api   : 컨테이너 app(CPU 최대 100m 사용) + log-agent(거의 놀음), 2 replicas
#    cache : polinux/stress 로 메모리 120M 를 잡고 있는 파드 → 메모리 1등
if ! kubectl get ns prod >/dev/null 2>&1; then
  kubectl create ns prod
  kubectl label ns prod q13=b13        # 이 문제가 만든 namespace 표시 (cleanup 이 비었을 때만 지운다)
fi
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: prod
  labels: {app: api, q13: b13}
spec:
  replicas: 2
  selector:
    matchLabels: {app: api}
  template:
    metadata:
      labels: {app: api, q13: b13}
    spec:
      containers:
      - name: app
        image: busybox:1.36
        command: ["sh", "-c", "while true; do :; done"]
        resources:
          requests: {cpu: 100m, memory: 16Mi}
          limits:   {cpu: 100m, memory: 64Mi}
      - name: log-agent
        image: busybox:1.36
        command: ["sh", "-c", "while true; do date; sleep 5; done"]
        resources:
          requests: {cpu: 50m, memory: 16Mi}
          limits:   {cpu: 100m, memory: 64Mi}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cache
  namespace: prod
  labels: {app: cache, q13: b13}
spec:
  replicas: 1
  selector:
    matchLabels: {app: cache}
  template:
    metadata:
      labels: {app: cache, q13: b13}
    spec:
      containers:
      - name: cache
        image: polinux/stress
        command: ["stress"]
        args: ["--vm", "1", "--vm-bytes", "120M", "--vm-hang", "0"]
        resources:
          requests: {cpu: 10m, memory: 160Mi}
          limits:   {memory: 200Mi}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api
  namespace: prod
  labels: {q13: b13}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: api}
  minReplicas: 2
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target: {type: Utilization, averageUtilization: 80}
YAML
kubectl -n prod rollout status deploy api --timeout=180s
kubectl -n prod rollout status deploy cache --timeout=180s

# 3) 고장 내기: metrics-server 에서 --kubelet-insecure-tls 를 뺀다
#    → kubelet serving 인증서(자체 서명) 검증 실패 → 파드가 Ready 가 안 됨 → APIService False
#    기존 Ready 파드가 남지 않도록 0 으로 내렸다가 args 를 바꾸고 1 로 올린다
$MS scale deploy metrics-server --replicas=0
$MS wait pod -l k8s-app=metrics-server --for=delete --timeout=120s 2>/dev/null || true
args=$($MS get deploy metrics-server \
         -o jsonpath='{range .spec.template.spec.containers[0].args[*]}{@}{"\n"}{end}' \
       | grep -v -- '--kubelet-insecure-tls' | sed 's/.*/"&"/' | paste -sd, -)
$MS patch deploy metrics-server --type=json \
  -p="[{\"op\":\"replace\",\"path\":\"/spec/template/spec/containers/0/args\",\"value\":[$args]}]"
$MS scale deploy metrics-server --replicas=1

# 4) 답안 파일 디렉터리
mkdir -p /opt/q13

# 5) 시작 상태 확인: 1분 안에 kubectl top nodes 가 실패해야 한다
for _ in $(seq 1 12); do
  kubectl top nodes >/dev/null 2>&1 || break
  sleep 5
done
if kubectl top nodes >/dev/null 2>&1; then
  echo "경고: kubectl top nodes 가 아직 동작한다. 이 클러스터의 kubelet 인증서가 CA 서명(serverTLSBootstrap)이라 고장이 재현되지 않을 수 있다." >&2
else
  echo "준비 완료: kubectl top nodes 가 실패한다."
fi
kubectl -n prod get deploy,hpa
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 후 1분 안에 `kubectl top nodes` 가 실패하고, `prod` 의 HPA `api` 는 `<unknown>` 을 보인다. `prod` 에는 deployment `api`(2 replicas, 컨테이너 `app`·`log-agent`)와 `cache` 가 있다. `/opt/q13/` 는 비어 있다.
`mock_exam_c/q14` 도 namespace `prod` 를 쓰므로 두 문제를 동시에 펼쳐 두지 않는다. 이 문제의 setup/cleanup 은 label `q13=b13` 이 붙은 리소스만 만들고 지운다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

metrics-server Deployment 의 args 에서 `--kubelet-insecure-tls` 를 뺀다. metrics-server 가 kubelet 의 자체 서명 serving 인증서를 검증하지 못해 수집에 실패하고, 파드가 Ready 가 되지 않아 APIService `v1beta1.metrics.k8s.io` 가 `False (MissingEndpoints)` 가 된다. 기존 Ready 파드가 남지 않도록 replicas 를 0 으로 내렸다가 1 로 올린다.
kubelet 인증서를 클러스터 CA 로 서명해 쓰는 클러스터(`serverTLSBootstrap: true`)에서는 고장이 재현되지 않으며, setup 이 마지막에 경고를 낸다. `cleanup.sh` 는 플래그를 다시 넣고 metrics-server 가 Ready 가 될 때까지 기다린다.

</details>

<details><summary>정리 명령 (방법 A)</summary>

```bash
MS="kubectl -n kube-system"

# 1) metrics-server 에 --kubelet-insecure-tls 가 없으면 다시 넣고 Ready 가 될 때까지 기다린다
if $MS get deploy metrics-server >/dev/null 2>&1; then
  if ! $MS get deploy metrics-server \
       -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
    $MS patch deploy metrics-server --type=json \
      -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
  fi
  $MS scale deploy metrics-server --replicas=1
  $MS rollout status deploy metrics-server --timeout=180s
fi

# 2) 이 문제가 만든 것만 지운다 (prod 를 쓰는 다른 문제의 리소스는 남긴다)
kubectl -n prod delete deploy,hpa -l q13=b13 --ignore-not-found --wait=true 2>/dev/null || true
if [ "$(kubectl get ns prod -o jsonpath='{.metadata.labels.q13}' 2>/dev/null)" = "b13" ] \
   && [ -z "$(kubectl -n prod get all -o name 2>/dev/null)" ]; then
  kubectl delete ns prod
fi
rm -rf /opt/q13
```

</details>

## Task

`kubectl top nodes` fails on this cluster. An HPA in namespace `prod` is stuck showing
`<unknown>` as a consequence.

1. Write the exact error `kubectl top nodes` prints to `/opt/q13/error.txt`.
2. Determine whether the fault is the APIService registration, the metrics-server pod, or
   the connection from metrics-server to the kubelets. Write which one, and the command
   that decided it, to `/opt/q13/cause.txt`.
3. Fix it so that `kubectl top nodes` and `kubectl top pods -A` both return numbers.
   Do not delete the metrics-server Deployment.
4. Write the name of the pod using the most memory in namespace `prod` to
   `/opt/q13/top-mem.txt`.
5. For deployment `api` in `prod`, write the per-container CPU usage to
   `/opt/q13/api-containers.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

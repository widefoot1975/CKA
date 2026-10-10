# q05 — Autoscale a Deployment with an HPA

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns autoscale --ignore-not-found --wait=true

# 1) metrics-server 설치 (실습 클러스터는 --kubelet-insecure-tls 필요)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace + Deployment apache-web (httpd:2.4, CPU request 100m)
kubectl create ns autoscale
kubectl -n autoscale create deploy apache-web --image=httpd:2.4
kubectl -n autoscale set resources deploy apache-web --requests=cpu=100m
kubectl -n autoscale rollout status deploy apache-web

# 3) 설정 확인 (metrics-server 가 값을 모으기까지 1분 정도 걸릴 수 있음)
kubectl get pods -n kube-system -l k8s-app=metrics-server
kubectl -n autoscale get deploy apache-web \
  -o jsonpath='{.spec.template.spec.containers[0].resources}{"\n"}'
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 Deployment `apache-web` 은 CPU request `100m` 을 가지고 HPA 는 없다. metrics-server 가 값을 모으기까지 1분 정도 걸릴 수 있다.
`cleanup.sh` 는 metrics-server 를 남겨 둔다(`kubectl top` 등 다른 문제에서도 쓰임).

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns autoscale --ignore-not-found
# metrics-server 는 다른 문제(kubectl top 등)에서도 쓰므로 남겨 둔다
```

</details>

## Task

Deployment `apache-web` in namespace `autoscale` runs `httpd:2.4`, and its container already
requests `100m` CPU. metrics-server is installed.

1. Create a HorizontalPodAutoscaler named `apache-web` in namespace `autoscale` with API version
   `autoscaling/v2`. It targets Deployment `apache-web` with `minReplicas: 1`, `maxReplicas: 4`
   and a target average CPU utilization of `50%`.
2. When scaling down, the HPA must use a stabilization window of `30` seconds.
3. Confirm that the HPA reports an actual CPU percentage instead of `<unknown>`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

# q09 — Publish a Service with an Ingress

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 1) Ingress 컨트롤러: F5 NGINX Ingress Controller v5.6.3 (IngressClass nginx, Service 는 NodePort)
#    은퇴한 ingress-nginx 가 아니라 nginx/kubernetes-ingress 다. 이미 설치돼 있으면 그대로 넘어간다.
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/ns-and-sa.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/rbac/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/nginx-config.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/ingress-class.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/deployment/nginx-ingress.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/service/nodeport.yaml
kubectl -n nginx-ingress rollout status deploy nginx-ingress --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace echo
kubectl delete ns echo --ignore-not-found --wait=true
kubectl create ns echo

# 3) 백엔드: 어떤 경로든 200 과 "echo" 를 돌려주는 http-echo (컨테이너 포트 5678) → Service echo-svc:8080
kubectl -n echo create deploy echo --image=hashicorp/http-echo:1.0 -- /http-echo -text=echo
kubectl -n echo expose deploy echo --name=echo-svc --port=8080 --target-port=5678
kubectl -n echo rollout status deploy echo

# 4) 시작 상태 확인: IngressClass 가 하나 있고, echo 에는 Ingress 가 없음
kubectl get ingressclass
kubectl -n echo get deploy,svc,ingress
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에는 IngressClass `nginx` 가, `echo` 에는 Deployment `echo` 와 Service `echo-svc`(8080)가 있고 Ingress 는 없다. 문제 풀이에서 직접 만든다.
컨트롤러 Service `nginx-ingress`(ns `nginx-ingress`)는 NodePort 라 Ingress ADDRESS 가 비어 있을 수 있다. 그때는 아래처럼 `<노드IP>:<NodePort>` 로 curl 한다.

```bash
NP=$(kubectl -n nginx-ingress get svc nginx-ingress -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
NODE=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: example.org' http://$NODE:$NP/echo   # 200
```

NGINX Ingress Controller 는 다른 Ingress 문제에서도 쓰므로 정리할 때 `echo` 만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns echo --ignore-not-found
```

</details>

## Task

Namespace `echo` contains Service `echo-svc`, which listens on port `8080` and returns HTTP `200`
for any path. An Ingress controller is installed in the cluster.

1. Find the name of the IngressClass that exists in the cluster.
2. Create an Ingress named `echo` in namespace `echo` that uses this IngressClass and sends
   requests for host `example.org` with path `/echo` (path type `Prefix`) to Service `echo-svc`
   on port `8080`.
3. Using `curl` against the Ingress controller with the header `Host: example.org`, confirm that
   path `/echo` returns HTTP `200`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

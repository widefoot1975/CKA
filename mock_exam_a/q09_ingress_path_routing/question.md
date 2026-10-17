# q09 — Route traffic with an Ingress

| Item | Value |
|---|---|
| Exam | mock_exam_a |
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

# 2) namespace web 준비 — 없으면 만들고, 이전 실습에서 만든 이 문제의 리소스만 지운다
kubectl create ns web --dry-run=client -o yaml | kubectl apply -f -
kubectl -n web delete ingress shop-ingress --ignore-not-found
kubectl -n web delete svc site-svc api-svc --ignore-not-found
kubectl -n web delete deploy site api --ignore-not-found --cascade=foreground --wait=true
kubectl -n web delete pod img-check --ignore-not-found --wait=true

# 3) 노드가 echoserver 이미지를 받을 수 있는지 미리 확인 (오프라인 실습 환경 대비)
kubectl -n web run img-check --image=registry.k8s.io/e2e-test-images/echoserver:2.5 --restart=Never
kubectl -n web wait --for=condition=Ready pod/img-check --timeout=120s || \
  echo "echoserver 이미지를 받지 못함 — 레지스트리 접근을 먼저 확인할 것"
kubectl -n web delete pod img-check --ignore-not-found --wait=true

# 4) 시작 상태 확인: IngressClass 가 하나 있고, web 에는 site / api / shop-ingress 가 없음
kubectl get ingressclass
kubectl -n web get deploy,svc,ingress
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에는 IngressClass `nginx` 가 있고, namespace `web` 은 있지만 이 문제의 Deployment·Service·Ingress 는 없다.
1단계부터 직접 만든다. namespace `web` 은 b05, d08, f06 도 쓰므로 setup 과 cleanup 은 namespace 를 통째로 지우지 않고
이 문제의 리소스(`site`, `api`, `site-svc`, `api-svc`, `shop-ingress`)만 지운다. 다른 문제와 동시에 풀지 않는 편이 깔끔하다.

컨트롤러 Service `nginx-ingress`(ns `nginx-ingress`)는 NodePort 라 Ingress ADDRESS 가 비어 있을 수 있다. 그때는 아래처럼
`<노드IP>:<NodePort>` 로 curl 한다.

```bash
NP=$(kubectl -n nginx-ingress get svc nginx-ingress -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
NODE=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: shop.example.com' http://$NODE:$NP/    # Ingress 를 만든 뒤 실행
```

NGINX Ingress Controller 는 다른 Ingress 문제에서도 쓰므로 정리할 때 남겨 둔다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n web delete ingress shop-ingress --ignore-not-found
kubectl -n web delete svc site-svc api-svc --ignore-not-found
kubectl -n web delete deploy site api --ignore-not-found --cascade=foreground --wait=true
kubectl -n web delete pod img-check --ignore-not-found --wait=true

if kubectl get ns web >/dev/null 2>&1; then
  left=$(kubectl -n web get deploy,sts,ds,job,cronjob,pod,svc,ingress,cm,secret,pvc -o name 2>/dev/null \
    | grep -v '^configmap/kube-root-ca.crt$' || true)
  if [ -z "$left" ]; then
    kubectl delete ns web --ignore-not-found
  else
    echo "namespace web 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
    echo "$left"
  fi
fi
```

</details>

## Task

Two applications in namespace `web` must share one hostname.

1. Create Deployments `site` and `api` in `web`, 2 replicas each, image
   `registry.k8s.io/e2e-test-images/echoserver:2.5`, container port 8080.
2. Expose each with a ClusterIP Service on port 80 targeting 8080, named `site-svc` and
   `api-svc`.
3. Find the IngressClass available in this cluster and note its name.
4. Create an Ingress `shop-ingress` in `web` for host `shop.example.com` on that class:
   `/` and everything below it → `site-svc:80`, `/api` and everything below → `api-svc:80`.
5. Add a rule routing exactly `/health` to `api-svc:80`; `/health/extra` must not match.
6. Verify all three paths with `curl` and a `Host` header.
7. State in one line what happens if `pathType` is left out of a rule.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

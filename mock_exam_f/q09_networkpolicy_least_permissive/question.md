# q09 — Choose the least permissive NetworkPolicy

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `app` 은 C13·C17 도 쓰므로 namespace 는 지우지 않고 이 문제의 파드와 정책만 정리한다. `default-deny-ingress` 가 `app` 의 모든 파드를 막으므로 C13·C17 과 동시에 펼쳐 두지 않는다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 (이 문제의 파드와 정책만, 적용했던 후보 정책 포함)
kubectl -n app delete networkpolicy default-deny-ingress allow-backend-a allow-backend-b allow-backend-c --ignore-not-found 2>/dev/null || true
kubectl -n app delete pod backend frontend --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/course/f09
#    namespace 는 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns app >/dev/null 2>&1; then
  kubectl create ns app
  kubectl label ns app cka-lab-f09=created --overwrite
fi

# 1) 파드 두 개: backend 는 8080 에서 HTTP 응답, frontend 는 busybox
kubectl -n app run backend  --image=hashicorp/http-echo:1.0 --labels=app=backend --port=8080 -- -listen=:8080 -text=backend
kubectl -n app run frontend --image=busybox:1.36 --labels=app=frontend -- sleep 3600

# 2) 이미 있는 정책 default-deny-ingress (모든 파드의 ingress 차단) — kubectl create 로는 못 만들어서 YAML
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny-ingress, namespace: app}
spec:
  podSelector: {}
  policyTypes: [Ingress]
YAML

# 3) 후보 정책 세 개 (적용하지 않고 파일로만 둔다)
mkdir -p /opt/course/f09
cat > /opt/course/f09/policy-a.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-a
  namespace: app
spec:
  podSelector:
    matchLabels: {app: backend}
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector: {}
YAML
cat > /opt/course/f09/policy-b.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-b
  namespace: app
spec:
  podSelector:
    matchLabels: {app: backend}
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector:
        matchLabels: {app: frontend}
    ports:
    - {protocol: TCP, port: 8080}
YAML
cat > /opt/course/f09/policy-c.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-c
  namespace: app
spec:
  podSelector:
    matchLabels: {app: backend}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector: {}
    ports:
    - {protocol: TCP, port: 8080}
YAML

kubectl -n app wait pod --all --for=condition=Ready --timeout=120s

# 4) 시작 상태 확인: frontend → backend 가 막혀 있어야 함 (닿으면 CNI 가 NetworkPolicy 를 지원하지 않는 것)
kubectl -n app get pods --show-labels
kubectl -n app get netpol
ls /opt/course/f09
BIP=$(kubectl -n app get pod backend -o jsonpath='{.status.podIP}')
kubectl -n app exec frontend -- wget -qO- -T 3 http://$BIP:8080 || echo "frontend → backend 막힘 (정상)"
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `app` 에는 파드 `backend`(8080 에서 `backend` 문자열 응답)와 `frontend`, NetworkPolicy `default-deny-ingress` 가 있다. `/opt/course/f09/` 에는 후보 `policy-a.yaml`·`policy-b.yaml`·`policy-c.yaml` 이 파일로만 있고 아무것도 적용되지 않았으며, `choice.txt` 는 없다.
마지막 확인에서 frontend 의 요청이 응답을 받으면 CNI 가 NetworkPolicy 를 지원하지 않는 것이다(flannel 등). 이 문제는 Calico·Cilium 같은 CNI 에서 풀어야 의미가 있다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n app delete networkpolicy default-deny-ingress allow-backend-a allow-backend-b allow-backend-c --ignore-not-found 2>/dev/null || true
kubectl -n app delete pod backend frontend --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/course/f09

# namespace 는 이 실습의 setup 이 만들었고(라벨 cka-lab-f09=created) 남은 리소스가 없을 때만 지운다
for ns in app; do
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.cka-lab-f09}' 2>/dev/null || true)" = "created" ] || continue
  left=$( { kubectl -n "$ns" get all,configmap,secret,ingress,pvc,networkpolicy -o name 2>/dev/null
            kubectl -n "$ns" get gateway,httproute -o name 2>/dev/null; } \
          | grep -v '^configmap/kube-root-ca.crt$' || true)
  if [ -z "$left" ]; then
    kubectl delete ns "$ns"
  else
    echo "namespace $ns 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
    echo "$left"
  fi
done
```

</details>

## Task

In namespace `app`, Pod `frontend` (label `app=frontend`, image `busybox:1.36`) must reach
Pod `backend` (label `app=backend`), which serves HTTP on TCP port `8080`. A default-deny
ingress NetworkPolicy already exists in `app` and currently blocks this traffic. Three
candidate policies are prepared in `/opt/course/f09/`: `policy-a.yaml`, `policy-b.yaml`
and `policy-c.yaml`.

1. Apply the one candidate that is the **least permissive** while still allowing
   `frontend` to reach `backend` on TCP port `8080`. Do not modify or delete the existing
   NetworkPolicies.
2. Write the file name of the policy you applied (for example `policy-x.yaml`) to
   `/opt/course/f09/choice.txt`.
3. Verify that `frontend` can now connect to `backend` on port `8080`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

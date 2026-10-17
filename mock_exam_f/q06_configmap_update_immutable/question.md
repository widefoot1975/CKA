# q06 — Update configuration and lock it

| Item | Value |
|---|---|
| Exam | mock_exam_f |
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
# 0) 이전 실습 흔적 정리 (immutable ConfigMap 은 수정할 수 없어서 지우고 다시 만든다)
kubectl -n web delete deploy api --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n web delete configmap app-config --ignore-not-found 2>/dev/null || true

# 1) namespace — 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns web >/dev/null 2>&1; then
  kubectl create ns web
  kubectl label ns web cka-lab-f06=created --overwrite
fi
#    ConfigMap app-config (LOG_LEVEL=debug)
kubectl -n web create configmap app-config --from-literal=LOG_LEVEL=debug

# 2) Deployment api (nginx:1.27, envFrom 으로 app-config 전체 로드)
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        envFrom:
        - configMapRef:
            name: app-config
EOF

kubectl -n web rollout status deploy api

# 3) 설정 확인: 파드 환경 변수 LOG_LEVEL=debug
kubectl -n web get configmap app-config -o jsonpath='{.data}{" immutable="}{.immutable}{"\n"}'
kubectl -n web exec deploy/api -- printenv LOG_LEVEL
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 파드 안에서 `LOG_LEVEL=debug` 가 보인다. immutable ConfigMap 은 되돌릴 수 없어서 setup 이 ConfigMap `app-config` 와 Deployment `api` 를 지우고 다시 만든다.
namespace `web` 은 A06·A09·B05·D08 도 쓰므로 namespace 는 이 setup 이 만들었고 비어 있을 때만 지운다.
`mock_exam_a/q06` 도 ConfigMap `app-config` 를, `mock_exam_a/q09` 도 Deployment `api` 를 `web` 에 만들므로 이 두 문제와는 동시에 펼쳐 두지 않는다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n web delete deploy api --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n web delete configmap app-config --ignore-not-found 2>/dev/null || true

# namespace 는 이 실습의 setup 이 만들었고(라벨 cka-lab-f06=created) 남은 리소스가 없을 때만 지운다
for ns in web; do
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.cka-lab-f06}' 2>/dev/null || true)" = "created" ] || continue
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

In namespace `web`, Deployment `api` (image `nginx:1.27`) loads all keys of ConfigMap
`app-config` as environment variables through `envFrom`. The ConfigMap currently contains
`LOG_LEVEL=debug`.

1. Change `LOG_LEVEL` in ConfigMap `app-config` to `info`.
2. Make ConfigMap `app-config` immutable so that its data can no longer be changed.
3. Make the Pods of Deployment `api` use the new value without deleting the Deployment,
   and verify with `kubectl exec` that `LOG_LEVEL=info` is set in a running Pod.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**

# q15 — A Service with no endpoints

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기** (트러블슈팅 문제라 명령어에 답이 보인다. 미리 보고 싶지 않으면 방법 B 를 쓴다)

<details><summary>설정 명령 펼치기 (답 포함)</summary>

```bash
# 0) 이전 실습 흔적 정리 — namespace shop 은 A08·C08·D05·E08·F15 도 쓰므로 namespace 는 지우지 않고
#    이 문제의 오브젝트만 지운다 (A08 도 Deployment api 를 만들므로 A08 의 api 는 여기서 바뀐다)
kubectl create ns shop --dry-run=client -o yaml | kubectl apply -f -
kubectl -n shop delete deploy api --ignore-not-found --cascade=foreground --wait=true
kubectl -n shop delete svc api-svc --ignore-not-found --wait=true

# 1) Deployment api: 파드 3개, 라벨 app=api, 컨테이너는 8080 에서 듣는다 (nginx-unprivileged 기본 포트)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: shop
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: nginxinc/nginx-unprivileged:1.27
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          periodSeconds: 5
YAML

# 2) Service api-svc — 고장 두 개: selector 가 app=api-server, targetPort 가 80
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: api-svc
  namespace: shop
spec:
  selector:
    app: api-server
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
YAML

kubectl -n shop rollout status deploy api --timeout=120s

# 3) 시작 상태 확인: 파드 3개 Ready, EndpointSlice 의 ENDPOINTS 는 비어 있음
kubectl -n shop get pods -l app=api
kubectl -n shop get endpointslice -l kubernetes.io/service-name=api-svc
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `shop` 에는 Deployment `api`(파드 3개, Ready)와 Service `api-svc`(port 80)가 있고, EndpointSlice 의 ENDPOINTS 는 비어 있다.
`shop` 은 A08·C08·D05·E08·F15 도 쓰는 namespace 라서 setup·cleanup 은 namespace 를 통째로 지우지 않고 `api`·`api-svc` 만 지운다.
다만 A08 도 Deployment `api` 를 만들므로 A08 과는 동시에 펼쳐 두지 않는다. cleanup 은 `shop` 에 다른 리소스가 없을 때만 namespace 를 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
# 이 문제의 오브젝트만 지운다 (namespace shop 은 다른 문제도 쓴다)
kubectl -n shop delete deploy api --ignore-not-found --cascade=foreground --wait=true
kubectl -n shop delete svc api-svc --ignore-not-found --wait=true
kubectl -n shop delete pod tmp --ignore-not-found

# shop 에 다른 문제의 리소스가 남아 있지 않으면 namespace 도 지운다
left=$(kubectl api-resources --verbs=list --namespaced -o name 2>/dev/null \
  | grep -vE '^(events|events\.events\.k8s\.io|endpoints|endpointslices\.discovery\.k8s\.io)$|metrics\.k8s\.io$' | paste -sd, - \
  | xargs -r kubectl -n shop get --ignore-not-found -o name 2>/dev/null \
  | grep -vE '^(configmap/kube-root-ca\.crt|serviceaccount/default)$' || true)
if [ -z "$left" ]; then
  kubectl delete ns shop --ignore-not-found
else
  echo "namespace shop 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
  echo "$left"
fi
```

</details>

## Task

Service `api-svc` in namespace `shop` accepts connections but every client gets
`connection refused`. Three pods of Deployment `api` are running.

1. Show that the Service has no endpoints, once through its Endpoints object and once
   through its EndpointSlice.
2. Compare the Service selector against the labels actually present on the pods.
3. Report whether the pods are `Ready`.
4. Compare the Service `targetPort` against the port the container actually listens on.
5. Fix the Service so three endpoints appear. Do not relabel, restart or recreate the pods.
6. Write in one line the two independent reasons an endpoint list can be empty.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
